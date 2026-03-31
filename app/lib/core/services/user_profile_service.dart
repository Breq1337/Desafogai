import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    this.bio = '',
    this.monthlyIncome = 0,
    this.address = '',
    this.occupation = '',
    this.age,
  });

  final String displayName;
  final String email;
  final String photoUrl;
  final String bio;
  final double monthlyIncome;
  final String address;
  final String occupation;
  final int? age;

  factory UserProfile.empty(User? user) {
    return UserProfile(
      displayName: user?.displayName?.trim() ?? '',
      email: user?.email?.trim() ?? '',
      photoUrl: user?.photoURL?.trim() ?? '',
    );
  }
}

abstract final class UserProfileService {
  static Stream<UserProfile> watchProfile(String uid) {
    final auth = FirebaseAuth.instance;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((doc) {
      final user = auth.currentUser;
      final data = doc.data() ?? <String, dynamic>{};
      return UserProfile(
        displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
            ? (data['displayName'] as String).trim()
            : (user?.displayName?.trim() ?? ''),
        email: user?.email?.trim() ?? '',
        photoUrl: (data['photoUrl'] as String?)?.trim().isNotEmpty == true
            ? (data['photoUrl'] as String).trim()
            : (user?.photoURL?.trim() ?? ''),
        bio: (data['bio'] as String?)?.trim() ?? '',
        monthlyIncome: (data['monthlyIncome'] as num?)?.toDouble() ?? 0,
        address: (data['address'] as String?)?.trim() ?? '',
        occupation: (data['occupation'] as String?)?.trim() ?? '',
        age: (data['age'] as num?)?.toInt(),
      );
    });
  }

  static Future<void> saveProfile({
    required String uid,
    required String displayName,
    String bio = '',
    double? monthlyIncome,
    String? address,
    String? occupation,
    int? age,
  }) async {
    final authUser = FirebaseAuth.instance.currentUser;
    final normalizedName = displayName.trim();

    final fields = <String, dynamic>{
      'displayName': normalizedName,
      'bio': bio.trim(),
      'photoUrl': authUser?.photoURL ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (monthlyIncome != null) fields['monthlyIncome'] = monthlyIncome;
    if (address != null) fields['address'] = address.trim();
    if (occupation != null) fields['occupation'] = occupation.trim();
    if (age != null) fields['age'] = age;

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      fields,
      SetOptions(merge: true),
    );

    if (authUser != null && normalizedName.isNotEmpty && authUser.displayName != normalizedName) {
      await authUser.updateDisplayName(normalizedName);
    }

    if (monthlyIncome != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('main')
          .set({'monthlyIncome': monthlyIncome}, SetOptions(merge: true));
    }
  }

  static Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List bytes,
  }) async {
    final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final photoUrl = await ref.getDownloadURL();

    final authUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (authUser != null) {
      await authUser.updatePhotoURL(photoUrl);
    }

    return photoUrl;
  }
}
