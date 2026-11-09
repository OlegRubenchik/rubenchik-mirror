# Changelog

Release notes are also published on the [Releases page](https://github.com/OlegRubenchik/rubenchik-mirror/releases).

## Unreleased

- **Pairing code is shown in the window.** UxPlay only printed the PIN to the console, which the app now closes, so a new iPhone was asked for a code that could not be seen. The window now shows it in large digits (and comes forward if minimized).
- **Choose the receiver's name.** The first start asks for a name ("Living Room"...) that appears in the iPhone's Screen Mirroring list, so several PCs in one home are no longer all called "Rubenchik Mirror". It is saved per Windows user and can be changed by clicking the name in the title bar (the app restarts to apply it).

## 1.3.1

- **In-app updater:** a green *Update vX.Y.Z* button appears in the window title bar when a newer release exists. It downloads the installer, verifies its SHA-256 against the checksum published with the release, runs it silently and restarts the app. The settings file (`uxplayrc`) is no longer overwritten by the installer on updates.
- Installer: restarts the app after a silent (in-app) update.

## 1.3.0

- **Branded host window:** logo waiting screen, custom title bar (minimize, fullscreen, close), drag to move, resize from the edges, F11 / Alt+Enter / Esc for fullscreen. Screen mirroring and YouTube are drawn inside this window. The console window is closed at start, the system window outline is removed.
- **YouTube (HLS) now plays in a bundled mpv instead of GStreamer** (GStreamer's HLS player froze after seeking): up to 1440p, original audio track, pause, seek, speed, volume, subtitles and audio selection from the phone, one window kept between videos, the window closes a few seconds after playback ends.
- Fixed: abort when the iPhone kept sending mirroring packets while YouTube started; the "play" request being lost while switching from mirroring to YouTube; mpv start-up being mistaken for "video finished".
- mpv identifies itself as a standard AirPlay media client (`AppleCoreMedia` User-Agent).
- Windows fixes for UxPlay are kept as a patch in `patches/`; the build applies it.

## 1.2.1

- Bundle the GSettings schemas (fixes a crash when playing YouTube/HLS video).

## 1.2.0

- YouTube support via UxPlay's HLS mode (`hls` option): bundled GStreamer HLS/HTTP plugins and TLS backend.
- Release workflow can also be started manually and attach the installer to an existing release.

## 1.1.0

- Optional PIN protection (installer option, on by default); autostart is now an installer option, off by default.
- CI checks that the build links against OpenSSL 3.x; `THIRD_PARTY_NOTICES.md` and licenses are installed with the app.

## 1.0.0

- First release: UxPlay built for Windows with all dependencies bundled, Inno Setup installer with firewall rule, shortcuts and uninstaller, branding, CI build and release workflows.
