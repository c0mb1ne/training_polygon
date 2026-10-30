#!/usr/bin/env python3
"""
bake_shatter.py - bake 3D-ish shatter trajectories for pieceN.svg masks.

Run it inside the folder that contains piece1.svg ... pieceN.svg:

    python bake_shatter.py
    python bake_shatter.py --spread 900 --tilt 70 --depth 150 --seed 7

What it does
  1. Reads every piece*.svg and finds each shard's centroid.
  2. Finds the impact point (where the cracks meet) automatically,
     or you can pass it: --origin 0.488,0.453  (normalized 0..1)
  3. Each shard flies straight away from the impact point, and tumbles
     around the axis of its own flight direction (like a bullet spinning),
     using  rotateZ(a) rotateX(tilt) rotateZ(-a)  so there is no flat 2D spin.

Outputs (next to the svgs):
    shatter_baked.json   raw data
    shatter_baked.js     const SHATTER_DATA = [...]
    shatter_baked.css    base + .Shattered rules per piece (just AddClass('Shattered'))

No third-party packages needed.
"""
import argparse
import glob
import json
import math
import os
import random
import re
import sys
import xml.etree.ElementTree as ET

TOKEN = re.compile(r'[MmLlHhVvCcSsQqTtAaZz]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?')
NARGS = dict(M=2, L=2, H=1, V=1, C=6, S=4, Q=4, T=2, A=7, Z=0)


# ----------------------------------------------------------------- geometry
def bezier(p0, p1, p2, p3, n=12):
    pts = []
    for k in range(1, n + 1):
        t = k / n
        u = 1 - t
        x = u**3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t**3 * p3[0]
        y = u**3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t**3 * p3[1]
        pts.append((x, y))
    return pts


def quad(p0, p1, p2, n=10):
    pts = []
    for k in range(1, n + 1):
        t = k / n
        u = 1 - t
        pts.append((u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0],
                    u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]))
    return pts


def parse_path(d):
    """Flatten an SVG path into a list of subpaths (lists of points).
    Arcs are approximated by their end point."""
    toks = TOKEN.findall(d)
    subpaths, cur = [], []
    x = y = sx = sy = 0.0
    i = 0
    cmd = None
    prev_kind, prev_ctrl = None, None  # for S / T reflection

    while i < len(toks):
        if toks[i].isalpha():
            cmd = toks[i]
            i += 1
            if cmd in 'Zz':
                if cur:
                    subpaths.append(cur)
                    cur = []
                x, y = sx, sy
                prev_kind, prev_ctrl = None, None
                continue
        if cmd is None:
            break

        C = cmd.upper()
        rel = cmd.islower()
        n = NARGS[C]
        a = [float(t) for t in toks[i:i + n]]
        i += n
        if len(a) < n:
            break

        ox, oy = (x, y) if rel else (0.0, 0.0)

        if C != 'M' and not cur:
            cur = [(x, y)]

        if C == 'M':
            x, y = ox + a[0], oy + a[1]
            sx, sy = x, y
            if cur:
                subpaths.append(cur)
            cur = [(x, y)]
            cmd = 'l' if rel else 'L'  # extra pairs after M are implicit lineto
            prev_kind, prev_ctrl = None, None
        elif C == 'L':
            x, y = ox + a[0], oy + a[1]
            cur.append((x, y))
            prev_kind, prev_ctrl = None, None
        elif C == 'H':
            x = (x + a[0]) if rel else a[0]
            cur.append((x, y))
            prev_kind, prev_ctrl = None, None
        elif C == 'V':
            y = (y + a[0]) if rel else a[0]
            cur.append((x, y))
            prev_kind, prev_ctrl = None, None
        elif C == 'C':
            p1 = (ox + a[0], oy + a[1])
            p2 = (ox + a[2], oy + a[3])
            p3 = (ox + a[4], oy + a[5])
            cur += bezier((x, y), p1, p2, p3)
            x, y = p3
            prev_kind, prev_ctrl = 'C', p2
        elif C == 'S':
            if prev_kind == 'C':
                p1 = (2 * x - prev_ctrl[0], 2 * y - prev_ctrl[1])
            else:
                p1 = (x, y)
            p2 = (ox + a[0], oy + a[1])
            p3 = (ox + a[2], oy + a[3])
            cur += bezier((x, y), p1, p2, p3)
            x, y = p3
            prev_kind, prev_ctrl = 'C', p2
        elif C == 'Q':
            p1 = (ox + a[0], oy + a[1])
            p2 = (ox + a[2], oy + a[3])
            cur += quad((x, y), p1, p2)
            x, y = p2
            prev_kind, prev_ctrl = 'Q', p1
        elif C == 'T':
            if prev_kind == 'Q':
                p1 = (2 * x - prev_ctrl[0], 2 * y - prev_ctrl[1])
            else:
                p1 = (x, y)
            p2 = (ox + a[0], oy + a[1])
            cur += quad((x, y), p1, p2)
            x, y = p2
            prev_kind, prev_ctrl = 'Q', p1
        elif C == 'A':
            x, y = ox + a[5], oy + a[6]
            cur.append((x, y))
            prev_kind, prev_ctrl = None, None

    if cur:
        subpaths.append(cur)
    return subpaths


def shape_centroid(subpaths):
    """Area-weighted centroid over all subpaths (shoelace). Falls back to bbox center."""
    total_a = cx_sum = cy_sum = 0.0
    all_pts = []
    for pts in subpaths:
        all_pts += pts
        if len(pts) < 3:
            continue
        a = cx = cy = 0.0
        for k in range(len(pts)):
            x0, y0 = pts[k]
            x1, y1 = pts[(k + 1) % len(pts)]
            cross = x0 * y1 - x1 * y0
            a += cross
            cx += (x0 + x1) * cross
            cy += (y0 + y1) * cross
        a *= 0.5
        if abs(a) < 1e-12:
            continue
        cx /= (6 * a)
        cy /= (6 * a)
        total_a += a
        cx_sum += a * cx
        cy_sum += a * cy

    if abs(total_a) > 1e-9:
        return cx_sum / total_a, cy_sum / total_a
    if not all_pts:
        return None
    xs = [p[0] for p in all_pts]
    ys = [p[1] for p in all_pts]
    return (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2


def detect_origin(piece_vertices, grid=0.01):
    """Find the impact point: the spot where the most shards share a vertex.
    piece_vertices: list (per piece) of lists of normalized (x, y).
    Returns ((x, y), number_of_pieces_touching_it)."""
    counts = {}
    for pts in piece_vertices:
        cells = set()
        for x, y in pts:
            cx, cy = round(x / grid), round(y / grid)
            for ddx in (-1, 0, 1):          # dilate so near-identical vertices still meet
                for ddy in (-1, 0, 1):
                    cells.add((cx + ddx, cy + ddy))
        for c in cells:
            counts[c] = counts.get(c, 0) + 1
    if not counts:
        return None, 0
    best_cell, best_count = max(counts.items(), key=lambda kv: kv[1])
    bx, by = best_cell[0] * grid, best_cell[1] * grid
    near = [(x, y) for pts in piece_vertices for x, y in pts
            if math.hypot(x - bx, y - by) < grid * 2.5]
    if near:
        bx = sum(p[0] for p in near) / len(near)
        by = sum(p[1] for p in near) / len(near)
    return (bx, by), best_count


# -------------------------------------------------------------- svg reading
def strip_ns(tag):
    return tag.split('}', 1)[-1]


def num(s, default=0.0):
    if s is None:
        return default
    m = re.match(r'\s*([-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?)', s)
    return float(m.group(1)) if m else default


def read_svg(path):
    """Returns (viewbox(x0,y0,w,h), subpaths)."""
    root = ET.parse(path).getroot()

    vb = root.get('viewBox')
    if vb:
        x0, y0, w, h = [float(v) for v in re.split(r'[\s,]+', vb.strip())]
    else:
        x0 = y0 = 0.0
        w, h = num(root.get('width'), 1.0), num(root.get('height'), 1.0)

    subpaths = []
    warned = False
    for el in root.iter():
        tag = strip_ns(el.tag)
        if el.get('transform') and not warned:
            print(f"  warning: {os.path.basename(path)} uses a transform attribute "
                  f"(ignored, centroid may be off)")
            warned = True

        if tag == 'path' and el.get('d'):
            subpaths += parse_path(el.get('d'))
        elif tag in ('polygon', 'polyline') and el.get('points'):
            v = [float(t) for t in TOKEN.findall(el.get('points'))]
            subpaths.append(list(zip(v[0::2], v[1::2])))
        elif tag == 'rect':
            rx, ry = num(el.get('x')), num(el.get('y'))
            rw, rh = num(el.get('width')), num(el.get('height'))
            subpaths.append([(rx, ry), (rx + rw, ry), (rx + rw, ry + rh), (rx, ry + rh)])
        elif tag in ('circle', 'ellipse'):
            cx, cy = num(el.get('cx')), num(el.get('cy'))
            rx = num(el.get('r')) if tag == 'circle' else num(el.get('rx'))
            ry = rx if tag == 'circle' else num(el.get('ry'))
            subpaths.append([(cx + rx * math.cos(t * math.pi / 12),
                              cy + ry * math.sin(t * math.pi / 12)) for t in range(24)])

    return (x0, y0, w, h), subpaths


def piece_number(path):
    m = re.search(r'(\d+)', os.path.basename(path))
    return int(m.group(1)) if m else 0


# --------------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser(description="Bake shatter trajectories from pieceN.svg files")
    ap.add_argument('--pattern', default='piece*.svg', help='glob for the svg files')
    ap.add_argument('--origin', default='auto',
                    help="impact point: 'auto' (detect where cracks meet), 'center', or 'x,y' normalized 0..1")
    ap.add_argument('--spread', type=float, default=700, help='max fly distance in px')
    ap.add_argument('--depth', type=float, default=120,
                    help='max px a shard moves toward the camera (needs perspective on the container)')
    ap.add_argument('--tilt', type=float, default=70, help='max tumble angle around the flight axis (deg)')
    ap.add_argument('--tilt-min', type=float, default=25, help='min tumble angle (deg)')
    ap.add_argument('--ybias', type=float, default=1.0,
                    help='vertical spread multiplier: 1 = all directions equally, 0.3 = mostly sideways')
    ap.add_argument('--delay', type=float, default=0.08, help='seconds of delay per unit of distance from origin')
    ap.add_argument('--jitter', type=float, default=0.3, help='random variation of fly distance (0..1)')
    ap.add_argument('--seed', type=int, default=1, help='random seed (same seed = same result)')
    ap.add_argument('--out', default='shatter_baked', help='output file prefix')
    args = ap.parse_args()

    files = sorted(glob.glob(args.pattern), key=piece_number)
    if not files:
        sys.exit(f"No files matching '{args.pattern}' in {os.getcwd()}")

    rng = random.Random(args.seed)
    pieces = []
    all_vertices = []

    print(f"Found {len(files)} svgs")
    for f in files:
        vbox, subs = read_svg(f)
        c = shape_centroid(subs)
        n = piece_number(f)
        verts = [((x - vbox[0]) / vbox[2], (y - vbox[1]) / vbox[3]) for sp in subs for x, y in sp]
        all_vertices.append(verts)
        if c is None:
            print(f"  warning: no geometry in {f}, using random position")
            nx, ny = rng.random(), rng.random()
        else:
            nx = (c[0] - vbox[0]) / vbox[2]
            ny = (c[1] - vbox[1]) / vbox[3]
        pieces.append({'id': n, 'cx': nx, 'cy': ny})

    # impact point
    if args.origin == 'center':
        ox, oy = 0.5, 0.5
        print("Origin: center (0.5, 0.5)")
    elif args.origin == 'auto':
        found, count = detect_origin(all_vertices)
        if found is None or count < 3:
            ox, oy = 0.5, 0.5
            print("Origin: could not detect an impact point, using center (0.5, 0.5)")
        else:
            ox, oy = found
            print(f"Origin: detected at ({ox:.3f}, {oy:.3f}), shared by {count} shards")
            print("        (if that looks wrong, pass --origin x,y)")
    else:
        ox, oy = [float(v) for v in args.origin.split(',')]
        print(f"Origin: manual ({ox:.3f}, {oy:.3f})")

    baked = []
    for p in pieces:
        vx, vy = p['cx'] - ox, p['cy'] - oy
        dist = math.hypot(vx, vy)
        if dist < 1e-4:  # shard sitting on the impact point: random direction
            ang = rng.random() * math.tau
            vx, vy, dist = math.cos(ang), math.sin(ang), 0.01
        else:
            vx, vy = vx / dist, vy / dist

        power = (0.4 + dist * 1.6) * args.spread
        power *= (1 - args.jitter / 2) + rng.random() * args.jitter
        dx = vx * power
        dy = vy * power * args.ybias
        dz = rng.random() * args.depth

        # axis of flight in screen space (y points down, same as CSS rotateZ)
        axis = math.degrees(math.atan2(dy, dx))
        tilt = rng.choice((-1, 1)) * (args.tilt_min + rng.random() * max(0.0, args.tilt - args.tilt_min))

        baked.append({
            'id': p['id'],
            'cx': round(p['cx'], 4),
            'cy': round(p['cy'], 4),
            'dx': round(dx, 1),
            'dy': round(dy, 1),
            'dz': round(dz, 1),
            'axis': round(axis, 2),
            'tilt': round(tilt, 1),
            'delay': round(dist * args.delay, 3),
        })

    # json
    with open(args.out + '.json', 'w') as fh:
        json.dump({'origin': [round(ox, 4), round(oy, 4)], 'pieces': baked}, fh, indent=2)

    # js
    with open(args.out + '.js', 'w') as fh:
        fh.write('// generated by bake_shatter.py - do not edit by hand\n')
        fh.write('const SHATTER_DATA = [\n')
        for b in baked:
            fh.write(f"    {{id:{b['id']}, dx:{b['dx']}, dy:{b['dy']}, dz:{b['dz']}, "
                     f"axis:{b['axis']}, tilt:{b['tilt']}, delay:{b['delay']}}},\n")
        fh.write('];\n')

    # css
    # Both states use the same transform function list, rotateZ(a) rotateX(t) rotateZ(-a),
    # and the base state already contains the per-piece axis angle. That way only
    # translate3d and rotateX are animated, and the tumble stays exactly around the flight axis.
    with open(args.out + '.css', 'w') as fh:
        fh.write('/* generated by bake_shatter.py - do not edit by hand */\n')
        for b in baked:
            a = b['axis']
            fh.write(
                f".ShatterPiece.piece{b['id']} {{\n"
                f"    transform: translate3d(0px, 0px, 0px) rotateZ({a}deg) rotateX(0deg) rotateZ({-a}deg);\n"
                f"}}\n"
                f".ShatterPiece.Shattered.piece{b['id']} {{\n"
                f"    transform: translate3d({b['dx']}px, {b['dy']}px, {b['dz']}px) "
                f"rotateZ({a}deg) rotateX({b['tilt']}deg) rotateZ({-a}deg);\n"
                f"    opacity: 0;\n"
                f"    transition-delay: {b['delay']}s;\n"
                f"}}\n"
            )

    print(f"Baked {len(baked)} pieces -> {args.out}.json / .js / .css")


if __name__ == '__main__':
    main()