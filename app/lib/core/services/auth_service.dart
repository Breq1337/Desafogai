import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // Google OAuth 2.0 Web Client ID from Firebase Console
  static const String _webClientId = '557072901026-oaroa6g4bvl55nhlhaentrnl0oigsnuk.apps.googleusercontent.com';

  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _providedGoogleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final GoogleSignIn? _providedGoogleSignIn;
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _google {
    if (_googleSignIn != null || _providedGoogleSignIn != null) {
      return _googleSignIn ??= _providedGoogleSignIn!;
    }
    // On web, provide explicit clientId; on mobile, let Google Sign-In SDK determine it
    return _googleSignIn ??= GoogleSignIn(
      clientId: kIsWeb ? _webClientId : null,
    );
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        return _auth.signInWithPopup(GoogleAuthProvider());
      } on FirebaseAuthException catch (e) {
        throw GoogleSignInFailedException.fromFirebaseAuthException(e);
      }
    }

    final googleUser = await _google.signIn();
    if (googleUser == null) {
      throw GoogleSignInCancelledException();
    }

    try {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw GoogleSignInFailedException.fromFirebaseAuthException(e);
    }
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
}

class GoogleSignInCancelledException implements Exception {
  @override
  String toString() => 'Login com Google cancelado.';
}

class GoogleSignInFailedException implements Exception {
  GoogleSignInFailedException(this.code, this.message);

  final String code;
  final String message;

  factory GoogleSignInFailedException.fromFirebaseAuthException(
    FirebaseAuthException e,
  ) {
    final code = e.code;
    final message = switch (code) {
      'operation-not-allowed' =>
        'Login com Google não está habilitado no Firebase Authentication.',
      'popup-blocked' =>
        'O navegador bloqueou a janela de login do Google. Permita popups e tente novamente.',
      'popup-closed-by-user' =>
        'A janela de login do Google foi fechada antes da conclusão.',
      'account-exists-with-different-credential' =>
        'Já existe conta com este e-mail usando outro método de login.',
      'unauthorized-domain' =>
        'Domínio não autorizado no Firebase para login com Google.',
      _ => e.message ?? 'Falha no login com Google.',
    };
    return GoogleSignInFailedException(code, message);
  }

  @override
  String toString() => message;
}
