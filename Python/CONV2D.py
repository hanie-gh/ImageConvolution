## This module aim to have a picture as input and write the equivalent grayscale pixel in file.
## the output will be used in FPGA TestBench for testing the implemented filter in VHDL
from PIL import Image
import numpy as np
path = "FOX.png"  # Your image path
img  = Image.open(path)
row, column = img.size

########################################################################################################################
## Making the size of the picture 5 times smaller.
########################################################################################################################
width  = int(row/5)
heigth = int(column/5)
resized_img = img.resize((width, heigth))
resized_img.save("FOX_resized.png")
pix  = resized_img.load()
pixel_new = [0 for x in range(heigth*width)]
pixel_2D = [[0 for x in range(width)] for y in range(heigth)]
for y in range(heigth):
    for x in range(width):
        pixel = pix[x, y]
        gray  = 0.2989 * pixel[0] + 0.5870 * pixel[1] + 0.1140 * pixel[2]
        gray  = int(gray)
        pixel_2D[y][x] = gray
        pixel_new[x+y*width] = gray

origin_file  = open('origin_file.txt', 'w')
for item in pixel_new:
    origin_file.write('{:02x}'.format(item))
    origin_file.write('\n')
origin_file.close()

img_new = Image.new('L', resized_img.size)
img_new.putdata(pixel_new)
img_new.save('FOX_GRY.png')
########################################################################################################################
## Applying the filter on image and save the result for comparison.
########################################################################################################################
pixel_conv = [0 for x in range(heigth*width)]
## You can change your kernel here!
kernel = [1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1]
kernel_size = 5
# kernel_div = kernel_size*kernel_size
## You can change your kernel divider here!
kernel_div = 1
for y in range(kernel_size-1):
    for x in range(width):
        pixel_conv[x+y*width] = 0
for y in range(heigth):
    for x in range(kernel_size-1):
        pixel_conv[x+y*width] = 0

kernel_re = kernel[::-1]
for y in range(kernel_size-1, heigth):
    for x in range(kernel_size-1, width):
        sum_kernel = 0
        for z1 in range(kernel_size):
            for z2 in range(kernel_size):
                sum_kernel += kernel_re[z2+(z1*kernel_size)] * pixel_new[x-z2 +(y-z1)*width]
        pixel_conv[x + y * width] = int(sum_kernel/kernel_div)
img_new = Image.new('L', resized_img.size)
img_new.putdata(pixel_conv)
img_new.save('FOX_GRY_CONV2D.png')

groundTruth_file  = open('ground_file.txt', 'w')
for item in pixel_conv:
    groundTruth_file.write('{:04x}'.format(item))
    groundTruth_file.write('\n')
groundTruth_file.close()
