import 'dart:io';

import 'package:nanobot_dart/src/skills/skill.dart';
import 'package:test/test.dart';

void main() {
  group('Skill', () {
    test('parses valid SKILL.md content', () {
      const content = '''
---
name: test_skill
description: A test skill
requirements:
  - git
capabilities:
  - testing
---
# Test Skill
This is the body.
''';

      final skill = Skill.parse(content);
      expect(skill, isNotNull);
      expect(skill!.name, 'test_skill');
      expect(skill.description, 'A test skill');
      expect(skill.requirements, ['git']);
      expect(skill.capabilities, ['testing']);
      expect(skill.content, '# Test Skill\nThis is the body.');
    });

    test('parses minimal SKILL.md content', () {
      const content = '''
---
name: minimal
---
Body content
''';

      final skill = Skill.parse(content);
      expect(skill, isNotNull);
      expect(skill!.name, 'minimal');
      expect(skill.description, '');
      expect(skill.requirements, isEmpty);
      expect(skill.capabilities, isEmpty);
      expect(skill.content, 'Body content');
    });

    test('returns null for invalid content', () {
      const content = 'invalid content';
      final skill = Skill.parse(content);
      expect(skill, isNull);
    });

    test('checkRequirements returns true for existing command', () async {
      final cmd = Platform.isWindows ? 'cmd' : 'ls';
      final skill = Skill(
        name: 'test',
        description: 'test',
        content: '',
        requirements: [cmd],
      );

      final result = await skill.checkRequirements();
      expect(result, isTrue);
    });

    test('checkRequirements returns false for non-existing command', () async {
      const skill = Skill(
        name: 'test',
        description: 'test',
        content: '',
        requirements: ['non_existent_command_12345'],
      );

      final result = await skill.checkRequirements();
      expect(result, isFalse);
    });

    test('checkRequirements ignores config requirements for now', () async {
      const skill = Skill(
        name: 'test',
        description: 'test',
        content: '',
        requirements: ['config:api_key'],
      );

      final result = await skill.checkRequirements();
      expect(result, isTrue);
    });
  });
}
