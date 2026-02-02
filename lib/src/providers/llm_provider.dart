import 'dart:async';

/// Abstract interface for LLM providers.
abstract class LlmProvider {
  /// Send a chat completion request.
  Future<LlmResponse> chat({
    required List<dynamic> messages,
    List<dynamic>? tools,
    String? model,
  });

  /// Get the provider name.
  String get name;

  /// Check if the provider is available.
  Future<bool> isAvailable();
}

/// Response from an LLM provider.
class LlmResponse {
  const LlmResponse({this.content, this.toolCalls});

  /// The text content of the response.
  final String? content;

  /// Tool calls requested by the model.
  final List<ToolCall>? toolCalls;

  /// Whether the response contains tool calls.
  bool get hasToolCalls => toolCalls != null && toolCalls!.isNotEmpty;
}

/// A tool call from the LLM.
class ToolCall {
  const ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    final function = json['function'] as Map<String, dynamic>;
    return ToolCall(
      id: json['id'] as String,
      name: function['name'] as String,
      arguments: function['arguments'],
    );
  }

  /// Unique ID for this tool call.
  final String id;

  /// Name of the tool to call.
  final String name;

  /// Arguments for the tool (JSON string or Map).
  final dynamic arguments;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'function',
        'function': {'name': name, 'arguments': arguments},
      };
}
