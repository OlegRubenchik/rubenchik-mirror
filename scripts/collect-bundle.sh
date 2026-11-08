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
  rtp rtpmanager udp tcp isomp4 mpegtsdemux opus
)

rm -rf "$OUT"
mkdir -p "$OUT/bin" "$OUT/lib/gstreamer-1.0" "$OUT/libexec/gstreamer-1.0" "$OUT/licenses"
cp "$UXPLAY_EXE" "$OUT/bin/uxplay.exe"

missing=()
for p in "${PLUGINS[@]}"; do
  f="$PREFIX/lib/gstreamer-1.0/libgst$p.dll"
  if [[ -f "$f" ]]; then cp "$f" "$OUT/lib/gstreamer-1.0/"; else missing+=("$p"); fi
done
[[ ${#missing[@]} -gt 0 ]] && echo "::warning::GStreamer plugins not found (skipped): ${missing[*]}"

cp "$PREFIX/libexec/gstreamer-1.0/gst-plugin-scanner.exe" "$OUT/libexec/gstreamer-1.0/"
# gst-inspect is copied for the CI check only; the workflow removes it before packaging.
cp "$PREFIX/bin/gst-inspect-1.0.exe" "$OUT/bin/"

# Resolve DLL dependencies (recursively) of every binary; keep only those from the MSYS2 prefix.
prefix_win="$(cygpath -w "$PREFIX" | tr 'A-Z' 'a-z')"
collect() {
  ntldd -R "$1" | sed -n 's/.*=> *\(.*\) (0x.*/\1/p' | while read -r dll; do
    [[ -z "$dll" || "$dll" == "not found" ]] && continue
    low="$(echo "$dll" | tr 'A-Z' 'a-z')"
    [[ "$low" == "$prefix_win"* ]] && cygpath -u "$dll"
  done
}
find "$OUT" \( -name '*.exe' -o -name '*.dll' \) | while read -r bin; do collect "$bin"; done | sort -u | while read -r dll; do
  cp -n "$dll" "$OUT/bin/"
done
# Plugins' dependencies may themselves pull in more DLLs: iterate until stable.
for _ in 1 2 3; do
  find "$OUT/bin" -name '*.dll' | while read -r bin; do collect "$bin"; done | sort -u | while read -r dll; do
    cp -n "$dll" "$OUT/bin/"
  done
done

# Verify nothing is unresolved except Windows system DLLs.
bad=0
while read -r bin; do
  if ntldd -R "$bin" | grep -i "not found" | grep -v -i -E 'api-ms-win|ext-ms-win' ; then bad=1; fi
done < <(find "$OUT" \( -name '*.exe' -o -name '*.dll' \))
[[ $bad -eq 0 ]] || { echo "::error::Unresolved dependencies"; exit 1; }

# License texts of MSYS2 packages whose files we redistribute.
[[ -d "$PREFIX/share/licenses" ]] && cp -r "$PREFIX/share/licenses/." "$OUT/licenses/" || true

echo "Bundle size:"; du -sh "$OUT"; ls "$OUT/bin" | wc -l
