if (!atrapando) {
    atrapando = true; // Evita que se ejecute varias veces
    
    // Paraliza al jugador al instante
    if (instance_exists(obj_jugador)) {
        obj_jugador.velocidad_camina = 0;
    }
    
    // Inicia un temporizador de 45 cuadros (aproximadamente 0.75 segundos)
    alarm[0] = 45;
}