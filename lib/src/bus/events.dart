/// Inbound message from a channel.
class InboundMessage {
  const InboundMessage({
    required this.content,
    required this.channel,
    required this.chatId,
    required this.senderId,
    this.media = const [],
    this.metadata,
  });

  /// The message content.
  final String content;

  /// Channel identifier (e.g., 'telegram', 'app', 'cli').
  final String channel;

  /// Chat/conversation identifier within the channel.
  final String chatId;

  /// Sender identifier.
  final String senderId;

  /// List of media URLs/paths.
  final List<String> media;

  /// Optional metadata.
  final Map<String, dynamic>? metadata;

  /// Generate a session key from channel and chat ID.
  String get sessionKey => '$channel:$chatId';
}

/// Outbound message to a channel.
class OutboundMessage {
  const OutboundMessage({
    required this.content,
    required this.channel,
    required this.chatId,
    this.metadata,
  });

  /// The message content.
  final String content;

  /// Target channel identifier.
  final String channel;

  /// Target chat/conversation identifier.
  final String chatId;

  /// Optional metadata.
  final Map<String, dynamic>? metadata;
}

/// Event types for the message bus.
enum MessageEventType { inbound, outbound, toolExecution, error }

/// A message bus event.
class MessageEvent {
  const MessageEvent({
    required this.type,
    required this.timestamp,
    this.inbound,
    this.outbound,
    this.toolName,
    this.error,
  });

  factory MessageEvent.inboundReceived(InboundMessage message) => MessageEvent(
        type: MessageEventType.inbound,
        timestamp: DateTime.now(),
        inbound: message,
      );

  factory MessageEvent.outboundSent(OutboundMessage message) => MessageEvent(
        type: MessageEventType.outbound,
        timestamp: DateTime.now(),
        outbound: message,
      );

  factory MessageEvent.toolExecuted(String toolName) => MessageEvent(
        type: MessageEventType.toolExecution,
        timestamp: DateTime.now(),
        toolName: toolName,
      );

  factory MessageEvent.errorOccurred(String error) => MessageEvent(
        type: MessageEventType.error,
        timestamp: DateTime.now(),
        error: error,
      );

  final MessageEventType type;
  final DateTime timestamp;
  final InboundMessage? inbound;
  final OutboundMessage? outbound;
  final String? toolName;
  final String? error;
}
