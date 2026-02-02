// Placeholder - Skill loader and interface

import 'dart:io';
import 'package:yaml/yaml.dart';

/// A skill loaded from a SKILL.md file.
class Skill {
  const Skill({
    required this.name,
    required this.description,
    required this.content,
    this.requirements = const [],
    this.capabilities = const [],
  });

  /// Skill name from frontmatter.
  final String name;

  /// Skill description from frontmatter.
  final String description;

  /// Skill content (markdown body).
  final String content;

  /// Required executables or config keys.
  final List<String> requirements;

  /// Capabilities this skill provides.
  final List<String> capabilities;

  /// Load a skill from a SKILL.md file.
  static Future<Skill?> load(String path) async {
    final file = File(path);
    if (!file.existsSync()) return null;

    final content = file.readAsStringSync();
    return parse(content);
  }

  /// Parse a SKILL.md file content.
  static Skill? parse(String content) {
    // Split frontmatter from body
    final parts = content.split('---');
    if (parts.length < 3) return null;

    try {
      final frontmatter = loadYaml(parts[1]) as Map;
      // Rejoin the rest of the parts in case the body contains '---'
      final body = parts.sublist(2).join('---').trim();

      return Skill(
        name: frontmatter['name'] as String? ?? 'unnamed',
        description: frontmatter['description'] as String? ?? '',
        content: body,
        requirements:
            (frontmatter['requirements'] as List<dynamic>?)?.cast<String>() ??
                [],
        capabilities:
            (frontmatter['capabilities'] as List<dynamic>?)?.cast<String>() ??
                [],
      );
    } catch (e) {
      // In a real app we might log this error
      return null;
    }
  }

  /// Check if all requirements are met.
  Future<bool> checkRequirements() async {
    for (final req in requirements) {
      if (!_checkRequirement(req)) return false;
    }
    return true;
  }

  bool _checkRequirement(String req) {
    if (req.isEmpty) return true;

    // Check for config key requirement (starts with config:)
    if (req.startsWith('config:')) {
      // Config checking to be implemented
      return true;
    }

    // Check for executable requirement
    // Simple check: try to find it in PATH (platform specific)
    try {
      if (Platform.isWindows) {
        final result = Process.runSync('where', [req]);
        return result.exitCode == 0;
      } else {
        final result = Process.runSync('which', [req]);
        return result.exitCode == 0;
      }
    } catch (e) {
      return false;
    }
  }
}

/// Abstract base class for programmatic skills.
abstract class NanoSkill {
  /// Skill name.
  String get name;

  /// Skill description.
  String get description;

  /// Required permissions.
  List<String> get permissions => [];

  /// Capabilities this skill provides.
  List<String> get capabilities => [];

  /// Execute the skill with given parameters.
  Future<String> execute(Map<String, dynamic> params);
}
