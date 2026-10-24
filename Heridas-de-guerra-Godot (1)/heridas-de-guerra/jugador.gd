class_name Jugador
extends CharacterBody2D

signal mensaje(texto: String)
signal derrotado
signal inventario_alternado(abierto: bool)
signal estado_linterna_cambiado
signal linterna_usada

@export var velocidad: float = 180.0
@export var alcance_interaccion: float = 100.0
@export var linterna_habilitada := true
@export var inventario_habilitado := true
var oculto := false
var sin_control := false
var inventario_abierto := false
var linterna_encendida := false
var linterna_utilizada := false
var direccion_mirada := Vector2.DOWN
var escondite: Node2D
# La posesión se deriva del inventario: nunca existe un segundo estado mutable.
var tiene_tarjeta: bool:
	get:
		return inventario.contiene(Inventario.TARJETA)

@onready var inventario: Inventario = $Inventario
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var mano: Node2D = $Mano
@onready var linterna: PointLight2D = $Mano/Linterna
@onready var halo: PointLight2D = $Halo
@onready var rayo: RayCast2D = $Mano/RayoLinterna

func _ready() -> void:
	add_to_group("jugador")
	inventario.agregar(Inventario.LINTERNA)
	inventario.cambiado.connect(_sincronizar_equipo)
	sprite.frame_changed.connect(_actualizar_mano)
	_actualizar_mano()
	_sincronizar_equipo()

func _unhandled_input(evento: InputEvent) -> void:
	if sin_control or evento.is_echo():
		return
	if evento.is_action_pressed("inventario") and inventario_habilitado:
		inventario_abierto = not inventario_abierto
		inventario_alternado.emit(inventario_abierto)
	elif evento.is_action_pressed("linterna") and linterna_habilitada:
		alternar_linterna()
	elif evento.is_action_pressed("interactuar"):
		interactuar()
	elif inventario_abierto and not oculto and evento.is_action_pressed("descartar"):
		descartar()
	if inventario_abierto:
		for indice in range(Inventario.CAPACIDAD):
			if evento.is_action_pressed("espacio_%d" % (indice + 1)):
				inventario.seleccionar(indice)

func _physics_process(_delta: float) -> void:
	if sin_control or oculto:
		velocity = Vector2.ZERO
		sprite.stop()
		return
	var direccion := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	velocity = direccion * velocidad
	move_and_slide()
	if direccion == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 0
		return
	direccion_mirada = direccion.normalized()
	if abs(direccion.x) > abs(direccion.y):
		sprite.flip_h = direccion.x < 0
		sprite.play("lado")
	elif direccion.y < 0:
		sprite.flip_h = false
		sprite.play("arriba")
	else:
		sprite.flip_h = false
		sprite.play("abajo")
	_actualizar_mano()

func _actualizar_mano() -> void:
	if not is_instance_valid(mano):
		return
	match sprite.animation:
		&"arriba":
			mano.position = Vector2(-14, -26)
			mano.z_index = -1
		&"lado":
			mano.position = Vector2(-10 if sprite.flip_h else 10, -22)
			mano.z_index = 1
		_:
			mano.position = Vector2(14, -20)
			mano.z_index = 1
	if sprite.is_playing() and sprite.frame % 2 == 1:
		mano.position.y += 1.0
	mano.rotation = direccion_mirada.angle()

func _sincronizar_equipo() -> void:
	var tiene_linterna := inventario.contiene(Inventario.LINTERNA)
	if not tiene_linterna:
		linterna_encendida = false
	mano.visible = tiene_linterna and linterna_habilitada and not oculto
	var iluminar := tiene_linterna and linterna_habilitada and linterna_encendida and not oculto and not sin_control
	linterna.visible = iluminar
	# El halo permite leer el entorno inmediato; el cono conserva el alcance.
	halo.visible = iluminar
	rayo.enabled = iluminar
	estado_linterna_cambiado.emit()

func alternar_linterna() -> void:
	if sin_control or oculto:
		return
	if not inventario.contiene(Inventario.LINTERNA):
		mensaje.emit("Necesitas llevar una linterna. Recógela para usar F.")
		return
	if not linterna_utilizada:
		linterna_utilizada = true
		linterna_usada.emit()
	linterna_encendida = not linterna_encendida
	_sincronizar_equipo()

func recoger_objeto(objeto: StringName) -> bool:
	if oculto or sin_control:
		return false
	if not inventario.agregar(objeto):
		mensaje.emit("Ya llevas una linterna." if objeto == Inventario.LINTERNA and inventario.contiene(objeto) else "El inventario está lleno.")
		return false
	if objeto == Inventario.TARJETA:
		mensaje.emit("¡Has recogido una tarjeta de acceso!")
	elif objeto == Inventario.LINTERNA:
		mensaje.emit("Has recogido la linterna. Pulsa F para encenderla.")
	else:
		mensaje.emit("Has recogido: " + Inventario.nombre_objeto(objeto))
	return true

func recoger_tarjeta() -> bool:
	return recoger_objeto(Inventario.TARJETA)

func objetivo_interaccion() -> Node2D:
	var elegido: Node2D
	var distancia := alcance_interaccion
	for objeto in get_tree().get_nodes_in_group("interactuables"):
		var punto: Vector2 = objeto.punto_interaccion()
		var actual := global_position.distance_to(punto)
		if actual < distancia and _visible_para_interactuar(objeto, punto):
			distancia = actual
			elegido = objeto
	return elegido

func _visible_para_interactuar(objeto: Node2D, punto: Vector2) -> bool:
	var consulta := PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -10), punto, 1)
	consulta.exclude = [get_rid(), objeto.get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(consulta).is_empty()

func interactuar() -> void:
	if sin_control:
		return
	if oculto:
		if is_instance_valid(escondite):
			escondite.interactuar(self)
		return
	var objeto := objetivo_interaccion()
	if objeto:
		objeto.interactuar(self)

func entrar_escondite(objeto: Node2D) -> void:
	escondite = objeto
	oculto = true
	velocity = Vector2.ZERO
	visible = false
	collision_layer = 0
	collision_mask = 0
	_sincronizar_equipo()

func salir_escondite(salida: Vector2) -> void:
	global_position = salida
	oculto = false
	escondite = null
	visible = true
	collision_layer = 2
	collision_mask = 5
	_sincronizar_equipo()

func descartar() -> void:
	if sin_control or oculto or inventario.objeto_seleccionado() == &"":
		return
	var hospital := get_tree().current_scene
	if hospital and hospital.has_method("soltar_objeto"):
		if hospital.soltar_objeto(inventario.objeto_seleccionado(), global_position + direccion_mirada * 42.0):
			inventario.quitar_seleccionado()
			mensaje.emit("Objeto descartado. Puedes volver a recogerlo.")
		else:
			mensaje.emit("No hay espacio libre para dejar el objeto.")

func recibir_ataque() -> void:
	if oculto or sin_control:
		return
	sin_control = true
	inventario_abierto = false
	inventario_alternado.emit(false)
	_sincronizar_equipo()
	velocity = Vector2.ZERO
	derrotado.emit()
