import 'dart:async';
import 'dart:math';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _assembledSnippet = '''
// The screen supplies the bounded height FlowThread needs, so the
// thread wants no SizedBox of its own.
FlowChatScreen(
  thread: FlowThread(messages: messages, controller: controller),
  composer: FlowComposer(
    placeholder: 'Message…',
    isStreaming: generating,
    onSend: send,
    onStop: stop,
  ),
  // Pass the same controller to both: taking finished widgets means
  // the screen can't reach in and attach one itself.
  threadController: controller,
  jumpToLatestTooltip: 'Jump to latest',
)''';

const String _emptySnippet = '''
FlowChatScreen(
  thread: FlowThread(messages: messages),
  composer: FlowComposer(controller: input, onSend: send),
  // Starters sit above the composer and go once the thread has
  // something in it.
  aboveComposer: messages.isEmpty
      ? FlowSuggestionGroup(
          suggestions: [
            for (final prompt in starters)
              FlowSuggestion(
                label: prompt,
                onTap: () => input.text = prompt,
              ),
          ],
        )
      : null,
)''';

/// Demo for [FlowChatScreen].
class ChatScreenPage extends StatelessWidget {
  const ChatScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Chat screen',
      className: 'FlowChatScreen',
      description:
          'The assembled surface: a bounded thread above a composer, centred '
          'at a readable width. It takes finished widgets rather than their '
          'data, and builds no Scaffold — drop it in a scaffold body and the '
          'host keeps the app bar and the keyboard inset.',
      children: [
        SectionHeader('Assembled'),
        DemoPreview(
          preview: SizedBox(height: 520, child: _ChatDemo()),
          code: _assembledSnippet,
          minHeight: 520,
        ),
        SectionHeader('Empty state'),
        DemoPreview(
          preview: SizedBox(height: 420, child: _EmptyStateDemo()),
          code: _emptySnippet,
          minHeight: 420,
        ),
      ],
    );
  }
}

const String _reply =
    'FlowChatScreen owns the layout and nothing else — it puts the thread in '
    'an Expanded so the reversed list has a bounded height, caps the column '
    'at a readable width, and offers a jump-to-latest button once you have '
    'scrolled back through the history. The pieces inside it are the same '
    'FlowThread and FlowComposer you would use on their own.';

class _ChatDemo extends StatefulWidget {
  const _ChatDemo();

  @override
  State<_ChatDemo> createState() => _ChatDemoState();
}

class _ChatDemoState extends State<_ChatDemo> {
  final ScrollController _controller = ScrollController();
  final Random _random = Random();
  late List<FlowMessageData> _messages = _seed();
  bool _generating = false;
  Timer? _timer;
  int _nextId = 0;

  /// Enough history that the jump-to-latest button is reachable.
  List<FlowMessageData> _seed() => [
    for (var i = 0; i < 8; i++) ...[
      FlowMessageData.text(
        id: 'u$i',
        role: FlowMessageRole.user,
        text: 'Question ${i + 1} about the chat surface.',
      ),
      FlowMessageData.text(
        id: 'a$i',
        role: FlowMessageRole.assistant,
        text:
            'Answer ${i + 1}. Scroll up through this history and the '
            'jump-to-latest button fades in above the composer.',
      ),
    ],
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _send(String text) {
    _timer?.cancel();
    final id = 'sent${_nextId++}';
    setState(() {
      _messages = [
        ..._messages,
        FlowMessageData.text(id: id, role: FlowMessageRole.user, text: text),
        FlowMessageData(
          id: '$id-reply',
          role: FlowMessageRole.assistant,
          status: FlowMessageStatus.pending,
        ),
      ];
      _generating = true;
    });

    // Brief pending phase, then stream word chunks in — the same shape as
    // the Message & Thread page's live demo.
    _timer = Timer(const Duration(milliseconds: 700), () {
      final words = _reply.split(' ');
      var index = 0;
      var streamed = '';
      _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
        if (index >= words.length) {
          timer.cancel();
          setState(() {
            _generating = false;
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

  void _stop() {
    _timer?.cancel();
    setState(() {
      _generating = false;
      _messages = [
        ..._messages.sublist(0, _messages.length - 1),
        _messages.last.copyWith(status: FlowMessageStatus.complete),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlowChatScreen(
      thread: FlowThread(messages: _messages, controller: _controller),
      threadController: _controller,
      jumpToLatestTooltip: 'Jump to latest',
      composer: FlowComposer(
        placeholder: 'Message flow_ui…',
        isStreaming: _generating,
        onSend: _send,
        onStop: _stop,
      ),
    );
  }
}

class _EmptyStateDemo extends StatefulWidget {
  const _EmptyStateDemo();

  @override
  State<_EmptyStateDemo> createState() => _EmptyStateDemoState();
}

class _EmptyStateDemoState extends State<_EmptyStateDemo> {
  static const List<String> _starters = [
    'Plan a weekend trip',
    'Explain this error',
    'Draft a reply',
    'Summarize a document',
  ];

  final TextEditingController _input = TextEditingController();
  List<FlowMessageData> _messages = const [];
  int _nextId = 0;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empty = _messages.isEmpty;
    return FlowChatScreen(
      thread: FlowThread(messages: _messages),
      // Starters go once the thread has a message in it.
      aboveComposer: empty
          ? FlowSuggestionGroup(
              suggestions: [
                for (final prompt in _starters)
                  FlowSuggestion(
                    label: prompt,
                    onTap: () => _input.text = prompt,
                  ),
              ],
            )
          : Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _messages = const []),
                child: const Text('Show starters again'),
              ),
            ),
      composer: FlowComposer(
        controller: _input,
        placeholder: 'Ask anything…',
        onSend: (text) => setState(() {
          _messages = [
            ..._messages,
            FlowMessageData.text(
              id: 'm${_nextId++}',
              role: FlowMessageRole.user,
              text: text,
            ),
          ];
        }),
      ),
    );
  }
}
