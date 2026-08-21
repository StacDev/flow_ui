import 'package:material_ui/material_ui.dart';

import '../models/flow_message_data.dart';
import '../models/flow_message_part.dart';
import 'flow_message.dart';

/// The scrollable conversation, a list of [FlowMessageData]s.
///
/// A conversation that still fits its viewport reads from the top, the AI
/// apps' convention; once it grows past the viewport it anchors to the
/// bottom instead. Uses a reversed [ListView] underneath so the thread
/// naturally sticks to the newest message while a reply streams in, and
/// holds position when the user scrolls up to read history. Needs a
/// bounded height (an [Expanded] in a column, or a sized parent).
class FlowThread extends StatefulWidget {
  const FlowThread({
    super.key,
    required this.messages,
    this.customPartBuilder,
    this.onAttachmentTap,
    this.previewCloseTooltip,
    this.onCodeCopy,
    this.copiedCodePart,
    this.codeCopyTooltip,
    this.onRetry,
    this.errorTitle,
    this.retryLabel,
    this.controller,
    this.padding,
    this.itemSpacing,
    this.messageBuilder,
    this.charactersPerSecond = 300,
    this.thinkingLabel,
  });

  /// Oldest → newest; once the conversation outgrows the viewport, the
  /// thread anchors to the newest.
  final List<FlowMessageData> messages;

  /// Forwarded to each [FlowMessage].
  final FlowCustomPartBuilder? customPartBuilder;

  /// Called with the message the attachment belongs to and its id —
  /// attachment ids only need to be unique within their own message.
  ///
  /// Supplying this *replaces* the built-in full-screen preview for every
  /// attachment in the thread; call `showFlowAttachmentPreview` from the
  /// handler to keep it.
  final void Function(FlowMessageData message, String attachmentId)?
  onAttachmentTap;

  /// Host-localized label for the built-in preview's close button.
  final String? previewCloseTooltip;

  /// Copy intent from any code block in the thread, handed the tapped
  /// [FlowCodePart]. Forwarded to each [FlowMessage].
  final ValueChanged<FlowCodePart>? onCodeCopy;

  /// The part whose block shows the copied check — the instance received
  /// from [onCodeCopy], passed back while the host's confirmation lasts.
  final FlowCodePart? copiedCodePart;

  /// Host-localized label for the code blocks' copy affordance.
  final String? codeCopyTooltip;

  /// Retry intent from a failed turn's error card, handed the message so
  /// the host can re-run it. Forwarded to each [FlowMessage].
  final void Function(FlowMessageData message)? onRetry;

  /// Host-localized headline for the thread's error cards, e.g.
  /// 'Connection error'.
  final String? errorTitle;

  /// Host-localized label for the error cards' retry pill; null renders
  /// the pill glyph-only.
  final String? retryLabel;

  /// Optional external scroll controller.
  final ScrollController? controller;

  /// Defaults to the design's 16 on every side.
  final EdgeInsetsGeometry? padding;

  /// Gap between messages; defaults to the design's 32.
  final double? itemSpacing;

  /// Per-message override; defaults to a [FlowMessage].
  final Widget Function(BuildContext context, FlowMessageData message)?
  messageBuilder;

  /// Forwarded to [FlowMessage] for streaming text parts.
  final double charactersPerSecond;

  /// Forwarded to each [FlowMessage]: the label beside the thinking glyph
  /// on a pending message.
  final String? thinkingLabel;

  @override
  State<FlowThread> createState() => _FlowThreadState();
}

class _FlowThreadState extends State<FlowThread> {
  /// The design's thread metrics: edge padding and the gap between turns.
  /// The edge 16 is mirrored by `FlowChatView`'s composer-block padding,
  /// which promises its edges line up with the thread's.
  static const EdgeInsetsGeometry _defaultPadding = EdgeInsets.all(16);
  static const double _defaultGap = 32;

  /// Whether the conversation still fits its viewport. A fitting thread
  /// lays out shrink-wrapped so the top alignment can take effect; once
  /// content overflows, the lazy bottom-anchored form takes over. The flip
  /// is read off the scroll metrics, and at the frame it happens content
  /// equals the viewport, so nothing visibly moves. Shrink-wrapping lays
  /// out every message, but a fitting conversation's messages are all
  /// visible anyway — the lazy form carries the long threads.
  bool _fits = true;

  void _handleMetrics(ScrollMetrics metrics) {
    final fits = metrics.maxScrollExtent <= 0;
    if (fits == _fits) return;
    // Metrics arrive during layout; flipping shrinkWrap there would
    // rebuild the tree mid-layout, so the flip waits for the frame's end.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _fits != fits) setState(() => _fits = fits);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gap = widget.itemSpacing ?? _defaultGap;
    final onAttachmentTap = widget.onAttachmentTap;
    final onRetry = widget.onRetry;
    final messages = widget.messages;

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        // Depth 0 is the thread's own list — scrollers nested inside
        // messages (attachment strips, code blocks) report deeper and
        // must not steer the fit.
        if (notification.depth == 0) _handleMetrics(notification.metrics);
        return false;
      },
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ListView.builder(
          controller: widget.controller,
          reverse: true,
          shrinkWrap: _fits,
          padding: widget.padding ?? _defaultPadding,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // Reversed list: index 0 is the newest (bottom) message.
            final message = messages[messages.length - 1 - index];
            final isOldest = index == messages.length - 1;
            return Padding(
              key: ValueKey(message.id),
              padding: EdgeInsets.only(top: isOldest ? 0 : gap),
              child:
                  widget.messageBuilder?.call(context, message) ??
                  FlowMessage(
                    message,
                    customPartBuilder: widget.customPartBuilder,
                    onAttachmentTap: onAttachmentTap == null
                        ? null
                        : (attachmentId) =>
                              onAttachmentTap(message, attachmentId),
                    previewCloseTooltip: widget.previewCloseTooltip,
                    onCodeCopy: widget.onCodeCopy,
                    copiedCodePart: widget.copiedCodePart,
                    codeCopyTooltip: widget.codeCopyTooltip,
                    onRetry: onRetry == null ? null : () => onRetry(message),
                    errorTitle: widget.errorTitle,
                    retryLabel: widget.retryLabel,
                    charactersPerSecond: widget.charactersPerSecond,
                    thinkingLabel: widget.thinkingLabel,
                  ),
            );
          },
        ),
      ),
    );
  }
}
