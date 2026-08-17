import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import 'demo_registry.dart';
import 'playground_item.dart';
import 'shell_palette.dart';

/// The playground's Dart highlighters, initialized once at startup.
///
/// `syntax_highlight` loads its TextMate grammar and themes from bundled
/// assets, so setup is async; `main` awaits [init] before running the app
/// and the panel then highlights synchronously. Plain text is the fallback
/// if init hasn't run.
class CodeHighlighting {
  CodeHighlighting._();

  static Highlighter? _light;
  static Highlighter? _dark;

  static Future<void> init() async {
    await Highlighter.initialize(['dart']);
    _light = Highlighter(
      language: 'dart',
      theme: await HighlighterTheme.loadLightTheme(),
    );
    _dark = Highlighter(
      language: 'dart',
      theme: await HighlighterTheme.loadDarkTheme(),
    );
  }

  static Highlighter? of(Brightness brightness) =>
      brightness == Brightness.dark ? _dark : _light;
}

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
                    _CopyButton(code: snippetFor(item)),
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
                            PhosphorIconsRegular.x,
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
                    child: _HighlightedCode(
                      code: snippetFor(item),
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

/// The header's copy chip: puts the snippet on the clipboard and reads
/// "Copied!" for a beat, per the design.
class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.code});

  final String code;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _copy,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: shell.codeChip,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _copied
                    ? PhosphorIconsRegular.check
                    : PhosphorIconsRegular.copy,
                size: 13,
                color: shell.text,
              ),
              const SizedBox(width: 6),
              Text(
                _copied ? 'Copied!' : 'Copy',
                style: shellText(
                  size: 12,
                  weight: FontWeight.w500,
                  color: shell.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The snippet through the VS Code Dart grammar, in the theme matching the
/// ambient brightness; the base style keeps the mono font and line height,
/// the spans carry per-token color.
class _HighlightedCode extends StatelessWidget {
  const _HighlightedCode({required this.code, required this.style});

  final String code;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final highlighter = CodeHighlighting.of(Theme.of(context).brightness);
    final content = highlighter == null
        ? TextSpan(text: code, style: style)
        : TextSpan(style: style, children: [highlighter.highlight(code)]);
    return SelectableText.rich(content);
  }
}
