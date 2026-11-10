extends SceneTree

var fallos := 0
var directorio := "/workspace/capturas-nivel-uno"

func _initialize() -> void:
	call_deferred("ejecutar")

func ejecutar() -> void:
	var nivel: NivelUno = load("res://nivel_uno.tscn").instantiate()
	root.add_child(nivel)
	current_scene = nivel
	await create_timer(0.4).timeout
	await capturar("01-consulta-dialogo")

	while not nivel.lineas_dialogo.is_empty():
		nivel._avanzar_dialogo()
		await process_frame
	await mover_camara(nivel.jugador, Vector2(1620, 590))
	await capturar("02-pasillo-pacientes")

	await mover_camara(nivel.jugador, Vector2(3700, 650))
	nivel.estado = NivelUno.Estado.TOMAR_PASTILLAS
	nivel._mostrar_objetivo("Toma las pastillas de la mesilla")
	await capturar("03-dormitorio-dia")

	nivel.activar_noche_directa()
	await mover_camara(nivel.jugador, Vector2(3592, 692))
	await capturar("04-aparicion-nino")

	nivel.nino.hide()
	nivel._activar_alucinacion()
	nivel.jugador.alternar_linterna()
	await mover_camara(nivel.jugador, Vector2(3000, 600))
	await capturar("05-pasillo-alucinado-linterna")
	print("RESULTADO CAPTURAS NIVEL UNO: %d fallos" % fallos)
	quit(0 if fallos == 0 else 1)

func mover_camara(jugador: Jugador, destino: Vector2) -> void:
	jugador.global_position = destino
	jugador.direccion_mirada = Vector2.RIGHT
	jugador._actualizar_mano()
	jugador.get_node("Camara").reset_smoothing()
	for _indice in range(5):
		await process_frame

func capturar(nombre: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(directorio)
	var imagen := root.get_texture().get_image()
	var ruta := directorio.path_join(nombre + ".png")
	if imagen.is_empty() or imagen.save_png(ruta) != OK:
		fallos += 1
		push_error("No se pudo guardar " + ruta)
	else:
		print("CAPTURA: ", ruta)
