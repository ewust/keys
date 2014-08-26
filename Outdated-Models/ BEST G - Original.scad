
//
// Generate a duplicate of a BEST G key by editing the last line of the file
// and entering in the key code of the lock.  If you don't know the key code,
// you can measure the key and compare the numbers at:
// http://web.archive.org/web/20050217020917fw_/http://dlaco.com/spacing/tips.htm
//
// This work is licensed under a Creative Commons Attribution 3.0 Unported License.

// Since the keys and locks I have were all designed in imperial units, the
// constants in this file will be defined in inches.  The mm function
// allows us to retain the proper size for exporting a metric STL.
function mm(i) = i*25.4;
$fn=100;

module rounded(size, r) {
	 
    union() {
        translate([0, r, 0]) cube([size[0], size[1]-2*r, size[2]]);
        translate([r, r, 0]) cylinder(h=size[2], r=r);
        translate([size[0]-r, r, 0]) cylinder(h=size[2], r=(r+.5));
        translate([r, size[1]-r, 0]) cylinder(h=size[2], r=(r));
        translate([size[0]-r, size[1]-r, 0]) cylinder(h=size[2], r=r);
		translate([(mm(1))/2, mm(.205) + ((mm(1))/2), 0]) cylinder(h= size[2], r=r);
		translate([(mm(1))/2, mm(.287), 0]) cylinder(h= size[2], r=r);
	  }
}

module bit() {
    w = mm(1/4);
    difference() {
        translate([-w/2, 0, 0]) cube([w, mm(1), w]);
        translate([-mm(7/256), 0, 0]) rotate([0, 0, 135]) cube([w, w, w]);
         translate([mm(7/256), 0, 0]) rotate([0, 0, -45]) cube([w, w, w]);
    }
}

// BEST G key.  The measurements are mostly guesses based on reverse
// engineering some keys I have and some publicly available information.
module best_g(bits) {
    // You may need to adjust these to fit your specific printer settings
    thickness = mm(0.080);
    length = mm(1.269);
    width = mm(.318);
    
    shoulder = mm(0.2);
    pin_spacing = mm(.15);
    depth_inc = mm(.0125);
    
    // A fudge factor.  Printing with your average RepRap, the bottom layer is
    // going to be squeezed larger than you want. You can make the pins
    // go slighly deeper by a fudge amount to make up for it if you aren't
    // adjusting for it elsewhere like Skeinforge or in your firmware.
    fudge = 0.5;
    
    // Handle size
    h_l = mm(1);
    h_w = mm(1);
    h_d = mm(1/16);
    difference() {
        // blade and key handle
        union() {
            translate([-h_l, -h_w/2 + width/2, 0])  difference() {
                rounded([h_l, h_w, thickness], mm(1/3));
                // Round out edge of bow to blade            
                translate([h_l, h_w/2 + width/2 + 8, 0]) cylinder(h=thickness, r=8);
                translate([h_l, h_w/2 - width/2 - 9 , 0]) cylinder(h=thickness, r=8);
				translate([(5*h_l)/8, -3, 0])  cube([2*thickness, 2*thickness, thickness]);
				translate([(5*h_l)/8, 3 + width + ( h_l/2), 0])  cube([2*thickness, 2*thickness, thickness]);
                translate([0 , h_w/2 + width/2 + 8, 0]) cylinder(h=thickness, r=8);
                translate([0, h_w/2 - width/2 - 9 , 0]) cylinder(h=thickness, r=8);
		       }

            // cut a little off the tip to avoid going too long
            cube([length, width, thickness]);
        }
        
        // chamfer the tip
        translate([length, mm(1/8), 0]) {
            rotate([0, 0, 34]) cube([10, 10, thickness]);

        }
        translate([length - mm(.106), 0, 0]) {
            cube([mm(.106), mm(.08), thickness]);       
        }

        // put in a hole for keychain use
        translate([-h_l + mm(3/16), width/2, 0]) cylinder(h=thickness, r=mm(1/8));
        
        // cut the channels in the key.  designed more for printability than accuracy
        union() {
            translate([-h_d, mm(.105), mm(.025)]) rotate([225, 0, 0]) cube([length + h_d, width, width]);
            translate([-h_d, mm(.105), mm(.05)]) rotate([260, 0, 0]) cube([length + h_d, thickness/2, mm(1/32)]);
            translate([-h_d, mm(.105), 0]) cube([length + h_d, mm(7/128), mm(.05)]);
            translate([-h_d, mm(.105) + mm(7/128), mm(.05)]) rotate([225, 0, 0]) cube([length + h_d, mm(3/64), thickness]);
        }
        
        translate([-h_d, width - mm(9/64), mm(.043)]) {
            cube([length + h_d, width - (width - mm(10/64)), thickness]);
            rotate([50, 0, 0]) cube([length + h_d, width, thickness]);
        }
        
        union() {
            translate([-h_d, mm(0.015), mm(.03)]) cube([length + h_d, mm(.041), thickness]);
            translate([-h_d, mm(0.015) + mm(13/256), thickness - mm(1/64)]) rotate([45, 0, 0]) cube([length + h_d, mm(1/16), mm(1/16)]);
        }
        
        // Do the actual bitting
        for (b = [0:6]) {
			if (bits[b] == 0)
			{}
			else
			{
				translate([shoulder + fudge + b*pin_spacing, width - (bits[b])*depth_inc - fudge, 0]) bit();
			}
        }
    }
}

best_g([0, 8, 5, 9, 8, 6, 5]);
