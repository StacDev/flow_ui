import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _defaultSnippet = '''
FlowLoadingIndicator()''';

const String _customSnippet = '''
FlowLoadingIndicator(
  color: context.flowColors.primary,
  dotSize: 12,
  duration: const Duration(milliseconds: 900),
)''';

/// Demo for [FlowLoadingIndicator].
class LoadingIndicatorPage extends StatelessWidget {
  const LoadingIndicatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;

    return GalleryPage(
      title: 'Loading indicator',
      className: 'FlowLoadingIndicator',
      description:
          'The staggered three-dot pulse shown while a reply is pending. '
          'Color, dot size, and period are all tunable.',
      children: [
        const SectionHeader('Default'),
        const DemoPreview(
          preview: FlowLoadingIndicator(),
          code: _defaultSnippet,
        ),
        const SectionHeader('Customized'),
        DemoPreview(
          preview: FlowLoadingIndicator(
            color: colors.primary,
            dotSize: 12,
            duration: const Duration(milliseconds: 900),
          ),
          code: _customSnippet,
        ),
      ],
    );
  }
}
