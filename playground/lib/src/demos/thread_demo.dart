import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

const String threadSnippet = '''
// A reversed, scrollable conversation — newest at the bottom. Give it
// bounded height; inside FlowChatScreen that comes for free.
SizedBox(
  height: 480,
  child: FlowThread(
    messages: messages,
    controller: scroll,
    thinkingLabel: 'thinking..',
  ),
)''';

const String _reply =
    'FlowThread lays the conversation out as a reversed list, so the '
    'newest message sits at the bottom and history loads upward. Messages '
    'keep their identity by id, which is what makes streaming updates '
    'cheap.';

List<FlowMessageData> _seed(bool streaming) => [
  FlowMessageData.text(
    id: 'u1',
    role: FlowMessageRole.user,
    text: 'What does FlowThread actually do?',
  ),
  FlowMessageData.text(
    id: 'a1',
    role: FlowMessageRole.assistant,
    text:
        'It renders the conversation: user bubbles on the ink wash, plain '
        'assistant prose, 32px apart.',
  ),
  FlowMessageData.text(
    id: 'u2',
    role: FlowMessageRole.user,
    text: 'And when a reply is still coming in?',
  ),
  FlowMessageData(
    id: 'a2',
    role: FlowMessageRole.assistant,
    parts: const [FlowTextPart(_reply)],
    status: streaming
        ? FlowMessageStatus.streaming
        : FlowMessageStatus.complete,
  ),
];

/// The conversation list on its own, at a bounded height. The Streaming
/// variant mounts the last reply mid-stream, so the reveal plays.
class ThreadDemo extends StatelessWidget {
  const ThreadDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SizedBox(
          height: 480,
          child: FlowThread(messages: _seed(variant == 'streaming')),
        ),
      ),
    );
  }
}
