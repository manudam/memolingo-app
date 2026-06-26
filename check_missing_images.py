import csv
import os

csv_file = "assets/memolingo/data/words_list_full.csv"
image_dir = "assets/memolingo/images"

missing = []
with open(csv_file, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    next(reader)
    for row in reader:
        filename = row[3]
        if not os.path.exists(os.path.join(image_dir, filename)):
            missing.append(row[4])

print(f"Total missing: {len(missing)}")
for m in missing:
    print(m)
