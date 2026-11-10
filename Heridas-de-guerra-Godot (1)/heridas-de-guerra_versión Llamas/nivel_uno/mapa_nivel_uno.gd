class_name MapaNivelUno
extends Node2D

func _ready() -> void:
	construir()

func construir() -> void:
	for hijo in get_children():
		hijo.queue_free()
	for indice in range(DisenoNivelUno.MUROS.size()):
		_crear_muro(DisenoNivelUno.MUROS[indice], indice)
	for datos in DisenoNivelUno.MUEBLES:
		var mueble := MuebleNormal.new()
		add_child(mueble)
		mueble.configurar(datos)

func _crear_muro(rect: Rect2, indice: int) -> void:
	var muro := StaticBody2D.new()
	muro.name = "Muro_%02d" % indice
	muro.collision_layer = 1
	muro.collision_mask = 6
	muro.position = rect.get_center()
	var forma := RectangleShape2D.new()
	forma.size = rect.size
	var colision := CollisionShape2D.new()
	colision.name = "Colision"
	colision.shape = forma
	muro.add_child(colision)
	# Únicamente la arquitectura bloquea la luz. Los escritorios, camas y
	# sillas conservan su colisión física, pero la linterna los atraviesa.
	var poligono := OccluderPolygon2D.new()
	var mitad := rect.size * 0.5
	poligono.polygon = PackedVector2Array([
		Vector2(-mitad.x, -mitad.y), Vector2(mitad.x, -mitad.y),
		Vector2(mitad.x, mitad.y), Vector2(-mitad.x, mitad.y),
	])
	var oclusor := LightOccluder2D.new()
	oclusor.name = "OclusionArquitectonica"
	oclusor.occluder = poligono
	muro.add_child(oclusor)
	add_child(muro)
