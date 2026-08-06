import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'code_block.dart';

/// Example-only demo card with Preview / Code tabs, like component doc sites.
class DemoPreview extends StatefulWidget {
  const DemoPreview({
    super.key,
    required this.preview,
    required this.code,
    this.minHeight = 140,
  });

  /// The live widget shown on the Preview tab.
  final Widget preview;

  /// The usage snippet shown on the Code tab.
  final String code;

  final double minHeight;

  @override
  State<DemoPreview> createState() => _DemoPreviewState();
}

class _DemoPreviewState extends State<DemoPreview> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final spacing = context.flowSpacing;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: context.flowRadii.lg,
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: spacing.sm),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              children: [
                _TabButton(
                  label: 'Preview',
                  selected: !_showCode,
                  onTap: () => setState(() => _showCode = false),
                ),
                _TabButton(
                  label: 'Code',
                  selected: _showCode,
                  onTap: () => setState(() => _showCode = true),
                ),
              ],
            ),
          ),
          if (!_showCode)
            Container(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              padding: EdgeInsets.all(spacing.lg),
              alignment: Alignment.centerLeft,
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

class _TabButton extends StatelessWidget {
  const _TabButton({
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
    final spacing = context.flowSpacing;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.md,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? colors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: context.flowTypography.labelLarge.copyWith(
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
