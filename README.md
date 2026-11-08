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

- Shows up as **"Rubenchik Mirror"** in the iPhone / iPad *Screen Mirroring* list. No app needed on the phone.
- Fullscreen, hardware-accelerated (Direct3D 11) video at up to 1080p / 60 fps, with audio.
- Plug and play: all libraries and GStreamer plugins are bundled. No MSYS2, GStreamer or Bonjour install needed.
- Windows Firewall rule (private networks), desktop shortcut and optional autostart are set up by the installer; the uninstaller removes everything.
- Open source, built from source by GitHub Actions, based on [UxPlay](https://github.com/FDH2/UxPlay).

## Requirements

- Windows 10 or 11, 64-bit.
- The PC and the iPhone on the **same Wi-Fi network** (5 GHz recommended), and the Windows network set to **Private**.
- Administrator rights for installation (for the firewall rule).

## Install

1. [**Download RubenchikMirror-Setup.exe**](https://github.com/OlegRubenchik/rubenchik-mirror/releases/latest/download/RubenchikMirror-Setup.exe).
2. Run it and click through the wizard. The installer is unsigned: if Windows shows **"Windows protected your PC"**, click **More info → Run anyway**. (Check the download against `RubenchikMirror-Setup.exe.sha256` on the release page if you like.)
3. Start **Rubenchik Mirror** from the desktop shortcut (it also starts with Windows if you left that box ticked).

## Usage

On the iPhone: open **Control Center → Screen Mirroring → Rubenchik Mirror**. The screen appears fullscreen on the PC. Press **Alt+Enter** to toggle fullscreen, close the window or stop the app to disconnect.

To mirror to a TV, connect the laptop by HDMI and make the TV the main display (Win+P → *Duplicate* or *Second screen only*).

Settings (resolution, frame rate, audio device, latency) are in `C:\Program Files\Rubenchik Mirror\uxplayrc`. Use *Start menu → Edit Rubenchik Mirror settings*. Every option is documented in the [UxPlay README](https://github.com/FDH2/UxPlay#readme).

## Troubleshooting

- **Not in the Screen Mirroring list:** the Windows firewall, a different network or *client isolation* is the usual cause. Make sure the PC and iPhone use the same Wi-Fi (not a guest network with client/AP isolation), the PC network profile is **Private** (Settings → Network → Properties), and no third-party firewall/antivirus blocks `uxplay.exe`.
- **Black screen / no picture:** DRM-protected apps (Netflix, Disney+, Apple TV+ ...) block screen mirroring by design on every AirPlay receiver.
- **Lag or stutter:** use 5 GHz Wi-Fi close to the router, or put the PC on Ethernet. For lowest latency uncomment `vsync no` in `uxplayrc`.
- **No sound:** check the Windows default playback device; you can set `as wasapisink` in `uxplayrc`.
- Still stuck? [Open an issue](https://github.com/OlegRubenchik/rubenchik-mirror/issues/new/choose) with logs.

## Uninstall

*Settings → Apps → Installed apps → Rubenchik Mirror → Uninstall.* This removes the program, shortcuts, autostart entry and firewall rule.

## Build from source

Everything is built in GitHub Actions ([`build.yml`](.github/workflows/build.yml)) on `windows-latest`: UxPlay (pinned commit) is compiled with MSYS2 UCRT64, all runtime DLLs and GStreamer plugins are collected with `ntldd` ([`scripts/collect-bundle.sh`](scripts/collect-bundle.sh)), smoke-tested on a clean `PATH`, and packaged with Inno Setup ([`packaging/installer.iss`](packaging/installer.iss)). Pushing a tag like `v1.0.1` publishes a release via [`release.yml`](.github/workflows/release.yml). Every push and pull request builds an installer artifact without releasing.

## Credits

- [UxPlay](https://github.com/FDH2/UxPlay) by antimof, FDH2 and contributors, which builds on RPiPlay, Shairplay and others.
- [GStreamer](https://gstreamer.freedesktop.org/), [FFmpeg](https://ffmpeg.org/), [libplist](https://github.com/libimobiledevice/libplist), [OpenSSL](https://www.openssl.org/), [MSYS2](https://www.msys2.org/), [Inno Setup](https://jrsoftware.org/isinfo.php).

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

[GPL-3.0](LICENSE). Code signing of the installer may be added in the future; until then Windows SmartScreen will warn as described above.

---

*Not affiliated with or endorsed by Apple. AirPlay is a trademark of Apple Inc.*
