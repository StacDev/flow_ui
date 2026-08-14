import 'package:flutter/material.dart';

/// Semantic color tokens for flow_ui components.
///
/// Role names follow Material 3's [ColorScheme] (primary / secondary /
/// tertiary / error groups, surface containers, outline, inverse), so a host
/// can map an existing M3 scheme straight onto flow_ui. [onSurfaceMuted] is
/// the one addition: the Flow design system draws content at three ink
/// levels, and M3 only names two.
///
/// The presets come from the Flow UI design file. Two things about them are
/// worth knowing before overriding one:
///
/// * **The ink ramp is translucent.** [onSurfaceVariant] (75%),
///   [onSurfaceMuted] (50%), [outline] (14%) and [outlineVariant] (6%) are
///   the foreground ink at an alpha, not resolved colors. The design uses the
///   same label and the same hairline on the page *and* on the raised card,
///   which only works if they composite.
/// * **The surface ramp is opaque.** Backgrounds get drawn on, scrimmed and
///   layered over host images, so every `surface*` token is a flat color.
///   The container ladder is the design's even ink tints — 2% / 4% / 6% /
///   8% / 10% from `Lowest` to `Highest` — flattened over each theme's
///   [surface] so the tokens stay opaque.
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
    required this.surfaceBright,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onSurfaceMuted,
    required this.onSurfaceDisabled,
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

  // Primary — brand / interactive accent. The design carries a single accent
  // and uses it at the same value in both themes.
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  // Secondary — muted, supporting accent. Neutral here: the design's user
  // bubble and its label are the ink family, not a second hue.
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  // Tertiary — contrasting complementary accent. Derived: the design names
  // no third accent, so this is the deep end of the primary's hue.
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  // Error — destructive intent and failure states.
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  // Surface — backgrounds and the content on them.

  /// The page.
  final Color surface;

  /// The brightest surface: the floating card — menus and sheets. The one
  /// surface that lifts *off* the page in both themes, sitting outside the
  /// container tint ladder below.
  final Color surfaceBright;

  /// Content ink at full strength: prose, the model name, an active label.
  final Color onSurface;

  /// Ink at 75% — secondary content: row labels and their icons at rest.
  final Color onSurfaceVariant;

  /// Ink at 50% — muted chrome: placeholders, carets, message-action icons.
  final Color onSurfaceMuted;

  /// Ink at 30% — disabled content, like the send button that can't send.
  final Color onSurfaceDisabled;

  /// The tint ladder's faintest rung — 2% ink over the page, as are the
  /// rest of the containers at even steps up to 10%: the composer card and
  /// attachment tiles.
  final Color surfaceContainerLowest;

  /// Faintest fill — a suggestion row at rest.
  final Color surfaceContainerLow;

  /// Resting fill — the user bubble, a selected row.
  final Color surfaceContainer;

  /// Hover.
  final Color surfaceContainerHigh;

  /// Pressed, and the ground behind a failed attachment.
  final Color surfaceContainerHighest;

  // Outline — borders and separators.

  /// Hairline around a raised card — 14% ink in light, 20% in dark; dark
  /// hairlines need the extra step to hold the edge.
  final Color outline;

  /// Fainter hairline: separators, a chip at rest.
  final Color outlineVariant;

  // Inverse — elements on the opposite brightness (snackbars, tooltips).
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  /// Light preset: warm paper, near-black ink, rose accent.
  static const FlowColors light = FlowColors(
    primary: Color(0xFFE071A7),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF6E9ED),
    onPrimaryContainer: Color(0xFF8C3A67),
    secondary: Color(0xFF525251),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF0F0EE),
    onSecondaryContainer: Color(0xFF1A1A19),
    tertiary: Color(0xFFA8497B),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFF3E4EC),
    onTertiaryContainer: Color(0xFF5C2743),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: Color(0xFFF9F9F7),
    surfaceBright: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A19),
    onSurfaceVariant: Color(0xBF1A1A19),
    onSurfaceMuted: Color(0x801A1A19),
    onSurfaceDisabled: Color(0x4D1A1A19),
    surfaceContainerLowest: Color(0xFFF5F5F3),
    surfaceContainerLow: Color(0xFFF0F0EE),
    surfaceContainer: Color(0xFFECECEA),
    surfaceContainerHigh: Color(0xFFE7E7E5),
    surfaceContainerHighest: Color(0xFFE3E3E1),
    outline: Color(0x241A1A19),
    outlineVariant: Color(0x0F1A1A19),
    inverseSurface: Color(0xFF1E1E1E),
    onInverseSurface: Color(0xFFF9F9F7),
    inversePrimary: Color(0xFFE071A7),
  );

  /// Dark preset: the same palette with the ink inverted to white.
  static const FlowColors dark = FlowColors(
    primary: Color(0xFFE071A7),
    onPrimary: Color(0xFF1E1E1E),
    primaryContainer: Color(0xFF432B37),
    onPrimaryContainer: Color(0xFFF5CFE1),
    secondary: Color(0xFFC5C5C5),
    onSecondary: Color(0xFF1E1E1E),
    secondaryContainer: Color(0xFF202020),
    onSecondaryContainer: Color(0xFFFFFFFF),
    tertiary: Color(0xFFDE9CC0),
    onTertiary: Color(0xFF3D1F2E),
    tertiaryContainer: Color(0xFF4E3040),
    onTertiaryContainer: Color(0xFFF6DCE9),
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFECACA),
    surface: Color(0xFF171717),
    surfaceBright: Color(0xFF1E1E1E),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xBFFFFFFF),
    onSurfaceMuted: Color(0x80FFFFFF),
    onSurfaceDisabled: Color(0x4DFFFFFF),
    surfaceContainerLowest: Color(0xFF1C1C1C),
    surfaceContainerLow: Color(0xFF202020),
    surfaceContainer: Color(0xFF252525),
    surfaceContainerHigh: Color(0xFF2A2A2A),
    surfaceContainerHighest: Color(0xFF2E2E2E),
    outline: Color(0x33FFFFFF),
    outlineVariant: Color(0x0FFFFFFF),
    inverseSurface: Color(0xFFF9F9F7),
    onInverseSurface: Color(0xFF1A1A19),
    inversePrimary: Color(0xFF8C3A67),
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
    Color? surfaceBright,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? onSurfaceMuted,
    Color? onSurfaceDisabled,
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
      surfaceBright: surfaceBright ?? this.surfaceBright,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      onSurfaceDisabled: onSurfaceDisabled ?? this.onSurfaceDisabled,
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
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      onSurfaceDisabled: Color.lerp(
        onSurfaceDisabled,
        other.onSurfaceDisabled,
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
