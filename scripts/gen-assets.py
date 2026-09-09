#!/usr/bin/env python3
"""重新生成各插件的 assets/icon.png 与 assets/logo.png。

风格：白色圆角卡片 + 细边框 + 扁平多彩几何 + 比熊犬头像，三个插件靠品牌色和右上角
徽章区分。icon 为纯图标，logo 在图标下方加插件名。

用法：python3 scripts/gen-assets.py       # 写入各插件 assets/
      python3 scripts/gen-assets.py 目录  # 预览到指定目录
依赖：rsvg-convert（brew install librsvg）
"""
import math, os, pathlib, subprocess, sys, tempfile

S = 512                      # 画布
CARD = dict(x=24, y=24, w=464, h=464, r=116)
INK  = "#1F2328"             # 眼睛/鼻子
FUR_STROKE = "#D5DAE1"       # 白毛描边
FUR_SHADE  = "#F0F2F5"       # 毛发暗部
TONGUE = "#FF8DA1"

PLUGINS = {
    "dd-prd-flow": dict(colors=["#5EEAD4", "#14B8A6", "#0F766E"], label="DD PRD FLOW"),
    "dd-modules":  dict(colors=["#93C5FD", "#3B82F6", "#1D4ED8"], label="DD MODULES"),
    "dd-agent":    dict(colors=["#C4B5FD", "#8B5CF6", "#6D28D9"], label="DD AGENT"),
}


def fluff(cx, cy, rx, ry, n, bump=1.18, phase=0.0):
    """扇贝边闭合路径，模拟比熊的蓬松毛发轮廓。"""
    pts = []
    for i in range(n):
        a = phase + 2 * math.pi * i / n
        pts.append((cx + rx * math.cos(a), cy + ry * math.sin(a)))
    chord = math.dist(pts[0], pts[1])
    r = chord / 2 * bump
    d = [f"M {pts[0][0]:.1f} {pts[0][1]:.1f}"]
    for i in range(1, n + 1):
        x, y = pts[i % n]
        d.append(f"A {r:.1f} {r:.1f} 0 0 1 {x:.1f} {y:.1f}")
    d.append("Z")
    return " ".join(d)


def dog(cx=256, cy=296, scale=1.0):
    """正面比熊犬头像：蓬松大头、宽眼距、大黑鼻、吐舌。"""
    def s(v):
        return v * scale
    g = [f'<g transform="translate({cx} {cy}) scale({scale}) translate({-cx} {-cy})">']
    # 两侧耳朵（藏在蓬毛里，只露出层次）
    g.append(f'<path d="{fluff(cx-118, cy+18, 52, 62, 8, 1.22, 0.3)}" fill="{FUR_SHADE}" stroke="{FUR_STROKE}" stroke-width="5"/>')
    g.append(f'<path d="{fluff(cx+118, cy+18, 52, 62, 8, 1.22, 0.3)}" fill="{FUR_SHADE}" stroke="{FUR_STROKE}" stroke-width="5"/>')
    # 头部主体
    g.append(f'<path d="{fluff(cx, cy, 132, 124, 13, 1.16, -math.pi/2)}" fill="#FFFFFF" stroke="{FUR_STROKE}" stroke-width="5.5"/>')
    # 口鼻区域的柔和毛色分区
    g.append(f'<ellipse cx="{cx}" cy="{cy+52}" rx="62" ry="50" fill="{FUR_SHADE}" opacity="0.75"/>')
    # 眼睛
    for ex in (cx - 47, cx + 47):
        g.append(f'<ellipse cx="{ex}" cy="{cy-14}" rx="17" ry="19.5" fill="{INK}"/>')
        g.append(f'<circle cx="{ex-5}" cy="{cy-22}" r="5.2" fill="#FFFFFF" opacity="0.92"/>')
    # 鼻子
    g.append(f'<path d="M {cx-24} {cy+34} q 24 -16 48 0 q 2 22 -24 30 q -26 -8 -24 -30 Z" fill="{INK}"/>')
    # 嘴 + 舌头
    g.append(f'<path d="M {cx} {cy+62} v 13" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>')
    g.append(f'<path d="M {cx} {cy+75} q -7 21 -33 17" fill="none" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>')
    g.append(f'<path d="M {cx} {cy+75} q 7 21 33 17" fill="none" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>')
    g.append(f'<path d="M {cx-25} {cy+76} h 50 v 22 a 25 26 0 0 1 -50 0 Z" fill="{TONGUE}"/>')
    g.append(f'<path d="M {cx} {cy+86} v 26" stroke="#EF6B85" stroke-width="4" stroke-linecap="round" opacity="0.75"/>')
    g.append('</g>')
    return "\n".join(g)


def badge_flow(c):
    """三张递进的文档卡片。"""
    o = []
    for dx, dy, col in [(-54, 26, c[0]), (-27, 13, c[1]), (0, 0, c[2])]:
        o.append(f'<rect x="{306+dx}" y="{74+dy}" width="92" height="112" rx="18" fill="{col}"/>')
    o.append('<path d="M 328 118 h 48 M 328 140 h 48 M 328 162 h 30" stroke="#FFFFFF" stroke-width="9" stroke-linecap="round" opacity="0.95"/>')
    return "\n".join(o)


def badge_modules(c):
    """等距立方体（模块 / pod）。"""
    cx, cy, w, h = 360, 146, 62, 36
    top = f'M {cx} {cy-h-22} l {w} {h} l {-w} {h} l {-w} {-h} Z'
    left = f'M {cx-w} {cy-22} v 62 l {w} {h} v -62 Z'
    right = f'M {cx+w} {cy-22} v 62 l {-w} {h} v -62 Z'
    return (f'<path d="{left}" fill="{c[1]}"/>'
            f'<path d="{right}" fill="{c[2]}"/>'
            f'<path d="{top}" fill="{c[0]}"/>')


def badge_agent(c):
    """诊断通过：圆环 + 勾。"""
    return (f'<circle cx="364" cy="146" r="70" fill="{c[0]}"/>'
            f'<circle cx="364" cy="146" r="52" fill="{c[2]}"/>'
            f'<path d="M 340 146 l 17 18 l 32 -35" fill="none" stroke="#FFFFFF" '
            f'stroke-width="14" stroke-linecap="round" stroke-linejoin="round"/>')


BADGES = {"dd-prd-flow": badge_flow, "dd-modules": badge_modules, "dd-agent": badge_agent}


def svg(name, with_label=False):
    cfg = PLUGINS[name]
    card = CARD
    body = []
    body.append(f'''<defs><filter id="sh" x="-25%" y="-25%" width="150%" height="150%">
      <feDropShadow dx="0" dy="7" stdDeviation="9" flood-color="#0B1220" flood-opacity="0.10"/>
    </filter></defs>''')

    if with_label:
        cy_shift, card_scale = -34, 0.86
        body.append(f'<g transform="translate({S/2} {S/2 + cy_shift}) scale({card_scale}) translate({-S/2} {-S/2})">')
    body.append(f'<rect x="{card["x"]}" y="{card["y"]}" width="{card["w"]}" height="{card["h"]}" '
                f'rx="{card["r"]}" fill="#FFFFFF" stroke="#E6E9ED" stroke-width="3" filter="url(#sh)"/>')
    body.append(BADGES[name](cfg["colors"]))
    body.append(dog(scale=0.99))
    if with_label:
        body.append('</g>')
        body.append(f'<text x="{S/2}" y="470" text-anchor="middle" font-family="Helvetica Neue, Helvetica, Arial, sans-serif" '
                    f'font-size="37" font-weight="700" letter-spacing="1.2" fill="{cfg["colors"][2]}">{cfg["label"]}</text>')

    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{S}" height="{S}" viewBox="0 0 {S} {S}">'
            + "\n".join(body) + '</svg>')


def render(svg_text, png_path):
    with tempfile.NamedTemporaryFile("w", suffix=".svg", delete=False) as f:
        f.write(svg_text)
        tmp = f.name
    try:
        subprocess.run(["rsvg-convert", "-w", str(S), "-h", str(S), tmp, "-o", str(png_path)], check=True)
    finally:
        os.unlink(tmp)


if __name__ == "__main__":
    root = pathlib.Path(__file__).resolve().parent.parent
    preview = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else None
    if preview:
        preview.mkdir(parents=True, exist_ok=True)
    for name in PLUGINS:
        for kind, labelled in (("icon", False), ("logo", True)):
            dest = (preview / f"{name}-{kind}.png") if preview else (root / name / "assets" / f"{kind}.png")
            dest.parent.mkdir(parents=True, exist_ok=True)
            render(svg(name, labelled), dest)
            print(f"  {dest.relative_to(root) if not preview else dest}")
