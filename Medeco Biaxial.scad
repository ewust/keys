//Medeco Biaxial

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
	w = mm(.15);
	difference() 
	{
		translate([-(mm(1/4))/2, 0, -(mm(1/4))/2]) cube([mm(1/4), mm(1), 2*w]);
		translate([-mm(4/256), 0, -w/2]) rotate([0, 0, 135]) cube([w, w, 2*w]);
		translate([mm(4/256), 0, -w/2]) rotate([0, 0, -43]) cube([w, w, 2*w]);
	}
}

module blade(blade_length, blade_width, blade_thickness, key_cuts, key_cut_angle, key_cut_spacing, shoulder, cut_spacing, cut_depth)
{
	difference()
	{
		cube([blade_length, blade_width, blade_thickness]);

		//Contour tip		 
		translate([blade_length, mm(1/8), 0]) {
			rotate([0, 0, 34]) cube([10, 10, blade_thickness]);
		}

		//Cut the key channels
		translate([0, mm(.035), 0]) rotate([0, 90, 0]) cylinder(h = blade_length + .01, r = mm(.03));
		translate([0, mm(.1), 0]) rotate([0, 90, 0]) cylinder(h = blade_length+ .01, r = mm(.03));
		translate([0, mm(.05), blade_thickness]) rotate([0, 90, 0]) cylinder(h = blade_length + .01, r = mm(.035));

		translate([0, blade_width - (7 * cut_depth), 0]) cube([blade_length, 7 * cut_depth, blade_thickness/4]);
		translate([0, blade_width - (7 * cut_depth), (3*blade_thickness)/4]) cube([blade_length, 7 * cut_depth, blade_thickness/4]);
		//Cut the blade
		for (counter = [0:5]) 
		{
			translate([shoulder + (counter * cut_spacing) + .5 + (key_cut_spacing[counter] * mm(.03)), blade_width - (key_cuts[counter]) * cut_depth - .5, 0]) rotate ([0, key_cut_angle[counter] * 20, 0]) bit();
		}
	}
}

module biaxial(key_cuts, key_cut_angle, key_cut_spacing) 
{
	blade_length = mm(1.119);
	blade_width = mm(.318);
	blade_thickness = mm(0.085);

	shoulder = mm(0.2);
	cut_spacing = mm(.15);
	cut_depth = mm(.025);
    
	bow_length = mm(1);
	bow_width = mm(1);
	bow_thickness = mm(.085);

	difference()
	{
		union()
		{
			bow(bow_length, bow_width, bow_thickness); 
			translate([bow_length, bow_width - blade_width - 9, 0]) blade(blade_length, blade_width, blade_thickness, key_cuts, , key_cut_angle, key_cut_spacing, shoulder, cut_spacing, cut_depth);
		}
		translate([bow_length, bow_width - blade_width - 9 + mm(.05), blade_thickness]) sphere(r = mm(.035));
		translate([bow_length, bow_width - blade_width - 9 + mm(.035), 0]) sphere(r = mm(.03));
		translate([bow_length, bow_width - blade_width - 9 + mm(.1), 0]) sphere(r = mm(.03));
	}
}

//Angles -1 = -20 0 = 0 1 = 20
//Cut spacing -1 = aft 0 = center 1 = fore

biaxial([4, 6, 5, 6, 6, 6], [-1, 0, 0, 1, 0, 1], [0, 0, 0, 0, 0, 0]);
