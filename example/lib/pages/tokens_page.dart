import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/section_header.dart';
import '../widgets/gallery_page.dart';

/// Renders every design token — the visual check for the theme layer.
class TokensPage extends StatelessWidget {
  const TokensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Design tokens',
      className: 'FlowTheme',
      description:
          'Every token the theme extension carries — colors, the type '
          'scale, spacing steps, and radii — in the current brightness.',
      children: [
        _ColorsSection(),
        _TypographySection(),
        _SpacingSection(),
        _RadiiSection(),
      ],
    );
  }
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final spacing = context.flowSpacing;

    final swatches = <String, Color>{
      'primary': colors.primary,
      'onPrimary': colors.onPrimary,
      'primaryContainer': colors.primaryContainer,
      'onPrimaryContainer': colors.onPrimaryContainer,
      'secondary': colors.secondary,
      'onSecondary': colors.onSecondary,
      'secondaryContainer': colors.secondaryContainer,
      'onSecondaryContainer': colors.onSecondaryContainer,
      'tertiary': colors.tertiary,
      'onTertiary': colors.onTertiary,
      'tertiaryContainer': colors.tertiaryContainer,
      'onTertiaryContainer': colors.onTertiaryContainer,
      'error': colors.error,
      'onError': colors.onError,
      'errorContainer': colors.errorContainer,
      'onErrorContainer': colors.onErrorContainer,
      'surface': colors.surface,
      'onSurface': colors.onSurface,
      'onSurfaceVariant': colors.onSurfaceVariant,
      'onSurfaceMuted': colors.onSurfaceMuted,
      'surfaceContainerLowest': colors.surfaceContainerLowest,
      'surfaceContainerLow': colors.surfaceContainerLow,
      'surfaceContainer': colors.surfaceContainer,
      'surfaceContainerHigh': colors.surfaceContainerHigh,
      'surfaceContainerHighest': colors.surfaceContainerHighest,
      'outline': colors.outline,
      'outlineVariant': colors.outlineVariant,
      'inverseSurface': colors.inverseSurface,
      'onInverseSurface': colors.onInverseSurface,
      'inversePrimary': colors.inversePrimary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Colors'),
        Wrap(
          spacing: spacing.md,
          runSpacing: spacing.md,
          children: [
            for (final entry in swatches.entries)
              _Swatch(name: entry.key, color: entry.value),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    return SizedBox(
      width: 148,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 148,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: context.flowRadii.sm,
              border: Border.all(color: colors.outlineVariant),
            ),
          ),
          SizedBox(height: context.flowSpacing.xs),
          Text(
            name,
            style: context.flowTypography.labelMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;

    final styles = <String, TextStyle>{
      'displayLarge': typography.displayLarge,
      'displayMedium': typography.displayMedium,
      'displaySmall': typography.displaySmall,
      'headlineLarge': typography.headlineLarge,
      'headlineMedium': typography.headlineMedium,
      'headlineSmall': typography.headlineSmall,
      'titleLarge': typography.titleLarge,
      'titleMedium': typography.titleMedium,
      'titleSmall': typography.titleSmall,
      'bodyLarge': typography.bodyLarge,
      'bodyMedium': typography.bodyMedium,
      'bodySmall': typography.bodySmall,
      'labelLarge': typography.labelLarge,
      'labelMedium': typography.labelMedium,
      'labelSmall': typography.labelSmall,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Typography'),
        for (final entry in styles.entries)
          Padding(
            padding: EdgeInsets.only(bottom: context.flowSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 128,
                  child: Text(
                    entry.key,
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'The quick brown fox jumps over the lazy dog',
                    style: entry.value.copyWith(color: colors.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final spacing = context.flowSpacing;

    final tokens = <String, double>{
      'xs': spacing.xs,
      'sm': spacing.sm,
      'md': spacing.md,
      'lg': spacing.lg,
      'xl': spacing.xl,
      'xxl': spacing.xxl,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Spacing'),
        for (final entry in tokens.entries)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 128,
                  child: Text(
                    '${entry.key} · ${entry.value.toStringAsFixed(0)}',
                    style: context.flowTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  width: entry.value * 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: context.flowRadii.sm,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RadiiSection extends StatelessWidget {
  const _RadiiSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final radii = context.flowRadii;

    final tokens = <String, BorderRadius>{
      'sm': radii.sm,
      'md': radii.md,
      'lg': radii.lg,
      'full': radii.full,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Radii'),
        Wrap(
          spacing: context.flowSpacing.md,
          runSpacing: context.flowSpacing.md,
          children: [
            for (final entry in tokens.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 96,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: entry.value,
                      border: Border.all(color: colors.outline),
                    ),
                  ),
                  SizedBox(height: context.flowSpacing.xs),
                  Text(
                    entry.key,
                    style: context.flowTypography.labelMedium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
