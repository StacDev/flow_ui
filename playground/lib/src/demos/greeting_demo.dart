import 'package:flow_ui/flow_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

const String greetingSnippet = '''
FlowGreeting(
  icon: PhosphorIconsRegular.sunHorizon,
  text: 'Good Afternoon, Divyanshu',
)
// Below 600px of available width it restacks: icon above 21px text.
// The host supplies the whole string — nothing is derived.''';

/// The zero state's headline. On the phone stage it restacks into the
/// compact form by itself — the switch is width-based.
class GreetingDemo extends StatelessWidget {
  const GreetingDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlowGreeting(
        icon: variant == 'text' ? null : PhosphorIconsRegular.sunHorizon,
        text: 'Good Afternoon, Divyanshu',
      ),
    );
  }
}
