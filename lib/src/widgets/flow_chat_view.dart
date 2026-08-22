import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

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
/// readable width, with a zero state for the conversation that hasn't
/// started.
///
/// ```dart
/// FlowChatView(
///   empty: messages.isEmpty,
///   greeting: FlowGreeting(icon: Icons.wb_twilight, text: 'Good afternoon'),
///   suggestions: FlowSuggestionGroup(...),
///   thread: FlowThread(messages: messages, controller: controller),
///   composer: FlowComposer(onSend: send),
///   threadController: controller,
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
class FlowChatView extends StatefulWidget {
  const FlowChatView({
    super.key,
    required this.composer,
    this.thread,
    this.header,
    this.aboveComposer,
    this.empty = false,
    this.greeting,
    this.suggestions,
    this.threadController,
    this.jumpToLatestTooltip,
    this.maxContentWidth = 760,
    this.emptyComposerWidth = 640,
    this.emptySuggestionsWidth = 480,
    this.padding,
  }) : assert(
         thread != null ||
             composer != null ||
             header != null ||
             aboveComposer != null ||
             greeting != null ||
             suggestions != null,
         'FlowChatView was built with nothing to show, which renders a '
         'blank surface. Pass a thread, a composer, or the zero state '
         'pieces (greeting, suggestions) — see the class doc for the '
         'minimal usage.',
       ),
       assert(maxContentWidth > 0, 'maxContentWidth must be positive'),
       assert(emptyComposerWidth > 0, 'emptyComposerWidth must be positive'),
       assert(
         emptySuggestionsWidth > 0,
         'emptySuggestionsWidth must be positive',
       );

  /// The conversation, usually a [FlowThread]. Given the bounded height it
  /// needs, so it does not want a `SizedBox` of its own.
  ///
  /// Defaults to an empty [FlowThread] — a conversation nobody has spoken in
  /// yet is a real state of a chat, so the surface stands up on its own.
  final Widget? thread;

  /// The input, usually a `FlowComposer`. Required so a surface without an
  /// input is a decision rather than an omission: pass an explicit null for
  /// a read-only surface — an archived thread, a shared transcript.
  ///
  /// There is deliberately no default: a composer needs somewhere to send
  /// to, which is why `FlowComposer` makes `onSend` required, and a
  /// stand-in would swallow what the user typed.
  final Widget? composer;

  /// Optional bar above the thread, full-bleed — the design's mobile nav
  /// spans edge to edge. A host wanting a capped header constrains it
  /// itself.
  final Widget? header;

  /// Between the thread and the composer — a scrolling starter strip, a
  /// notice, anything the host wants pinned above the input.
  final Widget? aboveComposer;

  /// The zero state: no messages yet. The thread gives way to [greeting]
  /// and [suggestions] — on wide layouts the composer lifts to the vertical
  /// centre between them, per the design; on compact ones it stays docked
  /// with the suggestions just above it and the greeting floating centred.
  ///
  /// The host flips this (typically `messages.isEmpty`): the view takes
  /// finished widgets and cannot see into the thread.
  final bool empty;

  /// The zero state's headline, usually a `FlowGreeting`. Shown only while
  /// [empty].
  final Widget? greeting;

  /// The zero state's starters, usually a column `FlowSuggestionGroup`.
  /// Shown only while [empty]; the view places them — 48 below the
  /// composer on wide layouts, capped at [emptySuggestionsWidth], and 16
  /// above it on compact ones, stepped in a further 8.
  final Widget? suggestions;

  /// Enables the jump-to-latest button. Pass the **same** controller to the
  /// [thread]; taking finished widgets means this one cannot reach in and
  /// attach its own. Null leaves the button out entirely.
  final ScrollController? threadController;

  /// Host-localized label for the jump-to-latest button.
  final String? jumpToLatestTooltip;

  /// A conversation spanning a wide display is unreadable, so the thread
  /// and composer are centred and capped. The composer spans this rail in
  /// full where there is room; `FlowThread`'s own edge padding insets the
  /// bubbles 16 inside it. Defaults to the design's 760.
  final double maxContentWidth;

  /// The composer's rail in the wide zero state, where it sits narrower
  /// than in a running chat. Defaults to the design's 640.
  final double emptyComposerWidth;

  /// The [suggestions] rail in the wide zero state. Defaults to the
  /// design's 480.
  final double emptySuggestionsWidth;

  /// Around the composer block. Defaults to the design's 16 at the sides —
  /// kept *outside* [maxContentWidth], so the composer still reaches the
  /// full rail where there is room — with 40 below on wide layouts and 24
  /// on compact ones. An explicit value is used as given on both.
  final EdgeInsetsGeometry? padding;

  @override
  State<FlowChatView> createState() => _FlowChatViewState();
}

class _FlowChatViewState extends State<FlowChatView> {
  /// The design's surface metrics. Compact begins below 600, Material's
  /// compact/medium boundary — read from this widget's own constraints, so
  /// a pane or a phone frame counts, not just a phone. The composer block
  /// floats 40 off the bottom on wide layouts and 24 on compact ones, the
  /// jump button 12 off the composer, starters 8 above it.
  static const double _compactBreakpoint = 600;
  static const double _sideInset = 16;
  static const double _bottomInsetWide = 40;
  static const double _bottomInsetCompact = 24;
  static const double _jumpInset = 12;
  static const double _composerGap = 8;

  /// The jump button's lift, as an alpha over the ink — the composer's
  /// idiom, stronger on the small floating disc so it separates from the
  /// content scrolling beneath it.
  static const double _jumpShadowOpacity = 0.08;
  static const double _jumpShadowBlur = 12;

  /// The zero state's rhythm: greeting 32 above the composer; suggestions
  /// 48 below it on wide layouts, and on compact ones 16 above the docked
  /// composer, stepped in a further 8 — the design's 24 with the default
  /// padding.
  static const double _greetingGap = 32;
  static const double _suggestionsGapWide = 48;
  static const double _suggestionsGapCompact = 16;
  static const double _suggestionsExtraInset = 8;

  bool _showJump = false;
  Timer? _jumpDebounce;

  @override
  void initState() {
    super.initState();
    widget.threadController?.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(FlowChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadController != widget.threadController) {
      oldWidget.threadController?.removeListener(_handleScroll);
      widget.threadController?.addListener(_handleScroll);
      _handleScroll();
    }
    // Entering the zero state unmounts the thread, and no scroll event
    // arrives from a detaching position — recompute, or a jump button shown
    // before the switch would still be showing when the thread returns.
    if (oldWidget.empty != widget.empty) _handleScroll();
  }

  @override
  void dispose() {
    _jumpDebounce?.cancel();
    widget.threadController?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    final controller = widget.threadController;
    // hasClients guards the frames before the thread has attached, and the
    // ones after it detaches.
    final over =
        controller != null &&
        controller.hasClients &&
        controller.offset > _jumpThreshold;
    if (!over) {
      _jumpDebounce?.cancel();
      _jumpDebounce = null;
      if (_showJump) setState(() => _showJump = false);
      return;
    }
    if (_showJump || _jumpDebounce != null) return;
    // The thread's follow glide can carry the offset past the threshold
    // for a beat while a block eases in — only a held position earns the
    // button, so it isn't mounted and torn down by every entrance.
    _jumpDebounce = Timer(const Duration(milliseconds: 250), () {
      _jumpDebounce = null;
      if (!mounted) return;
      final controller = widget.threadController;
      if (controller != null &&
          controller.hasClients &&
          controller.offset > _jumpThreshold) {
        setState(() => _showJump = true);
      }
    });
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
    return GestureDetector(
      // Taps that reach the surface itself — dead space, the thread, a
      // settled message — dismiss the keyboard, the chat convention.
      // Interactive children (the composer, links, buttons) win the
      // gesture arena first, so their taps behave as before. Touch
      // platforms only — on desktop clicking a page's background doesn't
      // blur the input, and a global unfocus would even reach fields
      // outside this view. The theme's platform, like the composer's and
      // the menus' resolution, so hosts and tests can steer it.
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final platform = Theme.of(context).platform;
        if (platform == TargetPlatform.iOS ||
            platform == TargetPlatform.android) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < _compactBreakpoint;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.header != null) widget.header!,
                if (widget.empty && !compact)
                  // The wide zero state: the composer leaves the bottom edge
                  // and the whole cluster centres itself instead.
                  Expanded(child: _emptyCentre(constraints.maxWidth))
                else ...[
                  Expanded(
                    child: widget.empty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: _sideInset,
                              ),
                              child: widget.greeting,
                            ),
                          )
                        : _threadArea(context),
                  ),
                  ..._composerZone(compact),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// The running chat: the thread on the content rail, with the
  /// jump-to-latest button floating over its bottom edge.
  Widget _threadArea(BuildContext context) {
    final colors = context.flowColors;

    // An empty thread rather than an empty box: the surface behaves the same
    // whether or not a host has wired one up yet.
    final thread = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
        child: widget.thread ?? const FlowThread(messages: []),
      ),
    );
    // The scrollable lives inside the centred rail, so left alone the
    // platform scrollbar hugs the rail's edge, floating mid-window on
    // wide layouts. Suppressing it and painting one out here instead —
    // fed by the thread's own notifications — puts the thumb at the
    // surface's edge, where readers expect it. Depth 0 keeps the
    // scrollers nested in messages (tables, code blocks) off it.
    final scrollArea = Scrollbar(
      controller: widget.threadController,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: thread,
      ),
    );
    if (widget.threadController == null) return scrollArea;

    return Stack(
      children: [
        Positioned.fill(child: scrollArea),
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
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.onSurface.withValues(
                          alpha: _jumpShadowOpacity,
                        ),
                        blurRadius: _jumpShadowBlur,
                      ),
                    ],
                  ),
                  // The hairline rides in front of the disc — behind it,
                  // the opaque circle would paint over the stroke.
                  foregroundDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: FlowCircleButton(
                    icon: Icons.arrow_downward,
                    // The opaque ground, not a translucent container wash —
                    // the button floats over the thread, and messages
                    // scrolling beneath must not read through it.
                    background: colors.surface,
                    foreground: colors.onSurface,
                    tooltip: widget.jumpToLatestTooltip,
                    onTap: _jumpToLatest,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The wide zero state's centred cluster: greeting, composer, starters,
  /// each on its own rail. Scrollable so a short window degrades gracefully
  /// instead of overflowing.
  Widget _emptyCentre(double viewportWidth) {
    final available = viewportWidth - _sideInset * 2;
    final composerWidth = math.min(widget.emptyComposerWidth, available);
    final suggestionsWidth = math.min(widget.emptySuggestionsWidth, available);

    final composerBlock = <Widget>[
      if (widget.aboveComposer != null) widget.aboveComposer!,
      if (widget.composer != null) ...[
        if (widget.aboveComposer != null) const SizedBox(height: _composerGap),
        widget.composer!,
      ],
    ];

    // Gaps only between the pieces actually present, so a host without a
    // greeting or without starters still gets a coherent centre.
    final cluster = <Widget>[];
    if (widget.greeting != null) cluster.add(widget.greeting!);
    if (composerBlock.isNotEmpty) {
      if (cluster.isNotEmpty) {
        cluster.add(const SizedBox(height: _greetingGap));
      }
      cluster.add(
        SizedBox(
          width: composerWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: composerBlock,
          ),
        ),
      );
    }
    if (widget.suggestions != null) {
      if (cluster.isNotEmpty) {
        cluster.add(const SizedBox(height: _suggestionsGapWide));
      }
      cluster.add(SizedBox(width: suggestionsWidth, child: widget.suggestions));
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(_sideInset),
        child: Column(mainAxisSize: MainAxisSize.min, children: cluster),
      ),
    );
  }

  /// The docked composer block: starters and strip above the input, on the
  /// content rail, inside the surface padding. Skipped entirely when there
  /// is nothing to put below the thread, so a read-only surface doesn't
  /// carry a strip of padding where its composer would have been.
  List<Widget> _composerZone(bool compact) {
    final suggestions = widget.empty ? widget.suggestions : null;
    if (widget.composer == null &&
        widget.aboveComposer == null &&
        suggestions == null) {
      return const [];
    }

    final padding =
        widget.padding ??
        EdgeInsetsDirectional.fromSTEB(
          _sideInset,
          0,
          _sideInset,
          compact ? _bottomInsetCompact : _bottomInsetWide,
        );

    final column = <Widget>[];
    if (suggestions != null) {
      column.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _suggestionsExtraInset,
          ),
          child: suggestions,
        ),
      );
    }
    if (widget.aboveComposer != null) {
      if (column.isNotEmpty) {
        column.add(const SizedBox(height: _suggestionsGapCompact));
      }
      column.add(widget.aboveComposer!);
    }
    if (widget.composer != null) {
      if (widget.aboveComposer != null) {
        column.add(const SizedBox(height: _composerGap));
      } else if (column.isNotEmpty) {
        column.add(const SizedBox(height: _suggestionsGapCompact));
      }
      column.add(widget.composer!);
    }

    return [
      Padding(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: column,
            ),
          ),
        ),
      ),
    ];
  }
}
