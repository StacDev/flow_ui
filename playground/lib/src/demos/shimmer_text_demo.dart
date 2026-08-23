import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

String shimmerTextSnippet([String? variant]) => switch (variant) {
  'settled' => _settledSnip,
  _ => _activeSnip,
};

const String _activeSnip = '''
FlowShimmerText(
  text: 'Searching the web..',
  enabled: true, // the sweeping highlight, while work is under way
)''';

const String _settledSnip = '''
FlowShimmerText(
  text: 'Searching the web..',
  enabled: false, // parks the text in the muted base ink
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
