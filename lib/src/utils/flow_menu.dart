import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import 'flow_state_colors.dart';

// Internal menu infrastructure shared by the selector widgets.
// Not exported from the package barrel.

/// Token-styled [MenuStyle] for selector menus.
MenuStyle flowMenuStyle(BuildContext context) {
  final colors = context.flowColors;
  return MenuStyle(
    // A menu is a raised card, the same one the composer is.
    backgroundColor: WidgetStatePropertyAll(colors.surfaceContainerLowest),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: context.flowRadii.md,
        side: BorderSide(color: colors.outline),
      ),
    ),
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(vertical: context.flowSpacing.xs),
    ),
  );
}

/// A hairline rule between menu sections.
class FlowMenuDivider extends StatelessWidget {
  const FlowMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: context.flowSpacing.xs),
      color: context.flowColors.outlineVariant,
    );
  }
}

/// Token-styled [ButtonStyle] for a [SubmenuButton] row, matching
/// [FlowMenuRow]'s metrics and hover treatment.
ButtonStyle flowSubmenuRowStyle(BuildContext context) {
  final colors = context.flowColors;
  final spacing = context.flowSpacing;
  return ButtonStyle(
    backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)
          ? colors.surfaceContainerHigh
          : Colors.transparent,
    ),
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
    ),
    minimumSize: const WidgetStatePropertyAll(Size(220, 0)),
    shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
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
    this.closeOnTap = true,
    this.minWidth = 220,
  });

  final String label;
  final String? description;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  /// Whether tapping dismisses the enclosing menu. Picking an option is the
  /// decision a selector menu exists for, so it defaults to true; a row that
  /// toggles state in place can opt out.
  final bool closeOnTap;

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

    // This context sits inside the menu overlay, so the enclosing
    // MenuAnchor's controller is in scope here — the row can dismiss the
    // menu itself, and every selector built on it closes on pick.
    final VoidCallback? handleTap = !enabled || onTap == null
        ? null
        : () {
            if (closeOnTap) MenuController.maybeOf(context)?.close();
            onTap!();
          };

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: handleTap,
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
