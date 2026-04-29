import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';

enum CsvEntityType {
  tsiwaMembers,
  leaders,
  edirMembers;

  String get displayName {
    switch (this) {
      case CsvEntityType.tsiwaMembers:
        return 'የፅዋ አባላት';
      case CsvEntityType.leaders:
        return 'አመራሮች';
      case CsvEntityType.edirMembers:
        return 'የእድር አባላት';
    }
  }

  String get fileName {
    switch (this) {
      case CsvEntityType.tsiwaMembers:
        return 'tsiwa_members';
      case CsvEntityType.leaders:
        return 'leaders';
      case CsvEntityType.edirMembers:
        return 'edir_members';
    }
  }
}

class CsvService {
  final FirebaseFirestore _firestore;

  CsvService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Headers ──

  static const List<String> memberHeaders = [
    'ሙሉ ስም',
    'የክርስትና ስም',
    'ስልክ',
    'ስልክ 2',
    'መለያ ቁጥር',
    'አድራሻ',
    'ሚና',
    'ተራ ቁጥር',
  ];

  static const List<String> leaderHeaders = [
    'ሙሉ ስም',
    'የክርስትና ስም',
    'ስልክ',
    'ስልክ 2',
    'ሚና',
  ];

  static const List<String> edirMemberHeaders = [
    'ሙሉ ስም',
    'የክርስትና ስም',
    'ስልክ',
    'ሁኔታ',
  ];

  // ── Export ──

  Future<String> exportMembers(String areaId, String tsiwaId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.members(areaId, tsiwaId))
        .where('deletedAt', isNull: true)
        .orderBy('orderIndex')
        .get();

    final rows = <List<String>>[memberHeaders];
    for (final doc in snapshot.docs) {
      final m = Member.fromDoc(doc);
      rows.add([
        m.fullName,
        m.christianName,
        m.phone,
        m.phone2,
        m.idNumber,
        m.address,
        m.role.displayName,
        m.orderIndex.toString(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<String> exportLeaders(String areaId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.leaders(areaId))
        .orderBy('role')
        .get();

    final rows = <List<String>>[leaderHeaders];
    for (final doc in snapshot.docs) {
      final l = Leader.fromDoc(doc);
      rows.add([
        l.fullName,
        l.christianName,
        l.phone,
        l.phone2,
        l.role.displayName,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<String> exportEdirMembers(String areaId, String edirId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.edirMembers(areaId, edirId))
        .orderBy('fullName')
        .get();

    final rows = <List<String>>[edirMemberHeaders];
    for (final doc in snapshot.docs) {
      final m = EdirMember.fromDoc(doc);
      rows.add([
        m.fullName,
        m.christianName,
        m.phone,
        m.status.displayName,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  // ── Import ──

  Future<List<Member>> parseMembersCsv(String csvContent) async {
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.length < 2) return [];

    final members = <Member>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;

      final roleName = row.length > 6 ? row[6].toString().trim() : '';
      final orderStr = row.length > 7 ? row[7].toString().trim() : '0';

      members.add(Member(
        fullName: row[0].toString().trim(),
        christianName: row[1].toString().trim(),
        phone: row[2].toString().trim(),
        phone2: row[3].toString().trim(),
        idNumber: row[4].toString().trim(),
        address: row[5].toString().trim(),
        role: _parseMemberRole(roleName),
        orderIndex: int.tryParse(orderStr) ?? 0,
      ));
    }

    return members;
  }

  Future<List<Leader>> parseLeadersCsv(String csvContent) async {
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.length < 2) return [];

    final leaders = <Leader>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 3) continue;

      final roleName = row.length > 4 ? row[4].toString().trim() : '';

      leaders.add(Leader(
        fullName: row[0].toString().trim(),
        christianName: row[1].toString().trim(),
        phone: row[2].toString().trim(),
        phone2: row.length > 3 ? row[3].toString().trim() : '',
        role: _parseLeaderRole(roleName),
      ));
    }

    return leaders;
  }

  Future<List<EdirMember>> parseEdirMembersCsv(String csvContent) async {
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.length < 2) return [];

    final members = <EdirMember>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 3) continue;

      final statusName = row.length > 3 ? row[3].toString().trim() : '';

      members.add(EdirMember(
        fullName: row[0].toString().trim(),
        christianName: row[1].toString().trim(),
        phone: row[2].toString().trim(),
        status: _parseEdirMemberStatus(statusName),
      ));
    }

    return members;
  }

  // ── Batch write ──

  Future<int> importMembers(
    String areaId,
    String tsiwaId,
    List<Member> members,
  ) async {
    int imported = 0;
    final collection =
        _firestore.collection(FirestorePaths.members(areaId, tsiwaId));

    final existingSnapshot =
        await collection.where('deletedAt', isNull: true).get();
    int nextOrder = 1;
    for (final doc in existingSnapshot.docs) {
      final idx = doc.data()['orderIndex'] as int? ?? 0;
      if (idx >= nextOrder) nextOrder = idx + 1;
    }

    final batch = _firestore.batch();
    for (final member in members) {
      if (member.fullName.isEmpty) continue;
      final m = member.copyWith(orderIndex: nextOrder++);
      batch.set(collection.doc(), m.toCreateMap());
      imported++;
    }
    await batch.commit();

    await _updateTswaCounts(areaId, tsiwaId);
    return imported;
  }

  Future<int> importLeaders(String areaId, List<Leader> leaders) async {
    int imported = 0;
    final collection =
        _firestore.collection(FirestorePaths.leaders(areaId));

    final batch = _firestore.batch();
    for (final leader in leaders) {
      if (leader.fullName.isEmpty) continue;
      batch.set(collection.doc(), leader.toCreateMap());
      imported++;
    }
    await batch.commit();
    return imported;
  }

  Future<int> importEdirMembers(
    String areaId,
    String edirId,
    List<EdirMember> members,
  ) async {
    int imported = 0;
    final collection =
        _firestore.collection(FirestorePaths.edirMembers(areaId, edirId));

    final batch = _firestore.batch();
    for (final member in members) {
      if (member.fullName.isEmpty) continue;
      batch.set(collection.doc(), member.toCreateMap());
      imported++;
    }
    await batch.commit();

    await _updateEdirMemberCount(areaId, edirId);
    return imported;
  }

  // ── File operations ──

  Future<File> writeCsvFile(String csv, String fileName) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${fileName}_$timestamp.csv');
    return file.writeAsString('\uFEFF$csv'); // BOM for Excel Amharic support
  }

  Future<void> shareCsvFile(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<String?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    return File(path).readAsString();
  }

  // ── Helpers ──

  MemberRole _parseMemberRole(String displayName) {
    for (final role in MemberRole.values) {
      if (role.displayName == displayName) return role;
    }
    return MemberRole.member;
  }

  LeaderRole _parseLeaderRole(String displayName) {
    for (final role in LeaderRole.values) {
      if (role.displayName == displayName) return role;
    }
    return LeaderRole.viewer;
  }

  EdirMemberStatus _parseEdirMemberStatus(String displayName) {
    for (final status in EdirMemberStatus.values) {
      if (status.displayName == displayName) return status;
    }
    return EdirMemberStatus.active;
  }

  Future<void> _updateTswaCounts(String areaId, String tsiwaId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.members(areaId, tsiwaId))
          .where('deletedAt', isNull: true)
          .where('isActive', isEqualTo: true)
          .get();

      int memberCount = 0;
      int museCount = 0;

      for (final doc in snapshot.docs) {
        memberCount++;
        final role = doc.data()['role'] as String?;
        if (role == 'muse' || role == 'assistant_muse') {
          museCount++;
        }
      }

      await _firestore
          .doc(FirestorePaths.tsiwaMahber(areaId, tsiwaId))
          .update({
        'memberCount': memberCount,
        'museCount': museCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _updateEdirMemberCount(String areaId, String edirId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.edirMembers(areaId, edirId))
          .get();
      await _firestore.doc(FirestorePaths.edir(areaId, edirId)).update({
        'memberCount': snapshot.docs.length,
      });
    } catch (_) {}
  }
}
