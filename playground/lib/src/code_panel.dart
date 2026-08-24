import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
// The built-in highlighter isn't part of the public barrel; the
// playground lives beside the package and reaches in for it so the
// panel can typeset its snippets in the code block's own style without
// the package growing panel-only API.
// ignore: implementation_imports
import 'package:flow_ui/src/utils/flow_syntax_highlighter.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'demo_registry.dart';
import 'playground_item.dart';
import 'shell_palette.dart';

/// The slide-in code panel, resizable by its left edge. The snippet is
/// typeset in the package's code block style — the built-in highlighter
/// over the theme's syntax tokens and mono face — directly on the
/// panel's ground, with copy and close as header chips. It follows the
/// stage: switching the variant pills swaps the code to match what's
/// being shown.
class CodePanel extends StatefulWidget {
  const CodePanel({
    super.key,
    required this.open,
    required this.item,
    this.variant,
    required this.onClose,
  });

  final bool open;
  final PlaygroundItem item;

  /// The stage's active variant; null renders the item's default form.
  final String? variant;

  final VoidCallback onClose;

  @override
  State<CodePanel> createState() => _CodePanelState();
}

class _CodePanelState extends State<CodePanel> {
  /// The pane resizes by its left edge, between the design's default
  /// width and a cap that keeps the stage usable.
  static const double _minWidth = 400;
  static const double _maxWidth = 720;
  static const Duration _slide = Duration(milliseconds: 250);

  double _width = _minWidth;
  bool _dragging = false;

  /// The copy confirmation, per the package's contract: the block
  /// reports intent, the panel owns the clipboard and the timing.
  bool _copied = false;
  Timer? _reset;

  @override
  void didUpdateWidget(CodePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item || widget.variant != oldWidget.variant) {
      _reset?.cancel();
      _reset = null;
      _copied = false;
    }
  }

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);
    final code = snippetFor(widget.item, variant: widget.variant);

    return AnimatedContainer(
      // Zero while dragging: the width must track the pointer, not ease
      // after it — the slide animates only opening and closing.
      duration: _dragging ? Duration.zero : _slide,
      curve: Curves.ease,
      width: widget.open ? _width : 0,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: shell.codeBg,
        border: widget.open
            ? Border(left: BorderSide(color: shell.border))
            : const Border(),
      ),
      // Fixed-width inner pane so the content doesn't reflow while the
      // panel animates — it slides, per the design.
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.open ? 1 : 0,
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: _width,
          maxWidth: _width,
          child: Stack(
            children: [
              Positioned.fill(child: _pane(shell, code)),
              // The resize handle rides the pane's left edge: drag to
              // widen between the min and max.
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: 8,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (_) =>
                        setState(() => _dragging = true),
                    onHorizontalDragUpdate: (details) => setState(() {
                      _width = (_width - details.delta.dx).clamp(
                        _minWidth,
                        _maxWidth,
                      );
                    }),
                    onHorizontalDragEnd: (_) =>
                        setState(() => _dragging = false),
                    onHorizontalDragCancel: () =>
                        setState(() => _dragging = false),
                    // Double-tap snaps back to the default width.
                    onDoubleTap: () => setState(() => _width = _minWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The header's 24px action chip — copy and close share the form.
  Widget _headerChip(
    ShellPalette shell, {
    required VoidCallback onTap,
    required Widget child,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: shell.codeChip,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _pane(ShellPalette shell, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
          child: Row(
            children: [
              Text(
                'Code',
                style: shellText(
                  size: 12,
                  weight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: shell.codeHeaderText,
                ),
              ),
              const Spacer(),
              // The copy affordance, always visible beside the close
              // chip: copy, then a primary-tinted check while the
              // confirmation lasts.
              Tooltip(
                message: 'Copy code',
                child: _headerChip(
                  shell,
                  onTap: () => _copy(code),
                  child: Icon(
                    _copied ? Icons.check : Icons.copy_outlined,
                    size: 14,
                    color: _copied
                        ? context.flowColors.primary
                        : shell.codeHeaderText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _headerChip(
                shell,
                onTap: widget.onClose,
                child: Icon(
                  PhosphorIconsRegular.x,
                  size: 14,
                  color: shell.codeHeaderText,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText.rich(
                FlowSyntaxHighlighter.highlight(
                  code,
                  language: FlowCodeLanguage.find('dart'),
                  style: context.flowTypography.code.copyWith(
                    color: context.flowColors.onSurface,
                  ),
                  colors: context.flowSyntaxColors,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
