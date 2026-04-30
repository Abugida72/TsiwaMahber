import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/members/data/member_repository.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';
import 'package:tsiwa_mahber/features/members/presentation/member_form_screen.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class MemberListScreen extends StatefulWidget {
  final String areaId;
  final String tsiwaId;
  final String tsiwaName;

  const MemberListScreen({
    super.key,
    required this.areaId,
    required this.tsiwaId,
    required this.tsiwaName,
  });

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _memberRepository = MemberRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.members),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.tsiwaName,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Member>>(
        stream:
            _memberRepository.watchMembers(widget.areaId, widget.tsiwaId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                S.dataLoadFailed,
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingState(message: S.loading);
          }

          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: S.noMembersYet,
              message: S.addMemberHint,
              action: ElevatedButton.icon(
                onPressed: _openCreateForm,
                icon: const Icon(Icons.person_add),
                label: Text(S.newMember),
              ),
            );
          }

          final museMembers =
              members.where((m) => m.role == MemberRole.muse).toList();
          final assistantMuse = members
              .where((m) => m.role == MemberRole.assistantMuse)
              .toList();
          final regularMembers =
              members.where((m) => m.role == MemberRole.member).toList();
          final observers =
              members.where((m) => m.role == MemberRole.observer).toList();

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            children: [
              _buildSummaryCard(members),
              if (museMembers.isNotEmpty)
                _buildSection('ሙሴ', museMembers, Icons.star),
              if (assistantMuse.isNotEmpty)
                _buildSection(
                    'ረዳት ሙሴ', assistantMuse, Icons.star_half),
              if (regularMembers.isNotEmpty)
                _buildSection(S.members, regularMembers, Icons.person),
              if (observers.isNotEmpty)
                _buildSection(S.viewerSection, observers, Icons.visibility),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildSummaryCard(List<Member> members) {
    final activeCount = members.where((m) => m.isActive).length;
    final inRotation = members.where((m) => m.isInRotation).length;
    final museCount = members
        .where((m) =>
            m.role == MemberRole.muse ||
            m.role == MemberRole.assistantMuse)
        .length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(S.total, activeCount.toString(), AppTheme.primary),
            _buildStat(S.inRotation, inRotation.toString(), Colors.teal),
            _buildStat('ሙሴ', museCount.toString(), AppTheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      String title, List<Member> members, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Text(
                '$title (${members.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        ...members.map((member) => _MemberCard(
              member: member,
              onTap: () => _openEditForm(member),
              onDelete: () => _deleteMember(member),
            )),
      ],
    );
  }

  void _openCreateForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberFormScreen(
          areaId: widget.areaId,
          tsiwaId: widget.tsiwaId,
        ),
      ),
    );
  }

  void _openEditForm(Member member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberFormScreen(
          areaId: widget.areaId,
          tsiwaId: widget.tsiwaId,
          existingMember: member,
        ),
      ),
    );
  }

  Future<void> _deleteMember(Member member) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: S.deleteMember,
      message: '"${member.fullName}" አባልን ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: S.delete,
    );

    if (confirmed == true && mounted) {
      try {
        await _memberRepository.softDeleteMember(
          widget.areaId,
          widget.tsiwaId,
          member.id,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('አባልን መሰረዝ አልተቻለም።')),
          );
        }
      }
    }
  }
}

class _MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MemberCard({
    required this.member,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildOrderBadge(),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildRoleBadge(),
                      ],
                    ),
                    if (member.christianName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        member.christianName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (member.phone.isNotEmpty &&
                            !member.isHiddenPhone) ...[
                          Icon(Icons.phone, size: 12,
                              color: AppTheme.textMuted.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            member.phone,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (!member.isInRotation)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ከተራ ውጪ',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        if (!member.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              S.stopped,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red.shade300,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: member.isInRotation
            ? AppTheme.primary.withValues(alpha: 0.15)
            : AppTheme.textMuted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${member.orderIndex}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: member.isInRotation ? AppTheme.primary : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    Color color;
    switch (member.role) {
      case MemberRole.muse:
        color = AppTheme.primary;
        break;
      case MemberRole.assistantMuse:
        color = AppTheme.secondary;
        break;
      case MemberRole.observer:
        color = AppTheme.textMuted;
        break;
      case MemberRole.member:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        member.role.displayName,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
