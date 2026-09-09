// 1. Ajustar profundidad para el ordenamiento visual 2.5D
depth = -y;

// Registrar posición previa para evaluar desplazamiento real
var _x_previo = x;
var _y_previo = y;

var _persiguiendo = false;

// 2. Verificar que el jugador existe y NO está escondido
if (instance_exists(obj_jugador) && !obj_jugador.escondido) {
    
    var _distancia = point_distance(x, y, obj_jugador.x, obj_jugador.y);
    
    // 3. MODO PERSECUCIÓN
    if (_distancia < distancia_alarma) {
        _persiguiendo = true;
        
        var _direccion = point_direction(x, y, obj_jugador.x, obj_jugador.y);
        
        var _vx = lengthdir_x(velocidad_perseguir, _direccion);
        var _vy = lengthdir_y(velocidad_perseguir, _direccion);
        
        if (!place_meeting(x + _vx, y, obj_pared)) {
            x += _vx;
        }
        if (!place_meeting(x, y + _vy, obj_pared)) {
            y += _vy;
        }
    }
}

// --- TRANSICIÓN: Si estaba persiguiendo y el jugador se esconde o sale del rango ---
if (estaba_persiguiendo && !_persiguiendo) {
    tiempo_pausa = 20; // Pausa de confusión al perder de vista al jugador antes de patrullar
}
estaba_persiguiendo = _persiguiendo;

// 4. MODO PATRULLA
if (!_persiguiendo) {
    if (tiempo_pausa > 0) {
        tiempo_pausa--;
    } else {
        var _vx_patrulla = dir_patrulla * velocidad_patrulla;
        
        if (place_meeting(x + _vx_patrulla, y, obj_pared) || (x + _vx_patrulla < 32) || (x + _vx_patrulla > room_width - 32)) {
            dir_patrulla *= -1;
            tiempo_pausa = 20;
        } else {
            x += _vx_patrulla;
        }
    }
}

// 5. GESTIÓN DE ANIMACIONES Y SPRITES
var _se_movio = (x != _x_previo || y != _y_previo);

if (_se_movio) {
    image_speed = 1;
    
    // Angulo exacto del movimiento (90° = Arriba, 270° = Abajo)
    var _dir_mov = point_direction(_x_previo, _y_previo, x, y);
    
    if (_dir_mov >= 45 && _dir_mov < 135) {
        // Moviéndose hacia ARRIBA
        sprite_index = spr_monstruo_up_strip4;
        image_xscale = 1;
    } else if (_dir_mov >= 225 && _dir_mov < 315) {
        // Moviéndose hacia ABAJO
        sprite_index = spr_monstruo_down_strip4;
        image_xscale = 1;
    } else if (_dir_mov >= 135 && _dir_mov < 225) {
        // Moviéndose hacia la IZQUIERDA
        sprite_index = spr_monstruo_side_strip4;
        image_xscale = -1;
    } else {
        // Moviéndose hacia la DERECHA
        sprite_index = spr_monstruo_side_strip4;
        image_xscale = 1;
    }
} else {
    image_speed = 0;
    image_index = 0;
}