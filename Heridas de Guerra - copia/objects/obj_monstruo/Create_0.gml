estaba_persiguiendo = false; // Registra si el monstruo estaba persiguiendo en el frame anterio

// --- VELOCIDADES Y DETECCIÓN ---
velocidad_patrulla = 1;
velocidad_perseguir = 1.7;   // Velocidad al perseguir (más lento que el jugador para dar ventaja)
distancia_alarma = 200;      // Rango de visión en píxeles para detectar al jugador

// --- PATRULLA Y ESTADO ---
dir_patrulla = -1;           // Dirección de patrulla inicial (-1 = Izquierda, 1 = Derecha)
tiempo_pausa = 0;            // Contador para pausas al patrullar
atrapando = false;           // Controla si ya se inició la secuencia de muerte

// --- PROFUNDIDAD ---
depth = -y;                  // Profundidad inicial para ordenamiento de capas