"""
Resize app-icon-professional-1728.png to 512x512 for Google Play Store
Requirements: pip install pillow
"""

from PIL import Image
import os

def resize_icon_for_playstore():
    """Resize the 1728x1728 icon to 512x512"""

    input_file = 'assets/app-icon-professional-1728.png'
    output_file = 'play_store_icon_512x512.png'
    target_size = (512, 512)

    print("=" * 50)
    print("Icon Resizer for Google Play Store")
    print("=" * 50)

    # Check if input file exists
    if not os.path.exists(input_file):
        print(f"❌ ERROR: Cannot find {input_file}")
        print(f"\nMake sure the file is in the current directory:")
        print(f"  {os.getcwd()}")
        return None

    try:
        # Open the image
        print(f"Opening {input_file}...")
        img = Image.open(input_file)

        # Get original size
        original_size = img.size
        print(f"✓ Original size: {original_size[0]}×{original_size[1]} pixels")

        # Resize with high-quality resampling
        print(f"Resizing to {target_size[0]}×{target_size[1]}...")
        img_resized = img.resize(target_size, Image.Resampling.LANCZOS)

        # Convert to RGB if it has transparency (Play Store requires no transparency)
        if img_resized.mode == 'RGBA':
            print("Converting RGBA to RGB (removing transparency)...")
            # Create white background
            rgb_img = Image.new('RGB', target_size, (255, 255, 255))
            rgb_img.paste(img_resized, mask=img_resized.split()[3])  # Use alpha as mask
            img_resized = rgb_img
        elif img_resized.mode != 'RGB':
            print(f"Converting {img_resized.mode} to RGB...")
            img_resized = img_resized.convert('RGB')

        # Save the resized icon
        img_resized.save(output_file, 'PNG', quality=100, optimize=True)

        # Verify the output
        file_size = os.path.getsize(output_file)

        print("=" * 50)
        print("✓ SUCCESS!")
        print("=" * 50)
        print(f"Icon saved: {output_file}")
        print(f"Size: {target_size[0]}×{target_size[1]} pixels")
        print(f"File size: {file_size:,} bytes")
        print(f"Format: PNG (no transparency)")
        print()
        print("Next steps:")
        print("1. Check the icon looks good")
        print("2. Upload to Google Play Console:")
        print("   Store presence → Main store listing → App icon")
        print("=" * 50)

        return output_file

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == "__main__":
    resize_icon_for_playstore()
