import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/api_exception.dart';
import 'config_service.dart';

class TokenMeta {
  final String id;
  final String name;
  final String prefix;
  final String status;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;

  TokenMeta({
    required this.id,
    required this.name,
    required this.prefix,
    required this.status,
    this.createdAt,
    this.lastUsedAt,
  });

  factory TokenMeta.fromJson(Map<String, dynamic> json) {
    return TokenMeta(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Token',
      prefix: json['prefix'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      lastUsedAt: json['lastUsedAt'] != null ? DateTime.tryParse(json['lastUsedAt']) : null,
    );
  }

  bool get isActive => status == 'active';
}

class TokenService {
  TokenService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  String get _base =>
      ConfigService.getDesafogApiBaseUrl().replaceAll(RegExp(r'/+$'), '');

  Future<String> _bearerToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw ApiException(message: 'Faça login.');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw ApiException(message: 'Sessão expirada.');
    }
    return token;
  }

  Future<List<TokenMeta>> listTokens() async {
    final token = await _bearerToken();
    final resp = await _dio.get(
      '$_base/api/app/tokens/list',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final list = (resp.data['tokens'] as List?) ?? [];
    return list.map((t) => TokenMeta.fromJson(t as Map<String, dynamic>)).toList();
  }

  Future<({String rawToken, TokenMeta meta})> createToken({String name = 'Token'}) async {
    final token = await _bearerToken();
    final resp = await _dio.post(
      '$_base/api/app/tokens/create',
      data: {'name': name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final raw = resp.data['token'] as String;
    final meta = TokenMeta.fromJson(resp.data['meta'] as Map<String, dynamic>);
    return (rawToken: raw, meta: meta);
  }

  Future<void> revokeToken(String tokenId) async {
    final token = await _bearerToken();
    await _dio.post(
      '$_base/api/app/tokens/revoke',
      data: {'tokenId': tokenId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<({String rawToken, TokenMeta meta})> regenerateToken(String tokenId) async {
    final token = await _bearerToken();
    final resp = await _dio.post(
      '$_base/api/app/tokens/regenerate',
      data: {'tokenId': tokenId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final raw = resp.data['token'] as String;
    final meta = TokenMeta.fromJson(resp.data['meta'] as Map<String, dynamic>);
    return (rawToken: raw, meta: meta);
  }
}
