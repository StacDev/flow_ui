import 'dart:async';
import 'dart:math';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/gallery_page.dart';

/// Demo for [FlowChatScreen].
///
/// Fills the pane rather than sitting in a demo card: a surface boxed into a
/// fixed-height `SizedBox` would be hiding the very thing it exists to do.
class ChatScreenPage extends StatelessWidget {
  const ChatScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage.filling(
      title: 'Chat screen',
      className: 'FlowChatScreen',
      child: _ChatDemo(),
    );
  }
}

const String _reply =
    'FlowChatScreen owns the layout and nothing else — it puts the thread in '
    'an Expanded so the reversed list has a bounded height, caps the column '
    'at a readable width, and offers a jump-to-latest button once you have '
    'scrolled back through the history. The pieces inside it are the same '
    'FlowThread and FlowComposer you would use on their own.';

const List<String> _starters = [
  'Plan a weekend trip',
  'Explain this error',
  'Draft a reply',
  'Summarize a document',
];

class _ChatDemo extends StatefulWidget {
  const _ChatDemo();

  @override
  State<_ChatDemo> createState() => _ChatDemoState();
}

class _ChatDemoState extends State<_ChatDemo> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _input = TextEditingController();
  final Random _random = Random();
  late List<FlowMessageData> _messages = _seed();
  bool _generating = false;
  Timer? _timer;
  bool _researchOn = false;
  String _modelId = 'fable-5';
  String _effortId = 'medium';
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
    _input.dispose();
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
    final empty = _messages.isEmpty;
    return FlowChatScreen(
      // The header slot: here it just switches the demo between a seeded
      // thread and an empty one, so both states are reachable in the one
      // surface rather than needing two cards.
      header: _DemoHeader(
        empty: empty,
        onToggle: () {
          _timer?.cancel();
          setState(() {
            _generating = false;
            _messages = empty ? _seed() : const [];
          });
        },
      ),
      thread: FlowThread(
        messages: _messages,
        controller: _controller,
        thinkingLabel: 'Thinking…',
      ),
      threadController: _controller,
      jumpToLatestTooltip: 'Jump to latest',
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
          : null,
      composer: FlowComposer(
        controller: _input,
        placeholder: 'Message flow_ui…',
        isStreaming: _generating,
        onSend: _send,
        onStop: _stop,
        // Presentation is left on `auto`: anchored menus out here, bottom
        // sheets inside the phone frame, which reports a mobile platform.
        leadingActions: [
          FlowMenu(
            icon: Icons.add,
            tooltip: 'Add to chat',
            sheetTitle: 'Add to Chat',
            entries: [
              const FlowMenuOption(
                id: 'files',
                icon: Icons.upload_file_outlined,
                label: 'Add Files or Photos',
              ),
              const FlowMenuDivider(),
              FlowMenuOption(
                id: 'research',
                icon: Icons.school_outlined,
                label: 'Research',
                selected: _researchOn,
              ),
              const FlowMenuOption(
                id: 'web-search',
                icon: Icons.language_outlined,
                label: 'Web Search',
              ),
            ],
            onSelected: (id) {
              if (id == 'research') {
                setState(() => _researchOn = !_researchOn);
              }
            },
          ),
        ],
        trailingActions: [
          FlowModelSelector(
            tooltip: 'Choose model',
            sheetTitle: 'Select model',
            models: const [
              FlowModelOption(
                id: 'fable-5',
                label: 'Fable 5',
                description: 'Our flagship model',
              ),
              FlowModelOption(
                id: 'haiku-4-5',
                label: 'Haiku 4.5',
                description: 'Fastest for quick answers',
              ),
            ],
            selectedId: _modelId,
            onSelected: (id) => setState(() => _modelId = id),
            efforts: const [
              FlowEffortOption(
                id: 'medium',
                label: 'Medium',
                description: 'Light & casual tasks',
              ),
              FlowEffortOption(
                id: 'high',
                label: 'High',
                description: 'Balance between speed & complexity',
              ),
            ],
            selectedEffortId: _effortId,
            onEffortSelected: (id) => setState(() => _effortId = id),
          ),
        ],
      ),
    );
  }
}

class _DemoHeader extends StatelessWidget {
  const _DemoHeader({required this.empty, required this.onToggle});

  final bool empty;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final spacing = context.flowSpacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.sm, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              empty
                  ? 'Empty thread — starters sit above the composer.'
                  : 'Scroll back for the jump-to-latest button.',
              style: context.flowTypography.bodySmall.copyWith(
                color: context.flowColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(empty ? 'Load history' : 'Clear thread'),
          ),
        ],
      ),
    );
  }
}
