class_name MapaHospital
extends Node2D

func _ready() -> void:
	_construir_muros()
	_construir_muebles()

func _construir_muros() -> void:
	for indice in range(DisenoHospital.MUROS.size()):
		var rect: Rect2 = DisenoHospital.MUROS[indice]
		var cuerpo := StaticBody2D.new()
		cuerpo.name = "Muro%03d" % indice
		cuerpo.position = rect.get_center()
		cuerpo.collision_layer = 1
		cuerpo.collision_mask = 6
		var forma := RectangleShape2D.new()
		forma.size = rect.size
		var colision := CollisionShape2D.new()
		colision.name = "CollisionShape2D"
		colision.shape = forma
		cuerpo.add_child(colision)
		var poligono := OccluderPolygon2D.new()
		var mitad := rect.size * 0.5
		poligono.polygon = PackedVector2Array([
			Vector2(-mitad.x, -mitad.y), Vector2(mitad.x, -mitad.y),
			Vector2(mitad.x, mitad.y), Vector2(-mitad.x, mitad.y),
		])
		var oclusion := LightOccluder2D.new()
		oclusion.name = "Oclusion"
		oclusion.occluder = poligono
		cuerpo.add_child(oclusion)
		add_child(cuerpo)

func _construir_muebles() -> void:
	for indice in range(DisenoHospital.MUEBLES.size()):
		var mueble := MuebleHospital.new()
		mueble.name = "Mueble%03d_%s" % [indice, DisenoHospital.MUEBLES[indice].tipo]
		mueble.configurar(DisenoHospital.MUEBLES[indice])
		add_child(mueble)
