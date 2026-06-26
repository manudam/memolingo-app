import csv
import os
import requests
import time
from deep_translator import GoogleTranslator

CSV_FILE = "assets/memolingo/data/words_list_full.csv"
OUTPUT_DIR = "assets/memolingo/images"
API_KEY = "56266684-991f86f53324cb55d2afbabfb"

def get_pixabay_image_url(query, skip_first=False):
    query_quoted = requests.utils.quote(query)
    url = f"https://pixabay.com/api/?key={API_KEY}&q={query_quoted}&image_type=photo&per_page=5&safesearch=true"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        if data['totalHits'] > 0:
            hits = data['hits']
            idx = 1 if skip_first and len(hits) > 1 else 0
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

categories_needed = {
    "everyday objects": {"image": "CategoryObjects.png", "level": "5", "needed": 1, "candidates": ["stapler", "binder", "clipboard", "thumbtack"]},
    "personal belongings": {"image": "CategoryPersonal.png", "level": "4", "needed": 6, "candidates": ["hairbrush", "tweezers", "cologne", "deodorant", "lotion", "sunscreen", "lip balm", "compact", "mirror", "contact lenses"]},
    "Nature & Environment": {"image": "CategoryNature.png", "level": "4", "needed": 10, "candidates": ["volcano", "iceberg", "tornado", "earthquake", "galaxy", "comet", "pebble", "moss", "glacier", "coral", "tundra", "savanna", "canyon", "cliff"]},
    "Professions": {"image": "CategoryProfessions.png", "level": "5", "needed": 10, "candidates": ["surgeon", "dentist", "pharmacist", "therapist", "psychologist", "psychiatrist", "pediatrician", "optometrist", "dermatologist", "cardiologist", "barista", "sommelier", "chef", "waiter", "bartender"]},
    "Clothing & Accessories": {"image": "CategoryClothing.png", "level": "5", "needed": 18, "candidates": ["tuxedo", "bowtie", "cufflinks", "suspenders", "trenchcoat", "parka", "windbreaker", "poncho", "leggings", "tights", "pantyhose", "stockings", "kimono", "sari", "kilt", "toga", "sombrero", "fedora", "beanie", "beret", "bandana", "visor"]},
    "Technology & Electronics": {"image": "CategoryTech.png", "level": "6", "needed": 8, "candidates": ["server", "microchip", "processor", "motherboard", "usb", "antenna", "software", "hardware", "database", "network"]},
    "Musical Instruments": {"image": "CategoryMusic.png", "level": "6", "needed": 1, "candidates": ["xylophone", "synthesizer", "theremin", "marimba"]},
    "Health & Medicine": {"image": "CategoryHealth.png", "level": "6", "needed": 5, "candidates": ["pacemaker", "defibrillator", "ultrasound", "mri", "xray", "inhaler", "thermometer", "microscope", "forceps"]}
}

langs = ['fr', 'nl', 'de', 'it', 'es', 'ru', 'ko', 'zh-CN', 'ja']

with open(CSV_FILE, "r", encoding="utf-8") as f:
    reader = csv.reader(f)
    header = next(reader)
    existing_words = {row[4].lower() for row in reader}

new_rows = []
for cat, data in categories_needed.items():
    added = 0
    for candidate in data["candidates"]:
        if added >= data["needed"]:
            break
        if candidate.lower() not in existing_words:
            print(f"Translating {candidate}...")
            translations = []
            for lang in langs:
                lang_code = lang
                try:
                    translated = GoogleTranslator(source='en', target=lang_code).translate(candidate)
                    translations.append(translated)
                except Exception as e:
                    translations.append(candidate)
            
            filename = f"{candidate.replace(' ', '_')}.jpg"
            row = [cat, data["image"], data["level"], filename, candidate] + translations
            new_rows.append(row)
            existing_words.add(candidate.lower())
            added += 1

with open(CSV_FILE, "a", encoding="utf-8", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(new_rows)
    
print(f"Added {len(new_rows)} new words.")

for row in new_rows:
    word = row[4]
    filename = row[3]
    filepath = os.path.join(OUTPUT_DIR, filename)
    url = get_pixabay_image_url(word, skip_first=False)
    if url:
        if download_image(url, filepath):
            print(f"  [+] Downloaded new image for {word}")
    time.sleep(0.6)

try:
    with open("flagged_images.txt", "r") as f:
        flagged_words = f.read().splitlines()
except:
    flagged_words = []

for word in flagged_words:
    print(f"Refetching flagged word: {word}")
    filename = None
    with open(CSV_FILE, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        next(reader)
        for row in reader:
            if row[4].lower() == word.lower():
                filename = row[3]
                break
    
    if filename:
        filepath = os.path.join(OUTPUT_DIR, filename)
        url = get_pixabay_image_url(word, skip_first=True)
        if url:
            if download_image(url, filepath):
                print(f"  [+] Replaced {word} with alternative image")
        else:
            print(f"  [-] Failed to find alternative for {word}")
        time.sleep(0.6)

print("Done fixing dataset!")
