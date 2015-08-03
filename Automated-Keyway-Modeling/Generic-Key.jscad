function mm(i) {
    return i*25.4;
}
function pixel(i) {
    return mm(i*###SCALE_FACTOR###);
}
function channels(blade_length) {
    return union(
###CHANNELS###
    );
}
function bit(cut_depth, blade_width) {
    return difference(
        cube({size: [blade_width, 20, 20]}).translate([0, -20, 0]).rotateX(45),
        cube({size: [blade_width, mm(0.025), mm(0.05)]}).translate([0, -mm(0.025), -mm(0.05)/2]) 
    ).translate([0, mm(0.025 + (cut_depth * 0.0125)), 0]);
}
function bow_edges(bow_height, inner_radius, outer_radius, amount_show) {
    outer_radius = 2*outer_radius;
    return difference(
        cylinder({h: 2*bow_height, r: outer_radius}),
        cylinder({h: 2*bow_height, r: inner_radius}),
        cube({size: [2*outer_radius, 2*outer_radius, 2*bow_height]}).translate([-inner_radius + amount_show, -outer_radius, 0])   
    ).translate([inner_radius, 0, 0]);
}
function bow(input_x_len, input_y_len) {
    bow_height = input_y_len;
    bow_x_length = input_x_len * 2.808888889;
    bow_y_length = input_x_len * 2.891851852;
    return difference(
        cube({size: [bow_x_length, bow_y_length, bow_height]}),
        cylinder({h: bow_height, r: bow_x_length/2 - input_x_len/2}),
        cylinder({h: bow_height, r: bow_x_length/2 - input_x_len/2}).translate([bow_x_length, 0, 0]),
        cylinder({h: bow_height, r: bow_x_length/2 - input_x_len/2}).translate([0, 0.925 * bow_y_length, 0]),
        cylinder({h: bow_height, r: bow_x_length/2 - input_x_len/2}).translate([bow_x_length, 0.925 * bow_y_length, 0]),
        bow_edges(bow_height, 0.173442623 * bow_y_length, 0.192110656 * bow_y_length, 0.074367089 * bow_x_length)
        .translate([0, 0.4615 * bow_y_length, 0]),
        bow_edges(bow_height, 0.173442623 * bow_y_length, 0.192110656 * bow_y_length, 0.074367089 * bow_x_length)
        .rotateY(180).translate([bow_x_length, 0.4615 * bow_y_length, 3*bow_height/2]),
        bow_edges(bow_height, bow_y_length - 8*(0.074367089 * bow_x_length), bow_y_length - 2*(0.074367089 * bow_x_length), 0.074367089 * bow_x_length)
        .rotateZ(270).translate([bow_x_length/2, bow_y_length - 0.1*bow_y_length, 0]),
        difference(
            cube({size: [input_x_len, 0.15*bow_y_length, bow_height]}).translate([bow_x_length/2 - input_x_len/2, 0, 0]),
            cube({size: [bow_x_length/2 - input_x_len/2, 0.3*bow_y_length, bow_height]}).rotateZ(-15),
            cube({size: [bow_x_length/2 + input_x_len/2, 0.3*bow_y_length, bow_height]}).rotateZ(105).translate([bow_x_length/2 + input_x_len/2 + cos(15) * 0.3*bow_y_length, sin(15) * 0.3*bow_y_length, 0])
        ).translate([-0.006*bow_x_length, 0.65*bow_y_length, 0])
    );
}
function blade(key_cuts) {
    ###BLADE_LENGTH###
    ###BLADE_WIDTH### 
    shoulder = mm(0.195);
    cut_spacing = mm(0.15);
    return difference(
        channels(blade_length).translate([-blade_width, 0, 0]).rotateY(180),
        cube({size: [blade_width, mm(0.159), mm(0.159)]}).rotateY(45).translate([0, 0, -blade_length - mm(9*0.0125)]),
        ###TIP_STOP###
        bit(key_cuts[0], blade_width).translate([0, 0, -shoulder - (0 * cut_spacing)]),
        bit(key_cuts[1], blade_width).translate([0, 0, -shoulder - (1 * cut_spacing)]),
        bit(key_cuts[2], blade_width).translate([0, 0, -shoulder - (2 * cut_spacing)]),
        bit(key_cuts[3], blade_width).translate([0, 0, -shoulder - (3 * cut_spacing)]),
        bit(key_cuts[4], blade_width).translate([0, 0, -shoulder - (4 * cut_spacing)]),
        bit(key_cuts[5], blade_width).translate([0, 0, -shoulder - (5 * cut_spacing)]),
        bit(key_cuts[6], blade_width).translate([0, 0, -shoulder - (6 * cut_spacing)])
    );
}
function main() {
    ###X_LENGTH###
    ###Y_LENGTH###
    return union(
        blade(###KEY_CUTS###),
        bow(y_length, x_length).rotateX(90).rotateZ(90).translate([0, -((y_length*2.808888889)/2 - y_length/2), 0])
    );
}
