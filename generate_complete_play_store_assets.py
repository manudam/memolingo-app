#!/usr/bin/env python3
"""
Complete Google Play Store Graphics Generator
Creates ALL required graphics for Play Store submission in one go.
Includes feature graphic, high-res icon, and promotional images.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import os
import sys


def create_gradient_background(width, height, color1, color2):
    """Create a vertical gradient background"""
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)

    for y in range(height):
        ratio = y / height
        r = int(color1[0] + (color2[0] - color1[0]) * ratio)
        g = int(color1[1] + (color2[1] - color1[1]) * ratio)
        b = int(color1[2] + (color2[2] - color1[2]) * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    return img


def add_icon_with_shadow(canvas, icon_path, position, size, shadow_offset=15, shadow_opacity=100):
    """Add icon with professional shadow effect"""
    try:
        icon = Image.open(icon_path).convert('RGBA')
        icon = icon.resize((size, size), Image.Resampling.LANCZOS)

        # Create shadow
        shadow_size = size + shadow_offset * 2
        shadow = Image.new('RGBA', (shadow_size, shadow_size), (0, 0, 0, 0))
        shadow_draw = ImageDraw.Draw(shadow)
        shadow_draw.ellipse([0, 0, shadow_size, shadow_size], 
                           fill=(0, 0, 0, shadow_opacity))
        shadow = shadow.filter(ImageFilter.GaussianBlur(shadow_offset))

        # Paste shadow then icon
        shadow_x = position[0] - shadow_offset // 2
        shadow_y = position[1] - shadow_offset // 2
        canvas.paste(shadow, (shadow_x, shadow_y), shadow)
        canvas.paste(icon, position, icon)

        return True
    except Exception as e:
        print(f"Warning: Could not add icon: {e}")
        return False


def get_font(size, bold=False):
    """Get the best available font"""
    font_paths = [
        # macOS fonts
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/SFCompact.ttf", 
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        # Linux fonts
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        # Windows fonts
        "C:\\Windows\\Fonts\\arialbd.ttf" if bold else "C:\\Windows\\Fonts\\arial.ttf",
    ]

    for font_path in font_paths:
        try:
            return ImageFont.truetype(font_path, size)
        except:
            continue

    return ImageFont.load_default()


def create_feature_graphic(icon_path, output_path):
    """
    Create 1024x500 feature graphic (REQUIRED for Play Store)
    This appears at the top of your app's store listing
    """
    print("Creating feature graphic (1024x500)...")

    width, height = 1024, 500

    # Create gradient background
    color1 = (37, 99, 235)   # Blue
    color2 = (21, 101, 192)  # Darker blue
    img = create_gradient_background(width, height, color1, color2)

    # Add subtle pattern overlay
    pattern = Image.new('RGBA', (width, height), (255, 255, 255, 0))
    pattern_draw = ImageDraw.Draw(pattern)
    for i in range(0, width, 40):
        pattern_draw.line([(i, 0), (i, height)], fill=(255, 255, 255, 8), width=1)
    img.paste(pattern, (0, 0), pattern)

    # Add icon
    icon_size = 320
    icon_x = 80
    icon_y = (height - icon_size) // 2
    add_icon_with_shadow(img, icon_path, (icon_x, icon_y), icon_size)

    # Add text
    draw = ImageDraw.Draw(img)
    text_x = 450

    # Main title
    title_font = get_font(80, bold=True)
    title1 = "11+ Vocabulary"
    title2 = "Master"

    draw.text((text_x + 3, 110), title1, fill=(0, 0, 0, 100), font=title_font)
    draw.text((text_x, 107), title1, fill=(255, 255, 255), font=title_font)

    draw.text((text_x + 3, 195), title2, fill=(0, 0, 0, 100), font=title_font)
    draw.text((text_x, 192), title2, fill=(255, 255, 255), font=title_font)

    # Subtitle
    subtitle_font = get_font(38)
    subtitle = "Master 500+ Words for Success"
    draw.text((text_x + 2, 305), subtitle, fill=(0, 0, 0, 80), font=subtitle_font)
    draw.text((text_x, 303), subtitle, fill=(255, 255, 220), font=subtitle_font)

    # Add accent elements
    accent_color = (255, 215, 0, 180)  # Gold
    draw.ellipse([920, 40, 960, 80], fill=accent_color)
    draw.ellipse([950, 420, 990, 460], fill=accent_color)

    img.save(output_path, 'PNG', quality=95, optimize=True)
    file_size = os.path.getsize(output_path) / 1024
    print(f"  ✓ Saved: {output_path} ({file_size:.1f} KB)")
    return True


def create_high_res_icon(icon_path, output_path):
    """
    Create 512x512 high-resolution icon (REQUIRED for Play Store)
    """
    print("\nCreating high-res icon (512x512)...")

    try:
        icon = Image.open(icon_path).convert('RGBA')
        icon = icon.resize((512, 512), Image.Resampling.LANCZOS)
        icon.save(output_path, 'PNG', quality=95, optimize=True)

        file_size = os.path.getsize(output_path) / 1024
        print(f"  ✓ Saved: {output_path} ({file_size:.1f} KB)")
        return True
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False


def create_promo_graphic(icon_path, output_path):
    """
    Create 180x120 promo graphic (OPTIONAL but recommended)
    Used in promotional campaigns
    """
    print("\nCreating promo graphic (180x120)...")

    width, height = 180, 120

    # Create gradient
    color1 = (37, 99, 235)
    color2 = (21, 101, 192)
    img = create_gradient_background(width, height, color1, color2)

    # Add small icon
    icon_size = 80
    icon_x = 10
    icon_y = (height - icon_size) // 2

    try:
        icon = Image.open(icon_path).convert('RGBA')
        icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        img.paste(icon, (icon_x, icon_y), icon)

        # Add text
        draw = ImageDraw.Draw(img)
        font = get_font(16)
        draw.text((100, 45), "11+", fill=(255, 255, 255), font=font)
        draw.text((100, 65), "Vocab", fill=(255, 255, 255), font=font)

        img.save(output_path, 'PNG', quality=95, optimize=True)
        file_size = os.path.getsize(output_path) / 1024
        print(f"  ✓ Saved: {output_path} ({file_size:.1f} KB)")
        return True
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False


def create_tv_banner(icon_path, output_path):
    """
    Create 1280x720 TV banner (OPTIONAL, only if targeting Android TV)
    """
    print("\nCreating TV banner (1280x720)...")

    width, height = 1280, 720

    # Create gradient
    color1 = (37, 99, 235)
    color2 = (21, 101, 192)
    img = create_gradient_background(width, height, color1, color2)

    # Add icon
    icon_size = 400
    icon_x = 100
    icon_y = (height - icon_size) // 2
    add_icon_with_shadow(img, icon_path, (icon_x, icon_y), icon_size)

    # Add text
    draw = ImageDraw.Draw(img)
    text_x = 550

    title_font = get_font(100, bold=True)
    draw.text((text_x + 3, 220), "11+ Vocabulary", fill=(0, 0, 0, 100), font=title_font)
    draw.text((text_x, 217), "11+ Vocabulary", fill=(255, 255, 255), font=title_font)

    subtitle_font = get_font(50)
    draw.text((text_x + 2, 350), "Master 500+ Words", fill=(0, 0, 0, 80), font=subtitle_font)
    draw.text((text_x, 348), "Master 500+ Words", fill=(255, 255, 220), font=subtitle_font)

    img.save(output_path, 'PNG', quality=95, optimize=True)
    file_size = os.path.getsize(output_path) / 1024
    print(f"  ✓ Saved: {output_path} ({file_size:.1f} KB)")
    return True


def create_sample_screenshots_guide(output_dir):
    """
    Create visual guide showing what screenshots to capture
    """
    print("\nCreating screenshot guide...")

    width, height = 1080, 1920  # Phone dimensions
    screenshots_needed = [
        ("1. Vocabulary List", "Show main vocabulary list with sets"),
        ("2. Practice Mode", "Show flashcard or practice screen"),
        ("3. Word Details", "Show detailed word info with examples"),
        ("4. Statistics", "Show progress tracking screen"),
        ("5. Settings", "Show settings with audio options"),
    ]

    for idx, (title, description) in enumerate(screenshots_needed, 1):
        img = Image.new('RGB', (width, height), (240, 240, 245))
        draw = ImageDraw.Draw(img)

        # Title
        title_font = get_font(60, bold=True)
        draw.text((width // 2 - 200, 400), title, fill=(37, 99, 235), font=title_font)

        # Description
        desc_font = get_font(40)
        draw.text((width // 2 - 300, 500), description, fill=(100, 100, 100), font=desc_font)

        # Instructions
        inst_font = get_font(35)
        instructions = [
            "How to capture:",
            "1. Open your app to this screen",
            "2. Take a screenshot",
            "3. Save it with a clear name",
            f"   (e.g., 'screenshot_{idx}_{title.split('.')[1].strip().lower().replace(' ', '_')}.png')"
        ]
        y = 700
        for inst in instructions:
            draw.text((100, y), inst, fill=(80, 80, 80), font=inst_font)
            y += 60

        output_path = os.path.join(output_dir, f"guide_{idx}_{title.split('.')[1].strip().lower().replace(' ', '_')}.png")
        img.save(output_path, 'PNG', optimize=True)

    print(f"  ✓ Created {len(screenshots_needed)} screenshot guide images")


def main():
    print("=" * 70)
    print("  COMPLETE GOOGLE PLAY STORE GRAPHICS GENERATOR")
    print("=" * 70)
    print()

    # Setup paths
    project_root = os.path.dirname(os.path.abspath(__file__))
    icon_path = os.path.join(project_root, 'assets', 'chicken-icon-natural.png')
    output_dir = os.path.join(project_root, 'play_store_assets')

    # Check icon exists
    if not os.path.exists(icon_path):
        print(f"✗ ERROR: Icon not found at {icon_path}")
        print("  Please ensure 'chicken-icon-natural.png' exists in assets/")
        return 1

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)

    print(f"Icon source: {icon_path}")
    print(f"Output directory: {output_dir}")
    print()

    success_count = 0
    total_count = 0

    # Generate required assets
    print("GENERATING REQUIRED ASSETS")
    print("-" * 70)

    # 1. Feature Graphic (REQUIRED)
    total_count += 1
    if create_feature_graphic(icon_path, 
                             os.path.join(output_dir, 'feature_graphic_1024x500.png')):
        success_count += 1

    # 2. High-res Icon (REQUIRED)
    total_count += 1
    if create_high_res_icon(icon_path,
                           os.path.join(output_dir, 'high_res_icon_512x512.png')):
        success_count += 1

    # Generate optional assets
    print("\nGENERATING OPTIONAL ASSETS")
    print("-" * 70)

    # 3. Promo Graphic (OPTIONAL)
    total_count += 1
    if create_promo_graphic(icon_path,
                           os.path.join(output_dir, 'promo_graphic_180x120.png')):
        success_count += 1

    # 4. TV Banner (OPTIONAL - only if targeting Android TV)
    # Uncomment if you want to target Android TV
    # total_count += 1
    # if create_tv_banner(icon_path,
    #                    os.path.join(output_dir, 'tv_banner_1280x720.png')):
    #     success_count += 1

    # Create screenshot guides
    screenshots_guide_dir = os.path.join(output_dir, 'screenshot_guides')
    os.makedirs(screenshots_guide_dir, exist_ok=True)
    create_sample_screenshots_guide(screenshots_guide_dir)

    # Summary
    print("\n" + "=" * 70)
    print(f"  GENERATION COMPLETE: {success_count}/{total_count} assets created")
    print("=" * 70)
    print()

    print("✓ GENERATED FILES:")
    print("  Required:")
    print("    • feature_graphic_1024x500.png")
    print("    • high_res_icon_512x512.png")
    print("  Optional:")
    print("    • promo_graphic_180x120.png")
    print()

    print("⚠ STILL NEEDED: App Screenshots")
    print("-" * 70)
    print("  You MUST capture actual app screenshots:")
    print()
    print("  PHONE (REQUIRED - minimum 2, recommended 4-8):")
    print("    • Size: 1080 x 1920 pixels (portrait)")
    print("    • Capture screens showing:")
    print("      1. Vocabulary list view")
    print("      2. Practice/flashcard mode")
    print("      3. Word details with examples")
    print("      4. Statistics/progress screen")
    print("      5. Settings page (optional)")
    print()
    print("  TABLET (OPTIONAL but recommended):")
    print("    • Size: 1200 x 1920 or 1920 x 1200 pixels")
    print("    • At least 2 screenshots")
    print()
    print("  HOW TO CAPTURE SCREENSHOTS:")
    print("    1. Run your app: flutter run")
    print("    2. Navigate to each screen")
    print("    3. Take screenshot:")
    print("       • Android Emulator: Click camera icon in toolbar")
    print("       • Physical device: Power + Volume Down buttons")
    print("    4. Save screenshots to: play_store_assets/raw_screenshots/")
    print()
    print("  AFTER CAPTURING:")
    print("    Run: python3 create_marketing_screenshots.py")
    print("    This will add professional overlays to your screenshots")
    print()
    print("  Check screenshot_guides/ folder for visual examples")
    print()

    print("NEXT STEPS:")
    print("-" * 70)
    print("  1. Review generated graphics in play_store_assets/")
    print("  2. Capture app screenshots (see guide above)")
    print("  3. Run create_marketing_screenshots.py to enhance screenshots")
    print("  4. Upload all assets to Google Play Console")
    print("  5. Review PLAY_STORE_SUBMISSION_CHECKLIST.md")
    print()

    return 0 if success_count == total_count else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as e:
        print(f"\n✗ ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
