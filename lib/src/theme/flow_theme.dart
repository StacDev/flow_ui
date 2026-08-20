import 'package:material_ui/material_ui.dart';

import 'flow_colors.dart';
import 'flow_syntax_colors.dart';
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
    this.syntax,
  });

  /// Light preset.
  factory FlowTheme.light() =>
      const FlowTheme(colors: FlowColors.light, syntax: FlowSyntaxColors.light);

  /// Dark preset.
  factory FlowTheme.dark() =>
      const FlowTheme(colors: FlowColors.dark, syntax: FlowSyntaxColors.dark);

  final FlowColors colors;
  final FlowTypography typography;

  /// Syntax token colors for code blocks. Null resolves to the preset
  /// matching the ambient brightness — unlike [typography], the right
  /// default depends on which way the theme leans, which a constructor
  /// default can't see.
  final FlowSyntaxColors? syntax;

  @override
  FlowTheme copyWith({
    FlowColors? colors,
    FlowTypography? typography,
    FlowSyntaxColors? syntax,
  }) {
    return FlowTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      syntax: syntax ?? this.syntax,
    );
  }

  @override
  FlowTheme lerp(ThemeExtension<FlowTheme>? other, double t) {
    if (other is! FlowTheme) return this;
    return FlowTheme(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      syntax: syntax == null ? other.syntax : syntax!.lerp(other.syntax, t),
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

  /// Syntax colors: the installed set, or the preset matching the ambient
  /// brightness when the theme carries none.
  FlowSyntaxColors get flowSyntaxColors {
    final syntax = flowTheme.syntax;
    if (syntax != null) return syntax;
    return Theme.of(this).brightness == Brightness.dark
        ? FlowSyntaxColors.dark
        : FlowSyntaxColors.light;
  }
}
