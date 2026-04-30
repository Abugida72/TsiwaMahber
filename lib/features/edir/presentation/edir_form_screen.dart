import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class EdirFormScreen extends StatefulWidget {
  final String areaId;
  final Edir? edir;

  const EdirFormScreen({
    super.key,
    required this.areaId,
    this.edir,
  });

  @override
  State<EdirFormScreen> createState() => _EdirFormScreenState();
}

class _EdirFormScreenState extends State<EdirFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = EdirRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contributionController;
  late final TextEditingController _penaltyController;
  late final TextEditingController _paymentDayController;

  bool _isSaving = false;

  bool get _isEditing => widget.edir != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.edir?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.edir?.description ?? '');
    _contributionController = TextEditingController(
        text: widget.edir?.monthlyContribution.toStringAsFixed(0) ?? '');
    _penaltyController = TextEditingController(
        text: widget.edir?.penaltyAmount.toStringAsFixed(0) ?? '');
    _paymentDayController = TextEditingController(
        text: widget.edir?.paymentDay.toString() ?? '1');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contributionController.dispose();
    _penaltyController.dispose();
    _paymentDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? S.editEdir : S.newEdir),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ስም *',
                hintText: S.edirName,
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
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: S.description,
                hintText: S.aboutEdir,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contributionController,
              decoration: InputDecoration(
                labelText: S.monthlyContribution,
                hintText: '100',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.monthlyContribRequired;
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return S.validAmountRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _penaltyController,
              decoration: InputDecoration(
                labelText: S.penaltyAmount,
                hintText: '50',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paymentDayController,
              decoration: InputDecoration(
                labelText: S.paymentDay,
                hintText: '1',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final day = int.tryParse(value);
                  if (day == null || day < 1 || day > 30) {
                    return S.dayMustBe1to30;
                  }
                }
                return null;
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
                  : Text(_isEditing ? S.save : S.create),
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
      final edir = (widget.edir ?? const Edir()).copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        monthlyContribution:
            double.tryParse(_contributionController.text) ?? 0,
        penaltyAmount: double.tryParse(_penaltyController.text) ?? 0,
        paymentDay: int.tryParse(_paymentDayController.text) ?? 1,
      );

      if (_isEditing) {
        await _repository.updateEdir(widget.areaId, edir);
      } else {
        await _repository.createEdir(widget.areaId, edir);
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
