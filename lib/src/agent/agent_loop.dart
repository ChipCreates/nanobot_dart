import 'dart:async';

import 'package:nanobot_dart/src/agent/context_builder.dart';
import 'package:nanobot_dart/src/agent/tool_registry.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// Core agent loop implementing the LLM ↔ tool execution cycle.
///
/// The agent loop processes messages iteratively:
/// 1. Build context from message + history + memory
/// 2. Call LLM with tools available
/// 3. If LLM returns tool calls, execute them and feed results back
/// 4. Repeat until LLM returns content without tool calls or max iterations
///
/// Example:
/// ```dart
/// final loop = AgentLoop(
///   provider: myLlmProvider,
///   tools: myToolRegistry,
///   context: myContextBuilder,
/// );
///
/// final response = await loop.process(message);
/// ```
class AgentLoop {
  AgentLoop({
    required this.provider,
    required this.tools,
    required this.context,
    this.maxIterations = 20,
  });

  /// The LLM provider for chat completions.
  final LlmProvider provider;

  /// Registry of available tools.
  final ToolRegistry tools;

  /// Context builder for prompt construction.
  final ContextBuilder context;

  /// Maximum iterations before giving up (default: 20).
  final int maxIterations;

  /// Process a message through the agent loop.
  ///
  /// Returns when either:
  /// - LLM returns content without tool calls
  /// - Max iterations reached
  /// - [cancellationToken] is triggered
  Future<AgentResponse> process(
    InboundMessage message, {
    CancellationToken? cancellationToken,
  }) async {
    var iteration = 0;
    var messages = context.buildMessages(message);

    while (iteration < maxIterations) {
      // Check for cancellation
      if (cancellationToken?.isCancelled ?? false) {
        return AgentResponse(
          content: 'Operation cancelled.',
          iteration: iteration,
          cancelled: true,
        );
      }

      iteration++;

      // Call LLM
      final response = await provider.chat(
        messages: messages,
        tools: tools.definitions,
      );

      if (response.hasToolCalls) {
        // Add assistant message with tool calls
        messages = context.addAssistantMessage(messages, response);

        // Execute each tool and add results
        for (final toolCall in response.toolCalls!) {
          final result = await tools.execute(toolCall);
          messages = context.addToolResult(messages, toolCall.id, result);
        }
      } else {
        // No tool calls - return final response
        return AgentResponse(
          content: response.content ?? '',
          iteration: iteration,
        );
      }
    }

    // Max iterations reached
    return AgentResponse(
      content: 'Max iterations ($maxIterations) reached.',
      iteration: iteration,
      maxIterationsReached: true,
    );
  }

  /// Process a message with streaming events.
  ///
  /// Yields [AgentEvent]s as the loop progresses, enabling real-time UI updates.
  ///
  /// Example:
  /// ```dart
  /// await for (final event in loop.processStream(message)) {
  ///   if (event.type == AgentEventType.toolExecution) {
  ///     print('Executing ${event.toolName}...');
  ///   }
  /// }
  /// ```
  Stream<AgentEvent> processStream(
    InboundMessage message, {
    CancellationToken? cancellationToken,
  }) async* {
    var iteration = 0;
    var messages = context.buildMessages(message);

    while (iteration < maxIterations) {
      // Check for cancellation
      if (cancellationToken?.isCancelled ?? false) {
        yield AgentEvent(
          type: AgentEventType.loopComplete,
          iteration: iteration,
          content: 'Operation cancelled.',
          timestamp: DateTime.now(),
        );
        return;
      }

      iteration++;
      yield AgentEvent(
        type: AgentEventType.iterationStart,
        iteration: iteration,
        timestamp: DateTime.now(),
      );

      // Call LLM
      final response = await provider.chat(
        messages: messages,
        tools: tools.definitions,
      );

      yield AgentEvent(
        type: AgentEventType.llmResponse,
        iteration: iteration,
        content: response.content,
        timestamp: DateTime.now(),
      );

      if (response.hasToolCalls) {
        // Add assistant message with tool calls
        messages = context.addAssistantMessage(messages, response);

        // Execute each tool and add results
        for (final toolCall in response.toolCalls!) {
          yield AgentEvent(
            type: AgentEventType.toolExecution,
            iteration: iteration,
            toolName: toolCall.name,
            timestamp: DateTime.now(),
          );

          final result = await tools.execute(toolCall);
          messages = context.addToolResult(messages, toolCall.id, result);
        }

        yield AgentEvent(
          type: AgentEventType.iterationComplete,
          iteration: iteration,
          timestamp: DateTime.now(),
        );
      } else {
        // No tool calls - return final response
        yield AgentEvent(
          type: AgentEventType.loopComplete,
          iteration: iteration,
          content: response.content ?? '',
          timestamp: DateTime.now(),
        );
        return;
      }
    }

    // Max iterations reached
    yield AgentEvent(
      type: AgentEventType.loopComplete,
      iteration: iteration,
      content: 'Max iterations ($maxIterations) reached.',
      timestamp: DateTime.now(),
    );
  }
}

/// Response from the agent loop.
class AgentResponse {
  const AgentResponse({
    required this.content,
    required this.iteration,
    this.cancelled = false,
    this.maxIterationsReached = false,
  });

  /// The final response content.
  final String content;

  /// Number of iterations performed.
  final int iteration;

  /// Whether the operation was cancelled.
  final bool cancelled;

  /// Whether max iterations was reached.
  final bool maxIterationsReached;
}

/// Token for cancelling agent loop execution.
class CancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;
}

/// Events emitted during agent loop execution.
enum AgentEventType {
  /// Loop iteration started.
  iterationStart,

  /// LLM returned a response.
  llmResponse,

  /// Tool is being executed.
  toolExecution,

  /// Loop iteration completed.
  iterationComplete,

  /// Agent loop completed (final result).
  loopComplete,
}

/// An event emitted during agent loop execution.
class AgentEvent {
  const AgentEvent({
    required this.type,
    required this.iteration,
    required this.timestamp,
    this.content,
    this.toolName,
  });

  /// Type of event.
  final AgentEventType type;

  /// Current iteration number.
  final int iteration;

  /// Timestamp when event occurred.
  final DateTime timestamp;

  /// Content (for llmResponse and loopComplete events).
  final String? content;

  /// Tool name (for toolExecution events).
  final String? toolName;

  @override
  String toString() {
    final parts = ['AgentEvent($type, iteration: $iteration'];
    if (content != null) {
      parts.add(
        'content: "${content!.substring(0, content!.length > 50 ? 50 : content!.length)}..."',
      );
    }
    if (toolName != null) {
      parts.add('tool: $toolName');
    }
    return '${parts.join(', ')})';
  }
}
