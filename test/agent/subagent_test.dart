import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nanobot_dart/src/agent/agent_loop.dart';
import 'package:nanobot_dart/src/agent/subagent.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<AgentLoop>()])
import 'subagent_test.mocks.dart';

void main() {
  group('SubagentManager', () {
    late MockAgentLoop mockAgentLoop;
    late SubagentManager manager;

    setUp(() {
      mockAgentLoop = MockAgentLoop();
      manager = SubagentManager();
    });

    test('spawn starts a task and returns ID', () async {
      when(
        mockAgentLoop.process(
          any,
          cancellationToken: anyNamed('cancellationToken'),
        ),
      ).thenAnswer((_) async {
        return const AgentResponse(content: 'Task completed', iteration: 1);
      });

      final taskId = await manager.spawn(
        agentLoop: mockAgentLoop,
        taskDescription: 'Do something',
      );

      expect(taskId, isNotEmpty);

      // Allow async task to start
      await Future<void>.delayed(Duration.zero);

      verify(
        mockAgentLoop.process(
          argThat(
            isA<InboundMessage>().having(
              (m) => m.content,
              'content',
              'Do something',
            ),
          ),
          cancellationToken: anyNamed('cancellationToken'),
        ),
      ).called(1);
    });

    test('getStatus returns correct status for running task', () async {
      final completer = Completer<AgentResponse>();

      when(
        mockAgentLoop.process(
          any,
          cancellationToken: anyNamed('cancellationToken'),
        ),
      ).thenAnswer((_) => completer.future);

      final taskId = await manager.spawn(
        agentLoop: mockAgentLoop,
        taskDescription: 'Long task',
      );

      final status = manager.getStatus(taskId);
      expect(status, isNotNull);
      expect(status!.isComplete, isFalse);
      expect(status.result, isNull);

      // Cleanup
      completer.complete(const AgentResponse(content: 'Done', iteration: 1));
      await Future<void>.delayed(Duration.zero);
    });

    test('getStatus returns correct status for completed task', () async {
      when(
        mockAgentLoop.process(
          any,
          cancellationToken: anyNamed('cancellationToken'),
        ),
      ).thenAnswer((_) async {
        return const AgentResponse(content: 'Done', iteration: 1);
      });

      final taskId = await manager.spawn(
        agentLoop: mockAgentLoop,
        taskDescription: 'Quick task',
      );

      // Wait for completion
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final status = manager.getStatus(taskId);
      expect(status, isNotNull);
      expect(status!.isComplete, isTrue);
      expect(status.result, 'Done');
    });

    test('cancel terminates a running task', () async {
      final completer = Completer<AgentResponse>();
      CancellationToken? token;

      when(
        mockAgentLoop.process(
          any,
          cancellationToken: anyNamed('cancellationToken'),
        ),
      ).thenAnswer((invocation) {
        token = invocation.namedArguments[const Symbol('cancellationToken')]
            as CancellationToken?;
        return completer.future;
      });

      final taskId = await manager.spawn(
        agentLoop: mockAgentLoop,
        taskDescription: 'Cancellable task',
      );

      // Allow task to start and capture token
      await Future<void>.delayed(Duration.zero);
      expect(token, isNotNull);
      expect(token!.isCancelled, isFalse);

      manager.cancel(taskId);
      expect(token!.isCancelled, isTrue);

      // Finish mock to clean up
      completer.complete(
        const AgentResponse(
          content: 'Cancelled',
          iteration: 0,
          cancelled: true,
        ),
      );
    });
  });
}
