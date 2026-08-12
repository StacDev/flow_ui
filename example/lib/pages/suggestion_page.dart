import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _scrollSnippet = '''
FlowSuggestionGroup(
  // The default: one row that scrolls, no scrollbar.
  suggestions: [
    for (final prompt in prompts)
      FlowSuggestion(label: prompt, onTap: () => send(prompt)),
  ],
)''';

const String _wrapSnippet = '''
FlowSuggestionGroup(
  layout: FlowSuggestionLayout.wrap,
  suggestions: [
    FlowSuggestion(
      label: 'Summarize this thread',
      icon: Icons.summarize_outlined,
      onTap: () => send('Summarize this thread'),
    ),
    // No onTap → disabled.
    FlowSuggestion(label: 'Run a deep research pass'),
  ],
)''';

const String _columnSnippet = '''
FlowSuggestionGroup(
  layout: FlowSuggestionLayout.column,
  spacing: 8,
  suggestions: [
    FlowSuggestion(
      label: 'Draft a reply to the last email',
      icon: Icons.mail_outlined,
      onTap: () => send('Draft a reply to the last email'),
    ),
  ],
)''';

const String _composerSnippet = '''
Column(
  children: [
    FlowSuggestionGroup(
      // Empty once the thread starts — the group then takes no space.
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
          'Prompt starters as tappable pills. The group lays them out as a '
          'scrolling row, a wrap, or a column; a pill without a callback '
          'renders disabled.',
      children: [
        SectionHeader('Scrolling row'),
        DemoPreview(
          preview: _ScrollDemo(),
          code: _scrollSnippet,
          alignment: Alignment.centerLeft,
        ),
        SectionHeader('Wrap'),
        DemoPreview(preview: _WrapDemo(), code: _wrapSnippet),
        SectionHeader('Column'),
        DemoPreview(
          preview: _ColumnDemo(),
          code: _columnSnippet,
          alignment: Alignment.centerLeft,
        ),
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

class _ScrollDemo extends StatelessWidget {
  const _ScrollDemo();

  static const List<String> _prompts = [
    'Plan a weekend trip',
    'Explain this screenshot',
    'Write unit tests',
    'Summarize the meeting notes',
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
          onTap: () => _notify(context, 'Sent: Summarize this thread'),
        ),
        FlowSuggestion(
          label: 'Brainstorm names',
          icon: Icons.auto_awesome_outlined,
          onTap: () => _notify(context, 'Sent: Brainstorm names'),
        ),
        FlowSuggestion(
          label: 'Review my code',
          icon: Icons.code_rounded,
          onTap: () => _notify(context, 'Sent: Review my code'),
        ),
        FlowSuggestion(
          label: 'Translate to Japanese',
          icon: Icons.translate_rounded,
          onTap: () => _notify(context, 'Sent: Translate to Japanese'),
        ),
        const FlowSuggestion(
          label: 'Run a deep research pass',
          icon: Icons.travel_explore_outlined,
          tooltip: 'Not available on this plan',
        ),
      ],
    );
  }
}

class _ColumnDemo extends StatelessWidget {
  const _ColumnDemo();

  @override
  Widget build(BuildContext context) {
    return FlowSuggestionGroup(
      layout: FlowSuggestionLayout.column,
      suggestions: [
        FlowSuggestion(
          label: 'Draft a reply to the last email',
          icon: Icons.mail_outlined,
          onTap: () => _notify(context, 'Sent: Draft a reply'),
        ),
        FlowSuggestion(
          label: 'Turn these notes into a checklist',
          icon: Icons.checklist_rounded,
          onTap: () => _notify(context, 'Sent: Turn notes into a checklist'),
        ),
        FlowSuggestion(
          label: 'Compare the two proposals',
          icon: Icons.compare_arrows_rounded,
          onTap: () => _notify(context, 'Sent: Compare the two proposals'),
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
    'Debug an error',
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
    final spacing = context.flowSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FlowSuggestionGroup(
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
        SizedBox(height: spacing.sm),
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
