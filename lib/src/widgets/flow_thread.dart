import 'package:flutter/material.dart';

import '../models/flow_message_data.dart';
import '../theme/flow_theme.dart';
import 'flow_message.dart';

/// The scrollable conversation: a bottom-anchored list of [FlowMessageData]s.
///
/// Uses a reversed [ListView] so the thread naturally sticks to the newest
/// message while a reply streams in, and holds position when the user
/// scrolls up to read history. Needs a bounded height (an [Expanded] in a
/// column, or a sized parent).
class FlowThread extends StatelessWidget {
  const FlowThread({
    super.key,
    required this.messages,
    this.customPartBuilder,
    this.controller,
    this.padding,
    this.itemSpacing,
    this.messageBuilder,
    this.charactersPerSecond = 300,
  });

  /// Oldest → newest; the thread anchors to the newest.
  final List<FlowMessageData> messages;

  /// Forwarded to each [FlowMessage].
  final FlowCustomPartBuilder? customPartBuilder;

  /// Optional external scroll controller.
  final ScrollController? controller;

  /// Defaults to `EdgeInsets.all(spacing.lg)`.
  final EdgeInsetsGeometry? padding;

  /// Gap between messages; defaults to `spacing.lg`.
  final double? itemSpacing;

  /// Per-message override; defaults to a [FlowMessage].
  final Widget Function(BuildContext context, FlowMessageData message)?
  messageBuilder;

  /// Forwarded to [FlowMessage] for streaming text parts.
  final double charactersPerSecond;

  @override
  Widget build(BuildContext context) {
    final spacing = context.flowSpacing;
    final gap = itemSpacing ?? spacing.lg;

    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: padding ?? EdgeInsets.all(spacing.lg),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Reversed list: index 0 is the newest (bottom) message.
        final message = messages[messages.length - 1 - index];
        final isOldest = index == messages.length - 1;
        return Padding(
          key: ValueKey(message.id),
          padding: EdgeInsets.only(top: isOldest ? 0 : gap),
          child:
              messageBuilder?.call(context, message) ??
              FlowMessage(
                message,
                customPartBuilder: customPartBuilder,
                charactersPerSecond: charactersPerSecond,
              ),
        );
      },
    );
  }
}
