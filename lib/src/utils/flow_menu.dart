import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';

// Internal menu infrastructure shared by the selector widgets.
// Not exported from the package barrel.

const double _disabledOpacity = 0.38;

Color flowDisabledColor(Color color) =>
    color.withValues(alpha: color.a * _disabledOpacity);

/// Token-styled [MenuStyle] for selector menus.
MenuStyle flowMenuStyle(BuildContext context) {
  final colors = context.flowColors;
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(colors.surfaceContainerLow),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: context.flowRadii.md,
        side: BorderSide(color: colors.outlineVariant),
      ),
    ),
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(vertical: context.flowSpacing.xs),
    ),
  );
}

/// One row inside a selector menu: optional leading icon, label, optional
/// muted description, and a check when [selected].
class FlowMenuRow extends StatelessWidget {
  const FlowMenuRow({
    super.key,
    required this.label,
    this.description,
    this.icon,
    this.selected = false,
    this.enabled = true,
    this.onTap,
    this.minWidth = 220,
  });

  final String label;
  final String? description;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final spacing = context.flowSpacing;

    final labelColor = enabled
        ? colors.onSurface
        : flowDisabledColor(colors.onSurface);
    final mutedColor = enabled
        ? colors.onSurfaceVariant
        : flowDisabledColor(colors.onSurfaceVariant);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enabled ? onTap : null,
        hoverColor: colors.surfaceContainerHigh,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: mutedColor),
                  SizedBox(width: spacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: typography.bodyMedium.copyWith(
                          color: labelColor,
                        ),
                      ),
                      if (description != null)
                        Text(
                          description!,
                          style: typography.bodySmall.copyWith(
                            color: mutedColor,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected) ...[
                  SizedBox(width: spacing.md),
                  Icon(Icons.check, size: 16, color: colors.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
