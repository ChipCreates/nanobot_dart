import 'dart:async';

import 'package:nanobot_dart/src/bus/events.dart';

/// Message bus for routing inbound and outbound messages.
class MessageBus {
  final _inboundController = StreamController<InboundMessage>.broadcast();
  final _outboundController = StreamController<OutboundMessage>.broadcast();
  final _eventController = StreamController<MessageEvent>.broadcast();

  /// Stream of inbound messages.
  Stream<InboundMessage> get inbound => _inboundController.stream;

  /// Stream of outbound messages.
  Stream<OutboundMessage> get outbound => _outboundController.stream;

  /// Stream of all message events.
  Stream<MessageEvent> get events => _eventController.stream;

  /// Publish an inbound message.
  void publishInbound(InboundMessage message) {
    _inboundController.add(message);
    _eventController.add(MessageEvent.inboundReceived(message));
  }

  /// Publish an outbound message.
  void publishOutbound(OutboundMessage message) {
    _outboundController.add(message);
    _eventController.add(MessageEvent.outboundSent(message));
  }

  /// Log a tool execution event.
  void logToolExecution(String toolName) {
    _eventController.add(MessageEvent.toolExecuted(toolName));
  }

  /// Log an error event.
  void logError(String error) {
    _eventController.add(MessageEvent.errorOccurred(error));
  }

  /// Dispose of the message bus.
  Future<void> dispose() async {
    await _inboundController.close();
    await _outboundController.close();
    await _eventController.close();
  }
}
