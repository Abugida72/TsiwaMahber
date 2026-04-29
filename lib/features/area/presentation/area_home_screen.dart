import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/app_card.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/area/data/area_repository.dart';
import 'package:tsiwa_mahber/features/area/domain/area.dart';
import 'package:tsiwa_mahber/features/leadership/data/leader_repository.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/leadership/presentation/leader_list_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/presentation/edir_list_screen.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/auth/presentation/profile_screen.dart';
import 'package:tsiwa_mahber/features/auth/presentation/user_management_screen.dart';
import 'package:tsiwa_mahber/features/tsiwa/presentation/tsiwa_list_screen.dart';

class AreaHomeScreen extends StatefulWidget {
  final AppUser? currentUser;

  const AreaHomeScreen({super.key, this.currentUser});

  @override
  State<AreaHomeScreen> createState() => _AreaHomeScreenState();
}

class _AreaHomeScreenState extends State<AreaHomeScreen> {
  final _areaRepository = AreaRepository();
  final _tsiwaRepository = TsiwaRepository();
  final _leaderRepository = LeaderRepository();
  final _edirRepository = EdirRepository();
  final _authRepository = AuthRepository();
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
        actions: [
          if (widget.currentUser?.role.canManageUsers == true)
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: 'ተጠቃሚዎች',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const UserManagementScreen(),
                  ),
                );
              },
            ),
          if (widget.currentUser != null)
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'መገለጫ',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(user: widget.currentUser!),
                  ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'ውጣ',
              onPressed: () => _authRepository.signOut(),
            ),
        ],
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
              const SizedBox(height: 16),
              _buildDashboardStats(),
              const SizedBox(height: 16),
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
          icon: Icons.admin_panel_settings,
          title: 'አመራሮች',
          subtitle: 'አመራሮችን ያስተዳድሩ',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeaderListScreen(
                  areaId: AppConstants.defaultAreaId,
                ),
              ),
            );
          },
        ),
        AppInfoCard(
          icon: Icons.account_balance_wallet,
          title: 'እድር',
          subtitle: 'እድርን ያስተዳድሩ',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EdirListScreen(
                  areaId: AppConstants.defaultAreaId,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashboardStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StreamBuilder<List<TsiwaMahber>>(
              stream: _tsiwaRepository.watchTsiwas(AppConstants.defaultAreaId),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  label: 'ፅዋ ማህበሮች',
                  value: count.toString(),
                  icon: Icons.groups,
                  color: AppTheme.primary,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StreamBuilder<List<Leader>>(
              stream: _leaderRepository.watchLeaders(AppConstants.defaultAreaId),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  label: 'አመራሮች',
                  value: count.toString(),
                  icon: Icons.admin_panel_settings,
                  color: AppTheme.secondary,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StreamBuilder<List<Edir>>(
              stream: _edirRepository.watchEdirs(AppConstants.defaultAreaId),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatCard(
                  label: 'እድር',
                  value: count.toString(),
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
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
        ),
      ),
    );
  }
}
