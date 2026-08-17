## Summary

<!-- What changes, and why. Link the issue it closes: Closes #123 -->

## Screenshots

<!-- flow_ui is a UI library, so anything visual needs a picture. Delete this
     section only if the change renders nothing. -->

| Before | After |
| --- | --- |
|  |  |

## How this was verified

<!-- Which playground stages you exercised, on which platforms (and both
     themes, if the change touches colour). -->

## Checklist

- [ ] `flutter analyze lib` and `flutter analyze` in `example/` and `playground/` are clean
- [ ] `dart format .` applied
- [ ] Exercised in the playground — with a stage demo added or updated if this is a new component or variant
- [ ] No new entries under `dependencies:` in `pubspec.yaml` (Flutter SDK and flutter.dev packages only)
- [ ] Nothing model-facing — no prompts, schemas, or provider/network calls
- [ ] New public API is exported from `lib/flow_ui.dart` and documented in `docs/` and the README table
- [ ] `CHANGELOG.md` updated for user-facing changes, with breaking changes called out
- [ ] PR title follows conventional commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`)
