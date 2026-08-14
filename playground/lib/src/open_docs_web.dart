import 'dart:js_interop';

@JS('window.location.assign')
external void _assign(JSString url);

@JS('window.open')
external JSAny? _open(JSString url, JSString target);

/// Web: navigate this tab to the docs site at the origin root.
void openDocs() => _assign('/'.toJS);

/// Web: open [url] in a new tab.
void openExternal(String url) => _open(url.toJS, '_blank'.toJS);
