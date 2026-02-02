import 'dart:async';

import 'package:nanobot_dart/src/agent/agent_loop.dart';
import 'package:nanobot_dart/src/bus/events.dart';

/// Manager for spawning background subagents.
///
/// Subagents run independently from the main agent loop,
/// enabling long-running tasks without blocking.
class SubagentManager {
  final List<_SubagentTask> _running = [];

  /// Spawn a subagent to execute a task in the background.
  Future<String> spawn({
    required AgentLoop agentLoop,
    required String taskDescription,
    String? announceChannel,
    String? announceChatId,
  }) async {
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();

    final task = _SubagentTask(id: taskId, description: taskDescription);
    _running.add(task);

    // Run in background
    unawaited(_executeTask(task, agentLoop));

    return taskId;
  }

  /// Get status of a running subagent task.
  SubagentStatus? getStatus(String taskId) {
    final task = _running.where((t) => t.id == taskId).firstOrNull;
    if (task == null) return null;

    return SubagentStatus(
      id: task.id,
      description: task.description,
      isComplete: task.isComplete,
      result: task.result,
    );
  }

  /// Cancel a running subagent task.
  void cancel(String taskId) {
    final task = _running.where((t) => t.id == taskId).firstOrNull;
    task?.cancellationToken.cancel();
  }

  Future<void> _executeTask(_SubagentTask task, AgentLoop agentLoop) async {
    try {
      final response = await agentLoop.process(
        InboundMessage(
          content: task.description,
          channel: 'subagent',
          chatId: task.id,
          senderId: 'system',
        ),
        cancellationToken: task.cancellationToken,
      );
      task
        ..isComplete = true
        ..result = response.content;
    } catch (e) {
      task
        ..isComplete = true
        ..result = 'Error: $e';
    }
  }
}

class _SubagentTask {
  _SubagentTask({required this.id, required this.description});

  final String id;
  final String description;
  final CancellationToken cancellationToken = CancellationToken();
  bool isComplete = false;
  String? result;
}

/// Status of a subagent task.
class SubagentStatus {
  const SubagentStatus({
    required this.id,
    required this.description,
    required this.isComplete,
    this.result,
  });

  final String id;
  final String description;
  final bool isComplete;
  final String? result;
}
