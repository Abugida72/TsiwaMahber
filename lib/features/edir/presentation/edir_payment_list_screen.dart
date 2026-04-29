import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/widgets/empty_state.dart';
import 'package:tsiwa_mahber/core/widgets/loading_state.dart';
import 'package:tsiwa_mahber/features/edir/data/edir_repository.dart';
import 'package:tsiwa_mahber/features/edir/domain/payment.dart';

class EdirPaymentListScreen extends StatefulWidget {
  final String areaId;
  final String edirId;
  final String edirName;

  const EdirPaymentListScreen({
    super.key,
    required this.areaId,
    required this.edirId,
    required this.edirName,
  });

  @override
  State<EdirPaymentListScreen> createState() =>
      _EdirPaymentListScreenState();
}

class _EdirPaymentListScreenState extends State<EdirPaymentListScreen> {
  final _repository = EdirRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.edirName} — ክፍያዎች'),
      ),
      body: StreamBuilder<List<Payment>>(
        stream:
            _repository.watchPayments(widget.areaId, widget.edirId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'መረጃ ማግኘት አልተቻለም',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'በመጫን ላይ...');
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return const EmptyState(
              icon: Icons.payment,
              title: 'እስካሁን ክፍያ አልተመዘገበም።',
              message: 'ከአባላት ዝርዝር ክፍያ ማስመዝገብ ይችላሉ',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: payments.length,
            itemBuilder: (context, index) =>
                _buildPaymentCard(payments[index]),
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final typeColor = payment.type == PaymentType.penalty
        ? Colors.red
        : payment.type == PaymentType.monthly
            ? AppTheme.primary
            : AppTheme.secondary;

    final dateStr = payment.createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(payment.createdAt!)
        : '';

    String periodStr = '';
    if (payment.forMonth != null && payment.forYear != null) {
      periodStr =
          '${AppConstants.ethiopianMonthName(payment.forMonth!)} ${payment.forYear}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                payment.type == PaymentType.penalty
                    ? Icons.warning
                    : Icons.payment,
                color: typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.memberName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          payment.type.displayName,
                          style:
                              TextStyle(fontSize: 10, color: typeColor),
                        ),
                      ),
                      if (periodStr.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(periodStr,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted)),
                      ],
                    ],
                  ),
                  if (payment.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(payment.note,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ],
                  if (dateStr.isNotEmpty)
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ),
            Text(
              '${payment.amount.toStringAsFixed(0)} ብር',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: typeColor),
            ),
          ],
        ),
      ),
    );
  }
}
