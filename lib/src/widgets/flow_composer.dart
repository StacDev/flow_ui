import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../models/flow_attachment.dart';
import '../styles/flow_composer_style.dart';
import '../theme/flow_theme.dart';
import '../utils/flow_circle_button.dart';
import '../utils/flow_gradient_outline.dart';
import 'flow_attachment_group.dart';
import 'flow_pill.dart';

/// The message input area: an auto-growing text field with an action bar
/// and a send button that morphs into stop while [isStreaming].
///
/// ```dart
/// FlowComposer(
///   placeholder: 'Message…',
///   isStreaming: generating,
///   onSend: (text) => startGeneration(text),
///   onStop: cancelGeneration,
///   leadingActions: [FlowMenu(...)],
///   trailingActions: [FlowModelSelector(...)],
/// )
/// ```
///
/// On hardware keyboards Enter sends and Shift+Enter inserts a newline
/// (when [submitOnEnter]); mobile soft keyboards keep their newline key and
/// use the send button.
class FlowComposer extends StatefulWidget {
  const FlowComposer({
    super.key,
    required this.onSend,
    this.onStop,
    this.isStreaming = false,
    this.controller,
    this.focusNode,
    this.placeholder = 'How can I help you today?',
    this.enabled = true,
    this.clearOnSend = true,
    this.submitOnEnter = true,
    this.maxLines = 6,
    this.attachments = const [],
    this.onRemoveAttachment,
    this.onAttachmentTap,
    this.removeAttachmentTooltip,
    this.previewCloseTooltip,
    this.leadingActions = const [],
    this.trailingActions = const [],
    this.padding,
    this.borderRadius,
    this.style,
  }) : assert(maxLines > 0, 'maxLines must be positive');

  /// Called with the trimmed text; never with empty text.
  final ValueChanged<String> onSend;

  /// Stop generation; wired to the button while [isStreaming].
  final VoidCallback? onStop;

  /// While true the send button becomes a stop button.
  final bool isStreaming;

  /// Optional external controller; an internal one is used when null.
  final TextEditingController? controller;

  /// Optional external focus node; an internal one is used when null.
  final FocusNode? focusNode;

  /// Hint text in the empty field. Defaults to the design's greeting —
  /// the one string the package ships, so localized hosts should pass
  /// their own copy. An explicit null renders no hint at all.
  final String? placeholder;

  final bool enabled;

  /// Clear the field after a successful send.
  final bool clearOnSend;

  /// Enter sends, Shift+Enter newlines (hardware keyboards).
  final bool submitOnEnter;

  /// Auto-grow cap; the field scrolls beyond it.
  final int maxLines;

  /// Pending attachments, shown above the input. Empty renders nothing.
  final List<FlowAttachment> attachments;

  /// Called with the id of the attachment whose remove button was tapped.
  final ValueChanged<String>? onRemoveAttachment;

  /// Called with the tapped attachment's id, *instead of* opening the
  /// built-in full-screen preview. Call `showFlowAttachmentPreview` from the
  /// handler to keep it alongside your own handling.
  final ValueChanged<String>? onAttachmentTap;

  /// Host-localized label for the remove button on each attachment.
  final String? removeAttachmentTooltip;

  /// Host-localized label for the built-in preview's close button.
  final String? previewCloseTooltip;

  /// Bottom-left slot, e.g. a `FlowMenu`.
  final List<Widget> leadingActions;

  /// Bottom-right slot before the send button, e.g. a `FlowModelSelector`.
  final List<Widget> trailingActions;

  /// Inside the card, around the field and action bar. Defaults to the
  /// design's 16 at the start and 8 elsewhere.
  final EdgeInsetsGeometry? padding;

  /// The card's corner. Defaults to the design's 24.
  final BorderRadius? borderRadius;

  /// Per-instance restyling, merged over [FlowTheme.composerStyle]'s
  /// fields; nulls fall through to the theme tokens.
  final FlowComposerStyle? style;

  @override
  State<FlowComposer> createState() => _FlowComposerState();
}

class _FlowComposerState extends State<FlowComposer> {
  /// The design's card: 24px corners padded 19 above and 11 below (the
  /// outline's 1px included), its content — attachment strip and field —
  /// inset 18 further from the sides while the action row tucks in at 10,
  /// under a soft ambient shadow.
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(24));
  static const EdgeInsetsGeometry _cardPadding = EdgeInsetsDirectional.fromSTEB(
    1,
    19,
    1,
    11,
  );
  static const double _contentInset = 18;
  static const double _actionInset = 10;
  static const double _attachmentGap = 12;
  static const double _fieldGap = 16;
  static const double _leadingGap = 4;
  static const double _trailingGap = 8;

  /// Between two neighbouring pills in the action row — the design's 8,
  /// closing to 6 on phones.
  static const double _pillGap = 8;
  static const double _mobilePillGap = 6;

  /// The field's floor, sized so an empty composer stands at the design's
  /// 116px: 19 + 38 + 16 (gap) + 32 (action row) + 11.
  static const double _fieldMinHeight = 38;

  /// The design's outline: a 1px hairline over the ink, sweeping from the
  /// top-left toward the bottom-right where it thins — 14% → 8% at rest,
  /// 20% → 12% while the composer is hovered or focused.
  static const double _outlineRestAlpha = 0.14;
  static const double _outlineRestFadeAlpha = 0.08;
  static const double _outlineActiveAlpha = 0.20;
  static const double _outlineActiveFadeAlpha = 0.12;

  /// Send and stop are the design's ringed button: a 26px disc inside a
  /// surface-colored gap and a 1px ring, on a 32px frame.
  static const double _buttonFrame = 32;
  static const double _buttonDisc = 26;

  /// Centers the stop glyph on the disc (26 = 18 + 2 × 4).
  static const double _stopPadding = 4;

  /// The card's lift, as an alpha over the ink — the attachment tiles'
  /// idiom at the composer's tighter blur.
  static const double _shadowOpacity = 0.02;
  static const double _shadowBlur = 12;

  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  late FocusNode _attachedFocusNode;
  bool _focused = false;
  bool _hovered = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _attachedFocusNode = _focusNode..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(FlowComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode != _attachedFocusNode) {
      _attachedFocusNode.removeListener(_handleFocusChange);
      _attachedFocusNode = _focusNode..addListener(_handleFocusChange);
      _handleFocusChange();
    }
  }

  @override
  void dispose() {
    _attachedFocusNode.removeListener(_handleFocusChange);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focused != _attachedFocusNode.hasFocus) {
      setState(() => _focused = _attachedFocusNode.hasFocus);
    }
  }

  /// The effective style: the widget's over the theme's, tokens beneath.
  FlowComposerStyle? _styleOf(BuildContext context) =>
      context.flowTheme.composerStyle?.merge(widget.style) ?? widget.style;

  /// The theme's platform rather than the real one, like the menus' sheet
  /// resolution, so hosts and tests can steer it without a device.
  static bool _isMobile(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.android;
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    if (widget.clearOnSend) _controller.clear();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.submitOnEnter || widget.isStreaming) {
      return KeyEventResult.ignored;
    }
    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (event is KeyDownEvent &&
        isEnter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _send();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// The design's button anatomy: the disc floats inside a gap of the
  /// card's own surface, enclosed by a hairline ring — the ring muted while
  /// the button can't act, so the geometry never jumps on enable.
  Widget _ringed(
    BuildContext context, {
    required bool active,
    required Widget disc,
  }) {
    final colors = context.flowColors;
    final style = _styleOf(context);
    return Container(
      width: _buttonFrame,
      height: _buttonFrame,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: style?.backgroundColor ?? colors.surfaceBright,
        shape: CircleBorder(
          side: BorderSide(
            color: active
                ? (style?.sendBackgroundColor ?? colors.primary)
                : colors.outline,
          ),
        ),
      ),
      child: SizedBox.square(dimension: _buttonDisc, child: disc),
    );
  }

  Widget _buildSendStopButton(BuildContext context) {
    final colors = context.flowColors;
    final style = _styleOf(context);
    final discColor = style?.sendBackgroundColor ?? colors.primary;
    final glyphColor = style?.sendForegroundColor ?? colors.onPrimary;
    if (widget.isStreaming) {
      return _ringed(
        context,
        active: true,
        disc: FlowCircleButton(
          icon: Icons.stop_rounded,
          background: discColor,
          foreground: glyphColor,
          padding: _stopPadding,
          onTap: widget.onStop,
        ),
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final canSend = widget.enabled && value.text.trim().isNotEmpty;
        return _ringed(
          context,
          active: canSend,
          disc: Material(
            // Disabled keeps the arrow's ink and only drains the disc:
            // primary gives way to the 30% disabled wash.
            color: canSend ? discColor : colors.onSurfaceDisabled,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: canSend ? _send : null,
              customBorder: const CircleBorder(),
              child: CustomPaint(
                // The design's arrow is a thin stroke, not the chunky
                // Material glyph.
                painter: _ArrowUpPainter(color: glyphColor),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;

    final active = widget.enabled && (_focused || _hovered);
    final radius = widget.borderRadius ?? _cardRadius;
    final style = _styleOf(context);
    // A style's outline flattens the default gradient to one solid color
    // in every state, like the menu card's border override does.
    final outline = style?.outlineColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: CustomPaint(
        // The outline is painted rather than a layout border so the card
        // never shifts as it swaps between its rest and active gradients.
        foregroundPainter: FlowGradientOutlinePainter(
          radius: radius,
          start:
              outline ??
              colors.onSurface.withValues(
                alpha: active ? _outlineActiveAlpha : _outlineRestAlpha,
              ),
          end:
              outline ??
              colors.onSurface.withValues(
                alpha: active ? _outlineActiveFadeAlpha : _outlineRestFadeAlpha,
              ),
        ),
        child: Container(
          decoration: BoxDecoration(
            // The composer is the design's raised card: it sits above the
            // page rather than tinting it, in both themes, under a
            // barely-there ambient lift.
            color: style?.backgroundColor ?? colors.surfaceBright,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: colors.onSurface.withValues(alpha: _shadowOpacity),
                blurRadius: _shadowBlur,
              ),
            ],
          ),
          padding: widget.padding ?? _cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.attachments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _contentInset,
                  ),
                  child: FlowAttachmentGroup(
                    attachments: widget.attachments,
                    onTap: widget.onAttachmentTap,
                    // Editing is what `enabled` gates; viewing an attachment
                    // that is already pending stays available, as does the send
                    // button while streaming.
                    onRemove: widget.enabled ? widget.onRemoveAttachment : null,
                    removeTooltip: widget.removeAttachmentTooltip,
                    previewCloseTooltip: widget.previewCloseTooltip,
                  ),
                ),
                const SizedBox(height: _attachmentGap),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _contentInset),
                child: Container(
                  constraints: const BoxConstraints(minHeight: _fieldMinHeight),
                  alignment: AlignmentDirectional.topStart,
                  child: Focus(
                    onKeyEvent: _handleKeyEvent,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      minLines: 1,
                      maxLines: widget.maxLines,
                      style: typography.bodyLarge
                          .copyWith(height: 1.3, color: colors.onSurface)
                          .merge(style?.textStyle),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: widget.placeholder,
                        hintStyle: typography.bodyLarge.copyWith(
                          height: 1.3,
                          color: style?.hintColor ?? colors.onSurfaceMuted,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _fieldGap),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _actionInset),
                child: Row(
                  children: [
                    for (var i = 0; i < widget.leadingActions.length; i++) ...[
                      widget.leadingActions[i],
                      // Two neighbouring pills read as a set and take the
                      // design's wider step — 8, closing to 6 on phones —
                      // while everything else keeps the action row's 4.
                      SizedBox(
                        width:
                            i + 1 < widget.leadingActions.length &&
                                widget.leadingActions[i] is FlowPill &&
                                widget.leadingActions[i + 1] is FlowPill
                            ? (_isMobile(context) ? _mobilePillGap : _pillGap)
                            : _leadingGap,
                      ),
                    ],
                    const Spacer(),
                    for (final action in widget.trailingActions) ...[
                      action,
                      const SizedBox(width: _trailingGap),
                    ],
                    _buildSendStopButton(context),
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

/// The send arrow: a thin rounded stroke, matching the design's 1.5-weight
/// mark rather than the Material icon's filled glyph. Drawn to scale with
/// the disc it sits on.
class _ArrowUpPainter extends CustomPainter {
  const _ArrowUpPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.shortestSide / 17
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final center = size.center(Offset.zero);
    // The design's proportions on its 26px disc: a 12-tall stem with a
    // 10-wide head.
    final stem = size.shortestSide * (12 / 26) / 2;
    final head = size.shortestSide * (10 / 26) / 2;
    final top = Offset(center.dx, center.dy - stem);
    canvas.drawLine(top, Offset(center.dx, center.dy + stem), paint);
    final path = Path()
      ..moveTo(center.dx - head, top.dy + head)
      ..lineTo(top.dx, top.dy)
      ..lineTo(center.dx + head, top.dy + head);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowUpPainter oldDelegate) => oldDelegate.color != color;
}
