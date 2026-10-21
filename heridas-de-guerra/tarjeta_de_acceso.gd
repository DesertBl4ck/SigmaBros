extends Area2D


func _ready() -> void:
	body_entered.connect(_al_tocar_jugador)


func _al_tocar_jugador(cuerpo: Node2D) -> void:
	if cuerpo.has_method("recoger_tarjeta"):
		cuerpo.recoger_tarjeta()
		queue_free()
