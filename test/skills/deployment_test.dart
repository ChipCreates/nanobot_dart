import 'dart:io';
import 'package:nanobot_dart/src/skills/registry.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('SkillsRegistry Deployment', () {
    late String tempDir;
    late SkillsRegistry registry;

    setUp(() async {
      tempDir = p.join(
        Directory.systemTemp.path,
        'nanobot_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      await Directory(tempDir).create(recursive: true);
      registry = SkillsRegistry(workspacePath: tempDir);
    });

    tearDown(() async {
      await Directory(tempDir).delete(recursive: true);
    });

    test('deployBuiltins creates skill files', () async {
      await registry.deployBuiltins();

      final githubSkill = File(
        p.join(tempDir, '.nanobot', 'skills', 'builtin', 'github', 'SKILL.md'),
      );
      expect(githubSkill.existsSync(), isTrue);
      expect(await githubSkill.readAsString(), contains('name: github'));

      final tmuxScript = File(
        p.join(
          tempDir,
          '.nanobot',
          'skills',
          'builtin',
          'tmux',
          'scripts',
          'find-sessions.sh',
        ),
      );
      expect(tmuxScript.existsSync(), isTrue);

      // On non-windows, check executable bit if possibly?
      // Process.run('ls', ['-l', tmuxScript.path]) etc.
      if (!Platform.isWindows) {
        final result = await Process.run(
          'ls',
          ['-l', tmuxScript.path],
        );
        expect(result.stdout as String, contains('x'));
      }
    });

    test('loadAll loads deployed skills', () async {
      await registry.deployBuiltins();
      await registry.loadAll();

      expect(registry.names, contains('github'));
      expect(registry.names, contains('weather'));
      expect(registry.get('github')?.description, contains('GitHub'));
    });
  });
}
