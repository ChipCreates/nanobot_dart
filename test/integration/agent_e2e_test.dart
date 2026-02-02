import 'dart:io';

import 'package:nanobot_dart/nanobot_dart.dart';
import 'package:test/test.dart';

import 'mock_provider.dart';

void main() {
  group('Agent E2E', () {
    late Directory tempDir;
    late Config config;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('nanobot_e2e_');
      config = Config(
        agents: AgentsConfig(
          defaults: AgentDefaults(
            workspace: tempDir.path,
            maxToolIterations: 5,
          ),
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Agent processes message and returns response', () async {
      final mockProvider = MockIntegrationProvider(
        responses: [
          const LlmResponse(content: 'Hello! How can I help you today?'),
        ],
      );

      final agent = NanoAgent(
        config: config,
        provider: mockProvider,
      );

      const message = InboundMessage(
        content: 'Hi there',
        channel: 'test-channel',
        chatId: 'user-123', senderId: 'user',
      );

      final response = await agent.process(message);

      expect(response.content, 'Hello! How can I help you today?');
      expect(response.iteration, 1);
    });

    test('Agent maintains session history', () async {
      final mockProvider = MockIntegrationProvider(
        responses: [
          const LlmResponse(content: 'Response 1'),
          const LlmResponse(content: 'Response 2'),
        ],
      );

      final agent = NanoAgent(
        config: config,
        provider: mockProvider,
      );

      // Turn 1
      await agent.process(
        const InboundMessage(
          content: 'Message 1',
          channel: 'test',
          chatId: 'session-1', senderId: 'user',
        ),
      );

      // Turn 2
      await agent.process(
        const InboundMessage(
          content: 'Message 2',
          channel: 'test',
          chatId: 'session-1', senderId: 'user',
        ),
      );

      final session = await agent.sessions.getOrCreate('test:session-1');
      expect(session.messages, hasLength(4)); // User 1, Asst 1, User 2, Asst 2
      expect(session.messages[0].content, 'Message 1');
      expect(session.messages[1].content, 'Response 1');
      expect(session.messages[2].content, 'Message 2');
      expect(session.messages[3].content, 'Response 2');
    });
  });
}
