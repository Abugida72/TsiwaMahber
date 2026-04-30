import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.users),
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: _authRepository.watchAllUsers(),
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

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(S.noUsersFound),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: users.length,
            itemBuilder: (context, index) =>
                _buildUserCard(users[index]),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    final roleColor = switch (user.role) {
      UserRole.developer => Colors.deepPurple,
      UserRole.admin => AppTheme.primary,
      UserRole.leader => AppTheme.secondary,
      UserRole.member => Colors.teal,
      UserRole.viewer => AppTheme.textMuted,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: roleColor.withValues(alpha: 0.15),
              child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: roleColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            PopupMenuButton<UserRole>(
              onSelected: (role) => _changeRole(user, role),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.role.displayName,
                      style: TextStyle(fontSize: 12, color: roleColor),
                    ),
                    Icon(Icons.arrow_drop_down,
                        size: 16, color: roleColor),
                  ],
                ),
              ),
              itemBuilder: (context) => UserRole.values
                  .where((role) => role != UserRole.developer)
                  .map((role) {
                return PopupMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      if (role == user.role)
                        const Icon(Icons.check, size: 16)
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text(role.displayName),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeRole(AppUser user, UserRole newRole) async {
    if (newRole == user.role) return;

    try {
      await _authRepository.updateUserRole(user.uid, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${user.displayName} → ${newRole.displayName}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ስህተት: $e')),
        );
      }
    }
  }
}
