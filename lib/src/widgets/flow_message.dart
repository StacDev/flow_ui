import 'package:flutter/material.dart';

import '../models/flow_message_data.dart';
import '../models/flow_message_part.dart';
import '../theme/flow_theme.dart';
import 'flow_attachment_group.dart';
import 'flow_loading_indicator.dart';
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
/// - **user** — right-aligned bubble (`secondaryContainer`).
/// - **assistant** — plain full-width content, no bubble.
/// - **system** — centered muted text (notices, dividers).
///
/// [FlowMessageStatus.pending] assistant messages show a
/// [FlowLoadingIndicator]; [FlowMessageStatus.error] content renders in an
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
    final spacing = context.flowSpacing;

    final bubble = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        color: _isError ? colors.errorContainer : colors.secondaryContainer,
        borderRadius: context.flowRadii.lg,
      ),
      child: _buildParts(
        context,
        _isError ? colors.onErrorContainer : colors.onSecondaryContainer,
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
                padding: EdgeInsets.only(top: spacing.xs),
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
        SizedBox(width: spacing.md),
        leading!,
      ],
    );
  }

  Widget _buildAssistant(BuildContext context) {
    final colors = context.flowColors;
    final spacing = context.flowSpacing;

    Widget content;
    if (message.status == FlowMessageStatus.pending && message.parts.isEmpty) {
      content = const FlowLoadingIndicator();
    } else if (_isError) {
      content = Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.errorContainer,
            borderRadius: context.flowRadii.lg,
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
            padding: EdgeInsets.only(top: spacing.xs),
            child: footer,
          ),
      ],
    );

    if (leading == null) return column;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading!,
        SizedBox(width: spacing.md),
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

  /// The message's parts as a column, text parts in [foreground].
  Widget _buildParts(BuildContext context, Color foreground) {
    final typography = context.flowTypography;
    final spacing = context.flowSpacing;
    final style = typography.bodyLarge
        .copyWith(color: foreground)
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
                padding: EdgeInsets.only(top: spacing.sm),
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
