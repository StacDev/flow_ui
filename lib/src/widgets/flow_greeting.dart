import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';

/// The zero state's headline — "Good afternoon, …" over a thread nobody has
/// spoken in yet, usually through `FlowChatScreen.greeting`:
///
/// ```dart
/// FlowGreeting(
///   icon: Icons.wb_twilight,
///   text: 'Good Afternoon, Divyanshu',
/// )
/// ```
///
/// Two forms, switched on the width available: a row — the glyph beside the
/// text, bottom-aligned — where there is room, and a stacked column with
/// smaller text on compact screens. [text] is the whole message; the package
/// ships no strings and does not derive one from the time of day.
class FlowGreeting extends StatelessWidget {
  const FlowGreeting({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
    this.textStyle,
  });

  /// The greeting, ready to show.
  final String text;

  /// Optional glyph — the design draws a sun on the horizon.
  final IconData? icon;

  /// Defaults to [FlowColors.primary], which is how the design keeps its
  /// accent in the glyph in both themes.
  final Color? iconColor;

  /// Defaults to `headlineLarge` in the row form, and the same style at the
  /// design's 21 in the stacked form. An explicit style is used as given in
  /// both.
  final TextStyle? textStyle;

  /// The design's title: a 40px glyph, beside 32px text on wide screens —
  /// 16 apart, bottom-aligned — and above 21px text on compact ones, 4
  /// apart. The 21 sits between the type scale's steps, so it stays here as
  /// drawn. Compact begins below 600, Material's compact/medium boundary.
  static const double _iconSize = 40;
  static const double _wideGap = 16;
  static const double _narrowGap = 4;
  static const double _narrowFontSize = 21;
  static const double _compactBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < _compactBreakpoint;
        final style =
            textStyle ??
            context.flowTypography.headlineLarge.copyWith(
              color: colors.onSurface,
              fontSize: compact ? _narrowFontSize : null,
            );
        final label = Text(text, style: style, textAlign: TextAlign.center);
        if (icon == null) return label;

        final glyph = Icon(
          icon,
          size: _iconSize,
          color: iconColor ?? colors.primary,
        );
        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              glyph,
              const SizedBox(height: _narrowGap),
              label,
            ],
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            glyph,
            const SizedBox(width: _wideGap),
            label,
          ],
        );
      },
    );
  }
}
