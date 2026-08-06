import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'pages/loading_indicator_page.dart';
import 'pages/streaming_text_page.dart';
import 'pages/tokens_page.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleMode() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flow_ui gallery',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [FlowTheme.light()],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [FlowTheme.dark()],
      ),
      home: GalleryHomePage(onToggleTheme: _toggleMode),
    );
  }
}

class GalleryHomePage extends StatelessWidget {
  const GalleryHomePage({super.key, required this.onToggleTheme});

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
          'flow_ui gallery',
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
          _DemoTile(
            title: 'Design tokens',
            subtitle: 'Colors, typography, spacing, radii',
            builder: (_) => TokensPage(onToggleTheme: onToggleTheme),
          ),
          _DemoTile(
            title: 'Streaming text',
            subtitle: 'FlowStreamingText — animated streaming reveal',
            builder: (_) => StreamingTextPage(onToggleTheme: onToggleTheme),
          ),
          _DemoTile(
            title: 'Loading indicator',
            subtitle: 'FlowLoadingIndicator — staggered three-dot pulse',
            builder: (_) => LoadingIndicatorPage(onToggleTheme: onToggleTheme),
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final colors = context.flowColors;
    final typography = context.flowTypography;

    return Container(
      margin: EdgeInsets.only(bottom: context.flowSpacing.sm),
      child: Material(
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: context.flowRadii.md,
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          title: Text(
            title,
            style: typography.titleMedium.copyWith(color: colors.onSurface),
          ),
          subtitle: Text(
            subtitle,
            style: typography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: builder));
          },
        ),
      ),
    );
  }
}
