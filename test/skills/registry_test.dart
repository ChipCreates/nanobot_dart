import 'dart:io';

import 'package:nanobot_dart/src/skills/registry.dart';
import 'package:test/test.dart';

void main() {
  group('SkillsRegistry', () {
    late Directory tempDir;
    late String workspacePath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('nanobot_test_');
      workspacePath = tempDir.path;
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('loads skills from builtin & workspace dirs', () async {
      // Create built-in skill
      final builtinDir = Directory('$workspacePath/.nanobot/skills/builtin')
        ..createSync(recursive: true);
      File('${builtinDir.path}/builtin.SKILL.md').writeAsStringSync('''
---
name: builtin_skill
description: Built-in skill
---
Body
''');

      // Create workspace skill
      final workspaceDir = Directory('$workspacePath/.nanobot/skills')
        ..createSync(recursive: true);
      File('${workspaceDir.path}/workspace.SKILL.md').writeAsStringSync('''
---
name: workspace_skill
description: Workspace skill
---
Body
''');

      final registry = SkillsRegistry(workspacePath: workspacePath);
      await registry.loadAll();

      expect(registry.names, containsAll(['builtin_skill', 'workspace_skill']));
    });

    test('workspace skill overrides built-in skill via same name', () async {
      // Create built-in skill
      final builtinDir = Directory('$workspacePath/.nanobot/skills/builtin')
        ..createSync(recursive: true);
      File('${builtinDir.path}/common.SKILL.md').writeAsStringSync('''
---
name: common_skill
description: Built-in version
---
Built-in Body
''');

      // Create workspace skill with same name
      final workspaceDir = Directory('$workspacePath/.nanobot/skills')
        ..createSync(recursive: true);
      File('${workspaceDir.path}/override.SKILL.md').writeAsStringSync('''
---
name: common_skill
description: Workspace version
---
Workspace Body
''');

      final registry = SkillsRegistry(workspacePath: workspacePath);
      await registry.loadAll();

      final skill = registry.get('common_skill');
      expect(skill, isNotNull);
      expect(skill!.description, 'Workspace version');
      expect(skill.content, 'Workspace Body');
    });

    test('skips skills with unmet requirements', () async {
      final workspaceDir = Directory('$workspacePath/.nanobot/skills')
        ..createSync(recursive: true);
      File('${workspaceDir.path}/impossible.SKILL.md').writeAsStringSync('''
---
name: impossible
description: Needs non-existent command
requirements:
  - non_existent_command_12345
---
Body
''');

      final registry = SkillsRegistry(workspacePath: workspacePath);
      await registry.loadAll();

      expect(registry.names, isNot(contains('impossible')));
    });

    test('buildSummary returns formatted string', () async {
      final workspaceDir = Directory('$workspacePath/.nanobot/skills')
        ..createSync(recursive: true);
      final cmd = Platform.isWindows ? 'cmd' : 'ls';
      File('${workspaceDir.path}/test.SKILL.md').writeAsStringSync('''
---
name: test
description: Test Description
requirements:
  - $cmd
capabilities:
  - cap1
---
Body
''');
      final registry = SkillsRegistry(workspacePath: workspacePath);
      await registry.loadAll();

      final summary = registry.buildSummary();
      expect(summary, contains('Available skills:'));
      expect(summary, contains('- test: Test Description'));
      // Since requirements are checked (and req1 is missing), this skill might not load if we mock properly.
      // But wait, "req1" check will fail in our `Skill.checkRequirements` implementation unless we mock it or use a real command.
      // Let's use a real command for this test to ensure it loads.
    });

    test('buildSummary works with loaded skills', () async {
      final workspaceDir = Directory('$workspacePath/.nanobot/skills')
        ..createSync(recursive: true);
      final cmd = Platform.isWindows ? 'cmd' : 'ls';
      File('${workspaceDir.path}/real.SKILL.md').writeAsStringSync('''
---
name: real
description: Real Description
requirements:
  - $cmd
capabilities:
  - cap1
---
Body
''');
      final registry = SkillsRegistry(workspacePath: workspacePath);
      await registry.loadAll();

      final summary = registry.buildSummary();
      expect(summary, contains('Available skills:'));
      expect(summary, contains('- real: Real Description'));
      expect(summary, contains('Requirements: $cmd'));
      expect(summary, contains('Capabilities: cap1'));
    });
  });
}
