import 'dart:io';

/// WhatsApp channel configuration.
class WhatsAppConfig {
  const WhatsAppConfig({
    this.enabled = false,
    this.bridgeUrl = 'ws://localhost:3001',
    this.allowFrom = const [],
  });

  factory WhatsAppConfig.fromJson(Map<String, dynamic> json) => WhatsAppConfig(
        enabled: json['enabled'] as bool? ?? false,
        bridgeUrl: json['bridge_url'] as String? ?? 'ws://localhost:3001',
        allowFrom: (json['allow_from'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  final bool enabled;
  final String bridgeUrl;
  final List<String> allowFrom;

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'bridge_url': bridgeUrl,
        'allow_from': allowFrom,
      };
}

/// Telegram channel configuration.
class TelegramConfig {
  const TelegramConfig({
    this.enabled = false,
    this.token = '',
    this.allowFrom = const [],
  });

  factory TelegramConfig.fromJson(Map<String, dynamic> json) => TelegramConfig(
        enabled: json['enabled'] as bool? ?? false,
        token: json['token'] as String? ?? '',
        allowFrom: (json['allow_from'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  final bool enabled;
  final String token;
  final List<String> allowFrom;

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'token': token,
        'allow_from': allowFrom,
      };
}

/// Configuration for chat channels.
class ChannelsConfig {
  const ChannelsConfig({
    this.whatsapp = const WhatsAppConfig(),
    this.telegram = const TelegramConfig(),
  });

  factory ChannelsConfig.fromJson(Map<String, dynamic> json) => ChannelsConfig(
        whatsapp: json['whatsapp'] == null
            ? const WhatsAppConfig()
            : WhatsAppConfig.fromJson(json['whatsapp'] as Map<String, dynamic>),
        telegram: json['telegram'] == null
            ? const TelegramConfig()
            : TelegramConfig.fromJson(json['telegram'] as Map<String, dynamic>),
      );

  final WhatsAppConfig whatsapp;
  final TelegramConfig telegram;

  Map<String, dynamic> toJson() => {
        'whatsapp': whatsapp.toJson(),
        'telegram': telegram.toJson(),
      };
}

/// Default agent configuration.
class AgentDefaults {
  const AgentDefaults({
    this.workspace = '~/.nanobot/workspace',
    this.model = 'anthropic/claude-opus-4-5',
    this.maxTokens = 8192,
    this.temperature = 0.7,
    this.maxToolIterations = 20,
  });

  factory AgentDefaults.fromJson(Map<String, dynamic> json) => AgentDefaults(
        workspace: json['workspace'] as String? ?? '~/.nanobot/workspace',
        model: json['model'] as String? ?? 'anthropic/claude-opus-4-5',
        maxTokens: json['max_tokens'] as int? ?? 8192,
        temperature: (json['temperature'] as num? ?? 0.7).toDouble(),
        maxToolIterations: json['max_tool_iterations'] as int? ?? 20,
      );

  final String workspace;
  final String model;
  final int maxTokens;
  final double temperature;
  final int maxToolIterations;

  Map<String, dynamic> toJson() => {
        'workspace': workspace,
        'model': model,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'max_tool_iterations': maxToolIterations,
      };
}

/// Agent configuration.
class AgentsConfig {
  const AgentsConfig({
    this.defaults = const AgentDefaults(),
  });

  factory AgentsConfig.fromJson(Map<String, dynamic> json) => AgentsConfig(
        defaults: json['defaults'] == null
            ? const AgentDefaults()
            : AgentDefaults.fromJson(json['defaults'] as Map<String, dynamic>),
      );

  final AgentDefaults defaults;

  Map<String, dynamic> toJson() => {
        'defaults': defaults.toJson(),
      };
}

/// LLM provider configuration.
class ProviderConfig {
  const ProviderConfig({
    this.apiKey = '',
    this.apiBase,
  });

  factory ProviderConfig.fromJson(Map<String, dynamic> json) => ProviderConfig(
        apiKey: json['api_key'] as String? ?? '',
        apiBase: json['api_base'] as String?,
      );

  final String apiKey;
  final String? apiBase;

  Map<String, dynamic> toJson() => {
        'api_key': apiKey,
        if (apiBase != null) 'api_base': apiBase,
      };
}

/// Configuration for LLM providers.
class ProvidersConfig {
  const ProvidersConfig({
    this.anthropic = const ProviderConfig(),
    this.openai = const ProviderConfig(),
    this.openrouter = const ProviderConfig(),
    this.vllm = const ProviderConfig(),
  });

  factory ProvidersConfig.fromJson(Map<String, dynamic> json) =>
      ProvidersConfig(
        anthropic: json['anthropic'] == null
            ? const ProviderConfig()
            : ProviderConfig.fromJson(
                json['anthropic'] as Map<String, dynamic>,
              ),
        openai: json['openai'] == null
            ? const ProviderConfig()
            : ProviderConfig.fromJson(json['openai'] as Map<String, dynamic>),
        openrouter: json['openrouter'] == null
            ? const ProviderConfig()
            : ProviderConfig.fromJson(
                json['openrouter'] as Map<String, dynamic>,
              ),
        vllm: json['vllm'] == null
            ? const ProviderConfig()
            : ProviderConfig.fromJson(json['vllm'] as Map<String, dynamic>),
      );

  final ProviderConfig anthropic;
  final ProviderConfig openai;
  final ProviderConfig openrouter;
  final ProviderConfig vllm;

  Map<String, dynamic> toJson() => {
        'anthropic': anthropic.toJson(),
        'openai': openai.toJson(),
        'openrouter': openrouter.toJson(),
        'vllm': vllm.toJson(),
      };
}

/// Gateway/server configuration.
class GatewayConfig {
  const GatewayConfig({
    this.host = '0.0.0.0',
    this.port = 18790,
  });

  factory GatewayConfig.fromJson(Map<String, dynamic> json) => GatewayConfig(
        host: json['host'] as String? ?? '0.0.0.0',
        port: json['port'] as int? ?? 18790,
      );

  final String host;
  final int port;

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
      };
}

/// Web search tool configuration.
class WebSearchConfig {
  const WebSearchConfig({
    this.apiKey = '',
    this.maxResults = 5,
  });

  factory WebSearchConfig.fromJson(Map<String, dynamic> json) =>
      WebSearchConfig(
        apiKey: json['api_key'] as String? ?? '',
        maxResults: json['max_results'] as int? ?? 5,
      );

  final String apiKey;
  final int maxResults;

  Map<String, dynamic> toJson() => {
        'api_key': apiKey,
        'max_results': maxResults,
      };
}

/// Web tools configuration.
class WebToolsConfig {
  const WebToolsConfig({
    this.search = const WebSearchConfig(),
  });

  factory WebToolsConfig.fromJson(Map<String, dynamic> json) => WebToolsConfig(
        search: json['search'] == null
            ? const WebSearchConfig()
            : WebSearchConfig.fromJson(json['search'] as Map<String, dynamic>),
      );

  final WebSearchConfig search;

  Map<String, dynamic> toJson() => {
        'search': search.toJson(),
      };
}

/// Tools configuration.
class ToolsConfig {
  const ToolsConfig({
    this.web = const WebToolsConfig(),
  });

  factory ToolsConfig.fromJson(Map<String, dynamic> json) => ToolsConfig(
        web: json['web'] == null
            ? const WebToolsConfig()
            : WebToolsConfig.fromJson(json['web'] as Map<String, dynamic>),
      );

  final WebToolsConfig web;

  Map<String, dynamic> toJson() => {
        'web': web.toJson(),
      };
}

/// Root configuration for nanobot.
class Config {
  const Config({
    this.agents = const AgentsConfig(),
    this.channels = const ChannelsConfig(),
    this.providers = const ProvidersConfig(),
    this.gateway = const GatewayConfig(),
    this.tools = const ToolsConfig(),
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        agents: json['agents'] == null
            ? const AgentsConfig()
            : AgentsConfig.fromJson(json['agents'] as Map<String, dynamic>),
        channels: json['channels'] == null
            ? const ChannelsConfig()
            : ChannelsConfig.fromJson(json['channels'] as Map<String, dynamic>),
        providers: json['providers'] == null
            ? const ProvidersConfig()
            : ProvidersConfig.fromJson(
                json['providers'] as Map<String, dynamic>,
              ),
        gateway: json['gateway'] == null
            ? const GatewayConfig()
            : GatewayConfig.fromJson(json['gateway'] as Map<String, dynamic>),
        tools: json['tools'] == null
            ? const ToolsConfig()
            : ToolsConfig.fromJson(json['tools'] as Map<String, dynamic>),
      );

  final AgentsConfig agents;
  final ChannelsConfig channels;
  final ProvidersConfig providers;
  final GatewayConfig gateway;
  final ToolsConfig tools;

  Map<String, dynamic> toJson() => {
        'agents': agents.toJson(),
        'channels': channels.toJson(),
        'providers': providers.toJson(),
        'gateway': gateway.toJson(),
        'tools': tools.toJson(),
      };

  /// Get expanded workspace path.
  String get workspacePath {
    var path = agents.defaults.workspace;
    if (path.startsWith('~')) {
      final home = Platform.environment['HOME'] ?? '';
      path = path.replaceFirst('~', home);
    }
    return path;
  }

  /// Get API key in priority order: OpenRouter > Anthropic > OpenAI > vLLM.
  String? get apiKey {
    if (providers.openrouter.apiKey.isNotEmpty) {
      return providers.openrouter.apiKey;
    }
    if (providers.anthropic.apiKey.isNotEmpty) {
      return providers.anthropic.apiKey;
    }
    if (providers.openai.apiKey.isNotEmpty) {
      return providers.openai.apiKey;
    }
    if (providers.vllm.apiKey.isNotEmpty) {
      return providers.vllm.apiKey;
    }
    return null;
  }

  /// Get API base URL if using OpenRouter or vLLM.
  String? get apiBase {
    if (providers.openrouter.apiKey.isNotEmpty) {
      return providers.openrouter.apiBase ?? 'https://openrouter.ai/api/v1';
    }
    if (providers.vllm.apiBase != null) {
      return providers.vllm.apiBase;
    }
    return null;
  }
}
