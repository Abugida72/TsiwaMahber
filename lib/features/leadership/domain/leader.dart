import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

enum EdirLeaderRole {
  likeMenber,
  mLikeMenber,
  tsehafi,
  hisabShum,
  gimjaBet;

  String get displayName {
    switch (this) {
      case EdirLeaderRole.likeMenber:
        return S.edirChairman;
      case EdirLeaderRole.mLikeMenber:
        return S.edirViceChairman;
      case EdirLeaderRole.tsehafi:
        return S.edirSecretary;
      case EdirLeaderRole.hisabShum:
        return S.edirAccountant;
      case EdirLeaderRole.gimjaBet:
        return S.edirTreasurer;
    }
  }

  String get firestoreValue {
    switch (this) {
      case EdirLeaderRole.likeMenber:
        return 'like_menber';
      case EdirLeaderRole.mLikeMenber:
        return 'm_like_menber';
      case EdirLeaderRole.tsehafi:
        return 'tsehafi';
      case EdirLeaderRole.hisabShum:
        return 'hisab_shum';
      case EdirLeaderRole.gimjaBet:
        return 'gimja_bet';
    }
  }

  static EdirLeaderRole? fromString(String? value) {
    switch (value) {
      case 'like_menber':
        return EdirLeaderRole.likeMenber;
      case 'm_like_menber':
        return EdirLeaderRole.mLikeMenber;
      case 'tsehafi':
        return EdirLeaderRole.tsehafi;
      case 'hisab_shum':
        return EdirLeaderRole.hisabShum;
      case 'gimja_bet':
        return EdirLeaderRole.gimjaBet;
      default:
        return null;
    }
  }
}

enum LeaderRole {
  owner,
  amerar,
  memakir,
  edirAmerar,
  viewer;

  String get displayName {
    switch (this) {
      case LeaderRole.owner:
        return S.leaderOwner;
      case LeaderRole.amerar:
        return S.leaderAmerar;
      case LeaderRole.memakir:
        return S.leaderMemakir;
      case LeaderRole.edirAmerar:
        return S.leaderEdirAmerar;
      case LeaderRole.viewer:
        return S.leaderViewerRole;
    }
  }

  String get firestoreValue {
    switch (this) {
      case LeaderRole.owner:
        return 'owner';
      case LeaderRole.amerar:
        return 'amerar';
      case LeaderRole.memakir:
        return 'memakir';
      case LeaderRole.edirAmerar:
        return 'edir_amerar';
      case LeaderRole.viewer:
        return 'viewer';
    }
  }

  static LeaderRole fromString(String? value) {
    switch (value) {
      case 'owner':
        return LeaderRole.owner;
      case 'amerar':
        return LeaderRole.amerar;
      case 'memakir':
        return LeaderRole.memakir;
      case 'edir_amerar':
        return LeaderRole.edirAmerar;
      default:
        return LeaderRole.viewer;
    }
  }
}

class Leader {
  final String id;
  final String fullName;
  final String christianName;
  final String phone;
  final String phone2;
  final LeaderRole role;
  final List<String> assignedTsiwaIds;
  final List<String> assignedEdirIds;
  final EdirLeaderRole? edirRole;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Leader({
    this.id = '',
    this.fullName = '',
    this.christianName = '',
    this.phone = '',
    this.phone2 = '',
    this.role = LeaderRole.viewer,
    this.assignedTsiwaIds = const [],
    this.assignedEdirIds = const [],
    this.edirRole,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Leader.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Leader(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      christianName: data['christianName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      phone2: data['phone2'] as String? ?? '',
      role: LeaderRole.fromString(data['role'] as String?),
      assignedTsiwaIds: List<String>.from(
          data['assignedTsiwaIds'] as List<dynamic>? ?? []),
      assignedEdirIds: List<String>.from(
          data['assignedEdirIds'] as List<dynamic>? ?? []),
      edirRole: EdirLeaderRole.fromString(data['edirRole'] as String?),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'fullName': fullName,
      'christianName': christianName,
      'phone': phone,
      'phone2': phone2,
      'role': role.firestoreValue,
      'assignedTsiwaIds': assignedTsiwaIds,
      'assignedEdirIds': assignedEdirIds,
      'edirRole': edirRole?.firestoreValue,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'fullName': fullName,
      'christianName': christianName,
      'phone': phone,
      'phone2': phone2,
      'role': role.firestoreValue,
      'assignedTsiwaIds': assignedTsiwaIds,
      'assignedEdirIds': assignedEdirIds,
      'edirRole': edirRole?.firestoreValue,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Leader copyWith({
    String? id,
    String? fullName,
    String? christianName,
    String? phone,
    String? phone2,
    LeaderRole? role,
    List<String>? assignedTsiwaIds,
    List<String>? assignedEdirIds,
    EdirLeaderRole? edirRole,
    bool? isActive,
  }) {
    return Leader(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      christianName: christianName ?? this.christianName,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      role: role ?? this.role,
      assignedTsiwaIds: assignedTsiwaIds ?? this.assignedTsiwaIds,
      assignedEdirIds: assignedEdirIds ?? this.assignedEdirIds,
      edirRole: edirRole ?? this.edirRole,
      isActive: isActive ?? this.isActive,
    );
  }
}
