import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/leadership/data/leader_repository.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';

class LeaderFormScreen extends StatefulWidget {
  final String areaId;
  final Leader? existingLeader;
  final List<TsiwaMahber> availableTsiwas;

  const LeaderFormScreen({
    super.key,
    required this.areaId,
    this.existingLeader,
    required this.availableTsiwas,
  });

  @override
  State<LeaderFormScreen> createState() => _LeaderFormScreenState();
}

class _LeaderFormScreenState extends State<LeaderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _leaderRepository = LeaderRepository();

  late final TextEditingController _fullNameController;
  late final TextEditingController _christianNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _phone2Controller;

  late LeaderRole _role;
  EdirLeaderRole? _edirRole;
  late bool _isActive;
  late Set<String> _selectedTsiwaIds;
  bool _isSaving = false;

  bool get _isEditing => widget.existingLeader != null;

  @override
  void initState() {
    super.initState();
    final l = widget.existingLeader;

    _fullNameController = TextEditingController(text: l?.fullName ?? '');
    _christianNameController =
        TextEditingController(text: l?.christianName ?? '');
    _phoneController = TextEditingController(text: l?.phone ?? '');
    _phone2Controller = TextEditingController(text: l?.phone2 ?? '');

    _role = l?.role ?? LeaderRole.amerar;
    _edirRole = l?.edirRole;
    _isActive = l?.isActive ?? true;
    _selectedTsiwaIds = Set<String>.from(l?.assignedTsiwaIds ?? []);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _christianNameController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'አመራር አርትዕ' : 'አዲስ አመራር'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('የግል መረጃ'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'ሙሉ ስም *'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ሙሉ ስም ያስገቡ';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _christianNameController,
              decoration: const InputDecoration(labelText: 'የክርስትና ስም'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'ስልክ ቁጥር'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone2Controller,
              decoration: const InputDecoration(labelText: 'ተጨማሪ ስልክ'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('ሚና'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LeaderRole.values.map((role) {
                    final isSelected = _role == role;
                    return ChoiceChip(
                      label: Text(role.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _role = role;
                            if (role != LeaderRole.edirAmerar) {
                              _edirRole = null;
                            }
                          });
                        }
                      },
                      selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (_role == LeaderRole.edirAmerar) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('የእድር ሚና'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: EdirLeaderRole.values.map((eRole) {
                      final isSelected = _edirRole == eRole;
                      return ChoiceChip(
                        label: Text(eRole.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _edirRole = selected ? eRole : null;
                          });
                        },
                        selectedColor:
                            AppTheme.primary.withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textMuted,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            if (widget.availableTsiwas.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('የተመደበባቸው ፅዋ ማህበሮች'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: widget.availableTsiwas.map((tsiwa) {
                    final isSelected =
                        _selectedTsiwaIds.contains(tsiwa.id);
                    return CheckboxListTile(
                      title: Text(
                        tsiwa.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: tsiwa.churchName.isNotEmpty
                          ? Text(
                              tsiwa.churchName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            )
                          : null,
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedTsiwaIds.add(tsiwa.id);
                          } else {
                            _selectedTsiwaIds.remove(tsiwa.id);
                          }
                        });
                      },
                      activeColor: AppTheme.primary,
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildSectionHeader('ሁኔታ'),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('ንቁ'),
                subtitle: const Text('አመራሩ ንቁ ነው'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade700),
                    ),
                    child: const Text('ተወው'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isEditing ? 'አስቀምጥ' : 'መዝግብ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final leader = Leader(
        id: widget.existingLeader?.id ?? '',
        fullName: _fullNameController.text.trim(),
        christianName: _christianNameController.text.trim(),
        phone: _phoneController.text.trim(),
        phone2: _phone2Controller.text.trim(),
        role: _role,
        assignedTsiwaIds: _selectedTsiwaIds.toList(),
        edirRole: _role == LeaderRole.edirAmerar ? _edirRole : null,
        isActive: _isActive,
      );

      if (_isEditing) {
        await _leaderRepository.updateLeader(widget.areaId, leader);
      } else {
        await _leaderRepository.createLeader(widget.areaId, leader);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('መረጃውን ማስቀመጥ አልተቻለም።')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
