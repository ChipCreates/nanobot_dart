# NanoBot Dart

[![Dart](https://github.com/vllm-project/nanobot/actions/workflows/dart.yml/badge.svg)](https://github.com/vllm-project/nanobot/actions/workflows/dart.yml)

A standalone Dart port of [NanoBot](https://github.com/vllm-project/nanobot), an ultra-lightweight AI agent framework.

## Features

- 🧠 **Universal Agent**: Works with any LLM (Anthropic, OpenAI, OpenRouter, Local).
- 🛠️ **Tool System**: Type-safe tool definitions and execution.
- 💾 **Memory**: Markdown-based daily notes and long-term memory.
- 🔄 **Sessions**: Persistent conversation history (JSONL).
- 🔌 **Skills**: Drop-in skill modules (`SKILL.md`).
- 📱 **Cross-Platform**: Designed for Flutter (Mobile/Desktop/Web) and Dart CLI.

## Installation

Add to your `pubspec.yaml`:

```yaml
# From local path (during development)
dependencies:
  nanobot_dart:
    path: ../nanobot_dart

# Or from Git
dependencies:
  nanobot_dart:
    git:
      url: https://github.com/ChipCreates/nanobot_dart
      ref: main
```

## Quick Start

```dart
import 'package:nanobot_dart/nanobot_dart.dart';

void main() async {
  // 1. Configure
  final config = Config(
    agents: AgentsConfig(
      defaults: AgentDefaults(
        model: 'anthropic/claude-3.5-sonnet',
        workspace: '~/.nanobot',
      ),
    ),
    providers: ProvidersConfig(
      anthropic: ProviderConfig(apiKey: 'your-api-key'),
    ),
  );

  // 2. Initialize Agent
  final agent = NanoAgent(
    config: config,
    provider: AnthropicProvider(apiKey: config.apiKey!),
  );

  // 3. Process Message
  final response = await agent.process(InboundMessage(
    content: 'Hello, world!',
    channel: 'cli',
    chatId: 'general',
  ));

  print(response.content);
}
```

## Architecture

`nanobot_dart` follows the Python reference architecture:

```
lib/
├── src/
│   ├── agent/          # AgentLoop, NanoAgent, Tools
│   ├── config/         # Configuration loading
│   ├── bus/            # Message bus & events
│   ├── providers/      # LLM provider implementations
│   ├── session/        # Session management
│   └── skills/         # Skill loading & registry
├── nanobot_dart.dart   # Main exports
```

## License

MIT License.

Based on [NanoBot](https://github.com/vllm-project/nanobot) by the vLLM project.
