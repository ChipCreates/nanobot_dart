import 'dart:async';

import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/bus/message_bus.dart';
import 'package:test/test.dart';

void main() {
  group('MessageBus', () {
    late MessageBus bus;

    setUp(() {
      bus = MessageBus();
    });

    tearDown(() async {
      await bus.dispose();
    });

    test('publishes and receives inbound messages', () async {
      const message = InboundMessage(
        content: 'Test message',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final future = bus.inbound.first;
      bus.publishInbound(message);

      final received = await future;
      expect(received.content, 'Test message');
      expect(received.channel, 'test');
      expect(received.chatId, '123');
    });

    test('publishes and receives outbound messages', () async {
      const message = OutboundMessage(
        content: 'Response',
        channel: 'test',
        chatId: '123',
      );

      final future = bus.outbound.first;
      bus.publishOutbound(message);

      final received = await future;
      expect(received.content, 'Response');
      expect(received.channel, 'test');
      expect(received.chatId, '123');
    });

    test('emits events for inbound messages', () async {
      const message = InboundMessage(
        content: 'Test',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final future = bus.events.first;
      bus.publishInbound(message);

      final event = await future;
      expect(event.type, MessageEventType.inbound);
      expect(event.inbound?.content, 'Test');
    });

    test('emits events for outbound messages', () async {
      const message = OutboundMessage(
        content: 'Response',
        channel: 'test',
        chatId: '123',
      );

      final future = bus.events.first;
      bus.publishOutbound(message);

      final event = await future;
      expect(event.type, MessageEventType.outbound);
      expect(event.outbound?.content, 'Response');
    });

    test('logs tool execution events', () async {
      final future = bus.events.first;
      bus.logToolExecution('test_tool');

      final event = await future;
      expect(event.type, MessageEventType.toolExecution);
      expect(event.toolName, 'test_tool');
    });

    test('logs error events', () async {
      final future = bus.events.first;
      bus.logError('Test error');

      final event = await future;
      expect(event.type, MessageEventType.error);
      expect(event.error, 'Test error');
    });

    test('supports multiple subscribers', () async {
      const message = InboundMessage(
        content: 'Broadcast',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final futures = [
        bus.inbound.first,
        bus.inbound.first,
        bus.inbound.first,
      ];

      bus.publishInbound(message);

      final results = await Future.wait(futures);
      expect(results.length, 3);
      expect(results.every((m) => m.content == 'Broadcast'), true);
    });

    test('handles message metadata', () async {
      const message = InboundMessage(
        content: 'Test',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
        metadata: <String, dynamic>{'user_id': 'user123', 'priority': 'high'},
      );

      final future = bus.inbound.first;
      bus.publishInbound(message);

      final received = await future;
      expect(received.metadata?['user_id'], 'user123');
      expect(received.metadata?['priority'], 'high');
    });

    test('disposes cleanly', () async {
      bus.publishInbound(
        const InboundMessage(
          content: 'Test',
          channel: 'test',
          chatId: '123',
          senderId: 'user',
        ),
      );

      await bus.dispose();

      // Streams should be closed
      expect(bus.inbound.isBroadcast, true);
    });
  });

  group('InboundMessage', () {
    test('generates session key', () {
      const message = InboundMessage(
        content: 'Test',
        channel: 'telegram',
        chatId: '12345',
        senderId: 'user',
      );

      expect(message.sessionKey, 'telegram:12345');
    });

    test('handles different channel types', () {
      const messages = [
        InboundMessage(
          content: 'Test',
          channel: 'app',
          chatId: '1',
          senderId: 'user',
        ),
        InboundMessage(
          content: 'Test',
          channel: 'cli',
          chatId: '2',
          senderId: 'user',
        ),
        InboundMessage(
          content: 'Test',
          channel: 'telegram',
          chatId: '3',
          senderId: 'user',
        ),
      ];

      expect(messages[0].sessionKey, 'app:1');
      expect(messages[1].sessionKey, 'cli:2');
      expect(messages[2].sessionKey, 'telegram:3');
    });
  });

  group('MessageEvent', () {
    test('creates inbound event with timestamp', () {
      const message = InboundMessage(
        content: 'Test',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final event = MessageEvent.inboundReceived(message);

      expect(event.type, MessageEventType.inbound);
      expect(event.inbound, message);
      expect(event.timestamp, isA<DateTime>());
    });

    test('creates outbound event with timestamp', () {
      const message = OutboundMessage(
        content: 'Response',
        channel: 'test',
        chatId: '123',
      );

      final event = MessageEvent.outboundSent(message);

      expect(event.type, MessageEventType.outbound);
      expect(event.outbound, message);
      expect(event.timestamp, isA<DateTime>());
    });

    test('creates tool execution event', () {
      final event = MessageEvent.toolExecuted('search');

      expect(event.type, MessageEventType.toolExecution);
      expect(event.toolName, 'search');
      expect(event.timestamp, isA<DateTime>());
    });

    test('creates error event', () {
      final event = MessageEvent.errorOccurred('Network error');

      expect(event.type, MessageEventType.error);
      expect(event.error, 'Network error');
      expect(event.timestamp, isA<DateTime>());
    });
  });
}
