import 'package:nanobot_dart/src/agent/memory/narrative_builder.dart';
import 'package:test/test.dart';

void main() {
  group('NarrativeBuilder', () {
    late NarrativeBuilder builder;

    setUp(() {
      builder = NarrativeBuilder();
    });

    test('formats simple memory entry', () {
      final memory = <String, dynamic>{
        'timestamp': '2024-01-15T10:30:00Z',
        'content': 'User prefers concise answers',
      };

      final narrative = builder.formatMemory(memory);

      expect(narrative, contains('2024-01-15'));
      expect(narrative, contains('User prefers concise answers'));
    });

    test('formats memory with metadata', () {
      final memory = <String, dynamic>{
        'timestamp': '2024-01-15T10:30:00Z',
        'content': 'Important fact',
        'tags': ['preference', 'important'],
        'source': 'conversation',
      };

      final narrative = builder.formatMemory(memory);

      expect(narrative, contains('Important fact'));
      expect(narrative, contains('preference'));
      expect(narrative, contains('important'));
    });

    test('summarizes daily memories', () {
      final memories = [
        <String, dynamic>{
          'timestamp': '2024-01-15T09:00:00Z',
          'content': 'Morning meeting notes',
        },
        <String, dynamic>{
          'timestamp': '2024-01-15T14:00:00Z',
          'content': 'Afternoon work session',
        },
      ];

      final summary = builder.summarizeDailyMemories(memories);

      expect(summary, contains('Morning meeting notes'));
      expect(summary, contains('Afternoon work session'));
      expect(summary, isNot(isEmpty));
    });

    test('summarizes long-term memory', () {
      final longTerm = <String, dynamic>{
        'facts': [
          'User is a software developer',
          'Prefers Dart and Flutter',
        ],
        'preferences': [
          'Concise explanations',
          'Code examples',
        ],
      };

      final summary = builder.summarizeLongTerm(longTerm);

      expect(summary, contains('software developer'));
      expect(summary, contains('Dart and Flutter'));
      expect(summary, contains('Concise explanations'));
    });

    test('converts JSON to markdown format', () {
      final data = <String, dynamic>{
        'title': 'Important Notes',
        'items': ['First item', 'Second item'],
      };

      final markdown = builder.toMarkdown(data);

      expect(markdown, contains('Important Notes'));
      expect(markdown, contains('First item'));
      expect(markdown, contains('Second item'));
    });

    test('handles empty memory list', () {
      final summary = builder.summarizeDailyMemories([]);
      expect(summary, isEmpty);
    });

    test('handles null values gracefully', () {
      final memory = <String, dynamic>{
        'timestamp': null,
        'content': 'Test content',
      };

      final narrative = builder.formatMemory(memory);
      expect(narrative, contains('Test content'));
    });

    test('formats memory context for prompts', () {
      final context = <String, dynamic>{
        'long_term': 'User facts',
        'recent': ['Today note 1', 'Today note 2'],
      };

      final formatted = builder.formatForPrompt(context);

      expect(formatted, contains('User facts'));
      expect(formatted, contains('Today note 1'));
      expect(formatted, contains('Today note 2'));
    });

    test('creates readable timestamp format', () {
      final memory = <String, dynamic>{
        'timestamp': '2024-01-15T10:30:00Z',
        'content': 'Test',
      };

      final narrative = builder.formatMemory(memory);

      // Should contain a human-readable date
      expect(narrative, contains('2024'));
      expect(narrative, contains('01'));
      expect(narrative, contains('15'));
    });

    test('supports markdown headers in output', () {
      final memories = [
        <String, dynamic>{
          'timestamp': '2024-01-15T09:00:00Z',
          'content': 'Test memory',
        },
      ];

      final summary = builder.summarizeDailyMemories(memories);

      // Should use markdown formatting
      expect(summary, anyOf(contains('#'), contains('-'), contains('*')));
    });
  });
}
