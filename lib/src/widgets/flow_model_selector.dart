import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../utils/flow_menu.dart';
import '../utils/flow_state_colors.dart';

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

/// One effort choice in a [FlowModelSelector].
@immutable
class FlowEffortOption {
  const FlowEffortOption({
    required this.id,
    required this.label,
    this.enabled = true,
  });

  /// Reported through `onEffortSelected`.
  final String id;

  /// Host-supplied display name, e.g. 'Medium'.
  final String label;

  final bool enabled;
}

/// Compact model picker: a pill trigger showing the selected model, opening
/// a token-styled menu. Designed for a composer's `trailingActions` slot.
///
/// Passing [efforts] adds an Effort submenu row under the models and the
/// selected effort's label, muted, to the trigger — `Sonnet 5  Medium`.
/// Picking a model or an effort applies immediately and closes the menu.
class FlowModelSelector extends StatefulWidget {
  const FlowModelSelector({
    super.key,
    required this.models,
    this.selectedId,
    this.onSelected,
    this.efforts = const <FlowEffortOption>[],
    this.selectedEffortId,
    this.onEffortSelected,
    this.effortLabel = 'Effort',
    this.effortHint,
    this.enabled = true,
    this.tooltip,
  }) : assert(
         efforts.length == 0 || selectedEffortId != null,
         'selectedEffortId is required when efforts are provided.',
       ),
       assert(
         efforts.length == 0 || onEffortSelected != null,
         'onEffortSelected is required when efforts are provided.',
       );

  /// Menu entries, in order.
  final List<FlowModelOption> models;

  /// Highlighted in the menu; its label shows on the trigger.
  /// Falls back to the first model's label when null.
  final String? selectedId;

  /// Called with the chosen option's id. Null disables the selector.
  final ValueChanged<String>? onSelected;

  /// Effort levels, in order. Empty hides the effort section and the
  /// trigger's effort label.
  final List<FlowEffortOption> efforts;

  /// Highlighted in the effort section; its label shows muted on the
  /// trigger. Required when [efforts] is non-empty.
  final String? selectedEffortId;

  /// Called with the chosen effort's id. Required when [efforts] is
  /// non-empty.
  final ValueChanged<String>? onEffortSelected;

  /// Host-localized label on the submenu row.
  final String effortLabel;

  /// Optional muted paragraph at the top of the effort submenu, e.g. what
  /// higher effort trades away.
  final String? effortHint;

  final bool enabled;

  /// Host-localized trigger tooltip.
  final String? tooltip;

  @override
  State<FlowModelSelector> createState() => _FlowModelSelectorState();
}

class _FlowModelSelectorState extends State<FlowModelSelector> {
  final MenuController _menuController = MenuController();
  bool _hovered = false;

  FlowModelOption? get _selected {
    for (final model in widget.models) {
      if (model.id == widget.selectedId) return model;
    }
    return widget.models.isEmpty ? null : widget.models.first;
  }

  FlowEffortOption? get _selectedEffort {
    for (final effort in widget.efforts) {
      if (effort.id == widget.selectedEffortId) return effort;
    }
    return null;
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
    final effortForeground = enabled
        ? colors.onSurfaceVariant
        : flowDisabledColor(colors.onSurfaceVariant);
    final effort = _selectedEffort;

    return MenuAnchor(
      controller: _menuController,
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
        if (widget.efforts.isNotEmpty) ...[
          const FlowMenuDivider(),
          SubmenuButton(
            menuStyle: flowMenuStyle(context),
            style: flowSubmenuRowStyle(context),
            // The chevron goes in the submenu-indicator slot; putting it in
            // trailingIcon would double up with the button's built-in arrow.
            submenuIcon: WidgetStatePropertyAll(
              Icon(
                Icons.chevron_right,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
            trailingIcon: effort == null
                ? null
                : Text(
                    effort.label,
                    style: context.flowTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
            menuChildren: [
              if (widget.effortHint != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.md,
                    spacing.sm,
                    spacing.md,
                    spacing.sm,
                  ),
                  child: SizedBox(
                    width: 260,
                    child: Text(
                      widget.effortHint!,
                      style: context.flowTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              for (final option in widget.efforts)
                FlowMenuRow(
                  label: option.label,
                  selected: option.id == widget.selectedEffortId,
                  enabled: option.enabled,
                  // The row's own closeOnTap would only dismiss the submenu
                  // it sits in; picking an effort should close the whole
                  // menu, so the root controller does it.
                  closeOnTap: false,
                  onTap: () {
                    _menuController.close();
                    widget.onEffortSelected?.call(option.id);
                  },
                ),
            ],
            child: Text(
              widget.effortLabel,
              style: context.flowTypography.bodyMedium.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
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
                  if (effort != null) ...[
                    SizedBox(width: spacing.sm),
                    Text(
                      effort.label,
                      style: context.flowTypography.labelLarge.copyWith(
                        color: effortForeground,
                      ),
                    ),
                  ],
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
