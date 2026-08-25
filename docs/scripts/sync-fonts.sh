#!/usr/bin/env bash
# Copies the package's bundled Google Sans faces (the four weights the design
# uses) into the docs site, keeping repo fonts/ the single source. Runs
# automatically via the predev/prebuild npm hooks.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p public/fonts
cp ../fonts/GoogleSans-Regular.ttf \
   ../fonts/GoogleSans-Medium.ttf \
   ../fonts/GoogleSans-SemiBold.ttf \
   ../fonts/GoogleSans-Bold.ttf \
   ../fonts/OFL-GoogleSans.txt \
   public/fonts/
