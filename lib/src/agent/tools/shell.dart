import 'dart:async';

import 'dart:io';

import 'package:nanobot_dart/src/agent/tool_registry.dart';

/// Tool to execute shell commands.
///
/// CAUTION: This tool allows arbitrary command execution.
class ExecTool extends Tool {
  ExecTool({
    this.timeout = const Duration(minutes: 1),
    this.workingDir,
  });

  final Duration timeout;
  final String? workingDir;

  @override
  String get name => 'exec';

  @override
  String get description =>
      'Execute a shell command and return its output. Use with caution.';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'command': {
            'type': 'string',
            'description': 'The shell command to execute',
          },
          'working_dir': {
            'type': 'string',
            'description': 'Optional working directory for the command',
          },
        },
        'required': ['command'],
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final command = params['command'] as String;
    final workingDir = params['working_dir'] as String? ?? this.workingDir;

    // Use default shell if possible, or just parse generic command?
    // Python implementation uses asyncio.create_subprocess_shell
    // Dart Process.run with runInShell: true mimics this.

    try {
      final result = await Process.run(
        'sh',
        ['-c', command],
        workingDirectory: workingDir,
        runInShell: true, // Though 'sh -c' implies shell, this safeguards env
      ).timeout(timeout);

      final stdout = result.stdout as String;
      final stderr = result.stderr as String;

      final outputParts = <String>[];
      if (stdout.isNotEmpty) {
        outputParts.add(stdout.trim());
      }
      if (stderr.isNotEmpty) {
        outputParts.add('STDERR:\n${stderr.trim()}');
      }
      if (result.exitCode != 0) {
        outputParts.add('\nExit code: ${result.exitCode}');
      }

      var combined =
          outputParts.isNotEmpty ? outputParts.join('\n') : '(no output)';

      // Truncate if too long (matching Python's 10000 char limit)
      const maxLen = 10000;
      if (combined.length > maxLen) {
        combined =
            '${combined.substring(0, maxLen)}\n... (truncated, ${combined.length - maxLen} more chars)';
      }

      return combined;
    } on TimeoutException {
      return 'Error: Command timed out after ${timeout.inSeconds} seconds';
    } catch (e) {
      return 'Error executing command: $e';
    }
  }
}
