//Medeco Keymark

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

module security_leg(blade_length, radius, security_leg_thickness, security_leg_width, shift)
{
	translate([-shift, 0, 0]) difference()
	{
		cylinder(h = blade_length, r = radius);
		cylinder(h = blade_length, r = (radius - security_leg_thickness));
		translate([0, security_leg_width, 0]) cube([radius, radius - security_leg_width, blade_length]);
		translate([0, -radius, 0]) cube([radius, radius, blade_length]);
		translate([-radius, -radius, 0]) cube([radius, 2 * radius, blade_length]);
	}; 
}
module blade(blade_length, blade_width, blade_thickness, key_cuts, shoulder, cut_spacing, cut_depth)
{
	biting_blade_width = mm(.150);
	biting_blade_thickness = mm(.05);
	security_leg_thickness = mm(.06);
	security_leg_width = mm(.225);
	radius = 20;
	shift = sqrt((radius-security_leg_thickness)*(radius-security_leg_thickness) - security_leg_width*security_leg_width);
	difference()
	{

		translate([blade_length, 0, 0]) rotate([0, 180, 0])
		{
			difference()
			{
				union()
				{
					translate([0, mm(.225) - mm(.02), -.25]) difference()
					{
						cube([blade_length, biting_blade_width, biting_blade_thickness]);
						translate([-mm(.075), mm(.04), mm(.01)]) rotate([0, 90, 0]) cylinder(h = blade_length + mm(.1), r = mm(.02));
					}
					rotate([0, 90, 0]) security_leg(blade_length, radius, security_leg_thickness, security_leg_width, shift);
				};

				//Cut security leg channels
				translate([0, security_leg_width - (mm(.05)), -mm(.015)]) rotate([0, 90, 0]) cylinder(h = blade_length + mm(.1), r = mm(.03));
				translate([0, mm(.06), -mm(.1)]) rotate([0, 90, 0]) cylinder(h = blade_length + mm(.1), r = mm(.03));
				translate([0, mm(.06), 0]) rotate([0, 90, 0]) cylinder(h = blade_length + mm(.1), r = mm(.045));
			};
		};
		//Contour tip		 
		translate([blade_length, mm(1/8), -20]) {
			rotate([0, 0, 34]) cube([10, 10, 40]);
		}

		//Tip stop
		translate([blade_length - mm(.06), 0, 0]) {
			cube([mm(.09877), mm(.0601), blade_thickness]);
		}

		//Cut the blade
		for (counter = [0:6]) 
		{
			*translate([shoulder + (counter * cut_spacing) + .5, blade_width - (key_cuts[counter]) * cut_depth - .5, 0]) bit();
		}
	}
}

module keymark(key_cuts) 
{
	blade_length = mm(1.269);
	blade_width = mm(.318);
	blade_thickness = mm(0.110);

	shoulder = mm(0.2);
	cut_spacing = mm(.15);
	cut_depth = mm(.0125);
    
	bow_length = mm(1);
	bow_width = mm(1);
	bow_thickness = mm(4.5/32);

	union()
	{
		bow(bow_length, bow_width, bow_thickness); 
		translate([bow_length, bow_width - blade_width - 10, mm(1/16)]) blade(blade_length, blade_width, blade_thickness, key_cuts, shoulder, cut_spacing, cut_depth);
	}
}

keymark([0, 0, 0, 0, 0, 0, 0]);
