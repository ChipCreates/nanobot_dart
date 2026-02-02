import 'dart:async';

import 'package:nanobot_dart/src/agent/agent_loop.dart';
import 'package:nanobot_dart/src/agent/subagent.dart';
import 'package:nanobot_dart/src/agent/tool_registry.dart';

/// Tool to spawn a subagent for background task execution.
class SpawnTool extends Tool {
  SpawnTool({
    required this.manager,
    required this.agentLoop, // Needs reference to loop to spawn "copies" or new instances?
    // Actually SubagentManager.spawn takes AgentLoop.
    // But typically we want a NEW loop or reuse the provider/tools?
    // The Python implementation uses a factory or just passes the manager.
    // In Dart SubagentManager.spawn takes 'AgentLoop agentLoop'.
    // We should probably pass the *current* agent's configuration/provider to create a new loop,
    // or if the architecture expects the SAME loop instance (which might be busy)?
    //
    // Looking at SubagentManager in Dart:
    // Future<String> spawn({required AgentLoop agentLoop, ...})
    // It calls `agentLoop.process` inside `_executeTask`.
    // If `agentLoop.process` is re-entrant or safe to call concurrently?
    // AgentLoop process is async.
    // If we pass the *same* AgentLoop instance, it shares state (context?).
    // Subagent usually implies a fresh context or isolated context.
    //
    // Python `SubagentManager.spawn` creates a NEW AgentLoop instance usually.
    // Let's check `lib/src/agent/subagent.dart` again.
    // It takes `AgentLoop agentLoop`.
  });

  final SubagentManager manager;
  final AgentLoop agentLoop;

  String _originChannel = 'cli';
  String _originChatId = 'direct';

  /// Set the origin context for subagent announcements.
  void setContext(String channel, String chatId) {
    _originChannel = channel;
    _originChatId = chatId;
  }

  @override
  String get name => 'spawn';

  @override
  String get description =>
      'Spawn a subagent to handle a task in the background. '
      'Use this for complex or time-consuming tasks that can run independently. '
      'The subagent will complete the task and report back when done.';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'task': {
            'type': 'string',
            'description': 'The task for the subagent to complete',
          },
          'label': {
            'type': 'string',
            'description': 'Optional short label for the task (for display)',
          },
        },
        'required': ['task'],
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final task = params['task'] as String;
    // label is unused in Dart implementation currently but compatible with schema

    return manager.spawn(
      agentLoop: agentLoop,
      taskDescription: task,
      announceChannel: _originChannel,
      announceChatId: _originChatId,
    );
  }
}
