import 'package:nanobot_dart/src/bus/events.dart';
import 'package:nanobot_dart/src/bus/message_bus.dart';

/// Abstract base class for chat channel implementations.
abstract class BaseChannel {
  BaseChannel(this.config, this.bus);

  final dynamic config;
  final MessageBus bus;

  bool _running = false;
  bool get isRunning => _running;

  String get name;

  /// Start the channel and begin listening for messages.
  Future<void> start() async {
    _running = true;
  }

  /// Stop the channel and clean up resources.
  Future<void> stop() async {
    _running = false;
  }

  /// Send a message through this channel.
  Future<void> send(OutboundMessage msg);

  /// Check if a sender is allowed to use this bot.
  bool isAllowed(String senderId) {
    final allowList = (config as dynamic)?.allowFrom as List<String>?;

    if (allowList == null || allowList.isEmpty) {
      return true;
    }

    return allowList.contains(senderId);
  }

  /// Handle an incoming message from the chat platform.
  Future<void> handleMessage({
    required String senderId,
    required String chatId,
    required String content,
    List<String> media = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    if (!isAllowed(senderId)) {
      return;
    }

    final msg = InboundMessage(
      channel: name,
      senderId: senderId,
      chatId: chatId,
      content: content,
      media: media,
      metadata: metadata,
    );

    bus.publishInbound(msg);
  }
}
