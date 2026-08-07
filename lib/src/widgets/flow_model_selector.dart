import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../utils/flow_menu.dart';

/// One model choice in a [FlowModelSelector].
@immutable
class FlowModelOption {
  const FlowModelOption({
    required this.id,
    required this.label,
    this.description,
    this.enabled = true,
  });

  /// Reported through `onSelected`.
  final String id;

  /// Host-supplied display name, e.g. 'Sonnet 5'.
  final String label;

  /// Optional second line in the menu, e.g. 'Fast and balanced'.
  final String? description;

  final bool enabled;
}

/// Compact model picker: a pill trigger showing the selected model, opening
/// a token-styled menu. Designed for a composer's `trailingActions` slot.
class FlowModelSelector extends StatefulWidget {
  const FlowModelSelector({
    super.key,
    required this.models,
    this.selectedId,
    this.onSelected,
    this.enabled = true,
    this.tooltip,
  });

  /// Menu entries, in order.
  final List<FlowModelOption> models;

  /// Highlighted in the menu; its label shows on the trigger.
  /// Falls back to the first model's label when null.
  final String? selectedId;

  /// Called with the chosen option's id. Null disables the selector.
  final ValueChanged<String>? onSelected;

  final bool enabled;

  /// Host-localized trigger tooltip.
  final String? tooltip;

  @override
  State<FlowModelSelector> createState() => _FlowModelSelectorState();
}

class _FlowModelSelectorState extends State<FlowModelSelector> {
  bool _hovered = false;

  FlowModelOption? get _selected {
    for (final model in widget.models) {
      if (model.id == widget.selectedId) return model;
    }
    return widget.models.isEmpty ? null : widget.models.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final spacing = context.flowSpacing;
    final enabled =
        widget.enabled && widget.onSelected != null && widget.models.isNotEmpty;

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
        for (final model in widget.models)
          FlowMenuRow(
            label: model.label,
            description: model.description,
            selected: model.id == widget.selectedId,
            enabled: model.enabled,
            onTap: () => widget.onSelected?.call(model.id),
          ),
      ],
      builder: (context, controller, _) {
        Widget trigger = Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled
                ? () => controller.isOpen
                      ? controller.close()
                      : controller.open()
                : null,
            onHover: enabled
                ? (value) => setState(() => _hovered = value)
                : null,
            borderRadius: context.flowRadii.sm,
            hoverColor: colors.surfaceContainerHigh,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selected?.label ?? '',
                    style: context.flowTypography.labelLarge.copyWith(
                      color: foreground,
                    ),
                  ),
                  SizedBox(width: spacing.xs),
                  Icon(Icons.expand_more, size: 16, color: foreground),
                ],
              ),
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
