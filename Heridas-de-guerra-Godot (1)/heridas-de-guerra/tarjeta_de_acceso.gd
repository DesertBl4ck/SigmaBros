class_name ObjetoRecogible
extends Area2D

@export var objeto: StringName = &"tarjeta_acceso"
@export var espera_recogida: float = 0.0
var recogido := false
var aviso_lleno := false

func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	$Sprite2D.texture = Inventario.icono(objeto)
	$Sprite2D.scale = Vector2(0.09, 0.09) if objeto == Inventario.LINTERNA else Vector2.ONE
	body_entered.connect(_al_tocar_jugador)
	body_exited.connect(func(_cuerpo: Node2D): aviso_lleno = false)

func _physics_process(delta: float) -> void:
	espera_recogida = maxf(0.0, espera_recogida - delta)
	if espera_recogida == 0.0 and not recogido:
		for cuerpo in get_overlapping_bodies():
			if aviso_lleno and cuerpo is Jugador and not cuerpo.inventario.puede_agregar(objeto):
				continue
			_al_tocar_jugador(cuerpo)

func _al_tocar_jugador(cuerpo: Node2D) -> void:
	if recogido or espera_recogida > 0.0 or not cuerpo is Jugador:
		return
	if cuerpo.recoger_objeto(objeto):
		recogido = true
		set_deferred("monitoring", false)
		queue_free()
	else:
		aviso_lleno = true
