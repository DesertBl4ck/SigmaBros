extends SceneTree

var fallos := 0

func _initialize() -> void:
	call_deferred("ejecutar")

func capturar(nombre: String) -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	var argumentos := OS.get_cmdline_user_args()
	var directorio := argumentos[0] if not argumentos.is_empty() else "user://capturas"
	DirAccess.make_dir_recursive_absolute(directorio)
	var ruta := directorio.path_join(nombre + ".png")
	var imagen := root.get_texture().get_image()
	if imagen.is_empty() or imagen.save_png(ruta) != OK:
		fallos += 1
		push_error("No se pudo guardar " + ruta)
	else:
		print("CAPTURA: ", ruta)
	return imagen

func ejecutar() -> void:
	var hospital: Node2D = load("res://hospital.tscn").instantiate()
	root.add_child(hospital)
	current_scene = hospital
	for enemigo in get_nodes_in_group("enemigos"):
		enemigo.set_physics_process(false)
	await create_timer(0.35).timeout
	var jugador: Jugador = hospital.get_node("Jugador")

	var apagada := await capturar("01-recepcion-linterna-apagada")
	await pulsar(KEY_F)
	await create_timer(0.2).timeout
	var encendida := await capturar("02-recepcion-linterna-encendida")
	verificar(not apagada.is_empty() and apagada.get_size() == Vector2i(1366, 768), "La ventana renderiza a 1366 × 768")
	if not apagada.is_empty() and not encendida.is_empty():
		var zona := Rect2i(420, 180, 620, 420)
		verificar(intensidad(encendida, zona) > intensidad(apagada, zona) + 0.001, "F hace visible el entorno mediante el círculo y el cono")

	jugador.recoger_tarjeta()
	await pulsar(KEY_I)
	await capturar("03-inventario-descripciones")
	await pulsar(KEY_I)

	await mover_camara(jugador, Vector2(1512, 1056))
	await capturar("04-pasillos-principales")
	await mover_camara(jugador, Vector2(2080, 320))
	await capturar("05-terapia")
	await mover_camara(jugador, Vector2(512, 1840))
	await capturar("06-hospitalizacion")
	await mover_camara(jugador, Vector2(1600, 1504))
	await capturar("07-acceso-restringido")

	var puerta: PuertaMedica = hospital.get_node("PuertaAislamiento")
	puerta.interactuar(jugador)
	await create_timer(0.2).timeout
	await mover_camara(jugador, Vector2(1984, 1568))
	await capturar("08-aislamiento")
	await mover_camara(jugador, Vector2(2496, 1800))
	await capturar("09-archivo-medico")
	await mover_camara(jugador, Vector2(2848, 1680))
	await capturar("10-mantenimiento")

	var armario: Armario = hospital.get_node("ArmarioMantenimiento")
	armario.interactuar(jugador)
	await capturar("11-jugador-oculto")
	armario.interactuar(jugador)
	jugador.recibir_ataque()
	await capturar("12-derrota")
	print("RESULTADO GRÁFICO: 2 comprobaciones, %d fallos" % fallos)
	quit(0 if fallos == 0 else 1)

func mover_camara(jugador: Jugador, destino: Vector2) -> void:
	jugador.position = destino
	jugador.direccion_mirada = Vector2.RIGHT
	jugador._actualizar_mano()
	jugador.get_node("Camara").reset_smoothing()
	for _indice in range(4):
		await process_frame

func intensidad(imagen: Image, zona: Rect2i) -> float:
	var total := 0.0
	for y in range(zona.position.y, zona.end.y, 3):
		for x in range(zona.position.x, zona.end.x, 3):
			total += imagen.get_pixel(x, y).get_luminance()
	return total / float((zona.size.x / 3) * (zona.size.y / 3))

func verificar(condicion: bool, texto: String) -> void:
	if condicion:
		print("OK · ", texto)
	else:
		fallos += 1
		push_error(texto)

func pulsar(tecla: Key) -> void:
	var evento := InputEventKey.new()
	evento.physical_keycode = tecla
	evento.pressed = true
	Input.parse_input_event(evento)
	await process_frame
	evento = InputEventKey.new()
	evento.physical_keycode = tecla
	evento.pressed = false
	Input.parse_input_event(evento)
	await process_frame
