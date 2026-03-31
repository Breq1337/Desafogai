import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for generating one-time codes to link Telegram to a Firebase account.
abstract final class TelegramLinkService {
  static final _firestore = FirebaseFirestore.instance;

  /// Generate a 6-char alphanumeric code and store in Firestore.
  /// Returns the code, or null if the user is not authenticated.
  static Future<String?> generateLinkCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final code = _randomCode(6);

    final expiresAt = DateTime.now().add(const Duration(minutes: 15));

    await _firestore.collection('link_codes').add({
      'uid': user.uid,
      'code': code,
      'used': false,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });

    return code;
  }

  /// Check if the current user has a linked Telegram account.
  static Future<bool> isLinked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snap = await _firestore
        .collection('telegram_links')
        .where('firebaseUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  /// Unlink the Telegram account.
  static Future<void> unlink() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await _firestore
        .collection('telegram_links')
        .where('firebaseUid', isEqualTo: user.uid)
        .get();

    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  static String _randomCode(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
