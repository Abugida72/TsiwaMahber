import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/utils/ethiopian_calendar.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/edir/domain/payment.dart';

class RecordPaymentScreen extends StatefulWidget {
  final String areaId;
  final String edirId;
  final EdirMember member;
  final double monthlyContribution;

  const RecordPaymentScreen({
    super.key,
    required this.areaId,
    required this.edirId,
    required this.member,
    required this.monthlyContribution,
  });

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = EdirRepository();

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  PaymentType _type = PaymentType.monthly;
  late int _forMonth;
  late int _forYear;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.monthlyContribution.toStringAsFixed(0));
    _noteController = TextEditingController();

    final today = EthiopianCalendar.today();
    _forMonth = today.month;
    _forYear = today.year;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ክፍያ መዝግብ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        widget.member.fullName.isNotEmpty
                            ? widget.member.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.member.fullName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        Text(
                          'ቀሪ ዕዳ: ${widget.member.balance.toStringAsFixed(0)} ብር',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'የክፍያ ዓይነት',
              ),
              items: PaymentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                    if (value == PaymentType.monthly) {
                      _amountController.text =
                          widget.monthlyContribution.toStringAsFixed(0);
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'መጠን (ብር) *',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'መጠን ያስፈልጋል';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'ትክክለኛ መጠን ያስገቡ';
                }
                return null;
              },
            ),
            if (_type == PaymentType.monthly) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _forMonth,
                      decoration: const InputDecoration(
                        labelText: 'ለየትኛው ወር',
                      ),
                      items: List.generate(13, (i) {
                        final month = i + 1;
                        return DropdownMenuItem(
                          value: month,
                          child: Text(
                              AppConstants.ethiopianMonthName(month)),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _forMonth = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _forYear,
                      decoration: const InputDecoration(
                        labelText: 'ዓ.ም.',
                      ),
                      items: List.generate(5, (i) {
                        final year = _forYear - 2 + i;
                        return DropdownMenuItem(
                          value: year,
                          child: Text('$year'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _forYear = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'ማስታወሻ',
                hintText: 'ተጨማሪ ማስታወሻ',
              ),
              maxLines: 2,
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
                  : const Text('ክፍያ መዝግብ'),
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
      final payment = Payment(
        memberId: widget.member.id,
        memberName: widget.member.fullName,
        type: _type,
        amount: double.tryParse(_amountController.text) ?? 0,
        note: _noteController.text.trim(),
        forMonth: _type == PaymentType.monthly ? _forMonth : null,
        forYear: _type == PaymentType.monthly ? _forYear : null,
      );

      await _repository.recordPayment(
          widget.areaId, widget.edirId, payment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ክፍያ ተመዝግቧል')),
        );
        Navigator.pop(context);
      }
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
