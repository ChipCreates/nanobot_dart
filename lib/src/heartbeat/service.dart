import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

/// Callback for heartbeat execution.
typedef HeartbeatCallback = Future<String> Function(String prompt);

/// The prompt sent to agent during heartbeat.
const String _kHeartbeatPrompt = '''
Read HEARTBEAT.md in your workspace (if it exists).
Follow any instructions or tasks listed there.
If nothing needs attention, reply with just: HEARTBEAT_OK
''';

/// Token that indicates "nothing to do".
const String _kHeartbeatOkToken = 'HEARTBEAT_OK';

/// Default interval: 30 minutes.
const Duration _kDefaultHeartbeatInterval = Duration(minutes: 30);

/// Periodic heartbeat service that wakes the agent to check for tasks.
///
/// The agent reads HEARTBEAT.md from the workspace and executes any
/// tasks listed there. If nothing needs attention, it replies HEARTBEAT_OK.
class HeartbeatService {
  HeartbeatService({
    required this.workspacePath,
    this.onHeartbeat,
    this.interval = _kDefaultHeartbeatInterval,
    this.enabled = true,
  });

  final String workspacePath;
  final HeartbeatCallback? onHeartbeat;
  final Duration interval;
  final bool enabled;

  Timer? _timer;
  bool _running = false;
  final Logger _logger = Logger('HeartbeatService');

  File get heartbeatFile => File(p.join(workspacePath, 'HEARTBEAT.md'));

  /// Start the heartbeat service.
  void start() {
    if (!enabled) {
      return;
    }
    if (_running) {
      return;
    }

    _running = true;
    _runLoop();
    // Schedule periodic ticks
    _timer = Timer.periodic(interval, (_) => _runLoop());
  }

  /// Stop the heartbeat service.
  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Manually trigger a heartbeat.
  Future<String?> triggerNow() async {
    if (onHeartbeat != null) {
      return onHeartbeat!(_kHeartbeatPrompt);
    }
    return null;
  }

  Future<void> _runLoop() async {
    if (!_running) return;

    try {
      await _tick();
    } catch (e) {
      // Log error but don't crash
      _logger.severe('Heartbeat error: $e');
    }
  }

  Future<void> _tick() async {
    final content = _readHeartbeatFile();
    _logger.info('Heartbeat tick: $content');

    if (_isHeartbeatEmpty(content)) {
      _logger.info('Heartbeat: no tasks');
      return;
    }

    if (onHeartbeat != null) {
      final response = await onHeartbeat!(_kHeartbeatPrompt);

      if (response
          .toUpperCase()
          .replaceAll('_', '')
          .contains(_kHeartbeatOkToken.replaceAll('_', ''))) {
        // Heartbeat OK
      } else {
        // Heartbeat active task completed
      }
    }
  }

  String? _readHeartbeatFile() {
    final file = heartbeatFile;
    if (file.existsSync()) {
      try {
        return file.readAsStringSync();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  bool _isHeartbeatEmpty(String? content) {
    if (content == null || content.trim().isEmpty) {
      return true;
    }

    const skipPatterns = {'- [ ]', '* [ ]', '- [x]', '* [x]'};
    final lines = content.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty ||
          line.startsWith('#') ||
          line.startsWith('<!--') ||
          skipPatterns.contains(line)) {
        continue;
      }
      return false; // Found actionable content
    }

    return true;
  }
}
