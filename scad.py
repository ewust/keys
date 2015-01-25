#!/usr/bin/python

import cv2
import sys

f = open('./generic-key.scad', 'r')
generic_scad = f.read()
f.close()

img = cv2.imread(sys.argv[1], 0)

# radius of 12.2 mm circle was ~134px
# (another was 11.7mm), let's call it 12mm
# so 11.15px/mm

#29 wide, 90 px tall (0.3222)

#8.19 measured tall
#2.37 measured wide


FMT = '''       translate([0, pixel(%d)-pixel(1)/2, pixel(%d)-pixel(%d)/2]) cube([blade_length, pixel(1.05), pixel(%d)]);\n'''

channels = ''
for y in xrange(len(img)):
    state = 'OUT'  # white/out of keyway
    last_black_to_white_change = 0
    for x in xrange(len(img[y])):
        if img[y][x] < 127:
            if img[y][x-1] > 127:
            	channels += (FMT % (len(img) - y, ((x - last_black_to_white_change)/2)+last_black_to_white_change, x - last_black_to_white_change, x - last_black_to_white_change))
        if img[y][x] > 127:
            if img[y][x-1] < 127:
                last_black_to_white_change = x-1
        if x + 1 == len(img[y]):
        		if(img[y][x] > 127):
        			channels += (FMT % (len(img) - y, ((x+1 - last_black_to_white_change)/2)+last_black_to_white_change, x +1 - last_black_to_white_change, x +1 - last_black_to_white_change))            



print generic_scad.replace('###CHANNELS###', channels)
