if (atrapando) {
    // Pinta un rectángulo rojo semitransparente sobre toda la interfaz
    draw_set_color(c_red);
    draw_set_alpha(0.5);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    
    // Restaura los valores de dibujo por defecto
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}