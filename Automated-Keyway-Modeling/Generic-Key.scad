$fn=100;

function mm(i) = i*25.4;
###SCALE_FACTOR###

//Auto generated channels
module channels(blade_length)
{
    ###CHANNELS###
}

module bit(cut_depth, blade_width)
{
	translate([0, mm(.025 + (cut_depth * .0125)), 0])
        difference() 
        {
            rotate([45, 0, 0]) translate([0, -20, 0]) cube([blade_width, 20, 20]);
            translate([0, -mm(.025), -mm(.05)/2]) cube([blade_width, mm(.025), mm(.05)]);
        }
}

module blade(key_cuts)
{
    ###BLADE_LENGTH###
    ###BLADE_WIDTH###
    shoulder = mm(.195);
    cut_spacing = mm(.15);
    difference()
    {
        //Generate Blade With Channels
        translate([0, 0, -blade_length]) channels(blade_length);
        //Contour Tip
        translate([0, 0, -blade_length - mm(9*.0125)]) 
            rotate([45, 0, 0])  cube([blade_width, mm(.159), mm(.159)]);
        //Cut Tip Stop
        ###TIP_STOP###
        //Place cuts on the key 
        for (counter = [0:###NUMBER_OF_CUTS###])
        {
            translate([0, 0, -shoulder - (counter * cut_spacing)]) 
                bit(key_cuts[counter], blade_width);
        }
    }  
}

module bow_smooth(x_length, y_length)
{
    difference()
    {
        rotate([0, 90, 0]) cylinder(h = x_length*3, r = y_length/2);
        rotate([0, 90, 0]) cylinder(h = x_length*3, r = 3*y_length/8);
        translate([-x_length/2, -y_length/2, -y_length/2]) cube([4*x_length, y_length/2, y_length]);
    }
}

module bow()
{
    ###X_LENGTH###
    ###Y_LENGTH###
    ###CONNECTOR_HEIGHT###
    difference()
    {
        union()
        {
            translate([0, -y_length/2, connector_height]) cube([x_length, 2*y_length, 3*y_length/2]); 
             cube([x_length, y_length, connector_height]); 
            difference()
            {
                translate([0, y_length/2, connector_height + 3*y_length/2]) rotate([0, 90, 0]) cylinder(h = x_length, r = y_length/2);
                translate([-x_length/4, y_length/2, connector_height + 3*y_length/2]) rotate([0, 90, 0]) cylinder(h = 3*x_length/2, r = y_length/2-y_length/4);
            }
        }
        translate([-x_length/4, -y_length/2, connector_height]) rotate([0, 90, 0]) 
            cylinder(h = 3*x_length/2, r = y_length/2);
        translate([-x_length/4, 3*y_length/2, connector_height]) rotate([0, 90, 0]) 
            cylinder(h = 3*x_length/2, r = y_length/2);
        translate([-x_length/4, -y_length/2, connector_height + 3*y_length/2]) 
            rotate([0, 90, 0]) cylinder(h = 3*x_length/2, r = y_length/2);
        translate([-x_length/4, 3*y_length/2, connector_height+ 3*y_length/2]) 
            rotate([0, 90, 0]) cylinder(h = 3*x_length/2, r = y_length/2);
        translate([-x_length/4, 3*y_length/2 - 3*y_length/8, connector_height + 3*y_length/4]) 
            bow_smooth(x_length, y_length);
        translate([5*x_length/4, -y_length/8, connector_height + 3*y_length/4])
            rotate([0, 0, 180]) bow_smooth(x_length, y_length);
    }      
}

module key(key_cuts)
{
    union()
    {
        blade(key_cuts);
        bow();
    }
}

key(###KEY_CUTS###);
