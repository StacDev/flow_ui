import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

const String suggestionsSnippet = '''
FlowSuggestionGroup(
  // column: full-width rows, the zero state's form.
  // scroll (default): one strip, no scrollbar — above a composer.
  // wrap: as many lines as needed.
  layout: FlowSuggestionLayout.column,
  suggestions: [
    for (final starter in starters)
      FlowSuggestion(
        label: starter.prompt,
        icon: starter.icon,
        // outlined: true draws the faint fill and hairline.
        onTap: () => send(starter.prompt),
      ),
  ],
)''';

const List<(IconData, String)> _starters = [
  (
    PhosphorIconsRegular.articleNyTimes,
    'Write an essay about life and enjoyment',
  ),
  (
    PhosphorIconsRegular.calendarCheck,
    'Create a Monday briefing about my tasks and meetings',
  ),
  (PhosphorIconsRegular.magnifyingGlass, 'Suggest a new venture for me'),
];

const List<String> _prompts = [
  'Write an essay about life',
  'Create a Monday briefing',
  'Suggest a new venture for me',
  'Translate to Japanese',
  'Find the bug in this stack trace',
];

/// Prompt starters in the group's three layouts: the zero state's column,
/// the outlined scrolling strip, and the wrap.
class SuggestionsDemo extends StatelessWidget {
  const SuggestionsDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    final Widget group;
    switch (variant) {
      case 'scroll':
        group = FlowSuggestionGroup(
          suggestions: [
            for (final prompt in _prompts)
              FlowSuggestion(label: prompt, outlined: true, onTap: () {}),
          ],
        );
      case 'wrap':
        group = FlowSuggestionGroup(
          layout: FlowSuggestionLayout.wrap,
          suggestions: [
            for (final (icon, prompt) in _starters)
              FlowSuggestion(
                label: prompt,
                icon: icon,
                outlined: true,
                onTap: () {},
              ),
            const FlowSuggestion(
              label: 'Run a deep research pass',
              outlined: true,
              tooltip: 'Not available on this plan',
            ),
          ],
        );
      default:
        group = FlowSuggestionGroup(
          layout: FlowSuggestionLayout.column,
          suggestions: [
            for (final (icon, prompt) in _starters)
              FlowSuggestion(label: prompt, icon: icon, onTap: () {}),
          ],
        );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: group,
      ),
    );
  }
}
