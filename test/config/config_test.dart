import 'package:nanobot_dart/src/config/config.dart';
import 'package:test/test.dart';

void main() {
  group('Config Serialization', () {
    test('Config serializes to/from JSON correctly', () {
      const config = Config(
        agents: AgentsConfig(
          defaults: AgentDefaults(
            model: 'test-model',
            maxTokens: 100,
          ),
        ),
        providers: ProvidersConfig(
          openai: ProviderConfig(apiKey: 'sk-test'),
        ),
      );

      final json = config.toJson();
      final decoded = Config.fromJson(json);

      expect(decoded.agents.defaults.model, 'test-model');
      expect(decoded.agents.defaults.maxTokens, 100);
      expect(decoded.providers.openai.apiKey, 'sk-test');
      expect(decoded.apiKey, 'sk-test'); // Helper getter
    });

    test('Helper getters prioritize correctly', () {
      const config = Config(
        providers: ProvidersConfig(
          openai: ProviderConfig(apiKey: 'sk-openai'),
          anthropic: ProviderConfig(apiKey: 'sk-anthropic'),
          openrouter: ProviderConfig(apiKey: 'sk-openrouter'),
        ),
      );

      // OpenRouter > Anthropic > OpenAI
      expect(config.apiKey, 'sk-openrouter');
      expect(config.apiBase, 'https://openrouter.ai/api/v1'); // Default base
    });

    test('Helper getters fall through', () {
      const config = Config(
        providers: ProvidersConfig(
          openai: ProviderConfig(apiKey: 'sk-openai'),
        ),
      );
      expect(config.apiKey, 'sk-openai');
    });

    test('Defaults are correct', () {
      const config = Config();
      expect(config.agents.defaults.model, 'anthropic/claude-opus-4-5');
      expect(config.gateway.port, 18790);
    });
  });
}
