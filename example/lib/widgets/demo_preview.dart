import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'code_block.dart';

/// Example-only demo card with Preview / Code tabs, like component doc sites.
///
/// The demo renders centered on a clean [FlowColors.surface] stage inside the
/// card, so a small trigger reads as an object on a surface; widgets that
/// expand (a composer, a thread) naturally fill the stage width.
class DemoPreview extends StatefulWidget {
  const DemoPreview({
    super.key,
    required this.preview,
    required this.code,
    this.minHeight = 140,
    this.alignment = Alignment.center,
  });

  /// The live widget shown on the Preview tab.
  final Widget preview;

  /// The usage snippet shown on the Code tab.
  final String code;

  final double minHeight;

  /// Where the demo sits on the stage. Centered by default, which presents
  /// small widgets well; text demos pass [Alignment.centerLeft] so a
  /// growing paragraph reads left to right instead of expanding from the
  /// middle.
  final Alignment alignment;

  @override
  State<DemoPreview> createState() => _DemoPreviewState();
}

class _DemoPreviewState extends State<DemoPreview> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _TabSwitch(
                  showCode: _showCode,
                  onChanged: (value) => setState(() => _showCode = value),
                ),
              ],
            ),
          ),
          if (!_showCode)
            Container(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              padding: const EdgeInsets.all(16),
              alignment: widget.alignment,
              color: colors.surface,
              child: widget.preview,
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: CodeBlock(code: widget.code, bare: true),
            ),
        ],
      ),
    );
  }
}

/// The compact Preview | Code segmented switch in the card header.
class _TabSwitch extends StatelessWidget {
  const _TabSwitch({required this.showCode, required this.onChanged});

  final bool showCode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Preview',
            selected: !showCode,
            onTap: () => onChanged(false),
          ),
          _Segment(
            label: 'Code',
            selected: showCode,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return Material(
      color: selected ? colors.surface : Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: selected ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            label,
            style: context.flowTypography.labelMedium.copyWith(
              color: selected ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
