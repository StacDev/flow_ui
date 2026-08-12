import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../utils/flow_menu.dart';
import '../utils/flow_state_colors.dart';

/// One entry in a [FlowAddMenu].
@immutable
class FlowAddOption {
  const FlowAddOption({
    required this.id,
    required this.icon,
    required this.label,
    this.enabled = true,
  });

  /// Reported through `onSelected`.
  final String id;

  final IconData icon;

  /// Host-supplied display label, e.g. 'Upload a file'.
  final String label;

  final bool enabled;
}

/// The "+" button that opens a menu of things to add to the chat —
/// attachments (photos, files) as well as tools and modes (web search,
/// research, …). Designed for a composer's `leadingActions` slot.
class FlowAddMenu extends StatefulWidget {
  const FlowAddMenu({
    super.key,
    required this.options,
    this.onSelected,
    this.enabled = true,
    this.tooltip,
    this.icon = Icons.add,
  });

  /// Menu entries, in order.
  final List<FlowAddOption> options;

  /// Called with the chosen option's id. Null disables the menu.
  final ValueChanged<String>? onSelected;

  final bool enabled;

  /// Host-localized trigger tooltip.
  final String? tooltip;

  /// The trigger glyph.
  final IconData icon;

  @override
  State<FlowAddMenu> createState() => _FlowAddMenuState();
}

class _FlowAddMenuState extends State<FlowAddMenu> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final enabled =
        widget.enabled &&
        widget.onSelected != null &&
        widget.options.isNotEmpty;

    final Color foreground;
    if (!enabled) {
      foreground = flowDisabledColor(colors.onSurfaceVariant);
    } else if (_hovered) {
      foreground = colors.onSurface;
    } else {
      foreground = colors.onSurfaceVariant;
    }

    return MenuAnchor(
      style: flowMenuStyle(context),
      menuChildren: [
        for (final option in widget.options)
          FlowMenuRow(
            label: option.label,
            icon: option.icon,
            enabled: option.enabled,
            onTap: () => widget.onSelected?.call(option.id),
          ),
      ],
      builder: (context, controller, _) {
        Widget trigger = Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled
                ? () =>
                      controller.isOpen ? controller.close() : controller.open()
                : null,
            onHover: enabled
                ? (value) => setState(() => _hovered = value)
                : null,
            customBorder: const CircleBorder(),
            hoverColor: colors.surfaceContainerHigh,
            child: Padding(
              padding: EdgeInsets.all(context.flowSpacing.xs),
              child: Icon(widget.icon, size: 20, color: foreground),
            ),
          ),
        );
        final tooltip = widget.tooltip;
        if (tooltip != null) {
          trigger = Tooltip(message: tooltip, child: trigger);
        }
        return trigger;
      },
    );
  }
}
