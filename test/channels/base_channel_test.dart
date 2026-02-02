import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/bus/message_bus.dart';
import 'package:nanobot_dart/src/channels/base.dart';
import 'package:test/test.dart';

/// Test channel implementation to test BaseChannel
class TestChannel extends BaseChannel {
  TestChannel(super.config, super.bus);

  final List<OutboundMessage> sentMessages = [];

  @override
  String get name => 'test';

  @override
  Future<void> send(OutboundMessage msg) async {
    sentMessages.add(msg);
  }
}

/// Config class for testing
class TestConfig {
  TestConfig({this.allowFrom});
  final List<String>? allowFrom;
}

void main() {
  group('BaseChannel', () {
    late MessageBus bus;

    setUp(() {
      bus = MessageBus();
    });

    tearDown(() {
      bus.dispose();
    });

    test('start sets isRunning to true', () async {
      final channel = TestChannel(TestConfig(), bus);
      expect(channel.isRunning, isFalse);

      await channel.start();
      expect(channel.isRunning, isTrue);

      await channel.stop();
    });

    test('stop sets isRunning to false', () async {
      final channel = TestChannel(TestConfig(), bus);
      await channel.start();
      expect(channel.isRunning, isTrue);

      await channel.stop();
      expect(channel.isRunning, isFalse);
    });

    test('isAllowed returns true when allowList is null', () {
      final channel = TestChannel(TestConfig(), bus);
      expect(channel.isAllowed('anyone'), isTrue);
    });

    test('isAllowed returns true when allowList is empty', () {
      final channel = TestChannel(TestConfig(allowFrom: []), bus);
      expect(channel.isAllowed('anyone'), isTrue);
    });

    test('isAllowed returns true when sender in allowList', () {
      final channel = TestChannel(
        TestConfig(allowFrom: ['user1', 'user2']),
        bus,
      );
      expect(channel.isAllowed('user1'), isTrue);
      expect(channel.isAllowed('user2'), isTrue);
    });

    test('isAllowed returns false when sender not in allowList', () {
      final channel = TestChannel(
        TestConfig(allowFrom: ['user1']),
        bus,
      );
      expect(channel.isAllowed('unknown'), isFalse);
    });

    test('handleMessage publishes to bus when allowed', () async {
      final channel = TestChannel(TestConfig(), bus);

      final messages = <InboundMessage>[];
      bus.inbound.listen(messages.add);

      await channel.handleMessage(
        senderId: 'user1',
        chatId: 'chat1',
        content: 'Hello!',
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(messages.length, 1);
      expect(messages.first.channel, 'test');
      expect(messages.first.senderId, 'user1');
      expect(messages.first.chatId, 'chat1');
      expect(messages.first.content, 'Hello!');
    });

    test('handleMessage does not publish when not allowed', () async {
      final channel = TestChannel(
        TestConfig(allowFrom: ['allowed_user']),
        bus,
      );

      final messages = <InboundMessage>[];
      bus.inbound.listen(messages.add);

      await channel.handleMessage(
        senderId: 'blocked_user',
        chatId: 'chat1',
        content: 'Hello!',
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(messages, isEmpty);
    });

    test('handleMessage includes media and metadata', () async {
      final channel = TestChannel(TestConfig(), bus);

      final messages = <InboundMessage>[];
      bus.inbound.listen(messages.add);

      await channel.handleMessage(
        senderId: 'user1',
        chatId: 'chat1',
        content: 'Check this out',
        media: ['image.jpg'],
        metadata: {'type': 'photo'},
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(messages.first.media, ['image.jpg']);
      expect(messages.first.metadata!['type'], 'photo');
    });

    test('send method works correctly', () async {
      final channel = TestChannel(TestConfig(), bus);
      const msg = OutboundMessage(
        channel: 'test',
        chatId: 'chat1',
        content: 'Response',
      );

      await channel.send(msg);

      expect(channel.sentMessages.length, 1);
      expect(channel.sentMessages.first.content, 'Response');
    });
  });
}
