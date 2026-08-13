# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## What this is

**flow_ui** is a chat/assistant UI component library for Flutter — the presentation layer for AI assistant interfaces. It is a plain Flutter package (no codegen, no melos). Downstream packages depend on the public API exported from `lib/flow_ui.dart`, so treat it as a compatibility surface.

Two hard constraints shape everything here:

- **No third-party dependencies.** `dependencies:` in `pubspec.yaml` contains only the Flutter SDK. Dev dependencies (`flutter_test`, `flutter_lints`) are fine.
- **Nothing model-facing.** Components render state passed in and report intent out through callbacks. No prompts, schemas, provider/network calls, or any LLM awareness — that belongs to the layers built on top.

The theme, the conversation components (message, thread, streaming text, actions, loading), the composer and its menus, attachments with their preview, suggestions, and the chat surface are implemented; the roadmap below tracks the rest. Message content is modeled as typed parts (`lib/src/models/`) — sealed `FlowMessagePart` subtypes rendered by `FlowMessage`, with `FlowCustomPart` + `FlowCustomPartBuilder` as the extension seam for host-injected content.

## Layout

- Package at the repo root: `lib/`, `test/`, `pubspec.yaml`.
- `example/` — a full Flutter app depending on the package via `path: ../`. Use it to demo and manually exercise components.

## Commands

From the repo root:

```bash
flutter test                                  # all tests
flutter test test/some_widget_test.dart       # single file
flutter test --plain-name "some test name"    # single test by name
flutter analyze
dart format .
```

Example app:

```bash
cd example
flutter pub get
flutter run -d chrome    # or any device
```

## Component roadmap

Status legend: ⬜ Todo · ✅ Done

### Theme (build first)

`ThemeExtension`-based design tokens. Every component consumes these tokens (no hardcoded values); build this layer before any component.

| # | Component | Notes | Status |
|---|-----------|-------|--------|
| 1 | Design tokens | colors, typography, spacing, radii | ✅ |
| 2 | Light/dark themes | | ✅ |

### Basic elements

| # | Component | Variants / notes | Status |
|---|-----------|------------------|--------|
| 3 | Avatar | default, with icon, group, group count, group icon | ⬜ |
| 4 | Button | primary, secondary, outline, text, icon, destructive | ⬜ |
| 5 | Text | | ⬜ |
| 6 | Chip | | ⬜ |
| 7 | Badge | | ⬜ |

### AI elements

| # | Component | Variants / notes | Status |
|---|-----------|------------------|--------|
| 8 | Message & Thread | | ✅ |
| 9 | Thread List | | ⬜ |
| 10 | Message actions | | ✅ |
| 11 | Streaming text | | ✅ |
| 12 | Message composer | | ✅ |
| 13 | Model selector | effort & overflow submenus; sheet on phones | ✅ |
| 14 | Menu | icon-trigger menu: groups, submenus, toggles; sheet on phones | ✅ |
| 15 | Attachments | images and files, type pill; videos pending | ✅ |
| 16 | Preview | full-screen image viewer: zoom, paging | ✅ |
| 17 | Tool | TBD | ⬜ |
| 18 | Suggestion & Suggestion Group | scrolling row, wrap, column | ✅ |
| 19 | Confirmation | default, approved, rejected | ⬜ |
| 20 | Error state | | ⬜ |
| 21 | Code block | | ⬜ |
| 22 | Loading indicator | staggered three-dot pulse | ✅ |
| 23 | Shimmer | text only | ⬜ |

### Surfaces

| # | Component | Variants / notes | Status |
|---|-----------|------------------|--------|
| 24 | Chat Screen | thread + composer, centred, jump to latest | ✅ |
| 25 | SidePanel | | ⬜ |
| 26 | Modal | | ⬜ |
