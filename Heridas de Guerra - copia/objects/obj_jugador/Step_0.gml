// 1. Interacción con armarios al pulsar 'E'
if (keyboard_check_pressed(ord("E"))) {
    var _armario = instance_nearest(x, y, obj_armario_medico);
    
    if (_armario != noone && point_distance(x, y, _armario.x, _armario.y) < 40) {
        escondido = !escondido;
        
        if (escondido) {
            x = _armario.x;
            y = _armario.y + 10;
            visible = false;
        } else {
            y += 16;
            visible = true;
        }
    }
}

// Cancelar lógica si el personaje está escondido
if (escondido) {
    exit;
}

// 2. Detección de Teclas (WASD)
var _tecla_derecha   = keyboard_check(ord("D"));
var _tecla_izquierda = keyboard_check(ord("A"));
var _tecla_arriba    = keyboard_check(ord("W"));
var _tecla_abajo     = keyboard_check(ord("S"));

// 3. Calcular Dirección de Movimiento
var _move_x = _tecla_derecha - _tecla_izquierda;
var _move_y = _tecla_abajo - _tecla_arriba;

if (_move_x != 0 && _move_y != 0) {
    _move_x *= 0.7071;
    _move_y *= 0.7071;
}

// Registrar posición previa para verificar movimiento real
var _x_previo = x;
var _y_previo = y;

// 4. Colisión Precisa y Movimiento
// --- Colisión Horizontal ---
var _target_x = x + _move_x * velocidad_camina;
if (place_meeting(_target_x, y, obj_pared)) {
    while (!place_meeting(x + sign(_move_x), y, obj_pared)) {
        x += sign(_move_x);
    }
    _move_x = 0;
}
x += _move_x * velocidad_camina;

// --- Colisión Vertical ---
var _target_y = y + _move_y * velocidad_camina;
if (place_meeting(x, _target_y, obj_pared)) {
    while (!place_meeting(x, y + sign(_move_y), obj_pared)) {
        y += sign(_move_y);
    }
    _move_y = 0;
}
y += _move_y * velocidad_camina;

// 5. Asignación de Sprite y Dirección
if (_tecla_abajo) {
    sprite_index = spr_player_down_strip4;
    image_xscale = 1;
} else if (_tecla_arriba) {
    sprite_index = spr_player_up_strip4;
    image_xscale = 1;
} else if (_tecla_derecha) {
    sprite_index = spr_player_side_strip4;
    image_xscale = 1;
} else if (_tecla_izquierda) {
    sprite_index = spr_player_side_strip4;
    image_xscale = -1;
}

// 6. Control de Animación por Desplazamiento Real
var _se_movio = (x != _x_previo || y != _y_previo);

if (_se_movio) {
    image_speed = 1; // Reproduce animación solo si avanzó en el mapa
} else {
    image_speed = 0; // Se detiene si no hay teclas o si choca contra pared
    image_index = 0; // Mantiene el frame inicial de pie
}

// 7. Profundidad
depth = -y;