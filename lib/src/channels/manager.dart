import 'dart:async';

import 'package:logging/logging.dart';
import 'package:nanobot_dart/src/bus/message_bus.dart';
import 'package:nanobot_dart/src/channels/base.dart';
import 'package:nanobot_dart/src/channels/telegram.dart';
import 'package:nanobot_dart/src/channels/whatsapp.dart';
// Note: You need to make sure Config has these fields.
// For now, I'm assuming dynamic config passing or we need adding channel config to the main config object.
// I will use a Map<String, dynamic> for config for flexibility here or specific config classes.

class ChannelManager {
  ChannelManager(this.bus);

  final MessageBus bus;
  final Map<String, BaseChannel> channels = {};
  final Logger _logger = Logger('ChannelManager');

  /// Initialize channels from configuration map.
  void initChannels(Map<String, dynamic> config) {
    // Telegram
    if (config.containsKey('telegram')) {
      final tgConfig =
          TelegramConfig.fromJson(config['telegram'] as Map<String, dynamic>);
      if (tgConfig.enabled) {
        channels['telegram'] = TelegramChannel(tgConfig, bus);
      }
    }

    // WhatsApp
    if (config.containsKey('whatsapp')) {
      final waConfig =
          WhatsAppConfig.fromJson(config['whatsapp'] as Map<String, dynamic>);
      if (waConfig.enabled) {
        channels['whatsapp'] = WhatsAppChannel(waConfig, bus);
      }
    }
  }

  Future<void> start() async {
    _logger.info('Starting channels...');

    await Future.wait(channels.values.map((c) => c.start()));

    unawaited(_dispatchOutbound());
  }

  Future<void> stop() async {
    _logger.info('Stopping channels...');

    for (final channel in channels.values) {
      await channel.stop();
    }
  }

  Future<void> _dispatchOutbound() async {
    _logger.info('Outbound dispatcher started');

    await for (final msg in bus.outbound) {
      try {
        final channel = channels[msg.channel];
        if (channel != null) {
          try {
            await channel.send(msg);
          } catch (e) {
            _logger.severe('Error sending to ${msg.channel}: $e');
          }
        } else {
          // Ignore if channel not found or not managed here (e.g. 'cli')
          if (msg.channel != 'cli') {
            _logger.warning('Unknown channel: ${msg.channel}');
          }
        }
      } catch (e) {
        _logger.severe('Dispatcher error: $e');
      }
    }
  }
}
