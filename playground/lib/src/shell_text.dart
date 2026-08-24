import 'package:material_ui/material_ui.dart';

/// A chrome text style in Figtree (bundled by flow_ui). The chrome keeps
/// its own bespoke sizes from the Claude Design prototype, but draws them
/// in the package's face and colors them from [FlowColors] tokens.
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
