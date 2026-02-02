import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nanobot_dart/src/config/config.dart';
import 'package:path/path.dart' as p;

final _logger = Logger('ConfigLoader');

/// Get the default configuration file path.
///
/// Returns ~/.nanobot/config.json
String getConfigPath() {
  final home = Platform.environment['HOME'];
  if (home == null) {
    throw StateError('HOME environment variable not set');
  }
  return p.join(home, '.nanobot', 'config.json');
}

/// Load configuration from file or create default.
Future<Config> loadConfig({
  String? path,
  Map<String, String>? environment,
}) async {
  final configPath = path ?? getConfigPath();
  final file = File(configPath);
  var json = <String, dynamic>{};

  if (file.existsSync()) {
    try {
      final content = await file.readAsString();
      json = jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      _logger
        ..warning('Failed to load config from $configPath: $e')
        ..info('Using default configuration.');
    }
  }

  // Apply environment overrides
  json = _applyEnvOverrides(json, environment ?? Platform.environment);

  return Config.fromJson(json);
}

Map<String, dynamic> _applyEnvOverrides(
  Map<String, dynamic> base,
  Map<String, String> env,
) {
  final result = Map<String, dynamic>.from(base);

  for (final key in env.keys) {
    if (key.startsWith('NANOBOT_')) {
      final value = env[key];
      if (value == null) continue;

      // Remove prefix and lowercase the first segment to match our snake_case expectation
      // actually, Pydantic settings are case-insensitive usually, but here we mapped to internal JSON structure.
      // Our fromJson expects keys like 'agents', 'providers'.
      // NANOBOT_AGENTS__DEFAULTS__MODEL -> agents.defaults.model

      final parts = key.substring(8).toLowerCase().split('__');
      _setNested(result, parts, value);
    }
  }
  return result;
}

void _setNested(Map<String, dynamic> map, List<String> path, String value) {
  var current = map;
  for (var i = 0; i < path.length - 1; i++) {
    final key = path[i];

    // Create nested map if it doesn't exist
    if (!current.containsKey(key) || current[key] is! Map) {
      current[key] = <String, dynamic>{};
    }

    current = current[key] as Map<String, dynamic>;
  }

  final lastKey = path.last;
  // Attempt simple type conversion for bool/int/double
  if (value.toLowerCase() == 'true') {
    current[lastKey] = true;
  } else if (value.toLowerCase() == 'false') {
    current[lastKey] = false;
  } else if (int.tryParse(value) != null) {
    current[lastKey] = int.parse(value);
  } else if (double.tryParse(value) != null) {
    current[lastKey] = double.parse(value);
  } else {
    current[lastKey] = value;
  }
}

/// Save configuration to file.
Future<void> saveConfig(Config config, {String? path}) async {
  final configPath = path ?? getConfigPath();
  final file = File(configPath);

  await file.parent.create(recursive: true);

  final json = config.toJson();
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(json));
}
