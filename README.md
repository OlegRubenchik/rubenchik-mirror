<p align="center">
  <img src="assets/fresh_logo_dark.svg" alt="Rubenchik Mirror" width="480">
</p>

<h3 align="center">Mirror your iPhone to a Windows PC or TV in one click. Free, open source, no extra software.</h3>

<p align="center">
  <a href="https://github.com/OlegRubenchik/rubenchik-mirror/releases/latest/download/RubenchikMirror-Setup.exe">
    <img src="https://img.shields.io/badge/%E2%AC%87%20Download%20for%20Windows-RubenchikMirror--Setup.exe-22c55e?style=for-the-badge&logo=windows&logoColor=white" alt="Download for Windows">
  </a>
</p>

<p align="center">
  <a href="https://github.com/OlegRubenchik/rubenchik-mirror/actions/workflows/build.yml"><img src="https://github.com/OlegRubenchik/rubenchik-mirror/actions/workflows/build.yml/badge.svg" alt="Build"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-blue" alt="License GPL-3.0"></a>
  <a href="https://github.com/OlegRubenchik/rubenchik-mirror/releases/latest"><img src="https://img.shields.io/github/v/release/OlegRubenchik/rubenchik-mirror" alt="Latest release"></a>
</p>

## Features

- Shows up in the iPhone / iPad *Screen Mirroring* list under **a name you choose** (for example "Living Room"): the app asks for it on the first start, so several PCs in one home can be told apart. No app needed on the phone.
- **One branded window** for everything: a logo "waiting" screen, a minimal title bar (minimize, fullscreen, close, drag to move, resize from the edges), and the video drawn inside it. Fullscreen with F11, Alt+Enter or the title-bar button.
- **Screen mirroring** with hardware-accelerated Direct3D 11 rendering, up to 1080p / 60 fps, with audio.
- **YouTube from the iPhone app:** tap the AirPlay icon in the YouTube app and the video plays on the PC in up to 1440p, with the phone as a remote control: play/pause, seeking, playback speed, volume, subtitles, switching to another video (the window stays open). The original audio track is used by default. Playback is done by the bundled [mpv](https://mpv.io/).
- **Updates from inside the app:** when a new release is published, a green *Update vX.Y.Z* button appears in the title bar. One click downloads the installer from GitHub, verifies its SHA-256 checksum, updates the app and starts it again. Your settings are kept.
- Plug and play: all libraries, GStreamer plugins and mpv are bundled. No MSYS2, GStreamer, mpv or Bonjour install needed (UxPlay's built-in mDNS responder is used).
- Optional PIN protection: the iPhone must enter a code shown on the PC before mirroring (on by default in the installer).
- Windows Firewall rule (private networks) and desktop shortcut are set up by the installer; autostart is optional (off by default). The uninstaller removes everything.
- Open source, built from source by GitHub Actions, based on [UxPlay](https://github.com/FDH2/UxPlay).

## Requirements

- Windows 10 or 11, 64-bit.
- The PC and the iPhone on the **same Wi-Fi network** (5 GHz recommended), and the Windows network set to **Private**.
- Administrator rights for installation (for the firewall rule) and for updates.

## Install

1. [**Download RubenchikMirror-Setup.exe**](https://github.com/OlegRubenchik/rubenchik-mirror/releases/latest/download/RubenchikMirror-Setup.exe).
2. Run it and click through the wizard. The installer is unsigned: if Windows shows **"Windows protected your PC"**, click **More info → Run anyway**. (Check the download against `RubenchikMirror-Setup.exe.sha256` on the release page if you like.)
3. Start **Rubenchik Mirror** from the desktop shortcut or Start menu. Installer options: desktop shortcut, *start with Windows* (unchecked by default) and *require a PIN* (checked by default).

## Usage

### Screen mirroring

**First start:** the window asks you to **name this receiver** (it suggests `Rubenchik Mirror (<PC name>)`). Use a different name for every PC, e.g. *Living Room* or *Bedroom*. The name is saved per Windows user in `%APPDATA%\Rubenchik Mirror\device-name.txt`. To change it later, click the name shown in the title bar, type a new one and press *Save* (the app restarts to apply it).

On the iPhone: open **Control Center → Screen Mirroring** and pick the name you chose. The screen appears in the Rubenchik Mirror window. Drag the title bar to move the window, use the title-bar buttons or **F11 / Alt+Enter** for fullscreen (**Esc** leaves fullscreen), and stop mirroring on the iPhone or close the window to disconnect.

**PIN:** the first time an iPhone connects, the iPhone asks for a code and the Rubenchik Mirror window shows it in large digits ("Enter this code on your iPhone"; the window is brought forward if it was minimized). After you enter it once, the iPhone remembers this PC and does not ask again (to be asked again, make the iPhone forget the receiver). To change this later, add or remove the line `pin` in `uxplayrc` (use `pw yourpassword`, at least 6 characters, instead for a fixed password). PIN protection stops casual use by other devices on your network but does not add encryption beyond what AirPlay already does.

To mirror to a TV, connect the laptop by HDMI and make the TV the main display (Win+P → *Duplicate* or *Second screen only*), then use fullscreen.

### YouTube

Open a video in the YouTube iPhone app, tap the AirPlay/cast icon and choose *Rubenchik Mirror*. The video opens in the same window. Everything is controlled from the phone: pause, seek, speed (1.5x, 2x...), volume, captions, next video. When the video ends or you stop casting, the window returns to the logo screen. The `hls` line in `uxplayrc` enables this feature.

### Settings

Settings (resolution, frame rate, audio device, latency, window behaviour) are in `C:\Program Files\Rubenchik Mirror\uxplayrc`: *Start menu → Edit Rubenchik Mirror settings*, then restart the app. The file is written on the first install only, so **updates keep your changes**. Every UxPlay option is documented in the [UxPlay README](https://github.com/FDH2/UxPlay#readme). Useful ones:

| Line in `uxplayrc` | Effect |
|---|---|
| `fs` | go fullscreen automatically when a video starts |
| `s 1920x1080@60`, `fps 60` | resolution and frame rate requested from the iPhone |
| `as wasapisink` | choose the Windows audio sink |
| `vsync no` | lowest latency (no audio/video timestamp sync) |
| `pin` / `pw secret` | PIN on first connection / fixed password |

### Environment variables

| Variable | Effect |
|---|---|
| `RUBENCHIK_CONSOLE=1` | keep the console window (the app normally closes it at start); useful with `-d` for logs |
| `RUBENCHIK_NO_UI=1` | do not use the branded window; the video renderers open their own windows |
| `RUBENCHIK_NO_MPV=1` | play YouTube with the built-in GStreamer player instead of mpv |
| `RUBENCHIK_NO_UPDATE_CHECK=1` | disable the update check |
| `RUBENCHIK_MPV_LOG=<file>` | write mpv's verbose log to a file |

## Updating

Normally just click the green **Update** button when it appears. It downloads `RubenchikMirror-Setup.exe` from the GitHub release, compares its SHA-256 with the checksum published next to it, and runs the installer silently (Windows asks for administrator approval). Versions before 1.3.1 have no update button: install 1.3.1 or newer once by hand. You can also always download the newest installer from the link at the top.

## Troubleshooting

- **Not in the Screen Mirroring list:** the Windows firewall, a different network or *client isolation* is the usual cause. Make sure the PC and iPhone use the same Wi-Fi (not a guest network with client/AP isolation), the PC network profile is **Private** (Settings → Network → Properties), and no third-party firewall/antivirus blocks `uxplay.exe`.
- **Black screen / no picture while mirroring:** DRM-protected apps (Netflix, Disney+, Apple TV+ ...) block screen mirroring by design on every AirPlay receiver.
- **Safari / website video does nothing or stays black:** the phone sends the video's address and the PC downloads it itself. Some sites only serve their video to the original browser session and answer every request from a receiver with an error (HTTP 403). Nothing can be done about it on the receiver side; screen mirroring still works for those videos.
- **Lag or stutter:** use 5 GHz Wi-Fi close to the router, or put the PC on Ethernet. For lowest latency uncomment `vsync no` in `uxplayrc`.
- **No sound:** check the Windows default playback device; you can set `as wasapisink` in `uxplayrc`.
- **The window does not appear / the app closes at start:** run `RUBENCHIK_CONSOLE=1` and start `bin\uxplay.exe -rc uxplayrc -d` from a terminal to see the log.
- Still stuck? [Open an issue](https://github.com/OlegRubenchik/rubenchik-mirror/issues/new/choose) with logs.

## Uninstall

*Settings → Apps → Installed apps → Rubenchik Mirror → Uninstall.* This removes the program, shortcuts, the autostart entry (if you enabled it) and the firewall rule.

## Build from source

Everything is built in GitHub Actions ([`build.yml`](.github/workflows/build.yml)) on `windows-latest`: UxPlay (pinned commit) gets the patches from [`patches/`](patches), is compiled with MSYS2 UCRT64, all runtime DLLs, GStreamer plugins and mpv are collected with `ntldd` ([`scripts/collect-bundle.sh`](scripts/collect-bundle.sh)), smoke-tested on a clean `PATH`, and packaged with Inno Setup ([`packaging/installer.iss`](packaging/installer.iss)). Every push to `main` and every pull request builds an installer artifact without releasing; pushing a tag like `v1.3.2` publishes a release via [`release.yml`](.github/workflows/release.yml).

How it is put together, how to build and test locally, and how to change the UxPlay patches: see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md). Release history: [CHANGELOG.md](CHANGELOG.md).

## Credits

- Rubenchik Mirror is **based on UxPlay and modified by Oleg Rubenchik** (Windows packaging, installer, branded window, mpv backend, updater, defaults).
- [UxPlay](https://github.com/FDH2/UxPlay) by antimof, FDH2 and contributors, which builds on RPiPlay, Shairplay and others.
- [mpv](https://mpv.io/), [GStreamer](https://gstreamer.freedesktop.org/), [FFmpeg](https://ffmpeg.org/), [libplist](https://github.com/libimobiledevice/libplist), [OpenSSL](https://www.openssl.org/), [MSYS2](https://www.msys2.org/), [Inno Setup](https://jrsoftware.org/isinfo.php).

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[GPL-3.0](LICENSE). The license, `THIRD_PARTY_NOTICES.md` and the bundled components' license texts are also installed with the app. The build is linked against OpenSSL 3.x (checked in CI), as UxPlay's license note requires. Code signing of the installer may be added in the future; until then Windows SmartScreen will warn as described above.

---

*Not affiliated with or endorsed by Apple. AirPlay is a trademark of Apple Inc.*
