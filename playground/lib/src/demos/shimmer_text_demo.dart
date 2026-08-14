import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

const String shimmerTextSnippet = '''
FlowShimmerText(
  text: 'Searching the web..',
  enabled: waiting, // false parks the text in the muted base ink
)''';

/// The sweeping highlight on waiting text — the thinking indicator's
/// label, usable anywhere. Settled stills the sweep.
class ShimmerTextDemo extends StatelessWidget {
  const ShimmerTextDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlowShimmerText(
        text: 'Searching the web..',
        enabled: variant != 'settled',
      ),
    );
  }
}
