import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/channels/base.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

class TelegramConfig {
  TelegramConfig({
    required this.token,
    this.allowFrom = const [],
    this.enabled = true,
  });

  final String token;
  final List<String> allowFrom;
  final bool enabled;

  // ignore: prefer_constructors_over_static_methods
  static TelegramConfig fromJson(Map<String, dynamic> json) {
    return TelegramConfig(
      token: json['token'] as String? ?? '',
      allowFrom: (json['allowFrom'] as List?)?.cast<String>() ?? const [],
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class TelegramChannel extends BaseChannel {
  TelegramChannel(TelegramConfig super.config, super.bus);

  @override
  String get name => 'telegram';

  TeleDart? _teledart;
  bool _initialized = false;
  final Logger _logger = Logger('TelegramChannel');

  // Map sender_id to chat_id for replies if they differ (mostly same in Telegram)
  final Map<String, int> _chatIds = {};

  @override
  Future<void> start() async {
    final cfg = config as TelegramConfig;
    if (cfg.token.isEmpty) {
      _logger.severe('Telegram bot token not configured');
      return;
    }

    // Initialize TeleDart
    final username = (await Telegram(cfg.token).getMe()).username;
    _teledart = TeleDart(cfg.token, Event(username!));

    _teledart!.start();
    _initialized = true;
    _logger.info('Telegram bot @$username connected');

    await super.start();

    // Listen for messages
    _teledart!.onMessage(entityType: '*').listen((message) async {
      await handleTeledartMessage(message);
    });

    // Command listener
    _teledart!.onCommand('start').listen((message) async {
      await message
          .reply("👋 Hi ${message.from?.firstName ?? 'there'}! I'm nanobot.\n\n"
              "Send me a message and I'll respond!");
    });
  }

  @visibleForTesting
  void setTeleDartForTest(TeleDart td) {
    _teledart = td;
    _initialized = true;
  }

  @override
  Future<void> stop() async {
    _teledart?.stop();
    _teledart = null;
    _initialized = false;
    await super.stop();
  }

  @override
  Future<void> send(OutboundMessage msg) async {
    if (!_initialized || _teledart == null) {
      _logger.warning('Telegram bot not running');
      return;
    }

    try {
      final chatId = int.tryParse(msg.chatId);
      if (chatId == null) {
        _logger.warning('Invalid chat_id: ${msg.chatId}');
        return;
      }

      // Simple text send
      await _teledart!.sendMessage(chatId, msg.content, parseMode: 'HTML');
    } catch (e) {
      _logger.severe('Error sending Telegram message: $e');
    }
  }

  @visibleForTesting
  Future<void> handleTeledartMessage(TeleDartMessage message) async {
    if (message.from == null) return;

    final user = message.from!;
    final senderId = user.username ?? user.id.toString();
    final chatId = message.chat.id.toString();

    // Store chat ID mapping
    _chatIds[senderId] = message.chat.id;

    final contentParts = <String>[];
    final mediaPaths = <String>[];

    if (message.text != null) {
      contentParts.add(message.text!);
    }
    if (message.caption != null) {
      contentParts.add(message.caption!);
    }

    // Media handling (placeholder for future implementation)
    if (message.photo != null && message.photo!.isNotEmpty) {
      contentParts.add('[image]');
    }

    final content =
        contentParts.isNotEmpty ? contentParts.join('\n') : '[empty message]';

    await handleMessage(
      senderId: senderId,
      chatId: chatId,
      content: content,
      media: mediaPaths,
      metadata: {
        'message_id': message.messageId,
        'user_id': user.id,
        'username': user.username,
        'first_name': user.firstName,
        // message.chat.type is a String in teledart, checking appropriately
        'is_group': message.chat.type != 'private',
      },
    );
  }
}
