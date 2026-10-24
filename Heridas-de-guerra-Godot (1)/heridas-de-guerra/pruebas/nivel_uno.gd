extends SceneTree

var comprobaciones := 0
var fallos := 0
var nivel: NivelUno
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
	nivel = load("res://nivel_uno.tscn").instantiate()
	root.add_child(nivel)
	current_scene = nivel
	await pasos(8)
	jugador = nivel.get_node("Jugador")

	comprobar(nivel.estado == NivelUno.Estado.CHARLA, "El nivel empieza con la charla del psicólogo")
	comprobar(jugador.sin_control, "La cinemática bloquea el movimiento del jugador")
	comprobar(is_instance_valid(nivel.burbuja) and nivel.burbuja.get_parent() == nivel.psicologo, "El diálogo aparece junto a quien habla")
	comprobar(not jugador.linterna_habilitada and not jugador.mano.visible, "La linterna permanece guardada durante el mundo normal")
	comprobar(not jugador.inventario_habilitado, "El inventario no interrumpe la cinemática")
	comprobar(DisenoNivelUno.TAMANO == Vector2(4096, 1152), "El pasillo ofrece un recorrido largo de exploración")
	comprobar(get_nodes_in_group("npcs_normales").size() == 9, "El psicólogo y ocho pacientes pueblan el hospital")

	var mapa: Node2D = nivel.get_node("Mapa")
	var muros := 0
	var oclusores_mueble := 0
	var muebles_solidos := 0
	var colisiones_cubren_dibujo := true
	for nodo in mapa.get_children():
		if nodo.name.begins_with("Muro") and nodo.has_node("OclusionArquitectonica"):
			muros += 1
		if nodo is MuebleNormal:
			if nodo.has_node("OclusionArquitectonica"):
				oclusores_mueble += 1
			if nodo.solido and nodo.has_node("ColisionFisica"):
				muebles_solidos += 1
				var forma: RectangleShape2D = nodo.get_node("ColisionFisica").shape
				colisiones_cubren_dibujo = colisiones_cubren_dibujo and forma.size.x >= nodo.tamano.x - 4.0 and forma.size.y >= nodo.tamano.y
	var esperados_solidos := DisenoNivelUno.MUEBLES.filter(func(datos): return datos.solido).size()
	comprobar(muros == DisenoNivelUno.MUROS.size(), "Todas las paredes bloquean la linterna")
	comprobar(oclusores_mueble == 0, "La luz atraviesa escritorios, sillas y camas")
	comprobar(muebles_solidos == esperados_solidos, "Los muebles impiden que el personaje camine sobre ellos")
	comprobar(colisiones_cubren_dibujo, "La colisión cubre toda la silueta de cada mueble")
	comprobar(ResourceLoader.exists("res://recursos/hospital_normal/atlas_normal.png"), "El nivel usa mobiliario clínico detallado")
	comprobar(ResourceLoader.exists("res://recursos/hospital_normal/ventana_dia_noche.png"), "La ventana tiene arte propio para el día y la noche")

	var paciente: NpcNormal = nivel.get_node("PacienteSuperior1")
	var psicologo: NpcNormal = nivel.get_node("Psicologo")
	for npc in [psicologo, paciente]:
		for animacion in [&"abajo", &"arriba", &"lado"]:
			comprobar(npc.sprite.sprite_frames.get_frame_count(animacion) == 4, "%s tiene cuatro pasos animados hacia %s" % [npc.name, animacion])
	var tamano_npc := paciente.sprite.sprite_frames.get_frame_texture(&"abajo", 0).get_size() * paciente.sprite.scale
	comprobar(tamano_npc.x <= 64.0 and tamano_npc.y <= 64.0 and tamano_npc.y >= 52.0, "Los personajes nuevos respetan el marco visual de 64 × 64")
	paciente._animar(Vector2.LEFT)
	comprobar(paciente.sprite.animation == &"lado" and paciente.sprite.flip_h, "La animación lateral se refleja hacia la izquierda")
	paciente._animar(Vector2.UP)
	comprobar(paciente.sprite.animation == &"arriba" and not paciente.sprite.flip_h, "El paciente anima el movimiento hacia arriba")
	var posicion_npc := paciente.position
	var cuadro_inicial := paciente.sprite.frame
	await pasos(20)
	comprobar(paciente.position.distance_to(posicion_npc) > 1.0, "Los pacientes se mueven dentro de sus habitaciones")
	comprobar(paciente.sprite.frame != cuadro_inicial, "El ciclo de caminar avanza entre fotogramas distintos")

	while not nivel.lineas_dialogo.is_empty():
		nivel._avanzar_dialogo()
		await process_frame
	comprobar(nivel.estado == NivelUno.Estado.IR_HABITACION and not jugador.sin_control, "La conversación libera al jugador al terminar")
	comprobar(nivel.texto_objetivo.text.contains("Dirígete a tu habitación"), "La misión indica el siguiente objetivo")

	jugador.global_position = Vector2(3470, 610)
	await pasos()
	comprobar(nivel.estado == NivelUno.Estado.TOMAR_PASTILLAS, "Entrar al dormitorio activa las pastillas")
	jugador.global_position = NivelUno.PUNTO_PASTILLAS
	nivel._iniciar_secuencia_pastillas()
	while not nivel.lineas_dialogo.is_empty():
		nivel._avanzar_dialogo()
		await process_frame
	comprobar(nivel.estado == NivelUno.Estado.DORMIR, "La sobredosis conduce al objetivo de dormir")
	comprobar(nivel.texto_objetivo.text.contains("Acuéstate"), "El juego guía al jugador hasta la cama")

	nivel.activar_noche_directa()
	comprobar(nivel.visual.modo_noche and nivel.luz_luna.visible, "La ventana y la luz cambian a la noche")
	comprobar(nivel.nino.visible and nivel.nino.global_position == Vector2(3608, 484), "El niño aparece delante de la cama bajo la luna")
	comprobar(not nivel.objetivo.visible, "La aparición nocturna limpia los objetivos anteriores")
	Engine.time_scale = 40.0
	nivel._dormir()
	for _indice in range(180):
		await process_frame
		if nivel.estado == NivelUno.Estado.ALUCINACION:
			break
	Engine.time_scale = 1.0
	comprobar(nivel.estado == NivelUno.Estado.ALUCINACION, "La sobredosis transforma el hospital en el mundo alucinado")
	comprobar(not nivel.nino.visible, "El niño abandona el dormitorio sin atacar")
	comprobar(nivel.visual.modo_alucinacion, "El entorno muestra deterioro y manchas durante la alucinación")
	comprobar(jugador.linterna_habilitada and jugador.inventario_habilitado, "La linterna y el inventario se habilitan para escapar")
	comprobar(get_nodes_in_group("npcs_normales").all(func(npc): return not npc.visible), "Los pacientes normales desaparecen del mundo alterado")

	print("RESULTADO NIVEL UNO: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	quit(0 if fallos == 0 else 1)
