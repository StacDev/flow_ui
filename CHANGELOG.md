# Changelog

## 0.2.0 (unreleased)

- **Code block** — `FlowCodeBlock`, and a `FlowCodePart` message part
  rendered by `FlowMessage`/`FlowThread` with copy intent surfaced on
  `onCodeCopy`. Highlighting is built in and synchronous (Dart, JSON,
  JavaScript/TypeScript, Python, shell, YAML, HTML, CSS and SQL;
  host-extensible via `FlowCodeLanguage.register`), colored by new
  `FlowSyntaxColors` theme tokens. The package now also bundles Geist Mono (three weights, SIL OFL)
  behind new `code` / `codeInline` typography roles — `withFontFamily()`
  no longer touches the mono roles; swap those with
  `withCodeFontFamily()`.
- **Error state** — `FlowErrorState` (error glyph, host-written message,
  retry pill) and a `FlowErrorPart` message part, with
  `onRetry`/`errorTitle`/`retryLabel` threaded through `FlowMessage` and
  `FlowThread`.
- **Markdown** — `FlowMarkdown`, assistant prose typeset by a built-in
  parser (no new dependency): headings on the existing type ramp,
  emphasis, inline code on the `codeInline` role as a rounded chip
  painted under the glyphs — wrapping keeps only the outer corners
  rounded — links reporting intent through `onLinkTap` (bare
  `https://`, `http://` and `www.` URLs autolink with GFM's trimming
  rules), nested lists, quotes, rules, tables with alignment and
  overflow scroll, and fenced code rendered by `FlowCodeBlock` —
  sharing the `FlowCodePart` copy contract. Streaming input may end
  mid-construct and renders gracefully, with the trailing paragraph
  revealing character by character.
- **Streaming motion** — markdown reveals through one sequenced
  frontier: nothing renders below the animating block, fences, tables
  and rules ease in with height and opacity when the frontier reaches
  them, and pacing keeps the frontier within the reveal's lag bound on
  fast streams. Growth is eased in layout — the revealing paragraph
  gains each wrapped line over a beat — so a thread pinned to the
  newest message moves continuously instead of stepping a line-height
  at a time. Reduced-motion settings render statically.
- **Breaking**: assistant text parts now render as markdown by default.
  Hosts whose assistant text is literal pass `markdown: false` on
  `FlowThread` or `FlowMessage`; user bubbles and system notices are
  unaffected.
- **Keyboard** — taps landing on the chat surface itself (dead space,
  the thread, a settled message) now dismiss the keyboard, and scrolling
  the thread dismisses it too (`FlowThread.keyboardDismissBehavior`,
  default on-drag) — the chat conventions. Interactive children keep
  their taps.
- **Thread** — a conversation that still fits its viewport now reads from
  the top, the AI-app convention, instead of hugging the composer with
  empty space above. Once it outgrows the viewport the thread anchors to
  the newest message as before.
- **Pill** — `FlowPill`, a removable pill showing an enabled tool or mode
  in the composer's action row: host-passed icon, label and tooltips,
  removal intent on `onRemove`, and a label that auto-drops to the
  icon-only form on phones (`showLabel` forces either).
- **Breaking**: `FlowComposer.placeholder` now defaults to
  'How can I help you today?' — the one string the package ships. Hosts
  that want an empty field must pass an explicit `placeholder: null`;
  localized hosts keep passing their own copy.
- **Breaking**: `FlowChatView.composer` is now required — still nullable,
  so a read-only surface passes an explicit `composer: null` instead of
  omitting it. Building the view with nothing to show at all (no thread,
  composer, header, or zero state) now asserts in debug builds rather
  than rendering a blank screen.
- **Breaking**: `FlowChatScreen` is renamed to `FlowChatView`. The widget
  was never a screen — it is body-only and embeddable, and upcoming
  surfaces (side panel, modal) will host it — so the name now follows
  Flutter's convention for embeddable composites. Rename call sites;
  the API is unchanged.
- **Breaking**: a failed assistant turn no longer recolors its content
  into an `errorContainer` bubble — parts keep their normal ink and the
  turn closes with an error card (a default one when no `FlowErrorPart`
  is present). The user bubble's error treatment is unchanged.
- **Breaking**: migrated from `package:flutter/material.dart` to
  `package:material_ui` (Material's home since Flutter 3.47) — no API
  changes, but the two Materials are distinct types, so the host app must
  migrate too: `dart fix --apply --code=migrate_design_widgets` on
  Flutter 3.44+, or pin flow_ui 0.1.x.

## 0.1.0

First public release — the assistant UI component library for Flutter, with
zero third-party dependencies and nothing model-facing.

Ships with:

- **Theme** — `FlowTheme` design tokens (colors + typography) as a
  `ThemeExtension`, light and dark presets, bundled Figtree typeface.
- **Message & Thread** — ink-wash user bubble, plain assistant, error state,
  typed content parts with a `FlowCustomPart` extension seam.
- **Streaming** — animated text reveal, thinking indicator, shimmer text.
- **Message actions** — copy / regenerate / edit / feedback presets.
- **Composer** — multiline input with send/stop, attachments strip, and
  leading/trailing action slots.
- **Menus** — `FlowMenu` (groups, submenus, toggles) and `FlowModelSelector`
  (effort + overflow submenus); anchored card on desktop, sheet on phones.
- **Attachments** — image and file tiles with type pill, plus a full-screen
  preview with zoom and paging.
- **Suggestions** — plain and outlined starters in scroll, wrap, or column
  layouts, with `FlowGreeting` for the zero state.
- **Chat Screen** — the composed surface: centred 760 rail, zero state with
  lifted composer, jump-to-latest.

## 0.0.1

Initial scaffold.
