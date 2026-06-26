from bing_image_downloader import downloader
import csv
import os
import shutil

csv_file = "assets/memolingo/data/words_list_full.csv"
output_dir = "assets/memolingo/images"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

words_to_download = []
with open(csv_file, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    header = next(reader, None)
    for row in reader:
        if len(row) > 4:
            filename = row[3]
            english_word = row[4]
            # Check if image already exists
            if not os.path.exists(os.path.join(output_dir, filename)):
                words_to_download.append((english_word, filename))

print(f"Found {len(words_to_download)} missing images to download.")

for word, filename in words_to_download:
    print(f"Downloading image for {word} -> {filename}")
    query = f"{word} object clear background"
    try:
        downloader.download(query, 
                            limit=1, 
                            output_dir=output_dir, 
                            adult_filter_off=False, 
                            force_replace=False, 
                            timeout=60, 
                            verbose=False)
                            
        query_folder = os.path.join(output_dir, query)
        if os.path.exists(query_folder):
            files = os.listdir(query_folder)
            if files:
                downloaded_file = files[0]
                src_path = os.path.join(query_folder, downloaded_file)
                dst_path = os.path.join(output_dir, filename)
                os.rename(src_path, dst_path)
            shutil.rmtree(query_folder, ignore_errors=True)
    except Exception as e:
        print(f"Error downloading {word}: {e}")
