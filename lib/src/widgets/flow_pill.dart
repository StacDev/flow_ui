import 'package:material_ui/material_ui.dart';

import '../theme/flow_theme.dart';
import '../utils/flow_state_colors.dart';

/// A removable pill showing an enabled tool or mode — "Research", "Web
/// Search" — in the composer's action row, typically appended to
/// `FlowComposer.leadingActions` while the host's toggle is on:
///
/// ```dart
/// if (researchOn)
///   FlowPill(
///     icon: Icons.school_outlined,
///     label: 'Research',
///     removeTooltip: 'Turn off Research',
///     onRemove: () => setResearch(false),
///   )
/// ```
///
/// The X reports removal through [onRemove]; actually turning the tool off
/// is the host's move. On phones the label drops away to the design's
/// icon-only form (see [showLabel]).
///
/// A pill without [onRemove] is a static status token in full ink, not a
/// disabled control — unlike `FlowSuggestion`, where a null tap renders
/// the row disabled. Disabling here is explicit, through [enabled].
class FlowPill extends StatefulWidget {
  const FlowPill({
    super.key,
    required this.icon,
    required this.label,
    this.onRemove,
    this.onTap,
    this.removeTooltip,
    this.tooltip,
    this.showLabel,
    this.enabled = true,
    this.padding,
    this.borderRadius,
  });

  /// The tool's glyph — always drawn; the pill's whole identity in the
  /// icon-only form.
  final IconData icon;

  /// The tool's name. Always the pill's accessible name, drawn only while
  /// the labeled form is in effect (see [showLabel]).
  final String label;

  /// Remove intent from the trailing X; null leaves the X off entirely —
  /// a static status pill.
  final VoidCallback? onRemove;

  /// Optional tap on the pill's body, e.g. reopening the tool's options.
  /// Null leaves the body inert without reading disabled.
  final VoidCallback? onTap;

  /// Host-localized label for the X, e.g. 'Turn off Research' — its
  /// tooltip and accessible name. Pass one whenever [onRemove] is set, or
  /// assistive tech announces an unnamed button.
  final String? removeTooltip;

  /// Host-localized tooltip over the pill's body — the tool's name when a
  /// host forces the icon-only form on a hovering device.
  final String? tooltip;

  /// Whether the label is drawn. Null resolves by platform — hidden on
  /// iOS and Android (the design's compact composer), shown elsewhere —
  /// reading the theme's platform rather than the real one, like the
  /// menus' sheet resolution, so hosts and tests can steer it without a
  /// device.
  final bool? showLabel;

  final bool enabled;

  /// Inside the pill. Defaults to the design's 8 horizontally.
  final EdgeInsetsGeometry? padding;

  /// The pill's corner. Defaults to the design's 8.
  final BorderRadius? borderRadius;

  @override
  State<FlowPill> createState() => _FlowPillState();
}

class _FlowPillState extends State<FlowPill> {
  /// The design's pill: 32 tall on an 8px corner, padded 8, an 18px glyph
  /// 6 from its label with the 14px X another 6 along — the gap closing
  /// to 4 in the icon-only form, per the compact composer.
  static const double _height = 32;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(8));
  static const EdgeInsetsGeometry _padding = EdgeInsets.symmetric(
    horizontal: 8,
  );
  static const double _iconSize = 18;
  static const double _removeSize = 14;
  static const double _gap = 6;
  static const double _compactGap = 4;

  bool _removeHovered = false;

  bool _labelVisible(BuildContext context) {
    final show = widget.showLabel;
    if (show != null) return show;
    final platform = Theme.of(context).platform;
    return platform != TargetPlatform.iOS && platform != TargetPlatform.android;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final enabled = widget.enabled;
    final showLabel = _labelVisible(context);
    final gap = showLabel ? _gap : _compactGap;
    final hasRemove = widget.onRemove != null;

    // Content rests in full ink; the X a step down at the muted chrome
    // level, lifting to full on hover. Disabling fades each from its own
    // rest, so the X stays proportionally fainter.
    final foreground = enabled
        ? colors.onSurface
        : flowDisabledColor(colors.onSurface);
    final removeRest = enabled
        ? colors.onSurfaceMuted
        : flowDisabledColor(colors.onSurfaceMuted);
    final removeForeground = _removeHovered && enabled
        ? colors.onSurface
        : removeRest;

    final shape = RoundedRectangleBorder(
      borderRadius: widget.borderRadius ?? _radius,
      side: BorderSide(color: colors.outlineVariant),
    );

    // The X's target spans the pill's full height and absorbs the end
    // inset, so splitting the padding needs the resolved sides — start on
    // the body, end inside the X — kept directional so RTL swaps them.
    final direction = Directionality.of(context);
    final resolved = (widget.padding ?? _padding).resolve(direction);
    final startInset = direction == TextDirection.ltr
        ? resolved.left
        : resolved.right;
    final endInset = direction == TextDirection.ltr
        ? resolved.right
        : resolved.left;

    Widget body = Padding(
      padding: EdgeInsetsDirectional.only(
        start: startInset,
        end: hasRemove ? 0 : endInset,
        top: resolved.top,
        bottom: resolved.bottom,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: _iconSize, color: foreground),
          if (showLabel) ...[
            const SizedBox(width: _gap),
            Text(
              widget.label,
              style: typography.labelLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.onTap != null) {
      body = InkWell(
        onTap: enabled ? widget.onTap : null,
        hoverColor: colors.surfaceContainerLow,
        child: body,
      );
      // Excluding the subtree keeps the label from reading twice, but it
      // drops the InkWell's tap action with it — the node re-owns
      // activation or assistive tech can announce the pill yet not tap it.
      body = Semantics(
        button: true,
        label: widget.label,
        excludeSemantics: true,
        onTap: enabled ? widget.onTap : null,
        child: body,
      );
    } else if (!showLabel) {
      // The inert icon-only body still announces the tool's name.
      body = Semantics(
        label: widget.label,
        child: ExcludeSemantics(child: body),
      );
    }

    // On the body only — the X carries its own tooltip, and covering it
    // from an ancestor would raise both at once.
    final tooltip = widget.tooltip;
    if (tooltip != null) {
      body = Tooltip(message: tooltip, child: body);
    }

    Widget? remove;
    if (hasRemove) {
      remove = InkWell(
        onTap: enabled ? widget.onRemove : null,
        onHover: enabled
            ? (value) => setState(() => _removeHovered = value)
            : null,
        hoverColor: colors.surfaceContainerLow,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: gap,
            end: endInset,
            top: resolved.top,
            bottom: resolved.bottom,
          ),
          child: Center(
            child: Icon(
              Icons.close,
              size: _removeSize,
              color: removeForeground,
            ),
          ),
        ),
      );
      // Tooltip already contributes the message to the semantics node, so
      // it doubles as the X's accessible name — the circle button's idiom.
      final removeTooltip = widget.removeTooltip;
      if (removeTooltip != null) {
        remove = Tooltip(message: removeTooltip, child: remove);
      }
    }

    return Material(
      color: colors.surfaceContainerLow,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: _height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // Stretched, so the body's ink and the X's target span the
          // pill's full height; each region centres its own glyphs.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [body, ?remove],
        ),
      ),
    );
  }
}
