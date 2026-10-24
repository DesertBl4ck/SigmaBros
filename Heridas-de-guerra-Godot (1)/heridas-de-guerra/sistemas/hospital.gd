extends Node2D

const RECOGIBLE := preload("res://objetos/recogible.tscn")
const TAMANO := DisenoHospital.TAMANO
const CELDA := 32
@export var demora_reinicio: float = 1.8
var navegacion := AStarGrid2D.new()
var navegacion_lista := false
var en_derrota := false
@onready var jugador: Jugador = $Jugador
@onready var interfaz = $Interfaz
@onready var temporizador: Timer = $Reinicio

func _enter_tree() -> void:
	add_to_group("hospital")

func _ready() -> void:
	jugador.mensaje.connect(interfaz.mostrar_mensaje)
	jugador.derrotado.connect(_derrota)
	jugador.inventario.cambiado.connect(interfaz.actualizar_inventario)
	interfaz.vincular(jugador)
	for puerta in get_tree().get_nodes_in_group("puertas"):
		puerta.abierta.connect(_actualizar_navegacion)
	temporizador.timeout.connect(_reiniciar)
	await get_tree().physics_frame
	reconstruir_navegacion()

func _actualizar_navegacion() -> void:
	# Esperar a que PhysicsServer aplique la desactivación diferida de la puerta.
	await get_tree().physics_frame
	await get_tree().physics_frame
	reconstruir_navegacion()

func reconstruir_navegacion() -> void:
	var columnas := ceili(TAMANO.x / CELDA)
	var filas := ceili(TAMANO.y / CELDA)
	navegacion.region = Rect2i(0, 0, columnas, filas)
	navegacion.cell_size = Vector2(CELDA, CELDA)
	navegacion.offset = Vector2(CELDA, CELDA) * 0.5
	navegacion.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	navegacion.update()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(28, 20)
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.collision_mask = 1
	for y in range(filas):
		for x in range(columnas):
			var punto := Vector2(x * CELDA + CELDA * 0.5, y * CELDA + CELDA * 0.5)
			consulta.transform = Transform2D(0.0, punto + Vector2(0, -10))
			var bloqueado := punto.x < 16 or punto.x > TAMANO.x - 16 or punto.y < 24 or punto.y > TAMANO.y - 8
			if not bloqueado:
				bloqueado = not get_world_2d().direct_space_state.intersect_shape(consulta, 1).is_empty()
			navegacion.set_point_solid(Vector2i(x, y), bloqueado)
	navegacion_lista = true

func celda_cercana(punto: Vector2) -> Vector2i:
	var celda := Vector2i((punto / float(CELDA)).floor())
	for radio in range(9):
		for y in range(-radio, radio + 1):
			for x in range(-radio, radio + 1):
				var candidata := celda + Vector2i(x, y)
				if navegacion.is_in_boundsv(candidata) and not navegacion.is_point_solid(candidata):
					return candidata
	return Vector2i(-1, -1)

func buscar_camino(origen: Vector2, destino: Vector2) -> PackedVector2Array:
	if not navegacion_lista:
		return PackedVector2Array()
	var inicio := celda_cercana(origen)
	var fin := celda_cercana(destino)
	if inicio.x == -1 or fin.x == -1:
		return PackedVector2Array()
	return navegacion.get_point_path(inicio, fin)

func soltar_objeto(objeto: StringName, punto: Vector2) -> bool:
	if objeto == &"" or punto.x < 16 or punto.y < 16 or punto.x > TAMANO.x - 16 or punto.y > TAMANO.y - 16:
		return false
	var forma := CircleShape2D.new()
	forma.radius = 12.0
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0.0, punto)
	consulta.collision_mask = 1
	if not get_world_2d().direct_space_state.intersect_shape(consulta).is_empty():
		return false
	var rayo := PhysicsRayQueryParameters2D.create(jugador.global_position + Vector2(0, -10), punto, 1)
	if not get_world_2d().direct_space_state.intersect_ray(rayo).is_empty():
		return false
	var recogible := RECOGIBLE.instantiate()
	recogible.objeto = objeto
	recogible.position = punto
	recogible.espera_recogida = 0.8
	add_child(recogible)
	return true

func _derrota() -> void:
	if en_derrota:
		return
	en_derrota = true
	interfaz.mostrar_derrota()
	temporizador.start(demora_reinicio)

func _reiniciar() -> void:
	get_tree().reload_current_scene()
