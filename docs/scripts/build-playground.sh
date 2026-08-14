#!/usr/bin/env bash
# Builds the playground app for the web and stages it into public/playground,
# where `astro build` copies it verbatim into dist — one deploy serves the
# docs at / and the playground (plus the docs' live demo embeds) at
# /playground/.
#
# --wasm: skwasm runs multithreaded on the standalone playground, where
# public/_headers sets COOP/COEP on /playground/* — and degrades to
# single-threaded inside the docs' demo iframes, whose top-level pages are
# deliberately not cross-origin isolated. Browsers without WasmGC fall back
# to the bundled JS build.
# --pwa-strategy=none: no service worker serving a stale playground.
set -euo pipefail
cd "$(dirname "$0")/.."
(cd ../playground && flutter pub get && flutter build web --release --wasm --base-href /playground/ --pwa-strategy=none)
rm -rf public/playground
mkdir -p public
cp -R ../playground/build/web public/playground
