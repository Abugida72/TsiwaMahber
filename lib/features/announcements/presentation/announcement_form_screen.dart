import 'package:flutter/material.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/features/announcements/data/announcement_repository.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/notifications/data/notification_repository.dart';
import 'package:tsiwa_mahber/features/notifications/data/telegram_service.dart';
import 'package:tsiwa_mahber/features/notifications/domain/app_notification.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final String areaId;
  final Announcement? announcement;
  final AppUser? currentUser;

  const AnnouncementFormScreen({
    super.key,
    required this.areaId,
    this.announcement,
    this.currentUser,
  });

  @override
  State<AnnouncementFormScreen> createState() =>
      _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState
    extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AnnouncementRepository();
  final _notificationRepository = NotificationRepository();
  final _telegramService = TelegramService();

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late AnnouncementPriority _priority;
  bool _isSaving = false;

  bool get _isEditing => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
        text: widget.announcement?.title ?? '');
    _bodyController = TextEditingController(
        text: widget.announcement?.body ?? '');
    _priority = widget.announcement?.priority ??
        AnnouncementPriority.normal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? S.editAnnouncement
            : S.newAnnouncement),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'ርዕስ *',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.titleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: S.detail,
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.detailRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AnnouncementPriority>(
              initialValue: _priority,
              decoration: InputDecoration(
                labelText: S.level,
              ),
              items: AnnouncementPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
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
      final announcement = Announcement(
        id: widget.announcement?.id ?? '',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        priority: _priority,
        authorId: widget.currentUser?.uid ?? '',
        authorName: widget.currentUser?.displayName ?? '',
        isActive: widget.announcement?.isActive ?? true,
      );

      if (_isEditing) {
        await _repository.updateAnnouncement(
            widget.areaId, announcement);
      } else {
        await _repository.createAnnouncement(
            widget.areaId, announcement);

        // Send in-app notifications to all users
        final notification = AppNotification(
          title: 'አዲስ ማስታወቂያ: ${announcement.title}',
          body: announcement.body.length > 100
              ? '${announcement.body.substring(0, 100)}...'
              : announcement.body,
          type: NotificationType.announcement,
          senderId: widget.currentUser?.uid,
          senderName: widget.currentUser?.displayName,
        );

        _notificationRepository.sendNotificationToAll(
          areaId: widget.areaId,
          notification: notification,
        );

        // Send to Telegram if configured
        _telegramService.sendAnnouncement(
          areaId: widget.areaId,
          title: announcement.title,
          body: announcement.body,
          priority: announcement.priority.firestoreValue,
          authorName: widget.currentUser?.displayName ??
              AppConstants.defaultAreaShortName,
        );
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
