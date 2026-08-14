import 'dart:async';
import 'dart:math';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// The canned reply, per the design prototype.
const String _reply =
    'I can assist you with most tasks across this app — changing your name, '
    'booking a hotel, or getting a cab. What else can I do for you today? '
    'If you need anything else, just type it out.';

/// The zero state's starters, per the design.
const List<(IconData, String)> _starters = [
  (
    PhosphorIconsRegular.articleNyTimes,
    'Write an essay about life and enjoyment',
  ),
  (
    PhosphorIconsRegular.calendarCheck,
    'Create a Monday briefing about my tasks and meetings',
  ),
  (PhosphorIconsRegular.magnifyingGlass, 'Suggest a new venture for me'),
];

/// The Full Chat example: a whole conversation surface on [FlowChatScreen],
/// live — starts in the zero state, sends for real, streams a canned reply
/// behind the thinking indicator, and carries the add and model menus.
class FullChatDemo extends StatefulWidget {
  const FullChatDemo({super.key});

  @override
  State<FullChatDemo> createState() => _FullChatDemoState();
}

class _FullChatDemoState extends State<FullChatDemo> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _input = TextEditingController();
  final Random _random = Random();
  List<FlowMessageData> _messages = const [];
  bool _generating = false;
  Timer? _timer;
  bool _researchOn = true;
  bool _webSearchOn = false;
  String _modelId = 'opus-5-1';
  String _effortId = 'extra';
  int _nextId = 0;

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

    // A thinking beat, then the reply streams in word chunks.
    _timer = Timer(const Duration(milliseconds: 1500), () {
      final words = _reply.split(' ');
      var index = 0;
      var streamed = '';
      _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
        if (index >= words.length) {
          timer.cancel();
          _finish();
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

  void _finish() {
    setState(() {
      _generating = false;
      _messages = [
        ..._messages.sublist(0, _messages.length - 1),
        _messages.last.copyWith(status: FlowMessageStatus.complete),
      ];
    });
  }

  void _stop() {
    _timer?.cancel();
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return FlowChatScreen(
      empty: _messages.isEmpty,
      greeting: const FlowGreeting(
        icon: PhosphorIconsRegular.sunHorizon,
        text: 'Good Afternoon',
      ),
      suggestions: FlowSuggestionGroup(
        layout: FlowSuggestionLayout.column,
        suggestions: [
          for (final (icon, prompt) in _starters)
            FlowSuggestion(
              label: prompt,
              icon: icon,
              onTap: () => _input.text = prompt,
            ),
        ],
      ),
      thread: FlowThread(
        messages: _messages,
        controller: _controller,
        thinkingLabel: 'thinking..',
      ),
      threadController: _controller,
      jumpToLatestTooltip: 'Jump to latest',
      composer: FlowComposer(
        controller: _input,
        placeholder: 'How can I help you today?',
        isStreaming: _generating,
        onSend: _send,
        onStop: _stop,
        leadingActions: [
          FlowMenu(
            icon: PhosphorIconsRegular.plus,
            tooltip: 'Add to chat',
            sheetTitle: 'Add to Chat',
            entries: [
              const FlowMenuOption(
                id: 'files',
                icon: PhosphorIconsRegular.file,
                label: 'Add Files or Photos',
              ),
              const FlowMenuDivider(),
              const FlowMenuOption(
                id: 'skills',
                icon: PhosphorIconsRegular.scroll,
                label: 'Skills',
              ),
              const FlowMenuOption(
                id: 'connectors',
                icon: PhosphorIconsRegular.lightning,
                label: 'Connectors',
              ),
              const FlowMenuDivider(),
              FlowMenuOption(
                id: 'research',
                icon: PhosphorIconsRegular.graduationCap,
                label: 'Research',
                selected: _researchOn,
              ),
              FlowMenuOption(
                id: 'web-search',
                icon: PhosphorIconsRegular.globe,
                label: 'Web Search',
                selected: _webSearchOn,
              ),
            ],
            onSelected: (id) {
              if (id == 'research') {
                setState(() => _researchOn = !_researchOn);
              } else if (id == 'web-search') {
                setState(() => _webSearchOn = !_webSearchOn);
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
                id: 'opus-5-1',
                label: 'Opus 5.1',
                description: 'For complex & thinking tasks',
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
              FlowEffortOption(
                id: 'extra',
                label: 'Extra',
                description: 'Extended thinking for hard problems',
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
