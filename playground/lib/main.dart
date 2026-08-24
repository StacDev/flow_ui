import 'package:flow_ui/flow_ui.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'src/embed.dart';
import 'src/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // `?embed=` boots the chrome-less single-demo mode the docs site
  // iframes. It shows no code panel, so the grammar load is skipped for a
  // faster first paint. On non-web platforms Uri.base has no query — the
  // full playground always boots.
  final embed = EmbedRequest.fromUri(Uri.base);
  if (embed != null) {
    runApp(EmbedApp(request: embed));
    return;
  }
  // Path URLs for the components: /playground/composer, not a hash route.
  // It goes *after* the embed branch on purpose — the docs iframe
  // /playground/index.html?embed=…, and under this strategy that reads as
  // the route name "/index.html", which the embed's plain Navigator can't
  // build. The embed returns above, so it never sees one. Off the web this
  // call is a documented no-op.
  usePathUrlStrategy();
  runApp(const PlaygroundApp());
}

/// The flow_ui playground: the shell from the Claude Design handoff, with
/// live component demos on the stage.
class PlaygroundApp extends StatefulWidget {
  const PlaygroundApp({super.key});

  @override
  State<PlaygroundApp> createState() => _PlaygroundAppState();
}

class _PlaygroundAppState extends State<PlaygroundApp> {
  // Follows the OS scheme until the reader picks a side in the top bar;
  // platforms that report no preference resolve to light.
  ThemeMode _mode = ThemeMode.system;

  // Built once: rebuilding the router on a theme flip would throw away the
  // location and the history with it.
  late final GoRouter _router = playgroundRouter(
    onThemeModeChanged: (mode) => setState(() => _mode = mode),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flow UI Playground · Flutter UI library for AI Chat Interfaces',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      // Chrome and stage demos alike paint from the FlowTheme extensions,
      // so the workbench and the exhibit flip together.
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [FlowTheme.light()],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [FlowTheme.dark()],
      ),
      routerConfig: _router,
    );
  }
}
