import 'package:flutter/material.dart';

import 'playground_item.dart';
import 'shell_palette.dart';

/// The slide-in code panel: a 400px pane with a filename header and a
/// snippet body. Snippets arrive with the demos — for now the body holds
/// a placeholder comment, but the header already tracks the selection.
class CodePanel extends StatelessWidget {
  const CodePanel({
    super.key,
    required this.open,
    required this.item,
    required this.onClose,
  });

  final bool open;
  final PlaygroundItem item;
  final VoidCallback onClose;

  static const double _width = 400;
  static const Duration _slide = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final shell = ShellPalette.of(context);

    return AnimatedContainer(
      duration: _slide,
      curve: Curves.ease,
      width: open ? _width : 0,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: shell.codeBg,
        border: open
            ? Border(left: BorderSide(color: shell.border))
            : const Border(),
      ),
      // Fixed-width inner pane so the content doesn't reflow while the
      // panel animates — it slides, per the design.
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: open ? 1 : 0,
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: _width,
          maxWidth: _width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: shell.codeHeaderBg,
                  border: Border(bottom: BorderSide(color: shell.codeBorder)),
                ),
                child: Row(
                  children: [
                    Text(
                      item.codeFile,
                      style: _mono(size: 12, color: shell.codeHeaderText),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: shell.codeBorder),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Text(
                        'DART',
                        style: shellText(
                          size: 10,
                          weight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: shell.codeHeaderText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: shell.codeChip,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_outlined,
                            size: 13,
                            color: shell.text,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Copy',
                            style: shellText(
                              size: 12,
                              weight: FontWeight.w500,
                              color: shell.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: shell.codeChip,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: shell.codeHeaderText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '// Component demos land here next.',
                      style: _mono(
                        size: 12,
                        height: 1.7,
                        color: shell.codeText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The design sets code in Geist; the playground doesn't bundle it, so
  /// this leans on the platform's monospace stack.
  static TextStyle _mono({double? size, double? height, Color? color}) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier'],
      fontSize: size,
      height: height,
      color: color,
    );
  }
}
