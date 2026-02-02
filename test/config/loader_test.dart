import 'dart:io';

import 'package:nanobot_dart/src/config/config.dart';
import 'package:nanobot_dart/src/config/loader.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ConfigLoader', () {
    late Directory tempDir;
    late String tempConfigPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('nanobot_test_');
      tempConfigPath = p.join(tempDir.path, 'config.json');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('loadConfig returns default if file missing', () async {
      final config = await loadConfig(path: tempConfigPath);
      expect(config.agents.defaults.model, 'anthropic/claude-opus-4-5');
    });

    test('saveConfig writes file and loadConfig reads it', () async {
      const original = Config(
        agents: AgentsConfig(
          defaults: AgentDefaults(model: 'custom-model'),
        ),
      );

      await saveConfig(original, path: tempConfigPath);

      final loaded = await loadConfig(path: tempConfigPath);
      expect(loaded.agents.defaults.model, 'custom-model');
    });

    test('loadConfig handles bad JSON gracefully', () async {
      File(tempConfigPath).writeAsStringSync('{ bad json }');
      final config = await loadConfig(path: tempConfigPath);
      // Should fall back to default
      expect(config.agents.defaults.model, 'anthropic/claude-opus-4-5');
    });
    test('loadConfig applies environment overrides', () async {
      final config = await loadConfig(
        path: tempConfigPath,
        environment: {
          'NANOBOT_AGENTS__DEFAULTS__MODEL': 'env-model',
          'NANOBOT_PROVIDERS__OPENAI__API_KEY': 'env-key',
          'NANOBOT_GATEWAY__PORT': '9000',
        },
      );

      expect(config.agents.defaults.model, 'env-model');
      expect(config.providers.openai.apiKey, 'env-key');
      expect(config.gateway.port, 9000);
    });
  });
}
