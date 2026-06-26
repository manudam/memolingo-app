#!/usr/bin/env python3
"""
Google Play Store Marketing Screenshot Generator
Generates professional screenshots with bottom overlays for phones & tablets.
Device size targets follow Play Store requirements (portrait phone & tablet).
Source screenshots should be raw captures from Android emulator or physical device.
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, glob, sys

# Target output dimensions (Google Play requirements allow various sizes; we standardize)
DEVICE_PROFILES = {
    'phone_portrait': {'width': 1080, 'height': 1920, 'orientation': 'portrait',
                       'name': 'Phone 1080x1920'},
    'phone_landscape': {'width': 1920, 'height': 1080, 'orientation': 'landscape',
                        'name': 'Phone 1920x1080'},
    'tablet_portrait': {'width': 1200, 'height': 1920, 'orientation': 'portrait',
                        'name': 'Tablet 1200x1920'},
    'tablet_landscape': {'width': 1920, 'height': 1200, 'orientation': 'landscape',
                         'name': 'Tablet 1920x1200'}
}

WHITE = (255, 255, 255);
DARK = (18, 24, 32);
PRIMARY = (37, 99, 235);
ACCENT = (59, 130, 246)

SCREENSHOT_CONFIGS = [
    {"title": "Master 450+ Words", "subtitle": "Essential 11+ Exam Vocabulary", "badge": "5 Sets",
     "description": "library"},
    {"title": "Interactive Practice", "subtitle": "Audio Pronunciation", "badge": "TTS",
     "description": "practice"},
    {"title": "Track Your Progress", "subtitle": "Real-Time Mastery Stats", "badge": "Stats",
     "description": "results"},
    {"title": "Learn from Mistakes", "subtitle": "Detailed Review System", "badge": "Review",
     "description": "review"},
    {"title": "Achievement Dashboard", "subtitle": "Monitor Your Journey", "badge": "Achievements",
     "description": "stats"},
]

FONT_CANDIDATES = [
    "/System/Library/Fonts/SFNS.ttf",
    "/System/Library/Fonts/SFCompact.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/Library/Fonts/Arial.ttf"
]


def load_font(size):
    for p in FONT_CANDIDATES:
        try:
            return ImageFont.truetype(p, size)
        except:
            continue
    return ImageFont.load_default()


def gradient_overlay(w, h, alpha=210):
    img = Image.new('RGBA', (w, h))
    d = ImageDraw.Draw(img)
    for i in range(h):
        a = int(alpha * (i / h * 0.4 + 0.6))
        d.line([(0, i), (w, i)], fill=(DARK[0], DARK[1], DARK[2], a))
    return img


def process(input_dir, output_dir, profile_key):
    profile = DEVICE_PROFILES[profile_key]
    w = profile['width'];
    h = profile['height'];
    orient = profile['orientation']
    os.makedirs(output_dir, exist_ok=True)
    patterns = ['*.png', '*.jpg', '*.jpeg']
    files = []
    for pat in patterns: files.extend(glob.glob(os.path.join(input_dir, pat)))
    files = [f for f in files if 'screenshot' in f.lower() or 'Screenshot' in f]
    files = sorted(files)
    if not files:
        print('No screenshots found. Capture emulator/device screens first.')
        return 1
    print(
        f"Found {len(files)} raw screenshot(s). Using first {len(SCREENSHOT_CONFIGS)} for marketing overlays.")
    for idx, raw in enumerate(files):
        if idx >= len(SCREENSHOT_CONFIGS): break
        cfg = SCREENSHOT_CONFIGS[idx]
        img = Image.open(raw)
        if img.size != (w, h):
            img = img.resize((w, h), Image.Resampling.LANCZOS)
        if img.mode != 'RGBA': img = img.convert('RGBA')
        overlay_h = int(h * 0.33 if orient == 'portrait' else h * 0.30)
        y = h - overlay_h
        grad = gradient_overlay(w, overlay_h)
        img.paste(grad, (0, y), grad)
        # Fonts
        title_font = load_font(int(w * 0.06))
        subtitle_font = load_font(int(w * 0.038))
        badge_font = load_font(int(w * 0.03))
        d = ImageDraw.Draw(img)
        margin = int(w * 0.05)
        # Badge
        badge = cfg['badge']
        bb = d.textbbox((0, 0), badge, font=badge_font)
        pad = int(w * 0.015);
        bw = bb[2] - bb[0] + pad * 2;
        bh = bb[3] - bb[1] + pad * 2
        d.rounded_rectangle(
            [(margin, y + int(overlay_h * 0.12)), (margin + bw, y + int(overlay_h * 0.12) + bh)],
            radius=pad, fill=PRIMARY + (255,))
        d.text((margin + pad, y + int(overlay_h * 0.12) + pad), badge, font=badge_font, fill=WHITE)
        # Title
        title = cfg['title'];
        ty = y + int(overlay_h * 0.35)
        d.text((margin + 3, ty + 3), title, font=title_font, fill=(0, 0, 0, 160))
        d.text((margin, ty), title, font=title_font, fill=WHITE)
        # Subtitle
        sub = cfg['subtitle'];
        sy = ty + int(overlay_h * 0.28)
        d.text((margin + 2, sy + 2), sub, font=subtitle_font, fill=(0, 0, 0, 140))
        d.text((margin, sy), sub, font=subtitle_font, fill=(230, 230, 230))
        out_name = f"play_{idx + 1}_{cfg['description']}.png"
        img.save(os.path.join(output_dir, out_name), 'PNG', optimize=True)
        print(f"Saved {out_name}")
    print('\nDone. Upload generated PNGs to Google Play Console (Phone + Tablet).')
    return 0


if __name__ == '__main__':
    inp = os.path.expanduser('~/Desktop')
    out = os.path.expanduser('~/Desktop/PlayStore_Screenshots')
    profile = 'phone_portrait'
    if len(sys.argv) > 1: profile = sys.argv[1]
    if len(sys.argv) > 2: inp = sys.argv[2]
    if len(sys.argv) > 3: out = sys.argv[3]
    if profile not in DEVICE_PROFILES:
        print('Invalid profile. Choose one of:', ', '.join(DEVICE_PROFILES.keys()));
        sys.exit(1)
    print(f"Profile: {profile} -> {DEVICE_PROFILES[profile]['name']}")
    print(f"Input: {inp}\nOutput: {out}")
    rc = process(inp, out, profile)
    sys.exit(rc)
