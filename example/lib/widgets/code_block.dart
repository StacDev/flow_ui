import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Example-only code snippet display with copy-to-clipboard.
///
/// The package's own Code block component will replace this once built.
class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.code, this.bare = false});

  final String code;

  /// When true, skips the border and radius — for embedding inside an
  /// already-decorated container (e.g. DemoPreview's Code tab).
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final spacing = context.flowSpacing;
    final codeStyle = context.flowTypography.bodyMedium.copyWith(
      color: colors.onSurface,
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier New'],
      height: 1.6,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: bare ? null : context.flowRadii.md,
        border: bare ? null : Border.all(color: colors.outlineVariant),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(spacing.lg),
            child: SelectableText(code, style: codeStyle),
          ),
          Positioned(
            top: spacing.xs,
            right: spacing.xs,
            child: IconButton(
              tooltip: 'Copy',
              iconSize: 16,
              icon: Icon(Icons.copy_outlined, color: colors.onSurfaceVariant),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      width: 220,
                    ),
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}
