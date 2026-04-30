import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? S.cancel),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText ?? S.confirm),
        ),
      ],
    );
  }
}
