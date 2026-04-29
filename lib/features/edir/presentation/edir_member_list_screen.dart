import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/edir/presentation/edir_member_form_screen.dart';
import 'package:tsiwa_mahber/features/edir/presentation/record_payment_screen.dart';

class EdirMemberListScreen extends StatefulWidget {
  final String areaId;
  final String edirId;
  final String edirName;
  final double monthlyContribution;

  const EdirMemberListScreen({
    super.key,
    required this.areaId,
    required this.edirId,
    required this.edirName,
    required this.monthlyContribution,
  });

  @override
  State<EdirMemberListScreen> createState() => _EdirMemberListScreenState();
}

class _EdirMemberListScreenState extends State<EdirMemberListScreen> {
  final _repository = EdirRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.edirName} — አባላት'),
      ),
      body: StreamBuilder<List<EdirMember>>(
        stream:
            _repository.watchEdirMembers(widget.areaId, widget.edirId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'መረጃ ማግኘት አልተቻለም',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'በመጫን ላይ...');
          }

          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return EmptyState(
              icon: Icons.people,
              title: 'እስካሁን አባል አልተመዘገበም።',
              message: 'አዲስ አባል ለመጨመር ከታች ያለውን ቁልፍ ይጫኑ',
              action: ElevatedButton.icon(
                onPressed: _openCreateForm,
                icon: const Icon(Icons.person_add),
                label: const Text('አዲስ አባል'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: members.length,
            itemBuilder: (context, index) =>
                _buildMemberCard(members[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildMemberCard(EdirMember member) {
    final statusColor = member.status == EdirMemberStatus.active
        ? Colors.green
        : member.status == EdirMemberStatus.suspended
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  AppTheme.primary.withValues(alpha: 0.15),
              child: Text(
                member.fullName.isNotEmpty
                    ? member.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.fullName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.status.displayName,
                          style: TextStyle(
                              fontSize: 11, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ከፍሏል: ${member.totalPaid.toStringAsFixed(0)} ብር · '
                    '${member.paidMonths} ወር',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted),
                  ),
                  if (member.balance > 0)
                    Text(
                      'ቀሪ ዕዳ: ${member.balance.toStringAsFixed(0)} ብር',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.red),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'pay') {
                  _openPayment(member);
                } else if (value == 'edit') {
                  _openEditForm(member);
                } else if (value == 'delete') {
                  _confirmDelete(member);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pay',
                  child: Row(
                    children: [
                      Icon(Icons.payment, size: 18),
                      SizedBox(width: 8),
                      Text('ክፍያ መዝግብ'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('አስተካክል'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18,
                          color: Colors.red),
                      SizedBox(width: 8),
                      Text('ሰርዝ',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EdirMemberFormScreen(
          areaId: widget.areaId,
          edirId: widget.edirId,
        ),
      ),
    );
  }

  void _openEditForm(EdirMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EdirMemberFormScreen(
          areaId: widget.areaId,
          edirId: widget.edirId,
          member: member,
        ),
      ),
    );
  }

  void _openPayment(EdirMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordPaymentScreen(
          areaId: widget.areaId,
          edirId: widget.edirId,
          member: member,
          monthlyContribution: widget.monthlyContribution,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(EdirMember member) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'አባል ሰርዝ',
      message: '"${member.fullName}" ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: 'ሰርዝ',
    );

    if (confirmed == true) {
      await _repository.deleteEdirMember(
          widget.areaId, widget.edirId, member.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${member.fullName}" ተሰርዟል')),
        );
      }
    }
  }
}
