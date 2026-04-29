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

  @override
  void initState() {
    super.initState();
    _areaRepository.ensureDefaultArea();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.defaultAreaName),
      ),
      body: StreamBuilder<Area?>(
        stream: _areaRepository.watchArea(AppConstants.defaultAreaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'በመጫን ላይ...');
          }

          final area = snapshot.data;
          if (area == null) {
            return const LoadingState(message: 'በመጫን ላይ...');
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
      ),
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
