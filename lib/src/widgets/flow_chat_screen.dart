import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../utils/flow_circle_button.dart';
import 'flow_thread.dart';

/// How far back through the history the thread must be before the
/// jump-to-latest button is worth offering — roughly one message.
///
/// Deliberately small: a short thread's whole scroll range can be only a
/// few hundred pixels, and a larger threshold would mean the button never
/// appears at all on one.
const double _jumpThreshold = 120;
const Duration _jumpReveal = Duration(milliseconds: 150);
const Duration _jumpScroll = Duration(milliseconds: 240);

/// The chat surface: a bounded thread above a composer, centred at a
/// readable width.
///
/// ```dart
/// FlowChatScreen(
///   thread: FlowThread(messages: messages, controller: controller),
///   composer: FlowComposer(onSend: send),
///   threadController: controller,
///   aboveComposer: messages.isEmpty ? FlowSuggestionGroup(...) : null,
/// )
/// ```
///
/// Takes finished widgets rather than their data, so it stays correct as
/// `FlowThread` and `FlowComposer` grow. It supplies the bounded height a
/// `FlowThread` needs, which is the one thing every host would otherwise
/// have to know.
///
/// Body-only: it builds no [Scaffold] and no app bar, so drop it in a
/// scaffold body and the host keeps the chrome, the background, and the
/// keyboard inset.
class FlowChatScreen extends StatefulWidget {
  const FlowChatScreen({
    super.key,
    this.thread,
    this.composer,
    this.header,
    this.aboveComposer,
    this.threadController,
    this.jumpToLatestTooltip,
    this.maxContentWidth = 768,
    this.padding,
  }) : assert(maxContentWidth > 0, 'maxContentWidth must be positive');

  /// The conversation, usually a [FlowThread]. Given the bounded height it
  /// needs, so it does not want a `SizedBox` of its own.
  ///
  /// Defaults to an empty [FlowThread] — a conversation nobody has spoken in
  /// yet is a real state of a chat, so the surface stands up on its own.
  final Widget? thread;

  /// The input, usually a `FlowComposer`.
  ///
  /// Null renders no input at all, leaving a read-only surface — an archived
  /// thread, a shared transcript. There is deliberately no default: a
  /// composer needs somewhere to send to, which is why `FlowComposer` makes
  /// `onSend` required, and a stand-in would swallow what the user typed.
  final Widget? composer;

  /// Optional bar above the thread, inside the content width.
  final Widget? header;

  /// Between the thread and the composer — prompt starters on an empty
  /// thread, a notice, anything the host wants pinned above the input.
  final Widget? aboveComposer;

  /// Enables the jump-to-latest button. Pass the **same** controller to the
  /// [thread]; taking finished widgets means this one cannot reach in and
  /// attach its own. Null leaves the button out entirely.
  final ScrollController? threadController;

  /// Host-localized label for the jump-to-latest button.
  final String? jumpToLatestTooltip;

  /// A conversation spanning a wide display is unreadable, so the whole
  /// column is centred and capped.
  final double maxContentWidth;

  /// Around the composer and [aboveComposer]. Defaults to 16 horizontally —
  /// matching `FlowThread`'s own default padding, so their edges line up —
  /// and 16 below, with no top: the thread's bottom padding already
  /// separates the two.
  final EdgeInsetsGeometry? padding;

  @override
  State<FlowChatScreen> createState() => _FlowChatScreenState();
}

class _FlowChatScreenState extends State<FlowChatScreen> {
  /// The design's surface metrics: the composer block's edge padding, the
  /// jump button's lift off the composer, and the starters-to-composer gap.
  /// The horizontal 16 must match `FlowThread`'s own default padding — the
  /// doc on [FlowChatScreen.padding] promises the edges line up.
  static const EdgeInsetsGeometry _defaultPadding =
      EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16);
  static const double _jumpInset = 12;
  static const double _composerGap = 8;

  bool _showJump = false;

  @override
  void initState() {
    super.initState();
    widget.threadController?.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(FlowChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadController != widget.threadController) {
      oldWidget.threadController?.removeListener(_handleScroll);
      widget.threadController?.addListener(_handleScroll);
      _handleScroll();
    }
  }

  @override
  void dispose() {
    widget.threadController?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    final controller = widget.threadController;
    // hasClients guards the frames before the thread has attached, and the
    // ones after it detaches.
    final show =
        controller != null &&
        controller.hasClients &&
        controller.offset > _jumpThreshold;
    if (show != _showJump) setState(() => _showJump = show);
  }

  void _jumpToLatest() {
    final controller = widget.threadController;
    if (controller == null || !controller.hasClients) return;
    // The thread is a reversed ListView, so offset 0 is the *newest* message
    // at the bottom and maxScrollExtent is the oldest at the top. Animating
    // to maxScrollExtent here would fly to the start of history instead.
    controller.animateTo(0, duration: _jumpScroll, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final padding = widget.padding ?? _defaultPadding;

    // An empty thread rather than an empty box: the surface behaves the same
    // whether or not a host has wired one up yet.
    final thread = widget.thread ?? const FlowThread(messages: []);

    Widget threadArea = thread;
    if (widget.threadController != null) {
      threadArea = Stack(
        children: [
          Positioned.fill(child: thread),
          Positioned(
            bottom: _jumpInset,
            left: 0,
            right: 0,
            child: Center(
              // Opacity alone still hit-tests and still takes focus, so a
              // faded-out button would swallow taps meant for the thread.
              child: IgnorePointer(
                ignoring: !_showJump,
                child: AnimatedOpacity(
                  opacity: _showJump ? 1 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : _jumpReveal,
                  child: FlowCircleButton(
                    icon: Icons.arrow_downward,
                    background: colors.surfaceContainerHigh,
                    foreground: colors.onSurface,
                    tooltip: widget.jumpToLatestTooltip,
                    onTap: _jumpToLatest,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header != null) widget.header!,
              Expanded(child: threadArea),
              // Skipped entirely when there is nothing to put below the
              // thread, so a read-only surface doesn't carry a strip of
              // padding where its composer would have been.
              if (widget.composer != null || widget.aboveComposer != null)
                Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.aboveComposer != null) widget.aboveComposer!,
                      if (widget.composer != null) ...[
                        if (widget.aboveComposer != null)
                          const SizedBox(height: _composerGap),
                        widget.composer!,
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
