import 'dart:async';
import 'dart:math';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _conversationSnippet = '''
FlowThread(
  messages: [
    FlowMessageData.text(
      id: '1',
      role: FlowMessageRole.user,
      text: 'What is flow_ui?',
    ),
    FlowMessageData.text(
      id: '2',
      role: FlowMessageRole.assistant,
      text: 'An assistant UI component library for Flutter...',
    ),
    FlowMessageData.text(
      id: '3',
      role: FlowMessageRole.system,
      text: 'Model changed to Sonnet',
    ),
  ],
)''';

const String _liveSnippet = '''
// Streaming is data, not streams: rebuild with updated
// messages as chunks arrive.
FlowThread(
  messages: [
    ...history,
    FlowMessageData(
      id: 'reply',
      role: FlowMessageRole.assistant,
      parts: [FlowTextPart(streamedSoFar)],
      status: FlowMessageStatus.streaming, // pending → streaming → complete
    ),
  ],
)''';

const String _statesSnippet = '''
// Pending: loading dots until the first token arrives.
FlowMessage(
  FlowMessageData(
    id: 'p',
    role: FlowMessageRole.assistant,
    status: FlowMessageStatus.pending,
  ),
)

// Error: content in an error bubble.
FlowMessage(
  FlowMessageData.text(
    id: 'e',
    role: FlowMessageRole.assistant,
    text: 'Something went wrong while generating a response.',
    status: FlowMessageStatus.error,
  ),
)''';

/// Demo for [FlowMessage] and [FlowThread].
class MessageThreadPage extends StatelessWidget {
  const MessageThreadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Message & Thread',
      className: 'FlowMessage · FlowThread',
      description:
          'Conversation rendering from plain message data — user, assistant, '
          'and system roles, live streaming, and the pending and error '
          'states.',
      children: [
        SectionHeader('Conversation'),
        DemoPreview(
          preview: SizedBox(height: 300, child: _ConversationDemo()),
          code: _conversationSnippet,
        ),
        SectionHeader('Live thread'),
        DemoPreview(preview: _LiveThreadDemo(), code: _liveSnippet),
        SectionHeader('States'),
        DemoPreview(preview: _StatesDemo(), code: _statesSnippet),
      ],
    );
  }
}

class _ConversationDemo extends StatelessWidget {
  const _ConversationDemo();

  @override
  Widget build(BuildContext context) {
    return FlowThread(
      padding: EdgeInsets.zero,
      messages: [
        FlowMessageData.text(
          id: '1',
          role: FlowMessageRole.user,
          text: 'What is flow_ui?',
        ),
        FlowMessageData.text(
          id: '2',
          role: FlowMessageRole.assistant,
          text:
              'An assistant UI component library for Flutter — it renders '
              'conversation state and reports intent through callbacks, with '
              'no model awareness and no third-party dependencies.',
        ),
        FlowMessageData.text(
          id: '3',
          role: FlowMessageRole.system,
          text: 'Model changed to Sonnet',
        ),
        FlowMessageData.text(
          id: '4',
          role: FlowMessageRole.user,
          text: 'Nice — and which pieces exist today?',
        ),
        FlowMessageData.text(
          id: '5',
          role: FlowMessageRole.assistant,
          text:
              'The theme tokens, streaming text, the loading indicator, '
              'and now messages and threads.',
        ),
      ],
    );
  }
}

class _LiveThreadDemo extends StatefulWidget {
  const _LiveThreadDemo();

  @override
  State<_LiveThreadDemo> createState() => _LiveThreadDemoState();
}

class _LiveThreadDemoState extends State<_LiveThreadDemo> {
  static const String _reply =
      'Sure. FlowThread is a bottom-anchored list of FlowMessageData view models, '
      'and each message renders its parts through FlowMessage — pending '
      'replies show the loading dots, streaming text animates in through '
      'FlowStreamingText, and settled history renders statically. Rebuild '
      'with new message data and the thread keeps itself pinned to the '
      'newest content.';

  final Random _random = Random();
  List<FlowMessageData> _messages = const [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _replay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _replay() {
    _timer?.cancel();
    setState(() {
      _messages = [
        FlowMessageData.text(
          id: 'u1',
          role: FlowMessageRole.user,
          text: 'How does the thread handle a streaming reply?',
        ),
        const FlowMessageData(
          id: 'a1',
          role: FlowMessageRole.assistant,
          status: FlowMessageStatus.pending,
        ),
      ];
    });

    // Brief pending phase, then stream word chunks in.
    _timer = Timer(const Duration(milliseconds: 900), () {
      final words = _reply.split(' ');
      var index = 0;
      var streamed = '';
      _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
        if (index >= words.length) {
          timer.cancel();
          setState(() {
            _messages = [
              ..._messages.sublist(0, _messages.length - 1),
              _messages.last.copyWith(status: FlowMessageStatus.complete),
            ];
          });
          return;
        }
        final take = min(1 + _random.nextInt(3), words.length - index);
        streamed += '${words.sublist(index, index + take).join(' ')} ';
        index += take;
        setState(() {
          _messages = [
            ..._messages.sublist(0, _messages.length - 1),
            _messages.last.copyWith(
              parts: [FlowTextPart(streamed)],
              status: FlowMessageStatus.streaming,
            ),
          ];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: _replay,
          icon: const Icon(Icons.replay),
          label: const Text('Replay'),
        ),
        SizedBox(height: context.flowSpacing.md),
        SizedBox(
          height: 300,
          child: FlowThread(padding: EdgeInsets.zero, messages: _messages),
        ),
      ],
    );
  }
}

class _StatesDemo extends StatelessWidget {
  const _StatesDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FlowMessage(
          FlowMessageData(
            id: 'p',
            role: FlowMessageRole.assistant,
            status: FlowMessageStatus.pending,
          ),
        ),
        SizedBox(height: context.flowSpacing.lg),
        FlowMessage(
          FlowMessageData.text(
            id: 'e',
            role: FlowMessageRole.assistant,
            text: 'Something went wrong while generating a response.',
            status: FlowMessageStatus.error,
          ),
        ),
      ],
    );
  }
}
