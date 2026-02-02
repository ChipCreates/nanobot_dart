import 'dart:convert';
import 'dart:io';

/// A conversation session.
class Session {
  Session({
    required this.key,
    List<SessionMessage>? messages,
    Map<String, dynamic>? metadata,
  })  : messages = messages ?? [],
        metadata = metadata ?? {};

  /// Create from JSON.
  factory Session.fromJson(Map<String, dynamic> json) => Session(
        key: json['key'] as String,
        metadata:
            (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        messages: (json['messages'] as List<dynamic>?)
                ?.map((m) => SessionMessage.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
      );

  /// Session key (channel:chatId).
  final String key;

  /// Messages in this session.
  final List<SessionMessage> messages;

  /// Session metadata.
  final Map<String, dynamic> metadata;

  /// Add a message to the session.
  void addMessage(SessionMessage message) {
    messages.add(message);
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() => {
        'key': key,
        'metadata': metadata,
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}

/// A message in a session.
class SessionMessage {
  const SessionMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory SessionMessage.fromJson(Map<String, dynamic> json) => SessionMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  final String role;
  final String content;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Manager for conversation sessions with JSONL persistence.
class SessionManager {
  SessionManager({required this.workspacePath, this.maxHistoryMessages = 50});

  final String workspacePath;
  final int maxHistoryMessages;

  final Map<String, Session> _cache = {};

  String get _sessionsDir => '$workspacePath/.nanobot/sessions';

  String _sessionPath(String key) {
    // Sanitize key for filesystem
    final sanitized = key.replaceAll(RegExp(r'[^\w\-]'), '_');
    return '$_sessionsDir/$sanitized.jsonl';
  }

  /// Get or create a session.
  Future<Session> getOrCreate(String key) async {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final session = await _load(key) ?? Session(key: key);
    _cache[key] = session;
    return session;
  }

  /// Save a session to disk.
  Future<void> save(Session session) async {
    final file = File(_sessionPath(session.key));
    await file.parent.create(recursive: true);

    // Trim to max history
    if (session.messages.length > maxHistoryMessages) {
      session.messages.removeRange(
        0,
        session.messages.length - maxHistoryMessages,
      );
    }

    // Write as JSONL
    final sink = file.openWrite();
    try {
      // Write metadata on first line
      sink.writeln(jsonEncode({'_metadata': session.metadata}));
      // Write each message
      for (final message in session.messages) {
        sink.writeln(jsonEncode(message.toJson()));
      }
    } finally {
      await sink.close();
    }

    _cache[session.key] = session;
  }

  /// Load a session from disk.
  Future<Session?> _load(String key) async {
    final file = File(_sessionPath(key));
    if (!file.existsSync()) return null;

    final lines = file.readAsLinesSync();
    if (lines.isEmpty) return Session(key: key);

    var metadata = <String, dynamic>{};
    final messages = <SessionMessage>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final json = jsonDecode(line) as Map<String, dynamic>;
      if (i == 0 && json.containsKey('_metadata')) {
        metadata = json['_metadata'] as Map<String, dynamic>;
      } else {
        messages.add(SessionMessage.fromJson(json));
      }
    }

    return Session(key: key, messages: messages, metadata: metadata);
  }

  /// Delete a session.
  Future<void> delete(String key) async {
    _cache.remove(key);
    final file = File(_sessionPath(key));
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  /// List all session keys.
  Future<List<String>> listSessions() async {
    final dir = Directory(_sessionsDir);
    if (!dir.existsSync()) return [];

    final sessions = <String>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.jsonl')) {
        final name = entity.uri.pathSegments.last;
        sessions.add(name.replaceAll('.jsonl', ''));
      }
    }
    return sessions;
  }
}
