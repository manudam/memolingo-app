#!/usr/bin/env python3
"""
Test script to verify iPad landscape overlay positioning
"""

from PIL import Image, ImageDraw
import os

# Test with one of your iPad screenshots
input_file = "/Users/manueldambrine/Desktop/Simulator Screenshot - iPad Air 11-inch (M3) - 2025-11-18 at 21.12.21.png"
output_file = "/Users/manueldambrine/Desktop/test_overlay_debug.png"

# Load image
img = Image.open(input_file)
width, height = img.size

print(f"Image size: {width}x{height}")
print(f"Orientation: {'Landscape' if width > height else 'Portrait'}")

# Expected App Store size
target_width = 2388
target_height = 1668

# Resize to App Store dimensions
img = img.resize((target_width, target_height), Image.Resampling.LANCZOS)
print(f"Resized to: {img.size}")

# Convert to RGBA
if img.mode != 'RGBA':
    img = img.convert('RGBA')

# Create overlay
overlay = Image.new('RGBA', (target_width, target_height), (0, 0, 0, 0))
draw = ImageDraw.Draw(overlay)

# Right-side overlay (40% of width)
overlay_width = int(target_width * 0.40)
gradient_x = target_width - overlay_width

print(f"\nOverlay calculations:")
print(f"  Overlay width: {overlay_width}px (40% of {target_width})")
print(f"  Gradient starts at X: {gradient_x}px")
print(f"  Overlay covers: {gradient_x}px to {target_width}px")
print(f"  App content visible: 0px to {gradient_x}px (60% of screen)")

# Draw a simple colored rectangle to show overlay position
draw.rectangle([(gradient_x, 0), (target_width, target_height)],
               fill=(255, 0, 0, 100))  # Red with transparency

# Draw markers
draw.line([(gradient_x, 0), (gradient_x, target_height)], fill=(0, 255, 0, 255),
          width=5)  # Green line at overlay start
draw.text((gradient_x + 50, 100), "OVERLAY STARTS HERE", fill=(255, 255, 255, 255))
draw.text((50, 100), "APP CONTENT (60%)", fill=(0, 255, 0, 255))

# Composite
result = Image.alpha_composite(img, overlay)

# Convert to RGB for saving
if result.mode == 'RGBA':
    rgb_img = Image.new('RGB', result.size, (255, 255, 255))
    rgb_img.paste(result, mask=result.split()[3])
    result = rgb_img

# Save
result.save(output_file, 'PNG')
print(f"\nTest image saved to: {output_file}")
print("This shows where the overlay should appear (red area on right 40%)")
