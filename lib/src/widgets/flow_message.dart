import 'package:material_ui/material_ui.dart';

import '../models/flow_message_data.dart';
import '../models/flow_message_part.dart';
import '../theme/flow_theme.dart';
import 'flow_attachment_group.dart';
import 'flow_code_block.dart';
import 'flow_error_state.dart';
import 'flow_markdown.dart';
import 'flow_thinking_indicator.dart';
import 'flow_streaming_text.dart';

/// Renders a [FlowCustomPart]; return null to skip it.
///
/// A full renderer registry waits for the Chat View surface — this
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
/// [FlowThinkingIndicator]; [FlowMessageStatus.streaming] animates the last
/// text part via [FlowStreamingText]. A [FlowMessageStatus.error] assistant
/// turn keeps its parts in normal ink and closes with a [FlowErrorState]
/// card — the message's own [FlowErrorPart], or a default one when the host
/// supplies none; an error user bubble recolors to the error container.
class FlowMessage extends StatelessWidget {
  const FlowMessage(
    this.message, {
    super.key,
    this.customPartBuilder,
    this.onAttachmentTap,
    this.previewCloseTooltip,
    this.onCodeCopy,
    this.copiedCodePart,
    this.codeCopyTooltip,
    this.markdown = true,
    this.onLinkTap,
    this.onRetry,
    this.errorTitle,
    this.retryLabel,
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

  /// Copy intent from a [FlowCodePart]'s block, handed the part so the
  /// host knows which code to write to the clipboard. Null hides every
  /// block's copy affordance.
  final ValueChanged<FlowCodePart>? onCodeCopy;

  /// The part whose block shows the copied check — pass back the instance
  /// received from [onCodeCopy] for as long as the confirmation should
  /// last; the host owns the timing.
  final FlowCodePart? copiedCodePart;

  /// Host-localized label for each code block's copy affordance.
  final String? codeCopyTooltip;

  /// Retry intent from the turn's error card — the default card a failed
  /// assistant turn renders, or any [FlowErrorPart]'s (unless the part
  /// says `retryable: false`). Null hides every retry affordance.
  final VoidCallback? onRetry;

  /// Whether assistant text parts render as markdown (`FlowMarkdown`).
  /// User bubbles and system notices always render plain — what the user
  /// typed is a transcription, not prose to typeset. Pass false for
  /// hosts whose assistant text is literal.
  final bool markdown;

  /// Link intent from markdown content, handed the tapped href. Null
  /// renders links as plain prose; the package never launches URLs.
  final ValueChanged<String>? onLinkTap;

  /// Host-localized headline for the error cards, e.g. 'Connection
  /// error'. Null lets each card's message take the glyph row.
  final String? errorTitle;

  /// Host-localized label for the error cards' retry pill; null renders
  /// the pill glyph-only.
  final String? retryLabel;

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

  /// Corner radius of the user bubble, its error state included.
  /// Defaults to the design's 12.
  final BorderRadius? bubbleRadius;

  /// Inside the user bubble. Defaults to the design's 16/10.
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
    } else if (_isError &&
        !message.parts.any((part) => part is FlowErrorPart)) {
      // A failure must not swallow what the user has already read: parts
      // keep their normal ink, and a default card closes the turn when
      // the host supplied no FlowErrorPart of its own.
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.parts.isNotEmpty) ...[
            _buildParts(context, colors.onSurface),
            const SizedBox(height: _partGap),
          ],
          FlowErrorState(
            title: errorTitle,
            retryLabel: retryLabel,
            onRetry: onRetry,
          ),
        ],
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
              // System messages are centered notices; attachments, code
              // and failures belong to user and assistant turns.
              FlowAttachmentPart() ||
              FlowCodePart() ||
              FlowErrorPart() => const SizedBox.shrink(),
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
    final onCodeCopy = this.onCodeCopy;

    // Only text parts get the streaming reveal; a message that ends in a
    // code part streams its code without one (FlowCodeBlock renders each
    // delivery whole).
    final lastTextIndex = message.parts.lastIndexWhere(
      (part) => part is FlowTextPart,
    );

    final children = <Widget>[];
    for (var i = 0; i < message.parts.length; i++) {
      final part = message.parts[i];
      final child = switch (part) {
        // Assistant prose typesets as markdown by default; the user's
        // words render exactly as typed.
        FlowTextPart(:final text)
            when markdown && message.role == FlowMessageRole.assistant =>
          FlowMarkdown(
            text: text,
            isStreaming:
                message.status == FlowMessageStatus.streaming &&
                i == lastTextIndex,
            style: style,
            charactersPerSecond: charactersPerSecond,
            onLinkTap: onLinkTap,
            onCodeCopy: onCodeCopy,
            copiedCodePart: copiedCodePart,
            codeCopyTooltip: codeCopyTooltip,
          ),
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
        FlowCodePart(:final code, :final language, :final filename) =>
          FlowCodeBlock(
            code: code,
            language: language,
            filename: filename,
            onCopy: onCodeCopy == null ? null : () => onCodeCopy(part),
            copyTooltip: codeCopyTooltip,
            copied: identical(part, copiedCodePart),
            // Streaming only while it's the growing tail — a part with
            // content after it is already complete.
            isStreaming:
                message.status == FlowMessageStatus.streaming &&
                i == message.parts.length - 1,
          ),
        // `message` names the FlowMessageData here, so the part's text
        // binds under its own name.
        FlowErrorPart(message: final errorMessage, :final retryable) =>
          FlowErrorState(
            title: errorTitle,
            message: errorMessage,
            retryLabel: retryLabel,
            onRetry: retryable ? onRetry : null,
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
