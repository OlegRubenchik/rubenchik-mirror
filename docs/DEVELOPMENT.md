# Development guide

Rubenchik Mirror is [UxPlay](https://github.com/FDH2/UxPlay) built for Windows, plus a set of patches and a Windows installer. This page explains how the pieces fit together and how to build, test and release.

## Repository layout

| Path | What it is |
|---|---|
| `.github/workflows/build.yml` | Builds everything on `windows-latest` (also callable from the release workflow) |
| `.github/workflows/release.yml` | On a `v*.*.*` tag (or manual dispatch) builds and publishes the GitHub Release |
| `patches/0001-windows-hls-fixes.patch` | All changes to UxPlay (see below). Applied to the pinned UxPlay commit during the build |
| `scripts/collect-bundle.sh` | Collects `uxplay.exe`, `mpv.exe`, every DLL (via `ntldd`), the curated GStreamer plugins, schemas and licenses into `dist/app` |
| `scripts/smoke-test.ps1` | Runs on a clean `PATH` (no MSYS2): `uxplay -h`, `mpv`, required GStreamer elements, server start-up |
| `scripts/make_brand_assets.py` | Regenerates `packaging/icon.ico` and the installer images from `assets/` (needs Pillow) |
| `packaging/installer.iss` | Inno Setup script (firewall rule, shortcuts, tasks, uninstaller, silent-update restart) |
| `packaging/uxplayrc`, `uxplayrc.pin` | Default settings (the second one adds `pin`) |
| `assets/` | Logo (SVG), icon (PNG) and the waiting-screen bitmap `idle-logo.bmp` |

## How a build works

1. `build.yml` computes the version (tag `v1.3.2` → `1.3.2`, otherwise `0.0.0-dev`).
2. It clones UxPlay at the commit pinned in `UXPLAY_REF`, removes `-march=native` (so the binary runs on any x86-64 CPU), applies `patches/*.patch`, writes `renderers/rm_version.h` and builds with CMake/Ninja in MSYS2 UCRT64. UxPlay's built-in mDNS responder is used, so **no Bonjour** is needed.
3. CI verifies the build links against OpenSSL 3.x (UxPlay's GPL note requires it).
4. `collect-bundle.sh` builds the relocatable runtime folder `dist/app`: `bin` (exe + DLLs + `mpv.exe`), `lib/gstreamer-1.0`, `libexec`, `share/glib-2.0/schemas`, `etc/fonts`, `licenses`.
5. The smoke test runs on a clean `PATH`. Then Inno Setup builds `RubenchikMirror-Setup.exe` and the `.sha256` file, and a silent install / uninstall test runs on the runner.

## What the patch changes in UxPlay

All code that is not UxPlay's own lives in new header-only files under `renderers/`, and small hooks in existing files:

- `renderers/rm_window.h` – the branded host window (Win32): custom title bar, drag/resize/fullscreen, logo waiting screen, the "Update" button, a child surface into which the renderers draw. It runs on its own thread; the video renderer polls it through a small state callback. GStreamer sinks render into it through `GstVideoOverlay` (UxPlay's existing `video_renderer_set_window_handle`), mpv through `--wid`.
- `renderers/mpv_hls.h` – plays AirPlay HLS (YouTube) video with `mpv.exe` located next to `uxplay.exe`. mpv is started once (idle) and controlled over its JSON IPC named pipe (`loadfile`, `pause`, `seek`, `speed`, `volume`, track selection, `idle-active` / `time-pos` for `/playback-info`). One instance is kept between videos and closed a few seconds after playback ends. mpv is placed in a Windows job object so it dies with `uxplay.exe`.
- Device name and pairing code (in `rm_window.h` / `video_renderer.c`): at start, before the AirPlay service is registered, `video_renderer_ui_device_name()` loads the name from `%APPDATA%\Rubenchik Mirror\device-name.txt` or, on the first run, makes the window show the "Name this receiver" screen and waits for it; the result replaces UxPlay's `server_name`. Clicking the name in the title bar saves a new one and starts a new copy of the app (`RUBENCHIK_DELAY_MS` makes it wait until the old copy has released the network ports). UxPlay's `display_pin()` callback also calls `video_renderer_ui_show_pin()`, which draws the code on the waiting screen.
- `renderers/rm_update.h` – the updater: checks `releases/latest` on GitHub with the Windows `curl.exe`, downloads the installer, verifies SHA-256 with `certutil`, starts it elevated with `/SILENT`.
- `lib/airplay_video.c` – with mpv, the master playlist is pruned to the best variant and its audio/subtitle group (ffmpeg's HLS demuxer probes every variant and does not switch quality); without mpv, only H.264 variants are kept for GStreamer.
- `lib/http_handlers.h`, `lib/raop.h`, `uxplay.cpp` – report the phone's audio/subtitle selection (`selectedMediaArray`) and playback speed (`/rate?value=1.5`) to the renderer; language fallback from the Windows display language (Windows has no `LANG`); software decoder ranking for the GStreamer fallback player; the close button of the window = Ctrl+C; a lost "play" request while switching from mirroring to YouTube is retried.
- `renderers/video_renderer.c` – the glue: no abort when mirroring packets arrive while HLS video plays, state for the host window, start/stop/seek/rate for mpv.

Why mpv: GStreamer's `playbin3`/`hlsdemux2` stalled after a seek or a start at a non-zero position on the development machine (position stays at the seek target), and its hardware decoders (D3D11/D3D12/NVDEC) hung the pipeline. mpv plays the same streams, seeks and pauses reliably.

## Building and testing locally

You do not need a local build for normal changes, CI does it. For fast iteration:

1. Install [MSYS2](https://www.msys2.org/) and, in a UCRT64 shell, the packages listed under `install:` in `build.yml` (gcc, cmake, ninja, pkgconf, openssl, libplist, gstreamer + plugins base/good/bad, gst-libav, libsoup3, glib-networking, mpv, ntldd).
2. Clone UxPlay at the pinned commit, apply the patch, build:
   ```bash
   git clone https://github.com/FDH2/UxPlay.git uxplay-src
   git -C uxplay-src checkout <UXPLAY_REF from build.yml>
   git -C uxplay-src apply ../rubenchik-mirror/patches/0001-windows-hls-fixes.patch
   cmake -S uxplay-src -B uxplay-build -G Ninja -DCMAKE_BUILD_TYPE=Release -DNO_MARCH_NATIVE=ON
   cmake --build uxplay-build
   ```
   Keep the paths short (long paths break git inside the MSYS2 tools on Windows).
3. For the window and YouTube, put `mpv.exe` next to `uxplay.exe`, and `assets/idle-logo.bmp` and `packaging/icon.ico` at `..\assets\idle-logo.bmp` and `..\icon.ico` relative to the exe folder (the installed layout is `<app>\bin\uxplay.exe`, `<app>\assets\idle-logo.bmp`, `<app>\icon.ico`).
4. Run with a log: `RUBENCHIK_CONSOLE=1 uxplay.exe -rc packaging\uxplayrc -d`. `RUBENCHIK_MPV_LOG=<file>` writes mpv's verbose log. A GStreamer log: `GST_DEBUG=3`.
5. A development build has version `0.0.0-dev` and never shows the update button. To test the button, create `renderers/rm_version.h` containing `#define RM_VERSION "1.2.0"` (and touch `video_renderer.c`, the build does not track a header that did not exist before).

### Changing the UxPlay patch

Edit the files in your `uxplay-src` checkout, then regenerate the patch (new files need `git add -N` first) and check it applies to a clean checkout:

```bash
cd uxplay-src
git add -N renderers/mpv_hls.h renderers/rm_window.h renderers/rm_update.h
git diff -- uxplay.cpp lib/airplay_video.c lib/raop.h lib/http_handlers.h \
    renderers/video_renderer.c renderers/video_renderer.h \
    renderers/mpv_hls.h renderers/rm_window.h renderers/rm_update.h > ../rubenchik-mirror/patches/0001-windows-hls-fixes.patch
```

The `-march=native` removal is not part of the patch (it is done with `sed` in `build.yml`). Keep source files with LF line endings (`.gitattributes` enforces it in this repo).

## Releasing

1. Merge to `main` and wait for the *Build* workflow to be green.
2. Tag and push: `git tag -a v1.3.2 -m "Rubenchik Mirror v1.3.2" && git push origin v1.3.2`. The *Release* workflow builds, verifies the checksum and publishes the GitHub Release with `RubenchikMirror-Setup.exe` and `RubenchikMirror-Setup.exe.sha256` (fixed names, so `releases/latest/download/RubenchikMirror-Setup.exe` always works).
3. Add the entry to `CHANGELOG.md`.

The in-app updater of installed copies picks up the new release by itself (it compares the tag with the version baked into the build).

## Known limitations

- Videos opened from Safari or other apps that send a direct HTTPS link are downloaded by the PC itself. Sites that only serve them to the original browser session answer HTTP 403; this cannot be solved on the receiver side.
- DRM-protected apps block mirroring on every AirPlay receiver.
- The installer is not code-signed, so Windows SmartScreen warns on first run.
- UxPlay's `master` (1.74) is pinned; its internal mDNS responder is marked experimental upstream.
