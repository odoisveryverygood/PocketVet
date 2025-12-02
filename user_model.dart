import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final bool isPremium;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.isPremium = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ----------------------------------------------------
  // CONVERT CLASS → FIRESTORE MAP
  // ----------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ----------------------------------------------------
  // CREATE CLASS FROM FIRESTORE MAP
  // ----------------------------------------------------
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      isPremium: map['isPremium'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // ----------------------------------------------------
  // COPYWITH (FOR UPDATING USER FIELDS)
  // ----------------------------------------------------
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isPremium,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
