/// Builds human-readable narrative summaries from memory data.
///
/// Converts structured JSON memory data into readable markdown format
/// for display and LLM prompt injection.
class NarrativeBuilder {
  /// Format a single memory entry into readable text.
  String formatMemory(Map<String, dynamic> memory) {
    final buffer = StringBuffer();
    final timestamp = memory['timestamp'] as String?;
    final content = memory['content'] as String?;
    final tags = memory['tags'] as List<dynamic>?;

    if (timestamp != null) {
      // Extract date from ISO8601 timestamp
      final date = timestamp.split('T').first;
      buffer.writeln('**$date**');
    }

    if (content != null) {
      buffer.writeln(content);
    }

    if (tags != null && tags.isNotEmpty) {
      buffer.writeln('\n_Tags: ${tags.join(', ')}_');
    }

    return buffer.toString().trim();
  }

  /// Summarize a list of daily memories into readable format.
  String summarizeDailyMemories(List<Map<String, dynamic>> memories) {
    if (memories.isEmpty) return '';

    final buffer = StringBuffer()..writeln('# Daily Memories\n');

    for (final memory in memories) {
      final formatted = formatMemory(memory);
      buffer.writeln('- $formatted\n');
    }

    return buffer.toString().trim();
  }

  /// Summarize long-term memory data.
  String summarizeLongTerm(Map<String, dynamic> longTerm) {
    final buffer = StringBuffer()..writeln('# Long-term Memory\n');

    for (final entry in longTerm.entries) {
      buffer.writeln('## ${_capitalize(entry.key)}\n');

      if (entry.value is List) {
        for (final item in entry.value as List<dynamic>) {
          buffer.writeln('- $item');
        }
      } else {
        buffer.writeln(entry.value.toString());
      }

      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  /// Convert structured data to markdown format.
  String toMarkdown(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    for (final entry in data.entries) {
      if (entry.key == 'title') {
        buffer.writeln('# ${entry.value}\n');
      } else if (entry.value is List) {
        buffer.writeln('## ${_capitalize(entry.key)}\n');
        for (final item in entry.value as List<dynamic>) {
          buffer.writeln('- $item');
        }
        buffer.writeln();
      } else {
        buffer.writeln('**${_capitalize(entry.key)}**: ${entry.value}\n');
      }
    }

    return buffer.toString().trim();
  }

  /// Format memory context for LLM prompts.
  String formatForPrompt(Map<String, dynamic> context) {
    final buffer = StringBuffer();

    if (context.containsKey('long_term')) {
      buffer
        ..writeln('## Long-term Memory\n')
        ..writeln(context['long_term'])
        ..writeln();
    }

    if (context.containsKey('recent')) {
      buffer.writeln('## Recent Notes\n');
      final recent = context['recent'] as List<dynamic>;
      for (final note in recent) {
        buffer.writeln('- $note');
      }
    }

    return buffer.toString().trim();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
