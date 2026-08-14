import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flow_ui example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(extensions: [FlowTheme.light()]),
      darkTheme: ThemeData(extensions: [FlowTheme.dark()]),
      home: const ChatPage(),
    );
  }
}

/// A complete chat surface: zero state with greeting and starters, a
/// thread that streams a canned reply, and a composer with menus.
///
/// flow_ui renders state and reports intent — there is no model behind
/// this page. Replace [_reply] with chunks from your backend.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

const String _reply =
    'I can assist you with most tasks across this app — drafting an essay, '
    'putting together a briefing, or sketching out a new venture. What else '
    'can I do for you today?';

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();
  List<FlowMessageData> _messages = const [];
  bool _generating = false;
  String _modelId = 'smart';
  Timer? _timer;
  int _nextId = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Appends the user turn plus a pending reply, then streams the canned
  /// text word by word — rebuild with [FlowMessageData.copyWith] as chunks
  /// arrive and the thread animates the reveal.
  void _send(String text) {
    _timer?.cancel();
    final id = 'msg${_nextId++}';
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

    // A thinking beat, then the reply streams in.
    _timer = Timer(const Duration(milliseconds: 1200), () {
      final words = _reply.split(' ');
      var index = 0;
      _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
        if (index >= words.length) {
          timer.cancel();
          _finish();
          return;
        }
        index++;
        setState(() {
          _messages = [
            ..._messages.sublist(0, _messages.length - 1),
            _messages.last.copyWith(
              parts: [FlowTextPart(words.take(index).join(' '))],
              status: FlowMessageStatus.streaming,
            ),
          ];
        });
      });
    });
  }

  void _finish() {
    _timer?.cancel();
    setState(() {
      _messages = [
        ..._messages.sublist(0, _messages.length - 1),
        _messages.last.copyWith(status: FlowMessageStatus.complete),
      ];
      _generating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.flowColors.surface,
      body: FlowChatScreen(
        empty: _messages.isEmpty,
        greeting: const FlowGreeting(
          icon: Icons.wb_twilight,
          text: 'Good afternoon',
        ),
        suggestions: FlowSuggestionGroup(
          layout: FlowSuggestionLayout.column,
          suggestions: [
            for (final (icon, prompt) in const [
              (Icons.edit_note, 'Write an essay about life and enjoyment'),
              (Icons.event_available, 'Create a Monday briefing from my tasks'),
              (Icons.search, 'Suggest a new venture for me'),
            ])
              FlowSuggestion(
                label: prompt,
                icon: icon,
                onTap: () => _send(prompt),
              ),
          ],
        ),
        thread: FlowThread(
          messages: _messages,
          controller: _scroll,
          thinkingLabel: 'Thinking…',
        ),
        threadController: _scroll,
        jumpToLatestTooltip: 'Jump to latest',
        composer: FlowComposer(
          controller: _input,
          placeholder: 'How can I help you today?',
          isStreaming: _generating,
          onSend: _send,
          onStop: _finish,
          leadingActions: [
            FlowMenu(
              icon: Icons.add,
              tooltip: 'Add to chat',
              sheetTitle: 'Add to chat',
              entries: const [
                FlowMenuOption(
                  id: 'files',
                  icon: Icons.attach_file,
                  label: 'Add files or photos',
                ),
                FlowMenuDivider(),
                FlowMenuOption(
                  id: 'web',
                  icon: Icons.public,
                  label: 'Web search',
                ),
              ],
              onSelected: (_) {},
            ),
          ],
          trailingActions: [
            FlowModelSelector(
              tooltip: 'Choose model',
              sheetTitle: 'Select model',
              models: const [
                FlowModelOption(
                  id: 'fast',
                  label: 'Fast',
                  description: 'Quick answers',
                ),
                FlowModelOption(
                  id: 'smart',
                  label: 'Smart',
                  description: 'For hard problems',
                ),
              ],
              selectedId: _modelId,
              onSelected: (id) => setState(() => _modelId = id),
            ),
          ],
        ),
      ),
    );
  }
}
