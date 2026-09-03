# Changelog

## 0.3.0 (unreleased)

- **Toast** — `FlowToast`, the floating notice: a host-supplied glyph,
  one line that wraps and a cross on the raised card at 80%, the line
  and the cross's label host-localized. `showFlowToast` floats it in
  the nearest `Overlay` with no setup: 358 wide in the top end corner
  on wide layouts, the full width inside 16 on compact ones, over a 3px
  frost of the page; toasts stack three deep, newest nearest the edge,
  leave on their own after four seconds (or never, with
  `duration: null`), pause under the pointer, and hand back a
  `FlowToastHandle` to dismiss one early or await its closing.
  `FlowToastStyle` joins the component styles with a
  `FlowTheme.toastStyle` default; the example shows one for a copied
  message.
- **Selectable text** — text in a `FlowThread` is selectable, the way a
  chat in a browser is: drag across turns with a mouse, long-press on
  touch, copy with the platform's shortcut or menu. A copy keeps its line
  breaks (paragraphs on their own lines, a blank line between turns);
  chrome (button labels, the code block's header, the attachment type
  pill, the thinking line) and list markers stay out of it. The highlight,
  handles and toolbar take `primary`, and the composer's caret and
  highlight now match; an explicit `ThemeData.textSelectionTheme` wins
  field by field. `FlowThread.selectable` (default true) turns the
  thread's own selection area off: the content joins a host's area above,
  or stays unselectable, code blocks included, when there is none. `FlowCodeBlock` renders its code as one paragraph that
  joins a thread's selection, and hosts its own selection area on its
  own. Select-all covers the turns the lazy list has built.
- **Confirmation** — `FlowConfirmation`, the approval card: an
  asterisk-marked request with approve and reject buttons that settle
  into the outcome, every label host-localized. `FlowConfirmationPart`
  renders it in a thread, reporting through
  `FlowThread.onConfirmationRespond`; `FlowConfirmationStyle` joins the
  component styles with a `FlowTheme.confirmationStyle` default.
- **Thread list** — `FlowThreadList`, the side panel's conversation
  history: host-labeled sections of title-only rows, single selection by
  id, an unread dot and pinned glyph, and a leading icon slot. Metrics
  are provisional pending a design frame; `FlowThreadListStyle` joins the
  component styles with a `FlowTheme.threadListStyle` default.
- **Attachment input** — the composer can now get the files itself.
  `FlowComposer.onAttachmentsPicked` renders the attach button and opens
  the platform's file dialog, handing back `FlowAttachment`s already read
  and decoded. `FlowAttachmentOptions` says what is accepted and at what
  decode caps, `FlowAttachmentTypeGroup` names types in all four families
  the platforms disagree over, and `onAttachmentRejected` reports every
  refusal with its reason. Holding the attachments is still the host's:
  they come back through `attachments` as before.
- **Picker, callable** — `showFlowAttachmentPicker` opens the platform's
  dialog from anywhere — the design's "+" menu, a host's own button — and
  hands back decoded `FlowAttachment`s. It never throws: a dialog that
  cannot open is reported through `onRejected` as `unreadable` under an
  empty name. The playground and the example route it through 'Add
  Files or Photos'.
- **Error banner** — `FlowComposer.errorMessage` raises the design's
  tab above the card: the error wash with a warning glyph and the host's
  line beside it, wrapping when long, growing in from the
  card's edge, and staying until its cross (`onErrorDismiss`) or the
  host clears it. `errorIcon` swaps the drawn glyph;
  `FlowComposerStyle.errorBackgroundColor` and `errorForegroundColor`
  recolour it. The playground and the example use it for refused files.
- **Drag and drop**, in either of two scopes.
  `FlowChatView.onAttachmentsDropped` takes the whole surface, raising
  the full-bleed treatment (`dropLabel`) while a file is over it;
  `FlowComposer.onAttachmentsDropped` takes just the input card, which
  lights up instead (`FlowComposerStyle.dropHighlightColor`). Both decode
  through the same `attachmentOptions`, and wiring both is fine — the
  innermost target under the pointer wins.
- **Paste** — `FlowComposer.onAttachmentsPasted` takes an image pasted
  into the field, decoded through the same `attachmentOptions` as a pick
  or a drop. It fires only while the field has focus and only when the
  clipboard holds a file, so text paste is untouched; a clipboard
  carrying both a file and its name attaches the file and keeps the name
  out of the draft. Web-only, like drop — Flutter's `Clipboard` reads
  plain text and nothing else on every platform.
- **Drop treatment, redrawn** — the design's vertical wash over a 12px
  blur of the page, `surfaceBright` at 40% down to `surface` at 80%, with
  the glyph and the
  invitation straight on it, replacing the flat tint and the centred
  card. `FlowChatViewStyle` (new, and on `FlowTheme.chatViewStyle`)
  carries `dropGradient`, `dropIconColor` and `dropLabelStyle`;
  `dropIcon` and `dropIconSize` join `dropLabel` as widget parameters.
  The treatment leaves the widget tree while idle.
- **Turning attachments off** — `attachmentsEnabled` on `FlowComposer`
  and `FlowChatView`. Presence of a callback says a way in is wired;
  this says it is available: false stops the button, drop, paste and
  keyboard media at once without unwiring any of them, while pending
  attachments stay removable. A drop target that is off yields to an
  enabled one around it — a card switched off hands its drops up to the
  surface — and where nothing enabled remains it stays registered and
  swallows what lands, so the browser never navigates to a dropped
  file; `FlowDropTarget.enabled` is the same switch for a host's own
  target.
- **Escape hatches** — `onAttach` renders the same attach button and
  leaves the picking to the host, for a gallery sheet or a camera.
  `dropActive` stays writable as an override, since drop detection is
  web-only and desktop hosts still need their own. `FlowDropTarget`
  exposes that detection for surfaces that are neither a `FlowChatView`
  nor a `FlowComposer`. Android keyboard media insertion arrives too
  (`onContentInserted`, the SDK's IME rich-content path), and the attach
  button restyles through `FlowComposerStyle.attachIconColor`.
- **Attachments carry their file** — `FlowAttachment.bytes` and
  `FlowAttachment.mimeType`, filled in for anything the picker or a drop
  produced. Nothing in flow_ui reads them; they are there because a host
  that lets the package pick still has to be able to upload what it
  picked, and digging the bytes back out of the `ImageProvider` is not an
  API. The bytes are the same list the thumbnail decodes from, so they
  cost nothing extra. `mimeType` is the platform's where it reports one
  and the extension's where it doesn't, since the native pickers report
  none. The example app sends attached images to Gemini with them.
- **Fix** — an attachment tile now renders a thumbnail that is already a
  `ResizeImage` instead of the failure glyph. `ResizeImage` asserts
  rather than nesting, and the tile wraps whatever it is handed in one of
  its own, sized to the tile and the display's pixel ratio; a host that
  had bounded its provider first got a broken image. The tile now leaves
  an already-bounded provider alone.
- **Sent images** — a user turn's attachments now lift out of the bubble
  and sit above it in a row from the trailing edge: each image a 116
  square tile, cover-cropped, under an `outline` hairline that firms up
  to `outlineVariant` on hover; files as tiles. A picture with no
  caption draws no bubble. `FlowMessageStyle.attachmentCardBorderColor` and
  `attachmentCardHoverBorderColor` restyle the hairline's two inks, and
  `attachmentCardColor` adds a ground behind transparent images.
  Assistant turns keep the inline tiles.
- **Preview** — tapping the frosted space around the picture now closes
  the full-screen viewer, alongside the close button and Escape. A tap on
  the picture itself still does nothing. The close button sits on an
  opaque `surfaceBright` disc with a hairline and the theme's shadow, so
  it reads over any picture in either theme — the translucent wash it
  had vanished over a dark photo — and grows to 44 on touch platforms.
  The backdrop is now the chat view's drop frost, a 12 blur under the
  `surfaceBright` 40% → `surface` 80% wash, so the two read as one.
- **Fix** — the composer's pending strip scrolls its tiles under the
  card's inset, so an overflowing strip cuts the last tile at the edge —
  the cue that there is more.
- **Image parts carry their file** — `FlowImagePart.bytes` and
  `mimeType`, the pair `FlowAttachment` already had and for the same
  reason: a generated picture is half rendered if the conversation cannot
  go on about it. The example sends them back with the history, so a
  follow-up can be about the picture the model drew.
- **Behaviour change** — a pending attachment now arms the send button on
  its own, and `FlowComposer.onSend` can fire with empty text. A picture
  with no caption is a message; before this, it could not be sent.
- **New dependency** — `file_selector`, flutter.dev-published, is what
  the built-in picker opens. It asks nothing of hosts that never attach
  files: no Android permission, no iOS plist string. macOS apps that do
  need `com.apple.security.files.user-selected.read-only` in both
  `DebugProfile.entitlements` and `Release.entitlements`.
- **Breaking**: `FlowMessagePart` is sealed, so the new `FlowImagePart`
  makes any exhaustive `switch` over parts non-exhaustive until it gains
  a case. `FlowShimmerText` also becomes a `StatelessWidget`, which
  breaks a `GlobalKey<State<FlowShimmerText>>` if anyone held one.
- **Image parts** — `FlowImagePart`, the large-format picture in a turn:
  an AI-generated image presented as content, unlike
  `FlowAttachmentPart`'s tiles. A null image renders the generating
  state — a shimmering block at the part's aspect ratio — and the host
  re-renders with the `ImageProvider` when it lands; tapping the picture
  opens the full-screen preview. The example app does exactly this with
  Gemini's image model: pick it in the selector, ask for a picture, and
  the block shimmers until the bytes arrive.
- **Component inks and type roles** — a pass over every component against
  the palette and scale. Grounds that were hand-rolled ink alphas now take
  container tokens: attachment tiles (`surfaceContainerLow`, `High` behind
  an image), the user bubble (`surfaceContainerLow`), the error card and
  the inline-code chip (`surfaceContainer`); the code block's hover edge
  and the menu sheet's border are `outlineVariant`. Disabled content is
  `onSurfaceDisabled` everywhere — a host's own colour override no longer
  shows faded when disabled. Type: the greeting is `headlineMedium` (32),
  markdown `#`/`##`/`###` take the emphasised title cuts, the code block's
  header is `labelMedium`, the error card's title `bodyMediumEmphasised`,
  bubble text sits on the body line (1.5), and the `code` token is 14 (was
  13). Message actions are 15px glyphs on fixed 20px frames, 4 apart,
  washing with `surfaceContainer` on hover; the jump-to-latest shadow
  matches the cards' 2%. Defaults only — no signatures change.
- **Colors** — presets retuned to the design file: ink `#111110`, a hot-pink
  `secondary` (markdown links follow), an indigo `tertiary`, a softer
  `error`, new `success` and `warning` groups, and a `shadow` role — the ink
  at 2%, alpha included — that every raised element's shadow now reads.
  Accent containers are now washes of their accent (8% accents, 6%
  statuses) with the accent as the `on` colour. **Breaking:** `outline`
  and `outlineVariant` swap meaning — `outline` is the faint hairline
  (7%), `outlineVariant` the firm one (12%) — the nine new roles are
  required constructor parameters (`copyWith` on a preset is unaffected),
  and markdown links default to `secondary` rather than `tertiary`. The
  dark preset follows: lifted accents that carry `#1E1E1E` as their `on`
  ink, and hairlines brought down to 8% and 12%.
- **Typefaces** — Google Sans replaces Figtree and Google Sans Code replaces
  Geist Mono. Neither is bundled: the package depends on `google_fonts`,
  which fetches each cut on first use and caches it (ship the files under a
  `google_fonts/` asset folder for offline-first apps). The fetch needs
  `android.permission.INTERNET` in the main Android manifest and the
  `com.apple.security.network.client` entitlement in a sandboxed macOS app.
  `FlowTypography.standard` is now built at runtime, and the new
  `FlowTypography.recut` re-cuts a token at another weight or style, which
  `copyWith(fontWeight:)` no longer can on the standard scale. Hosts that
  named `Figtree` or `GeistMono` directly should update.
- **Fix** — `FlowChatView`'s bottom inset no longer stacks on the safe
  area. The design's 24 (compact) and 40 (wide) are now measured from the
  bottom of the safe area, so a phone's home indicator is absorbed rather
  than added to — a device showed 58 where the design draws 24. Simulated
  frames and desktop, which report no inset, are unchanged, and the full
  inset returns above an open keyboard.
- **Component styles** — Material's component-theme tier, on flow_ui's
  tokens: every major widget now takes an optional style object of
  color and text overrides (`FlowComposerStyle`, `FlowMessageStyle`,
  `FlowMarkdownStyle`, `FlowCodeBlockStyle`, `FlowErrorStateStyle`,
  `FlowMessageActionsStyle`, `FlowPillStyle`, `FlowSuggestionStyle`,
  joining `FlowMenuStyle`), and `FlowTheme` carries an app-wide default
  for each (`FlowTheme.markdownStyle`, …). Resolution is field by field —
  the widget's style wins over the theme's, tokens beneath both; text
  fields merge over their role's base. `FlowMarkdownStyle` opens up the
  markdown surface per element: heading cuts, the link color, the
  inline-code chip, quote, table and rule inks. All additive — nothing
  breaks.
- **Fix** — the composer's card is now the field's hit target: a click on
  its padding, the gap under the field or the empty stretch of the action
  row focuses the field, and the pointer shows the text cursor over all of
  it. Before, only the field's own text run took the click, so a card
  with a short draft was mostly dead space. The buttons, the tiles and
  the host's actions keep their own taps and cursors.
- **Error state** — the card's fill drops two rungs, from
  `surfaceContainer` to `surfaceContainerLowest`, so it sits nearly flush
  with the page and the error hairline carries the state. The composer's
  error tab tightens its inner padding to 16 leading and 8 trailing.
- **Typography** — the `code` and `codeInline` roles, the code block's
  body and the inline span, drop from 14 to 13 on their 1.6 and 1.5
  lines.

## 0.2.0

- **Typography** — title and label roles now carry an emphasised cut
  (`titleLargeEmphasised` / `labelLargeEmphasised`, and the medium/small
  pair for each). The standard scale sizes and line heights are retuned
  to the design file: display at 1.15, headline at 1.2, title/label at
  1.3. Compact `FlowGreeting` uses `titleMedium` instead of a one-off 21.
- **Breaking**: constructing `FlowTypography(...)` now requires the new
  title and label emphasised styles. `FlowTypography.standard` and
  `copyWith` cover the usual host paths; label sizes also step up one
  rung (16 / 14 / 12).
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
  the newest message as before. A new `messageFooter` builder fills each
  default message's footer slot (an actions row, a timestamp) without
  replacing the whole message the way `messageBuilder` does. Default
  padding now gives the conversation 40 above and below (16 at the
  sides, all overridable through `padding`).
- **Chat View** — the thread's scrollbar rides the surface's edge
  instead of hugging the centred rail, and the jump-to-latest button
  sits on an outlined, softly lifted `surface` disc rather than a
  translucent wash.
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
