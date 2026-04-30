import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/auth/data/auth_repository.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';

class UserManagementScreen extends StatefulWidget {
  final String? areaId;

  const UserManagementScreen({super.key, this.areaId});

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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateMemberDialog,
        child: const Icon(Icons.person_add),
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
            padding: const EdgeInsets.only(top: 8, bottom: 80),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (user.kickedOut)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            S.kicked,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  if (user.phone.isNotEmpty)
                    Text(
                      user.phone,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textMuted),
                    ),
                  if (user.email.isNotEmpty)
                    Text(
                      user.email,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                    ),
                  if (user.areaId.isNotEmpty)
                    Text(
                      '${S.areaLabel}: ${user.areaId}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                    ),
                ],
              ),
            ),
            // Role badge + menu
            PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(user, value),
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
              itemBuilder: (context) => [
                ...UserRole.values
                    .where((role) => role != UserRole.developer)
                    .map((role) => PopupMenuItem(
                          value: 'role_${role.firestoreValue}',
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
                        )),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'set_password',
                  child: ListTile(
                    leading: const Icon(Icons.key, size: 18),
                    title: Text(S.setPassword),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: 'edit_phone',
                  child: ListTile(
                    leading: const Icon(Icons.phone, size: 18),
                    title: Text(S.editPhone),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: user.kickedOut ? 'reinstate' : 'kick',
                  child: ListTile(
                    leading: Icon(
                      user.kickedOut ? Icons.undo : Icons.block,
                      size: 18,
                      color: user.kickedOut ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      user.kickedOut ? S.reinstated : S.kickOut,
                      style: TextStyle(
                        color: user.kickedOut ? Colors.green : Colors.red,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever, size: 18,
                        color: Colors.red),
                    title: Text(S.deleteUser,
                        style: const TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUserAction(AppUser user, String action) async {
    if (action.startsWith('role_')) {
      final roleStr = action.substring(5);
      final newRole = UserRole.fromString(roleStr);
      if (newRole != user.role) {
        await _changeRole(user, newRole);
      }
    } else if (action == 'set_password') {
      _showSetPasswordDialog(user);
    } else if (action == 'kick') {
      _showKickConfirmDialog(user);
    } else if (action == 'edit_phone') {
      _showEditPhoneDialog(user);
    } else if (action == 'reinstate') {
      try {
        await _authRepository.reinstateUser(user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.displayName} — ${S.reinstated}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.errorMsg(e.toString()))),
          );
        }
      }
    } else if (action == 'delete') {
      _showDeleteConfirmDialog(user);
    }
  }

  Future<void> _changeRole(AppUser user, UserRole newRole) async {
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
          SnackBar(content: Text(S.errorMsg(e.toString()))),
        );
      }
    }
  }

  Future<void> _showSetPasswordDialog(AppUser user) async {
    final controller = TextEditingController(text: user.passwordCode);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.setPassword),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: S.newPassword,
            hintText: '1234',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(S.save),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result != null && result.isNotEmpty) {
      try {
        await _authRepository.updateMemberCredentials(
          uid: user.uid,
          passwordCode: result,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.passwordUpdated)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.errorMsg(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _showKickConfirmDialog(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.kickOut),
        content: Text(S.kickOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.kickOut),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authRepository.kickOutUser(user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.displayName} — ${S.kicked}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.errorMsg(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _showCreateMemberDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final codeController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.addMemberAccount),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: '${S.fullName} *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                    labelText: '${S.phoneNumber} *',
                    hintText: '09xxxxxxxx'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                    labelText: '${S.passwordCode} *',
                    hintText: '1234'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.create),
          ),
        ],
      ),
    );

    if (result == true) {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final code = codeController.text.trim();

      if (name.isEmpty || phone.isEmpty || code.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.nameAndShortRequired)),
          );
        }
      } else {
        final error = await _authRepository.createMemberAccount(
          displayName: name,
          phone: phone,
          passwordCode: code,
          areaId: widget.areaId ?? '',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(error ?? S.memberAccountCreated)),
          );
        }
      }
    }

    nameController.dispose();
    phoneController.dispose();
    codeController.dispose();
  }

  Future<void> _showEditPhoneDialog(AppUser user) async {
    final controller = TextEditingController(text: user.phone);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.editPhone),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: S.phoneNumber,
            hintText: '09xxxxxxxx',
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(S.save),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result != null && result.isNotEmpty) {
      try {
        await _authRepository.updateMemberCredentials(
          uid: user.uid,
          phone: result,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.phoneUpdated)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.errorMsg(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.deleteUser),
        content: Text('${S.deleteUserConfirm}\n\n${user.displayName}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authRepository.deleteUser(user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.userDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.errorMsg(e.toString()))),
          );
        }
      }
    }
  }
}
