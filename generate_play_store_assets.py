#!/usr/bin/env python3
"""
Generate Google Play Store graphics assets from app icon
This script helps create the required feature graphic and other promotional materials
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os


def create_feature_graphic(icon_path, output_path):
    """
    Create a 1024x500 feature graphic for Google Play Store
    """
    # Create canvas
    width, height = 1024, 500

    # Create gradient background (matching app theme)
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)

    # Create gradient from app's blue theme
    for y in range(height):
        # Gradient from #2563EB to #1565C0
        ratio = y / height
        r = int(37 + (21 - 37) * ratio)
        g = int(99 + (101 - 99) * ratio)
        b = int(235 + (192 - 235) * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # Load and resize icon
    try:
        icon = Image.open(icon_path)
        # Make icon smaller for feature graphic
        icon_size = 280
        icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)

        # Add subtle shadow to icon
        shadow = Image.new('RGBA', (icon_size + 20, icon_size + 20), (0, 0, 0, 0))
        shadow_draw = ImageDraw.Draw(shadow)
        shadow_draw.ellipse([0, 0, icon_size + 20, icon_size + 20],
                            fill=(0, 0, 0, 60))
        shadow = shadow.filter(ImageFilter.GaussianBlur(10))

        # Position icon on left side
        icon_x = 60
        icon_y = (height - icon_size) // 2

        # Paste shadow and icon
        img.paste(shadow, (icon_x - 10, icon_y - 10), shadow)
        if icon.mode == 'RGBA':
            img.paste(icon, (icon_x, icon_y), icon)
        else:
            img.paste(icon, (icon_x, icon_y))
    except Exception as e:
        print(f"Warning: Could not load icon: {e}")

    # Add text
    try:
        # Try to use a nice font, fall back to default if not available
        try:
            title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 72)
            subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        except:
            try:
                title_font = ImageFont.truetype("/Library/Fonts/Arial.ttf", 72)
                subtitle_font = ImageFont.truetype("/Library/Fonts/Arial.ttf", 36)
            except:
                title_font = ImageFont.load_default()
                subtitle_font = ImageFont.load_default()

        # Draw text on right side
        text_x = 400
        title_y = 160
        subtitle_y = 250

        # Title
        draw.text((text_x, title_y), "11+ Vocabulary",
                  fill='white', font=title_font)
        draw.text((text_x, title_y + 80), "Master",
                  fill='white', font=title_font)

        # Subtitle
        draw.text((text_x, subtitle_y + 80), "Master 500+ Words for Success",
                  fill=(255, 255, 255, 230), font=subtitle_font)
    except Exception as e:
        print(f"Warning: Could not add text: {e}")

    # Save
    img.save(output_path, 'PNG', quality=95)
    print(f"✓ Created feature graphic: {output_path}")
    print(f"  Size: {width}x{height}")


def create_high_res_icon(icon_path, output_path):
    """
    Create 512x512 high-res icon for Play Store
    """
    try:
        icon = Image.open(icon_path)
        icon = icon.resize((512, 512), Image.Resampling.LANCZOS)
        icon.save(output_path, 'PNG', quality=95)
        print(f"✓ Created high-res icon: {output_path}")
        print(f"  Size: 512x512")
    except Exception as e:
        print(f"✗ Could not create high-res icon: {e}")


def main():
    print("=" * 60)
    print("Google Play Store Graphics Generator")
    print("=" * 60)
    print()

    # Paths
    project_root = os.path.dirname(os.path.abspath(__file__))
    icon_path = os.path.join(project_root, 'assets', 'chicken-icon-natural.png')
    output_dir = os.path.join(project_root, 'play_store_assets')

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)

    # Check if icon exists
    if not os.path.exists(icon_path):
        print(f"✗ Icon not found: {icon_path}")
        print("  Please ensure chicken-icon-natural.png exists in assets/")
        return

    print(f"Using icon: {icon_path}")
    print(f"Output directory: {output_dir}")
    print()

    # Generate assets
    print("Generating Play Store assets...")
    print()

    # 1. Feature Graphic (1024x500) - REQUIRED
    feature_graphic_path = os.path.join(output_dir, 'feature_graphic_1024x500.png')
    create_feature_graphic(icon_path, feature_graphic_path)

    # 2. High-res Icon (512x512) - REQUIRED
    high_res_icon_path = os.path.join(output_dir, 'high_res_icon_512x512.png')
    create_high_res_icon(icon_path, high_res_icon_path)

    print()
    print("=" * 60)
    print("✓ Asset generation complete!")
    print("=" * 60)
    print()
    print("Generated files:")
    print(f"  1. {feature_graphic_path}")
    print(f"  2. {high_res_icon_path}")
    print()
    print("Next steps:")
    print("  1. Review the generated graphics")
    print("  2. Edit if needed (optional)")
    print("  3. Upload to Google Play Console > Store listing")
    print()
    print("Still needed:")
    print("  - Screenshots (phone: 1080x1920, tablet: 1200x1920)")
    print("    → Use create_play_store_screenshots.py or capture manually")
    print("    → Minimum 2 screenshots required")
    print()
    print("For screenshots:")
    print("  - Run app on emulator")
    print("  - Capture screens showing:")
    print("    • Vocabulary list view")
    print("    • Practice/flashcard mode")
    print("    • Statistics screen")
    print("    • Settings page")
    print()


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()
