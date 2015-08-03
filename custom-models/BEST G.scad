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
		translate([blade_length, mm(1/8), 0]) {
			rotate([0, 0, 34]) cube([10, 10, blade_thickness]);
		}

		//Tip stop
		translate([blade_length - mm(.06), 0, 0]) {
			cube([mm(.09877), mm(.0601), blade_thickness]);
		}
		
		//Cut the key channels
		union() 
		{	
			translate([0, mm(.105), 0]) cube([blade_length, mm(5/128), mm(.045)]);
			translate([0, mm(.14), mm(.05)]) rotate([230, 0, 0]) cube([blade_length, mm(8/64), blade_thickness]);
		}
        
		translate([0, blade_width - mm(9/64), mm(.043)]) 
		{
			cube([blade_length, mm(10/64), blade_thickness]);
			rotate([50, 0, 0]) cube([blade_length, blade_width, blade_thickness]);
		}
        
		union() {
			translate([0, mm(0.025), mm(.05)]) cube([blade_length, mm(.041), blade_thickness]);
			translate([0, mm(0.015) + mm(13/256), blade_thickness - mm(1/64)]) rotate([45, 0, 0]) cube([blade_length, mm(1/16), mm(1/16)]);
		}

		//Cut the blade
		for (counter = [0:6]) 
		{
			translate([shoulder + (counter * cut_spacing) + .5, blade_width - (key_cuts[counter]) * cut_depth - .5, 0]) bit();
		}
	}
}

module best_g(key_cuts) 
{
	blade_length = mm(1.269);
	blade_width = mm(.318);
	blade_thickness = mm(0.075);

	shoulder = mm(0.2);
	cut_spacing = mm(.15);
	cut_depth = mm(.0125);
    
	bow_length = mm(1);
	bow_width = mm(1);
	bow_thickness = mm(1/16);

	union()
	{
		bow(bow_length, bow_width, bow_thickness); 
		translate([bow_length, bow_width - blade_width - 9, 0]) blade(blade_length, blade_width, blade_thickness, key_cuts, shoulder, cut_spacing, cut_depth);
	}
}

best_g([0, 8, 5, 9, 8, 6, 5]);
