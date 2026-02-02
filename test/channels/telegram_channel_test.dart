import 'package:mocktail/mocktail.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/bus/message_bus.dart';
import 'package:nanobot_dart/src/channels/telegram.dart' as tg;
import 'package:teledart/model.dart'; // This contains Message, User, Chat, etc.
import 'package:teledart/teledart.dart';
import 'package:test/test.dart';

class MockTeleDart extends Mock implements TeleDart {}

class MockTeleDartMessage extends Mock implements TeleDartMessage {}

class MockUser extends Mock implements User {}

class MockChat extends Mock implements Chat {}

class TestTelegramChannel extends tg.TelegramChannel {
  TestTelegramChannel({
    required tg.TelegramConfig config,
    required MessageBus bus,
  }) : super(config, bus);
}

void main() {
  group('TelegramChannel', () {
    late MessageBus bus;
    late tg.TelegramConfig config;
    late TestTelegramChannel channel;
    late MockTeleDart mockTeleDart;
    late MockTeleDartMessage mockMsg;
    late MockUser mockFrom;
    late MockChat mockChat;

    setUp(() {
      bus = MessageBus();
      config = tg.TelegramConfig(
        token: 'test_token',
      );
      channel = TestTelegramChannel(config: config, bus: bus);
      mockTeleDart = MockTeleDart();
      mockMsg = MockTeleDartMessage();
      mockFrom = MockUser();
      mockChat = MockChat();
    });

    test('config parsing handles all fields', () {
      final cfg = tg.TelegramConfig.fromJson({
        'token': 'secret_token',
        'enabled': false,
        'allowFrom': ['user1'],
      });
      expect(cfg.token, 'secret_token');
      expect(cfg.enabled, false);
      expect(cfg.allowFrom, contains('user1'));
    });

    test('handleTeledartMessage parses and publishes message', () async {
      final messages = <InboundMessage>[];
      bus.inbound.listen(messages.add);

      when(() => mockMsg.from).thenReturn(mockFrom);
      when(() => mockMsg.chat).thenReturn(mockChat);
      when(() => mockMsg.text).thenReturn('Hello Telegram');
      when(() => mockMsg.messageId).thenReturn(123);

      when(() => mockFrom.id).thenReturn(12345);
      when(() => mockFrom.username).thenReturn('testuser');
      when(() => mockFrom.firstName).thenReturn('Test');

      when(() => mockChat.id).thenReturn(67890);
      when(() => mockChat.type).thenReturn('private');

      await channel.handleTeledartMessage(mockMsg);

      expect(messages.length, 1);
      expect(messages.first.content, 'Hello Telegram');
      expect(messages.first.senderId, 'testuser');
      expect(messages.first.chatId, '67890');
    });

    test('handleTeledartMessage handles captions and photos', () async {
      final messages = <InboundMessage>[];
      bus.inbound.listen(messages.add);

      when(() => mockMsg.from).thenReturn(mockFrom);
      when(() => mockMsg.chat).thenReturn(mockChat);
      when(() => mockMsg.text).thenReturn(null);
      when(() => mockMsg.caption).thenReturn('A caption');
      when(() => mockMsg.photo).thenReturn([
        PhotoSize(fileId: 'f1', fileUniqueId: 'u1', width: 10, height: 10),
      ]);
      when(() => mockMsg.messageId).thenReturn(2);

      when(() => mockFrom.id).thenReturn(12345);
      when(() => mockFrom.username).thenReturn('testuser');
      when(() => mockFrom.firstName).thenReturn('Test');

      when(() => mockChat.id).thenReturn(67890);
      when(() => mockChat.type).thenReturn('group');

      await channel.handleTeledartMessage(mockMsg);

      expect(messages.length, 1);
      expect(messages.first.content, contains('A caption'));
      expect(messages.first.content, contains('[image]'));
      expect(messages.first.metadata?['is_group'], isTrue);
    });

    test('send calls teledart sendMessage', () async {
      channel.setTeleDartForTest(mockTeleDart);
      when(
        () => mockTeleDart.sendMessage(
          any<dynamic>(),
          any<String>(),
          parseMode: any<String>(named: 'parseMode'),
        ),
      ).thenAnswer((_) async => mockMsg);

      const outbound = OutboundMessage(
        content: 'Response',
        chatId: '67890',
        channel: 'telegram',
      );

      await channel.send(outbound);

      verify(
        () => mockTeleDart.sendMessage(
          67890,
          'Response',
          parseMode: any<String>(named: 'parseMode'),
        ),
      ).called(1);
    });

    test('handleTeledartMessage respects allowFrom whitelist', () async {
      final messages = <InboundMessage>[];
      bus.inbound.listen(messages.add);

      final restrictedConfig = tg.TelegramConfig(
        token: 'token',
        allowFrom: ['allowed-user'],
      );
      final restrictedChannel = TestTelegramChannel(
        config: restrictedConfig,
        bus: bus,
      );

      // Blocked user
      when(() => mockMsg.from).thenReturn(mockFrom);
      when(() => mockFrom.username).thenReturn('blocked-user');
      when(() => mockFrom.firstName).thenReturn('Blocked');
      when(() => mockFrom.id).thenReturn(777);
      when(() => mockMsg.chat).thenReturn(mockChat);
      when(() => mockChat.id).thenReturn(1);
      when(() => mockMsg.text).thenReturn('Hi');
      when(() => mockMsg.messageId).thenReturn(3);
      when(() => mockChat.type).thenReturn('private');

      await restrictedChannel.handleTeledartMessage(mockMsg);
      expect(messages, isEmpty);

      // Allowed user
      when(() => mockFrom.username).thenReturn('allowed-user');
      when(() => mockFrom.firstName).thenReturn('Allowed');
      when(() => mockFrom.id).thenReturn(888);
      await restrictedChannel.handleTeledartMessage(mockMsg);
      expect(messages.length, 1);
    });
  });
}
