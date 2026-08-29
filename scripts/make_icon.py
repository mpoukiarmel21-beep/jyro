import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

S = 1024
out = sys.argv[1] if len(sys.argv) > 1 else "jyro-icon.png"

base = Image.new("RGB", (S, S))
top = (49, 39, 131)
mid = (68, 42, 140)
bot = (20, 10, 56)
px = base.load()
for y in range(S):
    t = y / (S - 1)
    if t < 0.5:
        f = t / 0.5
        c = [top[i] + (mid[i] - top[i]) * f for i in range(3)]
    else:
        f = (t - 0.5) / 0.5
        c = [mid[i] + (bot[i] - mid[i]) * f for i in range(3)]
    for x in range(S):
        px[x, y] = (int(c[0]), int(c[1]), int(c[2]))

img = base.convert("RGBA")
d = ImageDraw.Draw(img, "RGBA")

cx, cy, cr = 512, 508, 430
for r in range(cr, 0, -2):
    alpha = int(34 * (1 - r / cr))
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(150, 120, 255, alpha))

for r in range(340, 0, -3):
    alpha = int(22 * (1 - r / 340))
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(200, 180, 255, alpha))

bubbles = [(232, 232, 52), (820, 300, 30), (772, 692, 42), (286, 768, 28)]
for bx, by, br in bubbles:
    for r in range(br, 0, -1):
        alpha = int(46 * (1 - r / br))
        d.ellipse([bx - r, by - r, bx + r, by + r], fill=(170, 145, 255, alpha))

font_path = "C:/Windows/Fonts/Bahnschrift.ttf"
try:
    f = ImageFont.truetype(font_path, 500)
except Exception:
    f = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 500)

txt = Image.new("RGBA", (S, S), (0, 0, 0, 0))
td = ImageDraw.Draw(txt)
bbox = td.textbbox((0, 0), "Jy", font=f)
tw = bbox[2] - bbox[0]
th = bbox[3] - bbox[1]
pos = ((S - tw) / 2 - bbox[0], (S - th) / 2 - bbox[1] + 20)
td.text(pos, "Jy", font=f, fill=(255, 255, 255, 255))
glow = txt.filter(ImageFilter.GaussianBlur(14))
img = Image.alpha_composite(img, glow)
img = Image.alpha_composite(img, txt)

d = ImageDraw.Draw(img, "RGBA")
dot_r = 16
for i, (entry) in enumerate([(0.5, 640), (0.5 + 64, 662)]):
    pass
horiz_dots = [(512, 700), (1000, 560)]
for dx, dy in horiz_dots:
    d.ellipse([dx - dot_r, dy - dot_r, dx + dot_r, dy + dot_r], fill=(255, 255, 255, 220))

img.convert("RGB").save(out, "PNG")
print("saved", out)