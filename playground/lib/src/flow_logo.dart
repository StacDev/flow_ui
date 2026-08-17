import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Flow UI mark (Figma node 308:94), rendered from the SVG asset: the
/// brand-pink spiral on its near-black rounded tile. The asset carries the
/// tile and its 20% corner, so the logo arrives complete at any size.
class FlowLogo extends StatelessWidget {
  const FlowLogo({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo/flow_ui_logo.svg',
      width: size,
      height: size,
    );
  }
}
