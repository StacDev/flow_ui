import 'package:material_ui/material_ui.dart';

/// How a flow_ui menu presents when its trigger is tapped.
enum FlowMenuPresentation {
  /// A bottom sheet on iOS and Android, an anchored menu everywhere else.
  ///
  /// Resolved against `Theme.of(context).platform`, so a host (or a test)
  /// can steer it by overriding the ambient theme's platform.
  auto,

  /// Always an anchored menu, hanging off the trigger.
  menu,

  /// Always a modal bottom sheet.
  sheet,
}

/// Host overrides for a flow_ui menu's look, on top of the theme tokens.
///
/// Every field is optional; null falls back to the token-derived default
/// noted on the field. One instance covers both presentations — the anchored
/// menu and the bottom sheet draw from the same palette:
///
/// ```dart
/// FlowModelSelector(
///   models: models,
///   menuStyle: const FlowMenuStyle(
///     backgroundColor: Color(0xFF102030),
///     labelStyle: TextStyle(fontSize: 15),
///   ),
/// )
/// ```
@immutable
class FlowMenuStyle {
  const FlowMenuStyle({
    this.backgroundColor,
    this.borderColor,
    this.separatorColor,
    this.hoverColor,
    this.labelStyle,
    this.descriptionStyle,
    this.iconColor,
    this.checkColor,
    this.accentColor,
    this.menuRadius,
    this.sheetRadius,
    this.minWidth,
    this.barrierColor,
  });

  /// The menu card and the sheet. Defaults to `surfaceBright`.
  final Color? backgroundColor;

  /// Hairline around the card and the sheet. The card's default is a
  /// gradient from ink at 20% to ink at 12%; setting this flattens it to
  /// one solid color. The sheet's default is ink at 20%.
  final Color? borderColor;

  /// Rule between sections. Defaults to ink at 10%.
  final Color? separatorColor;

  /// Row fill on hover and focus. Defaults to `surfaceContainer`.
  final Color? hoverColor;

  /// Merged over the default row label style (`labelMediumEmphasised` in
  /// the menu, `labelLargeEmphasised` in the sheet).
  final TextStyle? labelStyle;

  /// Merged over the default description style (`labelMedium` in
  /// `onSurfaceMuted`).
  final TextStyle? descriptionStyle;

  /// Leading row icons. Defaults to `onSurfaceVariant`.
  final Color? iconColor;

  /// The selected check. Defaults to `primary`.
  final Color? checkColor;

  /// Accented trailing values, e.g. the chosen effort on its row.
  /// Defaults to `primary`.
  final Color? accentColor;

  /// Corner radius of the anchored menu card. Defaults to the design's 12.
  /// The bottom sheet's top corners come from [sheetRadius].
  final BorderRadius? menuRadius;

  /// The bottom sheet's top corners. Defaults to the design's 24.
  final Radius? sheetRadius;

  /// Minimum width of the anchored menu's rows. Defaults to 220.
  final double? minWidth;

  /// Scrim behind the bottom sheet. Defaults to the framework's.
  final Color? barrierColor;
}
