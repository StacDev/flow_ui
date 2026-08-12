import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/flow_attachment.dart';
import '../theme/flow_theme.dart';
import '../utils/flow_circle_button.dart';
import '../utils/flow_state_colors.dart';
import 'flow_attachment_group.dart';

/// The message input area: an auto-growing text field with an action bar
/// and a send button that morphs into stop while [isStreaming].
///
/// ```dart
/// FlowComposer(
///   placeholder: 'Message…',
///   isStreaming: generating,
///   onSend: (text) => startGeneration(text),
///   onStop: cancelGeneration,
///   leadingActions: [FlowAddMenu(...)],
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
    this.placeholder,
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

  /// Host-localized hint text.
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

  /// Bottom-left slot, e.g. a `FlowAddMenu`.
  final List<Widget> leadingActions;

  /// Bottom-right slot before the send button, e.g. a `FlowModelSelector`.
  final List<Widget> trailingActions;

  @override
  State<FlowComposer> createState() => _FlowComposerState();
}

class _FlowComposerState extends State<FlowComposer> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  late FocusNode _attachedFocusNode;
  bool _focused = false;

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

  Widget _buildSendStopButton(BuildContext context) {
    final colors = context.flowColors;
    if (widget.isStreaming) {
      return FlowCircleButton(
        icon: Icons.stop_rounded,
        background: colors.primary,
        foreground: colors.onPrimary,
        onTap: widget.onStop,
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final canSend = widget.enabled && value.text.trim().isNotEmpty;
        return FlowCircleButton(
          icon: Icons.arrow_upward,
          background: canSend ? colors.primary : colors.surfaceContainerHigh,
          foreground: canSend
              ? colors.onPrimary
              : flowDisabledColor(colors.onSurfaceVariant),
          onTap: canSend ? _send : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final spacing = context.flowSpacing;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: context.flowRadii.lg,
        border: Border.all(
          color: _focused ? colors.primary : colors.outlineVariant,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        spacing.lg,
        spacing.sm,
        spacing.sm,
        spacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.attachments.isNotEmpty) ...[
            FlowAttachmentGroup(
              attachments: widget.attachments,
              onTap: widget.onAttachmentTap,
              // Editing is what `enabled` gates; viewing an attachment that
              // is already pending stays available, as does the send button
              // while streaming.
              onRemove: widget.enabled ? widget.onRemoveAttachment : null,
              removeTooltip: widget.removeAttachmentTooltip,
              previewCloseTooltip: widget.previewCloseTooltip,
            ),
            SizedBox(height: spacing.sm),
          ],
          Focus(
            onKeyEvent: _handleKeyEvent,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              minLines: 1,
              maxLines: widget.maxLines,
              style: typography.bodyLarge.copyWith(color: colors.onSurface),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: typography.bodyLarge.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: spacing.sm),
              ),
            ),
          ),
          SizedBox(height: spacing.xs),
          Row(
            children: [
              for (final action in widget.leadingActions) ...[
                action,
                SizedBox(width: spacing.xs),
              ],
              const Spacer(),
              for (final action in widget.trailingActions) ...[
                action,
                SizedBox(width: spacing.sm),
              ],
              _buildSendStopButton(context),
            ],
          ),
        ],
      ),
    );
  }
}
