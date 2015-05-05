import cv2
from skimage import measure
from skimage import img_as_ubyte
import argparse
import sys
import os.path
parser = argparse.ArgumentParser(description='3D Key Blank Model Generation Utility.')
parser.add_argument('input', default = 'input.pgm', 
					help='the file to read from (default: input.pgm)')
parser.add_argument('--output', '-o', default='output.pgm', 
					help='the file to output to (default: output.pgm)')
parser.add_argument('--threshold', '-t', default=-1, type=float, 
					help='the threshold value to use when filtering the image (default: automatically generated)')
parser.add_argument('--min_threshold', default=25, type=int,
					help='set the minimum threshold value for the automated threshold detector (default: 25)')
parser.add_argument('--max_threshold', default=80, type=int,
					help='set the maximum threshold value for the automated threshold detector (default: 80)')
parser.add_argument('--step_size_threshold', default=5, type=int,
					help='set the step size for the automated threshold detector (default: 5)')
parser.add_argument('--print_threshold', '-pt', default=False, type=bool,
					help='print the automatically selected threshold value (default: False)')
parser.add_argument('--overhangs', '-oh', default=True, type=bool, 
					help='set if the image has overhangs (default: True)')
parser.add_argument('--generic_scad', '-gs', default='generic-key.scad', 
					help='set the location of the generic-key.scad file (default: ./generic-key.scad)')
args = parser.parse_args()
#START ARG CHECKING
if((args.threshold > 255) | ((args.threshold < 0) and (args.threshold != -1)) | 
	(args.min_threshold > 255) | (args.min_threshold < 0) | 
	(args.max_threshold > 255) | (args.max_threshold < 0) | 
	(args.step_size_threshold > (args.max_threshold - args.min_threshold)) | 
	(args.min_threshold > args.max_threshold)):
	print 'Error: threshold value out of range'
	sys.exit(1)
if(os.path.isfile(args.input) == False):
	print 'Error: input file does not exist'
	sys.exit(1)
if(os.path.isfile(args.output) == True):
	print 'Warning: output file exists'
	print 'Would you like to overwrite? (y/n)'
	input_data = raw_input()
	if((input_data == 'y') | (input_data == 'yes')) == False:
		sys.exit(1)
if(os.path.isfile(args.generic_scad) == False):
	print 'Error: generic_scad file does not exist'
	sys.exit(1)
#END ARG CHECKING
f = open(args.generic_scad, 'r')
generic_scad = f.read()
f.close()
img = cv2.imread(args.input, 0)
new_img = cv2.imread(args.input, 0)
first_run = True
last_area = 0
if(args.threshold == -1):
	for threshold in range(args.min_threshold, args.max_threshold, args.step_size_threshold):
		ret,new_img = cv2.threshold(img,threshold,255,cv2.THRESH_BINARY)
		labels = measure.label(new_img)
		x_array.append(threshold)
		max = 0
		region_label = -1
		region_image = []
		for region in measure.regionprops(labels, intensity_image=None, cache=True):
			if region.area > max:
				max = region.area
				region_label = region.label
				region_image = region.filled_image
		y_array.append(len(region_image)*len(region_image[1]))
		if(first_run):
			last_area = len(region_image)*len(region_image[1])
			first_run = False
		else:
			if(len(region_image)*len(region_image[1]) > 2*last_area or
				len(region_image)*len(region_image[1]) < last_area/2):
				break
		cv_image = img_as_ubyte(region_image)
		cv2.imwrite(args.output, cv_image)
		last_area = len(region_image)*len(region_image[1])
		last_threshold = threshold
	if(args.print_threshold):
		print 'Automatically detected threshold value:'
		print last_threshold
else:
	ret,new_img = cv2.threshold(img,args.threshold,255,cv2.THRESH_BINARY)
	labels = measure.label(new_img)
	max = 0
	region_label = -1
	region_image = []
	for region in measure.regionprops(labels, intensity_image=None, cache=True):
		if region.area > max:
			max = region.area
			region_label = region.label
			region_image = region.filled_image

	cv_image = img_as_ubyte(region_image)
	cv2.imwrite(args.output, cv_image)
if (args.overhangs == True):
	for y in range(0, len(cv_image)):
		for x in range(0, len(cv_image[y])):
			if(img[y][x] > 127 and x-1 >= 0 and img[y][x-1] < 127):
						last_black_pixel_x_position = x - 1
			if(img[y][x] < 127 and x-1 >= 0 and img[y][x-1] > 127):	
						length_of_white_segment = (x - 1)- last_black_pixel_x_position
						end_point = x - 1 
						#SOME CHANNEL MATH
else:
	for y in range(0, len(cv_image)):
		for x in range(0, len(cv_image[y])):
			if(img[y][x] > 127 and x-1 >= 0 and img[y][x-1] < 127):
						last_black_pixel_x_position = x - 1
		for x in range(len(cv_image[y]), 0):
			if(img[y][x] > 127 and x + 1 <= len(cv_image[y]) and img[y][x+1] < 127):
						length_of_white_segment = x - last_black_pixel_x_position
						end_point = x
		#SOME CHANNEL MATH
