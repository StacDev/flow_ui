import 'package:material_ui/material_ui.dart';

import '../theme/flow_syntax_colors.dart';
import '../theme/flow_theme.dart';
import '../utils/flow_syntax_highlighter.dart';

export '../utils/flow_syntax_highlighter.dart'
    show FlowCodeLanguage, FlowSyntaxRule, FlowSyntaxToken;

/// A code block: a fenced snippet on its own washed ground, under a header
/// that names the content and offers copy.
///
/// ```dart
/// FlowCodeBlock(
///   code: source,
///   language: 'dart',
///   copyTooltip: 'Copy code',
///   copied: copied,
///   onCopy: () => copy(source),
/// )
/// ```
///
/// Highlighting is built in and synchronous — no setup call, nothing
/// async. [language] picks a rule table via [FlowCodeLanguage.find];
/// unknown ids render plain, never an error, and hosts add languages with
/// [FlowCodeLanguage.register]. Token inks come from the theme's
/// [FlowSyntaxColors].
///
/// Copying reports intent, per the package's contract: [onCopy] fires, the
/// host writes the clipboard, then holds [copied] true while its
/// confirmation lasts — the affordance swaps to a check, tinted primary
/// like a selected message action. The package touches no clipboard and
/// ships no strings; [copyTooltip] is the affordance's accessible name.
///
/// Fills the width it's given, so it needs a bounded width — any column,
/// list or message slot provides one.
class FlowCodeBlock extends StatefulWidget {
  const FlowCodeBlock({
    super.key,
    required this.code,
    this.language,
    this.filename,
    this.onCopy,
    this.copyTooltip,
    this.copied = false,
    this.isStreaming = false,
    this.wrap = false,
    this.padding,
    this.borderRadius,
  });

  /// The source, rendered verbatim.
  final String code;

  /// [FlowCodeLanguage] id or alias, case-insensitive — usually the fence
  /// info string. Null or unknown renders plain.
  final String? language;

  /// Header label; null falls back to [language], and with neither the
  /// header keeps only the copy affordance.
  final String? filename;

  /// Copy intent. Null hides the affordance.
  final VoidCallback? onCopy;

  /// Host-localized; also the affordance's accessible name.
  final String? copyTooltip;

  /// Swaps the affordance to a check while true. The host owns the
  /// confirmation and its timing, as with `FlowMessageAction.thumbUp`.
  final bool copied;

  /// While true the copy affordance hides — there is nothing complete to
  /// copy — and each delivery renders whole, with no per-character reveal:
  /// streamed code arrives re-highlighted as often as appended, which a
  /// reveal would restart on.
  final bool isStreaming;

  /// False scrolls long lines horizontally inside the block, keeping the
  /// author's line breaks; true wraps them instead.
  final bool wrap;

  /// Around the code. Defaults to the design's 16/12.
  final EdgeInsetsGeometry? padding;

  /// The block's corner. Defaults to the design's 12.
  final BorderRadius? borderRadius;

  @override
  State<FlowCodeBlock> createState() => _FlowCodeBlockState();
}

class _FlowCodeBlockState extends State<FlowCodeBlock> {
  /// The design's block: the message bubble's 12px corner, code inset
  /// 16/12, and a 36 header — 6px around the copy affordance's 24 frame,
  /// with the label a full 16 from the edge so it aligns with the code.
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));
  static const EdgeInsetsGeometry _bodyPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const double _headerHeight = 36;
  static const EdgeInsetsGeometry _headerPadding = EdgeInsets.only(
    left: 16,
    right: 6,
  );

  /// The block's ground: the same 4% ink wash as the user bubble and the
  /// attachment tiles, edged with the tiles' outline hairline.
  static const double _groundOpacity = 0.04;

  /// The last highlight and the inputs it was computed from. Tokenizing
  /// re-scans the whole source, so a rebuild that changes none of the
  /// inputs — an ancestor animating, a hover elsewhere — must not pay for
  /// one.
  TextSpan? _span;
  String? _spanCode;
  FlowCodeLanguage? _spanLanguage;
  TextStyle? _spanStyle;
  FlowSyntaxColors? _spanColors;

  TextSpan _highlight(
    FlowCodeLanguage? language,
    TextStyle style,
    FlowSyntaxColors colors,
  ) {
    final cached = _span;
    if (cached != null &&
        _spanCode == widget.code &&
        identical(_spanLanguage, language) &&
        _spanStyle == style &&
        identical(_spanColors, colors)) {
      return cached;
    }
    final span = FlowSyntaxHighlighter.highlight(
      widget.code,
      language: language,
      style: style,
      colors: colors,
    );
    _span = span;
    _spanCode = widget.code;
    _spanLanguage = language;
    _spanStyle = style;
    _spanColors = colors;
    return span;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final syntaxColors = context.flowSyntaxColors;

    final language = FlowCodeLanguage.find(widget.language);
    final span = _highlight(
      language,
      typography.code.copyWith(color: colors.onSurface),
      syntaxColors,
    );

    final label = widget.filename ?? widget.language;
    final showCopy = widget.onCopy != null && !widget.isStreaming;
    final hasHeader = label != null || widget.onCopy != null;

    final padding = widget.padding ?? _bodyPadding;
    final code = SelectableText.rich(span);
    final body = widget.wrap
        ? Padding(padding: padding, child: code)
        // Padding inside the scroll view, so the last column of a long
        // line clears the edge instead of sitting against the clip.
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: padding,
            child: code,
          );

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: _groundOpacity),
        borderRadius: widget.borderRadius ?? _radius,
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader)
            Container(
              height: _headerHeight,
              padding: _headerPadding,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: label == null
                        ? const SizedBox.shrink()
                        : Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.labelMedium.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                  ),
                  if (showCopy)
                    _CopyButton(
                      copied: widget.copied,
                      tooltip: widget.copyTooltip,
                      onTap: widget.onCopy!,
                    ),
                ],
              ),
            ),
          body,
        ],
      ),
    );
  }
}

/// The header's copy affordance: a glyph on a 24 frame, resting at the
/// muted ink and lifting to full on hover, with the copied check tinted
/// primary — the message-action dress on a rounder corner.
class _CopyButton extends StatefulWidget {
  const _CopyButton({
    required this.copied,
    required this.tooltip,
    required this.onTap,
  });

  final bool copied;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  /// Breathing room around the 16 glyph inside its 24 frame.
  static const double _framePadding = 4;
  static const double _iconSize = 16;

  /// The frame's corner — a step under the block's 12, per the ratio the
  /// menu rows keep to their card.
  static const BorderRadius _frameRadius = BorderRadius.all(Radius.circular(6));

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    final Color foreground;
    if (widget.copied) {
      foreground = colors.primary;
    } else if (_hovered) {
      foreground = colors.onSurface;
    } else {
      foreground = colors.onSurfaceMuted;
    }

    // Transparent Material so ink and hover fills render inside the
    // block's decorated container.
    Widget button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (value) => setState(() => _hovered = value),
        borderRadius: _frameRadius,
        hoverColor: colors.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(_framePadding),
          child: Icon(
            widget.copied ? Icons.check : Icons.copy_outlined,
            size: _iconSize,
            color: foreground,
          ),
        ),
      ),
    );

    final tooltip = widget.tooltip;
    if (tooltip != null) {
      button = Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}
