import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    FlowModelOption(
      id: 'gemini-3.1-flash-image',
      label: 'Gemini 3.1 Flash Image',
      description: 'Generates pictures',
    ),
  ];

  /// The models that answer with pictures. Only these are asked for image
  /// output; a text model refuses the request outright.
  static const Set<String> _imageModels = {'gemini-3.1-flash-image'};

  final ScrollController _scroll = ScrollController();

  /// Every conversation this screen has held, newest first, and the one
  /// on screen. The thread list in the drawer reads these; the chat view
  /// only ever sees the active one.
  final Map<String, List<FlowMessageData>> _threads = {'t0': const []};
  final List<String> _threadOrder = ['t0'];
  String _activeThread = 't0';
  int _nextThread = 1;

  /// The composer's text, and each thread's draft while another is on
  /// screen — a draft belongs to the conversation it was typed in.
  final TextEditingController _draft = TextEditingController();
  final Map<String, String> _drafts = {};

  List<FlowMessageData> get _messages => _threads[_activeThread] ?? const [];
  set _messages(List<FlowMessageData> value) => _threads[_activeThread] = value;

  /// A thread is named by its opening question.
  String _titleOf(String id) {
    for (final message in _threads[id] ?? const <FlowMessageData>[]) {
      if (message.role != FlowMessageRole.user) continue;
      final text = message.plainText.trim();
      if (text.isEmpty) continue;
      return text.length > 40 ? '${text.substring(0, 40)}…' : text;
    }
    return 'New chat';
  }

  void _openThread(String id) {
    if (id == _activeThread) return;
    if (_generating) _stop();
    _drafts[_activeThread] = _draft.text;
    _draft.text = _drafts[id] ?? '';
    setState(() {
      _activeThread = id;
      _pending.clear();
      _rejection = null;
    });
  }

  void _newThread() {
    // An untouched thread is already the new chat.
    if (_messages.isEmpty) return;
    if (_generating) _stop();
    _drafts[_activeThread] = _draft.text;
    _draft.clear();
    setState(() {
      _activeThread = 't${_nextThread++}';
      _threads[_activeThread] = const [];
      _threadOrder.insert(0, _activeThread);
      _pending.clear();
      _rejection = null;
    });
  }

  StreamSubscription<GeminiDelta>? _reply;
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
    _draft.dispose();
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

  /// 'Add Files or Photos': the package's dialog, opened from this
  /// screen's menu. Called synchronously from the tap so the web keeps
  /// the gesture's user activation; the result is held here like any
  /// other attachment.
  Future<void> _pickFiles() async {
    final picked = await showFlowAttachmentPicker(
      options: _attachmentOptions,
      onRejected: _rejectAttachment,
    );
    if (!mounted || picked.isEmpty) return;
    _addAttachments(picked);
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
    final generatesImages = _imageModels.contains(_model);
    setState(() {
      _messages = [
        ..._messages,
        // A text model's turn starts pending, which renders the thinking
        // indicator until the first delta flips it to streaming. An image
        // model's turn starts streaming with the picture slot already in
        // it: the image models send nothing before the picture, so a
        // pending turn would show 'thinking' right up to the moment the
        // bytes land, and the generating block would never be seen.
        FlowMessageData(
          id: id,
          role: FlowMessageRole.assistant,
          status: generatesImages
              ? FlowMessageStatus.streaming
              : FlowMessageStatus.pending,
          parts: generatesImages
              ? const [FlowImagePart(semanticLabel: 'Generated image')]
              : const [],
        ),
      ];
    });

    var reply = '';
    Uint8List? picture;
    String? pictureType;
    var aspectRatio = 1.0;
    // Once the turn has failed its parts are the error card's, and a
    // measurement that lands afterwards must not write over them.
    var failed = false;

    // The turn as it stands. On an image model the picture slot is there
    // from the first delta: a null image is FlowImagePart's generating
    // state, a shimmering block that becomes the picture when the bytes
    // land — generation is data, so the host just re-renders with the
    // provider set. Text first, picture under it.
    List<FlowMessagePart> parts({required bool settled}) => [
      if (reply.isNotEmpty) FlowTextPart(reply),
      if (picture != null || (generatesImages && !settled))
        FlowImagePart(
          // The same Uint8List every rebuild, so MemoryImage stays equal
          // and the framework never decodes it twice.
          image: picture == null ? null : MemoryImage(picture!),
          aspectRatio: aspectRatio,
          semanticLabel: 'Generated image',
          // Carried so the next turn can send the picture back with the
          // history; GeminiApi inlines it the way it does an attachment.
          bytes: picture,
          mimeType: pictureType,
        ),
    ];

    _reply =
        GeminiApi(apiKey: apiKey, model: _model, imageOutput: generatesImages)
            .streamReply(history)
            .listen(
              (delta) {
                switch (delta) {
                  case GeminiTextDelta(:final text):
                    reply += text;
                  case GeminiImageDelta(:final bytes, :final mimeType):
                    picture = bytes;
                    pictureType = mimeType;
                    // The block holds its shape while the picture decodes;
                    // its real proportions come from the bytes, so measure
                    // them and re-render once known.
                    _measure(bytes).then((ratio) {
                      if (failed) return;
                      if (ratio == null || !identical(picture, bytes)) return;
                      aspectRatio = ratio;
                      if (_messages.any((m) => m.id == id)) {
                        _update(id, parts: parts(settled: _reply == null));
                      }
                    });
                }
                _update(
                  id,
                  parts: parts(settled: false),
                  status: FlowMessageStatus.streaming,
                );
              },
              onError: (Object error) {
                _reply = null;
                failed = true;
                _update(
                  id,
                  status: FlowMessageStatus.error,
                  parts: [
                    ...parts(settled: true),
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
                // A stream can close without ever emitting anything (an
                // empty or filtered response); completing then would leave
                // a blank assistant row — drop the turn instead, like _stop
                // does. Settling also drops the picture slot if the model
                // chose to answer in words alone.
                if (reply.isEmpty && picture == null) {
                  if (!mounted) return;
                  setState(() {
                    _messages = [
                      for (final m in _messages)
                        if (m.id != id) m,
                    ];
                  });
                } else {
                  _update(
                    id,
                    parts: parts(settled: true),
                    status: FlowMessageStatus.complete,
                  );
                }
              },
              cancelOnError: true,
            );
  }

  /// A generated picture's width over its height, from its bytes. Null
  /// when they cannot be decoded, which leaves the block square.
  static Future<double?> _measure(Uint8List bytes) async {
    try {
      final image = await decodeImageFromList(bytes);
      final ratio = image.width / image.height;
      image.dispose();
      return ratio;
    } catch (_) {
      return null;
    }
  }

  /// Stop keeps whatever streamed in and closes the turn — unless nothing
  /// arrived yet, where completing would leave an empty turn: the still
  /// pending reply is removed instead.
  void _stop() {
    // Only a turn in flight has anything to stop: the composer calls this
    // while streaming, and a thread switch may not be.
    if (!_generating) return;
    _reply?.cancel();
    _reply = null;
    final last = _messages.last;
    // A picture that never landed is not content: its generating block
    // goes with the stop, and a turn left with nothing goes entirely.
    final kept = [
      for (final part in last.parts)
        if (part is! FlowImagePart || part.image != null) part,
    ];
    if (kept.isEmpty) {
      setState(() {
        _messages = [
          for (final m in _messages)
            if (m.id != last.id) m,
        ];
      });
    } else {
      _update(last.id, parts: kept, status: FlowMessageStatus.complete);
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

  /// The context menu's entries: nothing while a turn is still coming
  /// in, copy and delete for the user's own, the actions row's set for a
  /// settled reply.
  List<FlowMenuEntry> _menuFor(FlowMessageData message) {
    if (message.status == FlowMessageStatus.pending ||
        message.status == FlowMessageStatus.streaming) {
      return const [];
    }
    final feedback = _feedback[message.id];
    return [
      const FlowMenuOption(
        id: 'copy',
        icon: Icons.copy_outlined,
        label: 'Copy',
      ),
      const FlowMenuOption(
        id: 'select',
        icon: Icons.text_fields,
        label: 'Select text',
      ),
      if (message.role == FlowMessageRole.assistant) ...[
        FlowMenuOption(
          id: 'up',
          icon: Icons.thumb_up_outlined,
          label: 'Good response',
          selected: feedback == true,
        ),
        FlowMenuOption(
          id: 'down',
          icon: Icons.thumb_down_outlined,
          label: 'Bad response',
          selected: feedback == false,
        ),
        FlowMenuOption(
          id: 'regenerate',
          icon: Icons.refresh,
          label: 'Regenerate',
          enabled: !_generating && message.id == _messages.last.id,
        ),
      ],
      const FlowMenuDivider(),
      const FlowMenuOption(
        id: 'delete',
        icon: Icons.delete_outline,
        label: 'Delete',
      ),
    ];
  }

  void _onMenu(FlowMessageData message, String id) {
    switch (id) {
      case 'copy':
        _copy(message);
      case 'select':
        showFlowTextSelection(
          context: context,
          message: message,
          closeTooltip: 'Close',
        );
      case 'up':
        setState(() {
          _feedback[message.id] == true
              ? _feedback.remove(message.id)
              : _feedback[message.id] = true;
        });
      case 'down':
        setState(() {
          _feedback[message.id] == false
              ? _feedback.remove(message.id)
              : _feedback[message.id] = false;
        });
      case 'regenerate':
        _retry(message);
      case 'delete':
        setState(() {
          _feedback.remove(message.id);
          _messages = [
            for (final m in _messages)
              if (m.id != message.id) m,
          ];
        });
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
    final colors = context.flowColors;
    final typography = context.flowTypography;
    return Scaffold(
      backgroundColor: colors.surface,
      // The app's own chrome, in the Flow tokens: a flat bar on the page
      // ground, the thread's title, the drawer and a new chat.
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          _titleOf(_activeThread),
          style: typography.labelLargeEmphasised.copyWith(
            color: colors.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Chats',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            tooltip: 'New chat',
            onPressed: _newThread,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: colors.surfaceBright,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                child: Row(
                  children: [
                    Text(
                      'Chats',
                      style: typography.titleSmallEmphasised.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.edit_square),
                        tooltip: 'New chat',
                        color: colors.onSurfaceVariant,
                        onPressed: () {
                          Navigator.of(context).pop();
                          _newThread();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) => FlowThreadList(
                    sections: [
                      FlowThreadListSection(
                        label: 'Today',
                        items: [
                          for (final id in _threadOrder)
                            FlowThreadListItem(
                              id: id,
                              title: _titleOf(id),
                              tooltip: _titleOf(id),
                            ),
                        ],
                      ),
                    ],
                    selectedId: _activeThread,
                    onThreadSelected: (id) {
                      Navigator.of(context).pop();
                      _openThread(id);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FlowChatView(
        // Web only: the SDK implements OS file drop nowhere else, and the
        // package says so at runtime when handed the callback elsewhere.
        onAttachmentsDropped: kIsWeb ? _addAttachments : null,
        onAttachmentRejected: _rejectAttachment,
        attachmentOptions: _attachmentOptions,
        dropLabel: 'Drop files to add to chat',
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
          // The long-press menu: the same intents as the actions row,
          // reachable from anywhere on the message, plus delete.
          messageMenu: _menuFor,
          onMessageMenuSelected: _onMenu,
        ),
        threadController: _scroll,
        jumpToLatestTooltip: 'Jump to latest',
        composer: FlowComposer(
          controller: _draft,
          isStreaming: _generating,
          onSend: _send,
          onStop: _stop,
          sendTooltip: 'Send',
          stopTooltip: 'Stop',
          // Picking goes through the "+" menu below; paste and drop land
          // in the same place — three ways in, one handler.
          onAttachmentsPasted: kIsWeb ? _addAttachments : null,
          onAttachmentRejected: _rejectAttachment,
          attachmentOptions: _attachmentOptions,
          // The design's error banner above the card; the words are this
          // screen's, and its cross hands the dismissal back here.
          errorMessage: _rejection,
          onErrorDismiss: () => setState(() => _rejection = null),
          errorDismissTooltip: 'Dismiss',
          onContentInserted: _insertContent,
          attachments: List.of(_pending),
          onRemoveAttachment: (id) =>
              setState(() => _pending.removeWhere((a) => a.id == id)),
          leadingActions: [
            // The design's way in: 'Add Files or Photos' opens the
            // package's own dialog, from the host's menu.
            FlowMenu(
              icon: Icons.add,
              tooltip: 'Add to chat',
              sheetTitle: 'Add to chat',
              entries: const [
                FlowMenuOption(
                  id: 'files',
                  icon: Icons.upload_file_outlined,
                  label: 'Add Files or Photos',
                ),
              ],
              onSelected: (id) {
                if (id == 'files') unawaited(_pickFiles());
              },
            ),
          ],
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
