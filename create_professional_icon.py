#!/usr/bin/env python3
"""
Generate a professional app icon for 11+ Vocabulary Master
Uses a modern, clean design with educational theme
"""

from PIL import Image, ImageDraw, ImageFont
import math


def create_app_icon(size=1024):
    """Create a professional app icon with gradient background and clean typography"""

    # Create image with transparent background initially
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Create rounded square background with gradient effect
    corner_radius = size // 5  # 20% radius for modern look

    # Draw gradient background (blue gradient)
    for y in range(size):
        # Calculate color based on position
        progress = y / size
        # From bright blue to darker blue
        r = int(37 + (30 - 37) * progress)  # 37 -> 30 (hex 25 -> 1E)
        g = int(99 + (64 - 99) * progress)  # 99 -> 64 (hex 63 -> 40)
        b = int(235 + (175 - 235) * progress)  # 235 -> 175 (hex EB -> AF)

        # Draw horizontal line with this color
        draw.rectangle([(0, y), (size, y + 1)], fill=(r, g, b, 255))

    # Create rounded corners by drawing a mask
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)

    # Apply mask to create rounded corners
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, (0, 0))
    output.putalpha(mask)

    draw = ImageDraw.Draw(output)

    # Add a subtle inner shadow/border effect
    border_width = max(2, size // 256)
    for i in range(border_width):
        alpha = int(30 * (1 - i / border_width))
        draw.rounded_rectangle(
            [(i, i), (size - i - 1, size - i - 1)],
            corner_radius - i,
            outline=(255, 255, 255, alpha),
            width=1
        )

    # Draw elegant "11+" text with modern styling
    try:
        # Try to use a system font
        font_size_main = size // 3
        font_size_plus = size // 4

        # For macOS, try SF Pro or Helvetica
        font_paths = [
            "/System/Library/Fonts/SFNS.ttf",  # SF Pro on newer macOS
            "/System/Library/Fonts/SFNSDisplay.ttf",
            "/System/Library/Fonts/Helvetica.ttc",
            "/Library/Fonts/Arial Bold.ttf",
        ]

        font_main = None
        for font_path in font_paths:
            try:
                font_main = ImageFont.truetype(font_path, font_size_main)
                font_plus = ImageFont.truetype(font_path, font_size_plus)
                break
            except:
                continue

        if font_main is None:
            # Fallback to default font
            font_main = ImageFont.load_default()
            font_plus = ImageFont.load_default()
    except:
        font_main = ImageFont.load_default()
        font_plus = ImageFont.load_default()

    # Draw "11" and "+" with careful positioning
    text_11 = "11"
    text_plus = "+"

    # Get text dimensions
    bbox_11 = draw.textbbox((0, 0), text_11, font=font_main)
    width_11 = bbox_11[2] - bbox_11[0]
    height_11 = bbox_11[3] - bbox_11[1]

    bbox_plus = draw.textbbox((0, 0), text_plus, font=font_plus)
    width_plus = bbox_plus[2] - bbox_plus[0]
    height_plus = bbox_plus[3] - bbox_plus[1]

    # Calculate total width and center position
    spacing = size // 40
    total_width = width_11 + spacing + width_plus

    # Position text slightly above center for visual balance
    x_start = (size - total_width) // 2
    y_position = (size - height_11) // 2 - size // 20

    # Draw shadow for depth (subtle)
    shadow_offset = max(2, size // 200)
    shadow_color = (0, 0, 0, 60)

    draw.text(
        (x_start + shadow_offset, y_position + shadow_offset),
        text_11,
        fill=shadow_color,
        font=font_main
    )

    # Draw main "11" text in white
    draw.text(
        (x_start, y_position),
        text_11,
        fill=(255, 255, 255, 255),
        font=font_main
    )

    # Draw "+" with slight offset
    x_plus = x_start + width_11 + spacing
    y_plus = y_position + (height_11 - height_plus) // 3  # Align to top-ish

    draw.text(
        (x_plus + shadow_offset, y_plus + shadow_offset),
        text_plus,
        fill=shadow_color,
        font=font_plus
    )

    draw.text(
        (x_plus, y_plus),
        text_plus,
        fill=(255, 255, 255, 255),
        font=font_plus
    )

    # Add small "VOCAB" text below (optional, subtle)
    font_size_small = size // 16
    try:
        font_small = None
        for font_path in font_paths:
            try:
                font_small = ImageFont.truetype(font_path, font_size_small)
                break
            except:
                continue
        if font_small is None:
            font_small = ImageFont.load_default()
    except:
        font_small = ImageFont.load_default()

    vocab_text = "VOCABULARY"
    bbox_vocab = draw.textbbox((0, 0), vocab_text, font=font_small)
    width_vocab = bbox_vocab[2] - bbox_vocab[0]

    x_vocab = (size - width_vocab) // 2
    y_vocab = y_position + height_11 + size // 12

    # Draw with slight transparency for subtlety
    draw.text(
        (x_vocab, y_vocab),
        vocab_text,
        fill=(255, 255, 255, 180),
        font=font_small
    )

    return output


def main():
    """Generate app icon at standard size"""
    print("Generating professional app icon...")

    # Create 1024x1024 icon (standard size for both platforms)
    icon = create_app_icon(1024)

    # Save as PNG
    output_path = "assets/app-icon-professional.png"
    icon.save(output_path, "PNG", quality=100)
    print(f"✓ Created {output_path}")

    # Also create a 1728x1728 version (adaptive icon size)
    icon_large = create_app_icon(1728)
    output_path_large = "assets/app-icon-professional-1728.png"
    icon_large.save(output_path_large, "PNG", quality=100)
    print(f"✓ Created {output_path_large}")

    print("\nIcon generation complete!")
    print("Run: flutter pub run flutter_launcher_icons to apply the new icon")


if __name__ == "__main__":
    main()
