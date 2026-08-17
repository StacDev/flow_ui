import 'package:material_ui/material_ui.dart';

import '../models/flow_message_data.dart';
import '../models/flow_message_part.dart';
import '../theme/flow_theme.dart';
import 'flow_attachment_group.dart';
import 'flow_thinking_indicator.dart';
import 'flow_streaming_text.dart';

/// Renders a [FlowCustomPart]; return null to skip it.
///
/// A full renderer registry waits for the Chat Screen surface — this
/// callback is the extension seam until then.
typedef FlowCustomPartBuilder =
    Widget? Function(
      BuildContext context,
      FlowMessageData message,
      FlowCustomPart part,
    );

/// Renders a single [FlowMessageData] with role-appropriate presentation:
///
/// - **user** — right-aligned bubble, a wash of ink over the page.
/// - **assistant** — plain full-width content, no bubble.
/// - **system** — centered muted text (notices, dividers).
///
/// [FlowMessageStatus.pending] assistant messages show a
/// [FlowThinkingIndicator]; [FlowMessageStatus.error] content renders in an
/// `errorContainer` bubble; [FlowMessageStatus.streaming] animates the last
/// text part via [FlowStreamingText].
class FlowMessage extends StatelessWidget {
  const FlowMessage(
    this.message, {
    super.key,
    this.customPartBuilder,
    this.onAttachmentTap,
    this.previewCloseTooltip,
    this.leading,
    this.footer,
    this.maxBubbleWidthFraction = 0.75,
    this.textStyle,
    this.charactersPerSecond = 300,
    this.thinkingLabel,
    this.bubbleRadius,
    this.bubblePadding,
  }) : assert(
         maxBubbleWidthFraction > 0 && maxBubbleWidthFraction <= 1,
         'maxBubbleWidthFraction must be in (0, 1]',
       );

  /// The view model to render.
  final FlowMessageData message;

  /// Hook for [FlowCustomPart] content.
  final FlowCustomPartBuilder? customPartBuilder;

  /// Called with the tapped attachment's id, *instead of* opening the
  /// built-in full-screen preview. Sent attachments are never removable, so
  /// this is the only intent they report — and a host that just wants to
  /// observe the tap should call `showFlowAttachmentPreview` from the
  /// handler, or the images stop opening.
  final ValueChanged<String>? onAttachmentTap;

  /// Host-localized label for the built-in preview's close button.
  final String? previewCloseTooltip;

  /// Slot beside the content, e.g. an avatar.
  final Widget? leading;

  /// Slot below the content, e.g. message actions.
  final Widget? footer;

  /// User-bubble max width as a fraction of the available width.
  final double maxBubbleWidthFraction;

  /// Override for text parts; merged over `bodyLarge` + the role foreground.
  final TextStyle? textStyle;

  /// Forwarded to [FlowStreamingText] while streaming.
  final double charactersPerSecond;

  /// Host-localized label beside the thinking glyph on a pending message,
  /// e.g. 'Thinking…'. Null shows the glyph alone — the package ships no
  /// strings.
  final String? thinkingLabel;

  /// Corner radius of the user bubble and the error bubbles. Defaults to
  /// the design's 12.
  final BorderRadius? bubbleRadius;

  /// Inside the user bubble. Defaults to the design's 16/10; the error
  /// bubbles keep their own spec padding.
  final EdgeInsetsGeometry? bubblePadding;

  /// The user bubble's ground, as an alpha over the ink — the same wash the
  /// design gives every tint that sits directly on the page, so it reads
  /// correctly in both themes.
  static const double _bubbleOpacity = 0.04;

  /// The design draws the bubble at 16/10 — ten sits between the spacing
  /// steps, like the attachment pill's one-pixel inset.
  static const double _bubbleVerticalPadding = 10;

  /// Bubble text sits on the tight line height; flowing assistant prose
  /// keeps the reading one.
  static const double _bubbleTextHeight = 1.3;

  /// The design's bubble: 12px corners on 16px side padding.
  static const BorderRadius _bubbleRadius = BorderRadius.all(
    Radius.circular(12),
  );
  static const double _bubbleHorizontalPadding = 16;

  /// The error bubble sits a step deeper than the user bubble's 10 — the
  /// design's asymmetry, not a leftover.
  static const double _errorBubbleVerticalPadding = 12;

  /// Gaps: between a message's parts, under a user bubble, under assistant
  /// content before its actions, and beside a leading slot.
  static const double _partGap = 8;
  static const double _userFooterGap = 4;
  static const double _assistantFooterGap = 12;
  static const double _leadingGap = 12;

  bool get _isError => message.status == FlowMessageStatus.error;

  @override
  Widget build(BuildContext context) {
    return switch (message.role) {
      FlowMessageRole.user => _buildUser(context),
      FlowMessageRole.assistant => _buildAssistant(context),
      FlowMessageRole.system => _buildSystem(context),
    };
  }

  Widget _buildUser(BuildContext context) {
    final colors = context.flowColors;

    final bubble = Container(
      padding:
          bubblePadding ??
          const EdgeInsets.symmetric(
            horizontal: _bubbleHorizontalPadding,
            vertical: _bubbleVerticalPadding,
          ),
      decoration: BoxDecoration(
        color: _isError
            ? colors.errorContainer
            : colors.onSurface.withValues(alpha: _bubbleOpacity),
        borderRadius: bubbleRadius ?? _bubbleRadius,
      ),
      child: _buildParts(
        context,
        _isError ? colors.onErrorContainer : colors.onSurface,
        height: _bubbleTextHeight,
      ),
    );

    final column = LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth * maxBubbleWidthFraction
            : double.infinity;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: bubble,
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.only(top: _userFooterGap),
                child: footer,
              ),
          ],
        );
      },
    );

    if (leading == null) return column;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: column),
        const SizedBox(width: _leadingGap),
        leading!,
      ],
    );
  }

  Widget _buildAssistant(BuildContext context) {
    final colors = context.flowColors;

    Widget content;
    if (message.status == FlowMessageStatus.pending && message.parts.isEmpty) {
      content = FlowThinkingIndicator(label: thinkingLabel);
    } else if (_isError) {
      content = Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _bubbleHorizontalPadding,
            vertical: _errorBubbleVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: colors.errorContainer,
            borderRadius: bubbleRadius ?? _bubbleRadius,
          ),
          child: _buildParts(context, colors.onErrorContainer),
        ),
      );
    } else {
      content = _buildParts(context, colors.onSurface);
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (footer != null)
          Padding(
            padding: const EdgeInsets.only(top: _assistantFooterGap),
            child: footer,
          ),
      ],
    );

    if (leading == null) return column;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading!,
        const SizedBox(width: _leadingGap),
        Expanded(child: column),
      ],
    );
  }

  Widget _buildSystem(BuildContext context) {
    final colors = context.flowColors;
    final style = context.flowTypography.bodySmall
        .copyWith(color: colors.onSurfaceVariant)
        .merge(textStyle);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final part in message.parts)
            switch (part) {
              FlowTextPart(:final text) => Text(
                text,
                style: style,
                textAlign: TextAlign.center,
              ),
              // System messages are centered notices; attachments belong to
              // user and assistant turns.
              FlowAttachmentPart() => const SizedBox.shrink(),
              FlowCustomPart() =>
                customPartBuilder?.call(context, message, part) ??
                    const SizedBox.shrink(),
            },
        ],
      ),
    );
  }

  /// The message's parts as a column, text parts in [foreground] and, when
  /// [height] is given, on that line height instead of the reading one.
  Widget _buildParts(BuildContext context, Color foreground, {double? height}) {
    final typography = context.flowTypography;
    final style = typography.bodyLarge
        .copyWith(color: foreground, height: height)
        .merge(textStyle);

    final lastTextIndex = message.parts.lastIndexWhere(
      (part) => part is FlowTextPart,
    );

    final children = <Widget>[];
    for (var i = 0; i < message.parts.length; i++) {
      final part = message.parts[i];
      final child = switch (part) {
        FlowTextPart(:final text) => FlowStreamingText(
          text: text,
          isStreaming:
              message.status == FlowMessageStatus.streaming &&
              i == lastTextIndex,
          style: style,
          charactersPerSecond: charactersPerSecond,
        ),
        // Wraps rather than scrolls: a bubble is capped well below the width
        // of a long strip, and content already sent must not be hidden
        // behind a scroll with no scrollbar. Null, not an empty box, so an
        // empty list doesn't leave a gap before the next part.
        FlowAttachmentPart(:final attachments) =>
          attachments.isEmpty
              ? null
              : FlowAttachmentGroup(
                  attachments: attachments,
                  layout: FlowAttachmentLayout.wrap,
                  onTap: onAttachmentTap,
                  previewCloseTooltip: previewCloseTooltip,
                ),
        FlowCustomPart() => customPartBuilder?.call(context, message, part),
      };
      if (child == null) continue;
      children.add(
        children.isEmpty
            ? child
            : Padding(
                padding: const EdgeInsets.only(top: _partGap),
                child: child,
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
