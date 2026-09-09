if (surface_exists(superficie_oscuridad)) {
    surface_free(superficie_oscuridad);
}
if (part_system_exists(sys_polvo)) {
    part_system_destroy(sys_polvo);
}