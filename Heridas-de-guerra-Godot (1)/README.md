# Heridas de Guerra

Juego 2D de terror con vista superior para **Godot 4.7.2 estándar**, sin plugins ni dependencias externas. Abrir `heridas-de-guerra/project.godot` y pulsar **F5** para iniciar la historia desde el consultorio del psicólogo.

El primer nivel presenta a un soldado joven internado por trastorno de estrés postraumático. La consulta inicial se cuenta mediante cuadros junto a cada personaje y bloquea el control hasta terminar. Después, el jugador recorre un pasillo largo con pacientes visibles, llega a su habitación, toma más medicación de la indicada y duerme. La ventana cambia del día a la noche, la luz de la luna revela al niño delante de la cama y el niño sale sin atacar. Entonces el hospital se deteriora y comienza el cambio hacia el mundo alucinado.

El segundo mundo es un hospital psiquiátrico abandonado de **3072 × 2048 píxeles**. Incluye recepción, administración, terapia, consultorios, enfermería, hospitalización, comedor, aislamiento, archivo médico y mantenimiento, unidos por pasillos principales y secundarios. Hay puertas restringidas, un atajo desbloqueable, tres armarios para esconderse y monstruos que representan recuerdos de la guerra.

## Controles

| Acción | Control |
| --- | --- |
| Caminar | WASD o flechas |
| Avanzar diálogos | E o espacio |
| Abrir la puerta con tarjeta | E cerca de la puerta |
| Entrar/salir del armario | E cerca del armario |
| Abrir/cerrar inventario | I |
| Seleccionar inventario y leer descripción | 1–5, con inventario abierto |
| Descartar objeto seleccionado | Q, con inventario abierto |
| Encender/apagar linterna | F |
| Recoger tarjeta | Acercarse al objeto |

Las puertas conservan la tarjeta. El inventario empieza cerrado y solo se despliega con I. Cada objeto tiene nombre, icono y una breve descripción al seleccionarlo o al pasar el cursor por su espacio.

La linterna ocupa el primer espacio, aparece en la mano y **empieza apagada**. Se habilita cuando comienza la alucinación. El mundo queda completamente oscuro hasta pulsar F; el indicador inicial desaparece después del primer uso. Al encenderla combina un círculo suave alrededor del personaje con el cono direccional de largo alcance. Las paredes y puertas cortan la luz; escritorios, camas, sillas y objetos pequeños dejan pasar el haz para evitar polígonos negros desproporcionados. No hay batería ni consumo. Si descartas la linterna, debes recogerla de nuevo antes de poder usar F.

Todo el arte nuevo usa píxeles definidos, paleta limitada y filtrado por vecino más cercano para conservar el estilo retro de los personajes originales. El mobiliario mantiene una escala común respecto a los personajes de 64 × 64: camas y camillas miden 112 × 64, los asientos son individuales y los armarios, libreros y paneles conservan su proporción vertical. La colisión cubre la silueta completa de cada mueble para impedir que el personaje camine encima. El suelo no contiene carteles ni nombres de zonas.

El psicólogo y los pacientes nuevos tienen cuatro fotogramas distintos para caminar hacia arriba, abajo y los lados; la izquierda refleja el ciclo lateral. La ventana del dormitorio tiene arte alineado para el patio de día y de noche. La cámara sigue al personaje suavemente sin salir de los límites del edificio. El niño y el adulto tienen animaciones direccionales, patrullan con AStar, persiguen con línea de visión y pierden al jugador si se esconde. El contacto enemigo muestra el efecto de derrota y reinicia el hospital.

## Ejecución y pruebas

Desde la raíz del repositorio, usando el ejecutable de Godot 4.7.2:

```bash
godot --path heridas-de-guerra --editor --import
godot --path heridas-de-guerra
```

En el entorno en la nube, el ejecutable correcto es `/workspace/tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`; `godot` global todavía puede apuntar a 4.6.3. Para usarlo en los comandos siguientes:

```bash
GODOT=/workspace/tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64
export XDG_CACHE_HOME=/workspace/.cache
export XDG_DATA_HOME=/workspace/.local/share
export XDG_CONFIG_HOME=/workspace/.config
"$GODOT" --headless --path heridas-de-guerra --editor --import
"$GODOT" --headless --fixed-fps 60 --path heridas-de-guerra --script res://pruebas/integracion.gd
"$GODOT" --headless --fixed-fps 60 --path heridas-de-guerra --script res://pruebas/navegacion.gd
"$GODOT" --headless --fixed-fps 60 --path heridas-de-guerra --script res://pruebas/inventario_linterna_nino.gd
"$GODOT" --headless --fixed-fps 60 --path heridas-de-guerra --script res://pruebas/nivel_uno.gd
```

Las pruebas fallan con código de salida 1 si detectan un problema. Requieren importación previa para registrar las clases de GDScript. Para comprobar el renderizado, con una pantalla X11/Windows disponible:

```bash
"$GODOT" --path heridas-de-guerra --script res://pruebas/capturas.gd -- /tmp/heridas-capturas
"$GODOT" --path heridas-de-guerra --script res://pruebas/capturas_nivel_uno.gd
```

En equipos de escritorio puede sustituirse `"$GODOT"` por el comando local de Godot 4.7.2. Sin directorio de salida, las capturas se guardan en `user://capturas`.

Consulta [la auditoría, el diseño del hospital y la validación de la migración](docs/MIGRACION.md). No están disponibles los archivos originales de GameMaker; esta reconstrucción implementa los comportamientos solicitados sobre los recursos existentes y no acredita una equivalencia exacta con el original.
