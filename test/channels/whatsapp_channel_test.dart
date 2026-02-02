import 'dart:async';
import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/bus/message_bus.dart';
import 'package:nanobot_dart/src/channels/whatsapp.dart' as ws;
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MockWebSocketChannel extends Mock implements WebSocketChannel {}

class MockWebSocketSink extends Mock implements WebSocketSink {}

class TestWhatsAppChannel extends ws.WhatsAppChannel {
  TestWhatsAppChannel({
    required ws.WhatsAppConfig config,
    required MessageBus bus,
  }) : super(config, bus);
}

void main() {
  group('WhatsAppChannel', () {
    late MessageBus bus;
    late ws.WhatsAppConfig config;
    late TestWhatsAppChannel channel;
    late MockWebSocketChannel mockWs;
    late MockWebSocketSink mockSink;

    setUp(() {
      bus = MessageBus();
      config = ws.WhatsAppConfig(
        bridgeUrl: 'ws://localhost:3000',
      );
      channel = TestWhatsAppChannel(config: config, bus: bus);
      mockWs = MockWebSocketChannel();
      mockSink = MockWebSocketSink();

      when(() => mockWs.sink).thenReturn(mockSink);
    });

    test('config parsing handles all fields', () {
      final cfg = ws.WhatsAppConfig.fromJson({
        'bridgeUrl': 'ws://remote:8080',
        'enabled': false,
        'allowFrom': ['user1', 'user2'],
      });
      expect(cfg.bridgeUrl, 'ws://remote:8080');
      expect(cfg.enabled, false);
      expect(cfg.allowFrom, containsAll(['user1', 'user2']));
    });

    test('handleBridgeMessage parses and publishes message', () async {
      final messages = <InboundMessage>[];
      bus.inbound.listen(messages.add);

      final payload = jsonEncode({
        'type': 'message',
        'sender': '12345678@s.whatsapp.net',
        'content': 'Hello from WhatsApp',
        'id': 'msg_123',
        'timestamp': 1700000000,
        'isGroup': false,
      });

      channel.handleBridgeMessage(payload);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(messages.length, 1);
      expect(messages.first.content, 'Hello from WhatsApp');
      expect(messages.first.senderId, '12345678');
      expect(messages.first.chatId, '12345678@s.whatsapp.net');
    });

    test('send calls websocket sink with proper payload', () async {
      channel.setWebSocketForTest(mockWs);
      when(() => mockSink.add(any<String>())).thenReturn(null);

      const msg = OutboundMessage(
        content: 'Reply to WhatsApp',
        chatId: '12345678@s.whatsapp.net',
        channel: 'whatsapp',
      );

      await channel.send(msg);

      final captured = verify(() => mockSink.add(captureAny<String?>()))
          .captured
          .first as String;
      final payload = jsonDecode(captured) as Map<String, dynamic>;

      expect(payload['type'], 'send');
      expect(payload['to'], '12345678@s.whatsapp.net');
      expect(payload['text'], 'Reply to WhatsApp');
    });

    test('handleBridgeMessage respects allowFrom whitelist', () async {
      final messages = <InboundMessage>[];
      bus.inbound.listen(messages.add);

      final restrictedConfig = ws.WhatsAppConfig(
        bridgeUrl: 'ws://localhost',
        allowFrom: ['allowed-user'],
      );
      final restrictedChannel = TestWhatsAppChannel(
        config: restrictedConfig,
        bus: bus,
      );

      final payload = jsonEncode({
        'type': 'message',
        'sender': 'blocked-user@s.whatsapp.net',
        'content': 'Hello',
        'id': 'msg1',
        'timestamp': 12345,
      });

      restrictedChannel.handleBridgeMessage(payload);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(messages, isEmpty);

      final allowedPayload = jsonEncode({
        'type': 'message',
        'sender': 'allowed-user@s.whatsapp.net',
        'content': 'Hello',
        'id': 'msg2',
        'timestamp': 12346,
      });

      restrictedChannel.handleBridgeMessage(allowedPayload);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(messages.length, 1);
    });

    test('handleBridgeMessage handles qr, status, and error', () {
      channel
        ..handleBridgeMessage(jsonEncode({'type': 'qr', 'qr': 'test-qr'}))
        ..handleBridgeMessage(
          jsonEncode({'type': 'status', 'status': 'connected'}),
        )
        ..handleBridgeMessage(
          jsonEncode({'type': 'error', 'error': 'some error'}),
        );
      // These should just log and not crash
      expect(true, isTrue);
    });

    test('handleBridgeMessage handles malformed JSON', () {
      // Should not crash
      channel.handleBridgeMessage('invalid json');
      expect(true, isTrue);
    });
  });
}
