import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/features/tsiwa/presentation/tsiwa_form_screen.dart';

class TsiwaDetailScreen extends StatefulWidget {
  final String areaId;
  final String tsiwaId;

  const TsiwaDetailScreen({
    super.key,
    required this.areaId,
    required this.tsiwaId,
  });

  @override
  State<TsiwaDetailScreen> createState() => _TsiwaDetailScreenState();
}

class _TsiwaDetailScreenState extends State<TsiwaDetailScreen> {
  final _tsiwaRepository = TsiwaRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TsiwaMahber?>(
      stream: _tsiwaRepository.watchTsiwa(widget.areaId, widget.tsiwaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('ፅዋ ዝርዝር')),
            body: const LoadingState(message: 'በመጫን ላይ...'),
          );
        }

        final tsiwa = snapshot.data;
        if (tsiwa == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('ፅዋ ዝርዝር')),
            body: const Center(child: Text('ፅዋ ማህበሩ አልተገኘም')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(tsiwa.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _edit(tsiwa),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _delete(tsiwa),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(tsiwa),
                const SizedBox(height: 16),
                _buildMonthlyTsiwaSection(tsiwa),
                const SizedBox(height: 16),
                _buildZikirFeedingSection(tsiwa),
                const SizedBox(height: 16),
                _buildStatusSection(tsiwa),
                const SizedBox(height: 16),
                _buildFuturePlaceholders(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoSection(TsiwaMahber tsiwa) {
    return _SectionCard(
      title: 'መሰረታዊ መረጃ',
      icon: Icons.info_outline,
      children: [
        _InfoRow(label: 'ስም', value: tsiwa.name),
        if (tsiwa.churchName.isNotEmpty)
          _InfoRow(label: 'ቤተ ክርስቲያን', value: tsiwa.churchName),
        if (tsiwa.saintName.isNotEmpty)
          _InfoRow(label: 'ቅዱስ/ቅድስት', value: tsiwa.saintName),
        if (tsiwa.location.isNotEmpty)
          _InfoRow(label: 'ቦታ', value: tsiwa.location),
        if (tsiwa.description.isNotEmpty)
          _InfoRow(label: 'መግለጫ', value: tsiwa.description),
      ],
    );
  }

  Widget _buildMonthlyTsiwaSection(TsiwaMahber tsiwa) {
    return _SectionCard(
      title: 'የወርሃዊ ፅዋ ቀን',
      icon: Icons.calendar_today,
      iconColor: AppTheme.primary,
      children: [
        _InfoRow(
          label: 'ቀን',
          value: 'በየወሩ ${tsiwa.monthlyTsiwaDay}',
        ),
        if (tsiwa.monthlyTsiwaDayNote.isNotEmpty)
          _InfoRow(label: 'ማስታወሻ', value: tsiwa.monthlyTsiwaDayNote),
      ],
    );
  }

  Widget _buildZikirFeedingSection(TsiwaMahber tsiwa) {
    final hasZikir = tsiwa.zikirMonth != null && tsiwa.zikirDay != null;
    final hasFeeding =
        tsiwa.feedingMonth != null && tsiwa.feedingDay != null;

    if (!hasZikir && !hasFeeding) {
      return _SectionCard(
        title: 'ዝክር / ማብላት',
        icon: Icons.restaurant,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'እስካሁን የዝክር ወይም የማብላት ቀን አልተመዘገበም',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (hasZikir)
          _SectionCard(
            title: tsiwa.zikirTitle,
            icon: Icons.auto_awesome,
            iconColor: AppTheme.secondary,
            children: [
              _InfoRow(
                label: 'ቀን',
                value:
                    '${AppConstants.ethiopianMonthName(tsiwa.zikirMonth!)} ${tsiwa.zikirDay}',
              ),
              if (tsiwa.zikirNote.isNotEmpty)
                _InfoRow(label: 'ማስታወሻ', value: tsiwa.zikirNote),
            ],
          ),
        if (hasZikir && hasFeeding) const SizedBox(height: 16),
        if (hasFeeding)
          _SectionCard(
            title: tsiwa.feedingTitle,
            icon: Icons.restaurant,
            iconColor: Colors.teal,
            children: [
              _InfoRow(
                label: 'ቀን',
                value:
                    '${AppConstants.ethiopianMonthName(tsiwa.feedingMonth!)} ${tsiwa.feedingDay}',
              ),
              if (tsiwa.feedingNote.isNotEmpty)
                _InfoRow(label: 'ማስታወሻ', value: tsiwa.feedingNote),
            ],
          ),
      ],
    );
  }

  Widget _buildStatusSection(TsiwaMahber tsiwa) {
    return _SectionCard(
      title: 'ሁኔታ',
      icon: Icons.toggle_on,
      children: [
        _InfoRow(
          label: 'ንቁ',
          value: tsiwa.isActive ? 'አዎ' : 'አይ',
          valueColor: tsiwa.isActive ? AppTheme.success : Colors.red,
        ),
        _InfoRow(
          label: 'ማህደር',
          value: tsiwa.isArchived ? 'አዎ' : 'አይ',
        ),
      ],
    );
  }

  Widget _buildFuturePlaceholders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'በቀጣይ ስሪት',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            _buildPlaceholderItem(
              Icons.people,
              'አባላት',
              'Members will be added in Version 2',
            ),
            _buildPlaceholderItem(
              Icons.person,
              'ሙሴ',
              'Muse assignment will be added in Version 2',
            ),
            _buildPlaceholderItem(
              Icons.rotate_right,
              'የፅዋ ተራ',
              'Rotation schedule will be added in Version 3',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _edit(TsiwaMahber tsiwa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TsiwaFormScreen(
          areaId: widget.areaId,
          existingTsiwa: tsiwa,
        ),
      ),
    );
  }

  Future<void> _delete(TsiwaMahber tsiwa) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'ፅዋ ሰርዝ',
      message: '"${tsiwa.name}" ፅዋ ማህበሩን ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: 'ሰርዝ',
      cancelText: 'ተወው',
    );

    if (confirmed == true && mounted) {
      try {
        await _tsiwaRepository.deleteTsiwa(widget.areaId, tsiwa.id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('መረጃውን መሰረዝ አልተቻለም።')),
          );
        }
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor ?? AppTheme.textMuted),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
