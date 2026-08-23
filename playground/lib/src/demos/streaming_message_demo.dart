import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

String streamingMessageSnippet([String? variant]) => switch (variant) {
  'static' => _static,
  _ => _animated,
};

const String _static = '''
// Settled: active: false parks the asterisk upright and stills the
// shimmering label — the waiting state, at rest.
FlowThinkingIndicator(
  label: 'thinking..',
  active: false,
)''';

const String _animated = '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    FlowMessage(
      FlowMessageData.text(
        id: 'u1',
        role: FlowMessageRole.user,
        text: 'Can you tell me more about what you can do?',
      ),
    ),
    const SizedBox(height: 30),
    // The waiting state: a turning, breathing asterisk with a
    // shimmering label. `active: false` settles both.
    FlowThinkingIndicator(
      label: 'thinking..',
      active: generating,
    ),
  ],
)''';

/// The waiting moment from the design: the user's bubble with the
/// thinking indicator beneath it. The Static variant settles the
/// asterisk and stills the label's shimmer.
class StreamingMessageDemo extends StatelessWidget {
  const StreamingMessageDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlowMessage(
              FlowMessageData.text(
                id: 'u1',
                role: FlowMessageRole.user,
                text: 'Can you tell me more about what you can do?',
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FlowThinkingIndicator(
                label: 'thinking..',
                active: variant != 'static',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
