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

func ejecutar() -> void:
	hospital = load("res://hospital.tscn").instantiate()
	root.add_child(hospital)
	current_scene = hospital
	jugador = hospital.get_node("Jugador")
	for enemigo in get_nodes_in_group("enemigos"):
		enemigo.set_physics_process(false)
	await pasos(6)

	comprobar(DisenoHospital.TAMANO == Vector2(3072, 2048), "El hospital ocupa 3072 × 2048")
	comprobar(DisenoHospital.SECTORES.size() == 10, "Existen diez zonas funcionales")
	var nombres := ""
	for sector in DisenoHospital.SECTORES:
		nombres += String(sector.nombre) + " "
	for requerida in ["RECEPCIÓN", "CONSULTA", "TERAPIA", "ENFERMERÍA", "HOSPITALIZACIÓN", "COMEDOR", "AISLAMIENTO", "ARCHIVO", "MANTENIMIENTO"]:
		comprobar(nombres.contains(requerida), "Zona identificable: " + requerida)

	var mapa := hospital.get_node("MapaHospital")
	comprobar(mapa.get_child_count() == DisenoHospital.MUROS.size() + DisenoHospital.MUEBLES.size(), "Mapa físico generado a partir del diseño")
	var oclusores_muros := 0
	var muebles_con_oclusor := 0
	var colisiones := 0
	for nodo in mapa.get_children():
		if nodo is CollisionObject2D and nodo.has_node("CollisionShape2D"):
			colisiones += 1
		if nodo.name.begins_with("Muro") and nodo.has_node("Oclusion") and nodo.get_node("Oclusion").occluder != null:
			oclusores_muros += 1
		if nodo.name.begins_with("Mueble") and nodo.has_node("Oclusion"):
			muebles_con_oclusor += 1
	var muebles_solidos := 0
	var colisiones_cubren_dibujo := true
	for datos in DisenoHospital.MUEBLES:
		if datos.solido:
			muebles_solidos += 1
	for nodo in mapa.get_children():
		if nodo is MuebleHospital and nodo.solido:
			var forma: RectangleShape2D = nodo.get_node("CollisionShape2D").shape
			colisiones_cubren_dibujo = colisiones_cubren_dibujo and forma.size.x >= nodo.tamano.x - 4.0 and forma.size.y >= nodo.tamano.y
	comprobar(colisiones == DisenoHospital.MUROS.size() + muebles_solidos, "Muros y mobiliario sólido tienen colisión")
	comprobar(colisiones_cubren_dibujo, "Ningún personaje puede entrar en la silueta de los muebles")
	comprobar(oclusores_muros == DisenoHospital.MUROS.size(), "Cada pared bloquea la luz")
	comprobar(muebles_con_oclusor == 0, "La luz atraviesa escritorios, sillas y demás mobiliario")
	comprobar(hospital.get_node("Oscuridad").color == Color.BLACK, "La oscuridad ambiental es absoluta")
	comprobar(hospital.get_node("Interfaz") is CanvasLayer and hospital.get_node("Interfaz").layer > 0, "La interfaz permanece en una capa visible")

	comprobar(not jugador.linterna_encendida and not jugador.linterna.visible and not jugador.halo.visible, "La linterna empieza apagada y sin halo")
	comprobar(jugador.inventario.contiene(Inventario.LINTERNA) and jugador.mano.visible, "La linterna está equipada en la mano")
	comprobar(jugador.linterna.shadow_enabled, "El cono de la linterna proyecta sombras")
	var tamano_jugador := jugador.sprite.sprite_frames.get_frame_texture(&"abajo", 0).get_size() * jugador.sprite.scale
	comprobar(tamano_jugador.is_equal_approx(Vector2(64, 64)), "El jugador conserva una escala visual de 64 × 64")
	var camas_coherentes := true
	for mueble in DisenoHospital.MUEBLES:
		if mueble.tipo in [&"cama", &"camilla", &"cama_aislamiento"]:
			camas_coherentes = camas_coherentes and mueble.tam == Vector2(112, 64)
	comprobar(camas_coherentes, "Camas y camillas comparten proporciones coherentes con los personajes")
	var camara := jugador.get_node("Camara") as Camera2D
	comprobar(camara.limit_right == 3072 and camara.limit_bottom == 2048, "La cámara respeta los límites del edificio")
	comprobar(camara.position_smoothing_enabled, "La cámara sigue al jugador con suavizado")
	jugador.position = Vector2(960, 150)
	Input.action_press("mover_abajo")
	await pasos(60)
	Input.action_release("mover_abajo")
	comprobar(jugador.position.y <= 217.0, "El escritorio detiene al personaje antes de superponerlo")
	jugador.position = Vector2(704, 576)

	comprobar(hospital.navegacion_lista, "La malla de navegación se construye al iniciar")
	comprobar(not hospital.buscar_camino(jugador.position, Vector2(2400, 736)).is_empty(), "La tarjeta es accesible desde recepción")
	var puerta: PuertaMedica = hospital.get_node("PuertaAislamiento")
	comprobar(hospital.buscar_camino(Vector2(1600, 1504), Vector2(1900, 1504)).is_empty(), "La puerta cerrada aísla el sector restringido")
	jugador.recoger_tarjeta()
	puerta.interactuar(jugador)
	await pasos(5)
	comprobar(puerta.desbloqueada and puerta.get_node("CollisionShape2D").disabled, "La tarjeta abre la puerta y retira su colisión")
	comprobar(not hospital.buscar_camino(Vector2(1600, 1504), Vector2(1900, 1504)).is_empty(), "Abrir la puerta conecta aislamiento")
	comprobar(jugador.tiene_tarjeta, "La tarjeta se conserva después de abrir")

	var atajo: PuertaMedica = hospital.get_node("PuertaAtajo")
	comprobar(not atajo.desbloqueada, "El atajo empieza cerrado")
	atajo.interactuar(jugador)
	await pasos(5)
	comprobar(atajo.desbloqueada, "La misma tarjeta abre el atajo secundario")

	var armarios := get_nodes_in_group("interactuables").filter(func(nodo): return nodo is Armario)
	comprobar(armarios.size() == 3, "Hay escondites distribuidos por el hospital")
	var armario: Armario = hospital.get_node("ArmarioHospitalizacion")
	jugador.position = armario.punto_interaccion()
	armario.interactuar(jugador)
	comprobar(jugador.oculto and not jugador.visible and jugador.collision_layer == 0, "El armario oculta y desactiva al jugador")
	var adulto: Enemigo = hospital.get_node("MonstruoAdulto")
	comprobar(not adulto.ve_jugador(), "Los enemigos no detectan al jugador oculto")
	armario.interactuar(jugador)
	comprobar(not jugador.oculto and jugador.visible and jugador.collision_layer == 2, "Salir del armario restaura al jugador")

	for nombre in ["MonstruoAdulto", "MonstruoNino"]:
		var enemigo: Enemigo = hospital.get_node(nombre)
		comprobar(enemigo.ruta_patrulla.size() >= 4, nombre + " tiene una ruta de patrulla amplia")
		comprobar(enemigo.sprite.sprite_frames.has_animation(&"arriba") and enemigo.sprite.sprite_frames.has_animation(&"abajo") and enemigo.sprite.sprite_frames.has_animation(&"lado"), nombre + " conserva animaciones direccionales")

	jugador.position = Vector2(1500, 1056)
	adulto.position = Vector2(1630, 1056)
	await pasos()
	comprobar(adulto.ve_jugador(), "El enemigo detecta con línea de visión directa")
	jugador.position = Vector2(1000, 760)
	adulto.position = Vector2(1000, 900)
	await pasos()
	comprobar(not adulto.ve_jugador(), "Los muros bloquean la visión enemiga")

	var original := jugador.position
	jugador.position = Vector2(80, 100)
	Input.action_press("mover_izquierda")
	await pasos(30)
	Input.action_release("mover_izquierda")
	comprobar(jugador.position.x >= 43.0, "El límite exterior impide abandonar el mapa")
	jugador.position = original

	comprobar(ResourceLoader.exists("res://recursos/hospital_abandonado/atlas_mobiliario.png"), "El mobiliario nuevo está guardado como recurso del proyecto")
	comprobar(hospital.get_node("Polvo").emitting, "El ambiente conserva partículas de polvo")
	print("RESULTADO INTEGRACIÓN: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	quit(0 if fallos == 0 else 1)
