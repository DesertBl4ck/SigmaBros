
extends CharacterBody2D

# Velocidad del personaje en pixeles por segundo
@export var velocidad: float = 180.0
var tiene_tarjeta: bool = false

# Referencia al nodo que contiene las animaciones
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	# Detectar las teclas WASD
	var direccion: Vector2 = Input.get_vector(
		"mover_izquierda",
		"mover_derecha",
		"mover_arriba",
        "mover_abajo"
	)

	# Calcular velocidad y mover al jugador
	velocity = direccion * velocidad
	move_and_slide()

	# Si no se mueve, detener la animacion
	if direccion == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 0
		return

	# Elegir la animacion segun la direccion
	if abs(direccion.x) > abs(direccion.y):
		sprite.flip_h = direccion.x < 0
		sprite.play("lado")

	elif direccion.y < 0:
		sprite.flip_h = false
		sprite.play("arriba")

	else:
		sprite.flip_h = false
		sprite.play("abajo")


func recoger_tarjeta() -> void:
	if tiene_tarjeta:
		return

	tiene_tarjeta = true
	print("¡Has recogido la tarjeta de acceso!")
