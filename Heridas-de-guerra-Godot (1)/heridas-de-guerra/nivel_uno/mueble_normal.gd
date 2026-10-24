class_name MuebleNormal
extends StaticBody2D

const ATLAS := preload("res://recursos/hospital_normal/atlas_normal.png")
const REGIONES := {
	&"escritorio": Rect2(35, 335, 335, 330), &"sofa": Rect2(375, 345, 355, 320),
	&"cama": Rect2(715, 330, 255, 350), &"mesa_noche": Rect2(995, 345, 250, 320),
	&"gabinete": Rect2(60, 665, 280, 310), &"silla": Rect2(370, 680, 270, 285),
	&"pastillas": Rect2(680, 700, 280, 270), &"puerta": Rect2(980, 660, 270, 315),
	&"ventana": Rect2(35, 955, 335, 288), &"planta": Rect2(380, 955, 270, 288),
	&"reloj": Rect2(685, 955, 280, 288), &"carrito": Rect2(975, 955, 275, 288),
}

var tipo: StringName
var tamano := Vector2(64, 64)
var solido := true
var sprite: Sprite2D

func configurar(datos: Dictionary) -> void:
	tipo = datos.get("tipo", &"silla")
	position = datos.get("pos", Vector2.ZERO)
	tamano = datos.get("tam", Vector2(64, 64))
	solido = datos.get("solido", true)
	name = "Mueble_%s" % tipo
	add_to_group("mobiliario_normal")
	collision_layer = 1 if solido else 0
	collision_mask = 6 if solido else 0
	_crear_sprite()
	if solido:
		_crear_colision()

func _crear_sprite() -> void:
	sprite = Sprite2D.new()
	sprite.name = "Ilustracion"
	var textura := AtlasTexture.new()
	textura.atlas = ATLAS
	var region: Rect2 = REGIONES.get(tipo, REGIONES[&"silla"])
	textura.region = region
	sprite.texture = textura
	sprite.scale = tamano / region.size
	sprite.position.y = -tamano.y * 0.42
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

func _crear_colision() -> void:
	# La forma replica la silueta completa y evita que los pies entren bajo el
	# escritorio, la cama o el asiento.
	var forma := RectangleShape2D.new()
	forma.size = Vector2(maxf(18.0, tamano.x - 4.0), tamano.y + 8.0)
	var colision := CollisionShape2D.new()
	colision.name = "ColisionFisica"
	colision.shape = forma
	colision.position = Vector2(0, -tamano.y * 0.42)
	add_child(colision)

func establecer_alucinacion(valor: bool) -> void:
	if sprite:
		sprite.modulate = Color("758080") if valor else Color.WHITE
