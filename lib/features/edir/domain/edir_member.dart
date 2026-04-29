import 'package:cloud_firestore/cloud_firestore.dart';

enum EdirMemberStatus {
  active,
  inactive,
  suspended;

  String get displayName {
    switch (this) {
      case EdirMemberStatus.active:
        return 'ንቁ';
      case EdirMemberStatus.inactive:
        return 'ቦዝኗል';
      case EdirMemberStatus.suspended:
        return 'የታገደ';
    }
  }

  String get firestoreValue {
    switch (this) {
      case EdirMemberStatus.active:
        return 'active';
      case EdirMemberStatus.inactive:
        return 'inactive';
      case EdirMemberStatus.suspended:
        return 'suspended';
    }
  }

  static EdirMemberStatus fromString(String? value) {
    switch (value) {
      case 'inactive':
        return EdirMemberStatus.inactive;
      case 'suspended':
        return EdirMemberStatus.suspended;
      default:
        return EdirMemberStatus.active;
    }
  }
}

class EdirMember {
  final String id;
  final String fullName;
  final String christianName;
  final String phone;
  final EdirMemberStatus status;
  final double totalPaid;
  final double balance;
  final int paidMonths;
  final DateTime? lastPaymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EdirMember({
    this.id = '',
    this.fullName = '',
    this.christianName = '',
    this.phone = '',
    this.status = EdirMemberStatus.active,
    this.totalPaid = 0,
    this.balance = 0,
    this.paidMonths = 0,
    this.lastPaymentDate,
    this.createdAt,
    this.updatedAt,
  });

  factory EdirMember.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return EdirMember(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      christianName: data['christianName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      status: EdirMemberStatus.fromString(data['status'] as String?),
      totalPaid: (data['totalPaid'] as num?)?.toDouble() ?? 0,
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      paidMonths: data['paidMonths'] as int? ?? 0,
      lastPaymentDate:
          (data['lastPaymentDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'fullName': fullName,
      'christianName': christianName,
      'phone': phone,
      'status': status.firestoreValue,
      'totalPaid': 0,
      'balance': 0,
      'paidMonths': 0,
      'lastPaymentDate': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'fullName': fullName,
      'christianName': christianName,
      'phone': phone,
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  EdirMember copyWith({
    String? id,
    String? fullName,
    String? christianName,
    String? phone,
    EdirMemberStatus? status,
    double? totalPaid,
    double? balance,
    int? paidMonths,
    DateTime? lastPaymentDate,
  }) {
    return EdirMember(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      christianName: christianName ?? this.christianName,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      totalPaid: totalPaid ?? this.totalPaid,
      balance: balance ?? this.balance,
      paidMonths: paidMonths ?? this.paidMonths,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
    );
  }
}
