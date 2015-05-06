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
parser.add_argument('--no_arg', '-na', default=False, type=bool, 
					help='disable argument checking (default: False)')
parser.add_argument('--optimize', '-opt', default=False, type=bool, 
					help='enable y direction optimization (default: False)')
args = parser.parse_args()
args.overhangs = True
#START ARG CHECKING
if(args.no_arg == False):
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
		max = 0
		region_label = -1
		region_image = []
		for region in measure.regionprops(labels, intensity_image=None, cache=True):
			if region.area > max:
				max = region.area
				region_label = region.label
				region_image = region.filled_image
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
FMT = ''' translate([pixel(%d), pixel(%d), 0]) cube([pixel(%d), pixel(%d), blade_length]);\n'''
channels = ''
length_of_white_segment = 0
last_black_pixel_x_position = 0
channel_data = []
num_elems = 0
if (args.overhangs == False):
	for y in range(0, len(cv_image)):
		first_wall_found = False
		for x in range(0, len(cv_image[y])):
			if(cv_image[y][x] < 127 and x + 1 < len(cv_image[y]) 
				and cv_image[y][x+1] > 127 and first_wall_found == False):
				last_black_pixel_x_position = x
				first_wall_found = True
			if(cv_image[y][x] and x == 0  and first_wall_found == False):
				last_black_pixel_x_position = 0
				first_wall_found = True
			if ((cv_image[y][x] > 127 and x + 1 < len(cv_image[y]) and cv_image[y][x+1] < 127) or
				(cv_image[y][x] > 127 and x + 1 == len(cv_image[y]))):
				length_of_white_segment = x - last_black_pixel_x_position	
				channel_data.append([last_black_pixel_x_position, y, length_of_white_segment, 1])
				num_elems += 1
				if(args.optimize == False):
					channels += (FMT % (last_black_pixel_x_position, y, length_of_white_segment, 1))
if (args.overhangs == True):
	for y in range(0, len(cv_image)):
		for x in range(0, len(cv_image[y])):
			if(cv_image[y][x] < 127 and x + 1 < len(cv_image[y]) and cv_image[y][x+1] > 127):
				last_black_pixel_x_position = x
			if(cv_image[y][x] and x == 0):
				last_black_pixel_x_position = 0
			if((cv_image[y][x] > 127 and x + 1 < len(cv_image[y]) and cv_image[y][x+1] < 127) or
				(cv_image[y][x] > 127 and x + 1 == len(cv_image[y]))):
				length_of_white_segment = x - last_black_pixel_x_position
				channel_data.append([last_black_pixel_x_position, y, length_of_white_segment, 1])
				num_elems += 1
				if(args.optimize == False):
					channels += (FMT % (last_black_pixel_x_position, y, length_of_white_segment, 1))
if(args.optimize == True):
	i = 0;
	for x in range(0, num_elems-1):
		if(channel_data[i][1] >= len(cv_image)):
			break
		counter = 1
		if(i + 1 < num_elems):
			if((channel_data[i][0] != channel_data[i + 1][0]) or 
				(channel_data[i][2] != channel_data[i + 1][2])):
				channels += (FMT % (channel_data[i][0], channel_data[i][1], channel_data[i][2], counter))
			else:
				for j in range(1, len(cv_image) - i):
					if((channel_data[i][0] == channel_data[i + j][0]) and 
					(channel_data[i][2] == channel_data[i + j][2])):
						counter += 1
					else:
						channels += (FMT % (channel_data[i][0], channel_data[i][1], channel_data[i][2], counter))
						i = i + j - 1
						break
		else:
			break
		i += 1
print generic_scad.replace('###CHANNELS###', channels)
