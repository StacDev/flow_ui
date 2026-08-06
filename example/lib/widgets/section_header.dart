import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

/// Shared section heading for gallery pages.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final spacing = context.flowSpacing;
    return Padding(
      padding: EdgeInsets.only(top: spacing.xl, bottom: spacing.md),
      child: Text(
        title,
        style: context.flowTypography.headlineSmall.copyWith(
          color: context.flowColors.onSurface,
        ),
      ),
    );
  }
}
