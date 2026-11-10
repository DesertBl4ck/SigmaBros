class_name PuertaMedica
extends StaticBody2D

signal abierta
var desbloqueada := false

func _ready() -> void:
	add_to_group("interactuables")
	add_to_group("obstaculos")
	add_to_group("puertas")

func punto_interaccion() -> Vector2:
	return global_position + Vector2(32, 12)

func texto_interaccion() -> String:
	return "Puerta abierta" if desbloqueada else "E · Usar tarjeta / abrir puerta"

func interactuar(jugador: Jugador) -> void:
	if desbloqueada:
		return
	if not jugador.tiene_tarjeta:
		jugador.mensaje.emit("La puerta está bloqueada. Necesitas una tarjeta de acceso.")
		return
	desbloqueada = true
	$CollisionShape2D.set_deferred("disabled", true)
	$Oclusion.hide()
	$Sprite2D.hide()
	jugador.mensaje.emit("Puerta desbloqueada. Conservas la tarjeta de acceso.")
	abierta.emit()
