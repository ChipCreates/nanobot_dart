import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/channels/base.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WhatsAppConfig {
  WhatsAppConfig({
    required this.bridgeUrl,
    this.allowFrom = const [],
    this.enabled = true,
  });

  final String bridgeUrl;
  final List<String> allowFrom;
  final bool enabled;

  // ignore: prefer_constructors_over_static_methods
  static WhatsAppConfig fromJson(Map<String, dynamic> json) {
    return WhatsAppConfig(
      bridgeUrl: json['bridgeUrl'] as String? ?? 'ws://localhost:3000',
      allowFrom: (json['allowFrom'] as List?)?.cast<String>() ?? const [],
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class WhatsAppChannel extends BaseChannel {
  WhatsAppChannel(WhatsAppConfig super.config, super.bus);

  @override
  String get name => 'whatsapp';

  WebSocketChannel? _ws;
  bool _connected = false;
  final Logger _logger = Logger('WhatsAppChannel');

  @override
  Future<void> start() async {
    final cfg = config as WhatsAppConfig;
    _log('Connecting to WhatsApp bridge at ${cfg.bridgeUrl}...');

    await super.start();

    unawaited(_connectLoop());
  }

  Future<void> _connectLoop() async {
    final cfg = config as WhatsAppConfig;

    while (isRunning) {
      try {
        final uri = Uri.parse(cfg.bridgeUrl);
        _ws = WebSocketChannel.connect(uri);
        await _ws!.ready;

        _connected = true;
        _log('Connected to WhatsApp bridge');

        // Listen for messages
        await _ws!.stream.listen(
          (dynamic message) {
            if (message is String) {
              _handleBridgeMessage(message);
            }
          },
          onDone: () {
            _connected = false;
            _log('WhatsApp bridge disconnected');
          },
          onError: (Object error) {
            _connected = false;
            _logger.warning('WhatsApp bridge error: $error');
          },
        ).asFuture<void>();
      } catch (e) {
        _connected = false;
        _logger.warning('WhatsApp connection error: $e');
      }

      if (isRunning && !_connected) {
        _log('Reconnecting in 5 seconds...');
        await Future<void>.delayed(const Duration(seconds: 5));
      }
    }
  }

  @override
  Future<void> stop() async {
    await super.stop();
    await _ws?.sink.close();
    _ws = null;
    _connected = false;
  }

  @override
  Future<void> send(OutboundMessage msg) async {
    if (_ws == null || !_connected) {
      _logger.warning('WhatsApp bridge not connected');
      return;
    }

    try {
      final payload = {
        'type': 'send',
        'to': msg.chatId,
        'text': msg.content,
      };
      _ws!.sink.add(jsonEncode(payload));
    } catch (e) {
      _logger.severe('Error sending WhatsApp message: $e');
    }
  }

  void _handleBridgeMessage(String raw) {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final type = data['type'] as String?;

      if (type == 'message') {
        final sender = data['sender'] as String? ?? '';
        final content = data['content'] as String? ?? '';

        // sender is typically: <phone>@s.whatsapp.net
        final chatId = sender.contains('@') ? sender.split('@')[0] : sender;

        handleMessage(
          senderId: chatId,
          chatId: sender, // Use full JID for replies
          content: content,
          metadata: {
            'message_id': data['id'],
            'timestamp': data['timestamp'],
            'is_group': data['isGroup'] ?? false,
          },
        );
      } else if (type == 'status') {
        final status = data['status'];
        _log('WhatsApp status: $status');
      } else if (type == 'qr') {
        _log('Scan QR code in the bridge terminal to connect WhatsApp');
      } else if (type == 'error') {
        _logger.severe('WhatsApp bridge error: ${data['error']}');
      }
    } catch (e) {
      _logger.warning('Invalid JSON from bridge: $raw');
    }
  }

  void _log(String message) {
    _logger.info(message);
  }
}
