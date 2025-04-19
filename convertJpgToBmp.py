from PIL import Image

def convert_image(input_image_path, output_image_path):
    # Load the image from the path
    image = Image.open(input_image_path)

    # Resize the image to 320x200
    image = image.resize((320, 200), Image.Resampling.LANCZOS)

    # Convert the image to 8-bit color (256 colors)
    image = image.convert('P', palette=Image.ADAPTIVE, colors=256)

    # Save the image as BMP
    image.save(output_image_path, 'BMP')

# Example usage
convert_image('ending.jpg', 'ending.bmp')
