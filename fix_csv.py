import csv

input_file = "assets/memolingo/data/words_list_full.csv"
output_file = "assets/memolingo/data/words_list_full.csv.tmp"

allowed_categories = [
    "animals", "everyday objects", "in the home", "food", "personal belongings", 
    "verbs", "describing things", "places", "people", "sports", "transport", 
    "Nature & Environment", "Professions", "Clothing & Accessories", 
    "Technology & Electronics", "Musical Instruments", "Health & Medicine"
]

category_counts = {c: 0 for c in allowed_categories}
seen_words = {c: set() for c in allowed_categories}

rows_to_keep = []

with open(input_file, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    header = next(reader)
    rows_to_keep.append(header)
    
    for row in reader:
        cat = row[0]
        if cat in allowed_categories:
            word = row[4].strip().lower()
            if word not in seen_words[cat] and category_counts[cat] < 50:
                seen_words[cat].add(word)
                category_counts[cat] += 1
                rows_to_keep.append(row)

with open(output_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerows(rows_to_keep)

for cat, count in category_counts.items():
    print(f"{cat}: {count}")

