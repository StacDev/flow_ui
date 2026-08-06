import 'package:flutter/material.dart';

/// Semantic color tokens for flow_ui components.
///
/// Role names follow Material 3's [ColorScheme] (primary / secondary /
/// tertiary / error groups, surface containers, outline, inverse), so a host
/// can map an existing M3 scheme straight onto flow_ui.
@immutable
class FlowColors {
  const FlowColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
  });

  // Primary — brand / interactive accent.
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  // Secondary — muted, supporting accent.
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  // Tertiary — contrasting complementary accent.
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  // Error — destructive intent and failure states.
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  // Surface — backgrounds and content on them.
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  // Outline — borders and separators.
  final Color outline;
  final Color outlineVariant;

  // Inverse — elements on the opposite brightness (snackbars, tooltips).
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  /// Neutral light preset.
  static const FlowColors light = FlowColors(
    primary: Color(0xFF4F46E5),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE2E0FC),
    onPrimaryContainer: Color(0xFF3730A3),
    secondary: Color(0xFF5B5B66),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE9E9EB),
    onSecondaryContainer: Color(0xFF1A1A1E),
    tertiary: Color(0xFF0D9488),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCCFBF1),
    onTertiaryContainer: Color(0xFF134E4A),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1E),
    onSurfaceVariant: Color(0xFF55555E),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F7F8),
    surfaceContainer: Color(0xFFF2F2F4),
    surfaceContainerHigh: Color(0xFFECECEF),
    surfaceContainerHighest: Color(0xFFE6E6EA),
    outline: Color(0xFFC9C9D1),
    outlineVariant: Color(0xFFE4E4E8),
    inverseSurface: Color(0xFF2F2F33),
    onInverseSurface: Color(0xFFF4F4F6),
    inversePrimary: Color(0xFFA5B4FC),
  );

  /// Neutral dark preset.
  static const FlowColors dark = FlowColors(
    primary: Color(0xFF7C74F2),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF3730A3),
    onPrimaryContainer: Color(0xFFE0E7FF),
    secondary: Color(0xFFB4B4BD),
    onSecondary: Color(0xFF26262B),
    secondaryContainer: Color(0xFF2A2A30),
    onSecondaryContainer: Color(0xFFF4F4F6),
    tertiary: Color(0xFF2DD4BF),
    onTertiary: Color(0xFF134E4A),
    tertiaryContainer: Color(0xFF115E59),
    onTertiaryContainer: Color(0xFF99F6E4),
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFECACA),
    surface: Color(0xFF131316),
    onSurface: Color(0xFFF4F4F6),
    onSurfaceVariant: Color(0xFFB4B4BD),
    surfaceContainerLowest: Color(0xFF0E0E10),
    surfaceContainerLow: Color(0xFF1D1D21),
    surfaceContainer: Color(0xFF222226),
    surfaceContainerHigh: Color(0xFF26262B),
    surfaceContainerHighest: Color(0xFF2E2E34),
    outline: Color(0xFF3F3F47),
    outlineVariant: Color(0xFF2E2E34),
    inverseSurface: Color(0xFFF4F4F6),
    onInverseSurface: Color(0xFF1A1A1E),
    inversePrimary: Color(0xFF4F46E5),
  );

  FlowColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? outline,
    Color? outlineVariant,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
  }) {
    return FlowColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
    );
  }

  FlowColors lerp(FlowColors? other, double t) {
    if (other == null) return this;
    return FlowColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onSecondaryContainer: Color.lerp(
        onSecondaryContainer,
        other.onSecondaryContainer,
        t,
      )!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      tertiaryContainer: Color.lerp(
        tertiaryContainer,
        other.tertiaryContainer,
        t,
      )!,
      onTertiaryContainer: Color.lerp(
        onTertiaryContainer,
        other.onTertiaryContainer,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      surfaceContainerLowest: Color.lerp(
        surfaceContainerLowest,
        other.surfaceContainerLowest,
        t,
      )!,
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      )!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      onInverseSurface: Color.lerp(
        onInverseSurface,
        other.onInverseSurface,
        t,
      )!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
    );
  }
}
