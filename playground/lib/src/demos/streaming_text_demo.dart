import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

String streamingTextSnippet([String? variant]) => switch (variant) {
  'instant' => _instantSnip,
  _ => _animatedSnip,
};

const String _animatedSnip = '''
FlowStreamingText(
  text: streamedSoFar, // append as chunks arrive
  isStreaming: true,
  charactersPerSecond: 300,
)''';

const String _instantSnip = '''
FlowStreamingText(
  text: fullReply,
  isStreaming: false, // settles the reveal instantly — history at rest
)''';

const String _passage =
    'FlowStreamingText reveals its text at a steady character rate, so a '
    'reply arriving in uneven network chunks still reads as one calm, '
    'continuous stream. When streaming ends, whatever is still queued '
    'settles instantly instead of dribbling out.';

/// The animated reveal on its own. Animated mounts mid-stream and plays;
/// Instant renders the same text already settled.
class StreamingTextDemo extends StatelessWidget {
  const StreamingTextDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: FlowStreamingText(
          text: _passage,
          isStreaming: variant != 'instant',
        ),
      ),
    );
  }
}
