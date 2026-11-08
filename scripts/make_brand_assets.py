"""Regenerates packaging/icon.ico and the Inno Setup wizard images from assets/fresh_icon_dark.png.
Requires Pillow (dev-time only; the generated files are committed)."""
from PIL import Image, ImageDraw, ImageFont

src = Image.open("assets/fresh_icon_dark.png").convert("RGBA")
src.save("packaging/icon.ico", sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])

def gradient(w, h):
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        for x in range(w):
            t = (x / w + y / h) / 2
            px[x, y] = (int(0x14 + (0x0B - 0x14) * t), int(0x17 + (0x0D - 0x17) * t), int(0x1C + (0x10 - 0x1C) * t))
    return img

def font(size, bold=True):
    for p in ("C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf"):
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            pass
    return ImageFont.load_default()

big = gradient(328, 628)
icon = src.resize((220, 220), Image.LANCZOS)
big.paste(icon, (54, 150), icon)
d = ImageDraw.Draw(big)
for text, y, f, col in (("Rubenchik", 400, font(34), (255, 255, 255)),
                        ("Mirror", 440, font(34), (74, 222, 128)),
                        ("AirPlay mirroring for Windows", 500, font(15, False), (160, 170, 180))):
    w = d.textlength(text, font=f)
    d.text(((328 - w) / 2, y), text, font=f, fill=col)
big.save("packaging/wizard-large.bmp")

small = gradient(110, 116)
ic = src.resize((90, 90), Image.LANCZOS)
small.paste(ic, (10, 13), ic)
small.save("packaging/wizard-small.bmp")
