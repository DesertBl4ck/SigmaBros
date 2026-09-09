superficie_oscuridad = -1;
depth = -9999;

// Sistema de partículas para el polvo de la linterna
sys_polvo = part_system_create();
part_system_depth(sys_polvo, depth - 1);

part_polvo = part_type_create();
part_type_shape(part_polvo, pt_shape_pixel);
part_type_size(part_polvo, 1, 2, 0, 0);
part_type_color1(part_polvo, c_white);
part_type_alpha3(part_polvo, 0, 0.6, 0); // Aparece y desaparece suavemente
part_type_life(part_polvo, 40, 80);
part_type_speed(part_polvo, 0.1, 0.3, 0, 0);
part_type_direction(part_polvo, 0, 360, 0, 0);