import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class EdirMemberFormScreen extends StatefulWidget {
  final String areaId;
  final String edirId;
  final EdirMember? member;

  const EdirMemberFormScreen({
    super.key,
    required this.areaId,
    required this.edirId,
    this.member,
  });

  @override
  State<EdirMemberFormScreen> createState() => _EdirMemberFormScreenState();
}

class _EdirMemberFormScreenState extends State<EdirMemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = EdirRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _christianNameController;
  late final TextEditingController _phoneController;
  late EdirMemberStatus _status;

  bool _isSaving = false;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.member?.fullName ?? '');
    _christianNameController =
        TextEditingController(text: widget.member?.christianName ?? '');
    _phoneController =
        TextEditingController(text: widget.member?.phone ?? '');
    _status = widget.member?.status ?? EdirMemberStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _christianNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? S.editMember : S.newMember),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ሙሉ ስም *',
                hintText: S.memberFullName,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.nameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _christianNameController,
              decoration: InputDecoration(
                labelText: S.christianName,
                hintText: S.memberChristianName,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: S.phone,
                hintText: '09xxxxxxxx',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EdirMemberStatus>(
              initialValue: _status,
              decoration: InputDecoration(
                labelText: S.status,
              ),
              items: EdirMemberStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? S.save : S.add),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final member = (widget.member ?? const EdirMember()).copyWith(
        fullName: _nameController.text.trim(),
        christianName: _christianNameController.text.trim(),
        phone: _phoneController.text.trim(),
        status: _status,
      );

      if (_isEditing) {
        await _repository.updateEdirMember(
            widget.areaId, widget.edirId, member);
      } else {
        await _repository.addEdirMember(
            widget.areaId, widget.edirId, member);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ስህተት: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
