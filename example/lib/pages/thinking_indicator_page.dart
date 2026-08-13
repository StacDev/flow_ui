import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _defaultSnippet = '''
FlowThinkingIndicator(label: 'Thinking…')''';

const String _settledSnippet = '''
// active: false holds the line still — keep it on screen after
// thinking ends and swap the label you already own.
FlowThinkingIndicator(
  active: false,
  label: 'Thought about it',
)''';

const String _glyphSnippet = '''
// No label: just the spinning mark. semanticLabel keeps it
// announced; the package ships no strings.
FlowThinkingIndicator(
  size: 24,
  color: context.flowColors.primary,
  semanticLabel: 'Thinking',
)''';

/// Demo for [FlowThinkingIndicator].
class ThinkingIndicatorPage extends StatelessWidget {
  const ThinkingIndicatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return GalleryPage(
      title: 'Thinking indicator',
      className: 'FlowThinkingIndicator',
      description:
          'The turning, breathing asterisk shown while a reply is pending, its '
          'host-supplied label shimmering. active: false is the settled state — '
          'the same line, holding still. Pending messages render it '
          'automatically; pass thinkingLabel to FlowMessage or FlowThread.',
      children: [
        const SectionHeader('Thinking'),
        const DemoPreview(
          preview: FlowThinkingIndicator(label: 'Thinking…'),
          code: _defaultSnippet,
          alignment: Alignment.centerLeft,
        ),
        const SectionHeader('Settled'),
        const DemoPreview(
          preview: FlowThinkingIndicator(
            active: false,
            label: 'Thought about it',
          ),
          code: _settledSnippet,
          alignment: Alignment.centerLeft,
        ),
        const SectionHeader('Glyph only'),
        DemoPreview(
          preview: FlowThinkingIndicator(
            size: 24,
            color: colors.primary,
            semanticLabel: 'Thinking',
          ),
          code: _glyphSnippet,
        ),
      ],
    );
  }
}
