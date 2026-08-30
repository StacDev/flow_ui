import 'package:material_ui/material_ui.dart';

import '../styles/flow_message_actions_style.dart';
import '../theme/flow_theme.dart';
import '../utils/flow_touch_target.dart';

/// One action in a [FlowMessageActions] row.
///
/// Purely descriptive: an icon, an intent callback, and optional
/// host-localized [tooltip] — the package ships no strings. The named
/// constructors are icon presets for the common chat actions.
@immutable
class FlowMessageAction {
  const FlowMessageAction({
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.selected = false,
    this.selectedIcon,
  });

  /// Copy the message content.
  const FlowMessageAction.copy({this.onPressed, this.tooltip})
    : icon = Icons.copy_outlined,
      selected = false,
      selectedIcon = null;

  /// Regenerate the response.
  const FlowMessageAction.regenerate({this.onPressed, this.tooltip})
    : icon = Icons.refresh,
      selected = false,
      selectedIcon = null;

  /// Edit the message.
  const FlowMessageAction.edit({this.onPressed, this.tooltip})
    : icon = Icons.edit_outlined,
      selected = false,
      selectedIcon = null;

  /// Positive feedback; toggles to a filled thumb when [selected].
  const FlowMessageAction.thumbUp({
    this.onPressed,
    this.tooltip,
    this.selected = false,
  }) : icon = Icons.thumb_up_outlined,
       selectedIcon = Icons.thumb_up;

  /// Negative feedback; toggles to a filled thumb when [selected].
  const FlowMessageAction.thumbDown({
    this.onPressed,
    this.tooltip,
    this.selected = false,
  }) : icon = Icons.thumb_down_outlined,
       selectedIcon = Icons.thumb_down;

  final IconData icon;

  /// Shown instead of [icon] while [selected] (e.g. a filled thumb).
  final IconData? selectedIcon;

  /// Null renders the action disabled.
  final VoidCallback? onPressed;

  /// Host-localized tooltip; omitted → no tooltip.
  final String? tooltip;

  /// Toggled state, tinted with the primary color.
  final bool selected;
}

/// Compact icon-button row for message actions — designed for the
/// `footer` slot of a `FlowMessage`:
///
/// ```dart
/// FlowMessage(
///   message,
///   footer: FlowMessageActions(actions: [
///     FlowMessageAction.copy(tooltip: 'Copy', onPressed: ...),
///     FlowMessageAction.thumbUp(selected: liked, onPressed: ...),
///   ]),
/// )
/// ```
class FlowMessageActions extends StatelessWidget {
  const FlowMessageActions({
    super.key,
    required this.actions,
    this.iconSize = 15,
    this.padding,
    this.style,
  });

  /// The design's strip sets the frames 4 apart — a component spec
  /// value, not a scale step.
  static const double _gap = 4;

  /// The strip's reach above its frames on touch platforms: each button
  /// lays out this much taller with its frame at the bottom, and
  /// `FlowMessage` gives up the same run of its footer gap, so the frames
  /// stay put while the strip reaches up into the gap — or as much of it
  /// as the gap holds, through [FlowFooterReach]. Sideways the buttons
  /// share the strip's pitch between them, the edge ones keeping their
  /// frames flush with the strip's ends.
  static const double touchReach = 12;

  /// Rendered in order.
  final List<FlowMessageAction> actions;

  /// Compact by default, per the design.
  final double iconSize;

  /// Around the whole row; defaults to none.
  final EdgeInsetsGeometry? padding;

  /// Per-instance restyling, merged over [FlowTheme.messageActionsStyle]'s
  /// fields; nulls fall through to the theme tokens.
  final FlowMessageActionsStyle? style;

  @override
  Widget build(BuildContext context) {
    final effective =
        context.flowTheme.messageActionsStyle?.merge(style) ?? style;
    // The design's action strip: 15px glyphs on 20px frames, 4 apart. On
    // touch the gaps belong to the buttons instead — each edge button
    // takes half a gap on its outer side, the rest a full gap — so the
    // pitch and every frame's place are unchanged while a finger between
    // two frames still lands on one.
    final touch = FlowTouchTarget.isTouch(context);
    final last = actions.length - 1;
    double reachWidth(int i) {
      if (!touch || last == 0) return _ActionButtonState._frameSize;
      return _ActionButtonState._frameSize +
          (i == 0 || i == last ? _gap / 2 : _gap);
    }

    double leftShare(int i) => i == 0 ? 0 : (i == last ? 1 : 0.5);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0 && !touch) const SizedBox(width: _gap),
          _ActionButton(
            action: actions[i],
            iconSize: iconSize,
            style: effective,
            reachWidth: reachWidth(i),
            leftShare: leftShare(i),
          ),
        ],
      ],
    );
    if (padding == null) return row;
    return Padding(padding: padding!, child: row);
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.action,
    required this.iconSize,
    this.style,
    required this.reachWidth,
    required this.leftShare,
  });

  final FlowMessageAction action;
  final double iconSize;
  final FlowMessageActionsStyle? style;

  /// The button's share of the strip's pitch on touch platforms, and
  /// where its frame sits in it.
  final double reachWidth;
  final double leftShare;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  /// The spec frame: a host's `iconSize` resizes the glyph inside it,
  /// never the strip — an oversize glyph overflows.
  static const double _frameSize = 20;

  /// The frame's corner, tighter than any shared step reads at this size.
  static const BorderRadius _frameRadius = BorderRadius.all(Radius.circular(2));

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final action = widget.action;
    final enabled = action.onPressed != null;

    // Rest at the muted ink — the design's 50% for message-action glyphs —
    // lifting to full ink on hover so the affordance stays.
    final style = widget.style;
    final rest = style?.iconColor ?? colors.onSurfaceMuted;
    final Color foreground;
    if (!enabled) {
      foreground = colors.onSurfaceDisabled;
    } else if (action.selected) {
      foreground = style?.selectedColor ?? colors.primary;
    } else if (_hovered) {
      foreground = style?.hoverIconColor ?? colors.onSurface;
    } else {
      foreground = rest;
    }

    // Transparent Material so ink and hover fills render anywhere,
    // including inside decorated containers.
    Widget button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: action.onPressed,
        onHover: enabled ? (value) => setState(() => _hovered = value) : null,
        borderRadius: _frameRadius,
        hoverColor: style?.hoverColor ?? colors.surfaceContainer,
        child: SizedBox.square(
          dimension: _frameSize,
          child: Center(
            child: Icon(
              action.selected
                  ? (action.selectedIcon ?? action.icon)
                  : action.icon,
              size: widget.iconSize,
              color: foreground,
            ),
          ),
        ),
      ),
    );

    final tooltip = action.tooltip;
    if (tooltip != null) {
      button = Tooltip(message: tooltip, child: button);
    }
    // The frame keeps its place: its share of the pitch sideways, the
    // footer gap the message gave up above, seated at the bottom.
    final reach =
        FlowFooterReach.maybeOf(context) ?? FlowMessageActions.touchReach;
    return FlowTouchTarget(
      minWidth: widget.reachWidth,
      minHeight: _frameSize + reach,
      topShare: 1,
      leftShare: widget.leftShare,
      child: button,
    );
  }
}

/// How far a [FlowMessageActions] strip may reach above its frames on
/// touch platforms: the run of footer gap its message has given up.
/// `FlowMessage` sets it to the gap it has; a strip on its own takes the
/// full [FlowMessageActions.touchReach].
class FlowFooterReach extends InheritedWidget {
  const FlowFooterReach({super.key, required this.reach, required super.child});

  final double reach;

  static double? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FlowFooterReach>()?.reach;

  @override
  bool updateShouldNotify(FlowFooterReach oldWidget) =>
      reach != oldWidget.reach;
}
