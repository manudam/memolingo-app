import csv
import os
import requests
import time
import random

CSV_FILE = "assets/memolingo/data/words_list_full.csv"
OUTPUT_DIR = "assets/memolingo/images"
API_KEY = "56266684-991f86f53324cb55d2afbabfb"

def get_pixabay_image_url(query):
    query_quoted = requests.utils.quote(query)
    url = f"https://pixabay.com/api/?key={API_KEY}&q={query_quoted}&image_type=photo&per_page=10&safesearch=true"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        if data['totalHits'] > 0:
            hits = data['hits']
            # Pick a random result from index 1 to 5 (avoiding the 1st result)
            idx = random.randint(1, min(5, len(hits)-1)) if len(hits) > 1 else 0
            return hits[idx]['webformatURL']
    return None

def download_image(url, filepath):
    try:
        response = requests.get(url, stream=True, timeout=10)
        if response.status_code == 200:
            with open(filepath, 'wb') as f:
                for chunk in response.iter_content(1024):
                    f.write(chunk)
            return True
    except Exception:
        pass
    return False

with open("flagged_images.txt", "r") as f:
    flagged_words = f.read().splitlines()

# Get filename mapping from CSV
filename_map = {}
with open(CSV_FILE, "r", encoding="utf-8") as f:
    reader = csv.reader(f)
    next(reader)
    for row in reader:
        filename_map[row[4].lower()] = row[3]

count = 0
for word in flagged_words:
    word_lower = word.lower()
    if word_lower in filename_map:
        filename = filename_map[word_lower]
        filepath = os.path.join(OUTPUT_DIR, filename)
        url = get_pixabay_image_url(word)
        if url:
            if download_image(url, filepath):
                print(f"[{count+1}/{len(flagged_words)}] Replaced {word}")
        else:
            print(f"[{count+1}/{len(flagged_words)}] Failed to find alternative for {word}")
    else:
        print(f"Word {word} not found in CSV.")
    count += 1
    time.sleep(0.6) # Rate limit

print("Done replacing flagged images!")
