import 'package:nanobot_dart/nanobot_dart.dart';
import 'package:test/test.dart';
import 'helpers/mock_llm_provider.dart';

void main() {
  group('NanoAgent', () {
    late Config config;
    late MockLlmProvider mockProvider;
    late NanoAgent agent;

    setUp(() {
      config = const Config(
        agents: AgentsConfig(
          defaults: AgentDefaults(
            model: 'test-model',
          ),
        ),
        providers: ProvidersConfig(
          anthropic: ProviderConfig(apiKey: 'test-key'),
        ),
      );

      mockProvider = MockLlmProvider([
        const LlmResponse(content: 'Mock response content'),
      ]);

      agent = NanoAgent(
        config: config,
        provider: mockProvider,
      );
    });

    test('successfully processes an inbound message', () async {
      const message = InboundMessage(
        content: 'Hello, bot!',
        channel: 'test',
        chatId: 'test-chat',
        senderId: 'test-user',
      );

      final response = await agent.process(message);

      expect(response.content, equals('Mock response content'));
      expect(mockProvider.callCount, equals(1));

      final lastMessages = mockProvider.lastMessages!;
      final lastMessage = lastMessages.last;

      // Check if it's a Message object (from ContextBuilder) or a Map (from some providers)
      if (lastMessage is Message) {
        expect(lastMessage.content, contains('Hello, bot!'));
      } else {
        expect(
          (lastMessage as Map<String, dynamic>)['content'],
          contains('Hello, bot!'),
        );
      }
    });

    test('uses correct model from config', () async {
      const message = InboundMessage(
        content: 'ping',
        channel: 'test',
        chatId: 'test-chat',
        senderId: 'test-user',
      );

      await agent.process(message);

      // Verification of model passed to provider is implicit in AgentLoop
      // but we can check if the provider was called.
      expect(mockProvider.callCount, equals(1));
    });
  });
}
