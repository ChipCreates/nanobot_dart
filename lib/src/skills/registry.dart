// Placeholder - Skills registry

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:nanobot_dart/src/skills/bundles.dart';
import 'package:nanobot_dart/src/skills/skill.dart';
import 'package:path/path.dart' as p;

/// Registry for loading and managing skills.
class SkillsRegistry {
  SkillsRegistry({required this.workspacePath});

  final String workspacePath;
  final Map<String, Skill> _skills = {};

  final _logger = Logger('SkillsRegistry');

  String get _skillsDir => '$workspacePath/.nanobot/skills';
  String get _builtinDir => '$workspacePath/.nanobot/skills/builtin';

  /// Load all skills from workspace.
  ///
  /// Loads built-in skills first, then workspace skills.
  /// Workspace skills with same name will override built-in ones.
  Future<void> loadAll() async {
    // 1. Load built-ins explicitly
    await _loadFromDirectory(_builtinDir);

    // 2. Load workspace skills (excluding builtin to avoid double loading/order issues)
    // We manually list the top-level skills directory and recurse, but skip 'builtin' folder.
    final rootSkillsDir = Directory(_skillsDir);
    if (rootSkillsDir.existsSync()) {
      await _loadRecursively(rootSkillsDir, skipPaths: {_builtinDir});
    }
  }

  /// Deploy built-in skills to the workspace.
  Future<void> deployBuiltins() async {
    _logger.info('Deploying built-in skills to $_builtinDir');
    final builtinDir = Directory(_builtinDir);
    if (!builtinDir.existsSync()) {
      builtinDir.createSync(recursive: true);
    }

    for (final entry in BuiltinSkillsBundle.files.entries) {
      final parts = entry.key.split('/');
      // parts[0] is skill name, parts[1..] is file path inside skill
      // e.g. github/SKILL.md, tmux/scripts/find-sessions.sh

      if (parts.length < 2) continue;

      final fullPath = p.join(_builtinDir, entry.key);
      final file = File(fullPath);

      // Create parent dir if needed
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }

      // Write file (overwrite if exists, or check version?)
      // For now, simple overwrite to ensure parity
      await file.writeAsString(entry.value);

      // Make scripts executable
      if (fullPath.endsWith('.sh') || fullPath.endsWith('.py')) {
        try {
          // Use chmod +x
          await Process.run('chmod', ['+x', fullPath]);
        } catch (e) {
          _logger.warning('Failed to make executable: $fullPath');
        }
      }
    }
  }

  /// Helper to load a specific directory (mostly for built-ins).
  Future<void> _loadFromDirectory(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) return;
    await _loadRecursively(dir);
  }

  Future<void> _loadRecursively(
    Directory dir, {
    Set<String> skipPaths = const {},
  }) async {
    try {
      if (skipPaths.contains(dir.path)) return;

      final List<FileSystemEntity> entities;
      try {
        entities = dir.listSync();
      } catch (e) {
        _logger.warning('Failed to list directory: ${dir.path}', e);
        return;
      }

      for (final entity in entities) {
        if (entity is Directory) {
          if (!skipPaths.contains(entity.path)) {
            await _loadRecursively(entity, skipPaths: skipPaths);
          }
        } else if (entity is File && entity.path.endsWith('SKILL.md')) {
          final skill = await Skill.load(entity.path);
          if (skill != null) {
            // Check requirements before adding
            if (await skill.checkRequirements()) {
              _skills[skill.name] = skill;
            } else {
              _logger
                  .info('Skipping skill ${skill.name}: requirements not met');
            }
          }
        }
      }
    } catch (e) {
      _logger.severe('Error loading skills from ${dir.path}', e);
    }
  }

  /// Get a skill by name.
  Skill? get(String name) => _skills[name];

  /// Get all skill names.
  List<String> get names => _skills.keys.toList();

  /// Build a skills summary for prompt injection.
  String buildSummary() {
    if (_skills.isEmpty) return '';

    final buffer = StringBuffer('Available skills:\n');
    for (final skill in _skills.values) {
      buffer.writeln('- ${skill.name}: ${skill.description}');
      if (skill.requirements.isNotEmpty) {
        buffer.writeln('  Requirements: ${skill.requirements.join(', ')}');
      }
      if (skill.capabilities.isNotEmpty) {
        buffer.writeln('  Capabilities: ${skill.capabilities.join(', ')}');
      }
    }
    return buffer.toString();
  }
}
