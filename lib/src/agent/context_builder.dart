import 'package:nanobot_dart/src/agent/tool_registry.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/providers/llm_provider.dart';

/// Builds context for LLM calls including system prompt, history, and memory.
class ContextBuilder {
  ContextBuilder({required this.systemPrompt, this.maxHistoryMessages = 50});

  /// Base system prompt for the agent.
  final String systemPrompt;

  /// Maximum number of history messages to include.
  final int maxHistoryMessages;

  /// Build initial message list from an inbound message.
  List<Message> buildMessages(InboundMessage message) {
    return [Message.system(systemPrompt), Message.user(message.content)];
  }

  /// Add an assistant message with tool calls to the message list.
  List<Message> addAssistantMessage(
    List<Message> messages,
    LlmResponse response,
  ) {
    return [
      ...messages,
      Message.assistant(
        content: response.content,
        toolCalls: response.toolCalls,
      ),
    ];
  }

  /// Add a tool result to the message list.
  List<Message> addToolResult(
    List<Message> messages,
    String toolCallId,
    ToolResult result,
  ) {
    return [
      ...messages,
      Message.tool(toolCallId: toolCallId, content: result.output),
    ];
  }

  /// Inject memory context into the system prompt.
  String buildSystemPromptWithMemory(String memoryContext) {
    if (memoryContext.isEmpty) return systemPrompt;
    return '''
$systemPrompt

<memory>
$memoryContext
</memory>
''';
  }
}

/// A message in the conversation history.
class Message {
  const Message._({
    required this.role,
    this.content,
    this.toolCalls,
    this.toolCallId,
  });

  factory Message.system(String content) =>
      Message._(role: MessageRole.system, content: content);

  factory Message.user(String content) =>
      Message._(role: MessageRole.user, content: content);

  factory Message.assistant({String? content, List<ToolCall>? toolCalls}) =>
      Message._(
        role: MessageRole.assistant,
        content: content,
        toolCalls: toolCalls,
      );

  factory Message.tool({required String toolCallId, required String content}) =>
      Message._(
        role: MessageRole.tool,
        content: content,
        toolCallId: toolCallId,
      );

  final MessageRole role;
  final String? content;
  final List<ToolCall>? toolCalls;
  final String? toolCallId;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'role': role.name};
    if (content != null) json['content'] = content;
    if (toolCalls != null) {
      json['tool_calls'] = toolCalls!.map((tc) => tc.toJson()).toList();
    }
    if (toolCallId != null) json['tool_call_id'] = toolCallId;
    return json;
  }
}

/// Role of a message in the conversation.
enum MessageRole { system, user, assistant, tool }
