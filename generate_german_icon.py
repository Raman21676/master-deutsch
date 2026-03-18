#!/usr/bin/env python3
from PIL import Image, ImageDraw

def create_german_flag_icon(size):
    """Create a German flag icon with rounded corners"""
    # Create image with transparency
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Calculate corner radius
    radius = int(size * 0.2)
    
    # Create rounded rectangle mask
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size-1, size-1], radius=radius, fill=255)
    
    # Create flag image
    flag = Image.new('RGBA', (size, size))
    flag_draw = ImageDraw.Draw(flag)
    
    stripe_height = size // 3
    
    # Black stripe (top)
    flag_draw.rectangle([0, 0, size-1, stripe_height-1], fill=(0, 0, 0, 255))
    # Red stripe (middle)
    flag_draw.rectangle([0, stripe_height, size-1, stripe_height*2-1], fill=(255, 0, 0, 255))
    # Gold stripe (bottom)
    flag_draw.rectangle([0, stripe_height*2, size-1, size-1], fill=(255, 206, 0, 255))
    
    # Apply rounded corners
    flag.putalpha(mask)
    
    return flag

def main():
    # Icon sizes for Android
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    base_path = 'android/app/src/main/res'
    
    for folder, size in sizes.items():
        icon = create_german_flag_icon(size)
        filepath = f'{base_path}/{folder}/ic_launcher.png'
        icon.save(filepath, 'PNG')
        print(f'Generated {folder}/ic_launcher.png ({size}x{size})')
    
    print('\nAll German flag launcher icons generated!')

if __name__ == '__main__':
    main()
