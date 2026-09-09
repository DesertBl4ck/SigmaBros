// 1. Vista y cámara
var _cam = view_camera[0];
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);

if (_cw <= 0) { _cw = room_width; _ch = room_height; _cx = 0; _cy = 0; }

// 2. Control de Superficie
if (!surface_exists(superficie_oscuridad)) {
    superficie_oscuridad = surface_create(_cw, _ch);
}

surface_set_target(superficie_oscuridad);
draw_clear_alpha(c_black, 0.97);

gpu_set_blendmode(bm_subtract);

// 3. Renderizar iluminación SOLO si el jugador existe y NO está escondido en un armario
if (instance_exists(obj_jugador) && !obj_jugador.escondido) {
    // Centro real del cuerpo del jugador
    var _px = obj_jugador.x - _cx;
    var _py = (obj_jugador.y - 16) - _cy; 
    
    var _dir = point_direction(obj_jugador.x, obj_jugador.y - 16, mouse_x, mouse_y);
    
    // --- CONTROLES DE TAMAÑO Y ALCANCE DE LA LUZ ---
    var _distancia_haz = 180; // Largo de la linterna (alcanza más lejos)
    var _ancho_cono    = 0.95; // Grosor/Apertura del cono (engrosado para acoplar con el foco)
    var _tamano_spot   = 1.3;  // Círculo focal del final
    var _tamano_aura   = 0.8;  // Aura alrededor del cuerpo
    
    // A. Aura circular alrededor del jugador
    draw_sprite_ext(spr_luz_circulo, 0, _px, _py, _tamano_aura, _tamano_aura, 0, c_white, 0.85);
    
    // B. Cono de la linterna (Alineado y más ancho)
    draw_sprite_ext(spr_luz_cono, 0, _px, _py, _distancia_haz / 256, _ancho_cono, _dir, c_white, 0.9);
    
    // C. Foco final (Hotspot) en la punta de la linterna
    var _spot_x = _px + lengthdir_x(_distancia_haz, _dir);
    var _spot_y = _py + lengthdir_y(_distancia_haz, _dir);
    draw_sprite_ext(spr_luz_circulo, 0, _spot_x, _spot_y, _tamano_spot, _tamano_spot, 0, c_white, 1.0);
    
    // Generar partículas alineadas al área ampliada del haz
    if (random(100) < 30) {
        var _p_dist = random_range(10, _distancia_haz);
        var _p_dir = _dir + random_range(-10, 10);
        var _gx = obj_jugador.x + lengthdir_x(_p_dist, _p_dir);
        var _gy = (obj_jugador.y - 16) + lengthdir_y(_p_dist, _p_dir);
        part_particles_create(sys_polvo, _gx, _gy, part_polvo, 1);
    }
}

gpu_set_blendmode(bm_normal);
surface_reset_target();

draw_surface(superficie_oscuridad, _cx, _cy);