import 'dart:convert';
import 'dart:io';

import 'package:nanobot_dart/src/config/config.dart';
import 'package:nanobot_dart/src/config/loader.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ConfigLoader', () {
    late Directory tempDir;
    late String configPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('nanobot_config_test_');
      configPath = p.join(tempDir.path, 'config.json');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('loadConfig loads from file', () async {
      final file = File(configPath);
      await file.writeAsString(
        jsonEncode(
          {
            'agents': {
              'defaults': {'model': 'custom-model'},
            },
          },
        ),
      );

      final config = await loadConfig(path: configPath);
      expect(config.agents.defaults.model, 'custom-model');
    });

    test('loadConfig handles missing file with defaults', () async {
      final config = await loadConfig(path: configPath);
      expect(config.agents.defaults.model, isNotEmpty);
    });

    test('loadConfig handles invalid JSON with defaults', () async {
      final file = File(configPath);
      await file.writeAsString('invalid json');

      final config = await loadConfig(path: configPath);
      expect(config.agents.defaults.model, isNotEmpty);
    });

    test('saveConfig writes to file', () async {
      await loadConfig(path: configPath);

      const updatedConfig = Config(
        agents: AgentsConfig(
          defaults: AgentDefaults(model: 'saved-model'),
        ),
      );

      await saveConfig(updatedConfig, path: configPath);

      final file = File(configPath);
      expect(file.existsSync(), isTrue);

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      expect(
        ((json['agents'] as Map<String, dynamic>)['defaults']
            as Map<String, dynamic>)['model'],
        'saved-model',
      );
    });

    test('environment overrides apply correctly', () async {
      final env = {
        'NANOBOT_AGENTS__DEFAULTS__MODEL': 'env-model',
        'NANOBOT_AGENTS__DEFAULTS__MAX_TOKENS': '500',
        'NANOBOT_PROVIDERS__OPENAI__API_KEY': 'env-key',
        'NANOBOT_GATEWAY__PORT': '9999',
      };

      final config = await loadConfig(path: configPath, environment: env);

      expect(config.agents.defaults.model, 'env-model');
      expect(config.agents.defaults.maxTokens, 500);
      expect(config.providers.openai.apiKey, 'env-key');
      expect(config.gateway.port, 9999);
    });

    test('type conversions in overrides', () async {
      final env = {
        'NANOBOT_GATEWAY__PORT': '9999',
        'NANOBOT_CHANNELS__WHATSAPP__ENABLED': 'true',
      };

      final config = await loadConfig(path: configPath, environment: env);

      expect(config.gateway.port, 9999);
      expect(config.channels.whatsapp.enabled, isTrue);
    });

    test('getConfigPath returns expected path', () {
      final path = getConfigPath();
      expect(path, contains('.nanobot'));
      expect(path, endsWith('config.json'));
    });

    test('saveConfig creates nested directories', () async {
      final nestedPath = p.join(tempDir.path, 'nested', 'dir', 'config.json');
      const config = Config();
      await saveConfig(config, path: nestedPath);
      expect(File(nestedPath).existsSync(), isTrue);
    });

    test('loadConfig handles double parsing in environment variables',
        () async {
      final env = {
        'NANOBOT_AGENTS__DEFAULTS__TEMPERATURE': '0.5',
      };
      final config = await loadConfig(path: configPath, environment: env);
      expect(config.agents.defaults.temperature, 0.5);
    });
  });
}
