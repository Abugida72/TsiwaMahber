import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/features/tsiwa/data/tsiwa_repository.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_mahber.dart';

class TsiwaFormScreen extends StatefulWidget {
  final String areaId;
  final TsiwaMahber? existingTsiwa;

  const TsiwaFormScreen({
    super.key,
    required this.areaId,
    this.existingTsiwa,
  });

  @override
  State<TsiwaFormScreen> createState() => _TsiwaFormScreenState();
}

class _TsiwaFormScreenState extends State<TsiwaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tsiwaRepository = TsiwaRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _churchNameController;
  late final TextEditingController _saintNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  late final TextEditingController _monthlyTsiwaDayController;
  late final TextEditingController _monthlyTsiwaDayNoteController;

  late final TextEditingController _zikirTitleController;
  late final TextEditingController _zikirMonthController;
  late final TextEditingController _zikirDayController;
  late final TextEditingController _zikirNoteController;

  late final TextEditingController _feedingTitleController;
  late final TextEditingController _feedingMonthController;
  late final TextEditingController _feedingDayController;
  late final TextEditingController _feedingNoteController;

  late bool _isActive;
  late bool _isArchived;
  bool _isSaving = false;

  bool get _isEditing => widget.existingTsiwa != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTsiwa;

    _nameController = TextEditingController(text: t?.name ?? '');
    _churchNameController = TextEditingController(text: t?.churchName ?? '');
    _saintNameController = TextEditingController(text: t?.saintName ?? '');
    _locationController = TextEditingController(text: t?.location ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');

    _monthlyTsiwaDayController = TextEditingController(
      text: t?.monthlyTsiwaDay.toString() ?? '1',
    );
    _monthlyTsiwaDayNoteController = TextEditingController(
      text: t?.monthlyTsiwaDayNote ?? '',
    );

    _zikirTitleController = TextEditingController(
      text: t?.zikirTitle ?? 'የዝክር ቀን',
    );
    _zikirMonthController = TextEditingController(
      text: t?.zikirMonth?.toString() ?? '',
    );
    _zikirDayController = TextEditingController(
      text: t?.zikirDay?.toString() ?? '',
    );
    _zikirNoteController = TextEditingController(text: t?.zikirNote ?? '');

    _feedingTitleController = TextEditingController(
      text: t?.feedingTitle ?? 'ነድያንን የማብላት ቀን',
    );
    _feedingMonthController = TextEditingController(
      text: t?.feedingMonth?.toString() ?? '',
    );
    _feedingDayController = TextEditingController(
      text: t?.feedingDay?.toString() ?? '',
    );
    _feedingNoteController = TextEditingController(text: t?.feedingNote ?? '');

    _isActive = t?.isActive ?? true;
    _isArchived = t?.isArchived ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _churchNameController.dispose();
    _saintNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _monthlyTsiwaDayController.dispose();
    _monthlyTsiwaDayNoteController.dispose();
    _zikirTitleController.dispose();
    _zikirMonthController.dispose();
    _zikirDayController.dispose();
    _zikirNoteController.dispose();
    _feedingTitleController.dispose();
    _feedingMonthController.dispose();
    _feedingDayController.dispose();
    _feedingNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ፅዋ አርትዕ' : 'አዲስ ፅዋ'),
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
            _buildSectionHeader('መሰረታዊ መረጃ'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              label: 'ፅዋ ስም *',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ፅዋ ስም ያስገቡ';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _churchNameController,
              label: 'የቤተ ክርስቲያን ስም',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _saintNameController,
              label: 'የቅዱስ/ቅድስት ስም',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _locationController,
              label: 'ቦታ',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: 'መግለጫ',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('የወርሃዊ ፅዋ ቀን'),
            const SizedBox(height: 8),
            _buildNumberField(
              controller: _monthlyTsiwaDayController,
              label: 'ቀን (1-30) *',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'የወርሃዊ ፅዋ ቀን ያስገቡ';
                }
                final day = int.tryParse(value);
                if (day == null || day < 1 || day > 30) {
                  return 'ቀን ከ1 እስከ 30 መሆን አለበት';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _monthlyTsiwaDayNoteController,
              label: 'ማስታወሻ',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('የዝክር ቀን'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _zikirTitleController,
              label: 'ርዕስ',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _zikirMonthController,
                    label: 'ወር (1-13)',
                    validator: _validateOptionalMonth,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    controller: _zikirDayController,
                    label: 'ቀን (1-30)',
                    validator: (value) =>
                        _validateOptionalDay(value, _zikirMonthController.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _zikirNoteController,
              label: 'ማስታወሻ',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('ነድያንን የማብላት ቀን'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _feedingTitleController,
              label: 'ርዕስ',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _feedingMonthController,
                    label: 'ወር (1-13)',
                    validator: _validateOptionalMonth,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    controller: _feedingDayController,
                    label: 'ቀን (1-30)',
                    validator: (value) => _validateOptionalDay(
                        value, _feedingMonthController.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _feedingNoteController,
              label: 'ማስታወሻ',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('ሁኔታ'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('ንቁ'),
                    subtitle: const Text('ፅዋው በንቁ ሁኔታ ላይ ነው'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  if (_isEditing) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('ማህደር'),
                      subtitle: const Text('ፅዋውን ወደ ማህደር ያስገቡ'),
                      value: _isArchived,
                      onChanged: (value) =>
                          setState(() => _isArchived = value),
                    ),
                  ],
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
                    child: const Text('ተወው'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isEditing ? 'አስቀምጥ' : 'ፍጠር'),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
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

  String? _validateOptionalMonth(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 13) {
      return 'ወር ከ1 እስከ 13 መሆን አለበት';
    }
    return null;
  }

  String? _validateOptionalDay(String? value, String monthText) {
    final hasMonth = monthText.trim().isNotEmpty;
    final hasDay = value != null && value.trim().isNotEmpty;

    if (hasMonth && !hasDay) {
      return 'ቀን ያስገቡ';
    }
    if (hasDay && !hasMonth) {
      return 'ወር ያስገቡ';
    }
    if (hasDay) {
      final day = int.tryParse(value);
      if (day == null || day < 1 || day > 30) {
        return 'ቀን ከ1 እስከ 30 መሆን አለበት';
      }
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final tsiwa = TsiwaMahber(
        id: widget.existingTsiwa?.id ?? '',
        areaId: widget.areaId,
        name: _nameController.text.trim(),
        churchName: _churchNameController.text.trim(),
        saintName: _saintNameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        monthlyTsiwaDay: int.parse(_monthlyTsiwaDayController.text.trim()),
        monthlyTsiwaDayNote: _monthlyTsiwaDayNoteController.text.trim(),
        zikirTitle: _zikirTitleController.text.trim(),
        zikirMonth: _parseOptionalInt(_zikirMonthController.text),
        zikirDay: _parseOptionalInt(_zikirDayController.text),
        zikirNote: _zikirNoteController.text.trim(),
        feedingTitle: _feedingTitleController.text.trim(),
        feedingMonth: _parseOptionalInt(_feedingMonthController.text),
        feedingDay: _parseOptionalInt(_feedingDayController.text),
        feedingNote: _feedingNoteController.text.trim(),
        isActive: _isActive,
        isArchived: _isArchived,
        currentRotationIndex:
            widget.existingTsiwa?.currentRotationIndex ?? 0,
        memberCount: widget.existingTsiwa?.memberCount ?? 0,
        museCount: widget.existingTsiwa?.museCount ?? 0,
      );

      if (_isEditing) {
        await _tsiwaRepository.updateTsiwa(widget.areaId, tsiwa);
      } else {
        await _tsiwaRepository.createTsiwa(widget.areaId, tsiwa);
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

  int? _parseOptionalInt(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }
}
