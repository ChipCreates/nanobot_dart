import 'package:nanobot_dart/src/agent/context_builder.dart';
import 'package:nanobot_dart/src/agent/tool_registry.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/providers/llm_provider.dart';
import 'package:test/test.dart';

void main() {
  group('ContextBuilder', () {
    late ContextBuilder builder;

    setUp(() {
      builder = ContextBuilder(
        systemPrompt: 'You are a helpful assistant.',
      );
    });

    test('builds initial messages with system prompt and user message', () {
      const message = InboundMessage(
        content: 'Hello!',
        channel: 'test',
        chatId: '123', senderId: 'user',
      );

      final messages = builder.buildMessages(message);

      expect(messages.length, 2);
      expect(messages[0].role, MessageRole.system);
      expect(messages[0].content, 'You are a helpful assistant.');
      expect(messages[1].role, MessageRole.user);
      expect(messages[1].content, 'Hello!');
    });

    test('adds assistant message without tool calls', () {
      final initialMessages = [
        Message.system('System prompt'),
        Message.user('User message'),
      ];

      const response = LlmResponse(content: 'Assistant response');

      final messages = builder.addAssistantMessage(initialMessages, response);

      expect(messages.length, 3);
      expect(messages[2].role, MessageRole.assistant);
      expect(messages[2].content, 'Assistant response');
      expect(messages[2].toolCalls, null);
    });

    test('adds assistant message with tool calls', () {
      final initialMessages = [
        Message.system('System prompt'),
        Message.user('User message'),
      ];

      const response = LlmResponse(
        content: 'Let me search for that',
        toolCalls: [
          ToolCall(
            id: 'call_1',
            name: 'search',
            arguments: <String, dynamic>{'query': 'test'},
          ),
        ],
      );

      final messages = builder.addAssistantMessage(initialMessages, response);

      expect(messages.length, 3);
      expect(messages[2].role, MessageRole.assistant);
      expect(messages[2].content, 'Let me search for that');
      expect(messages[2].toolCalls?.length, 1);
      expect(messages[2].toolCalls![0].name, 'search');
    });

    test('adds tool result message', () {
      final initialMessages = [
        Message.system('System prompt'),
        Message.user('User message'),
        Message.assistant(
          content: 'Calling tool',
          toolCalls: [
            const ToolCall(
              id: 'call_1',
              name: 'test_tool',
              arguments: <String, dynamic>{},
            ),
          ],
        ),
      ];

      final result = ToolResult.success('Tool output');

      final messages = builder.addToolResult(initialMessages, 'call_1', result);

      expect(messages.length, 4);
      expect(messages[3].role, MessageRole.tool);
      expect(messages[3].content, 'Tool output');
      expect(messages[3].toolCallId, 'call_1');
    });

    test('builds system prompt with memory context', () {
      const memoryContext = 'User prefers concise answers.';

      final prompt = builder.buildSystemPromptWithMemory(memoryContext);

      expect(prompt, contains('You are a helpful assistant.'));
      expect(prompt, contains('<memory>'));
      expect(prompt, contains('User prefers concise answers.'));
      expect(prompt, contains('</memory>'));
    });

    test('returns original system prompt when memory context is empty', () {
      final prompt = builder.buildSystemPromptWithMemory('');

      expect(prompt, 'You are a helpful assistant.');
      expect(prompt, isNot(contains('<memory>')));
    });

    test('preserves message order when adding messages', () {
      final messages = [
        Message.system('System'),
        Message.user('User 1'),
        Message.assistant(content: 'Assistant 1'),
        Message.user('User 2'),
      ];

      const response = LlmResponse(content: 'Assistant 2');
      final newMessages = builder.addAssistantMessage(messages, response);

      expect(newMessages.length, 5);
      expect(newMessages[0].role, MessageRole.system);
      expect(newMessages[1].role, MessageRole.user);
      expect(newMessages[2].role, MessageRole.assistant);
      expect(newMessages[3].role, MessageRole.user);
      expect(newMessages[4].role, MessageRole.assistant);
    });

    test('handles multiple tool results in sequence', () {
      var messages = [
        Message.system('System'),
        Message.user('User'),
        Message.assistant(
          toolCalls: [
            const ToolCall(
              id: 'call_1',
              name: 'tool1',
              arguments: <String, dynamic>{},
            ),
            const ToolCall(
              id: 'call_2',
              name: 'tool2',
              arguments: <String, dynamic>{},
            ),
          ],
        ),
      ];

      messages = builder.addToolResult(
        messages,
        'call_1',
        ToolResult.success('Result 1'),
      );
      messages = builder.addToolResult(
        messages,
        'call_2',
        ToolResult.success('Result 2'),
      );

      expect(messages.length, 5);
      expect(messages[3].role, MessageRole.tool);
      expect(messages[3].toolCallId, 'call_1');
      expect(messages[4].role, MessageRole.tool);
      expect(messages[4].toolCallId, 'call_2');
    });
  });

  group('Message', () {
    test('creates system message', () {
      final message = Message.system('System prompt');

      expect(message.role, MessageRole.system);
      expect(message.content, 'System prompt');
      expect(message.toolCalls, null);
      expect(message.toolCallId, null);
    });

    test('creates user message', () {
      final message = Message.user('User input');

      expect(message.role, MessageRole.user);
      expect(message.content, 'User input');
    });

    test('creates assistant message without tool calls', () {
      final message = Message.assistant(content: 'Response');

      expect(message.role, MessageRole.assistant);
      expect(message.content, 'Response');
      expect(message.toolCalls, null);
    });

    test('creates assistant message with tool calls', () {
      final message = Message.assistant(
        content: 'Calling tools',
        toolCalls: [
          const ToolCall(
            id: 'call_1',
            name: 'test',
            arguments: <String, dynamic>{},
          ),
        ],
      );

      expect(message.role, MessageRole.assistant);
      expect(message.content, 'Calling tools');
      expect(message.toolCalls?.length, 1);
    });

    test('creates tool message', () {
      final message = Message.tool(
        toolCallId: 'call_1',
        content: 'Tool result',
      );

      expect(message.role, MessageRole.tool);
      expect(message.content, 'Tool result');
      expect(message.toolCallId, 'call_1');
    });

    test('converts to JSON correctly', () {
      final message = Message.user('Test message');
      final json = message.toJson();

      expect(json['role'], 'user');
      expect(json['content'], 'Test message');
    });

    test('converts assistant message with tool calls to JSON', () {
      final message = Message.assistant(
        content: 'Calling tool',
        toolCalls: [
          const ToolCall(
            id: 'call_1',
            name: 'test_tool',
            arguments: <String, dynamic>{'param': 'value'},
          ),
        ],
      );

      final json = message.toJson();

      expect(json['role'], 'assistant');
      expect(json['content'], 'Calling tool');
      expect(json['tool_calls'], isA<List<dynamic>>());
      expect((json['tool_calls'] as List<dynamic>).length, 1);
    });

    test('converts tool message to JSON', () {
      final message = Message.tool(
        toolCallId: 'call_1',
        content: 'Result',
      );

      final json = message.toJson();

      expect(json['role'], 'tool');
      expect(json['content'], 'Result');
      expect(json['tool_call_id'], 'call_1');
    });
  });
}
