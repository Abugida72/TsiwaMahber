import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/app_card.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/reports/data/report_service.dart';
import 'package:tsiwa_mahber/features/reports/presentation/tsiwa_report_screen.dart';
import 'package:tsiwa_mahber/features/reports/presentation/edir_report_screen.dart';

class ReportHomeScreen extends StatefulWidget {
  final String areaId;

  const ReportHomeScreen({super.key, required this.areaId});

  @override
  State<ReportHomeScreen> createState() => _ReportHomeScreenState();
}

class _ReportHomeScreenState extends State<ReportHomeScreen> {
  final _reportService = ReportService();
  bool _isLoading = true;
  OverviewStats? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _reportService.getOverviewStats(widget.areaId);
      if (mounted) setState(() => _stats = stats);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ሪፖርቶች'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'አድስ',
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'ሪፖርቶችን በመጫን ላይ...')
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'መረጃ ማግኘት አልተቻለም',
            style: TextStyle(color: Colors.red.shade300),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
            label: const Text('እንደገና ሞክር'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(stats),
          const SizedBox(height: 24),
          _buildReportMenu(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(OverviewStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'አጠቃላይ ማጠቃለያ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  icon: Icons.groups,
                  label: 'ፅዋ ማህበሮች',
                  value: stats.totalTsiwas.toString(),
                  detail: '${stats.activeTsiwas} ንቁ',
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OverviewCard(
                  icon: Icons.person,
                  label: 'አባላት',
                  value: stats.totalMembers.toString(),
                  detail: 'በሁሉም ፅዋ',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  icon: Icons.admin_panel_settings,
                  label: 'አመራሮች',
                  value: stats.totalLeaders.toString(),
                  detail: '',
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OverviewCard(
                  icon: Icons.account_balance_wallet,
                  label: 'እድር',
                  value: stats.totalEdirs.toString(),
                  detail: '${stats.totalTreasury.toStringAsFixed(0)} ብር ግምጃ',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'ዝርዝር ሪፖርቶች',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppInfoCard(
          icon: Icons.groups,
          title: 'የፅዋ ሪፖርት',
          subtitle: 'የአባላት ብዛት፣ ሚና ስርጭት',
          iconColor: AppTheme.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TsiwaReportScreen(areaId: widget.areaId),
              ),
            );
          },
        ),
        AppInfoCard(
          icon: Icons.account_balance_wallet,
          title: 'የእድር ሪፖርት',
          subtitle: 'የክፍያ ማጠቃለያ፣ ቀሪ ሂሳብ',
          iconColor: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EdirReportScreen(areaId: widget.areaId),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
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
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (detail.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
