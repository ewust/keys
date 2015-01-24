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

whitepxs = 0

FMT = '''       translate([0, pixel(%d), pixel(%d)]) cube([blade_length, pixel(1), pixel(1)]);\n'''

channels = ''
for y in xrange(len(img)):
    state = 'OUT'  # white/out of keyway
    for x in xrange(len(img[y])):


#        if img[y][x] < 127:
#            # this is in the keyway
#            if state == 'OUT':
#                # create a difference cube for this row
#
#        else:
#            # this is out of the keyway'''
#

        if img[y][x] > 127:
            # out of keyway
            whitepxs += 1

            channels += (FMT % (len(img)-y, x))



print generic_scad.replace('###CHANNELS###', channels)


