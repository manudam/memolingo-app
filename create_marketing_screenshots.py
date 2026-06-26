#!/usr/bin/env python3
"""
Marketing Screenshot Generator for App Store
Creates professional screenshots with text overlays for 11+ Vocabulary Master app
"""
#!/usr/bin/env python3
"""
Marketing Screenshot Processor for Google Play Store
Adds professional overlays to raw app screenshots.
Place raw screenshots in play_store_assets/raw_screenshots/ and run this script.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import os
import glob


# Screenshot configurations with titles and descriptions
SCREENSHOT_CONFIGS = [
    {
        "title": "Master 500+ Words",
        "subtitle": "5 Complete Vocabulary Sets",
        "description": "vocabulary_list",
        "badge": "5 SETS",
        "badge_color": (76, 175, 80)  # Green
    },
    {
        "title": "Interactive Practice",
        "subtitle": "Learn with Audio Pronunciation",
        "description": "practice_mode",
        "badge": "AUDIO",
        "badge_color": (33, 150, 243)  # Blue
    },
    {
        "title": "Word Details",
        "subtitle": "Meanings, Examples & Synonyms",
        "description": "word_details",
        "badge": "COMPLETE",
        "badge_color": (156, 39, 176)  # Purple
    },
    {
        "title": "Track Progress",
        "subtitle": "Monitor Your Learning Journey",
        "description": "statistics",
        "badge": "STATS",
        "badge_color": (255, 152, 0)  # Orange
    },
    {
        "title": "Daily Streaks",
        "subtitle": "Build Your Learning Habit",
        "description": "streaks",
        "badge": "REWARDS",
        "badge_color": (244, 67, 54)  # Red
    },
]


def get_font(size, bold=False):
    """Get the best available font"""
    font_paths = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/SFCompact.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "C:\\Windows\\Fonts\\arialbd.ttf" if bold else "C:\\Windows\\Fonts\\arial.ttf",
    ]

    for font_path in font_paths:
        try:
            return ImageFont.truetype(font_path, size)
        except:
            continue

    return ImageFont.load_default()


def create_gradient_overlay(width, height, alpha_start=50, alpha_end=230):
    """Create a dark gradient overlay for text visibility"""
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    for i in range(height):
        alpha = int(alpha_start + (alpha_end - alpha_start) * (i / height))
        draw.line([(0, i), (width, i)], fill=(18, 24, 32, alpha))

    return overlay


def add_professional_overlay(screenshot, config, device_type='phone'):
    """Add professional overlay to screenshot"""
    width, height = screenshot.size

    # Ensure RGBA mode
    if screenshot.mode != 'RGBA':
        screenshot = screenshot.convert('RGBA')

    # Calculate dimensions based on device type
    if device_type == 'phone':
        overlay_height = int(height * 0.32)  # Bottom 32%
        margin = int(width * 0.06)
        title_size = int(width * 0.065)
        subtitle_size = int(width * 0.040)
        badge_size = int(width * 0.032)
    else:  # tablet
        overlay_height = int(height * 0.28)
        margin = int(width * 0.05)
        title_size = int(width * 0.055)
        subtitle_size = int(width * 0.035)
        badge_size = int(width * 0.028)

    # Create gradient overlay
    gradient = create_gradient_overlay(width, overlay_height)
    overlay_y = height - overlay_height
    screenshot.paste(gradient, (0, overlay_y), gradient)

    # Draw on the screenshot
    draw = ImageDraw.Draw(screenshot)

    # Fonts
    title_font = get_font(title_size, bold=True)
    subtitle_font = get_font(subtitle_size)
    badge_font = get_font(badge_size, bold=True)

    # Badge
    badge_text = config['badge']
    badge_color = config['badge_color']

    # Calculate badge dimensions
    bbox = draw.textbbox((0, 0), badge_text, font=badge_font)
    badge_padding = int(width * 0.018)
    badge_width = bbox[2] - bbox[0] + badge_padding * 2
    badge_height = bbox[3] - bbox[1] + badge_padding * 1.5

    badge_x = margin
    badge_y = overlay_y + int(overlay_height * 0.12)

    # Draw badge
    draw.rounded_rectangle(
        [(badge_x, badge_y), (badge_x + badge_width, badge_y + badge_height)],
        radius=int(badge_padding * 0.7),
        fill=badge_color + (255,)
    )

    # Badge text
    text_x = badge_x + badge_padding
    text_y = badge_y + int(badge_padding * 0.7)
    draw.text((text_x, text_y), badge_text, font=badge_font, fill=(255, 255, 255))

    # Title with shadow
    title_y = overlay_y + int(overlay_height * 0.40)

    # Shadow
    draw.text((margin + 3, title_y + 3), config['title'], 
              font=title_font, fill=(0, 0, 0, 180))
    # Title
    draw.text((margin, title_y), config['title'], 
              font=title_font, fill=(255, 255, 255))

    # Subtitle with shadow
    subtitle_y = title_y + int(overlay_height * 0.30)

    # Shadow
    draw.text((margin + 2, subtitle_y + 2), config['subtitle'],
              font=subtitle_font, fill=(0, 0, 0, 160))
    # Subtitle
    draw.text((margin, subtitle_y), config['subtitle'],
              font=subtitle_font, fill=(230, 230, 240))

    return screenshot


def process_screenshots(input_dir, output_dir, device_type='phone'):
    """Process all screenshots in the input directory"""

    # Find all image files
    image_extensions = ['*.png', '*.jpg', '*.jpeg', '*.PNG', '*.JPG', '*.JPEG']
    image_files = []
    for ext in image_extensions:
        image_files.extend(glob.glob(os.path.join(input_dir, ext)))

    image_files = sorted(image_files)

    if not image_files:
        print(f"✗ No screenshots found in {input_dir}")
        print(f"  Please capture app screenshots first!")
        return 0

    print(f"Found {len(image_files)} screenshot(s) to process")
    print()

    processed = 0
    for idx, image_path in enumerate(image_files):
        if idx >= len(SCREENSHOT_CONFIGS):
            print(f"⚠ Warning: More screenshots than configs. Skipping {os.path.basename(image_path)}")
            continue

        config = SCREENSHOT_CONFIGS[idx]

        try:
            # Load screenshot
            screenshot = Image.open(image_path)

            # Resize if needed (to target dimensions)
            if device_type == 'phone' and screenshot.size != (1080, 1920):
                print(f"  Resizing {os.path.basename(image_path)} to 1080x1920")
                screenshot = screenshot.resize((1080, 1920), Image.Resampling.LANCZOS)
            elif device_type == 'tablet' and screenshot.size[0] != 1200:
                # Resize to tablet dimensions
                if screenshot.size[0] > screenshot.size[1]:  # Landscape
                    screenshot = screenshot.resize((1920, 1200), Image.Resampling.LANCZOS)
                else:  # Portrait
                    screenshot = screenshot.resize((1200, 1920), Image.Resampling.LANCZOS)

            # Add overlay
            processed_screenshot = add_professional_overlay(screenshot, config, device_type)

            # Save
            output_filename = f"{idx + 1:02d}_{config['description']}.png"
            output_path = os.path.join(output_dir, output_filename)
            processed_screenshot.save(output_path, 'PNG', optimize=True)

            file_size = os.path.getsize(output_path) / 1024
            print(f"  ✓ {output_filename} ({file_size:.1f} KB)")
            processed += 1

        except Exception as e:
            print(f"  ✗ Error processing {os.path.basename(image_path)}: {e}")

    return processed


def main():
    print("=" * 70)
    print("  MARKETING SCREENSHOT PROCESSOR")
    print("=" * 70)
    print()

    # Setup paths
    project_root = os.path.dirname(os.path.abspath(__file__))
    assets_dir = os.path.join(project_root, 'play_store_assets')

    # Input and output directories
    phone_input = os.path.join(assets_dir, 'raw_screenshots', 'phone')
    phone_output = os.path.join(assets_dir, 'phone_screenshots')

    tablet_input = os.path.join(assets_dir, 'raw_screenshots', 'tablet')
    tablet_output = os.path.join(assets_dir, 'tablet_screenshots')

    # Create directories
    os.makedirs(phone_input, exist_ok=True)
    os.makedirs(phone_output, exist_ok=True)
    os.makedirs(tablet_input, exist_ok=True)
    os.makedirs(tablet_output, exist_ok=True)

    total_processed = 0

    # Process phone screenshots
    print("PROCESSING PHONE SCREENSHOTS")
    print("-" * 70)
    phone_count = process_screenshots(phone_input, phone_output, 'phone')
    total_processed += phone_count
    print()

    # Process tablet screenshots
    print("PROCESSING TABLET SCREENSHOTS")
    print("-" * 70)
    tablet_count = process_screenshots(tablet_input, tablet_output, 'tablet')
    total_processed += tablet_count
    print()

    # Summary
    print("=" * 70)
    print(f"  PROCESSING COMPLETE: {total_processed} screenshot(s) processed")
    print("=" * 70)
    print()

    if phone_count == 0:
        print("⚠ WARNING: No phone screenshots processed!")
        print("  Phone screenshots are REQUIRED for Play Store submission.")
        print()
        print("  To capture screenshots:")
        print("    1. Run your app: flutter run")
        print("    2. Navigate to different screens")
        print("    3. Take screenshots")
        print(f"    4. Place them in: {phone_input}")
        print("    5. Run this script again")
        print()
    else:
        print(f"✓ Phone screenshots: {phone_count} (minimum 2 required)")
        print(f"  Location: {phone_output}")
        print()

    if tablet_count > 0:
        print(f"✓ Tablet screenshots: {tablet_count} (optional)")
        print(f"  Location: {tablet_output}")
        print()

    if total_processed > 0:
        print("NEXT STEPS:")
        print("  1. Review processed screenshots")
        print("  2. Upload to Google Play Console:")
        print("     • Store presence > Main store listing > Screenshots")
        print("  3. Complete store listing information")
        print("  4. Submit for review!")
        print()

    return 0 if total_processed > 0 else 1


if __name__ == '__main__':
    try:
        import sys
        sys.exit(main())
    except Exception as e:
        print(f"\n✗ ERROR: {e}")
        import traceback
        traceback.print_exc()
        import sys
        sys.exit(1)
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# App Store screenshot dimensions for iPhone 16 Pro Max (6.7")
WIDTH = 1290
HEIGHT = 2796

# Color scheme matching your app
PRIMARY_BLUE = (33, 150, 243)  # #2196F3
DARK_BLUE = (25, 118, 210)  # #1976D2
WHITE = (255, 255, 255)
BLACK = (40, 40, 40)
LIGHT_GRAY = (245, 245, 245)


def create_gradient_overlay(width, height, color1, color2, alpha=180):
    """Create a gradient overlay"""
    gradient = Image.new('RGBA', (width, height), color1 + (0,))
    draw = ImageDraw.Draw(gradient)

    for i in range(height):
        # Calculate color transition
        ratio = i / height
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        draw.line([(0, i), (width, i)], fill=(r, g, b, alpha))

    return gradient


def add_text_overlay(image, title, subtitle, position='bottom'):
    """Add marketing text overlay to screenshot"""
    draw = ImageDraw.Draw(image, 'RGBA')

    # Try to load system fonts, fallback to default
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/SFCompact.ttf", 80)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/SFCompact.ttf", 50)
    except:
        try:
            title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 80)
            subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 50)
        except:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()

    # Create semi-transparent overlay at bottom or top
    overlay_height = 400
    if position == 'bottom':
        overlay_y = HEIGHT - overlay_height
        gradient = create_gradient_overlay(WIDTH, overlay_height, (0, 0, 0), (40, 40, 40), 200)
        image.paste(gradient, (0, overlay_y), gradient)
        text_y_title = overlay_y + 80
        text_y_subtitle = text_y_title + 100
    else:  # top
        gradient = create_gradient_overlay(WIDTH, overlay_height, (40, 40, 40), (0, 0, 0), 200)
        image.paste(gradient, (0, 0), gradient)
        text_y_title = 80
        text_y_subtitle = text_y_title + 100

    # Draw title
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (WIDTH - title_width) // 2

    # Add shadow for better readability
    draw.text((title_x + 3, text_y_title + 3), title, font=title_font, fill=(0, 0, 0, 180))
    draw.text((title_x, text_y_title), title, font=title_font, fill=WHITE)

    # Draw subtitle
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (WIDTH - subtitle_width) // 2

    draw.text((subtitle_x + 2, text_y_subtitle + 2), subtitle, font=subtitle_font,
              fill=(0, 0, 0, 180))
    draw.text((subtitle_x, text_y_subtitle), subtitle, font=subtitle_font, fill=WHITE)

    return image


def create_feature_badge(image, text, x, y):
    """Add a feature badge/tag to the screenshot"""
    draw = ImageDraw.Draw(image, 'RGBA')

    try:
        badge_font = ImageFont.truetype("/System/Library/Fonts/SFCompact.ttf", 40)
    except:
        try:
            badge_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
        except:
            badge_font = ImageFont.load_default()

    # Calculate badge size
    text_bbox = draw.textbbox((0, 0), text, font=badge_font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]

    padding = 20
    badge_width = text_width + padding * 2
    badge_height = text_height + padding * 2

    # Draw rounded rectangle badge
    badge_shape = [(x, y), (x + badge_width, y + badge_height)]
    draw.rounded_rectangle(badge_shape, radius=15, fill=PRIMARY_BLUE + (230,))

    # Draw text
    text_x = x + padding
    text_y = y + padding - 5
    draw.text((text_x, text_y), text, font=badge_font, fill=WHITE)

    return image


# Screenshot configurations
SCREENSHOTS = [
    {
        "title": "Master 450+ Essential",
        "subtitle": "11+ Exam Vocabulary Words",
        "position": "bottom",
        "description": "Library screen showing vocabulary packs"
    },
    {
        "title": "Interactive Practice",
        "subtitle": "with Audio Pronunciation",
        "position": "bottom",
        "description": "Practice session with TTS"
    },
    {
        "title": "Track Your Progress",
        "subtitle": "& Master Every Word",
        "position": "bottom",
        "description": "Test results and completion"
    },
    {
        "title": "Learn from Mistakes",
        "subtitle": "Review Every Answer",
        "position": "bottom",
        "description": "Detailed review screen"
    },
    {
        "title": "Monitor Your Journey",
        "subtitle": "Stats & Achievements",
        "position": "bottom",
        "description": "Stats dashboard"
    }
]


def process_screenshots(input_dir, output_dir):
    """Process all screenshots in the input directory"""

    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    print("🎨 Marketing Screenshot Generator")
    print("=" * 50)

    # Look for screenshot files
    screenshot_files = sorted([f for f in os.listdir(input_dir) if f.endswith('.png')])

    if not screenshot_files:
        print("❌ No PNG screenshots found in", input_dir)
        print("\n📸 Please capture screenshots using:")
        print("   1. Run the app on iPhone 16 simulator")
        print("   2. Navigate to each key screen")
        print("   3. Press ⌘+S to capture")
        print("   4. Screenshots will be saved to Desktop")
        return

    print(f"✅ Found {len(screenshot_files)} screenshots")
    print()

    for idx, filename in enumerate(screenshot_files):
        if idx >= len(SCREENSHOTS):
            print(f"⚠️  Skipping {filename} (no configuration)")
            continue

        config = SCREENSHOTS[idx]
        input_path = os.path.join(input_dir, filename)
        output_filename = f"screenshot_{idx + 1}_{config['description'].replace(' ', '_')}.png"
        output_path = os.path.join(output_dir, output_filename)

        print(f"📱 Processing: {filename}")
        print(f"   Title: {config['title']}")
        print(f"   Subtitle: {config['subtitle']}")

        try:
            # Open screenshot
            img = Image.open(input_path)

            # Resize if needed to match App Store requirements
            if img.size != (WIDTH, HEIGHT):
                print(f"   ⚠️  Resizing from {img.size} to ({WIDTH}, {HEIGHT})")
                img = img.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)

            # Add text overlay
            img = add_text_overlay(img, config['title'], config['subtitle'], config['position'])

            # Save
            img.save(output_path, 'PNG', quality=95)
            print(f"   ✅ Saved: {output_filename}")

        except Exception as e:
            print(f"   ❌ Error: {str(e)}")

        print()

    print("=" * 50)
    print(f"✅ Done! Marketing screenshots saved to: {output_dir}")
    print()
    print("📤 Upload these to App Store Connect:")
    print("   1. Go to App Store Connect")
    print("   2. Select your app > App Store tab")
    print("   3. Scroll to Screenshots section")
    print("   4. Upload the generated PNG files")


if __name__ == "__main__":
    import sys

    # Default paths
    desktop = os.path.expanduser("~/Desktop")
    input_dir = desktop  # Screenshots from simulator save here
    output_dir = os.path.join(desktop, "AppStore_Screenshots")

    # Allow custom paths via command line
    if len(sys.argv) > 1:
        input_dir = sys.argv[1]
    if len(sys.argv) > 2:
        output_dir = sys.argv[2]

    print()
    print("📁 Input directory:  ", input_dir)
    print("📁 Output directory: ", output_dir)
    print()

    process_screenshots(input_dir, output_dir)

    print("\n💡 Tips:")
    print("   • Make sure you captured 5 screenshots in order:")
    print("     1. Library screen")
    print("     2. Practice session")
    print("     3. Test results")
    print("     4. Review screen")
    print("     5. Stats screen")
    print("   • Screenshots should be taken on iPhone 16 simulator")
    print("   • Press ⌘+S in simulator to capture")
