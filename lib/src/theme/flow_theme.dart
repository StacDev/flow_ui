import 'package:flutter/material.dart';

import 'flow_colors.dart';
import 'flow_radii.dart';
import 'flow_spacing.dart';
import 'flow_typography.dart';

/// The flow_ui design token system, installed as a [ThemeExtension]:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(extensions: [FlowTheme.light()]),
///   darkTheme: ThemeData(extensions: [FlowTheme.dark()]),
/// )
/// ```
///
/// Components read tokens via [FlowThemeContext] (`context.flowTheme`,
/// `context.flowColors`, …). When no [FlowTheme] is installed, a preset
/// matching the ambient [ThemeData.brightness] is used, so flow_ui works
/// with zero host setup.
class FlowTheme extends ThemeExtension<FlowTheme> {
  const FlowTheme({
    required this.colors,
    this.typography = FlowTypography.standard,
    this.spacing = const FlowSpacing(),
    this.radii = const FlowRadii(),
  });

  /// Light preset.
  factory FlowTheme.light() => const FlowTheme(colors: FlowColors.light);

  /// Dark preset.
  factory FlowTheme.dark() => const FlowTheme(colors: FlowColors.dark);

  final FlowColors colors;
  final FlowTypography typography;
  final FlowSpacing spacing;
  final FlowRadii radii;

  @override
  FlowTheme copyWith({
    FlowColors? colors,
    FlowTypography? typography,
    FlowSpacing? spacing,
    FlowRadii? radii,
  }) {
    return FlowTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
    );
  }

  @override
  FlowTheme lerp(ThemeExtension<FlowTheme>? other, double t) {
    if (other is! FlowTheme) return this;
    return FlowTheme(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      spacing: spacing.lerp(other.spacing, t),
      radii: radii.lerp(other.radii, t),
    );
  }
}

/// Token access for widgets: `context.flowColors.accent`,
/// `context.flowSpacing.md`, …
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
  FlowSpacing get flowSpacing => flowTheme.spacing;
  FlowRadii get flowRadii => flowTheme.radii;
}
