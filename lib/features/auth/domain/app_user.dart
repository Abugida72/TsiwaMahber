import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  developer,
  admin,
  leader,
  member,
  viewer;

  String get displayName {
    switch (this) {
      case UserRole.developer:
        return 'ገንቢ';
      case UserRole.admin:
        return 'አስተዳዳሪ';
      case UserRole.leader:
        return 'አመራር';
      case UserRole.member:
        return 'አባል';
      case UserRole.viewer:
        return 'ታዛቢ';
    }
  }

  String get firestoreValue {
    switch (this) {
      case UserRole.developer:
        return 'developer';
      case UserRole.admin:
        return 'admin';
      case UserRole.leader:
        return 'leader';
      case UserRole.member:
        return 'member';
      case UserRole.viewer:
        return 'viewer';
    }
  }

  static UserRole fromString(String? value) {
    switch (value) {
      case 'developer':
        return UserRole.developer;
      case 'admin':
        return UserRole.admin;
      case 'leader':
        return UserRole.leader;
      case 'member':
        return UserRole.member;
      default:
        return UserRole.viewer;
    }
  }

  bool get isDeveloper => this == UserRole.developer;

  bool get isAdminOrAbove =>
      this == UserRole.developer || this == UserRole.admin;

  bool get canEdit =>
      this == UserRole.developer ||
      this == UserRole.admin ||
      this == UserRole.leader;

  bool get canDelete =>
      this == UserRole.developer || this == UserRole.admin;

  bool get canManageUsers =>
      this == UserRole.developer || this == UserRole.admin;

  bool get canCreateArea => this == UserRole.developer;

  bool get canManageDevelopers => this == UserRole.developer;

  bool get canAnnounce =>
      this == UserRole.developer ||
      this == UserRole.admin ||
      this == UserRole.leader;

  bool get isViewOnly =>
      this == UserRole.member || this == UserRole.viewer;
}

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final UserRole role;
  final String areaId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    this.uid = '',
    this.email = '',
    this.displayName = '',
    this.phone = '',
    this.role = UserRole.viewer,
    this.areaId = 'gelan',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      areaId: data['areaId'] as String? ?? 'gelan',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'role': role.firestoreValue,
      'areaId': areaId,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'displayName': displayName,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    UserRole? role,
    String? areaId,
    bool? isActive,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      areaId: areaId ?? this.areaId,
      isActive: isActive ?? this.isActive,
    );
  }
}
