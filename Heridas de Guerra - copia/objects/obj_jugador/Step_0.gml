// Interacción con armarios al pulsar 'E'
if (keyboard_check_pressed(ord("E"))) {
    var _armario = instance_nearest(x, y, obj_armario_medico);
    
    // Verifica si hay un armario a menos de 40 píxeles
    if (_armario != noone && point_distance(x, y, _armario.x, _armario.y) < 40) {
        escondido = !escondido;
        
        if (escondido) {
            x = _armario.x;
            y = _armario.y + 10; // Alinea al personaje dentro del armario
            visible = false;
        } else {
            y += 16; // Sale un poco hacia abajo al desocultarse
            visible = true;
        }
    }
}

// Si está escondido, cancela el movimiento
if (escondido) {
    exit;
}

// 1. Detección de Teclas (WASD)
var _tecla_derecha  = keyboard_check(ord("D"));
var _tecla_izquierda = keyboard_check(ord("A"));
var _tecla_arriba    = keyboard_check(ord("W"));
var _tecla_abajo     = keyboard_check(ord("S"));

// 2. Calcular Dirección de Movimiento
var _move_x = _tecla_derecha - _tecla_izquierda; // Será -1 (izq), 0 (quieto) o 1 (der)
var _move_y = _tecla_abajo - _tecla_arriba;     // Será -1 (up), 0 (quieto) o 1 (down)

// 3. Normalizar velocidad diagonal (para que no corra más rápido en diagonal)
if (_move_x != 0 && _move_y != 0) {
    _move_x *= 0.7071;
    _move_y *= 0.7071;
}

// 4. Colisión Precisa y Movimiento
// --- Colisión Horizontal ---
var _target_x = x + _move_x * velocidad_camina;
if (place_meeting(_target_x, y, obj_pared)) {
    while (!place_meeting(x + sign(_move_x), y, obj_pared)) {
        x += sign(_move_x);
    }
    _move_x = 0; // Me detengo horizontalmente
}
x += _move_x * velocidad_camina; // Muevo el personaje

// --- Colisión Vertical ---
var _target_y = y + _move_y * velocidad_camina;
if (place_meeting(x, _target_y, obj_pared)) {
    while (!place_meeting(x, y + sign(_move_y), obj_pared)) {
        y += sign(_move_y);
    }
    _move_y = 0; // Me detengo verticalmente
}
y += _move_y * velocidad_camina; // Muevo el personaje

// 5. Gestión de Animaciones y Sprites
if (_tecla_derecha || _tecla_izquierda || _tecla_arriba || _tecla_abajo) {
    image_speed = 1; // Activa la animación
    
    // Asigna sprite según la tecla pulsada
    if (_tecla_abajo) {
        sprite_index = spr_player_down_strip4;
        image_xscale = 1;
    } else if (_tecla_arriba) {
        sprite_index = spr_player_up_strip4;
        image_xscale = 1;
    } else if (_tecla_derecha) {
        sprite_index = spr_player_side_strip4;
        image_xscale = 1; // Normal a la derecha
    } else if (_tecla_izquierda) {
        sprite_index = spr_player_side_strip4;
        image_xscale = -1; // Invierte el sprite horizontalmente
    }
} else {
    image_speed = 0; // Pausa la animación si no toca teclas
    image_index = 0; // Se detiene en el frame inicial de reposo
}

// 6. Actualizar Profundidad (para que tape objetos si está delante)
depth = -y;