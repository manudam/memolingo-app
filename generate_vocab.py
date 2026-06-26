import time
import os
import csv
import socket
from deep_translator import GoogleTranslator

socket.setdefaulttimeout(10)

categories = {
    "animals": ["lion", "elephant", "bear", "wolf", "fox", "rabbit", "turtle", "frog", "snake", "crocodile", "shark", "whale", "dolphin", "penguin", "eagle", "owl", "parrot", "butterfly", "bee", "ant", "spider", "crab", "lobster", "octopus", "jellyfish", "seahorse", "starfish", "camel", "zebra", "giraffe", "hippopotamus", "rhinoceros", "kangaroo", "koala", "panda", "gorilla", "chimpanzee", "sloth", "armadillo", "bat", "rat", "hamster", "guinea pig", "ferret", "hedgehog", "lizard", "chameleon", "iguana", "gecko", "ostrich"],
    "everyday objects": ["umbrella", "wallet", "keys", "sunglasses", "backpack", "suitcase", "brush", "comb", "toothbrush", "toothpaste", "soap", "shampoo", "towel", "tissue", "toilet paper", "sponge", "broom", "mop", "bucket", "trash can", "scissors", "glue", "tape", "stapler", "paper clip", "rubber band", "ruler", "calculator", "notebook", "folder", "envelope", "stamp", "pen", "pencil", "eraser", "marker", "highlighter", "chalk", "whiteboard", "blackboard", "calendar", "clock", "watch", "alarm clock", "battery", "charger", "headphones", "earphones", "microphone", "speaker"],
    "in the home": ["couch", "armchair", "coffee table", "bookshelf", "television", "remote control", "rug", "carpet", "curtain", "blind", "cushion", "pillow", "blanket", "sheet", "mattress", "bed", "wardrobe", "closet", "dresser", "mirror", "lamp", "light bulb", "switch", "plug", "socket", "door", "window", "floor", "ceiling", "wall", "stairs", "elevator", "balcony", "terrace", "roof", "chimney", "fireplace", "radiator", "heater", "fan", "air conditioner", "stove", "oven", "microwave", "refrigerator", "freezer", "dishwasher", "sink", "faucet", "toilet"],
    "food": ["pizza", "hamburger", "hot dog", "sandwich", "taco", "burrito", "sushi", "pasta", "noodles", "rice", "soup", "salad", "bread", "toast", "cereal", "pancake", "waffle", "egg", "bacon", "sausage", "steak", "chicken", "fish", "shrimp", "cheese", "yogurt", "butter", "milk", "juice", "water", "coffee", "tea", "soda", "wine", "beer", "cake", "pie", "cookie", "brownie", "ice cream", "chocolate", "candy", "gum", "potato", "tomato", "onion", "garlic", "carrot", "broccoli", "spinach"],
    "personal belongings": ["purse", "handbag", "wallet", "briefcase", "backpack", "luggage", "suitcase", "passport", "ID card", "driver's license", "credit card", "cash", "coins", "receipt", "ticket", "boarding pass", "keys", "keychain", "sunglasses", "glasses", "contact lenses", "watch", "jewelry", "necklace", "bracelet", "ring", "earrings", "makeup", "lipstick", "perfume", "cologne", "deodorant", "comb", "brush", "mirror", "tissues", "hand sanitizer", "mask", "umbrella", "water bottle", "lunchbox", "thermos", "laptop", "tablet", "smartphone", "charger", "power bank", "headphones", "earbuds", "book"],
    "verbs": ["read", "write", "listen", "speak", "talk", "study", "learn", "teach", "understand", "remember", "forget", "think", "believe", "know", "guess", "dream", "imagine", "create", "build", "destroy", "break", "fix", "repair", "mend", "clean", "wash", "dry", "sweep", "mop", "vacuum", "dust", "polish", "paint", "draw", "sketch", "color", "cut", "paste", "glue", "fold", "tear", "rip", "open", "close", "lock", "unlock", "push", "pull", "turn", "twist"],
    "describing things": ["good", "bad", "beautiful", "ugly", "clean", "dirty", "new", "old", "young", "ancient", "modern", "early", "late", "fast", "slow", "hard", "soft", "heavy", "light", "strong", "weak", "thick", "thin", "wide", "narrow", "deep", "shallow", "high", "low", "tall", "short", "long", "round", "square", "flat", "sharp", "blunt", "smooth", "rough", "straight", "crooked", "curved", "empty", "full", "loud", "quiet", "bright", "dark", "colorful", "clear"],
    "places": ["city", "town", "village", "countryside", "street", "road", "highway", "bridge", "tunnel", "building", "house", "apartment", "castle", "palace", "tower", "church", "temple", "mosque", "hospital", "clinic", "pharmacy", "police station", "fire station", "post office", "bank", "school", "university", "library", "museum", "gallery", "theater", "cinema", "restaurant", "cafe", "bar", "bakery", "supermarket", "market", "mall", "shop", "store", "factory", "office", "hotel", "park", "garden", "zoo", "stadium", "airport", "station"],
    "people": ["family", "parent", "mother", "father", "child", "son", "daughter", "brother", "sister", "grandparent", "grandmother", "grandfather", "grandchild", "grandson", "granddaughter", "uncle", "aunt", "nephew", "niece", "cousin", "husband", "wife", "partner", "friend", "enemy", "neighbor", "colleague", "boss", "employee", "student", "teacher", "doctor", "nurse", "police officer", "firefighter", "soldier", "artist", "musician", "writer", "actor", "singer", "dancer", "athlete", "scientist", "engineer", "mechanic", "farmer", "chef", "waiter", "customer"],
    "sports": ["soccer", "basketball", "baseball", "football", "tennis", "volleyball", "golf", "rugby", "cricket", "hockey", "ice hockey", "table tennis", "badminton", "boxing", "wrestling", "martial arts", "karate", "judo", "taekwondo", "swimming", "diving", "surfing", "sailing", "rowing", "cycling", "running", "marathon", "sprinting", "jumping", "throwing", "weightlifting", "gymnastics", "skiing", "snowboarding", "skating", "ice skating", "roller skating", "skateboarding", "archery", "fencing", "equestrian", "horse racing", "motor racing", "billiards", "snooker", "darts", "bowling", "chess", "poker", "e-sports"],
    "transport": ["car", "taxi", "bus", "coach", "minibus", "van", "truck", "lorry", "motorcycle", "scooter", "moped", "bicycle", "tricycle", "unicycle", "skateboard", "roller skates", "train", "subway", "metro", "underground", "tram", "trolleybus", "monorail", "cable car", "airplane", "aeroplane", "helicopter", "glider", "hot air balloon", "blimp", "spaceship", "rocket", "satellite", "boat", "ship", "ferry", "yacht", "speedboat", "sailboat", "canoe", "kayak", "raft", "submarine", "hovercraft", "tractor", "bulldozer", "excavator", "crane", "forklift", "ambulance"],
    "Nature & Environment": ["sun", "moon", "star", "planet", "sky", "cloud", "rain", "snow", "wind", "storm", "lightning", "thunder", "fog", "ice", "fire", "water", "ocean", "sea", "lake", "river", "stream", "waterfall", "beach", "sand", "island", "mountain", "hill", "valley", "cave", "rock", "stone", "soil", "earth", "ground", "grass", "flower", "tree", "leaf", "branch", "root", "forest", "wood", "jungle", "desert", "spring", "summer", "autumn", "winter", "weather", "climate"],
    "Professions": ["accountant", "actor", "actress", "architect", "artist", "astronaut", "baker", "banker", "barber", "bartender", "builder", "butcher", "carpenter", "cashier", "chef", "cleaner", "clerk", "dentist", "designer", "doctor", "driver", "electrician", "engineer", "farmer", "firefighter", "flight attendant", "florist", "guard", "hairdresser", "journalist", "judge", "lawyer", "librarian", "mechanic", "musician", "nurse", "painter", "pharmacist", "photographer", "pilot", "plumber", "police officer", "politician", "programmer", "receptionist", "scientist", "soldier", "teacher", "veterinarian", "waiter"],
    "Clothing & Accessories": ["shirt", "t-shirt", "blouse", "sweater", "jumper", "cardigan", "hoodie", "jacket", "coat", "raincoat", "suit", "vest", "tie", "bowtie", "dress", "skirt", "pants", "trousers", "jeans", "shorts", "underwear", "panties", "bra", "socks", "stockings", "tights", "shoes", "boots", "sneakers", "trainers", "sandals", "slippers", "heels", "hat", "cap", "beanie", "scarf", "gloves", "mittens", "belt", "glasses", "sunglasses", "watch", "bracelet", "necklace", "ring", "earrings", "bag", "purse", "backpack"],
    "Technology & Electronics": ["computer", "laptop", "tablet", "smartphone", "cell phone", "telephone", "smartwatch", "television", "radio", "stereo", "speaker", "headphones", "earbuds", "microphone", "camera", "video camera", "webcam", "projector", "printer", "scanner", "photocopier", "fax machine", "keyboard", "mouse", "monitor", "screen", "router", "modem", "hard drive", "flash drive", "USB drive", "CD", "DVD", "battery", "charger", "cable", "wire", "plug", "socket", "adapter", "drone", "robot", "calculator", "game console", "controller", "joystick", "virtual reality", "smart home", "thermostat", "alarm"],
    "Musical Instruments": ["piano", "keyboard", "synthesizer", "organ", "accordion", "guitar", "electric guitar", "bass guitar", "acoustic guitar", "ukulele", "banjo", "mandolin", "harp", "violin", "viola", "cello", "double bass", "flute", "piccolo", "clarinet", "oboe", "bassoon", "saxophone", "trumpet", "trombone", "french horn", "tuba", "drums", "drum kit", "snare drum", "bass drum", "cymbals", "hi-hat", "tambourine", "maracas", "castanets", "triangle", "xylophone", "marimba", "glockenspiel", "timpani", "bongo", "conga", "djembe", "didgeridoo", "bagpipes", "harmonica", "kazoo", "recorder", "lute"],
    "Health & Medicine": ["hospital", "clinic", "pharmacy", "drugstore", "ambulance", "stretcher", "wheelchair", "crutches", "bandage", "plaster", "cast", "syringe", "needle", "thermometer", "stethoscope", "scalpel", "medicine", "pill", "tablet", "capsule", "syrup", "ointment", "cream", "drops", "vaccine", "injection", "prescription", "blood", "pulse", "blood pressure", "fever", "cough", "sneeze", "pain", "ache", "headache", "stomachache", "toothache", "injury", "wound", "cut", "bruise", "burn", "infection", "disease", "illness", "sickness", "health", "healthy", "sick"]
}

category_meta = {
    "animals": ("CategoryAnimals.png", "2"),
    "everyday objects": ("CategoryObjects.png", "1"),
    "in the home": ("CategoryInHome.png", "3"),
    "food": ("CategoryFood.png", "5"),
    "personal belongings": ("CategoryPersonal.png", "3"),
    "verbs": ("CategoryVerbs.png", "0"),
    "describing things": ("CategoryAdj.png", "7"),
    "places": ("CategoryPlaces.png", "6"),
    "people": ("CategoryPeople.png", "2"),
    "sports": ("CategorySports.png", "6"),
    "transport": ("CategoryTransport.png", "6"),
    "Nature & Environment": ("CategoryNature.png", "8"),
    "Professions": ("CategoryProfessions.png", "8"),
    "Clothing & Accessories": ("CategoryClothing.png", "8"),
    "Technology & Electronics": ("CategoryTech.png", "8"),
    "Musical Instruments": ("CategoryMusic.png", "8"),
    "Health & Medicine": ("CategoryHealth.png", "8")
}

langs = ['fr', 'nl', 'de', 'it', 'es', 'ru', 'ko', 'zh-CN', 'ja']

csv_file = "assets/memolingo/data/words_list_full.csv"

def translate_batch(words, dest_lang):
    max_retries = 3
    for attempt in range(max_retries):
        try:
            translator = GoogleTranslator(source='en', target=dest_lang)
            return translator.translate_batch(words)
        except Exception as e:
            print(f"Error translating to {dest_lang}: {e}, retrying {attempt+1}/{max_retries}...", flush=True)
            time.sleep(2)
    return [""] * len(words)

def sanitize(word):
    if word is None:
        return ""
    return str(word).strip().replace('\\r', '')

# We append to CSV row by row as soon as a category is done to prevent data loss.
for category, words in categories.items():
    print(f"Translating category: {category}", flush=True)
    cat_image, level = category_meta[category]
    
    translations_by_lang = {}
    for lang in langs:
        print(f"  -> Translating to {lang}", flush=True)
        translated_list = translate_batch(words, lang)
        
        if len(translated_list) < len(words):
            translated_list.extend([""] * (len(words) - len(translated_list)))
        elif len(translated_list) > len(words):
            translated_list = translated_list[:len(words)]
            
        translations_by_lang[lang] = [sanitize(w) for w in translated_list]
        time.sleep(1)
        
    rows_to_append = []
    for i, word in enumerate(words):
        filename = f"{word.replace(' ', '_').lower()}.jpg"
        row = [
            category,
            cat_image,
            level,
            filename,
            word,
            translations_by_lang.get('fr', [""] * len(words))[i],
            translations_by_lang.get('nl', [""] * len(words))[i],
            translations_by_lang.get('de', [""] * len(words))[i],
            translations_by_lang.get('it', [""] * len(words))[i],
            translations_by_lang.get('es', [""] * len(words))[i],
            translations_by_lang.get('ru', [""] * len(words))[i],
            translations_by_lang.get('ko', [""] * len(words))[i],
            translations_by_lang.get('zh-CN', [""] * len(words))[i],
            translations_by_lang.get('ja', [""] * len(words))[i],
        ]
        rows_to_append.append(row)

    with open(csv_file, 'a', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for row in rows_to_append:
            writer.writerow(row)
    print(f"  [+] Saved {category} to CSV.", flush=True)

print("Successfully generated and appended 850 new words with translations!", flush=True)
