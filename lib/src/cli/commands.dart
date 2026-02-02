import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nanobot_dart/src/agent/nano_agent.dart';
import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/config/config.dart';
import 'package:nanobot_dart/src/config/loader.dart';
import 'package:nanobot_dart/src/providers/anthropic_provider.dart';
import 'package:nanobot_dart/src/providers/llm_provider.dart';
import 'package:nanobot_dart/src/providers/openai_provider.dart';
import 'package:nanobot_dart/src/providers/openrouter_provider.dart';
import 'package:nanobot_dart/src/skills/registry.dart';

/// Main entry point for the nanobot CLI.
///
/// Ports the functionality from nanobot/cli/commands.py
class NanobotCommandRunner extends CommandRunner<void> {
  NanobotCommandRunner() : super('nanobot', 'nanobot - Personal AI Assistant') {
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print version information.',
      )
      ..addFlag('verbose', help: 'Enable verbose logging.');

    addCommand(OnboardCommand());
    addCommand(GatewayCommand());
    addCommand(AgentCommand());
    addCommand(ChannelsCommand());
    addCommand(CronCommand());
    addCommand(StatusCommand());
  }

  @override
  Future<void> run(Iterable<String> args) async {
    try {
      await super.run(args);
    } on UsageException catch (e) {
      stdout
        ..writeln(e.message)
        ..writeln()
        ..writeln(e.usage);
      exit(64);
    } catch (e, stack) {
      stderr.writeln('Error: $e');
      if (args.contains('--verbose')) {
        stderr.writeln(stack);
      }
      exit(1);
    }
  }
}

class OnboardCommand extends Command<void> {
  @override
  final name = 'onboard';
  @override
  final description = 'Initialize nanobot configuration and workspace.';

  @override
  Future<void> run() async {
    stdout.writeln('Initializing nanobot...');

    final path = getConfigPath();
    final file = File(path);

    if (file.existsSync()) {
      stdout.writeln('Configuration already exists at $path');
      return;
    }

    // Create default config
    const config = Config(
      agents: AgentsConfig(
        defaults: AgentDefaults(
          model: 'anthropic/claude-3.5-sonnet',
          // maxToolIterations matches default (20)
        ),
      ),
    );

    await saveConfig(config);
    stdout
      ..writeln('Created configuration at $path')
      ..writeln('Please edit this file to add your API keys.');

    // Create workspace dirs
    final workspace = config.workspacePath;
    for (final dir in ['skills', 'memory', 'sessions']) {
      await Directory('$workspace/.nanobot/$dir').create(recursive: true);
    }
    stdout
      ..writeln('Created workspace directories in $workspace/.nanobot/')
      ..writeln('Deploying built-in skills...')
      ..writeln('Deployed built-in skills.');

    final registry = SkillsRegistry(workspacePath: workspace);
    await registry.deployBuiltins();
  }
}

class GatewayCommand extends Command<void> {
  GatewayCommand() {
    argParser.addOption(
      'port',
      abbr: 'p',
      defaultsTo: '18790',
      help: 'Gateway port',
    );
  }

  @override
  final name = 'gateway';
  @override
  final description = 'Start the nanobot gateway.';

  @override
  Future<void> run() async {
    final port =
        int.tryParse(argResults?['port'] as String? ?? '18790') ?? 18790;
    stdout
      ..writeln('Starting nanobot gateway on port $port...')
      ..writeln('Gateway functionality is a prototype (Sprint 3).');
  }
}

class AgentCommand extends Command<void> {
  AgentCommand() {
    argParser
      ..addOption(
        'message',
        abbr: 'm',
        help: 'Message to send to the agent',
      )
      ..addOption(
        'session',
        abbr: 's',
        defaultsTo: 'cli:default',
        help: 'Session ID',
      );
  }

  @override
  final name = 'agent';
  @override
  final description = 'Interact with the agent directly.';

  @override
  Future<void> run() async {
    final message = argResults?['message'] as String?;
    final sessionId = argResults?['session'] as String? ?? 'cli:default';

    if (message != null) {
      try {
        final config = await loadConfig();

        // Determine provider (simple logic for CLI)
        LlmProvider provider;
        final model = config.agents.defaults.model;

        if (model.startsWith('anthropic')) {
          provider =
              AnthropicProvider(apiKey: config.providers.anthropic.apiKey);
        } else if (model.startsWith('openai')) {
          provider = OpenAIProvider(apiKey: config.providers.openai.apiKey);
        } else {
          provider =
              OpenRouterProvider(apiKey: config.providers.openrouter.apiKey);
        }

        final agent = NanoAgent(
          config: config,
          provider: provider,
        );

        final response = await agent.process(
          InboundMessage(
            content: message,
            channel: 'cli',
            chatId: sessionId,
            senderId: 'user',
          ),
        );

        stdout.writeln(response.content);
      } catch (e) {
        stderr.writeln('Error: $e');
        exit(1);
      }
    } else {
      stdout
        ..writeln('Interactive mode (re-implemented)')
        ..writeln('Type "exit" or "quit" to leave.');

      final config = await loadConfig();
      // Determine provider
      LlmProvider provider;
      final model = config.agents.defaults.model;
      if (model.startsWith('anthropic')) {
        provider = AnthropicProvider(apiKey: config.providers.anthropic.apiKey);
      } else if (model.startsWith('openai')) {
        provider = OpenAIProvider(apiKey: config.providers.openai.apiKey);
      } else {
        provider =
            OpenRouterProvider(apiKey: config.providers.openrouter.apiKey);
      }

      final agent = NanoAgent(config: config, provider: provider);

      while (true) {
        stdout.write('> ');
        final line = stdin.readLineSync();
        if (line == null ||
            ['exit', 'quit'].contains(line.trim().toLowerCase())) {
          break;
        }
        if (line.trim().isEmpty) continue;

        try {
          final response = await agent.process(
            InboundMessage(
              content: line,
              channel: 'cli',
              chatId: sessionId,
              senderId: 'user',
            ),
          );
          stdout.writeln(response.content);
        } catch (e) {
          stdout.writeln('Error: $e');
        }
      }
    }
  }
}

class ChannelsCommand extends Command<void> {
  ChannelsCommand() {
    addSubcommand(ChannelsStatusCommand());
    addSubcommand(ChannelsLoginCommand());
  }

  @override
  final name = 'channels';
  @override
  final description = 'Manage channels.';
}

class ChannelsStatusCommand extends Command<void> {
  @override
  final name = 'status';
  @override
  final description = 'Show channel status.';

  @override
  Future<void> run() async {
    stdout
      ..writeln('Channel Status:')
      ..writeln('  No active channels.');
  }
}

class ChannelsLoginCommand extends Command<void> {
  @override
  final name = 'login';
  @override
  final description = 'Link device via QR code.';

  @override
  Future<void> run() async {
    stdout
      ..writeln('Starting bridge for login...')
      ..writeln('  Bridge functionality not initialized.');
  }
}

class CronCommand extends Command<void> {
  CronCommand() {
    addSubcommand(CronListCommand());
    addSubcommand(CronAddCommand());
    addSubcommand(CronRemoveCommand());
    addSubcommand(CronEnableCommand());
    addSubcommand(CronRunCommand());
  }

  @override
  final name = 'cron';
  @override
  final description = 'Manage scheduled tasks.';
}

class CronListCommand extends Command<void> {
  CronListCommand() {
    argParser.addFlag('all', abbr: 'a', help: 'Include disabled jobs');
  }

  @override
  final name = 'list';
  @override
  final description = 'List scheduled jobs.';

  @override
  Future<void> run() async {
    stdout.writeln('No scheduled jobs.');
  }
}

class CronAddCommand extends Command<void> {
  @override
  final name = 'add';
  @override
  final description = 'Add a scheduled job.';

  // ... add options ...

  @override
  Future<void> run() async {
    stdout.writeln('Not implemented: cron add');
  }
}

class CronRemoveCommand extends Command<void> {
  @override
  final name = 'remove';
  @override
  final description = 'Remove a scheduled job.';

  @override
  Future<void> run() async {
    stdout.writeln('Not implemented: cron remove');
  }
}

class CronEnableCommand extends Command<void> {
  @override
  final name = 'enable';
  @override
  final description = 'Enable or disable a job.';

  @override
  Future<void> run() async {
    stdout.writeln('Not implemented: cron enable');
  }
}

class CronRunCommand extends Command<void> {
  @override
  final name = 'run';
  @override
  final description = 'Manually run a job.';

  @override
  Future<void> run() async {
    stdout.writeln('Not implemented: cron run');
  }
}

class StatusCommand extends Command<void> {
  @override
  final name = 'status';
  @override
  final description = 'Show nanobot status.';

  @override
  Future<void> run() async {
    stdout.writeln('Nanobot Status:');

    try {
      final config = await loadConfig();
      stdout
        ..writeln('  Workspace: ${config.workspacePath}')
        ..writeln('  Model: ${config.agents.defaults.model}')
        ..writeln('  API Key: ${config.apiKey != null ? 'Set' : 'Not Set'}')
        ..writeln('  API Base: ${config.apiBase ?? 'Default'}');
    } catch (e) {
      stdout
        ..writeln('  Error loading config: $e')
        ..writeln('  Run "nanobot onboard" to initialize.');
    }
  }
}
