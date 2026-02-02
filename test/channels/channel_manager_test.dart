import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/bus/message_bus.dart';
import 'package:nanobot_dart/src/channels/manager.dart';
import 'package:test/test.dart';

void main() {
  group('ChannelManager', () {
    late MessageBus bus;
    late ChannelManager manager;

    setUp(() {
      bus = MessageBus();
      manager = ChannelManager(bus);
    });

    tearDown(() async {
      await manager.stop();
      await bus.dispose();
    });

    test('initializes with empty channels', () {
      expect(manager.channels, isEmpty);
    });

    test('initChannels with empty config does nothing', () {
      manager.initChannels({});
      expect(manager.channels, isEmpty);
    });

    test('initChannels with disabled telegram does not add channel', () {
      manager.initChannels({
        'telegram': {
          'enabled': false,
          'token': 'test-token',
        },
      });
      expect(manager.channels, isEmpty);
    });

    test('initChannels with disabled whatsapp does not add channel', () {
      manager.initChannels({
        'whatsapp': {
          'enabled': false,
        },
      });
      expect(manager.channels, isEmpty);
    });

    test('initChannels with enabled telegram adds channel', () {
      manager.initChannels({
        'telegram': {
          'enabled': true,
          'token': 'test-token',
        },
      });
      expect(manager.channels.containsKey('telegram'), isTrue);
    });

    test('initChannels with enabled whatsapp adds channel', () {
      manager.initChannels({
        'whatsapp': {
          'enabled': true,
        },
      });
      expect(manager.channels.containsKey('whatsapp'), isTrue);
    });

    test('start and stop without channels works', () async {
      await manager.start();
      await manager.stop();
      expect(true, isTrue); // No exception thrown
    });

    // Note: Testing actual channel start/stop requires mocking external APIs
    // (Telegram, WhatsApp) which is outside the scope of unit tests.
    // Integration tests would cover those scenarios.
  });

  group('ChannelManager message routing', () {
    late MessageBus bus;
    late ChannelManager manager;

    setUp(() {
      bus = MessageBus();
      manager = ChannelManager(bus);
    });

    tearDown(() async {
      await manager.stop();
      await bus.dispose();
    });

    test('cli channel messages are ignored without warning', () async {
      // Start manager (no channels configured)
      await manager.start();

      // Send a message to cli channel (should be silently ignored)
      bus.publishOutbound(
        const OutboundMessage(
          channel: 'cli',
          chatId: 'direct',
          content: 'Test message',
        ),
      );

      // Give time for message to be processed
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // No exception should be thrown
      expect(true, isTrue);
    });
  });
}
