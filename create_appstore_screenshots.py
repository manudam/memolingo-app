#!/usr/bin/env python3
"""
Enhanced Marketing Screenshot Generator for App Store
Creates professional screenshots with text overlays for 11+ Vocabulary Master app
Supports multiple device sizes and advanced styling
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import os
import glob

# App Store screenshot dimensions
DEVICE_SIZES = {
    # iPhone sizes (Portrait)
    'iphone_67': {'width': 1290, 'height': 2796, 'name': '6.7" Display (iPhone 16 Pro Max)',
                  'orientation': 'portrait'},
    'iphone_65': {'width': 1284, 'height': 2778, 'name': '6.5" Display (iPhone 14 Plus)',
                  'orientation': 'portrait'},
    'iphone_61': {'width': 1179, 'height': 2556, 'name': '6.1" Display (iPhone 16)',
                  'orientation': 'portrait'},
    'iphone_55': {'width': 1242, 'height': 2208, 'name': '5.5" Display (iPhone 8 Plus)',
                  'orientation': 'portrait'},

    # iPad sizes (Landscape - 2nd generation and later)
    'ipad_129': {'width': 2048, 'height': 2732, 'name': '12.9" iPad Pro (Portrait)',
                 'orientation': 'portrait'},
    'ipad_129_landscape': {'width': 2732, 'height': 2048, 'name': '12.9" iPad Pro (Landscape)',
                           'orientation': 'landscape'},
    'ipad_11': {'width': 1668, 'height': 2388, 'name': '11" iPad Pro (Portrait)',
                'orientation': 'portrait'},
    'ipad_11_landscape': {'width': 2388, 'height': 1668, 'name': '11" iPad Pro (Landscape)',
                          'orientation': 'landscape'},
    'ipad_105': {'width': 1668, 'height': 2224, 'name': '10.5" iPad Pro (Portrait)',
                 'orientation': 'portrait'},
    'ipad_105_landscape': {'width': 2224, 'height': 1668, 'name': '10.5" iPad Pro (Landscape)',
                           'orientation': 'landscape'},
}

# Color scheme
PRIMARY_BLUE = (37, 99, 235)  # #2563EB - matches your app theme
ACCENT_BLUE = (59, 130, 246)  # #3B82F6
DARK_OVERLAY = (20, 20, 30)
WHITE = (255, 255, 255)
BLACK = (40, 40, 40)

# Screenshot configurations with marketing messages
SCREENSHOTS = [
    {
        "title": "Master 450+ Words",
        "subtitle": "Essential 11+ Exam Vocabulary",
        "position": "bottom",
        "badge": "📚 5 Complete Sets",
        "description": "library_screen"
    },
    {
        "title": "Interactive Practice",
        "subtitle": "Audio Pronunciation & Definitions",
        "position": "bottom",
        "badge": "🔊 TTS Enabled",
        "description": "practice_session"
    },
    {
        "title": "Track Progress",
        "subtitle": "See Your Mastery Grow",
        "position": "bottom",
        "badge": "📈 Real-time Stats",
        "description": "test_results"
    },
    {
        "title": "Learn from Mistakes",
        "subtitle": "Detailed Answer Reviews",
        "position": "bottom",
        "badge": "✓ Every Answer Explained",
        "description": "review_screen"
    },
    {
        "title": "Monitor Journey",
        "subtitle": "Stats & Achievements",
        "position": "bottom",
        "badge": "🏆 Track Mastery",
        "description": "stats_dashboard"
    }
]

# iPad landscape-specific configurations (optimized for wider screens)
IPAD_SCREENSHOTS = [
    {
        "title": "Complete Vocabulary Library",
        "subtitle": "450+ Essential 11+ Exam Words Across 5 Sets",
        "position": "bottom",  # Text at bottom for landscape
        "badge": "📚 Full Curriculum",
        "description": "library_screen"
    },
    {
        "title": "Engaging Practice Sessions",
        "subtitle": "Interactive Learning with Audio Support",
        "position": "bottom",
        "badge": "🔊 Audio Enabled",
        "description": "practice_session"
    },
    {
        "title": "Real-Time Progress Tracking",
        "subtitle": "Monitor Mastery & Achievement",
        "position": "bottom",
        "badge": "📊 Detailed Analytics",
        "description": "test_results"
    },
    {
        "title": "Comprehensive Review System",
        "subtitle": "Learn from Every Question",
        "position": "bottom",
        "badge": "✓ Full Explanations",
        "description": "review_screen"
    },
    {
        "title": "Advanced Statistics Dashboard",
        "subtitle": "Track Your Learning Journey",
        "position": "bottom",
        "badge": "🏆 Achievement System",
        "description": "stats_dashboard"
    }
]


def create_gradient_overlay(width, height, alpha=200):
    """Create a beautiful gradient overlay"""
    gradient = Image.new('RGBA', (width, height))
    draw = ImageDraw.Draw(gradient)

    for i in range(height):
        ratio = i / height
        # Smooth gradient from dark to darker
        opacity = int(alpha * (0.7 + 0.3 * ratio))
        r = int(DARK_OVERLAY[0] * (1 + 0.2 * ratio))
        g = int(DARK_OVERLAY[1] * (1 + 0.2 * ratio))
        b = int(DARK_OVERLAY[2] * (1 + 0.2 * ratio))
        draw.line([(0, i), (width, i)], fill=(r, g, b, opacity))

    return gradient


def get_font(size, bold=False):
    """Get system font with fallback"""
    font_options = [
        "/System/Library/Fonts/SFCompact.ttf",
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf"
    ]

    for font_path in font_options:
        try:
            return ImageFont.truetype(font_path, size)
        except:
            continue

    # Fallback to default
    return ImageFont.load_default()


def add_professional_overlay(image, config, device_size):
    """Add professional marketing overlay with modern design - bottom overlay for all devices"""
    width = device_size['width']
    height = device_size['height']
    orientation = device_size.get('orientation', 'portrait')

    # Convert to RGBA if needed
    if image.mode != 'RGBA':
        image = image.convert('RGBA')

    # Create overlay layer
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    # Bottom overlay for all devices (iPhone & iPad, portrait & landscape)
    overlay_height = int(height * 0.30)  # 30% of screen height for landscape, 35% for portrait
    if orientation == 'portrait':
        overlay_height = int(height * 0.35)

    gradient_y = height - overlay_height
    gradient = create_gradient_overlay(width, overlay_height, alpha=220)
    overlay.paste(gradient, (0, gradient_y), gradient)

    # Get fonts - use width-based sizing for consistent look
    title_font = get_font(int(width * 0.050), bold=True)  # Responsive sizing
    subtitle_font = get_font(int(width * 0.035))
    badge_font = get_font(int(width * 0.025))

    # Calculate text positions
    margin = int(width * 0.05)  # 5% margin from edges
    text_x = margin
    title_y = gradient_y + int(overlay_height * 0.30)
    subtitle_y = title_y + int(overlay_height * 0.35)
    badge_y = gradient_y + int(overlay_height * 0.12)

    # Draw badge if present
    if 'badge' in config and config['badge']:
        badge_text = config['badge']

        # Calculate badge dimensions
        bbox = draw.textbbox((0, 0), badge_text, font=badge_font)
        badge_padding_w = int(width * 0.02)
        badge_padding_h = int(height * 0.008)
        badge_width = bbox[2] - bbox[0] + badge_padding_w * 2
        badge_height = bbox[3] - bbox[1] + badge_padding_h * 2

        # Draw badge background
        badge_x = margin
        badge_rect = [
            (badge_x, badge_y),
            (badge_x + badge_width, badge_y + badge_height)
        ]
        radius = int(width * 0.015)
        draw.rounded_rectangle(badge_rect, radius=radius,
                               fill=PRIMARY_BLUE + (255,))

        # Draw badge text
        badge_text_x = badge_x + badge_padding_w
        badge_text_y = badge_y + badge_padding_h - int(badge_padding_h * 0.2)
        draw.text((badge_text_x, badge_text_y), badge_text, font=badge_font, fill=WHITE)

    # Draw title with shadow
    title = config['title']
    # Shadow
    draw.text((text_x + 3, title_y + 3), title, font=title_font,
              fill=(0, 0, 0, 180))
    # Main text
    draw.text((text_x, title_y), title, font=title_font, fill=WHITE)

    # Draw subtitle with shadow
    subtitle = config['subtitle']
    # Shadow
    draw.text((text_x + 2, subtitle_y + 2), subtitle, font=subtitle_font,
              fill=(0, 0, 0, 150))
    # Main text
    draw.text((text_x, subtitle_y), subtitle, font=subtitle_font,
              fill=(220, 220, 220))

    # Composite overlay onto original image
    result = Image.alpha_composite(image, overlay)

    return result


def add_device_frame(image, device_type='iphone_67'):
    """Add a subtle shadow effect to simulate device frame"""
    width, height = image.size

    # Create a slightly larger image for shadow
    shadow_margin = 20
    framed = Image.new('RGB',
                       (width + shadow_margin * 2, height + shadow_margin * 2),
                       (245, 245, 245))

    # Add shadow
    shadow = Image.new('RGBA', (width, height), (0, 0, 0, 30))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=10))

    # Paste shadow and image
    framed.paste(shadow, (shadow_margin + 5, shadow_margin + 5))
    if image.mode == 'RGBA':
        framed.paste(image, (shadow_margin, shadow_margin), image)
    else:
        framed.paste(image, (shadow_margin, shadow_margin))

    return framed


def process_screenshots(input_dir, output_dir, device_type='iphone_67', add_frames=False):
    """Process all screenshots in the input directory"""

    device_size = DEVICE_SIZES[device_type]
    width = device_size['width']
    height = device_size['height']
    orientation = device_size.get('orientation', 'portrait')

    # Select appropriate screenshot configurations
    is_ipad = 'ipad' in device_type
    is_landscape = orientation == 'landscape'
    screenshot_configs = IPAD_SCREENSHOTS if (is_ipad and is_landscape) else SCREENSHOTS

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)

    print("\n" + "=" * 70)
    print("📸 Professional App Store Screenshot Generator")
    print("=" * 70)
    print(f"🎯 Target Device: {device_size['name']}")
    print(f"📐 Resolution: {width}x{height}px")
    print(f"📱 Orientation: {orientation.capitalize()}")
    print(f"📁 Input: {input_dir}")
    print(f"📁 Output: {output_dir}")
    print("=" * 70 + "\n")

    # Find screenshot files
    screenshot_patterns = ['*.png', '*.PNG', '*.jpg', '*.JPG', '*.jpeg']
    screenshot_files = []
    for pattern in screenshot_patterns:
        screenshot_files.extend(glob.glob(os.path.join(input_dir, pattern)))

    # Filter simulator screenshots
    screenshot_files = [f for f in screenshot_files
                        if 'Simulator Screenshot' in f or 'screenshot' in f.lower()]
    screenshot_files = sorted(screenshot_files)

    if not screenshot_files:
        print("❌ No screenshots found!")
        print("\n📸 To capture screenshots:")
        device_name = "iPad Pro 12.9-inch" if is_ipad else "iPhone 16 Pro Max"
        print(f"   1. Launch app on {device_name} simulator")
        print("   2. Navigate to each screen:")
        print("      • Library (with vocabulary packs)")
        print("      • Practice session (with question)")
        print("      • Test results (completion screen)")
        print("      • Review screen (with answers)")
        print("      • Stats dashboard")
        print("   3. Press ⌘+S to save screenshot")
        print("   4. Run this script again\n")
        return False

    print(f"✅ Found {len(screenshot_files)} screenshot(s)\n")

    # Process each screenshot
    success_count = 0
    for idx, filepath in enumerate(screenshot_files[:len(screenshot_configs)]):
        config = screenshot_configs[idx]
        filename = os.path.basename(filepath)
        output_filename = f"{idx + 1}_{config['description']}.png"
        output_path = os.path.join(output_dir, output_filename)

        print(f"📱 Processing #{idx + 1}: {filename}")
        print(f"   Title: '{config['title']}'")
        print(f"   Subtitle: '{config['subtitle']}'")

        try:
            # Open image
            img = Image.open(filepath)
            original_size = img.size

            # Resize if needed
            if img.size != (width, height):
                print(f"   📐 Resizing from {original_size} to {width}x{height}")
                img = img.resize((width, height), Image.Resampling.LANCZOS)

            # Add professional overlay
            img = add_professional_overlay(img, config, device_size)

            # Optional: Add device frame
            if add_frames:
                img = add_device_frame(img, device_type)

            # Convert back to RGB for saving
            if img.mode == 'RGBA':
                # Create white background
                rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                rgb_img.paste(img, mask=img.split()[3] if len(img.split()) > 3 else None)
                img = rgb_img

            # Save with high quality
            img.save(output_path, 'PNG', optimize=True, quality=95)

            # Get file size
            file_size = os.path.getsize(output_path) / 1024  # KB
            print(f"   ✅ Saved: {output_filename} ({file_size:.0f} KB)")
            success_count += 1

        except Exception as e:
            print(f"   ❌ Error: {str(e)}")

        print()

    # Summary
    print("=" * 70)
    print(f"✨ Success! Generated {success_count}/{len(screenshot_files)} screenshots")
    print(f"📁 Location: {output_dir}")
    print("=" * 70)

    if success_count > 0:
        print("\n📤 Next Steps:")
        print("   1. Open Finder and navigate to the output folder")
        print("   2. Review all screenshots")
        print("   3. Go to App Store Connect")
        print("   4. Upload to: App Store > Screenshots > 6.7\" Display")
        print("   5. Arrange in order: Library → Practice → Results → Review → Stats\n")

        print("💡 Tips:")
        print("   • Keep screenshots in order to tell a story")
        print("   • First screenshot is most important (Library)")
        print("   • Apple recommends 3-5 screenshots minimum")
        print("   • You can add captions in App Store Connect\n")

    return success_count > 0


def main():
    import sys

    # Default paths
    desktop = os.path.expanduser("~/Desktop")
    input_dir = desktop
    output_dir = os.path.join(desktop, "AppStore_Screenshots")
    device_type = 'iphone_67'  # Default to largest iPhone
    add_frames = False

    # Parse command line arguments
    if len(sys.argv) > 1:
        if sys.argv[1] in ['--help', '-h']:
            print(
                "\nUsage: python3 create_appstore_screenshots.py [input_dir] [output_dir] [device_type]")
            print("\nDevice types:")
            for key, value in DEVICE_SIZES.items():
                print(f"  {key}: {value['name']}")
            print("\nExample:")
            print(
                "  python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/Screenshots iphone_67")
            print()
            return
        input_dir = sys.argv[1]

    if len(sys.argv) > 2:
        output_dir = sys.argv[2]

    if len(sys.argv) > 3:
        device_type = sys.argv[3]
        if device_type not in DEVICE_SIZES:
            print(f"❌ Invalid device type: {device_type}")
            print(f"Available: {', '.join(DEVICE_SIZES.keys())}")
            return

    # Process screenshots
    process_screenshots(input_dir, output_dir, device_type, add_frames)


if __name__ == "__main__":
    main()
