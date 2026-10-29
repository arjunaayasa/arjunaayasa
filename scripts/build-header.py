"""Renders assets/header-{light,dark}.svg.

Text is converted to outlines so the brand typefaces render exactly on GitHub,
which may not load fonts embedded in an SVG. The header is static: re-run this
only when its wording changes.

    python3 -m pip install fonttools brotli uharfbuzz
    python3 scripts/build-header.py
"""

import io
from pathlib import Path

import uharfbuzz as hb
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
FONTS = ROOT / "assets" / "fonts"

EYEBROW = "FOUNDER & CEO  ·  ARSYA DIGITAL INDONESIA"
NAME = "Arjuna Ayasa Putra"
TAGLINE = "Websites, software and AI — built carefully, shipped beautifully."

# Same brand tokens as scripts/lib.mjs.
THEMES = {
    "light": {"surface": "#f5efe4", "ink": "#2b2118", "ink_soft": "#6f6051",
              "hairline": "rgba(43,33,24,0.14)", "accent": "#c2613e"},
    "dark": {"surface": "#261c13", "ink": "#f1e9da", "ink_soft": "#b3a591",
             "hairline": "rgba(241,233,218,0.14)", "accent": "#c2613e"},
}

W, PAD = 840, 36


class Face:
    def __init__(self, name):
        ttf = TTFont(FONTS / f"{name}.woff2")
        ttf.flavor = None
        buf = io.BytesIO()
        ttf.save(buf)
        self.tt = TTFont(io.BytesIO(buf.getvalue()))
        self.glyphs = self.tt.getGlyphSet()
        self.order = self.tt.getGlyphOrder()
        self.upem = self.tt["head"].unitsPerEm
        self.hb = hb.Font(hb.Face(hb.Blob(buf.getvalue())))

    def path(self, text, x, y, size, tracking=0.0):
        """Outline `text` with its left baseline at (x, y). Returns (d, width)."""
        buf = hb.Buffer()
        buf.add_str(text)
        buf.guess_segment_properties()
        hb.shape(self.hb, buf, {"kern": True, "liga": True})
        scale = size / self.upem
        pen = SVGPathPen(self.glyphs, ntos=lambda v: f"{v:.2f}".rstrip("0").rstrip("."))
        cursor = 0.0
        for info, pos in zip(buf.glyph_infos, buf.glyph_positions):
            gx = x + (cursor + pos.x_offset) * scale
            gy = y - pos.y_offset * scale
            self.glyphs[self.order[info.codepoint]].draw(
                TransformPen(pen, (scale, 0, 0, -scale, gx, gy)))
            cursor += pos.x_advance + tracking * self.upem / size
        width = (cursor - tracking * self.upem / size) * scale
        return pen.getCommands(), width


def render(theme, serif, italic, sans):
    t = THEMES[theme]
    eyebrow, _ = sans.path(EYEBROW, PAD + 14, 58, 12.5, tracking=2.0)
    name, name_w = serif.path(NAME, PAD - 2, 132, 72)
    period, _ = serif.path(".", PAD - 2 + name_w + 1, 132, 72)
    tagline, tagline_w = italic.path(TAGLINE, PAD, 184, 27)
    assert tagline_w < W - 2 * PAD, "tagline is wider than the card"
    h = 222
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{h}" viewBox="0 0 {W} {h}" role="img" aria-labelledby="t">
<title id="t">{NAME}, Founder &amp; CEO of Arsya Digital Indonesia. {TAGLINE}</title>
<rect x="0.5" y="0.5" width="{W - 1}" height="{h - 1}" rx="14" fill="{t['surface']}" stroke="{t['hairline']}"/>
<circle cx="{PAD + 3.5}" cy="53.5" r="3.5" fill="{t['accent']}"/>
<path fill="{t['ink_soft']}" d="{eyebrow}"/>
<path fill="{t['ink']}" d="{name}"/>
<path fill="{t['accent']}" d="{period}"/>
<path fill="{t['ink_soft']}" d="{tagline}"/>
</svg>
"""


def main():
    serif = Face("InstrumentSerif-Regular")
    italic = Face("InstrumentSerif-Italic")
    sans = Face("HankenGrotesk-600")
    for theme in THEMES:
        (ROOT / "assets" / f"header-{theme}.svg").write_text(render(theme, serif, italic, sans))


if __name__ == "__main__":
    main()
