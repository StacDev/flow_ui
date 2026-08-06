import 'dart:async';
import 'dart:math';

import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';

import '../widgets/demo_preview.dart';
import '../widgets/section_header.dart';

const String _sampleText =
    'Flow UI is an assistant UI library for Flutter. It renders conversation '
    'state and reports user intent through callbacks, while staying completely '
    'model-agnostic. This paragraph is delivered in small chunks to simulate a '
    'model streaming its response. The widget reveals characters at an '
    'adaptive speed, catching up whenever the stream runs ahead, and '
    'fast-forwards the remainder the moment streaming completes.';

const String _streamingSnippet = '''
FlowStreamingText(
  // The full text received so far — grows as chunks arrive.
  text: streamedText,
  // Animates the reveal while more text may arrive;
  // flip to false to fast-forward the remainder.
  isStreaming: true,
)''';

const String _staticSnippet = '''
// History messages render statically, with no animation cost.
FlowStreamingText(
  text: fullText,
  isStreaming: false,
)''';

/// Demo for [FlowStreamingText]: a Timer-based fake stream feeds chunks of
/// words into the widget. The simulator lives in the example only.
class StreamingTextPage extends StatefulWidget {
  const StreamingTextPage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<StreamingTextPage> createState() => _StreamingTextPageState();
}

class _StreamingTextPageState extends State<StreamingTextPage> {
  String _streamed = '';
  bool _isStreaming = false;
  Timer? _timer;
  int _intervalMs = 80;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _replay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _replay() {
    _timer?.cancel();
    final words = _sampleText.split(' ');
    var index = 0;
    setState(() {
      _streamed = '';
      _isStreaming = true;
    });
    _timer = Timer.periodic(Duration(milliseconds: _intervalMs), (timer) {
      if (index >= words.length) {
        timer.cancel();
        setState(() => _isStreaming = false);
        return;
      }
      // Emit 1–3 words per tick, like token chunks.
      final take = min(1 + _random.nextInt(3), words.length - index);
      setState(() {
        _streamed += '${words.sublist(index, index + take).join(' ')} ';
        index += take;
      });
    });
  }

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
          'Streaming text',
          style: typography.titleLarge.copyWith(color: colors.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
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
          Wrap(
            spacing: spacing.md,
            runSpacing: spacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _replay,
                icon: const Icon(Icons.replay),
                label: const Text('Replay'),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 200, label: Text('Slow')),
                  ButtonSegment(value: 80, label: Text('Normal')),
                  ButtonSegment(value: 25, label: Text('Fast')),
                ],
                selected: {_intervalMs},
                onSelectionChanged: (selection) {
                  _intervalMs = selection.first;
                  _replay();
                },
              ),
            ],
          ),
          const SectionHeader('Streaming'),
          DemoPreview(
            preview: FlowStreamingText(
              text: _streamed,
              isStreaming: _isStreaming,
            ),
            code: _streamingSnippet,
          ),
          const SectionHeader('Static (history message)'),
          const DemoPreview(
            preview: FlowStreamingText(text: _sampleText, isStreaming: false),
            code: _staticSnippet,
          ),
        ],
      ),
    );
  }
}
