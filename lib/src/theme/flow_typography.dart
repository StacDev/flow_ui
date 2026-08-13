import 'package:flutter/material.dart';

/// The typeface the presets are drawn in, bundled with this package under
/// `fonts/` (SIL Open Font License — see `fonts/OFL.txt`).
///
/// Declared with `package:` so the family resolves to `packages/flow_ui/…`
/// and a host gets the design's typeface without adding a font of their own.
const String _fontFamily = 'Figtree';
const String _fontPackage = 'flow_ui';

/// Text style tokens for flow_ui components.
///
/// Follows the Material 3 type scale (display / headline / title / body /
/// label, each in large / medium / small), so a host can map an existing M3
/// text theme across. Styles are colorless — components combine them with
/// [FlowColors] tokens (e.g.
/// `typography.bodyLarge.copyWith(color: colors.onSurface)`).
///
/// Sizes, weights and line heights come from the Flow UI design file. Two
/// habits of that design carry through the whole scale: no letter-spacing,
/// and one of two line heights — 1.5 where text wraps into paragraphs, 1.3
/// where it sits on a single line in a row or a control.
@immutable
class FlowTypography {
  const FlowTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;

  /// Prose and composer input — the design's 16/1.5 body.
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  /// Controls — the design's 14/1.3 label.
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  /// The Flow type scale, in Figtree.
  static const FlowTypography standard = FlowTypography(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.15,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.15,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
    // The greeting: 32 regular at 1.3.
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    // A heading inside a message: 18 semibold at 1.5.
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      package: _fontPackage,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
  );

  /// The same scale set in [fontFamily] instead of the bundled Figtree.
  ///
  /// Pass [package] when the font ships inside a package rather than the app.
  /// Each style is rebuilt from the four things the scale carries — size,
  /// weight, line height and tracking — so anything else set on a customised
  /// style is dropped rather than half-kept.
  FlowTypography withFontFamily(String fontFamily, {String? package}) {
    TextStyle reface(TextStyle style) => TextStyle(
      fontFamily: fontFamily,
      package: package,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      height: style.height,
      letterSpacing: style.letterSpacing,
    );

    return FlowTypography(
      displayLarge: reface(displayLarge),
      displayMedium: reface(displayMedium),
      displaySmall: reface(displaySmall),
      headlineLarge: reface(headlineLarge),
      headlineMedium: reface(headlineMedium),
      headlineSmall: reface(headlineSmall),
      titleLarge: reface(titleLarge),
      titleMedium: reface(titleMedium),
      titleSmall: reface(titleSmall),
      bodyLarge: reface(bodyLarge),
      bodyMedium: reface(bodyMedium),
      bodySmall: reface(bodySmall),
      labelLarge: reface(labelLarge),
      labelMedium: reface(labelMedium),
      labelSmall: reface(labelSmall),
    );
  }

  FlowTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) {
    return FlowTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  FlowTypography lerp(FlowTypography? other, double t) {
    if (other == null) return this;
    return FlowTypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }
}
