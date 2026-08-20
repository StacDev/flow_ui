import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

const String threadSnippet = '''
// A reversed, scrollable conversation — newest at the bottom. Give it
// bounded height; inside FlowChatView that comes for free.
SizedBox(
  height: 480,
  child: FlowThread(
    messages: messages,
    controller: scroll,
    thinkingLabel: 'thinking..',
    // Code parts render FlowCodeBlocks; copy hands the part back, and
    // the host passes it along while its confirmation lasts.
    codeCopyTooltip: 'Copy code',
    copiedCodePart: copiedPart,
    onCodeCopy: copyPart,
  ),
)''';

const String _reply =
    'FlowThread lays the conversation out as a reversed list, so the '
    'newest message sits at the bottom and history loads upward. Messages '
    'keep their identity by id, which is what makes streaming updates '
    'cheap. Give it bounded height and it does the rest:';

const String _replyCode = '''
SizedBox(
  height: 480,
  child: FlowThread(
    messages: messages,
    controller: scroll,
  ),
)''';

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
    // Prose then code: the reveal plays on the text part, while the code
    // part renders whole — and hides its copy affordance mid-stream.
    parts: const [
      FlowTextPart(_reply),
      FlowCodePart(_replyCode, language: 'dart'),
    ],
    status: streaming
        ? FlowMessageStatus.streaming
        : FlowMessageStatus.complete,
  ),
];

/// The conversation list on its own, at a bounded height, closing on a
/// reply that carries a code part. The Streaming variant mounts that
/// reply mid-stream, so the text reveal plays above the code block. The
/// demo owns the clipboard write and the copied confirmation, the way a
/// host would.
class ThreadDemo extends StatefulWidget {
  const ThreadDemo({super.key, this.variant});

  final String? variant;

  @override
  State<ThreadDemo> createState() => _ThreadDemoState();
}

class _ThreadDemoState extends State<ThreadDemo> {
  FlowCodePart? _copiedPart;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy(FlowCodePart part) async {
    await Clipboard.setData(ClipboardData(text: part.code));
    if (!mounted) return;
    setState(() => _copiedPart = part);
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copiedPart = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SizedBox(
          height: 480,
          child: FlowThread(
            messages: _seed(widget.variant == 'streaming'),
            codeCopyTooltip: 'Copy code',
            copiedCodePart: _copiedPart,
            onCodeCopy: _copy,
          ),
        ),
      ),
    );
  }
}
