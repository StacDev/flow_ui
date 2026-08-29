# flow_ui example

A live chat screen built with flow_ui: a zero state with a greeting, a
streaming Gemini reply behind the thinking indicator, stop, and retry on
the error card. Images go both ways — attach one from the file dialog, a
drop or a paste and it rides up with the turn; pick the image model in
the selector, ask for a picture, and it comes back through
`FlowImagePart`, shimmering until the bytes land. flow_ui renders the
state; `gemini_api.dart` is the host-side transport it never sees.

Set up a key once — grab one from [Google AI Studio](https://aistudio.google.com/apikey)
and create `lib/env.g.dart` with it (the file is gitignored, so your key
stays on your machine):

```dart
const String apiKey = 'AIza...';
```

Platform runners are checked in, so it launches directly:

```bash
flutter run
```

With an empty key the app still runs — sending just answers with the
error card explaining what's missing.

For a live tour of every component — with variants and code snippets — open
the hosted [playground](https://flowui.stac.dev/playground), or run it from
[the repo](https://github.com/StacDev/flow_ui/tree/main/playground):

```bash
cd ../playground && flutter run -d chrome
```
