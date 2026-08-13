import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _columnSnippet = '''
FlowSuggestionGroup(
  // The design's primary form: full-width plain rows, 6px apart.
  layout: FlowSuggestionLayout.column,
  suggestions: [
    FlowSuggestion(
      label: 'Write an essay about life and enjoyment',
      icon: Icons.article_outlined,
      onTap: () => send('Write an essay about life and enjoyment'),
    ),
    FlowSuggestion(
      label: 'Create a Monday briefing about my tasks',
      icon: Icons.event_available_outlined,
      onTap: () => send('Create a Monday briefing about my tasks'),
    ),
  ],
)''';

const String _scrollSnippet = '''
FlowSuggestionGroup(
  // The default: one strip that scrolls, no scrollbar. outlined
  // draws each row on the faint fill and hairline, in full ink.
  suggestions: [
    for (final prompt in prompts)
      FlowSuggestion(
        label: prompt,
        outlined: true,
        onTap: () => send(prompt),
      ),
  ],
)''';

const String _wrapSnippet = '''
FlowSuggestionGroup(
  layout: FlowSuggestionLayout.wrap,
  suggestions: [
    FlowSuggestion(
      label: 'Summarize this thread',
      icon: Icons.summarize_outlined,
      outlined: true,
      onTap: () => send('Summarize this thread'),
    ),
    // No onTap → disabled.
    FlowSuggestion(label: 'Run a deep research pass', outlined: true),
  ],
)''';

const String _composerSnippet = '''
Column(
  children: [
    FlowSuggestionGroup(
      // Empty once the thread starts — the group then takes no space.
      layout: FlowSuggestionLayout.column,
      suggestions: [
        for (final prompt in starters)
          FlowSuggestion(
            label: prompt,
            onTap: () => controller.text = prompt,
          ),
      ],
    ),
    const SizedBox(height: 8),
    FlowComposer(controller: controller, onSend: send),
  ],
)''';

/// Demo for [FlowSuggestion] and [FlowSuggestionGroup].
class SuggestionPage extends StatelessWidget {
  const SuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Suggestions',
      className: 'FlowSuggestion & FlowSuggestionGroup',
      description:
          'Prompt starters as tappable rows, in two variants: plain rows in '
          'the secondary ink, and outlined rows on a faint fill in full ink. '
          'The group lays them out as a column (full-width, the design\'s '
          'primary form), a scrolling strip, or a wrap; a row without a '
          'callback renders disabled.',
      children: [
        SectionHeader('Column'),
        DemoPreview(
          preview: _ColumnDemo(),
          code: _columnSnippet,
          alignment: Alignment.centerLeft,
        ),
        SectionHeader('Scrolling strip, outlined'),
        DemoPreview(
          preview: _ScrollDemo(),
          code: _scrollSnippet,
          alignment: Alignment.centerLeft,
        ),
        SectionHeader('Wrap'),
        DemoPreview(preview: _WrapDemo(), code: _wrapSnippet),
        SectionHeader('Above a composer'),
        DemoPreview(
          preview: _ComposerHandoffDemo(),
          code: _composerSnippet,
          minHeight: 200,
        ),
      ],
    );
  }
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        width: 320,
      ),
    );
}

class _ColumnDemo extends StatelessWidget {
  const _ColumnDemo();

  @override
  Widget build(BuildContext context) {
    return FlowSuggestionGroup(
      layout: FlowSuggestionLayout.column,
      suggestions: [
        FlowSuggestion(
          label: 'Write an essay about life and enjoyment',
          icon: Icons.article_outlined,
          onTap: () => _notify(context, 'Sent: Write an essay'),
        ),
        FlowSuggestion(
          label: 'Create a Monday briefing about my tasks and meetings',
          icon: Icons.event_available_outlined,
          onTap: () => _notify(context, 'Sent: Create a Monday briefing'),
        ),
        FlowSuggestion(
          label: 'Suggest a new venture for me',
          icon: Icons.search,
          onTap: () => _notify(context, 'Sent: Suggest a new venture'),
        ),
      ],
    );
  }
}

class _ScrollDemo extends StatelessWidget {
  const _ScrollDemo();

  static const List<String> _prompts = [
    'Write an essay about life',
    'Create a Monday briefing for my tasks',
    'Suggest a new venture for me',
    'Translate to Japanese',
    'Find the bug in this stack trace',
  ];

  @override
  Widget build(BuildContext context) {
    return FlowSuggestionGroup(
      suggestions: [
        for (final prompt in _prompts)
          FlowSuggestion(
            label: prompt,
            outlined: true,
            onTap: () => _notify(context, 'Sent: $prompt'),
          ),
      ],
    );
  }
}

class _WrapDemo extends StatelessWidget {
  const _WrapDemo();

  @override
  Widget build(BuildContext context) {
    return FlowSuggestionGroup(
      layout: FlowSuggestionLayout.wrap,
      suggestions: [
        FlowSuggestion(
          label: 'Summarize this thread',
          icon: Icons.summarize_outlined,
          outlined: true,
          onTap: () => _notify(context, 'Sent: Summarize this thread'),
        ),
        FlowSuggestion(
          label: 'Brainstorm names',
          icon: Icons.auto_awesome_outlined,
          outlined: true,
          onTap: () => _notify(context, 'Sent: Brainstorm names'),
        ),
        FlowSuggestion(
          label: 'Review my code',
          outlined: true,
          onTap: () => _notify(context, 'Sent: Review my code'),
        ),
        const FlowSuggestion(
          label: 'Run a deep research pass',
          icon: Icons.travel_explore_outlined,
          outlined: true,
          tooltip: 'Not available on this plan',
        ),
      ],
    );
  }
}

/// The pattern hosts copy: starters above the composer that fill the field,
/// and disappear once the thread has a message in it.
class _ComposerHandoffDemo extends StatefulWidget {
  const _ComposerHandoffDemo();

  @override
  State<_ComposerHandoffDemo> createState() => _ComposerHandoffDemoState();
}

class _ComposerHandoffDemoState extends State<_ComposerHandoffDemo> {
  static const List<String> _starters = [
    'Plan my week',
    'Explain a photo',
    'Draft a post',
  ];

  final TextEditingController _controller = TextEditingController();
  bool _started = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FlowSuggestionGroup(
          layout: FlowSuggestionLayout.column,
          suggestions: _started
              ? const []
              : [
                  for (final prompt in _starters)
                    FlowSuggestion(
                      label: prompt,
                      onTap: () => _controller.text = prompt,
                    ),
                ],
        ),
        const SizedBox(height: 8),
        FlowComposer(
          controller: _controller,
          placeholder: 'Message…',
          onSend: (text) {
            setState(() => _started = true);
            _notify(context, 'Sent: $text');
          },
        ),
        if (_started)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _started = false),
              child: const Text('Show starters again'),
            ),
          ),
      ],
    );
  }
}
