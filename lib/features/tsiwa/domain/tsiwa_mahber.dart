import 'package:cloud_firestore/cloud_firestore.dart';

class TsiwaMahber {
  final String id;
  final String areaId;

  final String name;
  final String churchName;
  final String saintName;
  final String location;
  final String description;

  final int monthlyTsiwaDay;
  final String monthlyTsiwaDayNote;

  final String zikirTitle;
  final int? zikirMonth;
  final int? zikirDay;
  final String zikirNote;

  final String feedingTitle;
  final int? feedingMonth;
  final int? feedingDay;
  final String feedingNote;

  final int currentRotationIndex;
  final int memberCount;
  final int museCount;

  final bool isActive;
  final bool isArchived;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TsiwaMahber({
    this.id = '',
    this.areaId = '',
    this.name = '',
    this.churchName = '',
    this.saintName = '',
    this.location = '',
    this.description = '',
    this.monthlyTsiwaDay = 1,
    this.monthlyTsiwaDayNote = '',
    this.zikirTitle = 'የዝክር ቀን',
    this.zikirMonth,
    this.zikirDay,
    this.zikirNote = '',
    this.feedingTitle = 'ነድያንን የማብላት ቀን',
    this.feedingMonth,
    this.feedingDay,
    this.feedingNote = '',
    this.currentRotationIndex = 0,
    this.memberCount = 0,
    this.museCount = 0,
    this.isActive = true,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
  });

  factory TsiwaMahber.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String areaId,
  ) {
    final data = doc.data()!;
    return TsiwaMahber(
      id: doc.id,
      areaId: areaId,
      name: data['name'] as String? ?? '',
      churchName: data['churchName'] as String? ?? '',
      saintName: data['saintName'] as String? ?? '',
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      monthlyTsiwaDay: data['monthlyTsiwaDay'] as int? ?? 1,
      monthlyTsiwaDayNote: data['monthlyTsiwaDayNote'] as String? ?? '',
      zikirTitle: data['zikirTitle'] as String? ?? 'የዝክር ቀን',
      zikirMonth: data['zikirMonth'] as int?,
      zikirDay: data['zikirDay'] as int?,
      zikirNote: data['zikirNote'] as String? ?? '',
      feedingTitle: data['feedingTitle'] as String? ?? 'ነድያንን የማብላት ቀን',
      feedingMonth: data['feedingMonth'] as int?,
      feedingDay: data['feedingDay'] as int?,
      feedingNote: data['feedingNote'] as String? ?? '',
      currentRotationIndex: data['currentRotationIndex'] as int? ?? 0,
      memberCount: data['memberCount'] as int? ?? 0,
      museCount: data['museCount'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'churchName': churchName,
      'saintName': saintName,
      'location': location,
      'description': description,
      'monthlyTsiwaDay': monthlyTsiwaDay,
      'monthlyTsiwaDayNote': monthlyTsiwaDayNote,
      'zikirTitle': zikirTitle,
      'zikirMonth': zikirMonth,
      'zikirDay': zikirDay,
      'zikirNote': zikirNote,
      'feedingTitle': feedingTitle,
      'feedingMonth': feedingMonth,
      'feedingDay': feedingDay,
      'feedingNote': feedingNote,
      'currentRotationIndex': currentRotationIndex,
      'memberCount': memberCount,
      'museCount': museCount,
      'isActive': isActive,
      'isArchived': isArchived,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'churchName': churchName,
      'saintName': saintName,
      'location': location,
      'description': description,
      'monthlyTsiwaDay': monthlyTsiwaDay,
      'monthlyTsiwaDayNote': monthlyTsiwaDayNote,
      'zikirTitle': zikirTitle,
      'zikirMonth': zikirMonth,
      'zikirDay': zikirDay,
      'zikirNote': zikirNote,
      'feedingTitle': feedingTitle,
      'feedingMonth': feedingMonth,
      'feedingDay': feedingDay,
      'feedingNote': feedingNote,
      'isActive': isActive,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TsiwaMahber copyWith({
    String? id,
    String? areaId,
    String? name,
    String? churchName,
    String? saintName,
    String? location,
    String? description,
    int? monthlyTsiwaDay,
    String? monthlyTsiwaDayNote,
    String? zikirTitle,
    int? zikirMonth,
    int? zikirDay,
    String? zikirNote,
    String? feedingTitle,
    int? feedingMonth,
    int? feedingDay,
    String? feedingNote,
    int? currentRotationIndex,
    int? memberCount,
    int? museCount,
    bool? isActive,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TsiwaMahber(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      name: name ?? this.name,
      churchName: churchName ?? this.churchName,
      saintName: saintName ?? this.saintName,
      location: location ?? this.location,
      description: description ?? this.description,
      monthlyTsiwaDay: monthlyTsiwaDay ?? this.monthlyTsiwaDay,
      monthlyTsiwaDayNote: monthlyTsiwaDayNote ?? this.monthlyTsiwaDayNote,
      zikirTitle: zikirTitle ?? this.zikirTitle,
      zikirDay: zikirDay ?? this.zikirDay,
      zikirMonth: zikirMonth ?? this.zikirMonth,
      zikirNote: zikirNote ?? this.zikirNote,
      feedingTitle: feedingTitle ?? this.feedingTitle,
      feedingMonth: feedingMonth ?? this.feedingMonth,
      feedingDay: feedingDay ?? this.feedingDay,
      feedingNote: feedingNote ?? this.feedingNote,
      currentRotationIndex: currentRotationIndex ?? this.currentRotationIndex,
      memberCount: memberCount ?? this.memberCount,
      museCount: museCount ?? this.museCount,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
