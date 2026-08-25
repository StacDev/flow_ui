import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// A chrome text style in Google Sans, fetched through google_fonts like the
/// library's own scale. The chrome keeps its bespoke sizes from the Claude
/// Design prototype and colors them from flow_ui's color tokens.
TextStyle shellText({
  double? size,
  FontWeight? weight,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.googleSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}
