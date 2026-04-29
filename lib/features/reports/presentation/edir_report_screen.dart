import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/reports/data/report_service.dart';

class EdirReportScreen extends StatefulWidget {
  final String areaId;

  const EdirReportScreen({super.key, required this.areaId});

  @override
  State<EdirReportScreen> createState() => _EdirReportScreenState();
}

class _EdirReportScreenState extends State<EdirReportScreen> {
  final _reportService = ReportService();
  bool _isLoading = true;
  List<EdirStats> _stats = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _reportService.getEdirStats(widget.areaId);
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
      appBar: AppBar(title: const Text('የእድር ሪፖርት')),
      body: _isLoading
          ? const LoadingState(message: 'በመጫን ላይ...')
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('እንደገና ሞክር'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_stats.isEmpty) {
      return const Center(
        child: Text(
          'ምንም እድር አልተመዘገበም',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTreasurySummary(),
          const SizedBox(height: 24),
          ..._stats.map((stat) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildEdirCard(stat),
              )),
        ],
      ),
    );
  }

  Widget _buildTreasurySummary() {
    final totalTreasury =
        _stats.fold<double>(0, (sum, s) => sum + s.edir.treasury);
    final totalCollected =
        _stats.fold<double>(0, (sum, s) => sum + s.totalCollected);
    final totalOutstanding =
        _stats.fold<double>(0, (sum, s) => sum + s.totalOutstanding);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'አጠቃላይ የገንዘብ ማጠቃለያ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _FinanceCard(
                    label: 'ግምጃ ቤት',
                    value: '${totalTreasury.toStringAsFixed(0)} ብር',
                    icon: Icons.savings,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FinanceCard(
                    label: 'ጠቅላላ ክፍያ',
                    value: '${totalCollected.toStringAsFixed(0)} ብር',
                    icon: Icons.payments,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FinanceCard(
                    label: 'ቀሪ ሂሳብ',
                    value: '${totalOutstanding.toStringAsFixed(0)} ብር',
                    icon: Icons.warning_amber,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            if (_stats.length > 1) ...[
              const SizedBox(height: 16),
              const Text(
                'ግምጃ ቤት በእድር',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _stats
                            .map((s) => s.edir.treasury)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= _stats.length) {
                              return const SizedBox.shrink();
                            }
                            final name = _stats[idx].edir.name;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                name.length > 8
                                    ? '${name.substring(0, 8)}…'
                                    : name,
                                style: const TextStyle(
                                    fontSize: 10, color: AppTheme.textMuted),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textMuted),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade800,
                        strokeWidth: 0.5,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _stats.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.edir.treasury,
                            color: Colors.green,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEdirCard(EdirStats stat) {
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stat.edir.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stat.edir.treasury.toStringAsFixed(0)} ብር',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoTile(
                  label: 'አባላት',
                  value: stat.members.length.toString(),
                ),
                const SizedBox(width: 16),
                _InfoTile(
                  label: 'ወርሃዊ',
                  value: '${stat.edir.monthlyContribution.toStringAsFixed(0)} ብር',
                ),
                const SizedBox(width: 16),
                _InfoTile(
                  label: 'ቅጣት',
                  value: '${stat.edir.penaltyAmount.toStringAsFixed(0)} ብር',
                ),
              ],
            ),
            if (stat.paymentsByType.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'የክፍያ ስርጭት',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 24,
                          sections: stat.paymentsByType.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final colorIdx = entry.key % colors.length;
                            return PieChartSectionData(
                              color: colors[colorIdx],
                              value: entry.value.value,
                              title:
                                  '${entry.value.value.toStringAsFixed(0)}',
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: 40,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: stat.paymentsByType.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final colorIdx = entry.key % colors.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colors[colorIdx],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${entry.value.key}: ${entry.value.value.toStringAsFixed(0)} ብር',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            if (stat.membersByStatus.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'አባላት በሁኔታ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: stat.membersByStatus.entries.map((e) {
                  Color chipColor;
                  if (e.key == 'ንቁ') {
                    chipColor = Colors.green;
                  } else if (e.key == 'ቦዝኗል') {
                    chipColor = Colors.orange;
                  } else {
                    chipColor = Colors.red;
                  }
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: chipColor,
                      radius: 6,
                    ),
                    label: Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
            if (stat.members.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'ከፍተኛ ቀሪ ሂሳብ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              ...stat.members
                  .where((m) => m.balance > 0)
                  .toList()
                  .take(5)
                  .map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                m.fullName,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '${m.balance.toStringAsFixed(0)} ብር',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      )),
              if (stat.members.where((m) => m.balance > 0).isEmpty)
                const Text(
                  'ቀሪ ሂሳብ ያለው አባል የለም',
                  style: TextStyle(
                    fontSize: 12,
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

class _FinanceCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _FinanceCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
