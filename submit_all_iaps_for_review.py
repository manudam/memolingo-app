#!/usr/bin/env python3
"""
Submit all In-App Purchases for MemoLingo to Apple App Store Review.
"""

import glob
import os
import sys
import time
from typing import Any, Dict, List, Optional
import jwt
import requests

KEY_ID = "6239B44P75"
ISSUER_ID = "69a6de88-bea5-47e3-e053-5b8c7c11a4d1"
BUNDLE_ID = "com.trianglecarrot.memolingoapp"
DOWNLOADS_DIR = os.path.expanduser("~/Downloads")
DEFAULT_KEY_NAME = f"AuthKey_{KEY_ID}.p8"
DEFAULT_KEY_PATH = os.path.join(DOWNLOADS_DIR, DEFAULT_KEY_NAME)

BASE_URL = "https://api.appstoreconnect.apple.com"


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

    def get_app_id(self, bundle_id: str) -> str:
        resp = self.get("/v1/apps", params={"filter[bundleId]": bundle_id})
        data = resp.json().get("data", [])
        if not data:
            raise RuntimeError(f"App with bundle ID '{bundle_id}' not found.")
        app_id = data[0]["id"]
        app_name = data[0].get("attributes", {}).get("name", "Unknown")
        print(f"✓ Found App: '{app_name}' (ID: {app_id})")
        return app_id

    def get_all_iaps(self, app_id: str) -> Dict[str, Dict[str, Any]]:
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
                    existing[prod_id] = {
                        "id": item["id"],
                        "name": item.get("attributes", {}).get("name", prod_id),
                        "state": item.get("attributes", {}).get("state", "UNKNOWN"),
                    }
            url = data.get("links", {}).get("next")
        return existing

    def submit_iap(self, iap_id: str, name: str, current_state: str) -> str:
        if current_state in ("WAITING_FOR_REVIEW", "IN_REVIEW", "APPROVED"):
            print(f"    ✓ Already submitted: State is '{current_state}'")
            return current_state

        body = {
            "data": {
                "type": "inAppPurchaseSubmissions",
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
        resp = self.post("/v1/inAppPurchaseSubmissions", body)
        if resp.status_code in (200, 201):
            # Fetch updated state
            check_resp = self.get(f"/v2/inAppPurchases/{iap_id}")
            new_state = check_resp.json().get("data", {}).get("attributes", {}).get("state", "SUBMITTED")
            print(f"    ✓ Successfully submitted to Apple Review! State: {new_state}")
            return new_state
        else:
            print(f"    ✗ Submission error: {resp.status_code} - {resp.text}")
            return current_state


def main():
    print("==================================================")
    print(" MemoLingo: Submitting All IAPs for Apple Review")
    print("==================================================")

    key_path = find_private_key()
    print(f"✓ Using private key: {key_path}")
    token = generate_jwt(key_path)
    client = ASCClient(token)

    app_id = client.get_app_id(BUNDLE_ID)
    iaps = client.get_all_iaps(app_id)
    print(f"✓ Found {len(iaps)} In-App Purchases on App Store Connect\n")

    target_ids = [
        "memolingo_all_categories",
        "memolingo_category_in_the_home",
        "memolingo_category_food",
        "memolingo_category_personal_belongings",
        "memolingo_category_verbs",
        "memolingo_category_describing_things",
        "memolingo_category_places",
        "memolingo_category_people",
        "memolingo_category_sports",
        "memolingo_category_transport",
        "memolingo_category_nature_environment",
        "memolingo_category_professions",
        "memolingo_category_clothing_accessories",
        "memolingo_category_technology_electronics",
        "memolingo_category_musical_instruments",
        "memolingo_category_health_medicine",
    ]

    results = {}
    for idx, prod_id in enumerate(target_ids, 1):
        info = iaps.get(prod_id)
        if not info:
            print(f"[{idx}/{len(target_ids)}] ⚠ '{prod_id}' not found!")
            continue

        print(f"[{idx}/{len(target_ids)}] Submitting '{info['name']}' ({prod_id})...")
        final_state = client.submit_iap(info["id"], info["name"], info["state"])
        results[info["name"]] = final_state

    print("\n==================================================")
    print(" 🎉 Submission Results:")
    print("==================================================")
    for name, state in results.items():
        print(f" • {name}: {state}")


if __name__ == "__main__":
    main()
