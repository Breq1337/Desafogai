import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/auth_service.dart';

String authErrorMessage(Object error) {
  if (error is GoogleSignInCancelledException) {
    return 'Login com Google cancelado.';
  }
  if (error is GoogleSignInFailedException) {
    return error.message;
  }

  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'user-not-found' => 'Nenhuma conta encontrada com este e-mail.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-credential' => 'E-mail ou senha incorretos.',
      'email-already-in-use' => 'Este e-mail já está em uso.',
      'weak-password' => 'Senha fraca. Use pelo menos 5 caracteres e 1 símbolo.',
      'invalid-email' => 'E-mail inválido.',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
      'network-request-failed' => 'Sem conexão com a internet.',
      'operation-not-allowed' => 'Este método de login não está habilitado.',
      'unauthorized-domain' => 'Domínio não autorizado para login no Firebase.',
      _ => error.message ?? 'Erro de autenticação.',
    };
  }

  return 'Ocorreu um erro inesperado.';
}
