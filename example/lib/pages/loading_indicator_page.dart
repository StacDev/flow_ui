import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
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
  const LoadingIndicatorPage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;
    final spacing = context.flowSpacing;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLow,
        title: Text(
          'Loading indicator',
          style: typography.titleLarge.copyWith(color: colors.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(spacing.lg),
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
      ),
    );
  }
}
