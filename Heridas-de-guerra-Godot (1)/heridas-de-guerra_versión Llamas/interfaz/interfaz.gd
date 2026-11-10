extends CanvasLayer

@export var duracion_mensaje: float = 3.0
var jugador: Jugador
var iconos: Array[TextureRect] = []
var bordes: Array[PanelContainer] = []
var transcurrido := 0.0
@onready var panel_mensaje: PanelContainer = $Mensajes
@onready var texto_mensaje: Label = $Mensajes/Texto
@onready var reloj: Timer = $Duracion
@onready var seleccion: Label = $Inventario/Columna/Seleccion
@onready var indicacion: Label = $Indicacion
@onready var descripcion: Label = $Inventario/Columna/Descripcion
@onready var estado_linterna: Label = $EstadoLinterna
@onready var ayuda_linterna: PanelContainer = $AyudaLinterna

func _ready() -> void:
	reloj.timeout.connect(panel_mensaje.hide)
	for indice in range(Inventario.CAPACIDAD):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(64, 62)
		var caja := VBoxContainer.new()
		var numero := Label.new()
		numero.text = str(indice + 1)
		numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		numero.add_theme_font_size_override("font_size", 13)
		var icono := TextureRect.new()
		icono.custom_minimum_size = Vector2(32, 28)
		icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		caja.add_child(numero)
		caja.add_child(icono)
		panel.add_child(caja)
		$Inventario/Columna/Espacios.add_child(panel)
		bordes.append(panel)
		iconos.append(icono)

func vincular(personaje: Jugador) -> void:
	jugador = personaje
	jugador.inventario_alternado.connect(_mostrar_inventario)
	jugador.estado_linterna_cambiado.connect(_actualizar_estado_linterna)
	jugador.linterna_usada.connect(ayuda_linterna.hide)
	_mostrar_inventario(jugador.inventario_abierto)
	actualizar_inventario()
	_actualizar_estado_linterna()

func actualizar_inventario() -> void:
	if not is_instance_valid(jugador):
		return
	var inventario := jugador.inventario
	for indice in range(Inventario.CAPACIDAD):
		iconos[indice].texture = Inventario.icono(inventario.espacios[indice])
		bordes[indice].tooltip_text = Inventario.nombre_objeto(inventario.espacios[indice]) + "\n" + Inventario.descripcion_objeto(inventario.espacios[indice]) if inventario.espacios[indice] != &"" else "Espacio vacío"
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color("171e22")
		estilo.border_color = Color("c8b789") if indice == inventario.seleccionado else Color("465156")
		estilo.set_border_width_all(2)
		estilo.set_corner_radius_all(3)
		bordes[indice].add_theme_stylebox_override("panel", estilo)
	var objeto := inventario.objeto_seleccionado()
	seleccion.text = "Espacio vacío" if objeto == &"" else Inventario.nombre_objeto(objeto)
	descripcion.text = Inventario.descripcion_objeto(objeto) if objeto != &"" else "Selecciona un objeto para consultar su descripción."

func _mostrar_inventario(abierto: bool) -> void:
	$Inventario.visible = abierto

func _actualizar_estado_linterna() -> void:
	if not is_instance_valid(jugador):
		return
	var estado := "sin linterna"
	if jugador.inventario.contiene(Inventario.LINTERNA):
		estado = "encendida" if jugador.linterna_encendida else "apagada"
	estado_linterna.text = "I · Inventario    F · Linterna: " + estado

func mostrar_mensaje(texto: String) -> void:
	texto_mensaje.text = texto
	panel_mensaje.show()
	reloj.start(duracion_mensaje)

func _process(delta: float) -> void:
	transcurrido += delta
	if transcurrido < 0.12 or not is_instance_valid(jugador):
		return
	transcurrido = 0.0
	if jugador.sin_control:
		indicacion.text = ""
	elif jugador.oculto:
		indicacion.text = "OCULTO · E para salir"
	else:
		var objetivo := jugador.objetivo_interaccion()
		indicacion.text = objetivo.texto_interaccion() if objetivo else ""

func mostrar_derrota() -> void:
	$Derrota.show()
	$Inventario.hide()
	ayuda_linterna.hide()
	indicacion.text = ""
	panel_mensaje.hide()
	reloj.stop()
