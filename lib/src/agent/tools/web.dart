import 'package:http/http.dart' as http;
import 'package:nanobot_dart/src/agent/tool_registry.dart';

/// Tool for searching the web.
class WebSearchTool extends Tool {
  WebSearchTool({required this.apiKey, this.client});

  final String apiKey;
  final http.Client? client;

  @override
  String get name => 'web_search';

  @override
  String get description =>
      'Search the web for information using a search engine.';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'The search query.',
          },
        },
        'required': ['query'],
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final query = params['query'] as String;
    // Stub implementation for now until we have a real search API key config
    // In a real implementation, this would call Brave Search API or similar.
    return 'Search results for "$query":\n[Stub] No real search API configured yet.';
  }
}

/// Tool for fetching web page content.
class WebFetchTool extends Tool {
  WebFetchTool({this.client});

  final http.Client? client;

  @override
  String get name => 'web_fetch';

  @override
  String get description => 'Fetch the content of a URL.';

  @override
  Map<String, dynamic> get parametersSchema => {
        'type': 'object',
        'properties': {
          'url': {
            'type': 'string',
            'description': 'The URL to fetch.',
          },
        },
        'required': ['url'],
      };

  @override
  Future<String> execute(Map<String, dynamic> params) async {
    final url = params['url'] as String;
    final httpClient = client ?? http.Client();

    try {
      final response = await httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // In a real implementation, we might want to convert HTML to Markdown here.
        // For now, returning body is sufficient start.
        final content = response.body;
        // Basic truncation to prevent massive context context
        if (content.length > 10000) {
          return '${content.substring(0, 10000)}\n...[truncated]';
        }
        return content;
      } else {
        throw Exception('Failed to fetch URL: ${response.statusCode}');
      }
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
