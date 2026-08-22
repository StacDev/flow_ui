import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

// The API key lives in env.g.dart — paste yours there.
import 'env.g.dart';
import 'gemini_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // FlowTheme installs the design tokens as theme extensions — the
    // canonical host wiring, in both brightnesses so the app follows the
    // device setting.
    return MaterialApp(
      title: 'Flow UI Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(extensions: [FlowTheme.light()]),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [FlowTheme.dark()],
      ),
      home: const ChatScreen(),
    );
  }
}

/// The minimal live host: flow_ui renders the state, [GeminiApi] is the
/// transport, and this screen is the fold between them — messages are
/// pure view models, and streaming is data: each delta rebuilds the
/// reply's message with the grown text.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiApi _gemini = GeminiApi(apiKey: apiKey);
  final ScrollController _scroll = ScrollController();

  List<FlowMessageData> _messages = const [];
  StreamSubscription<String>? _reply;
  int _nextId = 0;

  bool get _generating => _reply != null;

  @override
  void dispose() {
    _reply?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (_generating) return;
    setState(() {
      _messages = [
        ..._messages,
        FlowMessageData.text(
          id: 'u${_nextId++}',
          role: FlowMessageRole.user,
          text: text,
        ),
      ];
    });
    _generate();
  }

  void _generate() {
    final id = 'a${_nextId++}';
    final history = List.of(_messages);
    setState(() {
      _messages = [
        ..._messages,
        // Pending renders the thinking indicator; the first delta flips
        // the turn to streaming and the text reveal takes over.
        FlowMessageData(
          id: id,
          role: FlowMessageRole.assistant,
          status: FlowMessageStatus.pending,
        ),
      ];
    });

    var reply = '';
    _reply = _gemini
        .streamReply(history)
        .listen(
          (delta) {
            reply += delta;
            _update(
              id,
              parts: [FlowTextPart(reply)],
              status: FlowMessageStatus.streaming,
            );
          },
          onError: (Object error) {
            _reply = null;
            _update(
              id,
              status: FlowMessageStatus.error,
              parts: [
                if (reply.isNotEmpty) FlowTextPart(reply),
                FlowErrorPart(
                  message: error is GeminiApiException
                      ? error.message
                      : 'Something went wrong. Check your connection and '
                            'try again.',
                ),
              ],
            );
          },
          onDone: () {
            _reply = null;
            // A stream can close without ever emitting text (an empty or
            // filtered response); completing then would leave a blank
            // assistant row — drop the turn instead, like _stop does.
            if (reply.isEmpty) {
              if (!mounted) return;
              setState(() {
                _messages = [
                  for (final m in _messages)
                    if (m.id != id) m,
                ];
              });
            } else {
              _update(id, status: FlowMessageStatus.complete);
            }
          },
          cancelOnError: true,
        );
  }

  /// Stop keeps whatever streamed in and closes the turn — unless nothing
  /// arrived yet, where completing would leave an empty turn: the still
  /// pending reply is removed instead.
  void _stop() {
    _reply?.cancel();
    _reply = null;
    final last = _messages.last;
    if (last.parts.isEmpty) {
      setState(() {
        _messages = [
          for (final m in _messages)
            if (m.id != last.id) m,
        ];
      });
    } else {
      _update(last.id, status: FlowMessageStatus.complete);
    }
  }

  /// Retry from the thread's error card: drop the failed reply, re-run.
  void _retry(FlowMessageData message) {
    if (_generating) return;
    setState(() {
      _messages = [
        for (final m in _messages)
          if (m.id != message.id) m,
      ];
    });
    _generate();
  }

  void _update(
    String id, {
    List<FlowMessagePart>? parts,
    FlowMessageStatus? status,
  }) {
    if (!mounted) return;
    setState(() {
      _messages = [
        for (final m in _messages)
          if (m.id == id) m.copyWith(parts: parts, status: status) else m,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.flowColors.surface,
      body: FlowChatView(
        empty: _messages.isEmpty,
        greeting: const FlowGreeting(
          icon: Icons.wb_twilight,
          text: 'Good afternoon',
        ),
        thread: FlowThread(
          messages: _messages,
          controller: _scroll,
          thinkingLabel: 'Thinking…',
          errorTitle: 'Reply failed',
          retryLabel: 'Retry',
          onRetry: _retry,
          // Intent out: the host decides what opening a link means. Here,
          // a snackbar showing the href stands in for a browser launch.
          onLinkTap: (message, href) =>
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(href))),
        ),
        threadController: _scroll,
        jumpToLatestTooltip: 'Jump to latest',
        composer: FlowComposer(
          isStreaming: _generating,
          onSend: _send,
          onStop: _stop,
        ),
      ),
    );
  }
}
