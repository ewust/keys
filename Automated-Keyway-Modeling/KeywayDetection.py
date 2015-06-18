import argparse
import cv2
import exifread
import os.path
import subprocess
import sys
from skimage import measure
from skimage import img_as_ubyte
from skimage.transform import rotate
parser = argparse.ArgumentParser(description='3D Key Blank Model Generation Utility.')
parser.add_argument('input', default = 'input.pgm', 
					help='the file to read from (default: input.pgm)')
parser.add_argument('--output', '-o', default='output.pgm', 
					help='the file to output the image mask to (default: output.pgm)')
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
parser.add_argument('--overhangs', '-oh', default=1, type=int, 
					help='set if the image has overhangs (default: True)')
parser.add_argument('--generic_scad', '-gs', default='Generic-Key.scad', 
					help='set the location of the generic-key.scad file (default: ./generic-key.scad)')
parser.add_argument('--no_arg', '-na', default=False, type=bool, 
					help='disable argument checking (default: False)')
parser.add_argument('--keyway_height', '-kh', default=.320, type=float, 
					help='set the height of the keyway in inches (default: .320")')
parser.add_argument('--blade_length', '-bl', default=1.25, type=float, 
					help='set the length of the key blade in inches (default: 1.25")')
parser.add_argument('--scad_output_file', '-sof', default='output.scad',  
					help='the file to output the OpenSCAD data to (default: output.scad)')
parser.add_argument('--key_cuts', '-kc', nargs='+', default=['0', '0', '0', '0', '0', '0', '0'],  
					help='the cuts to place on the key (default: 0 0 0 0 0 0 0)')
parser.add_argument('--output_stl', '-os', default='output.stl',  
					help='the file to render to (default: output.stl)')
parser.add_argument('--disable_stl_output', '-dso', default=False,  
					help='disable the automatic rendering of the OpenSCAD data (default: False)')
parser.add_argument('--trim', '-tr', default=10, type=int,
					help='scale stuff (default: False)')
args = parser.parse_args()
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

#READ GENERIC SCAD TEMPLATE
print "Reading Generic SCAD Template"
f = open(args.generic_scad, 'r+')
generic_scad = f.read()
f.close()
#END READ GENERIC SCAD TEMPLATE

#THRESHOLDING
img = cv2.imread(args.input, 0)
new_img = cv2.imread(args.input, 0)
exif = open(args.input, 'rb')
exif_data = exifread.process_file(exif, details=False)
try:
        exif_orientation = str(exif_data['Image Orientation'])
except KeyError, e:
#       print "EXIF DATA: NOT FOUND"
        exif_orientation = str("NotRotated A")
#print "EXIF DATA: FOUND"
exif_orientation_array = exif_orientation.split(" ")
threshold_array = []
area_array = []
first_run = True
if(args.threshold == -1):
	print "Determining Optimal Thresholding Value"
	for threshold in range(args.min_threshold, args.max_threshold, args.step_size_threshold):
		ret,new_img = cv2.threshold(img,threshold,255,cv2.THRESH_BINARY)
		labels = measure.label(new_img)
		max = 0
		region_label = -1
		region_image = []
		avg = 0
		for region in measure.regionprops(labels, intensity_image=None, cache=True):
			if region.area > max:
				max = region.area
				region_label = region.label
				region_image = region.filled_image
		counter = 0
		for i in range(0, int(.15*len(region_image))):
			avg += len(region_image[i])
			counter += 1
		if counter != 0:
			avg = avg/counter
		if(first_run):
			last_area = len(region_image)*len(region_image[1])
			first_run = False
		else:
			if(len(region_image)*len(region_image[1]) > 2*last_area or
				len(region_image)*len(region_image[1]) < last_area/2 or
					avg > 1.15 * last_avg):
				break
		counter = 0	
		image = region_image
		threshold_array.append(threshold)
		last_avg = avg
		last_area = len(region_image)*len(region_image[1])
		area_array.append(last_area)
		last_threshold = threshold
	print "Thresholding Image"
	if(args.print_threshold):
		print 'Automatically detected threshold value:'
		print last_threshold
else:
	print "Thresholding Image"
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
	image = region_image
#END THRESHOLDING
#for i in range(0, len(area_array)):
	#print "%s %.23f" % (threshold_array[i], float(area_array[i])/(float(len(new_img)*len(new_img[1]))))


#FIX IMAGE ROTATION AND CONVERT TO OPENCV2 FORMAT
if(exif_orientation_array[0] == "Rotated"):
	if(exif_orientation_array[2] == "CCW"):
		image = rotate(image, -int(exif_orientation_array[1]), resize = True)
	if(exif_orientation_array[2] == "CW"):
		image = rotate(image, int(exif_orientation_array[1]), resize = True)
cv_image = img_as_ubyte(image)
for y in range(int(.8*len(cv_image)), len(cv_image)):
	counter = 0
	for x in range(0, len(cv_image[0])):
		if cv_image[y][x] > 140:
			counter += 1
		if cv_image[y][x] < 140:
			if counter < .1 * len(cv_image[0]) :
				for i in range(x - counter, x):
					cv_image[y][i] = 0
			counter = 0
labels = measure.label(cv_image)
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
#END FIX IMAGE ROTATION AND CONVERT TO OPENCV2 FORMAT

#OPENSCAD CONVERSION
#LENGTH ARE SOMETIMES OVERALLOCATED FOR CUT AWAYS TO PREVENT ARTIFACTS FROM RENDERING PROBLEMS 
FMT = '''translate([pixel(%d), pixel(%d), 0]) cube([pixel(%d), pixel(%d), blade_length]);\n'''
SCALE_FACTOR = '''function pixel(i) = mm(i*%.12f); '''
BLADE_LENGTH = '''blade_length = mm(%f); '''
BLADE_WIDTH = '''blade_width = pixel(%f); '''
TIP_STOP = '''translate([-blade_width/4, .5*pixel(%d), -blade_length - mm(.0001)]) cube([3*blade_width/2, .6*pixel(%d), mm(.065)]); '''
BOW_CONNECTION = ''' cube([pixel(%d), pixel(%d), mm(%f)]); '''
X_LENGTH = '''x_length = pixel(%f); '''
Y_LENGTH = '''y_length = pixel(%f); '''
CONNECTOR_HEIGHT = '''connector_height = pixel(%f); '''
channels = ''
channel_data = []
num_elems = 0

print "Determining Keyway Profile"
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
				channel_data.append([last_black_pixel_x_position, y, length_of_white_segment, 1, -1])
				num_elems += 1
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
				channel_data.append([last_black_pixel_x_position, y, length_of_white_segment, 1, -1])
				num_elems += 1


print "Optimizing Keyway Profile"
channel_data_classifier = 1
for i in range(0, len(channel_data)):
	if(i - 1 >= 0):	
		if((channel_data[i-1][0] == channel_data[i][0]) and
			channel_data[i-1][2] == channel_data[i][2]):
			channel_data[i][4] = channel_data[i-1][4]
		else:
			channel_data[i][4] = channel_data_classifier
			channel_data_classifier += 1
	else:
		channel_data[i][4] = channel_data_classifier
		channel_data_classifier += 1
max_channel = channel_data_classifier
channel_data_classifier = 1
data_stor = [0, 0, 0, 0]
last_index = 0
first_index = 0
first_j = False

print "Converting Keyway Profile Into OpenSCAD" 
for i in range(channel_data_classifier, max_channel):
	counter = 0
	first_j = False
	for j in range(last_index, len(channel_data)):
		if(channel_data[j][4] == i):
			if(first_j == False):
				first_index = j
				first_j = True
			counter += 1
		else:
			last_index = j
			break
	channels += (FMT % (channel_data[first_index][0] + args.trim, channel_data[first_index][1], channel_data[first_index][2] - args.trim*2, counter))

print "Creating .scad File"
generic_scad = generic_scad.replace('###SCALE_FACTOR###', SCALE_FACTOR % (float(args.keyway_height)/float(len(cv_image))))
generic_scad = generic_scad.replace('###CHANNELS###', channels)
generic_scad = generic_scad.replace('###BLADE_LENGTH###', BLADE_LENGTH % (args.blade_length - (7 - len(args.key_cuts))*.15))
generic_scad = generic_scad.replace('###BLADE_WIDTH###', BLADE_WIDTH % (len(cv_image[0]) - 1))
generic_scad = generic_scad.replace('###TIP_STOP###', TIP_STOP % (len(cv_image) - 1, len(cv_image) - 1))
generic_scad = generic_scad.replace('###BOW_CONNECTION###', BOW_CONNECTION % (len(cv_image[0]) - 1, len(cv_image) - 1, args.blade_length * .1))
generic_scad = generic_scad.replace('###NUMBER_OF_CUTS###', str(len(args.key_cuts) - 1))
generic_scad = generic_scad.replace('###X_LENGTH###', X_LENGTH % (len(cv_image[0]) - 1))
generic_scad = generic_scad.replace('###Y_LENGTH###', Y_LENGTH % (len(cv_image) - 1))
generic_scad = generic_scad.replace('###CONNECTOR_HEIGHT###', CONNECTOR_HEIGHT % (args.blade_length * .1))
generic_scad = generic_scad.replace('###KEY_CUTS###', str(args.key_cuts).replace("'", ""))

#WRITE SCAD TO DISK
f = open(args.scad_output_file, 'w')
f.write(generic_scad)
f.close()

#RENDER SCAD
if(args.disable_stl_output == False):
	print "Rendering .stl File (This Will Take Awhile)"
	OPENSCAD_CALL = '''openscad -o %s %s 2>OpenSCAD_output.log 1>OpenSCAD_output.log'''
	subprocess.Popen(OPENSCAD_CALL % (args.output_stl, args.scad_output_file), shell=True, stdout=subprocess.PIPE).stdout.read()
