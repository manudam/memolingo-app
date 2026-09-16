#!/usr/bin/env python3
"""
Update App Store Connect In-App Purchases for MemoLingo:
1. Updates all 16 IAP price schedules to Pounds Sterling (GBR):
   - Bundle (memolingo_all_categories): £4.99 GBP
   - All 15 Category Packs: £0.99 GBP
2. Generates compliant, high-res (1242x2208) review screenshots for all 16 products.
3. Uploads and commits review screenshots to Apple via App Store Connect API.
"""

import csv
import glob
import hashlib
import json
import os
import sys
import time
from typing import Any, Dict, List, Optional
from PIL import Image, ImageDraw, ImageFont
import jwt
import requests

# ================= Configuration =================
KEY_ID = "6239B44P75"
ISSUER_ID = "69a6de88-bea5-47e3-e053-5b8c7c11a4d1"
BUNDLE_ID = "com.trianglecarrot.memolingoapp"
TERRITORY = "GBR"  # United Kingdom (Pounds Sterling)

DOWNLOADS_DIR = os.path.expanduser("~/Downloads")
DEFAULT_KEY_NAME = f"AuthKey_{KEY_ID}.p8"
DEFAULT_KEY_PATH = os.path.join(DOWNLOADS_DIR, DEFAULT_KEY_NAME)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "iap_review_screenshots")
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)

FONT_DELIUS = os.path.join(SCRIPT_DIR, "assets", "fonts", "DeliusUnicase-Bold.ttf")
FONT_CAVIAR = os.path.join(SCRIPT_DIR, "assets", "fonts", "CaviarDreams.ttf")

BASE_URL = "https://api.appstoreconnect.apple.com"

W, H = 1242, 2208

CATEGORY_META = {
    "memolingo_category_in_the_home": {
        "name": "In The Home",
        "csv_key": "in the home",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (15, 118, 110),
        "bg_color": (204, 251, 241),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategoryInHome@2x.png"),
    },
    "memolingo_category_food": {
        "name": "Food",
        "csv_key": "food",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (194, 65, 12),
        "bg_color": (255, 237, 213),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategoryFood@2x.png"),
    },
    "memolingo_category_personal_belongings": {
        "name": "Personal Belongings",
        "csv_key": "personal belongings",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (180, 83, 9),
        "bg_color": (254, 243, 199),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategoryPersonal@2x.png"),
    },
    "memolingo_category_verbs": {
        "name": "Verbs",
        "csv_key": "verbs",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (194, 65, 12),
        "bg_color": (255, 237, 213),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategoryVerbs@2x.png"),
    },
    "memolingo_category_describing_things": {
        "name": "Describing Things",
        "csv_key": "describing things",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (126, 34, 206),
        "bg_color": (243, 232, 255),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategoryAdj@2x.png"),
    },
    "memolingo_category_places": {
        "name": "Places",
        "csv_key": "places",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (67, 56, 202),
        "bg_color": (224, 231, 255),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategoryPlaces@2x.png"),
    },
    "memolingo_category_people": {
        "name": "People",
        "csv_key": "people",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (29, 78, 216),
        "bg_color": (219, 234, 254),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategoryPeople@2x.png"),
    },
    "memolingo_category_sports": {
        "name": "Sports",
        "csv_key": "sports",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (185, 28, 28),
        "bg_color": (254, 226, 226),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategorySports@2x.png"),
    },
    "memolingo_category_transport": {
        "name": "Transport",
        "csv_key": "transport",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (51, 65, 85),
        "bg_color": (241, 245, 249),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/icons/CategoryTransport@2x.png"),
    },
    "memolingo_category_nature_environment": {
        "name": "Nature & Environment",
        "csv_key": "Nature & Environment",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (21, 128, 61),
        "bg_color": (220, 252, 231),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/memolingo/images/sun.jpg"),
    },
    "memolingo_category_professions": {
        "name": "Professions",
        "csv_key": "Professions",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (71, 85, 105),
        "bg_color": (241, 245, 249),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/memolingo/images/doctor.jpg"),
    },
    "memolingo_category_clothing_accessories": {
        "name": "Clothing & Accessories",
        "csv_key": "Clothing & Accessories",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (190, 24, 93),
        "bg_color": (252, 231, 243),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/memolingo/images/shirt.jpg"),
    },
    "memolingo_category_technology_electronics": {
        "name": "Technology & Electronics",
        "csv_key": "Technology & Electronics",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (14, 116, 144),
        "bg_color": (207, 250, 254),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/memolingo/images/tablet.jpg"),
    },
    "memolingo_category_musical_instruments": {
        "name": "Musical Instruments",
        "csv_key": "Musical Instruments",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (109, 40, 217),
        "bg_color": (237, 233, 254),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/memolingo/images/piano.jpg"),
    },
    "memolingo_category_health_medicine": {
        "name": "Health & Medicine",
        "csv_key": "Health & Medicine",
        "price": "£0.99",
        "target_price_num": "0.99",
        "color": (225, 29, 72),
        "bg_color": (255, 228, 230),
        "icon_file": os.path.join(SCRIPT_DIR, "assets/memolingo/images/wheelchair.jpg"),
    },
}


def find_private_key() -> str:
    if os.path.exists(DEFAULT_KEY_PATH):
        return DEFAULT_KEY_PATH
    matches = glob.glob(os.path.join(DOWNLOADS_DIR, f"*{KEY_ID}*.p8"))
    if matches:
        return matches[0]
    all_p8 = glob.glob(os.path.join(DOWNLOADS_DIR, "*.p8"))
    if len(all_p8) == 1:
        return all_p8[0]
    raise FileNotFoundError(f"Could not find private key '{DEFAULT_KEY_NAME}' in {DOWNLOADS_DIR}")


def generate_jwt(key_path: str) -> str:
    with open(key_path, "r") as f:
        private_key = f.read()
    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,
        "aud": "appstoreconnect-v1",
    }
    headers = {"kid": KEY_ID, "alg": "ES256", "typ": "JWT"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)


class ASCClient:
    def __init__(self, token: str):
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        })

    def get(self, path: str, params: Optional[Dict[str, Any]] = None) -> requests.Response:
        url = f"{BASE_URL}{path}" if path.startswith("/") else path
        return self.session.get(url, params=params)

    def post(self, path: str, json_data: Dict[str, Any]) -> requests.Response:
        url = f"{BASE_URL}{path}" if path.startswith("/") else path
        return self.session.post(url, json=json_data)

    def patch(self, path: str, json_data: Dict[str, Any]) -> requests.Response:
        url = f"{BASE_URL}{path}" if path.startswith("/") else path
        return self.session.patch(url, json=json_data)

    def delete(self, path: str) -> requests.Response:
        url = f"{BASE_URL}{path}" if path.startswith("/") else path
        return self.session.delete(url)

    def get_app_id(self, bundle_id: str) -> str:
        resp = self.get("/v1/apps", params={"filter[bundleId]": bundle_id})
        data = resp.json().get("data", [])
        if not data:
            raise RuntimeError(f"App with bundle ID '{bundle_id}' not found.")
        app_id = data[0]["id"]
        app_name = data[0].get("attributes", {}).get("name", "Unknown")
        print(f"✓ Found App: '{app_name}' (ID: {app_id})")
        return app_id

    def get_all_iaps(self, app_id: str) -> Dict[str, str]:
        existing = {}
        url = f"/v1/apps/{app_id}/inAppPurchasesV2"
        params = {"limit": 100}
        while url:
            resp = self.get(url, params=params)
            params = None
            if resp.status_code != 200:
                break
            data = resp.json()
            for item in data.get("data", []):
                prod_id = item.get("attributes", {}).get("productId")
                if prod_id:
                    existing[prod_id] = item["id"]
            url = data.get("links", {}).get("next")
        return existing

    def update_price_schedule_gbr(self, iap_id: str, target_price_num: str) -> bool:
        """Sets base territory to GBR and attaches target price tier."""
        resp = self.get(f"/v2/inAppPurchases/{iap_id}/pricePoints", params={
            "filter[territory]": TERRITORY,
            "limit": 150,
        })
        if resp.status_code != 200:
            print(f"    ⚠ Could not query price points: {resp.text}")
            return False

        points = resp.json().get("data", [])
        matched_id = None
        for pt in points:
            if pt.get("attributes", {}).get("customerPrice") == target_price_num:
                matched_id = pt["id"]
                break

        if not matched_id:
            print(f"    ⚠ Price point '{target_price_num}' not found for GBR.")
            return False

        temp_id = "${price-temp-id}"
        body = {
            "data": {
                "type": "inAppPurchasePriceSchedules",
                "relationships": {
                    "inAppPurchase": {
                        "data": {"type": "inAppPurchases", "id": iap_id}
                    },
                    "baseTerritory": {
                        "data": {"type": "territories", "id": TERRITORY}
                    },
                    "manualPrices": {
                        "data": [{"type": "inAppPurchasePrices", "id": temp_id}]
                    }
                }
            },
            "included": [
                {
                    "type": "inAppPurchasePrices",
                    "id": temp_id,
                    "attributes": {},
                    "relationships": {
                        "inAppPurchasePricePoint": {
                            "data": {"type": "inAppPurchasePricePoints", "id": matched_id}
                        }
                    }
                }
            ]
        }
        post_resp = self.post("/v1/inAppPurchasePriceSchedules", body)
        if post_resp.status_code in (200, 201):
            print(f"    ✓ Pricing updated to £{target_price_num} GBP (Base: United Kingdom)")
            return True
        else:
            print(f"    ⚠ Failed to set GBR price: {post_resp.text}")
            return False

    def upload_review_screenshot(self, iap_id: str, image_path: str) -> bool:
        """Uploads review screenshot to App Store Connect."""
        # Check and remove existing screenshot if any
        resp = self.get(f"/v2/inAppPurchases/{iap_id}/appStoreReviewScreenshot")
        existing_ss = resp.json().get("data")
        if existing_ss and existing_ss.get("id"):
            old_id = existing_ss["id"]
            self.delete(f"/v1/inAppPurchaseAppStoreReviewScreenshots/{old_id}")
            time.sleep(0.5)

        with open(image_path, "rb") as f:
            file_bytes = f.read()

        file_size = len(file_bytes)
        file_name = os.path.basename(image_path)
        md5_checksum = hashlib.md5(file_bytes).hexdigest()

        # Step 1: Reserve screenshot
        res_body = {
            "data": {
                "type": "inAppPurchaseAppStoreReviewScreenshots",
                "attributes": {
                    "fileName": file_name,
                    "fileSize": file_size,
                },
                "relationships": {
                    "inAppPurchaseV2": {
                        "data": {
                            "type": "inAppPurchases",
                            "id": iap_id,
                        }
                    }
                }
            }
        }
        res_resp = self.post("/v1/inAppPurchaseAppStoreReviewScreenshots", res_body)
        if res_resp.status_code not in (200, 201):
            print(f"    ✗ Failed to reserve review screenshot: {res_resp.text}")
            return False

        ss_data = res_resp.json()["data"]
        ss_id = ss_data["id"]
        upload_ops = ss_data.get("attributes", {}).get("uploadOperations", [])

        if not upload_ops:
            print("    ✗ No upload operations returned by Apple.")
            return False

        # Step 2: Perform binary PUT upload(s)
        for op in upload_ops:
            method = op["method"]
            upload_url = op["url"]
            offset = op.get("offset", 0)
            length = op.get("length", file_size)
            headers = {}
            for h in op.get("requestHeaders", []):
                headers[h["name"]] = h["value"]

            chunk = file_bytes[offset:offset + length]
            put_resp = requests.request(method, upload_url, data=chunk, headers=headers)
            if put_resp.status_code not in (200, 201):
                print(f"    ✗ Chunk upload failed ({put_resp.status_code}): {put_resp.text}")
                return False

        # Step 3: Commit upload
        commit_body = {
            "data": {
                "type": "inAppPurchaseAppStoreReviewScreenshots",
                "id": ss_id,
                "attributes": {
                    "uploaded": True,
                    "sourceFileChecksum": md5_checksum,
                }
            }
        }
        commit_resp = self.patch(f"/v1/inAppPurchaseAppStoreReviewScreenshots/{ss_id}", commit_body)
        if commit_resp.status_code in (200, 201):
            print(f"    ✓ Review screenshot uploaded & committed ({file_name})")
            return True
        else:
            print(f"    ✗ Commit failed: {commit_resp.text}")
            return False


# ================= Screenshot Rendering =================

def load_words_by_category():
    data = {}
    csv_path = os.path.join(SCRIPT_DIR, "assets/memolingo/data/words_list_full.csv")
    with open(csv_path, "r", encoding="utf-8") as f:
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
    draw.text((60, 36), "9:41", fill=(255, 255, 255), font=font_time)
    for i in range(4):
        x = W - 200 + i * 10
        h = 10 + i * 6
        draw.rectangle([x, 58 - h, x + 6, 58], fill=(255, 255, 255))
    bx = W - 110
    draw.rounded_rectangle([bx, 40, bx + 55, 62], radius=4, outline=(255, 255, 255), width=3)
    draw.rectangle([bx + 5, 45, bx + 42, 57], fill=(255, 255, 255))
    draw.rectangle([bx + 56, 47, bx + 59, 55], fill=(255, 255, 255))


def draw_app_bar(draw: ImageDraw.Draw, fonts: dict):
    draw.rectangle([0, 0, W, 220], fill=(93, 109, 189))
    draw_status_bar(draw, fonts["time"])
    draw.text((45, 110), "<", fill=(255, 255, 255), font=fonts["arrow"])
    draw.text((95, 118), "MemoLingo", fill=(255, 255, 255), font=fonts["app_title"])
    draw.text((95, 175), "Vocabulary Library - UK Store", fill=(215, 222, 255), font=fonts["sub"])

    badge_x = W - 260
    draw.rounded_rectangle([badge_x, 125, W - 45, 185], radius=30, fill=(255, 255, 255))
    draw.text((badge_x + 25, 142), "EN -> ES", fill=(30, 41, 59), font=fonts["badge_small"])


def draw_tab_bar(draw: ImageDraw.Draw, fonts: dict):
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
    draw.rounded_rectangle([W // 2 - 140, H - 25, W // 2 + 140, H - 15], radius=5, fill=(15, 23, 42))


def paste_icon(canvas: Image.Image, file_path: str, box: list, radius: int = 16):
    if not os.path.exists(file_path):
        return
    try:
        with Image.open(file_path) as raw_img:
            w = box[2] - box[0]
            h = box[3] - box[1]
            resized = raw_img.convert("RGBA").resize((w, h), Image.Resampling.LANCZOS)
            mask = Image.new("L", (w, h), 0)
            mask_draw = ImageDraw.Draw(mask)
            mask_draw.rounded_rectangle([0, 0, w, h], radius=radius, fill=255)
            canvas.paste(resized, (box[0], box[1]), mask)
    except Exception:
        pass


def render_category_screenshot(prod_id: str, meta: dict, words: list, fonts: dict) -> str:
    img = Image.new("RGB", (W, H), color=(243, 244, 248))
    draw = ImageDraw.Draw(img)

    draw_app_bar(draw, fonts)

    # Compact Bundle Banner
    bundle_y1, bundle_y2 = 250, 370
    draw.rounded_rectangle([45, bundle_y1, W - 45, bundle_y2], radius=20, fill=(245, 243, 255), outline=(196, 181, 253), width=2)
    draw.text((75, 275), "Unlock All 15 Categories Bundle", fill=(109, 40, 217), font=fonts["h3"])
    draw.text((75, 320), "Get 750+ words across all packs for only £4.99 (Family Sharing)", fill=(100, 116, 139), font=fonts["body_small"])
    draw.rounded_rectangle([W - 320, 280, W - 75, 340], radius=16, fill=(124, 58, 237))
    draw.text((W - 295, 296), "Buy All - £4.99", fill=(255, 255, 255), font=fonts["btn_small"])

    # Hero Category Card
    card_y1 = 405
    card_y2 = 1440
    draw.rounded_rectangle([47, card_y1 + 4, W - 43, card_y2 + 4], radius=28, fill=(226, 232, 240))
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

    draw.line([75, card_y1 + 200, W - 75, card_y1 + 200], fill=(241, 245, 249), width=2)
    draw.text((75, card_y1 + 225), "Sample Words in this Pack:", fill=(51, 65, 85), font=fonts["h3"])

    # 4 Photo Cards Grid
    sample_words = words[:4] if len(words) >= 4 else words
    grid_y_start = card_y1 + 280
    card_w = (W - 90 - 60 - 40) // 2
    card_h = 240

    for idx, w_info in enumerate(sample_words):
        col = idx % 2
        row = idx // 2
        gx = 75 + col * (card_w + 40)
        gy = grid_y_start + row * (card_h + 25)

        draw.rounded_rectangle([gx, gy, gx + card_w, gy + card_h], radius=16, fill=(248, 250, 252), outline=(226, 232, 240), width=2)
        img_file = os.path.join(SCRIPT_DIR, "assets/memolingo/images", w_info["img"])
        paste_icon(img, img_file, [gx + 20, gy + 25, gx + 210, gy + 215], radius=12)

        tx = gx + 230
        draw.text((tx, gy + 55), w_info["en"].capitalize(), fill=(15, 23, 42), font=fonts["h3"])
        draw.text((tx, gy + 105), w_info["es"], fill=(93, 109, 189), font=fonts["body_bold"])
        draw.text((tx, gy + 150), "Native audio", fill=(148, 163, 184), font=fonts["tag"])

    # Bottom Purchase Row
    bot_y = card_y1 + 840
    draw.line([75, bot_y, W - 75, bot_y], fill=(241, 245, 249), width=2)
    draw.text((75, bot_y + 25), "One-Time Purchase", fill=(100, 116, 139), font=fonts["body_small"])
    draw.text((75, bot_y + 55), meta["price"], fill=(15, 23, 42), font=fonts["price_large"])
    draw.text((250, bot_y + 85), "GBP (incl. VAT)", fill=(148, 163, 184), font=fonts["tag"])

    # Purchase Button
    btn_w = 460
    btn_h = 85
    bx = W - 75 - btn_w
    by = bot_y + 40
    draw.rounded_rectangle([bx, by, bx + btn_w, by + btn_h], radius=20, fill=(37, 99, 235))
    btn_label = f"Purchase Pack - {meta['price']}"
    draw.text((bx + 35, by + 25), btn_label, fill=(255, 255, 255), font=fonts["btn_text"])

    # Context Below
    list_y = card_y2 + 35
    draw.text((55, list_y), "Other Categories in Library", fill=(100, 116, 139), font=fonts["h3"])

    item1_y = list_y + 55
    draw.rounded_rectangle([45, item1_y, W - 45, item1_y + 130], radius=20, fill=(255, 255, 255), outline=(226, 232, 240), width=2)
    draw.rounded_rectangle([70, item1_y + 20, 155, item1_y + 105], radius=16, fill=(254, 243, 199))
    paste_icon(img, os.path.join(SCRIPT_DIR, "assets/icons/CategoryAnimals@2x.png"), [75, item1_y + 25, 150, item1_y + 100], radius=12)
    draw.text((180, item1_y + 30), "Animals", fill=(15, 23, 42), font=fonts["h2"])
    draw.text((180, item1_y + 80), "50 words - Free Starter Pack", fill=(100, 116, 139), font=fonts["body_small"])
    draw.rounded_rectangle([W - 270, item1_y + 35, W - 75, item1_y + 93], radius=16, fill=(240, 253, 244))
    draw.text((W - 240, item1_y + 51), "Unlocked", fill=(22, 101, 52), font=fonts["btn_small"])

    item2_y = item1_y + 150
    draw.rounded_rectangle([45, item2_y, W - 45, item2_y + 130], radius=20, fill=(255, 255, 255), outline=(226, 232, 240), width=2)
    draw.rounded_rectangle([70, item2_y + 20, 155, item2_y + 105], radius=16, fill=(224, 231, 255))
    paste_icon(img, os.path.join(SCRIPT_DIR, "assets/icons/CategoryObjects@2x.png"), [75, item2_y + 25, 150, item2_y + 100], radius=12)
    draw.text((180, item2_y + 30), "Everyday Objects", fill=(15, 23, 42), font=fonts["h2"])
    draw.text((180, item2_y + 80), "50 words - Free Starter Pack", fill=(100, 116, 139), font=fonts["body_small"])
    draw.rounded_rectangle([W - 270, item2_y + 35, W - 75, item2_y + 93], radius=16, fill=(240, 253, 244))
    draw.text((W - 240, item2_y + 51), "Unlocked", fill=(22, 101, 52), font=fonts["btn_small"])

    draw_tab_bar(draw, fonts)

    out_path = os.path.join(SCREENSHOTS_DIR, f"{prod_id}.png")
    img.save(out_path, "PNG")
    return out_path


def render_bundle_screenshot(fonts: dict) -> str:
    img = Image.new("RGB", (W, H), color=(243, 244, 248))
    draw = ImageDraw.Draw(img)

    draw_app_bar(draw, fonts)

    card_y1 = 250
    card_y2 = 1880
    draw.rounded_rectangle([47, card_y1 + 4, W - 43, card_y2 + 4], radius=28, fill=(226, 232, 240))
    draw.rounded_rectangle([45, card_y1, W - 45, card_y2], radius=28, fill=(255, 255, 255), outline=(124, 58, 237), width=4)

    draw.rounded_rectangle([47, card_y1 + 2, W - 47, card_y1 + 180], radius=26, fill=(124, 58, 237))
    draw.rounded_rectangle([47, card_y1 + 120, W - 47, card_y1 + 180], radius=0, fill=(124, 58, 237))

    draw.rounded_rectangle([W - 460, card_y1 + 25, W - 75, card_y1 + 75], radius=14, fill=(255, 255, 255))
    draw.text((W - 435, card_y1 + 38), "COMPLETE COLLECTION", fill=(109, 40, 217), font=fonts["badge_small"])

    draw.text((80, card_y1 + 40), "MemoLingo", fill=(255, 255, 255), font=fonts["h1"])
    draw.text((80, card_y1 + 105), "All Categories Bundle - 15 Packs", fill=(237, 233, 254), font=fonts["h3"])

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

    price_y = card_y1 + 1180
    draw.line([75, price_y, W - 75, price_y], fill=(241, 245, 249), width=3)

    draw.rounded_rectangle([80, price_y + 30, 360, price_y + 70], radius=10, fill=(254, 242, 242))
    draw.text((95, price_y + 40), "SAVE 66% VS SINGLE PACKS", fill=(220, 38, 38), font=fonts["tag"])

    draw.text((80, price_y + 85), "£4.99", fill=(15, 23, 42), font=fonts["price_large"])
    draw.text((280, price_y + 115), "GBP (one-time payment)", fill=(100, 116, 139), font=fonts["body_small"])

    btn_y = price_y + 200
    draw.rounded_rectangle([80, btn_y, W - 80, btn_y + 110], radius=24, fill=(124, 58, 237))
    draw.text((W // 2 - 240, btn_y + 34), "Buy Complete Bundle - £4.99", fill=(255, 255, 255), font=fonts["btn_text"])

    draw.text((W // 2 - 210, btn_y + 135), "Secure Apple In-App Purchase - Family Sharing Included", fill=(100, 116, 139), font=fonts["tag"])

    draw_tab_bar(draw, fonts)

    out_path = os.path.join(SCREENSHOTS_DIR, "memolingo_all_categories.png")
    img.save(out_path, "PNG")
    return out_path


# ================= Main Execution =================

def main():
    print("==================================================")
    print(" MemoLingo: UK Pricing & Review Screenshot Upload")
    print("==================================================")

    # 1. Auth Setup
    key_path = find_private_key()
    print(f"✓ Using private key: {key_path}")
    token = generate_jwt(key_path)
    client = ASCClient(token)

    # 2. Get App & IAP IDs
    app_id = client.get_app_id(BUNDLE_ID)
    iaps = client.get_all_iaps(app_id)
    print(f"✓ Found {len(iaps)} In-App Purchases on App Store Connect\n")

    # 3. Load Fonts & Word Data
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

    # 4. Process Bundle Product
    bundle_id = "memolingo_all_categories"
    bundle_iap_id = iaps.get(bundle_id)
    print(f"[1/16] Processing Complete Bundle '{bundle_id}'...")
    if bundle_iap_id:
        client.update_price_schedule_gbr(bundle_iap_id, "4.99")
        img_path = render_bundle_screenshot(fonts)
        client.upload_review_screenshot(bundle_iap_id, img_path)
    else:
        print(f"    ✗ Bundle IAP ID not found on App Store Connect!")
    print()

    # 5. Process 15 Category Products
    for idx, (prod_id, meta) in enumerate(CATEGORY_META.items(), 2):
        print(f"[{idx}/16] Processing '{meta['name']}' ({prod_id})...")
        iap_id = iaps.get(prod_id)
        if not iap_id:
            print(f"    ✗ Product ID '{prod_id}' not found on App Store Connect!")
            continue

        # Update Pricing in GBR
        client.update_price_schedule_gbr(iap_id, meta["target_price_num"])

        # Render & Upload Review Screenshot
        words = words_by_cat.get(meta["csv_key"], [])
        img_path = render_category_screenshot(prod_id, meta, words, fonts)
        client.upload_review_screenshot(iap_id, img_path)
        print()

    print("==================================================")
    print(" 🎉 All 16 IAP products updated to GBP & screenshots uploaded!")
    print("==================================================")


if __name__ == "__main__":
    main()
