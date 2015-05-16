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

module bow_edges(bow_height, inner_radius, outer_radius, amount_show)
{
    outer_radius = 2*outer_radius;
    translate([inner_radius, 0, 0]) difference()
    {
        cylinder(h = 2*bow_height, r = outer_radius);
        cylinder(h = 2*bow_height, r = inner_radius);
        translate([-inner_radius + amount_show, -outer_radius, 0]) cube([2*outer_radius, 2*outer_radius, 2*bow_height]);
    }
    
}

module bow(input_x_len, input_y_len)
{
    bow_height = input_y_len;
    bow_x_length = input_x_len * 2.808888889;
    bow_y_length = input_x_len * 2.891851852;
    difference()
    {
        cube([bow_x_length, bow_y_length, bow_height]);
        cylinder(h = bow_height, r = bow_x_length/2 - input_x_len/2);
        translate([bow_x_length, 0, 0]) cylinder(h = bow_height, r = bow_x_length/2 - input_x_len/2);
        translate([0, .925 * bow_y_length, 0]) cylinder(h = bow_height, r = bow_x_length/2 - input_x_len/2);
        translate([bow_x_length, .925 * bow_y_length, 0]) cylinder(h = bow_height, r = bow_x_length/2 - input_x_len/2);
        translate([0, 0.4615 * bow_y_length, 0]) 
        bow_edges(bow_height, 0.173442623 * bow_y_length, 0.192110656 * bow_y_length, 0.074367089 * bow_x_length);
        translate([bow_x_length, 0.4615 * bow_y_length, 3*bow_height/2]) 
        rotate([0, 180, 0]) bow_edges(bow_height, 0.173442623 * bow_y_length, 0.192110656 * bow_y_length, 0.074367089 * bow_x_length);
        translate([bow_x_length/2, bow_y_length - .1*bow_y_length, 0]) 
        rotate([0, 0, 270]) bow_edges(bow_height, bow_y_length - 8*(.074367089 * bow_x_length),  bow_y_length - 2*(.074367089 * bow_x_length), 0.074367089 * bow_x_length);
        translate([-.006*bow_x_length, .65*bow_y_length, 0]) difference()
        {
            translate([bow_x_length/2 - input_x_len/2, 0, 0]) cube([input_x_len, .15*bow_y_length, bow_height]);
            rotate([0, 0, -15]) cube([bow_x_length/2 - input_x_len/2, .3*bow_y_length, bow_height]);
            translate([bow_x_length/2 + input_x_len/2 + cos(15) * .3*bow_y_length, sin(15) * .3*bow_y_length, 0]) rotate([0, 0, +105]) cube([bow_x_length/2 + input_x_len/2, .3*bow_y_length, bow_height]);
        }
    }
}

module key(key_cuts)
{
    ###X_LENGTH###
    ###Y_LENGTH###
    union()
    {
        blade(key_cuts);
        translate([0, -((y_length*2.808888889)/2 - y_length/2), 0]) rotate([90, 0, 90]) bow(y_length, x_length);
    }
}

key(###KEY_CUTS###);
