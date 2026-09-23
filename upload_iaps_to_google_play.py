#!/usr/bin/env python3
"""
Upload all 16 In-App Products to Google Play Console via the Google Play Developer API.

Requirements:
- Service Account JSON key downloaded from Google Play Console (Setup > API Access)
  placed in ~/Downloads or specified via --key.
- Uses existing pyjwt, cryptography, and requests libraries in venv.
"""

import glob
import json
import os
import sys
import time
from typing import Any, Dict, List, Optional
import jwt
import requests

PACKAGE_NAME = "com.trianglecarrot.memolingo"
DOWNLOADS_DIR = os.path.expanduser("~/Downloads")

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
STOREKIT_PATH = os.path.join(SCRIPT_DIR, "ios", "Runner", "Products.storekit")

TOKEN_URL = "https://oauth2.googleapis.com/token"
API_BASE = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"


def find_service_account_key(cli_arg: Optional[str] = None) -> str:
    if cli_arg and os.path.exists(cli_arg):
        return cli_arg

    # Check current directory
    local_keys = glob.glob("*.json")
    for k in local_keys:
        try:
            with open(k, "r") as f:
                data = json.load(f)
                if data.get("type") == "service_account" and "private_key" in data:
                    return k
        except Exception:
            continue

    # Check ~/Downloads
    dl_keys = glob.glob(os.path.join(DOWNLOADS_DIR, "*.json"))
    for k in dl_keys:
        try:
            with open(k, "r") as f:
                data = json.load(f)
                if data.get("type") == "service_account" and "private_key" in data:
                    return k
        except Exception:
            continue

    raise FileNotFoundError(
        "Could not find a Google Service Account JSON key.\n"
        "Please download your service account key from Google Play Console (Setup > API Access)\n"
        "and place it in your Downloads folder."
    )


def get_access_token(service_account_path: str) -> str:
    """Exchange service account JWT for an OAuth2 Google access token."""
    with open(service_account_path, "r") as f:
        sa_data = json.load(f)

    client_email = sa_data["client_email"]
    private_key = sa_data["private_key"]
    token_uri = sa_data.get("token_uri", TOKEN_URL)

    now = int(time.time())
    payload = {
        "iss": client_email,
        "scope": "https://www.googleapis.com/auth/androidpublisher",
        "aud": token_uri,
        "exp": now + 3600,
        "iat": now,
    }

    signed_jwt = jwt.encode(payload, private_key, algorithm="RS256")

    token_resp = requests.post(
        token_uri,
        data={
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": signed_jwt,
        },
    )

    if token_resp.status_code != 200:
        raise RuntimeError(f"Failed to obtain Google access token: {token_resp.status_code} - {token_resp.text}")

    return token_resp.json()["access_token"]


class GooglePlayClient:
    def __init__(self, access_token: str):
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
        })

    def list_inapp_products(self) -> Dict[str, Any]:
        url = f"{API_BASE}/{PACKAGE_NAME}/inappproducts"
        resp = self.session.get(url)
        if resp.status_code != 200:
            print(f"Note on querying existing products: {resp.status_code} - {resp.text}")
            return {}
        items = resp.json().get("inappproduct", [])
        return {item["sku"]: item for item in items}

    def insert_or_update_product(
        self,
        sku: str,
        title: str,
        description: str,
        price_micros: str,
        currency: str = "GBP",
        existing: bool = False,
    ):
        body = {
            "packageName": PACKAGE_NAME,
            "sku": sku,
            "status": "active",
            "purchaseType": "managedUser",  # Non-consumable / managed product
            "defaultPrice": {
                "priceMicros": price_micros,
                "currency": currency,
            },
            "listings": {
                "en-GB": {
                    "title": title[:55],
                    "description": description[:80],
                },
                "en-US": {
                    "title": title[:55],
                    "description": description[:80],
                },
            },
            "defaultLanguage": "en-GB",
        }

        if existing:
            url = f"{API_BASE}/{PACKAGE_NAME}/inappproducts/{sku}"
            resp = self.session.put(url, json=body)
            action = "Updated"
        else:
            url = f"{API_BASE}/{PACKAGE_NAME}/inappproducts"
            resp = self.session.post(url, json=body)
            action = "Created"
            # If already exists (409), retry with PUT
            if resp.status_code == 409:
                url = f"{API_BASE}/{PACKAGE_NAME}/inappproducts/{sku}"
                resp = self.session.put(url, json=body)
                action = "Updated (Existing)"

        if resp.status_code in (200, 201):
            print(f"    ✓ {action} SKU: {sku} - {title} (£{int(price_micros)/1_000_000:.2f})")
            return True
        else:
            print(f"    ✗ Failed to {action.lower()} SKU {sku}: {resp.status_code} - {resp.text}")
            return False


def main():
    print("==================================================")
    print(" MemoLingo: Google Play In-App Products Uploader")
    print("==================================================")

    key_arg = sys.argv[1] if len(sys.argv) > 1 else None
    try:
        key_path = find_service_account_key(key_arg)
        print(f"✓ Found service account key: {key_path}")
    except FileNotFoundError as e:
        print(f"\n[ERROR] {e}\n")
        print("To get a Google Service Account Key:")
        print("1. Go to Google Play Console -> Setup -> API access")
        print("2. Choose 'Link existing Google Cloud project' or 'Create new project'")
        print("3. Under Service Accounts, click 'Create Service Account' (or link existing)")
        print("4. Grant 'Manage in-app products' or 'Admin' permissions")
        print("5. Generate and download the JSON key to your ~/Downloads folder\n")
        sys.exit(1)

    print("✓ Authenticating with Google Play Developer API...")
    try:
        access_token = get_access_token(key_path)
        print("✓ Successfully obtained Google OAuth2 access token.")
    except Exception as e:
        print(f"[ERROR] Authentication failed: {e}")
        sys.exit(1)

    client = GooglePlayClient(access_token)

    # Load products from StoreKit
    with open(STOREKIT_PATH, "r") as f:
        storekit_data = json.load(f)

    products = storekit_data.get("products", [])
    print(f"✓ Loaded {len(products)} products from {STOREKIT_PATH}")

    print("\n✓ Fetching existing in-app products from Google Play...")
    existing_map = client.list_inapp_products()
    print(f"✓ Found {len(existing_map)} existing products on Google Play.\n")

    for idx, prod in enumerate(products, 1):
        sku = prod["productID"]
        ref_name = prod["referenceName"]
        locs = prod.get("localizations", [{}])[0]
        title = locs.get("displayName", ref_name)
        desc = locs.get("description", f"Unlock {ref_name} pack.")

        # Determine price in micros (GBP)
        # £4.99 = 4,990,000 micros, £0.99 = 990,000 micros
        if sku == "memolingo_all_categories":
            price_micros = "4990000"
        else:
            price_micros = "990000"

        print(f"[{idx}/{len(products)}] Processing '{ref_name}' ({sku})...")
        is_existing = sku in existing_map
        client.insert_or_update_product(
            sku=sku,
            title=title,
            description=desc,
            price_micros=price_micros,
            currency="GBP",
            existing=is_existing,
        )

    print("\n==================================================")
    print(" 🎉 All Google Play in-app products processed!")
    print("==================================================")


if __name__ == "__main__":
    main()
