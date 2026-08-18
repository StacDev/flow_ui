import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

const String errorStateSnippet = '''
// The card renders state and reports one intent; what retry means —
// re-run the turn, refetch, reconnect — is the host's business.
FlowErrorState(
  title: 'Connection error',
  message: 'The API is overloaded right now. Retry in a moment.',
  retryLabel: 'Retry',
  onRetry: resend,
)

// In a thread the card renders on its own: parts a failed turn already
// delivered keep their ink, and its FlowErrorPart closes the turn.
FlowThread(
  messages: messages,
  errorTitle: 'Connection error',
  retryLabel: 'Retry',
  onRetry: (message) => rerun(message),
)

// retryable: false suppresses the pill — for failures retrying
// can't fix.
FlowMessageData(
  id: 'a2',
  role: FlowMessageRole.assistant,
  status: FlowMessageStatus.error,
  parts: [
    FlowErrorPart(message: 'This conversation exceeds the context window.'),
  ],
)''';

const String _partialReply =
    'FlowThread lays the conversation out as a reversed list, so the newest '
    'message sits at the bottom and history loads';

const String _fullReply =
    '$_partialReply upward. Messages keep their identity by id, which is '
    'what makes streaming updates cheap.';

const String _failureMessage =
    'The API is overloaded right now. Retry in a moment.';

/// Stage demo for `FlowErrorState` — the full card, the message-only
/// minimal form, and a failed turn in a thread whose retry actually
/// re-runs the reply, the way a host would.
class ErrorStateDemo extends StatefulWidget {
  const ErrorStateDemo({super.key, this.variant});

  final String? variant;

  @override
  State<ErrorStateDemo> createState() => _ErrorStateDemoState();
}

class _ErrorStateDemoState extends State<ErrorStateDemo> {
  static const Duration _feedTick = Duration(milliseconds: 30);
  static const int _feedStep = 3;

  /// Thread variant: the failed reply's lifecycle. Retry resumes the
  /// stream from the partial text and completes it.
  FlowMessageStatus _replyStatus = FlowMessageStatus.error;
  int _fed = _partialReply.length;
  Timer? _feed;

  @override
  void dispose() {
    _feed?.cancel();
    super.dispose();
  }

  void _retry() {
    if (_replyStatus == FlowMessageStatus.streaming) return;
    setState(() => _replyStatus = FlowMessageStatus.streaming);
    _feed = Timer.periodic(_feedTick, (timer) {
      setState(() {
        _fed = (_fed + _feedStep).clamp(0, _fullReply.length);
        if (_fed == _fullReply.length) {
          _replyStatus = FlowMessageStatus.complete;
          timer.cancel();
        }
      });
    });
  }

  List<FlowMessageData> get _messages => [
    FlowMessageData.text(
      id: 'u1',
      role: FlowMessageRole.user,
      text: 'What does FlowThread actually do?',
    ),
    FlowMessageData(
      id: 'a1',
      role: FlowMessageRole.assistant,
      status: _replyStatus,
      parts: [
        FlowTextPart(_fullReply.substring(0, _fed)),
        // The failure closes the turn; once retry re-runs it, the part
        // goes with it.
        if (_replyStatus == FlowMessageStatus.error)
          const FlowErrorPart(message: _failureMessage),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final child = switch (widget.variant) {
      'minimal' => const FlowErrorState(message: _failureMessage),
      'thread' => SizedBox(
        height: 420,
        child: FlowThread(
          messages: _messages,
          errorTitle: 'Connection error',
          retryLabel: 'Retry',
          onRetry: (_) => _retry(),
        ),
      ),
      _ => FlowErrorState(
        title: 'Connection error',
        message: _failureMessage,
        retryLabel: 'Retry',
        onRetry: () {},
      ),
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: child,
      ),
    );
  }
}
