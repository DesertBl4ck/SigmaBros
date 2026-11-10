class_name Armario
extends StaticBody2D

var ocupante: Jugador

func _ready() -> void:
	add_to_group("interactuables")
	add_to_group("obstaculos")

func punto_interaccion() -> Vector2:
	return global_position + Vector2(32, 24)

func texto_interaccion() -> String:
	return "E · Salir del armario" if is_instance_valid(ocupante) else "E · Esconderse"

func interactuar(jugador: Jugador) -> void:
	if ocupante == jugador:
		for desplazamiento in [Vector2(32, 32), Vector2(84, 0), Vector2(-20, 0)]:
			var salida: Vector2 = global_position + desplazamiento
			if _salida_libre(salida, jugador):
				jugador.salir_escondite(salida)
				ocupante = null
				jugador.mensaje.emit("Has salido del armario.")
				return
		jugador.mensaje.emit("La salida está obstruida.")
	elif not is_instance_valid(ocupante):
		ocupante = jugador
		jugador.entrar_escondite(self)
		jugador.mensaje.emit("Estás oculto. Pulsa E para salir.")

func _salida_libre(salida: Vector2, jugador: Jugador) -> bool:
	var forma := RectangleShape2D.new()
	forma.size = Vector2(26, 22)
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0.0, salida + Vector2(0, -10))
	consulta.collision_mask = 5
	consulta.exclude = [jugador.get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(consulta).is_empty()
