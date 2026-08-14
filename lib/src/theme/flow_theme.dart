import 'package:flutter/material.dart';

import 'flow_colors.dart';
import 'flow_typography.dart';

/// The flow_ui design tokens — colors and typography — installed as a
/// [ThemeExtension]:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(extensions: [FlowTheme.light()]),
///   darkTheme: ThemeData(
///     brightness: Brightness.dark,
///     extensions: [FlowTheme.dark()],
///   ),
/// )
/// ```
///
/// Components read tokens via [FlowThemeContext] (`context.flowTheme`,
/// `context.flowColors`, …). When no [FlowTheme] is installed, a preset
/// matching the ambient [ThemeData.brightness] is used, so flow_ui works
/// with zero host setup.
///
/// Spacing and corner radii are not tokens: following Material's structure,
/// each component bakes its own metrics from the design file and exposes
/// per-widget overrides (`padding:`, `borderRadius:`) where hosts retheme.
class FlowTheme extends ThemeExtension<FlowTheme> {
  const FlowTheme({
    required this.colors,
    this.typography = FlowTypography.standard,
  });

  /// Light preset.
  factory FlowTheme.light() => const FlowTheme(colors: FlowColors.light);

  /// Dark preset.
  factory FlowTheme.dark() => const FlowTheme(colors: FlowColors.dark);

  final FlowColors colors;
  final FlowTypography typography;

  @override
  FlowTheme copyWith({FlowColors? colors, FlowTypography? typography}) {
    return FlowTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
    );
  }

  @override
  FlowTheme lerp(ThemeExtension<FlowTheme>? other, double t) {
    if (other is! FlowTheme) return this;
    return FlowTheme(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
    );
  }
}

/// Token access for widgets: `context.flowColors.primary`,
/// `context.flowTypography.bodyLarge`, …
extension FlowThemeContext on BuildContext {
  /// The installed [FlowTheme], or a brightness-matched preset if none is.
  FlowTheme get flowTheme {
    final theme = Theme.of(this);
    return theme.extension<FlowTheme>() ??
        (theme.brightness == Brightness.dark
            ? FlowTheme.dark()
            : FlowTheme.light());
  }

  FlowColors get flowColors => flowTheme.colors;
  FlowTypography get flowTypography => flowTheme.typography;
}
