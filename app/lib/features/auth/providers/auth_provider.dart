import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final isDemoUserProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user != null && user.isAnonymous;
});
