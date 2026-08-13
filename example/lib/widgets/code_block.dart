import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

/// The gallery's Dart highlighters, initialized once at startup.
///
/// `syntax_highlight` loads its TextMate grammar and themes from bundled
/// assets, so setup is async; `main` awaits [init] before running the app
/// and every [CodeBlock] then highlights synchronously.
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
    final codeStyle = context.flowTypography.bodyMedium.copyWith(
      color: colors.onSurface,
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier New'],
      height: 1.6,
    );

    // VS Code's Dart grammar, in the theme matching the ambient brightness;
    // the base style keeps the mono font and line height, the spans carry
    // per-token color. Plain text is the fallback if init hasn't run.
    final highlighter = CodeHighlighting.of(Theme.of(context).brightness);
    final content = highlighter == null
        ? TextSpan(text: code, style: codeStyle)
        : TextSpan(style: codeStyle, children: [highlighter.highlight(code)]);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: bare ? null : const BorderRadius.all(Radius.circular(12)),
        border: bare ? null : Border.all(color: colors.outlineVariant),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: SelectableText.rich(content),
          ),
          Positioned(
            top: 4,
            right: 4,
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
