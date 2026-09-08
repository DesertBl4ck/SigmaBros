// 1. Ajustar profundidad para el ordenamiento visual 2.5D
depth = -y;

var _persiguiendo = false;

// 2. Verificar que el jugador existe y NO está escondido en un casillero
if (instance_exists(obj_jugador) && !obj_jugador.escondido) {
    
    // Calcular distancia hasta el jugador
    var _distancia = point_distance(x, y, obj_jugador.x, obj_jugador.y);
    
    // 3. MODO PERSECUCIÓN: Se activa solo dentro del rango de visión/alarma
    if (_distancia < distancia_alarma) {
        _persiguiendo = true;
        
        var _direccion = point_direction(x, y, obj_jugador.x, obj_jugador.y);
        
        // Descomponer la velocidad según el ángulo hacia el objetivo
        var _vx = lengthdir_x(velocidad_perseguir, _direccion);
        var _vy = lengthdir_y(velocidad_perseguir, _direccion);
        
        // Movimiento con detección de colisión contra paredes
        if (!place_meeting(x + _vx, y, obj_pared)) {
            x += _vx;
        }
        if (!place_meeting(x, y + _vy, obj_pared)) {
            y += _vy;
        }
    }
}

// 4. MODO PATRULLA: Si no está persiguiendo (jugador lejos, escondido o no existente)
if (!_persiguiendo) {
    
    // Si está en pausa tras chocar, reduce el contador
    if (tiempo_pausa > 0) {
        tiempo_pausa--;
    } else {
        var _vx_patrulla = dir_patrulla * velocidad_patrulla;
        
        // Si va a chocar contra una pared o el límite de la sala, da la vuelta
        if (place_meeting(x + _vx_patrulla, y, obj_pared) || (x + _vx_patrulla < 32) || (x + _vx_patrulla > room_width - 32)) {
            dir_patrulla *= -1; // Invierte el sentido del movimiento
            tiempo_pausa = 45;  // Breve pausa de giro
        } else {
            x += _vx_patrulla;
        }
    }
}