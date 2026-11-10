extends SceneTree

var comprobaciones := 0
var fallos := 0
var hospital: Node2D
var jugador: Jugador

func _initialize() -> void:
	call_deferred("ejecutar")

func comprobar(condicion: bool, texto: String) -> void:
	comprobaciones += 1
	if condicion:
		print("OK · ", texto)
	else:
		fallos += 1
		push_error(texto)

func pasos(cantidad: int = 3) -> void:
	for _indice in range(cantidad):
		await physics_frame

func tecla(codigo: Key, repetida: bool = false) -> void:
	var evento := InputEventKey.new()
	evento.physical_keycode = codigo
	evento.pressed = true
	evento.echo = repetida
	Input.parse_input_event(evento)
	await process_frame
	evento = InputEventKey.new()
	evento.physical_keycode = codigo
	evento.pressed = false
	Input.parse_input_event(evento)
	await process_frame

func ejecutar() -> void:
	hospital = load("res://hospital.tscn").instantiate()
	root.add_child(hospital)
	current_scene = hospital
	jugador = hospital.get_node("Jugador")
	for enemigo in get_nodes_in_group("enemigos"):
		enemigo.set_physics_process(false)
	await pasos(5)
	var interfaz := hospital.get_node("Interfaz")
	var panel := interfaz.get_node("Inventario") as PanelContainer
	var ayuda := interfaz.get_node("AyudaLinterna") as PanelContainer

	comprobar(not panel.visible and not jugador.inventario_abierto, "El inventario empieza cerrado")
	comprobar(ayuda.visible and ayuda.get_node("Texto").text.contains("F"), "Se muestra la ayuda inicial de la linterna")
	await tecla(KEY_5)
	comprobar(not panel.visible and jugador.inventario.seleccionado == 0, "Los números no actúan con el inventario cerrado")
	jugador.recoger_tarjeta()
	comprobar(not panel.visible, "Recoger un objeto no abre el inventario")
	await tecla(KEY_I)
	comprobar(panel.visible and jugador.inventario_abierto, "I abre el inventario")
	comprobar(interfaz.descripcion.text.contains("F") and interfaz.seleccion.text == "Linterna", "La linterna muestra nombre y descripción")
	await tecla(KEY_I, true)
	comprobar(panel.visible, "Mantener I no alterna repetidamente el inventario")
	await tecla(KEY_2)
	comprobar(interfaz.seleccion.text == "Tarjeta de acceso" and interfaz.descripcion.text.contains("puerta médica"), "La tarjeta tiene una descripción útil")
	comprobar(interfaz.bordes[0].tooltip_text.contains("F") and interfaz.bordes[1].tooltip_text.contains("No se consume"), "Cada objeto ofrece una descripción")
	await tecla(KEY_I)
	comprobar(not panel.visible, "La segunda pulsación de I cierra el inventario")

	comprobar(not jugador.linterna_encendida and not jugador.linterna.visible and not jugador.rayo.enabled, "La linterna comienza apagada")
	comprobar(jugador.mano.visible, "La linterna apagada sigue visible en la mano")
	await tecla(KEY_F)
	comprobar(jugador.linterna_encendida and jugador.linterna.visible and jugador.rayo.enabled, "F enciende el cono de luz")
	comprobar(jugador.halo.visible and jugador.halo.texture_scale >= 3.0, "La linterna crea un círculo amplio alrededor del personaje")
	comprobar(not ayuda.visible and interfaz.estado_linterna.text.contains("encendida"), "La primera pulsación oculta la ayuda y actualiza el HUD")
	await tecla(KEY_F, true)
	comprobar(jugador.linterna_encendida, "Mantener F no produce parpadeos")
	await tecla(KEY_F)
	comprobar(not jugador.linterna_encendida and not jugador.linterna.visible, "F vuelve a apagar la linterna")

	await tecla(KEY_F)
	for entrada in [["mover_derecha", Vector2.RIGHT, "lado"], ["mover_izquierda", Vector2.LEFT, "lado"], ["mover_arriba", Vector2.UP, "arriba"], ["mover_abajo", Vector2.DOWN, "abajo"]]:
		Input.action_press(entrada[0])
		await pasos(4)
		Input.action_release(entrada[0])
		comprobar(jugador.sprite.animation == StringName(entrada[2]) and Vector2.RIGHT.rotated(jugador.mano.rotation).dot(entrada[1]) > 0.98, "Mano y cono orientados: " + entrada[0])
		comprobar(jugador.linterna.global_position.distance_to(jugador.mano.global_position) < 20.0, "El cono nace junto a la mano: " + entrada[0])

	await tecla(KEY_I)
	await tecla(KEY_1)
	jugador.position = Vector2(704, 576)
	jugador.direccion_mirada = Vector2.LEFT
	await tecla(KEY_Q)
	await pasos()
	comprobar(not jugador.inventario.contiene(Inventario.LINTERNA) and not jugador.mano.visible, "Descartar la linterna retira el equipo")
	await tecla(KEY_F)
	comprobar(not jugador.linterna_encendida and interfaz.texto_mensaje.text.contains("Necesitas"), "F informa si no se posee una linterna")
	var suelo: ObjetoRecogible
	for nodo in hospital.get_children():
		if nodo is ObjetoRecogible and nodo.objeto == Inventario.LINTERNA:
			suelo = nodo
	comprobar(is_instance_valid(suelo), "La linterna descartada queda en el escenario")
	if is_instance_valid(suelo):
		jugador.position = suelo.position
		await create_timer(0.9).timeout
		await pasos()
	comprobar(jugador.inventario.contiene(Inventario.LINTERNA) and not jugador.linterna_encendida, "Recogerla de nuevo la equipa apagada")

	await tecla(KEY_F)
	var armario: Armario = hospital.get_node("ArmarioHospitalizacion")
	armario.interactuar(jugador)
	comprobar(not jugador.mano.visible and not jugador.linterna.visible and not jugador.rayo.enabled, "Esconderse elimina toda emisión de luz")
	await tecla(KEY_F)
	comprobar(jugador.linterna_encendida and not jugador.linterna.visible, "F no cambia el estado mientras el jugador está oculto")
	armario.interactuar(jugador)
	comprobar(jugador.linterna.visible and jugador.mano.visible, "Salir restaura la linterna encendida")

	var nino: Enemigo = hospital.get_node("MonstruoNino")
	for animacion in [&"abajo", &"arriba", &"lado"]:
		var fotogramas := nino.sprite.sprite_frames
		comprobar(fotogramas.get_frame_count(animacion) == 4, "El niño tiene cuatro fotogramas: " + animacion)
		var huellas: Array[int] = []
		for indice in range(4):
			huellas.append(hash(fotogramas.get_frame_texture(animacion, indice).get_image().get_data()))
		comprobar(huellas.duplicate().all(func(huella): return huellas.count(huella) == 1), "Los fotogramas del niño son distintos: " + animacion)
		nino._animar(Vector2.DOWN if animacion == &"abajo" else Vector2.UP if animacion == &"arriba" else Vector2.RIGHT)
		nino.sprite.frame = 0
		await pasos(12)
		comprobar(nino.sprite.animation == animacion and nino.sprite.frame != 0, "La animación del niño avanza: " + animacion)
	nino._animar(Vector2.LEFT)
	comprobar(nino.sprite.flip_h and nino.sprite.animation == &"lado", "El niño se orienta a la izquierda")
	nino._animar(Vector2.RIGHT)
	comprobar(not nino.sprite.flip_h, "El niño se orienta a la derecha")
	print("RESULTADO INVENTARIO/LINTERNA/NIÑO: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	quit(0 if fallos == 0 else 1)
