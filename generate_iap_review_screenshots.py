#!/usr/bin/env python3
"""
Generate high-resolution (1242x2208) review screenshots for all 16 In-App Purchases in MemoLingo.
Designed specifically to meet Apple App Store Review requirements:
- Exact representation of the purchase UI
- Clear product name, price in Pounds Sterling (£0.99 or £4.99)
- Family Sharing badge
- Real sample words and photos from MemoLingo
- Flattened RGB PNG without alpha channel
"""

import csv
import os
from PIL import Image, ImageDraw, ImageFont

W, H = 1242, 2208
OUTPUT_DIR = "iap_review_screenshots"
os.makedirs(OUTPUT_DIR, exist_ok=True)

FONT_DELIUS = "assets/fonts/DeliusUnicase-Bold.ttf"
FONT_CAVIAR = "assets/fonts/CaviarDreams.ttf"

# Category metadata mapping
CATEGORY_META = {
    "memolingo_category_in_the_home": {
        "name": "In The Home",
        "csv_key": "in the home",
        "price": "£0.99",
        "color": (15, 118, 110),       # Teal
        "bg_color": (204, 251, 241),
        "icon_file": "assets/icons/CategoryInHome@2x.png",
    },
    "memolingo_category_food": {
        "name": "Food",
        "csv_key": "food",
        "price": "£0.99",
        "color": (194, 65, 12),        # Orange
        "bg_color": (255, 237, 213),
        "icon_file": "assets/icons/CategoryFood@2x.png",
    },
    "memolingo_category_personal_belongings": {
        "name": "Personal Belongings",
        "csv_key": "personal belongings",
        "price": "£0.99",
        "color": (180, 83, 9),         # Amber
        "bg_color": (254, 243, 199),
        "icon_file": "assets/icons/CategoryPersonal@2x.png",
    },
    "memolingo_category_verbs": {
        "name": "Verbs",
        "csv_key": "verbs",
        "price": "£0.99",
        "color": (194, 65, 12),        # Deep Orange
        "bg_color": (255, 237, 213),
        "icon_file": "assets/icons/CategoryVerbs@2x.png",
    },
    "memolingo_category_describing_things": {
        "name": "Describing Things",
        "csv_key": "describing things",
        "price": "£0.99",
        "color": (126, 34, 206),       # Purple
        "bg_color": (243, 232, 255),
        "icon_file": "assets/icons/CategoryAdj@2x.png",
    },
    "memolingo_category_places": {
        "name": "Places",
        "csv_key": "places",
        "price": "£0.99",
        "color": (67, 56, 202),        # Indigo
        "bg_color": (224, 231, 255),
        "icon_file": "assets/icons/CategoryPlaces@2x.png",
    },
    "memolingo_category_people": {
        "name": "People",
        "csv_key": "people",
        "price": "£0.99",
        "color": (29, 78, 216),        # Blue
        "bg_color": (219, 234, 254),
        "icon_file": "assets/icons/CategoryPeople@2x.png",
    },
    "memolingo_category_sports": {
        "name": "Sports",
        "csv_key": "sports",
        "price": "£0.99",
        "color": (185, 28, 28),        # Red
        "bg_color": (254, 226, 226),
        "icon_file": "assets/icons/CategorySports@2x.png",
    },
    "memolingo_category_transport": {
        "name": "Transport",
        "csv_key": "transport",
        "price": "£0.99",
        "color": (51, 65, 85),         # Slate
        "bg_color": (241, 245, 249),
        "icon_file": "assets/icons/CategoryTransport@2x.png",
    },
    "memolingo_category_nature_environment": {
        "name": "Nature & Environment",
        "csv_key": "Nature & Environment",
        "price": "£0.99",
        "color": (21, 128, 61),        # Green
        "bg_color": (220, 252, 231),
        "icon_file": "assets/memolingo/images/sun.jpg",
    },
    "memolingo_category_professions": {
        "name": "Professions",
        "csv_key": "Professions",
        "price": "£0.99",
        "color": (71, 85, 105),        # Blue Grey
        "bg_color": (241, 245, 249),
        "icon_file": "assets/memolingo/images/doctor.jpg",
    },
    "memolingo_category_clothing_accessories": {
        "name": "Clothing & Accessories",
        "csv_key": "Clothing & Accessories",
        "price": "£0.99",
        "color": (190, 24, 93),        # Pink
        "bg_color": (252, 231, 243),
        "icon_file": "assets/memolingo/images/shirt.jpg",
    },
    "memolingo_category_technology_electronics": {
        "name": "Technology & Electronics",
        "csv_key": "Technology & Electronics",
        "price": "£0.99",
        "color": (14, 116, 144),       # Cyan
        "bg_color": (207, 250, 254),
        "icon_file": "assets/memolingo/images/tablet.jpg",
    },
    "memolingo_category_musical_instruments": {
        "name": "Musical Instruments",
        "csv_key": "Musical Instruments",
        "price": "£0.99",
        "color": (109, 40, 217),       # Deep Purple
        "bg_color": (237, 233, 254),
        "icon_file": "assets/memolingo/images/piano.jpg",
    },
    "memolingo_category_health_medicine": {
        "name": "Health & Medicine",
        "csv_key": "Health & Medicine",
        "price": "£0.99",
        "color": (225, 29, 72),        # Rose
        "bg_color": (255, 228, 230),
        "icon_file": "assets/memolingo/images/wheelchair.jpg",
    },
}


def load_words_by_category():
    data = {}
    with open("assets/memolingo/data/words_list_full.csv", "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        next(reader)
        for r in reader:
            if len(r) >= 14:
                cat = r[0].strip()
                data.setdefault(cat, []).append({
                    "en": r[4].strip(),
                    "es": r[9].strip(),
                    "img": r[3].strip(),
                })
    return data


def draw_status_bar(draw: ImageDraw.Draw, font_time: ImageFont.FreeTypeFont):
    # Time
    draw.text((60, 36), "9:41", fill=(255, 255, 255), font=font_time)
    # Signal bars
    for i in range(4):
        x = W - 200 + i * 10
        h = 10 + i * 6
        draw.rectangle([x, 58 - h, x + 6, 58], fill=(255, 255, 255))
    # Battery outline
    bx = W - 110
    draw.rounded_rectangle([bx, 40, bx + 55, 62], radius=4, outline=(255, 255, 255), width=3)
    draw.rectangle([bx + 5, 45, bx + 42, 57], fill=(255, 255, 255))
    draw.rectangle([bx + 56, 47, bx + 59, 55], fill=(255, 255, 255))


def draw_app_bar(img: Image.Image, draw: ImageDraw.Draw, fonts: dict):
    draw.rectangle([0, 0, W, 220], fill=(93, 109, 189))
    draw_status_bar(draw, fonts["time"])

    # Back arrow
    draw.text((45, 110), "<", fill=(255, 255, 255), font=fonts["arrow"])
    # App title
    draw.text((95, 118), "MemoLingo", fill=(255, 255, 255), font=fonts["app_title"])
    draw.text((95, 175), "Vocabulary Library - UK Store", fill=(215, 222, 255), font=fonts["sub"])

    # Language badge on right
    badge_x = W - 260
    draw.rounded_rectangle([badge_x, 125, W - 45, 185], radius=30, fill=(255, 255, 255))
    draw.text((badge_x + 25, 142), "EN -> ES", fill=(30, 41, 59), font=fonts["badge_small"])


def draw_tab_bar(img: Image.Image, draw: ImageDraw.Draw, fonts: dict):
    bar_y = H - 150
    draw.rectangle([0, bar_y, W, H], fill=(255, 255, 255))
    draw.line([0, bar_y, W, bar_y], fill=(226, 232, 240), width=2)

    tabs = [
        ("Practice", False, W * 0.16),
        ("Library", True, W * 0.50),
        ("Progress", False, W * 0.84),
    ]

    for title, active, cx in tabs:
        color = (93, 109, 189) if active else (148, 163, 184)
        dot_y = bar_y + 40
        draw.ellipse([cx - 8, dot_y, cx + 8, dot_y + 16], fill=color)
        draw.text((cx - 40, bar_y + 65), title, fill=color, font=fonts["sub"])

    # Home indicator
    draw.rounded_rectangle([W // 2 - 140, H - 25, W // 2 + 140, H - 15], radius=5, fill=(15, 23, 42))


def paste_icon(canvas: Image.Image, file_path: str, box: list, radius: int = 16):
    """Safely load and paste an icon or word image into the specified box."""
    if not os.path.exists(file_path):
        return
    try:
        with Image.open(file_path) as raw_img:
            w = box[2] - box[0]
            h = box[3] - box[1]
            resized = raw_img.convert("RGBA").resize((w, h), Image.Resampling.LANCZOS)
            # Create rounded mask
            mask = Image.new("L", (w, h), 0)
            mask_draw = ImageDraw.Draw(mask)
            mask_draw.rounded_rectangle([0, 0, w, h], radius=radius, fill=255)
            canvas.paste(resized, (box[0], box[1]), mask)
    except Exception as e:
        pass


def generate_category_screenshot(prod_id: str, meta: dict, words: list, fonts: dict) -> str:
    img = Image.new("RGB", (W, H), color=(243, 244, 248))
    draw = ImageDraw.Draw(img)

    # 1. Top App Bar
    draw_app_bar(img, draw, fonts)

    # 2. Compact Bundle Banner (top)
    bundle_y1, bundle_y2 = 250, 370
    draw.rounded_rectangle([45, bundle_y1, W - 45, bundle_y2], radius=20, fill=(245, 243, 255), outline=(196, 181, 253), width=2)
    draw.text((75, 275), "* Unlock All 15 Categories Bundle", fill=(109, 40, 217), font=fonts["h3"])
    draw.text((75, 320), "Get 750+ words across all packs for only 4.99 (Family Sharing)", fill=(100, 116, 139), font=fonts["body_small"])
    # Button on right
    draw.rounded_rectangle([W - 320, 280, W - 75, 340], radius=16, fill=(124, 58, 237))
    draw.text((W - 295, 296), "Buy All - 4.99", fill=(255, 255, 255), font=fonts["btn_small"])

    # 3. Hero Category Card (Target In-App Purchase)
    card_y1 = 405
    card_y2 = 1440
    # Shadow
    draw.rounded_rectangle([47, card_y1 + 4, W - 43, card_y2 + 4], radius=28, fill=(226, 232, 240))
    # Card Background
    draw.rounded_rectangle([45, card_y1, W - 45, card_y2], radius=28, fill=(255, 255, 255), outline=meta["color"], width=4)

    # In-App Purchase Badge
    draw.rounded_rectangle([W - 460, card_y1 + 30, W - 75, card_y1 + 80], radius=14, fill=meta["bg_color"])
    draw.text((W - 440, card_y1 + 44), "IN-APP PURCHASE - UNLOCK", fill=meta["color"], font=fonts["badge_small"])

    # Category Icon Box
    icon_box = [75, card_y1 + 35, 175, card_y1 + 135]
    draw.rounded_rectangle(icon_box, radius=20, fill=meta["bg_color"])
    paste_icon(img, meta["icon_file"], [icon_box[0] + 8, icon_box[1] + 8, icon_box[2] - 8, icon_box[3] - 8], radius=14)

    # Category Name & Details
    draw.text((195, card_y1 + 40), meta["name"], fill=(15, 23, 42), font=fonts["h1"])
    draw.text((195, card_y1 + 95), "50 Essential Words - Audio - Quizzes", fill=(71, 85, 105), font=fonts["body"])

    # Family Sharing tag
    draw.rounded_rectangle([195, card_y1 + 135, 480, card_y1 + 175], radius=10, fill=(236, 253, 245))
    draw.text((210, card_y1 + 144), "Family Sharing Enabled", fill=(5, 150, 105), font=fonts["tag"])

    # Divider
    draw.line([75, card_y1 + 200, W - 75, card_y1 + 200], fill=(241, 245, 249), width=2)

    # Word Preview Section
    draw.text((75, card_y1 + 225), "Sample Words in this Pack:", fill=(51, 65, 85), font=fonts["h3"])

    # Draw 4 photo cards (2x2 grid)
    sample_words = words[:4] if len(words) >= 4 else words
    grid_y_start = card_y1 + 280
    card_w = (W - 90 - 60 - 40) // 2
    card_h = 240

    for idx, w_info in enumerate(sample_words):
        col = idx % 2
        row = idx // 2
        gx = 75 + col * (card_w + 40)
        gy = grid_y_start + row * (card_h + 25)

        # Word card bg
        draw.rounded_rectangle([gx, gy, gx + card_w, gy + card_h], radius=16, fill=(248, 250, 252), outline=(226, 232, 240), width=2)

        # Load and paste photo
        img_file = os.path.join("assets/memolingo/images", w_info["img"])
        paste_icon(img, img_file, [gx + 20, gy + 25, gx + 210, gy + 215], radius=12)

        # Text on right side of word card
        tx = gx + 230
        draw.text((tx, gy + 55), w_info["en"].capitalize(), fill=(15, 23, 42), font=fonts["h3"])
        draw.text((tx, gy + 105), w_info["es"], fill=(93, 109, 189), font=fonts["body_bold"])
        draw.text((tx, gy + 150), "Native audio", fill=(148, 163, 184), font=fonts["tag"])

    # Bottom purchase action row of the hero card
    bot_y = card_y1 + 840
    draw.line([75, bot_y, W - 75, bot_y], fill=(241, 245, 249), width=2)

    # Price
    draw.text((75, bot_y + 25), "One-Time Purchase", fill=(100, 116, 139), font=fonts["body_small"])
    draw.text((75, bot_y + 55), meta["price"], fill=(15, 23, 42), font=fonts["price_large"])
    draw.text((250, bot_y + 85), "GBP (incl. VAT)", fill=(148, 163, 184), font=fonts["tag"])

    # Buy Button on right
    btn_w = 460
    btn_h = 85
    bx = W - 75 - btn_w
    by = bot_y + 40
    draw.rounded_rectangle([bx, by, bx + btn_w, by + btn_h], radius=20, fill=(37, 99, 235))
    btn_label = f"Purchase Pack - {meta['price']}"
    draw.text((bx + 35, by + 25), btn_label, fill=(255, 255, 255), font=fonts["btn_text"])

    # 4. Adjacent Category List (Context below)
    list_y = card_y2 + 35
    draw.text((55, list_y), "Other Categories in Library", fill=(100, 116, 139), font=fonts["h3"])

    # Item 1: Free starter pack
    item1_y = list_y + 55
    draw.rounded_rectangle([45, item1_y, W - 45, item1_y + 130], radius=20, fill=(255, 255, 255), outline=(226, 232, 240), width=2)
    draw.rounded_rectangle([70, item1_y + 20, 155, item1_y + 105], radius=16, fill=(254, 243, 199))
    paste_icon(img, "assets/icons/CategoryAnimals@2x.png", [75, item1_y + 25, 150, item1_y + 100], radius=12)
    draw.text((180, item1_y + 30), "Animals", fill=(15, 23, 42), font=fonts["h2"])
    draw.text((180, item1_y + 80), "50 words - Free Starter Pack", fill=(100, 116, 139), font=fonts["body_small"])
    draw.rounded_rectangle([W - 270, item1_y + 35, W - 75, item1_y + 93], radius=16, fill=(240, 253, 244))
    draw.text((W - 240, item1_y + 51), "Unlocked", fill=(22, 101, 52), font=fonts["btn_small"])

    # Item 2: Another category
    item2_y = item1_y + 150
    draw.rounded_rectangle([45, item2_y, W - 45, item2_y + 130], radius=20, fill=(255, 255, 255), outline=(226, 232, 240), width=2)
    draw.rounded_rectangle([70, item2_y + 20, 155, item2_y + 105], radius=16, fill=(224, 231, 255))
    paste_icon(img, "assets/icons/CategoryObjects@2x.png", [75, item2_y + 25, 150, item2_y + 100], radius=12)
    draw.text((180, item2_y + 30), "Everyday Objects", fill=(15, 23, 42), font=fonts["h2"])
    draw.text((180, item2_y + 80), "50 words - Free Starter Pack", fill=(100, 116, 139), font=fonts["body_small"])
    draw.rounded_rectangle([W - 270, item2_y + 35, W - 75, item2_y + 93], radius=16, fill=(240, 253, 244))
    draw.text((W - 240, item2_y + 51), "Unlocked", fill=(22, 101, 52), font=fonts["btn_small"])

    # 5. Bottom Tab Bar
    draw_tab_bar(img, draw, fonts)

    out_path = os.path.join(OUTPUT_DIR, f"{prod_id}.png")
    img.save(out_path, "PNG")
    return out_path


def generate_bundle_screenshot(fonts: dict) -> str:
    img = Image.new("RGB", (W, H), color=(243, 244, 248))
    draw = ImageDraw.Draw(img)

    # 1. Top App Bar
    draw_app_bar(img, draw, fonts)

    # 2. Hero Bundle Card
    card_y1 = 250
    card_y2 = 1880
    # Shadow
    draw.rounded_rectangle([47, card_y1 + 4, W - 43, card_y2 + 4], radius=28, fill=(226, 232, 240))
    # Card
    draw.rounded_rectangle([45, card_y1, W - 45, card_y2], radius=28, fill=(255, 255, 255), outline=(124, 58, 237), width=4)

    # Top header banner
    draw.rounded_rectangle([47, card_y1 + 2, W - 47, card_y1 + 180], radius=26, fill=(124, 58, 237))
    draw.rounded_rectangle([47, card_y1 + 120, W - 47, card_y1 + 180], radius=0, fill=(124, 58, 237))

    draw.rounded_rectangle([W - 460, card_y1 + 25, W - 75, card_y1 + 75], radius=14, fill=(255, 255, 255))
    draw.text((W - 435, card_y1 + 38), "COMPLETE COLLECTION", fill=(109, 40, 217), font=fonts["badge_small"])

    draw.text((80, card_y1 + 40), "MemoLingo", fill=(255, 255, 255), font=fonts["h1"])
    draw.text((80, card_y1 + 105), "All Categories Bundle - 15 Packs", fill=(237, 233, 254), font=fonts["h3"])

    # Features list
    feat_y = card_y1 + 220
    draw.text((80, feat_y), "Everything included in this purchase:", fill=(15, 23, 42), font=fonts["h2"])

    features = [
        "- Instant access to all 15 vocabulary packs (750+ words)",
        "- Full native speaker audio pronunciations",
        "- Memory flashcards, interactive games and mastery tracking",
        "- Family Sharing enabled (share with up to 5 family members)",
        "- Lifetime access - Pay once, keep forever (No subscription)",
        "- All future category expansions and updates included",
    ]
    for i, feat in enumerate(features):
        fy = feat_y + 60 + i * 50
        draw.text((95, fy), feat, fill=(51, 65, 85), font=fonts["body_bold"])

    # Grid of included categories
    grid_title_y = feat_y + 390
    draw.line([75, grid_title_y - 20, W - 75, grid_title_y - 20], fill=(241, 245, 249), width=2)
    draw.text((80, grid_title_y), "15 Included Category Packs:", fill=(15, 23, 42), font=fonts["h3"])

    cat_names = [
        "In The Home", "Food", "Personal Belongings",
        "Verbs", "Describing Things", "Places",
        "People", "Sports", "Transport",
        "Nature & Env", "Professions", "Clothing & Acc",
        "Technology", "Musical Inst", "Health & Med",
    ]

    grid_y = grid_title_y + 55
    col_w = (W - 150) // 3
    for idx, cname in enumerate(cat_names):
        col = idx % 3
        row = idx // 3
        cx = 75 + col * col_w
        cy = grid_y + row * 65
        draw.rounded_rectangle([cx, cy, cx + col_w - 20, cy + 50], radius=12, fill=(245, 243, 255))
        draw.text((cx + 15, cy + 12), f"- {cname}", fill=(79, 70, 229), font=fonts["tag"])

    # Price & Purchase Bar inside Hero card
    price_y = card_y1 + 1180
    draw.line([75, price_y, W - 75, price_y], fill=(241, 245, 249), width=3)

    # Savings badge
    draw.rounded_rectangle([80, price_y + 30, 360, price_y + 70], radius=10, fill=(254, 242, 242))
    draw.text((95, price_y + 40), "SAVE 66% VS SINGLE PACKS", fill=(220, 38, 38), font=fonts["tag"])

    # Price
    draw.text((80, price_y + 85), "4.99", fill=(15, 23, 42), font=fonts["price_large"])
    draw.text((280, price_y + 115), "GBP (one-time payment)", fill=(100, 116, 139), font=fonts["body_small"])

    # Big CTA Button
    btn_y = price_y + 200
    draw.rounded_rectangle([80, btn_y, W - 80, btn_y + 110], radius=24, fill=(124, 58, 237))
    draw.text((W // 2 - 240, btn_y + 34), "Buy Complete Bundle - 4.99", fill=(255, 255, 255), font=fonts["btn_text"])

    # Security / Family note
    draw.text((W // 2 - 210, btn_y + 135), "Secure Apple In-App Purchase - Family Sharing Included", fill=(100, 116, 139), font=fonts["tag"])

    # 3. Bottom Tab Bar
    draw_tab_bar(img, draw, fonts)

    out_path = os.path.join(OUTPUT_DIR, "memolingo_all_categories.png")
    img.save(out_path, "PNG")
    return out_path


def main():
    print("Loading fonts...")
    fonts = {
        "time": ImageFont.truetype(FONT_DELIUS, 30),
        "arrow": ImageFont.truetype(FONT_DELIUS, 55),
        "app_title": ImageFont.truetype(FONT_DELIUS, 44),
        "h1": ImageFont.truetype(FONT_DELIUS, 44),
        "h2": ImageFont.truetype(FONT_DELIUS, 36),
        "h3": ImageFont.truetype(FONT_DELIUS, 30),
        "sub": ImageFont.truetype(FONT_CAVIAR, 24),
        "body": ImageFont.truetype(FONT_CAVIAR, 28),
        "body_bold": ImageFont.truetype(FONT_DELIUS, 24),
        "body_small": ImageFont.truetype(FONT_CAVIAR, 22),
        "tag": ImageFont.truetype(FONT_CAVIAR, 22),
        "badge_small": ImageFont.truetype(FONT_DELIUS, 20),
        "btn_small": ImageFont.truetype(FONT_DELIUS, 20),
        "btn_text": ImageFont.truetype(FONT_DELIUS, 28),
        "price_large": ImageFont.truetype(FONT_DELIUS, 64),
    }

    words_by_cat = load_words_by_category()

    print("Generating screenshot for Bundle: memolingo_all_categories...")
    p = generate_bundle_screenshot(fonts)
    print(f"Saved: {p} ({os.path.getsize(p)} bytes)")

    for prod_id, meta in CATEGORY_META.items():
        print(f"Generating screenshot for {meta['name']} ({prod_id})...")
        words = words_by_cat.get(meta["csv_key"], [])
        p = generate_category_screenshot(prod_id, meta, words, fonts)
        print(f"Saved: {p} ({os.path.getsize(p)} bytes)")

    print(f"\nAll 16 review screenshots successfully updated in '{OUTPUT_DIR}/'!")


if __name__ == "__main__":
    main()
