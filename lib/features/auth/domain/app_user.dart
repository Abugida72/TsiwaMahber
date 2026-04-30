import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

enum UserRole {
  developer,
  admin,
  leader,
  member,
  viewer;

  String get displayName {
    switch (this) {
      case UserRole.developer:
        return S.roleDeveloper;
      case UserRole.admin:
        return S.roleAdmin;
      case UserRole.leader:
        return S.roleLeader;
      case UserRole.member:
        return S.roleMember;
      case UserRole.viewer:
        return S.roleViewer;
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
  final String passwordCode;
  final UserRole role;
  final String areaId;
  final bool isActive;
  final bool kickedOut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    this.uid = '',
    this.email = '',
    this.displayName = '',
    this.phone = '',
    this.passwordCode = '',
    this.role = UserRole.viewer,
    this.areaId = '',
    this.isActive = true,
    this.kickedOut = false,
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
      passwordCode: data['passwordCode'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      areaId: data['areaId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      kickedOut: data['kickedOut'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> data, String docId) {
    return AppUser(
      uid: docId,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      passwordCode: data['passwordCode'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      areaId: data['areaId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      kickedOut: data['kickedOut'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'passwordCode': passwordCode,
      'role': role.firestoreValue,
      'areaId': areaId,
      'isActive': true,
      'kickedOut': false,
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
    String? passwordCode,
    UserRole? role,
    String? areaId,
    bool? isActive,
    bool? kickedOut,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      passwordCode: passwordCode ?? this.passwordCode,
      role: role ?? this.role,
      areaId: areaId ?? this.areaId,
      isActive: isActive ?? this.isActive,
      kickedOut: kickedOut ?? this.kickedOut,
    );
  }
}
