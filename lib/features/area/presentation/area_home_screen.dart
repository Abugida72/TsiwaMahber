import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/app_card.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/area/data/area_repository.dart';
import 'package:tsiwa_mahber/features/area/domain/area.dart';
import 'package:tsiwa_mahber/features/tsiwa/presentation/tsiwa_list_screen.dart';

class AreaHomeScreen extends StatefulWidget {
  const AreaHomeScreen({super.key});

  @override
  State<AreaHomeScreen> createState() => _AreaHomeScreenState();
}

class _AreaHomeScreenState extends State<AreaHomeScreen> {
  final _areaRepository = AreaRepository();
  String? _initError;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeArea();
  }

  Future<void> _initializeArea() async {
    setState(() {
      _isInitializing = true;
      _initError = null;
    });

    final error = await _areaRepository.ensureDefaultArea();

    if (mounted) {
      setState(() {
        _initError = error;
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.defaultAreaName),
      ),
      body: _isInitializing
          ? const LoadingState(message: 'በመጫን ላይ...')
          : _initError != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 72,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'ከFirestore ጋር መገናኘት አልተቻለም',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _initError!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Firestore security rules ያረጋግጡ\n'
              'እና ኢንተርኔት መኖሩን ያረጋግጡ',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeArea,
              icon: const Icon(Icons.refresh),
              label: const Text('እንደገና ሞክር'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<Area?>(
      stream: _areaRepository.watchArea(AppConstants.defaultAreaId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
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
                  onPressed: _initializeArea,
                  icon: const Icon(Icons.refresh),
                  label: const Text('እንደገና ሞክር'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState(message: 'በመጫን ላይ...');
        }

        final area = snapshot.data;
        if (area == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty, size: 48,
                    color: AppTheme.textMuted),
                const SizedBox(height: 16),
                const Text(
                  'መረጃ በመዘጋጀት ላይ...',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _initializeArea,
                  icon: const Icon(Icons.refresh),
                  label: const Text('እንደገና ሞክር'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(area),
              const SizedBox(height: 24),
              _buildMenuSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Area area) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.church,
                      color: AppTheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          area.location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (area.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  area.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'አገልግሎቶች',
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
          title: 'ፅዋ ማህበሮች',
          subtitle: 'ፅዋ ማህበሮችን ያስተዳድሩ',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TsiwaListScreen(
                  areaId: AppConstants.defaultAreaId,
                  areaName: AppConstants.defaultAreaName,
                ),
              ),
            );
          },
        ),
        AppInfoCard(
          icon: Icons.people,
          title: 'አመራሮች',
          subtitle: 'በቀጣይ ስሪት ይጨመራል',
          iconColor: AppTheme.textMuted,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('በቀጣይ ስሪት ይጨመራል')),
            );
          },
        ),
        AppInfoCard(
          icon: Icons.account_balance_wallet,
          title: 'እድር',
          subtitle: 'በቀጣይ ስሪት ይጨመራል',
          iconColor: AppTheme.textMuted,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('በቀጣይ ስሪት ይጨመራል')),
            );
          },
        ),
      ],
    );
  }
}
