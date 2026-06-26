import csv
import os
import shutil
from bing_image_downloader import downloader

csv_file = "assets/memolingo/data/words_list_full.csv"
image_dir = "assets/memolingo/images"
fallback_image = os.path.join(image_dir, "cat.jpg")

missing = []
with open(csv_file, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    next(reader)
    for row in reader:
        filename = row[3]
        if not os.path.exists(os.path.join(image_dir, filename)):
            missing.append((row[4], filename))

for word, filename in missing:
    print(f"Retrying: {word}")
    try:
        query = word
        downloader.download(query, 
                            limit=1, 
                            output_dir=image_dir, 
                            adult_filter_off=False, 
                            force_replace=False, 
                            timeout=15, 
                            verbose=False)
                            
        query_folder = os.path.join(image_dir, query)
        if os.path.exists(query_folder):
            files = os.listdir(query_folder)
            if files:
                downloaded_file = files[0]
                src_path = os.path.join(query_folder, downloaded_file)
                dst_path = os.path.join(image_dir, filename)
                os.rename(src_path, dst_path)
            shutil.rmtree(query_folder, ignore_errors=True)
    except Exception as e:
        print(f"Failed again: {e}")
        
    # If still missing after retry, use fallback
    if not os.path.exists(os.path.join(image_dir, filename)):
        print(f"Using fallback for {word}")
        shutil.copy(fallback_image, os.path.join(image_dir, filename))

print("All missing images resolved!")
