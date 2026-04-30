import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/confirm_dialog.dart';
import 'package:tsiwa_mahber/features/developer/data/developer_service.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class DeveloperManagementScreen extends StatefulWidget {
  const DeveloperManagementScreen({super.key});

  @override
  State<DeveloperManagementScreen> createState() =>
      _DeveloperManagementScreenState();
}

class _DeveloperManagementScreenState
    extends State<DeveloperManagementScreen> {
  final _developerService = DeveloperService();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.developers),
      ),
      body: StreamBuilder<List<String>>(
        stream: _developerService.watchDeveloperEmails(),
        builder: (context, snapshot) {
          final emails = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.addDeveloper,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Gmail ኢሜይል',
                                hintText: 'example@gmail.com',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType:
                                  TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addDeveloper,
                            child: Text(S.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  S.developerList,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              ...emails.map((email) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.primary,
                        child: Icon(Icons.code,
                            color: Colors.black, size: 20),
                      ),
                      title: Text(email),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            color: Colors.red.shade300),
                        onPressed: () => _removeDeveloper(email),
                      ),
                    ),
                  )),
              if (emails.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        S.noDevelopers,
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addDeveloper() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.validEmail)),
      );
      return;
    }

    try {
      await _developerService.addDeveloper(email);
      _emailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$email ተጨምሯል')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.saveFailed)),
        );
      }
    }
  }

  Future<void> _removeDeveloper(String email) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: S.deleteDeveloper,
      message: '"$email" ከገንቢ ዝርዝር ለመሰረዝ እርግጠኛ ነዎት?',
      confirmText: S.delete,
    );

    if (confirmed == true) {
      try {
        await _developerService.removeDeveloper(email);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.deleteFailed)),
          );
        }
      }
    }
  }
}
