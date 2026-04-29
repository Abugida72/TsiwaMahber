import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentType {
  monthly,
  penalty,
  other;

  String get displayName {
    switch (this) {
      case PaymentType.monthly:
        return 'ወርሃዊ';
      case PaymentType.penalty:
        return 'ቅጣት';
      case PaymentType.other:
        return 'ሌላ';
    }
  }

  String get firestoreValue {
    switch (this) {
      case PaymentType.monthly:
        return 'monthly';
      case PaymentType.penalty:
        return 'penalty';
      case PaymentType.other:
        return 'other';
    }
  }

  static PaymentType fromString(String? value) {
    switch (value) {
      case 'monthly':
        return PaymentType.monthly;
      case 'penalty':
        return PaymentType.penalty;
      default:
        return PaymentType.other;
    }
  }
}

class Payment {
  final String id;
  final String memberId;
  final String memberName;
  final PaymentType type;
  final double amount;
  final String note;
  final int? forMonth;
  final int? forYear;
  final DateTime? createdAt;

  const Payment({
    this.id = '',
    this.memberId = '',
    this.memberName = '',
    this.type = PaymentType.monthly,
    this.amount = 0,
    this.note = '',
    this.forMonth,
    this.forYear,
    this.createdAt,
  });

  factory Payment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Payment(
      id: doc.id,
      memberId: data['memberId'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      type: PaymentType.fromString(data['type'] as String?),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      note: data['note'] as String? ?? '',
      forMonth: data['forMonth'] as int?,
      forYear: data['forYear'] as int?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'type': type.firestoreValue,
      'amount': amount,
      'note': note,
      'forMonth': forMonth,
      'forYear': forYear,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
