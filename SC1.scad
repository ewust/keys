//BEST G - Model

$fn=100;

function mm(i) = i*25.4;

module bow(bow_length, bow_width, bow_thickness)
{
	difference()
	{
		union()
		{
			cube([bow_length, bow_width, bow_thickness]);

			//Place cylinders on the top and bottom of the bow for style

			//Top middle
			translate([bow_length / 2, bow_width - 4, 0]) cylinder(h = bow_thickness, r = 6);

			//Bottom middle
			translate([bow_length / 2, 4, 0]) cylinder(h = bow_thickness, r = 6);

			//Left
			translate([4, bow_width / 2, 0]) cylinder(h = bow_thickness, r = 6);
		}

		//Place cylinders around the edges to create a more contoured design

		//Right top
		translate([bow_length, bow_width - 1, 0]) cylinder(h = bow_thickness, r = 8);

		//Right bottom
		//Positioned -1 from the axis to create a bow stop
		translate([bow_length, -1 , 0]) cylinder(h = bow_thickness, r = 8);
		
		//Left top
		translate([0, bow_width, 0]) cylinder(h = bow_thickness, r = 8);
	
		//Left bottom
		translate([0, 0, 0]) cylinder(h = bow_thickness, r = 8);

		//Place hole for keychain use
		translate([4, bow_width / 2, 0]) cylinder(h = bow_thickness, r = 2);
	}
}

module bit()
{
	w = mm(1/4);
	difference() 
	{
		translate([-w/2, 0, 0]) cube([w, mm(1), w]);
		translate([-mm(7/256), 0, 0]) rotate([0, 0, 135]) cube([w, w, w]);
		translate([mm(7/256), 0, 0]) rotate([0, 0, -45]) cube([w, w, w]);
	}
}

module blade(blade_length, blade_width, blade_thickness, key_cuts, shoulder, cut_spacing, cut_depth)
{
	difference()
	{
		cube([blade_length, blade_width, blade_thickness]);

		//Contour tip		
		translate([blade_length, mm(1/8), 0]) 
		{
			rotate([0, 0, 45]) cube([10, 10, blade_thickness]);
			rotate([0, 0, 225]) cube([10, 10, blade_thickness]);
		}
		
		//Cut the key channels
		union()
		{
			translate([0, mm(9/64), blade_thickness / 2]) rotate([62, 0, 0]) cube([blade_length, blade_width, blade_width]);
			translate([0, mm(7/64), blade_thickness / 2]) rotate([55, 0, 0]) cube([blade_length, blade_width, blade_width]);
			translate([0, mm(7/64), blade_thickness / 2]) cube([blade_length, mm(1/32), blade_width]);
		}
        
		translate([0, blade_width - mm(9/64), 0]) cube([blade_length, mm(10/64), blade_thickness / 2]);
		translate([0, blade_width - mm(9/64), blade_thickness / 2]) rotate([-110, 0, 0]) cube([blade_length, blade_width, blade_thickness / 2]);
        
		intersection() 
		{
			translate([0, mm(1/32), blade_thickness / 2]) rotate([-118, 0, 0]) cube([blade_length, blade_width, blade_width]);
			translate([0, mm(1/32), blade_thickness / 2]) rotate([-110, 0, 0]) cube([blade_length, blade_width, blade_width]);
		}

		//Cut the blade
		for (counter = [0:4]) 
		{
			translate([shoulder + (counter * cut_spacing), blade_width - (key_cuts[counter]) * cut_depth, 0]) bit();
		}
	}
}

module sc1(key_cuts) 
{
	blade_length = mm(17/16);
	blade_width = mm(.335);
	blade_thickness = mm(0.080);

	shoulder = mm(0.231);
	cut_spacing = mm(.156);
	cut_depth = mm(.015);
    
	bow_length = mm(1);
	bow_width = mm(1);
	bow_thickness = mm(1/16);

	union()
	{
		bow(bow_length, bow_width, bow_thickness); 
		translate([bow_length, bow_width - blade_width - 9, 0]) blade(blade_length, blade_width, bow_thickness, key_cuts, shoulder, cut_spacing, cut_depth);
	}
}

sc1([2, 6, 6, 2, 3]);
