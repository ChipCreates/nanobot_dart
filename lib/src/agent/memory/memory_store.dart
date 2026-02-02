// Placeholder - Memory store implementation

import 'dart:io';

/// Memory store for daily notes and long-term memory.
///
/// Based on NanoBot's memory pattern:
/// - Daily notes: `YYYY-MM-DD.md` files
/// - Long-term memory: `MEMORY.md` file
class MemoryStore {
  MemoryStore({required this.workspacePath});

  final String workspacePath;

  String get _memoryDir => '$workspacePath/.nanobot/memory';
  String get _longTermPath => '$_memoryDir/MEMORY.md';

  /// Get today's memory file path.
  String get todayPath {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return '$_memoryDir/$date.md';
  }

  /// Append a memory to today's notes.
  Future<void> appendToday(String content) async {
    final file = File(todayPath);
    await file.parent.create(recursive: true);

    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString(
      '## $timestamp\n\n$content\n\n',
      mode: FileMode.append,
    );
  }

  /// Read today's memories.
  Future<String?> readToday() async {
    final file = File(todayPath);
    if (!file.existsSync()) return null;
    return file.readAsStringSync();
  }

  /// Read long-term memory.
  Future<String?> readLongTerm() async {
    final file = File(_longTermPath);
    if (!file.existsSync()) return null;
    return file.readAsStringSync();
  }

  /// Write to long-term memory.
  Future<void> writeLongTerm(String content) async {
    final file = File(_longTermPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  /// Get recent memories (last N days).
  Future<List<String>> getRecentMemories({int days = 7}) async {
    final memories = <String>[];
    final dir = Directory(_memoryDir);
    if (!dir.existsSync()) return memories;

    final now = DateTime.now();
    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final datePath =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final file = File('$_memoryDir/$datePath.md');
      if (file.existsSync()) {
        memories.add(file.readAsStringSync());
      }
    }
    return memories;
  }

  /// Build context string from memories for prompt injection.
  Future<String> buildContext({int recentDays = 3}) async {
    final parts = <String>[];

    // Long-term memory
    final longTerm = await readLongTerm();
    if (longTerm != null && longTerm.isNotEmpty) {
      parts.add('## Long-term Memory\n$longTerm');
    }

    // Recent memories
    final recent = await getRecentMemories(days: recentDays);
    if (recent.isNotEmpty) {
      parts.add('## Recent Notes\n${recent.join('\n---\n')}');
    }

    return parts.join('\n\n');
  }
}
