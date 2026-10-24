class_name Enemigo
extends CharacterBody2D

# Valores de reconstrucción editables; no se dispone de los scripts de GameMaker.
enum Estado { PATRULLA, PERSECUCION, BUSQUEDA }
@export var velocidad_patrulla: float = 65.0
@export var velocidad_persecucion: float = 110.0
@export var distancia_deteccion: float = 300.0
@export var distancia_ataque: float = 30.0
@export var duracion_busqueda: float = 2.5
@export var ruta_patrulla: PackedVector2Array
var estado := Estado.PATRULLA
var activo := true
var ultimo_avistamiento := Vector2.ZERO
var tiempo_busqueda := 0.0
var indice_patrulla := 0
var camino := PackedVector2Array()
var hasta_recalcular := 0.0
var atascado := 0.0
var hospital: Node2D
var jugador: Jugador
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision: RayCast2D = $Vision

func _ready() -> void:
	add_to_group("enemigos")
	hospital = get_tree().get_first_node_in_group("hospital")
	jugador = get_tree().get_first_node_in_group("jugador") as Jugador

func ve_jugador() -> bool:
	if not is_instance_valid(jugador) or jugador.oculto or jugador.sin_control:
		return false
	if global_position.distance_to(jugador.global_position) > distancia_deteccion:
		return false
	vision.target_position = jugador.global_position + Vector2(0, -10) - vision.global_position
	vision.force_raycast_update()
	return not vision.is_colliding()

func _physics_process(delta: float) -> void:
	if not activo or not is_instance_valid(jugador) or jugador.sin_control:
		velocity = Vector2.ZERO
		sprite.stop()
		return
	if ve_jugador():
		estado = Estado.PERSECUCION
		ultimo_avistamiento = jugador.global_position
		tiempo_busqueda = duracion_busqueda
	elif estado == Estado.PERSECUCION:
		estado = Estado.BUSQUEDA
		hasta_recalcular = 0.0
	if estado == Estado.BUSQUEDA:
		tiempo_busqueda -= delta
		if tiempo_busqueda <= 0.0:
			estado = Estado.PATRULLA
			hasta_recalcular = 0.0
	if estado == Estado.PERSECUCION and global_position.distance_to(jugador.global_position) <= distancia_ataque:
		jugador.recibir_ataque()
		velocity = Vector2.ZERO
		return
	var destino := ultimo_avistamiento
	if estado == Estado.PATRULLA:
		if ruta_patrulla.is_empty():
			velocity = Vector2.ZERO
			sprite.stop()
			return
		destino = ruta_patrulla[indice_patrulla]
		if global_position.distance_to(destino) < 20.0:
			indice_patrulla = (indice_patrulla + 1) % ruta_patrulla.size()
			destino = ruta_patrulla[indice_patrulla]
			hasta_recalcular = 0.0
	hasta_recalcular -= delta
	if hasta_recalcular <= 0.0 and is_instance_valid(hospital) and hospital.has_method("buscar_camino"):
		camino = hospital.buscar_camino(global_position, destino)
		hasta_recalcular = 0.4
	while not camino.is_empty() and global_position.distance_to(camino[0]) < 9.0:
		camino.remove_at(0)
	var direccion := Vector2.ZERO if camino.is_empty() else global_position.direction_to(camino[0])
	velocity = direccion * (velocidad_persecucion if estado == Estado.PERSECUCION else velocidad_patrulla)
	var anterior := global_position
	move_and_slide()
	if direccion != Vector2.ZERO and global_position.distance_to(anterior) < 0.1:
		atascado += delta
		if atascado > 1.0:
			hasta_recalcular = 0.0
			if estado == Estado.PATRULLA:
				indice_patrulla = (indice_patrulla + 1) % maxi(1, ruta_patrulla.size())
			atascado = 0.0
	else:
		atascado = 0.0
	_animar(direccion)

func _animar(direccion: Vector2) -> void:
	if direccion == Vector2.ZERO:
		sprite.stop()
		return
	if abs(direccion.x) > abs(direccion.y):
		sprite.flip_h = direccion.x < 0
		sprite.play("lado")
	else:
		sprite.flip_h = false
		sprite.play("arriba" if direccion.y < 0 else "abajo")
