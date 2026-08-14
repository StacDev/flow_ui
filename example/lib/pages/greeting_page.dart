import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/gallery_page.dart';
import '../widgets/section_header.dart';

const String _defaultSnippet = '''
FlowGreeting(
  // Wide form: 40px glyph beside 32px text, bottom-aligned.
  icon: Icons.wb_twilight,
  text: 'Good Afternoon, Divyanshu',
)''';

const String _compactSnippet = '''
// Below 600px of available width the greeting restacks itself:
// glyph above the text, at the design's 21px.
SizedBox(
  width: 390,
  child: FlowGreeting(
    icon: Icons.wb_twilight,
    text: 'Good Afternoon, Divyanshu',
  ),
)''';

const String _textOnlySnippet = '''
FlowGreeting(text: 'Welcome back')''';

const String _styledSnippet = '''
FlowGreeting(
  icon: Icons.auto_awesome_outlined,
  iconColor: colors.onSurfaceVariant,
  text: 'Ready when you are',
  // An explicit style is used as given in both forms.
  textStyle: typography.headlineSmall.copyWith(
    color: colors.onSurfaceVariant,
  ),
)''';

/// Demo for [FlowGreeting].
class GreetingPage extends StatelessWidget {
  const GreetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Greeting',
      className: 'FlowGreeting',
      description:
          'The zero state\'s headline over an empty thread — a glyph beside '
          'the text where there is room, restacked over smaller text below '
          '600px of available width. The host supplies the whole string; '
          'FlowChatScreen centres it when the conversation hasn\'t started.',
      children: [
        SectionHeader('Default'),
        DemoPreview(preview: _DefaultDemo(), code: _defaultSnippet),
        SectionHeader('Compact'),
        DemoPreview(preview: _CompactDemo(), code: _compactSnippet),
        SectionHeader('Text only'),
        DemoPreview(preview: _TextOnlyDemo(), code: _textOnlySnippet),
        SectionHeader('Custom style'),
        DemoPreview(preview: _StyledDemo(), code: _styledSnippet),
      ],
    );
  }
}

class _DefaultDemo extends StatelessWidget {
  const _DefaultDemo();

  @override
  Widget build(BuildContext context) {
    return const FlowGreeting(
      icon: Icons.wb_twilight,
      text: 'Good Afternoon, Divyanshu',
    );
  }
}

class _CompactDemo extends StatelessWidget {
  const _CompactDemo();

  @override
  Widget build(BuildContext context) {
    // The stage is usually wider than the breakpoint, so the compact form
    // is shown by boxing the greeting into a phone's width.
    return const SizedBox(
      width: 390,
      child: FlowGreeting(
        icon: Icons.wb_twilight,
        text: 'Good Afternoon, Divyanshu',
      ),
    );
  }
}

class _TextOnlyDemo extends StatelessWidget {
  const _TextOnlyDemo();

  @override
  Widget build(BuildContext context) {
    return const FlowGreeting(text: 'Welcome back');
  }
}

class _StyledDemo extends StatelessWidget {
  const _StyledDemo();

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    return FlowGreeting(
      icon: Icons.auto_awesome_outlined,
      iconColor: colors.onSurfaceVariant,
      text: 'Ready when you are',
      textStyle: context.flowTypography.headlineSmall.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
