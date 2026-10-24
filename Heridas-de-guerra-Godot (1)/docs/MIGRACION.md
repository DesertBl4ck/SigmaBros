# Migración y rediseño de Heridas de Guerra

## Alcance

El checkout no contiene archivos `.yyp`, `.yy` ni `.gml` de GameMaker. La implementación se basa en el proyecto Godot recibido, los recursos disponibles y los requisitos del encargo. Por esta razón no se puede acreditar paridad exacta con eventos, tiempos o rutas de una versión original ausente.

El proyecto utiliza Godot 4.7.2 estándar, sin plugins ni dependencias externas. Se conservaron los sistemas existentes de movimiento, inventario, tarjeta, puertas, escondites, enemigos, derrota y reinicio, adaptándolos al nuevo escenario.

## Primer nivel narrativo

`nivel_uno.tscn` es ahora la escena principal. Comienza en un hospital en funcionamiento y desarrolla la consulta del soldado mediante siete cuadros de diálogo situados junto al hablante. El jugador no puede caminar, interactuar, usar la linterna ni abrir el inventario mientras dura la conversación. Al terminar recibe el objetivo de llegar a su habitación.

El recorrido normal mide **4096 × 1152 píxeles**. El consultorio y el dormitorio están conectados por un único pasillo largo; ocho habitaciones cerradas permiten observar pacientes que recorren pequeñas rutas internas. El dormitorio contiene cama, mesilla, medicación, gabinete, silla, planta y una ventana al patio. La secuencia de medicación muestra la dosis prescrita, la decisión de tomar más pastillas y el objetivo de acostarse.

Después del fundido, la ventana y la iluminación cambian a la noche. Un cono de luz lunar cae delante de la cama, el niño aparece dentro de ese haz, observa al protagonista y sale caminando sin atacarlo. El entorno se deteriora, los pacientes desaparecen y se habilitan la linterna y el inventario. Volver por el pasillo conduce a `hospital.tscn`, el mundo alucinado con los recuerdos hostiles de la guerra.

El atlas `recursos/hospital_normal/atlas_normal.png` aporta escritorio, sofá, camas, mesillas, gabinete médico, sillas, medicación, puerta, plantas, reloj y carro en pixel art. `personajes_animados.png` contiene seis ciclos direccionales de cuatro fotogramas para el psicólogo y el paciente. `ventana_dia_noche.png` ofrece dos versiones alineadas de la ventana y el patio. Todas las regiones se recortan individualmente para evitar bordes de celdas vecinas.

## Hospital psiquiátrico

El mapa mide **3072 × 2048 píxeles**, frente al área anterior de 1366 × 768. Su diseño se define en `sistemas/diseno_hospital.gd` y se construye por datos para mantener alineados dibujo, colisiones, sombras y navegación.

Las diez zonas son:

1. Recepción principal y sala de espera.
2. Admisión y administración.
3. Sala de terapia.
4. Consultorios psiquiátricos.
5. Enfermería y medicamentos.
6. Hospitalización y habitaciones de pacientes.
7. Comedor y servicio.
8. Aislamiento.
9. Archivo médico.
10. Mantenimiento.

Dos corredores principales forman una cruz central. Los huecos de los muros crean pasillos secundarios y rutas alternativas. Aislamiento queda cerrado por una puerta con tarjeta. Otra puerta habilita un atajo entre el corredor central y el comedor. La tarjeta se encuentra en una zona accesible de enfermería, por lo que no hay un bloqueo imposible. Tres armarios permiten esconderse en hospitalización, archivo y mantenimiento.

Los sectores usan pisos y distribuciones distintas. Se retiraron del suelo todos los nombres de zona y carteles direccionales. El mobiliario incluye recepción, bancos, silla de ruedas, escritorios, estanterías, camillas, camas, círculo de terapia, carros clínicos, mesas de comedor, paneles eléctricos, tuberías y cajas. `recursos/hospital_abandonado/atlas_mobiliario.png` es un atlas nuevo generado para esta versión; los elementos sin región propia se dibujan con primitivas de estilo pixel art.

Los personajes mantienen un marco visual de 64 × 64. Las camas y camillas se normalizaron a 112 × 64; libreros, estanterías y paneles conservan orientación vertical y el banco de trabajo usa 160 × 96. Los dos atlas de mobiliario usan ahora contornos duros, paleta limitada y filtro de vecino más cercano. Esto evita el estiramiento y el contraste de estilos que producían muebles demasiado largos, cuadrados, estrechos o con acabado ilustrado.

## Arquitectura técnica

| Archivo | Responsabilidad |
| --- | --- |
| `nivel_uno.tscn`, `nivel_uno/nivel_uno.gd` | Consulta, objetivos, medicación, sueño, niño y cambio de mundo |
| `nivel_uno/diseno_nivel_uno.gd` | Planta normal, muros, habitaciones y mobiliario |
| `nivel_uno/visual_nivel_uno.gd` | Hospital normal, noche y deterioro alucinado |
| `nivel_uno/mapa_nivel_uno.gd`, `mueble_normal.gd` | Colisiones, oclusión arquitectónica y atlas clínico |
| `nivel_uno/npc_normal.gd` | Psicólogo y pacientes con rutas y animación |
| `hospital.tscn` | Composición del nivel, jugador, puertas, escondites, tarjeta, enemigos, oscuridad y UI |
| `sistemas/diseno_hospital.gd` | Dimensiones, sectores, muros, mobiliario y manchas |
| `escenario/visual_hospital.gd` | Pisos, pasillos, desgaste y muros visibles |
| `escenario/mapa_hospital.gd` | Construcción de cuerpos, colisiones y oclusores |
| `escenario/mueble_hospital.gd` | Mobiliario visual, físico y atlas nuevo |
| `objetos/puerta.tscn`, `objetos/armario.tscn` | Escenas reutilizables para progresión y ocultación |
| `sistemas/hospital.gd` | Navegación AStar de 32 píxeles, descarte y reinicio |
| `jugador.gd`, `jugador.tscn` | Movimiento, interacción, linterna en mano y cámara |
| `interfaz/` | Inventario, descripciones, mensajes, ayuda inicial y derrota |
| `enemigos/` | Patrulla, persecución, búsqueda, visión y animación |
| `pruebas/` | Integración, inventario/linterna/niño, navegación y capturas |

Cada muro y mueble sólido crea una forma física independiente. Solo los muros y puertas crean `LightOccluder2D`: la linterna atraviesa escritorios, camas, sillas y decoración, mientras la colisión de su base impide caminar encima de ellos. Las puertas eliminan de forma diferida su colisión y su oclusor al abrirse; después se reconstruye la cuadrícula AStar. La navegación usa una huella de 28 × 20 para dejar margen al cuerpo del jugador y evita diagonales a través de esquinas.

La cámara es hija del jugador, usa seguimiento suave y límites 0,0–3072,2048. La interfaz vive en un `CanvasLayer`, por lo que permanece fija y visible mientras el mundo se desplaza.

## Oscuridad y linterna

`CanvasModulate` usa negro absoluto. Con la linterna apagada, el mundo no emite luz y la interfaz sigue visible. La linterna:

- se entrega en el primer espacio del inventario;
- empieza apagada;
- permanece dibujada en la mano;
- alterna con F, sin batería;
- combina un círculo suave de unos 410 píxeles alrededor del personaje con un cono direccional ancho;
- proyecta sombras contra muros y puertas, pero atraviesa el mobiliario;
- orienta mano, objeto, luz y rayo según el movimiento;
- desaparece por completo al esconderse;
- muestra «Presiona F para encender la linterna» hasta el primer uso.

El círculo está centrado en el personaje y no gira con la mano. Se apaga junto con el cono al pulsar F, al descartar la linterna, al esconderse o durante la derrota.

## Sistemas conservados

- I es la única acción que abre o cierra el inventario. Las teclas 1–5 seleccionan espacios solo mientras está abierto y Q descarta el objeto seleccionado.
- Los objetos muestran icono, nombre, descripción y ayuda emergente. La posesión de la tarjeta se deriva del inventario.
- Un objeto se elimina del mundo solo después de confirmar su inserción. Los descartes no se crean dentro de paredes y tienen una espera breve antes de volver a recogerse.
- E elige el interactuable próximo con línea de visión libre. Los armarios desactivan visibilidad, colisiones y luz del jugador hasta encontrar una salida libre.
- Adulto y niño usan patrulla → persecución → búsqueda → patrulla. Los obstáculos cortan su visión y su ruta.
- El niño conserva cuatro fotogramas distintos para arriba, abajo y los lados; la izquierda refleja la animación lateral.
- La derrota bloquea entradas, cierra el inventario, muestra una capa roja y recarga la escena.

## Validación

Las pruebas se ejecutaron con Godot 4.7.2 oficial:

- Primer nivel narrativo: **37 comprobaciones, 0 fallos**.
- Integración del mundo alucinado: **47 comprobaciones, 0 fallos**.
- Inventario, linterna y niño: **43 comprobaciones, 0 fallos**.
- Navegación y progresión: **28 comprobaciones, 0 fallos**.
- Renderizado real con Xorg y OpenGL/Mesa llvmpipe: **17 capturas** y **2 comprobaciones, 0 fallos**.

Las comprobaciones cubren bloqueo de cinemáticas, cuadros junto al hablante, objetivos, pasillo, NPC, medicación, noche, ventana, niño, cambio de mundo, escala 64 × 64, ciclos de cuatro pasos, colisiones que cubren la silueta completa, oclusores solo en arquitectura, oscuridad total, UI, cámara, tarjeta accesible, sector restringido, atajo, escondites, visión enemiga, límites, entrada I/F, descarte/recogida, rutas, persecución y búsqueda.

La prueba gráfica compara una captura con la linterna apagada y otra encendida, y recorre recepción, pasillos, terapia, hospitalización, acceso restringido, aislamiento, archivo y mantenimiento. El controlador virtual informa que no puede cambiar V-Sync y que no hay dispositivo de audio; usa audio ficticio. Ninguno de esos avisos afecta al renderizado ni a la lógica.

## Límites conocidos

No se ha hecho una prueba humana prolongada de balance, ni una comparación con GameMaker, ni una ejecución en GPU física. Los valores de velocidad, detección y duración de búsqueda siguen siendo ajustes de reconstrucción. El mobiliario generado y la hoja animada del niño son recursos nuevos de esta versión.
