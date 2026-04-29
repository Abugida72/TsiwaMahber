import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class TelegramService {
  final FirebaseFirestore _firestore;

  TelegramService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<TelegramConfig?> getConfig(String areaId) async {
    final doc = await _firestore
        .doc('areas/$areaId/config/telegram')
        .get();
    if (!doc.exists) return null;
    return TelegramConfig.fromMap(doc.data()!);
  }

  Future<void> saveConfig(
      String areaId, TelegramConfig config) async {
    await _firestore
        .doc('areas/$areaId/config/telegram')
        .set(config.toMap());
  }

  Future<bool> sendMessage({
    required String botToken,
    required String chatId,
    required String message,
  }) async {
    try {
      final url = Uri.parse(
          'https://api.telegram.org/bot$botToken/sendMessage');
      final response = await http.post(url, body: {
        'chat_id': chatId,
        'text': message,
        'parse_mode': 'HTML',
      });
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendAnnouncement({
    required String areaId,
    required String title,
    required String body,
    required String priority,
    required String authorName,
  }) async {
    final config = await getConfig(areaId);
    if (config == null || !config.isEnabled) return false;

    final priorityEmoji = switch (priority) {
      'urgent' => '🚨',
      'important' => '⚠️',
      _ => '📢',
    };

    final message = '''
$priorityEmoji <b>$title</b>

$body

✍️ $authorName
''';

    return sendMessage(
      botToken: config.botToken,
      chatId: config.chatId,
      message: message,
    );
  }

  Future<bool> testConnection(
      String botToken, String chatId) async {
    return sendMessage(
      botToken: botToken,
      chatId: chatId,
      message: '✅ ቴሌግራም ተገናኝቷል — TsiwaMahber',
    );
  }

  Future<String?> getBotInfo(String botToken) async {
    try {
      final url = Uri.parse(
          'https://api.telegram.org/bot$botToken/getMe');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          return data['result']['first_name'] as String?;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class TelegramConfig {
  final String botToken;
  final String chatId;
  final bool isEnabled;
  final bool sendAnnouncements;
  final bool sendEvents;

  const TelegramConfig({
    this.botToken = '',
    this.chatId = '',
    this.isEnabled = false,
    this.sendAnnouncements = true,
    this.sendEvents = false,
  });

  factory TelegramConfig.fromMap(Map<String, dynamic> map) {
    return TelegramConfig(
      botToken: map['botToken'] as String? ?? '',
      chatId: map['chatId'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? false,
      sendAnnouncements: map['sendAnnouncements'] as bool? ?? true,
      sendEvents: map['sendEvents'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'botToken': botToken,
      'chatId': chatId,
      'isEnabled': isEnabled,
      'sendAnnouncements': sendAnnouncements,
      'sendEvents': sendEvents,
    };
  }

  TelegramConfig copyWith({
    String? botToken,
    String? chatId,
    bool? isEnabled,
    bool? sendAnnouncements,
    bool? sendEvents,
  }) {
    return TelegramConfig(
      botToken: botToken ?? this.botToken,
      chatId: chatId ?? this.chatId,
      isEnabled: isEnabled ?? this.isEnabled,
      sendAnnouncements: sendAnnouncements ?? this.sendAnnouncements,
      sendEvents: sendEvents ?? this.sendEvents,
    );
  }
}
