import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/leadership/data/leader_repository.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/leadership/presentation/leader_form_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';

class LeaderListScreen extends StatefulWidget {
  final String areaId;

  const LeaderListScreen({
    super.key,
    required this.areaId,
  });

  @override
  State<LeaderListScreen> createState() => _LeaderListScreenState();
}

class _LeaderListScreenState extends State<LeaderListScreen> {
  final _leaderRepository = LeaderRepository();
  final _tsiwaRepository = TsiwaRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('አመራሮች'),
      ),
      body: StreamBuilder<List<TsiwaMahber>>(
        stream: _tsiwaRepository.watchTsiwas(widget.areaId),
        builder: (context, tsiwaSnapshot) {
          final tsiwas = tsiwaSnapshot.data ?? [];
          final tsiwaMap = {for (final t in tsiwas) t.id: t.name};

          return StreamBuilder<List<Leader>>(
            stream: _leaderRepository.watchLeaders(widget.areaId),
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

              final leaders = snapshot.data ?? [];

              if (leaders.isEmpty) {
                return EmptyState(
                  icon: Icons.admin_panel_settings,
                  title: 'እስካሁን አመራር አልተመዘገበም።',
                  message: 'አዲስ አመራር ለመጨመር ከታች ያለውን ቁልፍ ይጫኑ',
                  action: ElevatedButton.icon(
                    onPressed: () => _openCreateForm(tsiwas),
                    icon: const Icon(Icons.person_add),
                    label: const Text('አዲስ አመራር'),
                  ),
                );
              }

              final ownerLeaders = leaders
                  .where((l) => l.role == LeaderRole.owner)
                  .toList();
              final amerarLeaders = leaders
                  .where((l) => l.role == LeaderRole.amerar)
                  .toList();
              final memakirtLeaders = leaders
                  .where((l) => l.role == LeaderRole.memakir)
                  .toList();
              final edirLeaders = leaders
                  .where((l) => l.role == LeaderRole.edirAmerar)
                  .toList();
              final viewerLeaders = leaders
                  .where((l) => l.role == LeaderRole.viewer)
                  .toList();

              return ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                children: [
                  _buildSummaryCard(leaders),
                  if (ownerLeaders.isNotEmpty)
                    _buildSection('ባለቤት', ownerLeaders, tsiwaMap,
                        Icons.star, AppTheme.primary),
                  if (amerarLeaders.isNotEmpty)
                    _buildSection('አመራሮች', amerarLeaders, tsiwaMap,
                        Icons.admin_panel_settings, AppTheme.secondary),
                  if (memakirtLeaders.isNotEmpty)
                    _buildSection('መማክርት', memakirtLeaders, tsiwaMap,
                        Icons.groups, Colors.teal),
                  if (edirLeaders.isNotEmpty)
                    _buildSection('የእድር አመራሮች', edirLeaders, tsiwaMap,
                        Icons.account_balance_wallet, Colors.purple),
                  if (viewerLeaders.isNotEmpty)
                    _buildSection('ታዛቢዎች', viewerLeaders, tsiwaMap,
                        Icons.visibility, AppTheme.textMuted),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<List<TsiwaMahber>>(
        stream: _tsiwaRepository.watchTsiwas(widget.areaId),
        builder: (context, snapshot) {
          return FloatingActionButton(
            onPressed: () => _openCreateForm(snapshot.data ?? []),
            child: const Icon(Icons.person_add),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Leader> leaders) {
    final activeCount = leaders.where((l) => l.isActive).length;
    final amerarCount = leaders
        .where((l) =>
            l.role == LeaderRole.amerar || l.role == LeaderRole.owner)
        .length;
    final memakirtCount =
        leaders.where((l) => l.role == LeaderRole.memakir).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('ጠቅላላ', activeCount.toString(), AppTheme.primary),
            _buildStat('አመራሮች', amerarCount.toString(), AppTheme.secondary),
            _buildStat('መማክርት', memakirtCount.toString(), Colors.teal),
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
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Leader> leaders,
      Map<String, String> tsiwaMap, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                '$title (${leaders.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        ...leaders.map((leader) => _LeaderCard(
              leader: leader,
              tsiwaMap: tsiwaMap,
              onTap: () => _openEditForm(leader),
              onDelete: () => _deleteLeader(leader),
            )),
      ],
    );
  }

  void _openCreateForm(List<TsiwaMahber> tsiwas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderFormScreen(
          areaId: widget.areaId,
          availableTsiwas: tsiwas,
        ),
      ),
    );
  }

  void _openEditForm(Leader leader) async {
    final tsiwas = await _tsiwaRepository
        .watchTsiwas(widget.areaId)
        .first;
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeaderFormScreen(
            areaId: widget.areaId,
            existingLeader: leader,
            availableTsiwas: tsiwas,
          ),
        ),
      );
    }
  }

  Future<void> _deleteLeader(Leader leader) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'አመራር ሰርዝ',
      message: '"${leader.fullName}" አመራሩን ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: 'ሰርዝ',
    );

    if (confirmed == true && mounted) {
      try {
        await _leaderRepository.deleteLeader(widget.areaId, leader.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('አመራሩን መሰረዝ አልተቻለም።')),
          );
        }
      }
    }
  }
}

class _LeaderCard extends StatelessWidget {
  final Leader leader;
  final Map<String, String> tsiwaMap;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LeaderCard({
    required this.leader,
    required this.tsiwaMap,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final assignedNames = leader.assignedTsiwaIds
        .map((id) => tsiwaMap[id] ?? id)
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildRoleIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            leader.fullName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildRoleBadge(),
                      ],
                    ),
                    if (leader.christianName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        leader.christianName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                    if (leader.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 12,
                              color: AppTheme.textMuted.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            leader.phone,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (assignedNames.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: assignedNames
                            .map((name) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                    if (!leader.isActive)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ቆሟል',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ),
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

  Widget _buildRoleIcon() {
    Color color;
    IconData icon;
    switch (leader.role) {
      case LeaderRole.owner:
        color = AppTheme.primary;
        icon = Icons.star;
        break;
      case LeaderRole.amerar:
        color = AppTheme.secondary;
        icon = Icons.admin_panel_settings;
        break;
      case LeaderRole.memakir:
        color = Colors.teal;
        icon = Icons.groups;
        break;
      case LeaderRole.edirAmerar:
        color = Colors.purple;
        icon = Icons.account_balance_wallet;
        break;
      case LeaderRole.viewer:
        color = AppTheme.textMuted;
        icon = Icons.visibility;
        break;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildRoleBadge() {
    Color color;
    switch (leader.role) {
      case LeaderRole.owner:
        color = AppTheme.primary;
        break;
      case LeaderRole.amerar:
        color = AppTheme.secondary;
        break;
      case LeaderRole.memakir:
        color = Colors.teal;
        break;
      case LeaderRole.edirAmerar:
        color = Colors.purple;
        break;
      case LeaderRole.viewer:
        color = AppTheme.textMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        leader.role.displayName,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
