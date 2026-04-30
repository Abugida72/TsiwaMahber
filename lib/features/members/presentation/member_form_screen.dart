import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/members/data/member_repository.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class MemberFormScreen extends StatefulWidget {
  final String areaId;
  final String tsiwaId;
  final Member? existingMember;

  const MemberFormScreen({
    super.key,
    required this.areaId,
    required this.tsiwaId,
    this.existingMember,
  });

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memberRepository = MemberRepository();

  late final TextEditingController _fullNameController;
  late final TextEditingController _christianNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _phone2Controller;
  late final TextEditingController _idNumberController;
  late final TextEditingController _addressController;
  late final TextEditingController _orderIndexController;

  late MemberRole _role;
  late bool _isInRotation;
  late bool _isHiddenPhone;
  late bool _isHiddenName;
  late bool _isActive;
  bool _isSaving = false;

  bool get _isEditing => widget.existingMember != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMember;

    _fullNameController = TextEditingController(text: m?.fullName ?? '');
    _christianNameController =
        TextEditingController(text: m?.christianName ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _phone2Controller = TextEditingController(text: m?.phone2 ?? '');
    _idNumberController = TextEditingController(text: m?.idNumber ?? '');
    _addressController = TextEditingController(text: m?.address ?? '');
    _orderIndexController =
        TextEditingController(text: m?.orderIndex.toString() ?? '');

    _role = m?.role ?? MemberRole.member;
    _isInRotation = m?.isInRotation ?? true;
    _isHiddenPhone = m?.isHiddenPhone ?? false;
    _isHiddenName = m?.isHiddenName ?? false;
    _isActive = m?.isActive ?? true;

    if (!_isEditing) {
      _loadNextOrderIndex();
    }
  }

  Future<void> _loadNextOrderIndex() async {
    try {
      final nextIndex = await _memberRepository.getNextOrderIndex(
        widget.areaId,
        widget.tsiwaId,
      );
      if (mounted) {
        _orderIndexController.text = nextIndex.toString();
      }
    } catch (_) {
      // Use default
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _christianNameController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    _idNumberController.dispose();
    _addressController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'አባል አርትዕ' : S.newMember),
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
            _buildSectionHeader(S.personalInfo),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _fullNameController,
              label: 'ሙሉ ስም *',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.fullNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _christianNameController,
              label: S.christianName,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: S.phoneNumber,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phone2Controller,
              label: S.additionalPhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _idNumberController,
              label: 'መታወቂያ ቁጥር',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _addressController,
              label: S.address,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('ሚና እና ተራ'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.role,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MemberRole.values.map((role) {
                        final isSelected = _role == role;
                        return ChoiceChip(
                          label: Text(role.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _role = role);
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildNumberField(
              controller: _orderIndexController,
              label: 'የተራ ቁጥር',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'የተራ ቁጥር ያስገቡ';
                }
                final idx = int.tryParse(value);
                if (idx == null || idx < 0) {
                  return 'ትክክለኛ ቁጥር ያስገቡ';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(S.status),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('በተራ ውስጥ'),
                    subtitle: const Text('አባሉ በፅዋ ተራ ውስጥ ነው'),
                    value: _isInRotation,
                    onChanged: (value) =>
                        setState(() => _isInRotation = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(S.active),
                    subtitle: const Text('አባሉ ንቁ ነው'),
                    value: _isActive,
                    onChanged: (value) =>
                        setState(() => _isActive = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('ስልክ ደብቅ'),
                    subtitle: const Text('ስልክ ቁጥሩ ለሌሎች አይታይም'),
                    value: _isHiddenPhone,
                    onChanged: (value) =>
                        setState(() => _isHiddenPhone = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('ስም ደብቅ'),
                    subtitle: const Text('የክርስትና ስሙ ለሌሎች አይታይም'),
                    value: _isHiddenName,
                    onChanged: (value) =>
                        setState(() => _isHiddenName = value),
                  ),
                ],
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
                    child: Text(S.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isEditing ? S.save : S.record),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final member = Member(
        id: widget.existingMember?.id ?? '',
        fullName: _fullNameController.text.trim(),
        christianName: _christianNameController.text.trim(),
        phone: _phoneController.text.trim(),
        phone2: _phone2Controller.text.trim(),
        idNumber: _idNumberController.text.trim(),
        address: _addressController.text.trim(),
        role: _role,
        orderIndex: int.tryParse(_orderIndexController.text.trim()) ?? 0,
        isInRotation: _isInRotation,
        isHiddenPhone: _isHiddenPhone,
        isHiddenName: _isHiddenName,
        isActive: _isActive,
      );

      final duplicateError = await _memberRepository.checkDuplicate(
        widget.areaId,
        widget.tsiwaId,
        member,
        excludeMemberId: _isEditing ? widget.existingMember!.id : null,
      );

      if (duplicateError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(duplicateError)),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      if (_isEditing) {
        await _memberRepository.updateMember(
          widget.areaId,
          widget.tsiwaId,
          member,
        );
      } else {
        await _memberRepository.createMember(
          widget.areaId,
          widget.tsiwaId,
          member,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.dataSaveFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
