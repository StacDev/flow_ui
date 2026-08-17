import 'package:material_ui/material_ui.dart';

import '../theme/flow_syntax_colors.dart';

// The highlighting engine behind FlowCodeBlock. The registry types are
// re-exported through flow_code_block.dart so hosts can add languages; the
// engine itself is not part of the public surface.
//
// The string-in / TextSpan-out shape follows serverpod's syntax_highlight,
// but where that package walks TextMate grammars loaded from assets (and so
// needs async setup), this one compiles a language's ordered rule table
// into a single alternated regex and colors matches in one synchronous
// pass. Rule order is precedence: at the same position the earlier rule's
// alternative wins, which is how a keyword inside a comment stays a
// comment.

/// The token classes the built-in highlighter distinguishes, each colored
/// by the matching [FlowSyntaxColors] role. Anything no rule claims stays
/// plain ink.
enum FlowSyntaxToken {
  /// Reserved words and control flow — `class`, `if`, `return`.
  keyword,

  /// Type names: uppercase identifiers and language primitives.
  type,

  /// A call or declaration site — an identifier ahead of its `(`.
  function,

  /// String literals, quotes included.
  string,

  /// Numeric literals.
  number,

  /// Comments.
  comment,

  /// Annotations, decorators and shell variables — `@override`, `$HOME`.
  meta,

  /// Brackets, separators and operators.
  punctuation,
}

/// One highlighting rule: every match of [pattern] reads as [token].
///
/// [pattern] is regex *source*, not a [RegExp] — the language joins its
/// rules into one alternation, so a pattern must not contain named groups
/// or numbered backreferences (plain `(…)` groups are fine).
@immutable
class FlowSyntaxRule {
  const FlowSyntaxRule(this.token, this.pattern);

  final FlowSyntaxToken token;
  final String pattern;
}

/// A language the code block can highlight: an id, lookup aliases, and an
/// ordered rule table.
///
/// The built-ins cover the fences an assistant most often emits — Dart,
/// JSON, JavaScript/TypeScript, Python and shell. Hosts extend the set:
///
/// ```dart
/// FlowCodeLanguage.register(
///   const FlowCodeLanguage(
///     id: 'lisp',
///     rules: [FlowSyntaxRule(FlowSyntaxToken.comment, r';[^\n]*')],
///   ),
/// );
/// ```
///
/// Rules earlier in the table take precedence, so comments and strings
/// come first.
@immutable
class FlowCodeLanguage {
  const FlowCodeLanguage({
    required this.id,
    this.aliases = const [],
    required this.rules,
  });

  /// Canonical name, lowercase by convention — what a fence info string
  /// usually carries.
  final String id;

  /// Other names [find] resolves, e.g. `'py'` for `'python'`.
  final List<String> aliases;

  /// Ordered by precedence.
  final List<FlowSyntaxRule> rules;

  static final Map<String, FlowCodeLanguage> _registry = () {
    final map = <String, FlowCodeLanguage>{};
    for (final language in [dart, json, javascript, python, bash, plain]) {
      _add(map, language);
    }
    return map;
  }();

  static void _add(
    Map<String, FlowCodeLanguage> map,
    FlowCodeLanguage language,
  ) {
    map[language.id.toLowerCase()] = language;
    for (final alias in language.aliases) {
      map[alias.toLowerCase()] = language;
    }
  }

  /// Makes [language] resolvable through [find], replacing any earlier
  /// registration of the same id or alias.
  static void register(FlowCodeLanguage language) {
    _add(_registry, language);
    FlowSyntaxHighlighter._invalidate(language.id);
  }

  /// The language for [id] — or an alias, case-insensitively — and null
  /// when unknown: the caller renders plain, never an error.
  static FlowCodeLanguage? find(String? id) {
    if (id == null) return null;
    return _registry[id.trim().toLowerCase()];
  }

  /// No rules: source renders in plain ink. The explicit registration lets
  /// `'text'` fences resolve rather than fall through as unknown (the
  /// rendering is the same either way).
  static const FlowCodeLanguage plain = FlowCodeLanguage(
    id: 'plain',
    aliases: ['text', 'txt'],
    rules: [],
  );

  static const FlowCodeLanguage dart = FlowCodeLanguage(
    id: 'dart',
    rules: [
      FlowSyntaxRule(FlowSyntaxToken.comment, r'//[^\n]*'),
      FlowSyntaxRule(FlowSyntaxToken.comment, r'/\*[\s\S]*?\*/'),
      FlowSyntaxRule(FlowSyntaxToken.string, r"r?'''[\s\S]*?'''"),
      FlowSyntaxRule(FlowSyntaxToken.string, r'r?"""[\s\S]*?"""'),
      FlowSyntaxRule(FlowSyntaxToken.string, r"r?'(?:\\.|[^'\\\n])*'"),
      FlowSyntaxRule(FlowSyntaxToken.string, r'r?"(?:\\.|[^"\\\n])*"'),
      FlowSyntaxRule(FlowSyntaxToken.meta, r'@[A-Za-z_][A-Za-z0-9_]*'),
      FlowSyntaxRule(FlowSyntaxToken.number, r'\b0[xX][0-9a-fA-F_]+\b'),
      FlowSyntaxRule(
        FlowSyntaxToken.number,
        r'\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?\b',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.keyword,
        r'\b(?:abstract|as|assert|async|await|base|break|case|catch|class|'
        r'const|continue|covariant|default|deferred|do|dynamic|else|enum|'
        r'export|extends|extension|external|factory|false|final|finally|for|'
        r'get|hide|if|implements|import|in|interface|is|late|library|mixin|'
        r'new|null|on|operator|part|required|rethrow|return|sealed|set|show|'
        r'static|super|switch|sync|this|throw|true|try|typedef|var|void|when|'
        r'while|with|yield)\b',
      ),
      FlowSyntaxRule(FlowSyntaxToken.type, r'\b(?:int|double|num|bool)\b'),
      FlowSyntaxRule(FlowSyntaxToken.type, r'\b[A-Z][A-Za-z0-9_]*\b'),
      FlowSyntaxRule(
        FlowSyntaxToken.function,
        r'\b[a-z_][A-Za-z0-9_]*(?=\s*\()',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.punctuation,
        r'[{}\[\]().,;:]+|[-+*/%=<>!&|^~?]+',
      ),
    ],
  );

  static const FlowCodeLanguage json = FlowCodeLanguage(
    id: 'json',
    aliases: ['jsonc'],
    rules: [
      // Line comments aren't JSON, but assistants emit them anyway (and
      // jsonc makes them official).
      FlowSyntaxRule(FlowSyntaxToken.comment, r'//[^\n]*'),
      // A key: a string ahead of its colon — must outrank the value rule.
      FlowSyntaxRule(FlowSyntaxToken.type, r'"(?:\\.|[^"\\])*"(?=\s*:)'),
      FlowSyntaxRule(FlowSyntaxToken.string, r'"(?:\\.|[^"\\])*"'),
      FlowSyntaxRule(FlowSyntaxToken.keyword, r'\b(?:true|false|null)\b'),
      FlowSyntaxRule(
        FlowSyntaxToken.number,
        r'-?\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b',
      ),
      FlowSyntaxRule(FlowSyntaxToken.punctuation, r'[{}\[\],:]+'),
    ],
  );

  /// One C-family table serves both: TypeScript is close enough to
  /// JavaScript at highlighting depth that separate tables would only
  /// drift.
  static const FlowCodeLanguage javascript = FlowCodeLanguage(
    id: 'javascript',
    aliases: ['js', 'jsx', 'typescript', 'ts', 'tsx'],
    rules: [
      FlowSyntaxRule(FlowSyntaxToken.comment, r'//[^\n]*'),
      FlowSyntaxRule(FlowSyntaxToken.comment, r'/\*[\s\S]*?\*/'),
      FlowSyntaxRule(FlowSyntaxToken.string, r'`[\s\S]*?`'),
      FlowSyntaxRule(FlowSyntaxToken.string, r"'(?:\\.|[^'\\\n])*'"),
      FlowSyntaxRule(FlowSyntaxToken.string, r'"(?:\\.|[^"\\\n])*"'),
      FlowSyntaxRule(FlowSyntaxToken.meta, r'@[A-Za-z_$][A-Za-z0-9_$]*'),
      FlowSyntaxRule(FlowSyntaxToken.number, r'\b0[xX][0-9a-fA-F_]+n?\b'),
      FlowSyntaxRule(
        FlowSyntaxToken.number,
        r'\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?n?\b',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.keyword,
        r'\b(?:abstract|as|async|await|break|case|catch|class|const|continue|'
        r'debugger|declare|default|delete|do|else|enum|export|extends|false|'
        r'finally|for|from|function|get|if|implements|import|in|infer|'
        r'instanceof|interface|is|keyof|let|namespace|new|null|of|override|'
        r'private|protected|public|readonly|return|satisfies|set|static|'
        r'super|switch|this|throw|true|try|type|typeof|undefined|var|void|'
        r'while|with|yield)\b',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.type,
        r'\b(?:any|bigint|boolean|never|number|object|string|symbol|'
        r'unknown)\b',
      ),
      FlowSyntaxRule(FlowSyntaxToken.type, r'\b[A-Z][A-Za-z0-9_$]*\b'),
      FlowSyntaxRule(
        FlowSyntaxToken.function,
        r'\b[A-Za-z_$][A-Za-z0-9_$]*(?=\s*\()',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.punctuation,
        r'[{}\[\]().,;:]+|[-+*/%=<>!&|^~?]+',
      ),
    ],
  );

  static const FlowCodeLanguage python = FlowCodeLanguage(
    id: 'python',
    aliases: ['py'],
    rules: [
      FlowSyntaxRule(FlowSyntaxToken.comment, r'#[^\n]*'),
      FlowSyntaxRule(
        FlowSyntaxToken.string,
        r"(?:[rbfuRBFU]{1,2})?'''[\s\S]*?'''",
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.string,
        r'(?:[rbfuRBFU]{1,2})?"""[\s\S]*?"""',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.string,
        r"(?:[rbfuRBFU]{1,2})?'(?:\\.|[^'\\\n])*'",
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.string,
        r'(?:[rbfuRBFU]{1,2})?"(?:\\.|[^"\\\n])*"',
      ),
      FlowSyntaxRule(FlowSyntaxToken.meta, r'@[A-Za-z_][A-Za-z0-9_.]*'),
      FlowSyntaxRule(FlowSyntaxToken.number, r'\b0[xXoObB][0-9a-fA-F_]+\b'),
      FlowSyntaxRule(
        FlowSyntaxToken.number,
        r'\b\d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?\b',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.keyword,
        r'\b(?:and|as|assert|async|await|break|case|class|continue|def|del|'
        r'elif|else|except|False|finally|for|from|global|if|import|in|is|'
        r'lambda|match|None|nonlocal|not|or|pass|raise|return|self|True|try|'
        r'while|with|yield)\b',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.type,
        r'\b(?:bool|bytes|dict|float|frozenset|int|list|object|set|str|'
        r'tuple)\b',
      ),
      FlowSyntaxRule(FlowSyntaxToken.type, r'\b[A-Z][A-Za-z0-9_]*\b'),
      FlowSyntaxRule(
        FlowSyntaxToken.function,
        r'\b[a-z_][A-Za-z0-9_]*(?=\s*\()',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.punctuation,
        r'[{}\[\]().,;:]+|[-+*/%=<>!&|@^~]+',
      ),
    ],
  );

  static const FlowCodeLanguage bash = FlowCodeLanguage(
    id: 'bash',
    aliases: ['sh', 'shell', 'zsh'],
    rules: [
      FlowSyntaxRule(FlowSyntaxToken.comment, r'#[^\n]*'),
      FlowSyntaxRule(FlowSyntaxToken.string, r"'[^']*'"),
      FlowSyntaxRule(FlowSyntaxToken.string, r'"(?:\\.|[^"\\])*"'),
      // Variables and expansions get the meta ink — the shell's one real
      // syntax.
      FlowSyntaxRule(
        FlowSyntaxToken.meta,
        r'\$\{[^}\n]*\}|\$[A-Za-z_][A-Za-z0-9_]*|\$[?$!#@*0-9-]',
      ),
      FlowSyntaxRule(
        FlowSyntaxToken.keyword,
        r'\b(?:alias|break|case|cd|continue|declare|do|done|echo|elif|else|'
        r'esac|exit|export|fi|for|function|if|in|local|read|return|select|'
        r'set|shift|source|then|unset|until|while)\b',
      ),
      FlowSyntaxRule(FlowSyntaxToken.number, r'\b\d+\b'),
      FlowSyntaxRule(FlowSyntaxToken.punctuation, r'[|&;<>(){}\[\]=]+'),
    ],
  );
}

/// Colors source through a language's rule table — synchronously: no
/// assets, no setup call, safe to run in `build`.
abstract final class FlowSyntaxHighlighter {
  /// Compiled alternations, keyed by language id. [FlowCodeLanguage.register]
  /// invalidates its id here so a replacement table takes effect.
  static final Map<String, RegExp> _compiled = {};

  static void _invalidate(String id) => _compiled.remove(id);

  static RegExp _patternFor(FlowCodeLanguage language) {
    return _compiled.putIfAbsent(language.id, () {
      // Each rule in its own named group: whichever group a match filled
      // names the rule that won, without counting the rule's internal
      // groups.
      final source = [
        for (var i = 0; i < language.rules.length; i++)
          '(?<g$i>${language.rules[i].pattern})',
      ].join('|');
      return RegExp(source, multiLine: true);
    });
  }

  /// [code] as a single [TextSpan]: plain stretches in [style], each rule
  /// match in the [colors] role of its token. Null or empty [language]
  /// renders the whole string plain.
  static TextSpan highlight(
    String code, {
    FlowCodeLanguage? language,
    required TextStyle style,
    required FlowSyntaxColors colors,
  }) {
    if (language == null || language.rules.isEmpty || code.isEmpty) {
      return TextSpan(text: code, style: style);
    }

    final rules = language.rules;
    final pattern = _patternFor(language);
    final children = <TextSpan>[];
    var position = 0;

    for (final match in pattern.allMatches(code)) {
      if (match.end == match.start) continue;
      if (match.start > position) {
        children.add(TextSpan(text: code.substring(position, match.start)));
      }

      FlowSyntaxToken? token;
      for (var i = 0; i < rules.length; i++) {
        if (match.namedGroup('g$i') != null) {
          token = rules[i].token;
          break;
        }
      }

      children.add(
        TextSpan(
          text: code.substring(match.start, match.end),
          style: token == null
              ? null
              : TextStyle(color: _colorFor(token, colors)),
        ),
      );
      position = match.end;
    }

    if (position < code.length) {
      children.add(TextSpan(text: code.substring(position)));
    }

    return TextSpan(style: style, children: children);
  }

  static Color _colorFor(FlowSyntaxToken token, FlowSyntaxColors colors) {
    return switch (token) {
      FlowSyntaxToken.keyword => colors.keyword,
      FlowSyntaxToken.type => colors.type,
      FlowSyntaxToken.function => colors.function,
      FlowSyntaxToken.string => colors.string,
      FlowSyntaxToken.number => colors.number,
      FlowSyntaxToken.comment => colors.comment,
      FlowSyntaxToken.meta => colors.meta,
      FlowSyntaxToken.punctuation => colors.punctuation,
    };
  }
}
