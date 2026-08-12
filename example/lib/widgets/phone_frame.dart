import 'dart:math' as math;

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'gallery_scope.dart';

/// Wraps a page body: untouched in web view, centered inside a [PhoneFrame]
/// when [GalleryScope.mobileView] is on.
///
/// One widget so the mobile framing is identical on every page.
class ViewportBody extends StatelessWidget {
  const ViewportBody({super.key, required this.child});

  /// The page content — typically the page's ListView.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!GalleryScope.of(context).mobileView) return child;
    // A tinted backdrop, or the phone screen would be surface-on-surface
    // and only the bezel would separate the two.
    return ColoredBox(
      color: context.flowColors.surfaceContainerLow,
      child: Center(child: PhoneFrame(child: child)),
    );
  }
}

/// Example-only device chrome: a bezel, a mock status bar, and a 390dp
/// screen whose [MediaQuery] reports a phone.
///
/// The size override means anything reading `MediaQuery.sizeOf` inside the
/// frame sees a phone-sized viewport, so future width-responsive widgets
/// take their mobile branch in here for free.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  /// The screen content.
  final Widget child;

  static const double _screenWidth = 390;
  static const double _screenHeight = 780;
  static const double _bezel = 6;
  static const double _outerRadius = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final spacing = context.flowSpacing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      // Room for the drop shadow, which reaches well past the bezel.
      padding: EdgeInsets.all(spacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = math.min(
            _screenWidth,
            constraints.maxWidth - _bezel * 2,
          );
          final screenH = math.min(
            _screenHeight,
            constraints.maxHeight - _bezel * 2,
          );
          return Container(
            // Padding rather than a border: a Border paints inside the box
            // and would shrink the screen below the size MediaQuery claims.
            padding: const EdgeInsets.all(_bezel),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: isDark ? 0.16 : 0.12),
              borderRadius: BorderRadius.circular(_outerRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_outerRadius - _bezel),
              child: Container(
                width: screenW,
                height: screenH,
                color: colors.surface,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: Size(screenW, screenH),
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: Column(
                    children: [
                      const _StatusBar(),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The mock status bar across the top of the phone screen.
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    return SizedBox(
      height: 38,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 24, 4),
        child: Row(
          children: [
            Text(
              '9:41',
              style: context.flowTypography.labelLarge.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.signal_cellular_alt_rounded,
              size: 14,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Icon(Icons.wifi_rounded, size: 14, color: colors.onSurfaceVariant),
            const SizedBox(width: 6),
            // Material draws the battery upright; a status bar wants it
            // lying down.
            Transform.rotate(
              angle: math.pi / 2,
              child: Icon(
                Icons.battery_full_rounded,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
