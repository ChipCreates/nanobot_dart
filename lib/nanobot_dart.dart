/// Ultra-lightweight AI agent framework for Dart.
///
/// NanoBot Dart provides a complete agent infrastructure including:
/// - [AgentLoop] - Core LLM ↔ tool execution cycle
/// - [MemoryStore] - Daily + long-term memory management
/// - [SessionManager] - Conversation persistence
/// - [SkillsRegistry] - SKILL.md-compatible skill loading
/// - [MessageBus] - Inbound/outbound message routing
///
/// ## Quick Start
///
/// ```dart
/// import 'package:nanobot_dart/nanobot_dart.dart';
///
/// final agent = NanoAgent(
///   provider: OpenRouterProvider(apiKey: 'your-key'),
///   config: Config(
///     agents: AgentsConfig(
///       defaults: AgentDefaults(maxToolIterations: 20),
///     ),
///     providers: ProvidersConfig(
///       openrouter: ProviderConfig(apiKey: 'your-key'),
///     ),
///   ),
/// );
///
/// final response = await agent.process(
///   InboundMessage(content: 'Hello!', channel: 'app', chatId: 'main'),
/// );
/// ```
library nanobot_dart;

import 'package:nanobot_dart/src/agent/agent_loop.dart' show AgentLoop;
import 'package:nanobot_dart/src/agent/memory/memory_store.dart'
    show MemoryStore;
import 'package:nanobot_dart/src/bus/message_bus.dart' show MessageBus;
import 'package:nanobot_dart/src/session/session_manager.dart'
    show SessionManager;
import 'package:nanobot_dart/src/skills/registry.dart' show SkillsRegistry;

export 'src/agent/agent_loop.dart';
export 'src/agent/context_builder.dart';
export 'src/agent/memory/memory_store.dart';
export 'src/agent/memory/narrative_builder.dart';
export 'src/agent/nano_agent.dart';
export 'src/agent/subagent.dart';
export 'src/agent/tool_registry.dart';
export 'src/agent/tools/filesystem.dart';
export 'src/agent/tools/message.dart';
export 'src/agent/tools/web.dart';
export 'src/bus/events.dart';
export 'src/bus/message_bus.dart';
export 'src/config/config.dart';
export 'src/config/loader.dart';
export 'src/providers/anthropic_provider.dart';
export 'src/providers/llm_provider.dart';
export 'src/providers/local_provider.dart';
export 'src/providers/openrouter_provider.dart';
export 'src/session/session.dart';
export 'src/session/session_manager.dart';
export 'src/skills/registry.dart';
export 'src/skills/skill.dart';
