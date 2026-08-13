import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../utils/flow_state_colors.dart';

/// A tappable prompt pill: the host's suggested message, optionally with a
/// leading icon. Usable on its own, or in a [FlowSuggestionGroup]:
///
/// ```dart
/// FlowSuggestion(
///   label: 'Summarize this thread',
///   icon: Icons.summarize_outlined,
///   onTap: () => send('Summarize this thread'),
/// )
/// ```
///
/// [label] is the whole content — the package ships no strings and does not
/// derive prompt text. A null [onTap] renders the pill disabled.
class FlowSuggestion extends StatefulWidget {
  const FlowSuggestion({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.tooltip,
    this.padding,
    this.borderRadius,
  });

  /// The suggestion text, on one line — it ellipsizes rather than wrapping.
  final String label;

  /// Optional leading glyph.
  final IconData? icon;

  /// Null renders the pill disabled.
  final VoidCallback? onTap;

  final bool enabled;

  /// Host-localized tooltip, e.g. the full text of a long suggestion.
  final String? tooltip;

  /// Inside the pill. Defaults to the design's 12/8.
  final EdgeInsetsGeometry? padding;

  /// The pill's corner. Defaults to fully rounded.
  final BorderRadius? borderRadius;

  @override
  State<FlowSuggestion> createState() => _FlowSuggestionState();
}

class _FlowSuggestionState extends State<FlowSuggestion> {
  /// The design's pill: fully rounded, 12/8 padding, an 8px icon gap.
  static const BorderRadius _pillRadius = BorderRadius.all(
    Radius.circular(999),
  );
  static const EdgeInsetsGeometry _pillPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const double _iconGap = 8;

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final enabled = widget.enabled && widget.onTap != null;

    final Color foreground;
    if (!enabled) {
      foreground = flowDisabledColor(colors.onSurfaceVariant);
    } else if (_hovered) {
      foreground = colors.onSurface;
    } else {
      foreground = colors.onSurfaceVariant;
    }

    final shape = RoundedRectangleBorder(
      borderRadius: widget.borderRadius ?? _pillRadius,
      side: BorderSide(color: colors.outlineVariant),
    );

    Widget pill = Material(
      color: colors.surfaceContainerLow,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? widget.onTap : null,
        onHover: enabled ? (value) => setState(() => _hovered = value) : null,
        customBorder: shape,
        hoverColor: colors.surfaceContainerHigh,
        child: Padding(
          padding: widget.padding ?? _pillPadding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final Widget label = Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.flowTypography.labelLarge.copyWith(
                  color: foreground,
                ),
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 16, color: foreground),
                    const SizedBox(width: _iconGap),
                  ],
                  // A row lays non-flex children out unbounded, so the label
                  // only ellipsizes as a flex child — which in turn is only
                  // legal when something bounds the pill. The scrolling
                  // layout doesn't, and there a long label just runs on.
                  if (constraints.maxWidth.isFinite)
                    Flexible(child: label)
                  else
                    label,
                ],
              );
            },
          ),
        ),
      ),
    );

    final tooltip = widget.tooltip;
    if (tooltip != null) {
      pill = Tooltip(message: tooltip, child: pill);
    }
    return pill;
  }
}

/// How a [FlowSuggestionGroup] arranges its pills.
enum FlowSuggestionLayout {
  /// One row that scrolls horizontally, without a scrollbar. Keeps a long
  /// set to a single line — the usual treatment above a composer.
  scroll,

  /// Wraps onto as many lines as needed; nothing scrolls.
  wrap,

  /// One pill per line, each hugging its label.
  column,
}

/// Lays out prompt suggestions as a scrolling row, a wrap, or a column —
/// typically above a `FlowComposer` on an empty thread:
///
/// ```dart
/// FlowSuggestionGroup(
///   suggestions: [
///     FlowSuggestion(label: 'Plan a trip', onTap: () => send('Plan a trip')),
///     FlowSuggestion(label: 'Explain a photo', onTap: ...),
///   ],
/// )
/// ```
///
/// An empty [suggestions] list takes no space, so a host can pass whatever
/// it has without guarding.
class FlowSuggestionGroup extends StatelessWidget {
  const FlowSuggestionGroup({
    super.key,
    required this.suggestions,
    this.layout = FlowSuggestionLayout.scroll,
    this.spacing,
    this.padding,
  });

  /// Rendered in order.
  final List<FlowSuggestion> suggestions;

  final FlowSuggestionLayout layout;

  /// Gap between pills, and between lines when wrapping. Defaults to the
  /// design's 8.
  final double? spacing;

  /// Around the whole group; defaults to none. In the scrolling layout it
  /// scrolls with the pills, so the first and last clear the edge.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final gap = spacing ?? _defaultGap;

    switch (layout) {
      case FlowSuggestionLayout.scroll:
        return ScrollConfiguration(
          // No scrollbar over the pills, and draggable with a mouse so the
          // row works on desktop without a horizontal wheel.
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: PointerDeviceKind.values.toSet(),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _withGaps(gap, Axis.horizontal),
            ),
          ),
        );
      case FlowSuggestionLayout.wrap:
        return _padded(
          Wrap(spacing: gap, runSpacing: gap, children: suggestions),
        );
      case FlowSuggestionLayout.column:
        return _padded(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _withGaps(gap, Axis.vertical),
          ),
        );
    }
  }

  /// The design's gap between pills — the same 8 the attachment strip uses.
  static const double _defaultGap = 8;

  Widget _padded(Widget child) {
    if (padding == null) return child;
    return Padding(padding: padding!, child: child);
  }

  List<Widget> _withGaps(double gap, Axis axis) {
    return [
      for (var i = 0; i < suggestions.length; i++) ...[
        if (i > 0)
          axis == Axis.horizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        suggestions[i],
      ],
    ];
  }
}
