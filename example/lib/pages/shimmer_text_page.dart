import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _defaultSnippet = '''
FlowShimmerText(text: 'Searching the web…')''';

const String _settledSnippet = '''
// enabled: false renders plain static text in the base ink —
// the same widget can stay in place once the work settles.
FlowShimmerText(
  enabled: false,
  text: 'Searched the web',
)''';

const String _customSnippet = '''
FlowShimmerText(
  text: 'Generating a slide deck…',
  highlightColor: context.flowColors.primary,
  style: const TextStyle(fontSize: 18),
  duration: const Duration(milliseconds: 1000),
)''';

/// Demo for [FlowShimmerText].
class ShimmerTextPage extends StatelessWidget {
  const ShimmerTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return GalleryPage(
      title: 'Shimmer text',
      className: 'FlowShimmerText',
      description:
          'A soft highlight sweeping through waiting text — the treatment '
          'for a label whose work is still in flight. The thinking '
          'indicator uses it for its label; tool and progress lines can '
          'take it directly.',
      children: [
        const SectionHeader('Waiting'),
        const DemoPreview(
          preview: FlowShimmerText(text: 'Searching the web…'),
          code: _defaultSnippet,
          alignment: Alignment.centerLeft,
        ),
        const SectionHeader('Settled'),
        const DemoPreview(
          preview: FlowShimmerText(enabled: false, text: 'Searched the web'),
          code: _settledSnippet,
          alignment: Alignment.centerLeft,
        ),
        const SectionHeader('Customized'),
        DemoPreview(
          preview: FlowShimmerText(
            text: 'Generating a slide deck…',
            highlightColor: colors.primary,
            style: const TextStyle(fontSize: 18),
            duration: const Duration(milliseconds: 1000),
          ),
          code: _customSnippet,
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }
}
