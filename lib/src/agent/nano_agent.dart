import 'dart:async';

import 'package:nanobot_dart/src/agent/agent_loop.dart';
import 'package:nanobot_dart/src/agent/context_builder.dart';
import 'package:nanobot_dart/src/agent/memory/memory_store.dart';
import 'package:nanobot_dart/src/agent/subagent.dart';
import 'package:nanobot_dart/src/agent/tool_registry.dart';
import 'package:nanobot_dart/src/agent/tools/shell.dart';
import 'package:nanobot_dart/src/agent/tools/spawn.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/config/config.dart';
import 'package:nanobot_dart/src/providers/llm_provider.dart';
import 'package:nanobot_dart/src/session/session.dart';

/// High-level agent facade.
///
/// Orchestrates the [AgentLoop], [MemoryStore], and [SessionManager] to
/// provide a simple API for processing messages.
class NanoAgent {
  NanoAgent({
    required this.config,
    required this.provider,
    this.systemPrompt = 'You are a helpful AI assistant.',
    MemoryStore? memory,
    SessionManager? sessions,
    ToolRegistry? tools,
  })  : memory = memory ?? MemoryStore(workspacePath: config.workspacePath),
        sessions =
            sessions ?? SessionManager(workspacePath: config.workspacePath),
        tools = tools ?? ToolRegistry(),
        subagentManager = SubagentManager() {
    // Register default tools
    this.tools.register(ExecTool());
    this.tools.register(
          SpawnTool(
            manager: subagentManager,
            agentLoop: AgentLoop(
              provider: provider,
              tools: this.tools,
              context: ContextBuilder(systemPrompt: systemPrompt),
            ),
          ),
        );
  }

  /// Configuration.
  final Config config;

  /// LLM Provider.
  final LlmProvider provider;

  /// Base system prompt.
  final String systemPrompt;

  /// Memory store.
  final MemoryStore memory;

  /// Session manager.
  final SessionManager sessions;

  /// Subagent manager.
  final SubagentManager subagentManager;

  /// Tool registry.
  final ToolRegistry tools;

  /// Process a message.
  Future<AgentResponse> process(InboundMessage message) async {
    // 1. Get or create session
    // Use channel:chatId as the key
    final sessionKey = '${message.channel}:${message.chatId}';
    final session = await sessions.getOrCreate(sessionKey);

    // 2. Add user message to session
    session.addMessage(
      SessionMessage(
        role: 'user',
        content: message.content,
        timestamp: DateTime.now(),
      ),
    );
    await sessions.save(session);

    // 3. Prepare context with memory
    final memoryContext = await memory.buildContext();
    final fullSystemPrompt = memoryContext.isEmpty
        ? systemPrompt
        : '$systemPrompt\n\n<memory>\n$memoryContext\n</memory>';

    final contextBuilder = ContextBuilder(systemPrompt: fullSystemPrompt);

    // 4. Initialize transient AgentLoop
    final loop = AgentLoop(
      provider: provider,
      tools: tools,
      context: contextBuilder,
      maxIterations: config.agents.defaults.maxToolIterations,
    );

    // 5. Run agent loop
    final response = await loop.process(message);

    // 6. Add assistant response to session
    session.addMessage(
      SessionMessage(
        role: 'assistant',
        content: response.content,
        timestamp: DateTime.now(),
      ),
    );
    await sessions.save(session);

    return response;
  }
}
