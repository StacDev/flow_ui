import 'dart:async';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

String codeBlockSnippet([String? variant]) => switch (variant) {
  'json' => _blockFor('json', 'screen.json'),
  'yaml' => _blockFor('yaml', 'deploy.yml'),
  'html' => _blockFor('html', 'index.html'),
  'css' => _blockFor('css', 'stage.css'),
  'sql' => _blockFor('sql', 'threads.sql'),
  'plain' => _plain,
  'streaming' => _streaming,
  _ => _dart,
};

String _blockFor(String language, String filename) =>
    '''
// Highlighting is built in and synchronous — $language is one of the
// nine bundled languages.
FlowCodeBlock(
  code: source,
  language: '$language',
  filename: '$filename',
  copyTooltip: 'Copy code',
  copied: copied,
  onCopy: copy,
)''';

const String _plain = r'''
// No registered language: the block renders plain. Hosts register
// their own rules:
FlowCodeBlock(
  code: buildLog,
  filename: 'build.log',
)

FlowCodeLanguage.register(
  const FlowCodeLanguage(
    id: 'lisp',
    rules: [FlowSyntaxRule(FlowSyntaxToken.comment, r';[^\n]*')],
  ),
);''';

const String _streaming = '''
// A fence still arriving: the copy affordance stays hidden until the
// code settles, exactly like a streaming FlowCodePart in a thread.
FlowCodeBlock(
  code: arrivedSoFar, // grows as chunks land
  language: 'dart',
  filename: 'point.dart',
  isStreaming: true,
)''';

const String _dart = r'''
// The block reports intent; the host owns the clipboard and the
// confirmation's timing.
FlowCodeBlock(
  code: source,
  language: 'dart',
  filename: 'point.dart',
  copyTooltip: 'Copy code',
  copied: copied,
  onCopy: () async {
    await Clipboard.setData(ClipboardData(text: source));
    setState(() => copied = true);
  },
)

// In a thread, FlowCodePart renders blocks and copy hands back the part:
FlowThread(
  messages: messages,
  codeCopyTooltip: 'Copy code',
  copiedCodePart: copiedPart,
  onCodeCopy: (part) => copy(part),
)

// Unknown languages render plain; hosts can register their own:
FlowCodeLanguage.register(
  const FlowCodeLanguage(
    id: 'lisp',
    rules: [FlowSyntaxRule(FlowSyntaxToken.comment, r';[^\n]*')],
  ),
);''';

/// Dart with some of everything the highlighter distinguishes: comments,
/// strings, numbers, keywords, types, calls and an annotation.
const String _dartSample = r'''
import 'dart:math';

/// A point on the unit circle.
class Point {
  const Point(this.x, this.y);

  final double x;
  final double y;

  @override
  String toString() => 'Point($x, $y)';
}

Point pointAt(num turns) {
  final angle = turns * 2 * pi;
  return Point(cos(angle), sin(angle));
}

void main() {
  for (var i = 0; i < 4; i++) {
    // Quarter turns land on the axes.
    print(pointAt(i / 4));
  }
}''';

/// A Stac screen payload — keys read apart from string values, and the
/// long line exercises the block's horizontal scroll.
const String _jsonSample = r'''
{
  "type": "scaffold",
  "appBar": {"type": "appBar", "title": {"type": "text", "data": "Home"}},
  "body": {
    "type": "column",
    "children": [
      {"type": "text", "data": "Hello, Stac!", "maxLines": 1},
      {"type": "sizedBox", "height": 12.5},
      {"type": "button", "enabled": true, "onTap": null}
    ]
  }
}''';

/// Keys against strings and booleans — and `on:` reading as a key, not
/// a boolean.
const String _yamlSample = r'''
# Deploy the playground on push.
name: deploy
on:
  push:
    branches: [main]

env:
  FLUTTER_VERSION: "3.44"

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: flutter build web --release
      - run: firebase deploy --only hosting
        if: startsWith(github.ref, 'refs/heads/main')''';

/// Tags, attributes and entities; quoted prose in text content stays
/// plain.
const String _htmlSample = r'''
<!doctype html>
<!-- The playground's shell. -->
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Flow UI</title>
  </head>
  <body>
    <div id="output" class="stage dark">
      <p>Rendering &amp; ready.</p>
    </div>
    <script src="main.dart.js" defer></script>
  </body>
</html>''';

/// Selectors, custom properties, units and value functions.
const String _cssSample = r'''
/* The stage's ground. */
:root {
  --stage-ink: #1e1e1e;
  --stage-gap: 1.5rem;
}

.stage {
  display: grid;
  gap: var(--stage-gap);
  padding: 24px 16px;
  color: var(--stage-ink);
}

.stage:hover > .pill {
  opacity: 0.75;
  transition: opacity 200ms ease;
}

@media (max-width: 760px) {
  .stage { padding: 12px; }
}''';

/// Keywords in either case, quoted strings, bind-style aliases.
const String _sqlSample = r'''
-- Threads with their newest message.
SELECT t.id, t.title, m.body AS latest
FROM threads AS t
JOIN messages AS m ON m.thread_id = t.id
WHERE m.created_at = (
  SELECT MAX(created_at) FROM messages
  WHERE thread_id = t.id
)
  AND t.visibility = 'public'
ORDER BY m.created_at DESC
LIMIT 20;''';

/// No language: plain ink, header from the filename alone.
const String _plainSample = r'''
$ flutter build web --release
Compiling lib/main.dart for the web...             12.4s
Font asset "MaterialIcons-Regular.otf" was tree-shaken.
Built build/web in release mode.''';

/// Stage demo for `FlowCodeBlock` — highlighted Dart and JSON, a plain
/// fallback, and a streaming feed. The demo owns the clipboard write and
/// the copied confirmation, the way a host would.
class CodeBlockDemo extends StatefulWidget {
  const CodeBlockDemo({super.key, this.variant});

  final String? variant;

  @override
  State<CodeBlockDemo> createState() => _CodeBlockDemoState();
}

class _CodeBlockDemoState extends State<CodeBlockDemo> {
  static const Duration _feedTick = Duration(milliseconds: 45);
  static const int _feedStep = 6;
  static const Duration _feedRestart = Duration(milliseconds: 1400);

  bool _copied = false;
  Timer? _reset;

  /// Streaming variant: how much of the sample has "arrived".
  int _fed = 0;
  Timer? _feed;

  bool get _streaming => widget.variant == 'streaming';

  @override
  void initState() {
    super.initState();
    if (_streaming) _startFeed();
  }

  @override
  void dispose() {
    _reset?.cancel();
    _feed?.cancel();
    super.dispose();
  }

  void _startFeed() {
    _fed = 0;
    _feed = Timer.periodic(_feedTick, (timer) {
      setState(() {
        _fed = (_fed + _feedStep).clamp(0, _dartSample.length);
      });
      if (_fed == _dartSample.length) {
        timer.cancel();
        _feed = Timer(_feedRestart, () {
          if (mounted) setState(_startFeed);
        });
      }
    });
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
    final (code, language, filename) = switch (widget.variant) {
      'json' => (_jsonSample, 'json', 'screen.json'),
      'yaml' => (_yamlSample, 'yaml', 'deploy.yml'),
      'html' => (_htmlSample, 'html', 'index.html'),
      'css' => (_cssSample, 'css', 'stage.css'),
      'sql' => (_sqlSample, 'sql', 'threads.sql'),
      'plain' => (_plainSample, null, 'build.log'),
      'streaming' => (_dartSample.substring(0, _fed), 'dart', 'point.dart'),
      _ => (_dartSample, 'dart', 'point.dart'),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: FlowCodeBlock(
            code: code,
            language: language,
            filename: filename,
            copyTooltip: 'Copy code',
            copied: _copied,
            isStreaming: _streaming && _fed < _dartSample.length,
            onCopy: () => _copy(code),
          ),
        ),
      ),
    );
  }
}
