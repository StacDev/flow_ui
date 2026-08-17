import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'src/code_panel.dart';
import 'src/embed.dart';
import 'src/playground_shell.dart';

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
  // Loads the Dart grammar and both highlight themes once, so the code
  // panel renders synchronously.
  await CodeHighlighting.init();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow UI Playground · Flutter UI library for AI Chat Interfaces',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      // The chrome paints itself from ShellPalette; the FlowTheme
      // extensions are for the component demos on the stage.
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [FlowTheme.light()],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [FlowTheme.dark()],
      ),
      home: PlaygroundShell(
        onThemeModeChanged: (mode) => setState(() => _mode = mode),
      ),
    );
  }
}
