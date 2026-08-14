import 'package:flutter/material.dart';

import 'src/playground_shell.dart';

void main() {
  runApp(const PlaygroundApp());
}

/// The flow_ui playground: the shell from the Claude Design handoff.
/// Component demos plug into the stage next.
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
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: PlaygroundShell(
        themeMode: _mode,
        onThemeModeChanged: (mode) => setState(() => _mode = mode),
      ),
    );
  }
}
