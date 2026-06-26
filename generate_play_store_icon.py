"""
Generate a 512x512 Play Store icon for 11+ Vocabulary app
Requirements: pip install pillow requests
"""

from PIL import Image, ImageDraw, ImageFont
import os
import sys

def download_font():
    """Download a free font if no system fonts are available"""
    try:
        import requests
        font_url = "https://github.com/google/fonts/raw/main/ofl/inter/Inter%5Bslnt%2Cwght%5D.ttf"
        font_path = "Inter-Bold.ttf"

        if not os.path.exists(font_path):
            print("Downloading Inter font...")
            response = requests.get(font_url)
            with open(font_path, 'wb') as f:
                f.write(response.content)
            print("✓ Font downloaded")
        return font_path
    except Exception as e:
        print(f"Could not download font: {e}")
        return None

def find_system_font():
    """Try to find a suitable system font"""
    font_paths = [
        # macOS
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Bold.ttf",
        # Windows
        "C:\\Windows\\Fonts\\arialbd.ttf",
        "C:\\Windows\\Fonts\\arial.ttf",
        "C:\\Windows\\Fonts\\calibrib.ttf",
        # Linux
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
    ]

    for path in font_paths:
        if os.path.exists(path):
            print(f"✓ Found system font: {path}")
            return path

    return None

def create_play_store_icon():
    """Generate the Play Store icon"""
    print("=" * 50)
    print("Play Store Icon Generator")
    print("=" * 50)

    # Play Store icon specifications
    size = 512

    # Create image with solid blue background (no transparency)
    bg_color = (37, 99, 235)  # #2563EB
    image = Image.new('RGB', (size, size), bg_color)
    draw = ImageDraw.Draw(image)

    # Try to load a font
    font_large = None
    font_small = None

    # First try system fonts
    font_path = find_system_font()

    # If no system font, try to download one
    if not font_path:
        print("No system font found. Attempting to download...")
        font_path = download_font()

    # Load the font
    try:
        if font_path:
            font_large = ImageFont.truetype(font_path, 200)
            font_small = ImageFont.truetype(font_path, 60)
            print(f"✓ Loaded fonts successfully")
        else:
            raise Exception("No font available")
    except Exception as e:
        print(f"⚠ Warning: Could not load custom font ({e})")
        print("  Using basic font. Icon will still work but may look simpler.")
        # Use a more reliable fallback
        try:
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()
        except:
            # Ultimate fallback - draw without specifying font
            font_large = None
            font_small = None

    # Draw "11+" text
    main_text = "11+"

    if font_large:
        bbox = draw.textbbox((0, 0), main_text, font=font_large)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        x = (size - text_width) // 2
        y = (size - text_height) // 2 - 40

        # Draw solid shadow (no alpha channel issues)
        shadow_offset = 6
        draw.text((x + shadow_offset, y + shadow_offset), main_text, 
                  fill=(20, 50, 150), font=font_large)  # Dark blue shadow
        draw.text((x, y), main_text, fill=(255, 255, 255), font=font_large)

        # Draw "VOCABULARY" text
        subtitle = "VOCABULARY"
        bbox_sub = draw.textbbox((0, 0), subtitle, font=font_small)
        sub_width = bbox_sub[2] - bbox_sub[0]
        x_sub = (size - sub_width) // 2
        y_sub = y + text_height + 20
        draw.text((x_sub, y_sub), subtitle, fill=(255, 255, 255), font=font_small)
    else:
        # Fallback simple text
        draw.text((150, 200), main_text, fill=(255, 255, 255))
        draw.text((120, 300), "VOCABULARY", fill=(255, 255, 255))

    # Save the icon
    output_path = 'play_store_icon_512x512.png'
    image.save(output_path, 'PNG')

    # Verify the file
    file_size = os.path.getsize(output_path)

    print("=" * 50)
    print("✓ SUCCESS!")
    print("=" * 50)
    print(f"Icon saved: {output_path}")
    print(f"Size: {size}x{size} pixels")
    print(f"File size: {file_size:,} bytes")
    print(f"Format: PNG (no transparency)")
    print()
    print("Next steps:")
    print("1. Check the icon looks good")
    print("2. Upload to Google Play Console:")
    print("   Store presence → Main store listing → App icon")
    print("=" * 50)

    return output_path

if __name__ == "__main__":
    try:
        create_play_store_icon()
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        print(f"\nFull error details:")
        import traceback
        traceback.print_exc()
        sys.exit(1)
