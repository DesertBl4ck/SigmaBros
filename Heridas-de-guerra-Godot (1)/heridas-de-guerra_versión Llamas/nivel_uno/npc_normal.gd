class_name NpcNormal
extends Node2D

const HOJA := preload("res://recursos/hospital_normal/personajes_animados.png")
const FILAS_Y := [34.0, 282.0, 521.0, 774.0, 1027.0, 1269.0]
const ALTO_REGION := 240.0
const ESCALA_PERSONAJE := Vector2(0.23, 0.23)

@export var es_psicologo := false
@export var ruta := PackedVector2Array()
@export var velocidad := 28.0
@export var desfase := 0.0

var pausado := false
var indice_ruta := 0
var sprite: AnimatedSprite2D

func _ready() -> void:
	add_to_group("npcs_normales")
	_crear_sprite_animado()
	if ruta.is_empty():
		ruta = PackedVector2Array([position])

func _process(delta: float) -> void:
	if pausado or ruta.size() < 2:
		_animar(Vector2.ZERO)
		return
	var destino := ruta[indice_ruta]
	var direccion := global_position.direction_to(destino)
	global_position = global_position.move_toward(destino, velocidad * delta)
	_animar(direccion)
	if global_position.distance_to(destino) < 3.0:
		indice_ruta = (indice_ruta + 1) % ruta.size()

func _crear_sprite_animado() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.name = "Personaje"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.sprite_frames = _crear_fotogramas()
	sprite.animation = &"abajo"
	sprite.position.y = -27.5
	# La silueta visible queda en 52–55 px, como el protagonista original.
	sprite.scale = ESCALA_PERSONAJE
	add_child(sprite)

func _crear_fotogramas() -> SpriteFrames:
	var fotogramas := SpriteFrames.new()
	fotogramas.remove_animation(&"default")
	var fila_base := 0 if es_psicologo else 3
	var ancho_celda := HOJA.get_size().x / 4.0
	for entrada in [[&"abajo", 0], [&"arriba", 1], [&"lado", 2]]:
		var animacion: StringName = entrada[0]
		var fila: int = fila_base + entrada[1]
		fotogramas.add_animation(animacion)
		fotogramas.set_animation_loop(animacion, true)
		fotogramas.set_animation_speed(animacion, 8.0)
		for cuadro in range(4):
			var textura := AtlasTexture.new()
			textura.atlas = HOJA
			textura.region = Rect2(cuadro * ancho_celda, FILAS_Y[fila], ancho_celda, ALTO_REGION)
			fotogramas.add_frame(animacion, textura)
	return fotogramas

func _animar(direccion: Vector2) -> void:
	if direccion.length_squared() < 0.01:
		sprite.stop()
		sprite.frame = 0
		return
	if absf(direccion.x) > absf(direccion.y):
		sprite.flip_h = direccion.x < 0
		sprite.play(&"lado")
	elif direccion.y < 0:
		sprite.flip_h = false
		sprite.play(&"arriba")
	else:
		sprite.flip_h = false
		sprite.play(&"abajo")

func establecer_alucinacion(valor: bool) -> void:
	visible = not valor
