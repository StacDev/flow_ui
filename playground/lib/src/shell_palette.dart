import 'package:flutter/material.dart';

/// The playground's accent — the design's pink, drawn on the logo tile and
/// the active sidebar icon.
const Color shellAccent = Color(0xFFED74A9);

/// A chrome text style in Figtree (bundled by flow_ui).
TextStyle shellText({
  double? size,
  FontWeight? weight,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Figtree',
    package: 'flow_ui',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// The playground chrome's own palette, straight from the Claude Design
/// prototype — deliberately separate from flow_ui's tokens: the chrome is
/// the workbench, not the exhibit.
@immutable
class ShellPalette {
  const ShellPalette({
    required this.topBarBg,
    required this.sidebarBg,
    required this.border,
    required this.chip,
    required this.segmentActiveBg,
    required this.segmentShadow,
    required this.text,
    required this.sectionLabel,
    required this.iconRest,
    required this.segmentRest,
    required this.navText,
    required this.navHover,
    required this.navActiveBg,
    required this.canvas,
    required this.stageBg,
    required this.codeBg,
    required this.codeHeaderBg,
    required this.codeBorder,
    required this.codeHeaderText,
    required this.codeText,
    required this.codeChip,
  });

  final Color topBarBg;
  final Color sidebarBg;
  final Color border;
  final Color chip;
  final Color segmentActiveBg;
  final Color segmentShadow;
  final Color text;
  final Color sectionLabel;
  final Color iconRest;
  final Color segmentRest;
  final Color navText;
  final Color navHover;
  final Color navActiveBg;
  final Color canvas;
  final Color stageBg;
  final Color codeBg;
  final Color codeHeaderBg;
  final Color codeBorder;
  final Color codeHeaderText;
  final Color codeText;
  final Color codeChip;

  static const ShellPalette light = ShellPalette(
    topBarBg: Color(0xFFFFFFFF),
    sidebarBg: Color(0xFFFCFBFA),
    border: Color(0xFFECEBE7),
    chip: Color(0xFFF2F1ED),
    segmentActiveBg: Color(0xFFFFFFFF),
    segmentShadow: Color(0x1A000000),
    text: Color(0xFF1F1E1B),
    sectionLabel: Color(0xFFABA9A2),
    iconRest: Color(0xFFABA9A2),
    segmentRest: Color(0xFF76746E),
    navText: Color(0xFF55534E),
    navHover: Color(0xFFF4F3EF),
    navActiveBg: Color(0xFFF1F0EC),
    canvas: Color(0xFFF0EFEA),
    stageBg: Color(0xFFF5F4F1),
    codeBg: Color(0xFFFFFFFF),
    codeHeaderBg: Color(0xFFFBFAF8),
    codeBorder: Color(0xFFEFEEE9),
    codeHeaderText: Color(0xFF8E8C86),
    codeText: Color(0xFF3B3A35),
    codeChip: Color(0xFFF2F1ED),
  );

  static const ShellPalette dark = ShellPalette(
    topBarBg: Color(0xFF1E1D1B),
    sidebarBg: Color(0xFF1A1917),
    border: Color(0xFF31302C),
    chip: Color(0xFF2C2B29),
    segmentActiveBg: Color(0xFF403E3A),
    segmentShadow: Color(0x59000000),
    text: Color(0xFFEDECE8),
    sectionLabel: Color(0xFF787670),
    iconRest: Color(0xFF8A8881),
    segmentRest: Color(0xFF9C9A93),
    navText: Color(0xFFC6C4BE),
    navHover: Color(0xFF2A2927),
    navActiveBg: Color(0xFF2E2D2A),
    canvas: Color(0xFF131211),
    stageBg: Color(0xFF1A1918),
    codeBg: Color(0xFF181715),
    codeHeaderBg: Color(0x05FFFFFF),
    codeBorder: Color(0x12FFFFFF),
    codeHeaderText: Color(0xFF8F8D86),
    codeText: Color(0xFFD8D6D0),
    codeChip: Color(0x17FFFFFF),
  );

  static ShellPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
