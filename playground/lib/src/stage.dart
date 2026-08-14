import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'playground_item.dart';
import 'shell_palette.dart';

/// Which frame the canvas stages the demo in.
enum StageDevice { web, mobile }

/// The canvas: the warm-grey work area with the demo stage centred on it —
/// a fluid 860px rail in web mode, a phone mock in mobile mode. Demos are
/// not wired up yet, so both frames stage a quiet placeholder.
class Stage extends StatelessWidget {
  const Stage({super.key, required this.device, required this.item});

  final StageDevice device;
  final PlaygroundItem item;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return ColoredBox(
      color: shell.canvas,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Widget stage = device == StageDevice.web
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: _Placeholder(item: item),
                )
              : _PhoneStage(
                  // Keep the phone inside the pane on short windows.
                  maxHeight: constraints.maxHeight - 108,
                  child: _Placeholder(item: item),
                );
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 56, 28, 52),
              child: stage,
            ),
          );
        },
      ),
    );
  }
}

/// Stands in for the component demo the stage will hold next.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.item});

  final PlaygroundItem item;

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            style: shellText(
              size: 15,
              weight: FontWeight.w600,
              color: shell.navText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Component demo coming soon',
            style: shellText(
              size: 12.5,
              weight: FontWeight.w500,
              color: shell.sectionLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// The mobile stage: a dark bezel around a 376×766 screen, with the mock
/// status bar, "AI Chat" nav, dynamic island, side buttons and home
/// indicator — the phone is chrome; the demo goes on the screen.
class _PhoneStage extends StatelessWidget {
  const _PhoneStage({required this.child, required this.maxHeight});

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
                  Column(
                    children: [
                      const _StatusBar(),
                      const _MobileNav(),
                      Expanded(child: child),
                    ],
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
              Icon(Icons.wifi, size: 15, color: shell.text),
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
          Icon(Icons.arrow_back, size: 18, color: shell.navText),
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
          Icon(Icons.settings_outlined, size: 17, color: shell.navText),
        ],
      ),
    );
  }
}
