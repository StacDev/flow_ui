import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import 'src/code_panel.dart';
import 'src/playground_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow UI Playground',
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
        themeMode: _mode,
        onThemeModeChanged: (mode) => setState(() => _mode = mode),
      ),
    );
  }
}
