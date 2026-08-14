import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'demo_registry.dart';
import 'playground_item.dart';
import 'shell_palette.dart';

/// Which frame the canvas stages the demo in.
enum StageDevice { web, mobile }

/// The canvas: the warm-grey work area with the demo stage centred on it —
/// a fluid rail in web mode, a phone mock in mobile mode — and, for items
/// with variants, the floating pill switcher over the top edge.
class Stage extends StatelessWidget {
  const Stage({
    super.key,
    required this.device,
    required this.item,
    this.variant,
    this.onVariantChanged,
  });

  final StageDevice device;
  final PlaygroundItem item;
  final String? variant;
  final ValueChanged<String>? onVariantChanged;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);
    final demo = demoFor(item, variant: variant);
    final variants = variantsFor(item);

    final Widget content;
    if (device == StageDevice.web) {
      // A full-surface demo (the chat) owns the whole pane; object demos
      // sit centred on the canvas.
      content = demoFillsStage(item)
          ? demo
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 56, 28, 52),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: demo,
                ),
              ),
            );
    } else {
      content = LayoutBuilder(
        builder: (context, constraints) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 56, 28, 52),
            child: _PhoneStage(
              // Remount the phone when the component changes, so routes a
              // demo pushed on the inner navigator (sheets, menus) don't
              // linger over the next demo — a fresh stage per component,
              // like the web canvas.
              key: ObjectKey(item),
              // Keep the phone inside the pane on short windows.
              maxHeight: constraints.maxHeight - 108,
              // On the phone screen, object demos centre with room to
              // breathe; full surfaces keep filling it.
              child: demoFillsStage(item)
                  ? demo
                  : Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: demo,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: shell.canvas,
      child: Stack(
        children: [
          Positioned.fill(child: content),
          if (variants.isNotEmpty)
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: _VariantPills(
                  variants: variants,
                  selected: variant ?? variants.first.$1,
                  onSelect: onVariantChanged ?? (_) {},
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The design's floating variant switcher, over the canvas top edge.
class _VariantPills extends StatelessWidget {
  const _VariantPills({
    required this.variants,
    required this.selected,
    required this.onSelect,
  });

  final List<(String, String)> variants;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: shell.topBarBg,
        border: Border.all(color: shell.pillBorder),
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, (id, label)) in variants.indexed) ...[
            if (i > 0) const SizedBox(width: 2),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onSelect(id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: id == selected ? shell.chip : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  child: Text(
                    label,
                    style: shellText(
                      size: 12.5,
                      weight: FontWeight.w500,
                      color: id == selected ? shell.text : shell.segmentRest,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The mobile stage: a dark bezel around a 376×766 screen, with the mock
/// status bar, "AI Chat" nav, dynamic island, side buttons and home
/// indicator — the phone is chrome; the demo goes on the screen.
class _PhoneStage extends StatelessWidget {
  const _PhoneStage({super.key, required this.child, required this.maxHeight});

  final Widget child;
  final double maxHeight;

  static const double _screenWidth = 376;
  static const double _screenHeight = 766;
  static const double _bezel = 9;
  static const double _outerRadius = 56;
  static const Color _bezelColor = Color(0xFF0B0B0C);
  static const Color _buttonColor = Color(0xFF2E2E30);

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = math
        .min(_screenHeight, math.max(320, maxHeight - _bezel * 2))
        .toDouble();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Volume and power buttons on the bezel's edges.
        for (final (top, height) in const [
          (112.0, 26.0),
          (160.0, 48.0),
          (218.0, 48.0),
        ])
          Positioned(
            left: -2,
            top: top,
            child: Container(
              width: 3,
              height: height,
              decoration: const BoxDecoration(
                color: _buttonColor,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(2)),
              ),
            ),
          ),
        Positioned(
          right: -2,
          top: 180,
          child: Container(
            width: 3,
            height: 76,
            decoration: const BoxDecoration(
              color: _buttonColor,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(_bezel),
          decoration: BoxDecoration(
            color: _bezelColor,
            borderRadius: BorderRadius.circular(_outerRadius),
            boxShadow: [
              if (dark)
                const BoxShadow(color: Color(0x1FFFFFFF), spreadRadius: 1.5),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, dark ? 0.55 : 0.28),
                offset: const Offset(0, 30),
                blurRadius: 80,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_outerRadius - _bezel),
            child: Container(
              width: _screenWidth,
              height: screenHeight,
              color: shell.stageBg,
              child: Stack(
                children: [
                  // The screen reports a phone: its size override makes
                  // width-responsive demos take their compact branch, the
                  // platform override makes platform-adaptive menus present
                  // as sheets, and the nested Navigator keeps those sheets
                  // inside the frame instead of over the whole window.
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(_screenWidth, screenHeight),
                      padding: EdgeInsets.zero,
                      viewPadding: EdgeInsets.zero,
                      viewInsets: EdgeInsets.zero,
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(platform: TargetPlatform.iOS),
                      child: _PhoneScreenScope(
                        demo: child,
                        child: Navigator(
                          onGenerateRoute: (settings) =>
                              MaterialPageRoute<void>(
                                settings: settings,
                                // The navigator generates this route once and
                                // keeps its builder for the route's lifetime,
                                // so nothing per-build may be captured here:
                                // the demo and palette are read through
                                // `context` so component, variant, and theme
                                // changes reach the screen.
                                builder: (context) => Material(
                                  color: ShellPalette.of(context).stageBg,
                                  child: Column(
                                    children: [
                                      const _StatusBar(),
                                      const _MobileNav(),
                                      Expanded(
                                        child: _PhoneScreenScope.demoOf(
                                          context,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  // Dynamic island.
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 96,
                        height: 27,
                        decoration: const BoxDecoration(
                          color: Color(0xFF050505),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                  // Home indicator.
                  Positioned(
                    bottom: 9,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 118,
                        height: 4,
                        decoration: BoxDecoration(
                          color: shell.text.withValues(alpha: 0.9),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hands the stage's current demo through to the phone screen's route.
///
/// Rebuilding the [Navigator] widget never regenerates a live route, so the
/// route content can't receive the demo as a closure capture — it would stay
/// frozen at whatever was staged first. Instead the scope above the navigator
/// carries the latest demo, and the route content depends on it, rebuilding
/// whenever the stage stages something new.
class _PhoneScreenScope extends InheritedWidget {
  const _PhoneScreenScope({required this.demo, required super.child});

  final Widget demo;

  static Widget demoOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PhoneScreenScope>()!.demo;

  @override
  bool updateShouldNotify(_PhoneScreenScope oldWidget) =>
      demo != oldWidget.demo;
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 16, 26, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: shellText(
              size: 14.5,
              weight: FontWeight.w600,
              letterSpacing: 0.15,
              color: shell.text,
            ),
          ),
          Row(
            children: [
              // Signal bars.
              for (final height in const [4.0, 6.0, 8.0, 10.0])
                Container(
                  width: 3,
                  height: height,
                  margin: const EdgeInsetsDirectional.only(start: 1.5),
                  decoration: BoxDecoration(
                    color: shell.text,
                    borderRadius: const BorderRadius.all(Radius.circular(1)),
                  ),
                ),
              const SizedBox(width: 6),
              Icon(PhosphorIconsRegular.wifiHigh, size: 15, color: shell.text),
              const SizedBox(width: 6),
              // Battery.
              Container(
                width: 22,
                height: 11,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  border: Border.all(color: shell.text, width: 1.5),
                  borderRadius: const BorderRadius.all(Radius.circular(3.5)),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: shell.text,
                    borderRadius: const BorderRadius.all(Radius.circular(1.5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileNav extends StatelessWidget {
  const _MobileNav();

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: shell.border)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.arrowLeft, size: 18, color: shell.navText),
          const SizedBox(width: 12),
          Text(
            'AI Chat',
            style: shellText(
              size: 16,
              weight: FontWeight.w600,
              color: shell.text,
            ),
          ),
          const Spacer(),
          Icon(PhosphorIconsRegular.gearSix, size: 17, color: shell.navText),
        ],
      ),
    );
  }
}
