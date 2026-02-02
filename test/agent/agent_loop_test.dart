import 'package:nanobot_dart/src/agent/agent_loop.dart';
import 'package:nanobot_dart/src/agent/context_builder.dart';
import 'package:nanobot_dart/src/agent/tool_registry.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/providers/llm_provider.dart';
import 'package:test/test.dart';

import '../helpers/mock_llm_provider.dart';
import '../helpers/mock_tool.dart';

void main() {
  group('AgentLoop', () {
    late ToolRegistry tools;
    late ContextBuilder context;

    setUp(() {
      tools = ToolRegistry();
      context = ContextBuilder(systemPrompt: 'You are a helpful assistant.');
    });

    test('processes simple message without tool calls', () async {
      final provider = MockLlmProvider([
        const LlmResponse(content: 'Hello! How can I help you?'),
      ]);

      final loop = AgentLoop(
        provider: provider,
        tools: tools,
        context: context,
      );

      const message = InboundMessage(
        content: 'Hi there',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final response = await loop.process(message);

      expect(response.content, 'Hello! How can I help you?');
      expect(response.iteration, 1);
      expect(response.cancelled, false);
      expect(response.maxIterationsReached, false);
      expect(provider.callCount, 1);
    });

    test('executes tool calls and continues iteration', () async {
      final mockTool = MockTool(
        toolName: 'test_tool',
        output: 'Tool result',
      );
      tools.register(mockTool);

      final provider = MockLlmProvider([
        const LlmResponse(
          toolCalls: [
            ToolCall(
              id: 'call_1',
              name: 'test_tool',
              arguments: <String, dynamic>{'input': 'test'},
            ),
          ],
        ),
        const LlmResponse(
          content: 'Based on the tool result, here is my answer.',
        ),
      ]);

      final loop = AgentLoop(
        provider: provider,
        tools: tools,
        context: context,
      );

      const message = InboundMessage(
        content: 'Run the test tool',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final response = await loop.process(message);

      expect(response.content, 'Based on the tool result, here is my answer.');
      expect(response.iteration, 2);
      expect(provider.callCount, 2);
      expect(mockTool.callCount, 1);
    });

    test('enforces max iterations', () async {
      final mockTool = MockTool(toolName: 'test_tool');
      tools.register(mockTool);

      final provider = MockLlmProvider(
        List.generate(
          25,
          (_) => const LlmResponse(
            toolCalls: [
              ToolCall(
                id: 'call_1',
                name: 'test_tool',
                arguments: <String, dynamic>{},
              ),
            ],
          ),
        ),
      );

      final loop = AgentLoop(
        provider: provider,
        tools: tools,
        context: context,
        maxIterations: 5,
      );

      const message = InboundMessage(
        content: 'Test',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final response = await loop.process(message);

      expect(response.content, 'Max iterations (5) reached.');
      expect(response.iteration, 5);
      expect(response.maxIterationsReached, true);
      expect(provider.callCount, 5);
    });

    test('supports cancellation', () async {
      final provider = MockLlmProvider([
        const LlmResponse(content: 'Response'),
      ]);

      final loop = AgentLoop(
        provider: provider,
        tools: tools,
        context: context,
      );

      const message = InboundMessage(
        content: 'Test',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final token = CancellationToken()..cancel();

      final response = await loop.process(message, cancellationToken: token);

      expect(response.content, 'Operation cancelled.');
      expect(response.cancelled, true);
      expect(provider.callCount, 0);
    });

    test('processStream emits events correctly', () async {
      final mockTool = MockTool(toolName: 'test_tool');
      tools.register(mockTool);

      final provider = MockLlmProvider([
        const LlmResponse(
          toolCalls: [
            ToolCall(
              id: 'call_1',
              name: 'test_tool',
              arguments: <String, dynamic>{},
            ),
          ],
        ),
        const LlmResponse(content: 'Done'),
      ]);

      final loop = AgentLoop(
        provider: provider,
        tools: tools,
        context: context,
      );

      const message = InboundMessage(
        content: 'Test',
        channel: 'test',
        chatId: '123',
        senderId: 'user',
      );

      final events = <AgentEvent>[];
      await for (final event in loop.processStream(message)) {
        events.add(event);
      }

      expect(events.length, 7);
      expect(events[0].type, AgentEventType.iterationStart);
      expect(events[1].type, AgentEventType.llmResponse);
      expect(events[2].type, AgentEventType.toolExecution);
      expect(events[3].type, AgentEventType.iterationComplete);
      expect(events[6].type, AgentEventType.loopComplete);
      expect(events[6].content, 'Done');
    });

    test('handles provider errors', () async {
      final provider = MockLlmProvider([]);
      final loop = AgentLoop(
        provider: provider,
        tools: tools,
        context: context,
      );

      final response = await loop.process(
        const InboundMessage(
          content: 'test',
          channel: 'test',
          chatId: '1',
          senderId: 'u',
        ),
      );

      expect(response.content, contains('An error occurred'));
    });

    test('processStream handles provider errors', () async {
      final provider = MockLlmProvider([]);
      final loop = AgentLoop(
        provider: provider,
        tools: tools,
        context: context,
      );

      final events = <AgentEvent>[];
      await for (final event in loop.processStream(
        const InboundMessage(
          content: 'test',
          channel: 'test',
          chatId: '1',
          senderId: 'u',
        ),
      )) {
        events.add(event);
      }

      expect(events.last.content, contains('An error occurred'));
      expect(events.last.type, AgentEventType.loopComplete);
    });
  });
}
