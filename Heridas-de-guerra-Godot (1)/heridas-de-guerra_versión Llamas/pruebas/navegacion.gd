extends SceneTree

var fallos := 0
var comprobaciones := 0

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

func ejecutar() -> void:
	var hospital: Node2D = load("res://hospital.tscn").instantiate()
	root.add_child(hospital)
	current_scene = hospital
	var jugador: Jugador = hospital.get_node("Jugador")
	for enemigo in get_nodes_in_group("enemigos"):
		enemigo.set_physics_process(false)
	await pasos(6)

	var origen := Vector2(1512, 1056)
	var destinos := {
		"recepción": Vector2(704, 576),
		"administración": Vector2(1056, 256),
		"terapia": Vector2(2080, 352),
		"consultorios": Vector2(2400, 128),
		"enfermería": Vector2(2400, 736),
		"hospitalización": Vector2(480, 1840),
		"comedor": Vector2(1216, 1840),
		"archivo": Vector2(2480, 1904),
		"mantenimiento": Vector2(2784, 1536),
	}
	for zona in destinos:
		var camino: PackedVector2Array = hospital.buscar_camino(origen, destinos[zona])
		comprobar(not camino.is_empty(), "Ruta válida hasta " + zona)

	var cerrada: PackedVector2Array = hospital.buscar_camino(Vector2(1600, 1504), Vector2(1900, 1504))
	comprobar(cerrada.is_empty(), "Aislamiento queda sellado por la puerta")
	jugador.recoger_tarjeta()
	var puerta: PuertaMedica = hospital.get_node("PuertaAislamiento")
	puerta.interactuar(jugador)
	await pasos(5)
	var abierta: PackedVector2Array = hospital.buscar_camino(Vector2(1600, 1504), Vector2(1900, 1504))
	comprobar(not abierta.is_empty(), "La puerta abierta habilita la ruta de aislamiento")
	for punto in abierta:
		var celda: Array[Vector2i] = hospital.navegacion.get_id_path(hospital.celda_cercana(Vector2(1600, 1504)), hospital.celda_cercana(punto))
		comprobar(not celda.is_empty(), "Cada tramo abierto pertenece a la malla transitable")

	var antes: PackedVector2Array = hospital.buscar_camino(Vector2(1500, 1800), Vector2(1200, 1800))
	var atajo: PuertaMedica = hospital.get_node("PuertaAtajo")
	atajo.interactuar(jugador)
	await pasos(5)
	var despues: PackedVector2Array = hospital.buscar_camino(Vector2(1500, 1800), Vector2(1200, 1800))
	comprobar(not antes.is_empty() and not despues.is_empty(), "El comedor tiene ruta alternativa aunque el atajo esté cerrado")
	comprobar(despues.size() < antes.size(), "Abrir el atajo acorta el recorrido")

	var adulto: Enemigo = hospital.get_node("MonstruoAdulto")
	jugador.entrar_escondite(hospital.get_node("ArmarioHospitalizacion"))
	adulto.position = Vector2(1184, 1056)
	adulto.ruta_patrulla = PackedVector2Array([Vector2(1512, 1056), Vector2(1512, 1344)])
	adulto.set_physics_process(true)
	var inicial := adulto.position
	await pasos(150)
	adulto.set_physics_process(false)
	comprobar(adulto.position.distance_to(inicial) > 80.0, "El adulto patrulla por los pasillos con AStar")
	comprobar(not adulto.ve_jugador(), "La ocultación rompe la detección durante la patrulla")

	jugador.salir_escondite(Vector2(1512, 1056))
	adulto.position = Vector2(1620, 1056)
	adulto.estado = Enemigo.Estado.PATRULLA
	adulto._physics_process(0.016)
	comprobar(adulto.estado == Enemigo.Estado.PERSECUCION, "La visión directa inicia persecución")
	jugador.entrar_escondite(hospital.get_node("ArmarioArchivo"))
	adulto._physics_process(0.016)
	comprobar(adulto.estado == Enemigo.Estado.BUSQUEDA, "Esconderse cambia persecución por búsqueda")
	adulto._physics_process(adulto.duracion_busqueda + 0.1)
	comprobar(adulto.estado == Enemigo.Estado.PATRULLA, "La búsqueda termina y reanuda la patrulla")

	print("RESULTADO NAVEGACIÓN: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	quit(0 if fallos == 0 else 1)
