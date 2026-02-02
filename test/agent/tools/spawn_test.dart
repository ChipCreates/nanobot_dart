import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nanobot_dart/src/agent/agent_loop.dart';
import 'package:nanobot_dart/src/agent/subagent.dart';
import 'package:nanobot_dart/src/agent/tools/spawn.dart';
import 'package:test/test.dart';

import 'spawn_test.mocks.dart';

@GenerateMocks([SubagentManager, AgentLoop])
void main() {
  group('SpawnTool', () {
    late SpawnTool tool;
    late MockSubagentManager mockManager;
    late MockAgentLoop mockLoop;

    setUp(() {
      mockManager = MockSubagentManager();
      mockLoop = MockAgentLoop();
      tool = SpawnTool(manager: mockManager, agentLoop: mockLoop);
    });

    test('calls manager.spawn with correct arguments', () async {
      when(
        mockManager.spawn(
          agentLoop: anyNamed('agentLoop'),
          taskDescription: anyNamed('taskDescription'),
          announceChannel: anyNamed('announceChannel'),
          announceChatId: anyNamed('announceChatId'),
        ),
      ).thenAnswer((_) async => 'task-123');

      final result = await tool.execute({
        'task': 'do something',
      });

      expect(result, equals('task-123'));
      verify(
        mockManager.spawn(
          agentLoop: mockLoop,
          taskDescription: 'do something',
          announceChannel: 'cli',
          announceChatId: 'direct',
        ),
      ).called(1);
    });

    test('uses custom context', () async {
      tool.setContext('telegram', 'chat-456');

      when(
        mockManager.spawn(
          agentLoop: anyNamed('agentLoop'),
          taskDescription: anyNamed('taskDescription'),
          announceChannel: anyNamed('announceChannel'),
          announceChatId: anyNamed('announceChatId'),
        ),
      ).thenAnswer((_) async => 'task-456');

      await tool.execute({
        'task': 'test task',
      });

      verify(
        mockManager.spawn(
          agentLoop: anyNamed('agentLoop'),
          taskDescription: 'test task',
          announceChannel: 'telegram',
          announceChatId: 'chat-456',
        ),
      ).called(1);
    });
  });
}
