// 1. Crear la superficie si no existe o se perdió de memoria
if (!surface_exists(sombra_surface)) {
    sombra_surface = surface_create(room_width, room_height);
}

// 2. Activar la superficie para dibujar DENTRO de ella
surface_set_target(sombra_surface);

// 3. Pintar la sala de oscuridad (Negro al 95% de opacidad)
draw_clear_alpha(c_black, 0.95);

// 4. Cambiar al modo "Restar" para recortar la oscuridad
gpu_set_blendmode(bm_subtract);

// 5. Dibujar la linterna táctica del jugador
if (instance_exists(obj_jugador)) {
    
    // Apaga la linterna por completo si el jugador está escondido en un casillero
    if (!obj_jugador.escondido) {
        
        with (obj_jugador) {
            var _origen_x = x;
            var _origen_y = y - 10; // Altura del pecho
            
            // --- Parámetros base de la linterna ---
            var _distancia_luz = 220;
            var _radio_cuerpo = 25;
            var _alfa_luz = 1.0;
            
            // --- Cálculo de Parpadeo por Proximidad ---
            if (instance_exists(obj_monstruo)) {
                var _dist_monstruo = point_distance(_origen_x, _origen_y, obj_monstruo.x, obj_monstruo.y);
                var _rango_alerta = 200; // Distancia en píxeles para activar la falla
                
                if (_dist_monstruo < _rango_alerta) {
                    // Calcula la cercanía (0 lejos, 1 encima)
                    var _factor_peligro = 1 - (_dist_monstruo / _rango_alerta);
                    
                    // A mayor peligro, mayor probabilidad de fallar en este cuadro
                    if (random(1.0) < _factor_peligro * 0.45) {
                        _distancia_luz *= random_range(0.1, 0.4); // Colapso del alcance
                        _radio_cuerpo *= random_range(0.2, 0.6);  // Reducción del halo personal
                        _alfa_luz = random_range(0.1, 0.5);       // Pérdida de potencia
                    }
                }
            }
            
            // 5a. Luz ambiental tenue e íntima alrededor del cuerpo
            draw_circle_color(_origen_x, _origen_y, _radio_cuerpo, c_white, c_black, false);
            
            // 5b. Dirección hacia el cursor del ratón
            var _dir = point_direction(_origen_x, _origen_y, mouse_x, mouse_y);
            var _apertura = 30; // Ancho del cono
            
            // 5c. Dibujar el cono de luz con parpadeo dinámico
            draw_primitive_begin(pr_trianglefan);
            draw_vertex_color(_origen_x, _origen_y, c_white, _alfa_luz);
            
            for (var i = -_apertura; i <= _apertura; i += 5) {
                var _px = _origen_x + lengthdir_x(_distancia_luz, _dir + i);
                var _py = _origen_y + lengthdir_y(_distancia_luz, _dir + i);
                draw_vertex_color(_px, _py, c_black, 1);
            }
            draw_primitive_end();
        }
        
    } // Fin del chequeo de sigilo
}

// 6. Destello de la tarjeta de acceso si existe en el mapa
if (instance_exists(obj_tarjeta_acceso)) {
    with (obj_tarjeta_acceso) {
        draw_circle_color(x, y, 15, c_white, c_black, false);
    }
}

// 7. Restaurar modo normal y dibujar la sombra en pantalla
gpu_set_blendmode(bm_normal);
surface_reset_target();

draw_surface(sombra_surface, 0, 0);