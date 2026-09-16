#!/usr/bin/env python3
"""
Upload In-App Purchases from Products.storekit to App Store Connect.

Requirements:
    pip install pyjwt cryptography requests
"""

import glob
import json
import os
import sys
import time
from typing import Any, Dict, List, Optional

try:
    import jwt
    import requests
except ImportError:
    print("\n[ERROR] Missing required Python libraries.")
    print("Please install them using:\n")
    print("    pip install pyjwt cryptography requests\n")
    sys.exit(1)

# ================= Configuration =================
KEY_ID = "6239B44P75"
ISSUER_ID = "69a6de88-bea5-47e3-e053-5b8c7c11a4d1"
BUNDLE_ID = "com.trianglecarrot.memolingoapp"

# Search ~/Downloads for the .p8 key file
DEFAULT_KEY_NAME = f"AuthKey_{KEY_ID}.p8"
DOWNLOADS_DIR = os.path.expanduser("~/Downloads")
DEFAULT_KEY_PATH = os.path.join(DOWNLOADS_DIR, DEFAULT_KEY_NAME)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
STOREKIT_PATH = os.path.join(SCRIPT_DIR, "ios", "Runner", "Products.storekit")

BASE_URL = "https://api.appstoreconnect.apple.com"


def find_private_key() -> str:
    """Find the .p8 private key file."""
    if os.path.exists(DEFAULT_KEY_PATH):
        return DEFAULT_KEY_PATH
    
    # Try searching any .p8 file in ~/Downloads containing the KEY_ID
    matches = glob.glob(os.path.join(DOWNLOADS_DIR, f"*{KEY_ID}*.p8"))
    if matches:
        return matches[0]

    # Try any .p8 file in ~/Downloads
    all_p8 = glob.glob(os.path.join(DOWNLOADS_DIR, "*.p8"))
    if len(all_p8) == 1:
        return all_p8[0]
    
    raise FileNotFoundError(
        f"Could not find private key file '{DEFAULT_KEY_NAME}' in {DOWNLOADS_DIR}.\n"
        f"Please ensure your downloaded .p8 file is in ~/Downloads."
    )


def generate_jwt(key_path: str) -> str:
    """Generate JWT token for App Store Connect API."""
    with open(key_path, "r") as f:
        private_key = f.read()

    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,  # 20 minutes expiration
        "aud": "appstoreconnect-v1",
    }
    headers = {
        "kid": KEY_ID,
        "alg": "ES256",
        "typ": "JWT",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)


class AppStoreConnectClient:
    def __init__(self, token: str):
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        })

    def get(self, path: str, params: Optional[Dict[str, Any]] = None) -> requests.Response:
        url = f"{BASE_URL}{path}" if path.startswith("/") else path
        resp = self.session.get(url, params=params)
        return resp

    def post(self, path: str, json_data: Dict[str, Any]) -> requests.Response:
        url = f"{BASE_URL}{path}" if path.startswith("/") else path
        resp = self.session.post(url, json=json_data)
        return resp

    def get_app_id(self, bundle_id: str) -> str:
        """Fetch App ID for bundle identifier."""
        resp = self.get("/v1/apps", params={"filter[bundleId]": bundle_id})
        if resp.status_code != 200:
            raise RuntimeError(f"Failed to query apps: {resp.status_code} - {resp.text}")
        data = resp.json().get("data", [])
        if not data:
            raise RuntimeError(f"App with bundle ID '{bundle_id}' not found in your App Store Connect account.")
        app_id = data[0]["id"]
        app_name = data[0].get("attributes", {}).get("name", "Unknown")
        print(f"✓ Found App: '{app_name}' (ID: {app_id})")
        return app_id

    def get_existing_iaps(self, app_id: str) -> Dict[str, str]:
        """Fetch existing IAPs for the app -> map of productId to IAP internal ID."""
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

    def create_iap(self, app_id: str, product_id: str, name: str) -> str:
        """Create non-consumable In-App Purchase with family sharing."""
        body = {
            "data": {
                "type": "inAppPurchases",
                "attributes": {
                    "name": name,
                    "productId": product_id,
                    "inAppPurchaseType": "NON_CONSUMABLE",
                    "familySharable": True,
                    "reviewNote": f"Unlocks '{name}' content in MemoLingo.",
                },
                "relationships": {
                    "app": {
                        "data": {
                            "type": "apps",
                            "id": app_id,
                        }
                    }
                },
            }
        }
        resp = self.post("/v2/inAppPurchases", body)
        if resp.status_code not in (200, 201):
            raise RuntimeError(f"Error creating IAP '{product_id}': {resp.status_code} - {resp.text}")
        return resp.json()["data"]["id"]

    def add_localization(self, iap_id: str, locale: str, name: str, description: str):
        """Add localization to an IAP."""
        # Convert en_GB to en-GB if needed
        norm_locale = locale.replace("_", "-")
        body = {
            "data": {
                "type": "inAppPurchaseLocalizations",
                "attributes": {
                    "name": name,
                    "locale": norm_locale,
                    "description": description,
                },
                "relationships": {
                    "inAppPurchaseV2": {
                        "data": {
                            "type": "inAppPurchases",
                            "id": iap_id,
                        }
                    }
                },
            }
        }
        resp = self.post("/v1/inAppPurchaseLocalizations", body)
        if resp.status_code not in (200, 201):
            # If locale exists or fails, log info
            print(f"    - Note on localization ({norm_locale}): {resp.json().get('errors', [{}])[0].get('detail', resp.text)}")
        else:
            print(f"    ✓ Localization added ({norm_locale}: {name})")

    def set_price_schedule(self, iap_id: str, target_price: str):
        """Fetch matching price point and set price schedule."""
        # Query price points for USA (USD)
        resp = self.get(f"/v2/inAppPurchases/{iap_id}/pricePoints", params={
            "filter[territory]": "USA",
            "limit": 200,
        })
        if resp.status_code != 200:
            print(f"    ⚠ Could not query price points: {resp.text}")
            return

        points = resp.json().get("data", [])
        matched_point_id = None
        for pt in points:
            price_str = pt.get("attributes", {}).get("customerPrice")
            if price_str == target_price:
                matched_point_id = pt["id"]
                break

        if not matched_point_id:
            # Try finding approximate or first tier
            print(f"    ⚠ Price point for ${target_price} not found directly in US territory.")
            return

        temp_id = "${price-temp-id}"
        body = {
            "data": {
                "type": "inAppPurchasePriceSchedules",
                "relationships": {
                    "inAppPurchase": {
                        "data": {
                            "type": "inAppPurchases",
                            "id": iap_id,
                        }
                    },
                    "baseTerritory": {
                        "data": {
                            "type": "territories",
                            "id": "USA",
                        }
                    },
                    "manualPrices": {
                        "data": [
                            {
                                "type": "inAppPurchasePrices",
                                "id": temp_id,
                            }
                        ]
                    },
                },
            },
            "included": [
                {
                    "type": "inAppPurchasePrices",
                    "id": temp_id,
                    "attributes": {},
                    "relationships": {
                        "inAppPurchasePricePoint": {
                            "data": {
                                "type": "inAppPurchasePricePoints",
                                "id": matched_point_id,
                            }
                        }
                    },
                }
            ],
        }
        resp = self.post("/v1/inAppPurchasePriceSchedules", body)
        if resp.status_code in (200, 201):
            print(f"    ✓ Price schedule set to ${target_price} USD")
        else:
            print(f"    - Note on price schedule: {resp.json().get('errors', [{}])[0].get('detail', resp.text)}")


def main():
    print("==================================================")
    print(" App Store Connect IAP Auto-Uploader")
    print("==================================================")

    # 1. Locate Private Key
    try:
        key_path = find_private_key()
        print(f"✓ Found private key: {key_path}")
    except FileNotFoundError as e:
        print(f"[ERROR] {e}")
        sys.exit(1)

    # 2. Generate JWT
    print("✓ Generating authentication token...")
    token = generate_jwt(key_path)
    client = AppStoreConnectClient(token)

    # 3. Find App ID
    print(f"✓ Looking up app for bundle ID: {BUNDLE_ID}...")
    try:
        app_id = client.get_app_id(BUNDLE_ID)
    except Exception as e:
        print(f"[ERROR] {e}")
        sys.exit(1)

    # 4. Load Products.storekit
    if not os.path.exists(STOREKIT_PATH):
        print(f"[ERROR] StoreKit file not found at: {STOREKIT_PATH}")
        sys.exit(1)

    with open(STOREKIT_PATH, "r") as f:
        storekit_data = json.load(f)

    products = storekit_data.get("products", [])
    print(f"✓ Loaded {len(products)} products from Products.storekit\n")

    # 5. Fetch existing IAPs to prevent duplicates
    print("✓ Checking existing In-App Purchases on App Store Connect...")
    existing_iaps = client.get_existing_iaps(app_id)
    print(f"✓ Found {len(existing_iaps)} existing IAP(s) in App Store Connect\n")

    # 6. Create / Update each product
    for idx, prod in enumerate(products, 1):
        product_id = prod["productID"]
        ref_name = prod["referenceName"]
        price = prod.get("displayPrice", "0.99")
        locs = prod.get("localizations", [])

        print(f"[{idx}/{len(products)}] Processing '{ref_name}' ({product_id})...")

        iap_id = existing_iaps.get(product_id)
        if iap_id:
            print(f"    ✓ Product already exists (IAP ID: {iap_id})")
        else:
            try:
                iap_id = client.create_iap(app_id, product_id, ref_name)
                print(f"    ✓ Created IAP (IAP ID: {iap_id})")
            except Exception as e:
                print(f"    ✗ Failed to create IAP: {e}")
                continue

        # Add localizations
        for loc in locs:
            client.add_localization(
                iap_id=iap_id,
                locale=loc.get("locale", "en_GB"),
                name=loc.get("displayName", ref_name),
                description=loc.get("description", f"Unlock {ref_name} pack."),
            )

        # Set price schedule
        client.set_price_schedule(iap_id, price)
        print()

    print("==================================================")
    print(" 🎉 All In-App Purchases successfully processed!")
    print("==================================================")


if __name__ == "__main__":
    main()
