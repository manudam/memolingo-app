import csv
import os
import requests
import time

API_KEY = "56266684-991f86f53324cb55d2afbabfb"
CSV_FILE = "assets/memolingo/data/words_list_full.csv"
OUTPUT_DIR = "assets/memolingo/images"

def get_pixabay_image_url(query):
    # Ensure query is url encoded properly
    query = requests.utils.quote(query)
    url = f"https://pixabay.com/api/?key={API_KEY}&q={query}&image_type=photo&per_page=3&safesearch=true"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        if data['totalHits'] > 0:
            return data['hits'][0]['webformatURL']
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

def main():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    missing_count = 0
    success_count = 0

    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader)
        
        for row in reader:
            category = row[0]
            filename = row[3]
            word = row[4]
            filepath = os.path.join(OUTPUT_DIR, filename)
            
            print(f"Fetching Pixabay image for: {word}")
            
            image_url = get_pixabay_image_url(word)
            
            # If nothing found, try removing special chars or 's' (plural)
            if not image_url and word.endswith('s'):
                image_url = get_pixabay_image_url(word[:-1])
                
            if image_url:
                if download_image(image_url, filepath):
                    print(f"  [+] Success")
                    success_count += 1
                else:
                    print(f"  [-] Failed to download file")
                    missing_count += 1
            else:
                print(f"  [-] No hits found on Pixabay")
                missing_count += 1
                
            # Sleep to respect Pixabay rate limits (100 req/min)
            time.sleep(0.6)

    print(f"\nDone! Successfully downloaded {success_count} images. {missing_count} failed/not found.")

if __name__ == "__main__":
    main()
