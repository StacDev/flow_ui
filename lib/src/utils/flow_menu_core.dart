import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../widgets/flow_menu_style.dart';
import 'flow_menu_sheet.dart';
import 'flow_state_colors.dart';

// Internal menu infrastructure shared by the selector widgets.
// Not exported from the package barrel.

/// The menu card's hairline and the section rule, as alphas over the ink.
///
/// Stronger than the `outline`/`outlineVariant` tokens on purpose: a menu
/// floats over arbitrary content, and the design draws its edges a step
/// firmer than the ones on cards that sit in the page.
const double _borderOpacity = 0.2;
const double _separatorOpacity = 0.1;

/// The design's menu metrics: a 12px card, rows padded 16/8 with a 12px
/// icon gap, and hairline rules inset like the rows.
const BorderRadius _menuRadius = BorderRadius.all(Radius.circular(12));
const double _menuVerticalPadding = 4;
const EdgeInsetsGeometry _rowPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 8,
);
const EdgeInsetsGeometry _dividerMargin = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 4,
);

/// The gap between a row's leading icon and its label — shared with the
/// SubmenuButton rows built outside this file, so neighbouring rows in one
/// menu can't drift out of column.
const double flowMenuIconGap = 12;
const double _valueGap = 8;
const double _checkGap = 12;
const double _chevronGap = 4;

/// Whether [presentation] means a bottom sheet in this context.
bool flowMenuPresentsAsSheet(
  BuildContext context,
  FlowMenuPresentation presentation,
) {
  switch (presentation) {
    case FlowMenuPresentation.menu:
      return false;
    case FlowMenuPresentation.sheet:
      return true;
    case FlowMenuPresentation.auto:
      // The theme's platform rather than the real one, so hosts and tests
      // can steer the resolution without a device.
      final platform = Theme.of(context).platform;
      return platform == TargetPlatform.iOS ||
          platform == TargetPlatform.android;
  }
}

Color flowMenuBackground(BuildContext context, FlowMenuStyle? style) =>
    style?.backgroundColor ?? context.flowColors.surfaceContainerLowest;

Color flowMenuBorderColor(BuildContext context, FlowMenuStyle? style) =>
    style?.borderColor ??
    context.flowColors.onSurface.withValues(alpha: _borderOpacity);

Color flowMenuSeparatorColor(BuildContext context, FlowMenuStyle? style) =>
    style?.separatorColor ??
    context.flowColors.onSurface.withValues(alpha: _separatorOpacity);

Color flowMenuHoverColor(BuildContext context, FlowMenuStyle? style) =>
    style?.hoverColor ?? context.flowColors.surfaceContainerHigh;

Color flowMenuAccentColor(BuildContext context, FlowMenuStyle? style) =>
    style?.accentColor ?? context.flowColors.primary;

/// Token-styled [MenuStyle] for selector menus.
MenuStyle flowMenuStyle(BuildContext context, {FlowMenuStyle? style}) {
  return MenuStyle(
    // A menu is a raised card, the same one the composer is.
    backgroundColor: WidgetStatePropertyAll(flowMenuBackground(context, style)),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: style?.menuRadius ?? _menuRadius,
        side: BorderSide(color: flowMenuBorderColor(context, style)),
      ),
    ),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(vertical: _menuVerticalPadding),
    ),
  );
}

/// The hairline rule between menu sections, inset like the rows beside it —
/// what a `FlowMenuDivider` entry renders.
class FlowMenuRule extends StatelessWidget {
  const FlowMenuRule({super.key, this.style});

  final FlowMenuStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: _dividerMargin,
      color: flowMenuSeparatorColor(context, style),
    );
  }
}

/// Token-styled [ButtonStyle] for a [SubmenuButton] row, matching
/// [FlowMenuRow]'s metrics and hover treatment.
ButtonStyle flowSubmenuRowStyle(BuildContext context, {FlowMenuStyle? style}) {
  final hover = flowMenuHoverColor(context, style);
  return ButtonStyle(
    backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)
          ? hover
          : Colors.transparent,
    ),
    padding: const WidgetStatePropertyAll(_rowPadding),
    minimumSize: WidgetStatePropertyAll(Size(style?.minWidth ?? 220, 0)),
    shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
    // Desktop's compact ambient density would shave the padding above,
    // leaving these rows visibly thinner than the FlowMenuRows beside
    // them, which are not buttons and never densify.
    visualDensity: VisualDensity.standard,
  );
}

/// The submenu indicator for a [SubmenuButton], sized for the menu.
WidgetStatePropertyAll<Widget> flowSubmenuChevron(BuildContext context) {
  return WidgetStatePropertyAll(
    Icon(
      Icons.chevron_right,
      size: 16,
      color: context.flowColors.onSurfaceVariant,
    ),
  );
}

/// Default row label style: the design's 14 Medium in the menu and
/// 16 Medium in the sheet, both on the tight line height.
TextStyle flowMenuLabelStyle(
  BuildContext context, {
  required bool large,
  FlowMenuStyle? style,
}) {
  final typography = context.flowTypography;
  final base = large
      ? typography.bodyLarge.copyWith(fontWeight: FontWeight.w500, height: 1.3)
      : typography.labelLarge.copyWith(fontWeight: FontWeight.w500);
  final override = style?.labelStyle;
  return override == null ? base : base.merge(override);
}

/// Default row description style: 14 regular in the muted ink.
TextStyle flowMenuDescriptionStyle(
  BuildContext context, {
  FlowMenuStyle? style,
}) {
  final base = context.flowTypography.labelLarge.copyWith(
    color: context.flowColors.onSurfaceMuted,
  );
  final override = style?.descriptionStyle;
  return override == null ? base : base.merge(override);
}

/// One row inside a selector menu or menu sheet: optional leading icon,
/// label, optional muted description, and a trailing value, chevron or
/// check.
///
/// [large] switches to the bottom sheet's metrics — the 16px label, the
/// 20px glyphs — while everything else stays shared, so the two
/// presentations can't drift apart.
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
    this.large = false,
    this.trailingLabel,
    this.showChevron = false,
    this.style,
  });

  final String label;
  final String? description;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  /// Whether tapping dismisses the enclosing menu or sheet. Picking an
  /// option is the decision a selector menu exists for, so it defaults to
  /// true; a row that pushes a sheet page or toggles in place opts out.
  final bool closeOnTap;

  /// Sheet metrics instead of menu metrics.
  final bool large;

  /// Accented value at the row's end, e.g. the chosen effort's label.
  final String? trailingLabel;

  /// A trailing chevron, for a row that opens a sheet page. Anchored menus
  /// get their chevron from [SubmenuButton] instead.
  final bool showChevron;

  final FlowMenuStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    final labelStyle = flowMenuLabelStyle(context, large: large, style: style);
    final descriptionStyle = flowMenuDescriptionStyle(context, style: style);
    final iconColor = style?.iconColor ?? colors.onSurface;
    final labelColor = labelStyle.color ?? colors.onSurface;

    final iconSize = large ? 20.0 : 18.0;
    final checkSize = large ? 20.0 : 16.0;
    final chevronSize = large ? 18.0 : 16.0;

    // This context sits inside the menu overlay or the sheet, so whichever
    // host is enclosing is in scope here — the row can dismiss it itself,
    // and every selector built on it closes on pick.
    final VoidCallback? handleTap = !enabled || onTap == null
        ? null
        : () {
            if (closeOnTap) {
              MenuController.maybeOf(context)?.close();
              FlowMenuSheetScope.maybeOf(context)?.close();
            }
            onTap!();
          };

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: handleTap,
        // These rows are not menu buttons, so the menu system doesn't know
        // the pointer moved here — a sibling SubmenuButton's open submenu
        // (and its highlight) would just stay put. Closing the enclosing
        // anchor's children on hover restores the native behaviour.
        onHover: (hovering) {
          if (hovering) MenuController.maybeOf(context)?.closeChildren();
        },
        hoverColor: flowMenuHoverColor(context, style),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: large ? 0 : (style?.minWidth ?? 220),
          ),
          child: Padding(
            padding: _rowPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: iconSize,
                    color: enabled ? iconColor : flowDisabledColor(iconColor),
                  ),
                  const SizedBox(width: flowMenuIconGap),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: labelStyle.copyWith(
                          color: enabled
                              ? labelColor
                              : flowDisabledColor(labelColor),
                        ),
                      ),
                      if (description != null)
                        Text(
                          description!,
                          style: enabled
                              ? descriptionStyle
                              : descriptionStyle.copyWith(
                                  color: flowDisabledColor(
                                    descriptionStyle.color ??
                                        colors.onSurfaceMuted,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
                if (trailingLabel != null) ...[
                  const SizedBox(width: _valueGap),
                  Text(
                    trailingLabel!,
                    style: labelStyle.copyWith(
                      color: flowMenuAccentColor(context, style),
                    ),
                  ),
                ],
                if (selected) ...[
                  const SizedBox(width: _checkGap),
                  Icon(
                    Icons.check,
                    size: checkSize,
                    color: style?.checkColor ?? colors.primary,
                  ),
                ],
                if (showChevron) ...[
                  const SizedBox(width: _chevronGap),
                  Icon(
                    Icons.chevron_right,
                    size: chevronSize,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
