import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../utils/flow_state_colors.dart';

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
    this.iconSize = 16,
    this.padding,
  });

  /// Rendered in order.
  final List<FlowMessageAction> actions;

  /// Compact by default.
  final double iconSize;

  /// Around the whole row; defaults to none.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.flowSpacing;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: spacing.xs),
          _ActionButton(action: actions[i], iconSize: iconSize),
        ],
      ],
    );
    if (padding == null) return row;
    return Padding(padding: padding!, child: row);
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.action, required this.iconSize});

  final FlowMessageAction action;
  final double iconSize;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final action = widget.action;
    final enabled = action.onPressed != null;

    final Color foreground;
    if (!enabled) {
      foreground = flowDisabledColor(colors.onSurfaceVariant);
    } else if (action.selected) {
      foreground = colors.primary;
    } else if (_hovered) {
      foreground = colors.onSurface;
    } else {
      foreground = colors.onSurfaceVariant;
    }

    // Transparent Material so ink and hover fills render anywhere,
    // including inside decorated containers.
    Widget button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: action.onPressed,
        onHover: enabled ? (value) => setState(() => _hovered = value) : null,
        borderRadius: context.flowRadii.sm,
        hoverColor: colors.surfaceContainerHigh,
        child: Padding(
          padding: EdgeInsets.all(context.flowSpacing.xs),
          child: Icon(
            action.selected
                ? (action.selectedIcon ?? action.icon)
                : action.icon,
            size: widget.iconSize,
            color: foreground,
          ),
        ),
      ),
    );

    final tooltip = action.tooltip;
    if (tooltip != null) {
      button = Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}
