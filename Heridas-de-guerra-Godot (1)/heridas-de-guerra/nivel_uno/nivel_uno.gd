class_name NivelUno
extends Node2D

enum Estado { CHARLA, IR_HABITACION, TOMAR_PASTILLAS, CHARLA_PASTILLAS, DORMIR, NOCHE_NINO, ALUCINACION, TRANSICION }

const PUNTO_PASTILLAS := Vector2(3832, 526)
const PUNTO_CAMA := Vector2(3696, 640)

var estado := Estado.CHARLA
var lineas_dialogo: Array[Dictionary] = []
var indice_dialogo := 0
var al_terminar_dialogo := Callable()
var burbuja: PanelContainer
var secuencia_en_curso := false

@onready var jugador: Jugador = $Jugador
@onready var psicologo: NpcNormal = $Psicologo
@onready var nino: Enemigo = $Nino
@onready var visual: VisualNivelUno = $Visual
@onready var oscuridad: CanvasModulate = $Oscuridad
@onready var luz_luna: PointLight2D = $LuzLuna
@onready var capitulo: Label = $InterfazNivelUno/Capitulo
@onready var objetivo: PanelContainer = $InterfazNivelUno/Objetivo
@onready var texto_objetivo: Label = $InterfazNivelUno/Objetivo/Texto
@onready var indicacion: PanelContainer = $InterfazNivelUno/Indicacion
@onready var texto_indicacion: Label = $InterfazNivelUno/Indicacion/Texto
@onready var ayuda_dialogo: Label = $InterfazNivelUno/AyudaDialogo
@onready var fundido: ColorRect = $InterfazNivelUno/Fundido

func _ready() -> void:
	add_to_group("nivel_historia")
	jugador.linterna_habilitada = false
	jugador.inventario_habilitado = false
	jugador.sin_control = true
	jugador._sincronizar_equipo()
	jugador.get_node("Camara").limit_right = int(DisenoNivelUno.TAMANO.x)
	jugador.get_node("Camara").limit_bottom = int(DisenoNivelUno.TAMANO.y)
	nino.activo = false
	nino.visible = false
	nino.collision_layer = 0
	nino.collision_mask = 0
	for npc in get_tree().get_nodes_in_group("npcs_normales"):
		npc.pausado = false
	await get_tree().process_frame
	_iniciar_charla_psicologo()
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(capitulo, "modulate:a", 0.0, 1.0)

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_echo():
		return
	if not lineas_dialogo.is_empty() and (evento.is_action_pressed("interactuar") or evento.is_action_pressed("ui_accept")):
		_avanzar_dialogo()
		get_viewport().set_input_as_handled()
		return
	if evento.is_action_pressed("interactuar"):
		if estado == Estado.TOMAR_PASTILLAS and jugador.global_position.distance_to(PUNTO_PASTILLAS) < 105.0:
			_iniciar_secuencia_pastillas()
		elif estado == Estado.DORMIR and jugador.global_position.distance_to(PUNTO_CAMA) < 125.0:
			_dormir()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if estado == Estado.IR_HABITACION and jugador.global_position.x > 3410.0:
		estado = Estado.TOMAR_PASTILLAS
		_mostrar_objetivo("Toma las pastillas de la mesilla")
	_actualizar_indicacion()
	if estado == Estado.ALUCINACION and jugador.global_position.x < 825.0 and not secuencia_en_curso:
		_entrar_hospital_abandonado()

func _iniciar_charla_psicologo() -> void:
	var lineas: Array[Dictionary] = [
		{"habla": psicologo, "nombre": "PSICÓLOGO", "texto": "Buenos días. Quiero que hablemos de las alucinaciones de anoche."},
		{"habla": jugador, "nombre": "SOLDADO", "texto": "Volví a verlos… soldados, niños. Personas que murieron allá."},
		{"habla": psicologo, "nombre": "PSICÓLOGO", "texto": "Son recuerdos intrusivos del trauma. Ahora estás en el hospital y estás a salvo."},
		{"habla": jugador, "nombre": "SOLDADO", "texto": "Cuando cierro los ojos, el lugar cambia. Parece abandonado y ellos vienen por mí."},
		{"habla": psicologo, "nombre": "PSICÓLOGO", "texto": "Toma únicamente la dosis recetada. Más pastillas pueden empeorar las alucinaciones."},
		{"habla": jugador, "nombre": "SOLDADO", "texto": "Entendido."},
		{"habla": psicologo, "nombre": "PSICÓLOGO", "texto": "Ve a descansar. Mañana continuaremos."},
	]
	_iniciar_dialogo(lineas, _terminar_consulta)

func _terminar_consulta() -> void:
	estado = Estado.IR_HABITACION
	jugador.sin_control = false
	psicologo.pausado = true
	_mostrar_objetivo("Dirígete a tu habitación")

func _iniciar_secuencia_pastillas() -> void:
	estado = Estado.CHARLA_PASTILLAS
	jugador.sin_control = true
	var lineas: Array[Dictionary] = [
		{"habla": jugador, "nombre": "SOLDADO", "texto": "(Toma la dosis indicada con un poco de agua.)"},
		{"habla": jugador, "nombre": "SOLDADO", "texto": "No puedo dormir. Siguen ahí cuando cierro los ojos."},
		{"habla": jugador, "nombre": "SOLDADO", "texto": "(Duda… y toma varias pastillas más.)"},
		{"habla": jugador, "nombre": "SOLDADO", "texto": "Solo quiero que las voces se callen."},
	]
	_iniciar_dialogo(lineas, _terminar_pastillas)

func _terminar_pastillas() -> void:
	estado = Estado.DORMIR
	jugador.sin_control = false
	_mostrar_objetivo("Acuéstate para intentar dormir")

func _iniciar_dialogo(lineas: Array[Dictionary], terminado: Callable) -> void:
	lineas_dialogo = lineas
	indice_dialogo = 0
	al_terminar_dialogo = terminado
	jugador.sin_control = true
	ayuda_dialogo.show()
	_mostrar_linea()

func _mostrar_linea() -> void:
	_eliminar_burbuja()
	if indice_dialogo >= lineas_dialogo.size():
		lineas_dialogo.clear()
		ayuda_dialogo.hide()
		var callback := al_terminar_dialogo
		al_terminar_dialogo = Callable()
		if callback.is_valid():
			callback.call()
		return
	var linea := lineas_dialogo[indice_dialogo]
	var hablante: Node2D = linea["habla"]
	burbuja = PanelContainer.new()
	burbuja.name = "BurbujaDialogo"
	burbuja.z_index = 100
	# El cuadro queda al lado de la cabeza y permanece dentro del encuadre aun
	# cuando el hablante está cerca de una pared superior.
	burbuja.position = Vector2(58, -92)
	burbuja.custom_minimum_size = Vector2(410, 116)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.96, 0.95, 0.86, 0.97)
	estilo.border_color = Color("243034")
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(7)
	estilo.set_content_margin_all(13)
	burbuja.add_theme_stylebox_override("panel", estilo)
	var etiqueta := Label.new()
	etiqueta.name = "Texto"
	etiqueta.text = "%s\n%s" % [linea["nombre"], linea["texto"]]
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.add_theme_color_override("font_color", Color("182328"))
	etiqueta.add_theme_font_size_override("font_size", 17)
	burbuja.add_child(etiqueta)
	hablante.add_child(burbuja)

func _avanzar_dialogo() -> void:
	indice_dialogo += 1
	_mostrar_linea()

func _eliminar_burbuja() -> void:
	if is_instance_valid(burbuja):
		burbuja.queue_free()
	burbuja = null

func _mostrar_objetivo(texto: String) -> void:
	texto_objetivo.text = "OBJETIVO · " + texto
	objetivo.show()
	objetivo.modulate.a = 0.0
	create_tween().tween_property(objetivo, "modulate:a", 1.0, 0.25)

func _actualizar_indicacion() -> void:
	var mostrar := false
	if estado == Estado.TOMAR_PASTILLAS and jugador.global_position.distance_to(PUNTO_PASTILLAS) < 105.0:
		texto_indicacion.text = "E · Tomar la medicación"
		mostrar = true
	elif estado == Estado.DORMIR and jugador.global_position.distance_to(PUNTO_CAMA) < 125.0:
		texto_indicacion.text = "E · Acostarse"
		mostrar = true
	indicacion.visible = mostrar

func _dormir() -> void:
	if secuencia_en_curso:
		return
	secuencia_en_curso = true
	estado = Estado.NOCHE_NINO
	jugador.sin_control = true
	objetivo.hide()
	indicacion.hide()
	await _fundir(true, 0.8)
	visual.establecer_noche(true)
	oscuridad.color = Color("344154")
	luz_luna.show()
	jugador.global_position = Vector2(3592, 692)
	jugador.direccion_mirada = Vector2.UP
	nino.global_position = Vector2(3608, 484)
	nino.visible = true
	await _fundir(false, 1.1)
	await get_tree().create_timer(1.25).timeout
	_iniciar_dialogo([{"habla": jugador, "nombre": "SOLDADO", "texto": "¿Quién eres…?"}], Callable())
	await get_tree().create_timer(2.0).timeout
	lineas_dialogo.clear()
	_eliminar_burbuja()
	ayuda_dialogo.hide()
	await get_tree().create_timer(1.0).timeout
	await _nino_sale()
	_activar_alucinacion()

func _nino_sale() -> void:
	nino.sprite.play("lado")
	nino.sprite.flip_h = true
	var tween := create_tween()
	tween.tween_property(nino, "global_position", Vector2(3388, 610), 2.0)
	tween.tween_property(nino, "global_position", Vector2(3190, 610), 1.35)
	await tween.finished
	nino.sprite.stop()
	nino.hide()

func _activar_alucinacion() -> void:
	visual.establecer_alucinacion(true)
	oscuridad.color = Color("18212a")
	luz_luna.energy = 0.65
	for npc in get_tree().get_nodes_in_group("npcs_normales"):
		npc.establecer_alucinacion(true)
	for mueble in get_tree().get_nodes_in_group("mobiliario_normal"):
		mueble.establecer_alucinacion(true)
	jugador.linterna_habilitada = true
	jugador.inventario_habilitado = true
	jugador.sin_control = false
	jugador._sincronizar_equipo()
	estado = Estado.ALUCINACION
	secuencia_en_curso = false
	_mostrar_objetivo("El hospital ha cambiado. Regresa por el pasillo · F: linterna")

func activar_noche_directa() -> void:
	# Punto de acceso estable para pruebas y revisión visual de la secuencia.
	visual.establecer_noche(true)
	objetivo.hide()
	indicacion.hide()
	luz_luna.show()
	nino.visible = true
	nino.global_position = Vector2(3608, 484)
	jugador.global_position = Vector2(3592, 692)
	oscuridad.color = Color("344154")
	estado = Estado.NOCHE_NINO

func _entrar_hospital_abandonado() -> void:
	secuencia_en_curso = true
	estado = Estado.TRANSICION
	jugador.sin_control = true
	await _fundir(true, 0.7)
	get_tree().change_scene_to_file("res://hospital.tscn")

func _fundir(a_negro: bool, duracion: float) -> void:
	var destino := 1.0 if a_negro else 0.0
	var tween := create_tween()
	tween.tween_property(fundido, "color:a", destino, duracion)
	await tween.finished
