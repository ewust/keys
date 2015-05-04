import cv2
from skimage import measure
from skimage import img_as_ubyte
import argparse
parser = argparse.ArgumentParser(description='3D Key Blank Model Generation Utility.')
parser.add_argument('input', default = 'input.pgm', 
					help='the file to read from (default: input.pgm)')
parser.add_argument('--output', '-o', default='output.pgm', 
					help='the file to output to (default: output.pgm)')
parser.add_argument('--threshold', '-t', default=30, type=float, 
					help='the threshold value to use when filtering the image (default: 30)')
args = parser.parse_args()
img = cv2.imread(args.input, 0)
ret,img = cv2.threshold(img,args.threshold,255,cv2.THRESH_BINARY)
labels = measure.label(img)
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
