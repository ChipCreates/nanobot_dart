import 'package:nanobot_dart/nanobot_dart.dart';

void main() async {
  // 1. Configure the agent
  const config = Config(
    agents: AgentsConfig(
      defaults: AgentDefaults(
        model: 'anthropic/claude-3-5-sonnet-20240620',
      ),
    ),
    providers: ProvidersConfig(
      anthropic: ProviderConfig(apiKey: 'your-api-key'),
    ),
  );

  // 2. Initialize the provider and agent
  final provider = AnthropicProvider(
    apiKey: config.providers.anthropic.apiKey,
  );
  final agent = NanoAgent(
    config: config,
    provider: provider,
  );

  // 3. Process a message
  print('--- NanoBot Example ---'); // ignore: avoid_print
  print('Sending message: "What is a nanobot?"'); // ignore: avoid_print

  try {
    final response = await agent.process(
      const InboundMessage(
        content: 'What is a nanobot?',
        channel: 'cli',
        chatId: 'example-session',
        senderId: 'user-123',
      ),
    );

    // 4. Print the response
    print('Response: ${response.content}'); // ignore: avoid_print
  } catch (e) {
    // ignore: avoid_print
    print(
      'Note: This example requires a valid API key to run fully.',
    );
    print('Error: $e'); // ignore: avoid_print
  }
}
