# Third-party notices

**Rubenchik Mirror is based on [UxPlay](https://github.com/FDH2/UxPlay) and modified by Oleg Rubenchik** (Windows build
and packaging, installer, default configuration, branding). UxPlay itself is the work of its authors; see below.
Copyright of the UxPlay code remains with its respective authors. Modifications (c) Oleg Rubenchik, GPL-3.0.

Rubenchik Mirror is a packaging of the open-source AirPlay server **UxPlay** for Windows. It is itself licensed under
the GNU General Public License v3.0 (see `LICENSE`). It contains the following third-party software, redistributed
under each component's own license. The license texts of the bundled MSYS2 packages are installed in the `licenses`
folder next to the application.

| Component | Role | License |
|---|---|---|
| [UxPlay](https://github.com/FDH2/UxPlay) (FDH2 and contributors) | AirPlay mirroring server (`uxplay.exe`) | GPL-3.0 (see `UxPlay-LICENSE.txt`) |
| RPiPlay, Shairplay, playfair and other code included in UxPlay | AirPlay protocol implementation | GPL-3.0 / LGPL-2.1, as stated in the UxPlay source tree |
| [GStreamer](https://gstreamer.freedesktop.org/) core, base, good and bad plugins | Video/audio decoding and rendering (Direct3D 11, WASAPI) | LGPL-2.1-or-later |
| [FFmpeg / libav](https://ffmpeg.org/) via `gst-libav` | H.264 and AAC/ALAC decoding | LGPL-2.1-or-later (as built by MSYS2) |
| [mpv](https://mpv.io/) (and its libraries: FFmpeg, libass, libplacebo, ...) | Plays YouTube / HLS video sent by the iPhone (`mpv.exe`, controlled by `uxplay.exe` over mpv's IPC pipe) | GPL-2.0-or-later (as built by MSYS2; compatible with GPL-3.0) |
| [libplist](https://github.com/libimobiledevice/libplist) | Apple property-list parsing | LGPL-2.1-or-later |
| [OpenSSL](https://www.openssl.org/) 3.x | Cryptography. CI verifies the build links against OpenSSL 3.0.0 or later, as UxPlay requires for GPL compliance | Apache-2.0 |
| UxPlay's internal mDNS responder (`lib/mdnsd`, by Juho Vähä-Herttua, kgbook and FDH2) | Service discovery, so that the iPhone can find the receiver. Apple's Bonjour / mDNSResponder (Apache-2.0) is **not** used or bundled | LGPL-2.1-or-later |
| GLib, GObject, GIO, libffi, zlib and other runtime libraries from [MSYS2](https://www.msys2.org/) (MinGW-w64 UCRT64) | Runtime dependencies | Various (mostly LGPL-2.1+, MIT, zlib); see the `licenses` folder |
| [Inno Setup](https://jrsoftware.org/isinfo.php) | Used at build time to create the installer (not redistributed) | Inno Setup License |

## Source code

The exact UxPlay source used for each release is the commit pinned in
[`.github/workflows/build.yml`](.github/workflows/build.yml) (`UXPLAY_REF`) from <https://github.com/FDH2/UxPlay>,
built from unmodified UxPlay source except for removing `-march=native` so the binary runs on any x86-64 CPU.
Source for the bundled MSYS2 packages is available from <https://packages.msys2.org/> and
<https://github.com/msys2/MINGW-packages>.

## Trademarks

Not affiliated with or endorsed by Apple. AirPlay, iPhone and iOS are trademarks of Apple Inc.
Apple's Bonjour software is **not** bundled or required: UxPlay's built-in mDNS responder is used.
