import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

const String thinkingIndicatorSnippet = '''
FlowThinkingIndicator(
  label: 'thinking..',
  active: generating, // false settles the asterisk upright
)''';

/// The turning, breathing asterisk with its shimmering label, on its own.
/// Settled parks the glyph upright and stills the label.
class ThinkingIndicatorDemo extends StatelessWidget {
  const ThinkingIndicatorDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlowThinkingIndicator(
        label: 'thinking..',
        active: variant != 'settled',
      ),
    );
  }
}
