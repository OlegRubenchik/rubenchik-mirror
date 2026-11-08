#!/usr/bin/env bash
# Run inside MSYS2 UCRT64. Builds a self-contained, relocatable runtime folder:
#   $OUT/bin      uxplay.exe + every DLL it (and the plugins) need
#   $OUT/lib/gstreamer-1.0     curated GStreamer plugins
#   $OUT/libexec/gstreamer-1.0 gst-plugin-scanner.exe
# GStreamer on Windows locates plugins relative to its own DLL, so no env vars are needed.
set -euo pipefail
OUT="$(realpath -m "$1")"
UXPLAY_EXE="$(realpath "$2")"
PREFIX="${MSYSTEM_PREFIX:-/ucrt64}"

PLUGINS=(
  coreelements app typefindfunctions playback
  videoparsersbad audioparsers libav
  d3d11 d3d12 wasapi wasapi2 directsound autodetect
  audioconvert audioresample volume videoconvertscale videofilter videorate audiorate audiobuffersplit
  level jpeg imagefreeze pango
  rtp rtpmanager udp tcp isomp4 mpegtsdemux opus
  adaptivedemux2 soup hls
)

rm -rf "$OUT"
mkdir -p "$OUT/bin" "$OUT/lib/gstreamer-1.0" "$OUT/libexec/gstreamer-1.0" "$OUT/licenses"
cp "$UXPLAY_EXE" "$OUT/bin/uxplay.exe"

missing=()
for p in "${PLUGINS[@]}"; do
  f="$PREFIX/lib/gstreamer-1.0/libgst$p.dll"
  if [[ -f "$f" ]]; then cp "$f" "$OUT/lib/gstreamer-1.0/"; else missing+=("$p"); fi
done
if [[ ${#missing[@]} -gt 0 ]]; then echo "::warning::GStreamer plugins not found (skipped): ${missing[*]}"; fi

# GIO TLS backend (glib-networking): needed for https downloads of YouTube HLS segments.
mkdir -p "$OUT/lib/gio/modules"
cp "$PREFIX"/lib/gio/modules/libgio*.dll "$OUT/lib/gio/modules/"

cp "$PREFIX/libexec/gstreamer-1.0/gst-plugin-scanner.exe" "$OUT/libexec/gstreamer-1.0/"
# gst-inspect is copied for the CI check only; the workflow removes it before packaging.
cp "$PREFIX/bin/gst-inspect-1.0.exe" "$OUT/bin/"

# Resolve DLL dependencies of every binary (ntldd -R is already recursive, so one pass over the
# executables and plugins covers all transitive DLLs). Keep only DLLs from the MSYS2 prefix.
prefix_win="$(cygpath -w "$PREFIX" | tr 'A-Z' 'a-z')"
collect() {
  ntldd -R "$1" | awk '$2=="=>" {print $3}' | tr "A-Z" "a-z" | grep -F "$prefix_win" || true
}
mapfile -t roots < <(find "$OUT" -name '*.exe' -o -name '*.dll')
for bin in "${roots[@]}"; do collect "$bin"; done | sort -u | while read -r dll; do
  [[ -n "$dll" ]] && cp -n "$(cygpath -u "$dll")" "$OUT/bin/"
done

# (Completeness is verified by scripts/smoke-test.ps1, which runs with a PATH that excludes MSYS2.)

# License texts of MSYS2 packages whose files we redistribute.
if [[ -d "$PREFIX/share/licenses" ]]; then cp -r "$PREFIX/share/licenses/." "$OUT/licenses/"; fi

echo "Bundle size:"; du -sh "$OUT"; ls "$OUT/bin" | wc -l
