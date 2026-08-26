import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/services.dart';
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
  /// The models offered in the composer's selector. The selection is host
  /// state: flow_ui reports the picked id and this screen hands it to the
  /// transport on the next turn.
  static const List<FlowModelOption> _models = [
    FlowModelOption(
      id: 'gemini-3.6-flash',
      label: 'Gemini 3.6 Flash',
      description: 'Fast, general-purpose replies',
    ),
    FlowModelOption(
      id: 'gemini-3.5-flash-lite',
      label: 'Gemini 3.5 Flash Lite',
      description: 'Lightest and quickest',
    ),
  ];

  final ScrollController _scroll = ScrollController();

  List<FlowMessageData> _messages = const [];
  StreamSubscription<String>? _reply;
  int _nextId = 0;
  String _model = 'gemini-3.6-flash';

  /// Feedback per message id — true thumbed up, false down. Host state,
  /// like everything else: the actions row only reports the taps.
  final Map<String, bool> _feedback = {};

  /// Attachments picked or dropped but not yet sent. flow_ui opens the
  /// dialog, detects the drop and decodes the bytes; holding what comes
  /// back — and sending it — is this screen's.
  final List<FlowAttachment> _pending = [];
  int _nextAttachmentId = 0;

  /// The last refused file, in this app's words. The package reports the
  /// name and the reason and ships no copy of its own.
  String? _rejection;

  /// Shared by the attach button and the drop target, so a file gets the
  /// same answer whichever way it arrives. The 10 MB cap is this app's
  /// policy — flow_ui defaults to none.
  static const FlowAttachmentOptions _attachmentOptions = FlowAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  );

  /// The code part whose copy confirmation is showing; cleared after a
  /// beat. Copying is intent out: the block reports the part, the host
  /// writes the clipboard.
  FlowCodePart? _copiedCode;
  Timer? _copiedReset;

  bool get _generating => _reply != null;

  @override
  void dispose() {
    _copiedReset?.cancel();
    _reply?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (_generating) return;
    setState(() {
      _rejection = null;
      _messages = [
        ..._messages,
        FlowMessageData(
          id: 'u${_nextId++}',
          role: FlowMessageRole.user,
          parts: [
            // Attachments lead the bubble and the caption follows, the
            // chat convention — parts render in the order given, so this
            // list *is* the layout.
            //
            // They also go up to Gemini with the turn: GeminiApi reads
            // the bytes flow_ui left on each attachment and inlines them.
            if (_pending.isNotEmpty) FlowAttachmentPart(List.of(_pending)),
            // Empty when a picture was sent with no caption, which the
            // composer allows — a photo on its own is a message.
            if (text.isNotEmpty) FlowTextPart(text),
          ],
        ),
      ];
      _pending.clear();
    });
    _generate();
  }

  /// Everything flow_ui hands back — picked from the dialog or dropped
  /// on the surface — lands here. The package read and decoded it; this
  /// app only has to hold it until send.
  void _addAttachments(List<FlowAttachment> attachments) {
    setState(() {
      _rejection = null;
      _pending.addAll(attachments);
    });
  }

  /// A file the options refused. flow_ui says which and why and stops
  /// there; the wording is the app's, and so is where it shows.
  void _rejectAttachment(String name, FlowAttachmentRejection reason) {
    final why = switch (reason) {
      FlowAttachmentRejection.tooLarge => 'is larger than 10 MB',
      FlowAttachmentRejection.unsupportedType => 'is not an image',
      FlowAttachmentRejection.unreadable => 'could not be read',
    };
    setState(() => _rejection = '$name $why');
  }

  /// Android's keyboard media insertion — a GIF picked inside the IME
  /// arrives as bytes rather than as a file, so it skips the picker and
  /// joins the pending strip directly.
  ///
  /// Carrying `bytes` and `mimeType` is what makes it upload like a
  /// picked file: the package fills those in for what it read itself, and
  /// a host building an attachment by hand fills them in the same way.
  void _insertContent(KeyboardInsertedContent content) {
    final data = content.data;
    if (data == null || data.isEmpty) return;
    setState(() {
      _rejection = null;
      _pending.add(
        FlowAttachment(
          id: 'p${_nextAttachmentId++}',
          thumbnail: MemoryImage(data),
          label: 'keyboard image',
          bytes: data,
          mimeType: content.mimeType,
        ),
      );
    });
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
    _reply = GeminiApi(apiKey: apiKey, model: _model)
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

  void _copyCode(FlowCodePart part) {
    Clipboard.setData(ClipboardData(text: part.code));
    _copiedReset?.cancel();
    setState(() => _copiedCode = part);
    _copiedReset = Timer(const Duration(seconds: 2), () {
      _copiedReset = null;
      if (mounted) setState(() => _copiedCode = null);
    });
  }

  void _copy(FlowMessageData message) {
    final text = [
      for (final part in message.parts)
        if (part is FlowTextPart) part.text,
    ].join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied')));
  }

  /// The actions row under a settled assistant reply: copy, feedback, and
  /// — on the latest reply only, where re-running makes sense — regenerate.
  Widget? _actionsFor(FlowMessageData message) {
    if (message.role != FlowMessageRole.assistant ||
        message.status != FlowMessageStatus.complete) {
      return null;
    }
    final feedback = _feedback[message.id];
    final isLatest = message.id == _messages.last.id;
    return FlowMessageActions(
      actions: [
        FlowMessageAction.copy(
          tooltip: 'Copy',
          onPressed: () => _copy(message),
        ),
        FlowMessageAction.thumbUp(
          tooltip: 'Good response',
          selected: feedback == true,
          onPressed: () => setState(() {
            feedback == true
                ? _feedback.remove(message.id)
                : _feedback[message.id] = true;
          }),
        ),
        FlowMessageAction.thumbDown(
          tooltip: 'Bad response',
          selected: feedback == false,
          onPressed: () => setState(() {
            feedback == false
                ? _feedback.remove(message.id)
                : _feedback[message.id] = false;
          }),
        ),
        if (isLatest)
          FlowMessageAction.regenerate(
            tooltip: 'Regenerate',
            onPressed: _generating ? null : () => _retry(message),
          ),
      ],
    );
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
        // Drag-and-drop, handled by the package. Web only — the SDK
        // implements OS file drop nowhere else — and a no-op elsewhere,
        // which is why the attach button carries the same job.
        onAttachmentsDropped: _addAttachments,
        onAttachmentRejected: _rejectAttachment,
        attachmentOptions: _attachmentOptions,
        dropLabel: 'Drop files to add to chat',
        aboveComposer: _rejection == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _rejection!,
                  textAlign: TextAlign.center,
                  style: context.flowTypography.bodySmall.copyWith(
                    color: context.flowColors.error,
                  ),
                ),
              ),
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
          onLinkTap: (message, href) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(href))),
          onCodeCopy: _copyCode,
          copiedCodePart: _copiedCode,
          codeCopyTooltip: 'Copy code',
          // The footer slot keeps the default message and its wiring;
          // only the actions row is the host's.
          messageFooter: _actionsFor,
        ),
        threadController: _scroll,
        jumpToLatestTooltip: 'Jump to latest',
        composer: FlowComposer(
          isStreaming: _generating,
          onSend: _send,
          onStop: _stop,
          // The package picks: the attach button opens the platform's
          // dialog and these come back read and decoded. Pass onAttach
          // instead to open a gallery sheet or a camera yourself.
          onAttachmentsPicked: _addAttachments,
          // Paste and drop land in the same place as a pick — three ways
          // in, one handler, which is the usual shape.
          onAttachmentsPasted: _addAttachments,
          onAttachmentRejected: _rejectAttachment,
          attachmentOptions: _attachmentOptions,
          attachTooltip: 'Attach images',
          onContentInserted: _insertContent,
          attachments: List.of(_pending),
          onRemoveAttachment: (id) =>
              setState(() => _pending.removeWhere((a) => a.id == id)),
          trailingActions: [
            FlowModelSelector(
              models: _models,
              selectedId: _model,
              onSelected: (id) => setState(() => _model = id),
            ),
          ],
        ),
      ),
    );
  }
}
