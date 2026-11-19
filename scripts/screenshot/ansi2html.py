#!/usr/bin/env python3
"""Turn `tmux capture-pane -e` output into a standalone HTML page.

usage: ansi2html.py CAPTURE.ansi DEFAULT_FG DEFAULT_BG COLS ROWS > page.html
Handles truecolor/256-color SGR, bold, italic, underline (plain or curly with
underline color), strikethrough and reverse video: what nvim emits.
"""
import html
import re
import sys

CELL_W_EM = 0.6  # JetBrains Mono advance width
FONT_PX = 14
ROW_PX = 20
PAD_PX = 28
SGR = re.compile(r"\x1b\[([0-9;:]*)m")
FONT = "'JetBrainsMono Nerd Font Mono','JetBrains Mono',Menlo,monospace"


def xterm256(n):
    if n < 16:
        return _ansi16(n)
    if n >= 232:
        v = 8 + (n - 232) * 10
        return (v, v, v)
    n -= 16
    steps = [0, 95, 135, 175, 215, 255]
    return (steps[n // 36], steps[(n // 6) % 6], steps[n % 6])


def _ansi16(n):
    table = [(0, 0, 0), (205, 0, 0), (0, 205, 0), (205, 205, 0), (0, 0, 238), (205, 0, 205),
             (0, 205, 205), (229, 229, 229), (127, 127, 127), (255, 0, 0), (0, 255, 0),
             (255, 255, 0), (92, 92, 255), (255, 0, 255), (0, 255, 255), (255, 255, 255)]
    return table[n]


def hexcolor(rgb):
    return "#%02x%02x%02x" % rgb


class Style:
    def __init__(self):
        self.reset()

    def reset(self):
        self.fg = self.bg = self.ul = None
        self.bold = self.italic = self.underline = self.curly = self.strike = self.reverse = False

    def apply(self, params):
        parts = [p for p in params.replace(":", ";").split(";")]
        i = 0
        while i < len(parts):
            code = int(parts[i] or 0)
            i += 1
            if code == 0:
                self.reset()
            elif code == 1:
                self.bold = True
            elif code == 3:
                self.italic = True
            elif code == 4:
                sub = int(parts[i]) if params.startswith("4:") and i < len(parts) else None
                self.underline = sub != 0
                self.curly = sub == 3
                i += 1 if sub is not None else 0
            elif code == 7:
                self.reverse = True
            elif code == 9:
                self.strike = True
            elif code == 22:
                self.bold = False
            elif code == 23:
                self.italic = False
            elif code == 24:
                self.underline = self.curly = False
            elif code == 27:
                self.reverse = False
            elif code == 29:
                self.strike = False
            elif code in (38, 48, 58):
                mode = int(parts[i])
                if mode == 2:
                    r, g, b = (int(x) for x in parts[i + 1:i + 4])
                    i += 4
                    color = (r, g, b)
                else:
                    color = xterm256(int(parts[i + 1]))
                    i += 2
                setattr(self, {38: "fg", 48: "bg", 58: "ul"}[code], color)
            elif code == 39:
                self.fg = None
            elif code == 49:
                self.bg = None
            elif code == 59:
                self.ul = None
            elif 30 <= code <= 37:
                self.fg = _ansi16(code - 30)
            elif 40 <= code <= 47:
                self.bg = _ansi16(code - 40)
            elif 90 <= code <= 97:
                self.fg = _ansi16(code - 90 + 8)
            elif 100 <= code <= 107:
                self.bg = _ansi16(code - 100 + 8)

    def css(self, fg_default, bg_default):
        fg, bg = self.fg or fg_default, self.bg or bg_default
        if self.reverse:
            fg, bg = bg, fg
        rules = [f"color:{hexcolor(fg)}"]
        if bg != bg_default:
            rules.append(f"background:{hexcolor(bg)}")
        if self.bold:
            rules.append("font-weight:700")
        if self.italic:
            rules.append("font-style:italic")
        lines = [name for name, on in (("underline", self.underline), ("line-through", self.strike)) if on]
        if lines:
            rules.append("text-decoration:" + " ".join(lines))
            if self.curly:
                rules.append("text-decoration-style:wavy")
            if self.ul:
                rules.append(f"text-decoration-color:{hexcolor(self.ul)}")
        return ";".join(rules)


def render_line(line, style, fg_default, bg_default):
    """Spans for one captured row; `style` carries SGR state across rows."""
    result, pos = [], 0
    for match in SGR.finditer(line):
        text = line[pos:match.start()]
        if text:
            result.append(f'<span style="{style.css(fg_default, bg_default)}">{html.escape(text)}</span>')
        style.apply(match.group(1))
        pos = match.end()
    tail = line[pos:]
    if tail:
        result.append(f'<span style="{style.css(fg_default, bg_default)}">{html.escape(tail)}</span>')
    return "".join(result)


def main():
    capture, fg_hex, bg_hex, cols, rows = sys.argv[1:6]
    fg_default = tuple(int(fg_hex[i:i + 2], 16) for i in (1, 3, 5))
    bg_default = tuple(int(bg_hex[i:i + 2], 16) for i in (1, 3, 5))
    style = Style()
    lines = open(capture, encoding="utf-8").read().split("\n")[: int(rows)]
    body = "\n".join(f'<div class="row">{render_line(line, style, fg_default, bg_default) or " "}</div>' for line in lines)
    width_px = round(int(cols) * FONT_PX * CELL_W_EM)
    print(f"""<!doctype html><meta charset="utf-8">
<style>
  html, body {{ margin: 0; background: {bg_hex}; }}
  body {{ padding: {PAD_PX}px; width: {width_px}px; }}
  .row {{ height: {ROW_PX}px; line-height: {ROW_PX}px; font: {FONT_PX}px/{ROW_PX}px {FONT}; white-space: pre; color: {hexcolor(fg_default)}; }}
</style>
{body}""")


main()
