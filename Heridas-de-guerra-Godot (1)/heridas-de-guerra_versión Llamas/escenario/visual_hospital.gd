class_name VisualHospital
extends Node2D

func _ready() -> void:
	z_index = -20
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, DisenoHospital.TAMANO), DisenoHospital.COLOR_BASE)
	_dibujar_pasillos()
	for sector in DisenoHospital.SECTORES:
		_dibujar_sector(sector)
	for mancha in DisenoHospital.MANCHAS:
		_dibujar_mancha(mancha.pos, mancha.radio)
	for muro in DisenoHospital.MUROS:
		_dibujar_muro(muro)

func _dibujar_pasillos() -> void:
	var pasillo := Color("2d383e")
	draw_rect(Rect2(1344, 32, 352, 1984), pasillo)
	draw_rect(Rect2(32, 832, 3008, 352), pasillo)
	for y in range(64, 2016, 64):
		draw_line(Vector2(1344, y), Vector2(1696, y), Color("39464d"), 1.0)
	for x in range(64, 3040, 64):
		draw_line(Vector2(x, 832), Vector2(x, 1184), Color("39464d"), 1.0)
	# Franja de orientación que conecta todo el edificio.
	draw_rect(Rect2(1496, 32, 16, 1984), Color("394744"))
	draw_rect(Rect2(32, 992, 3008, 16), Color("394744"))

func _dibujar_sector(sector: Dictionary) -> void:
	var rect: Rect2 = sector.rect
	var color: Color = sector.color
	draw_rect(rect, color)
	for y in range(int(rect.position.y), int(rect.end.y), 64):
		for x in range(int(rect.position.x), int(rect.end.x), 64):
			var alterno := ((x / 64) + (y / 64)) as int
			var variacion := color.lightened(0.035) if alterno % 2 == 0 else color.darkened(0.035)
			match int(sector.patron):
				0:
					draw_rect(Rect2(x + 1, y + 1, 62, 62), variacion)
				1:
					draw_rect(Rect2(x + 1, y + 1, 62, 30), variacion)
					draw_rect(Rect2(x + 33, y + 33, 30, 30), variacion)
				2:
					draw_rect(Rect2(x + 1, y + 1, 62, 62), variacion)
					draw_line(Vector2(x + 8, y + 56), Vector2(x + 56, y + 8), color.darkened(0.08), 2.0)
				3:
					draw_rect(Rect2(x + 1, y + 1, 62, 62), variacion)
					draw_line(Vector2(x + 32, y + 4), Vector2(x + 32, y + 60), color.darkened(0.1), 1.0)

func _dibujar_muro(rect: Rect2) -> void:
	draw_rect(rect, Color("17242a"))
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), Color("40545b"))
	if rect.size.x > rect.size.y:
		draw_line(rect.position + Vector2(0, 7), Vector2(rect.end.x, rect.position.y + 7), Color("718086"), 3.0)
		for x in range(int(rect.position.x + 32), int(rect.end.x), 64):
			draw_line(Vector2(x, rect.position.y + 8), Vector2(x - 7, rect.end.y - 5), Color("26373d"), 2.0)
	else:
		draw_line(rect.position + Vector2(7, 0), Vector2(rect.position.x + 7, rect.end.y), Color("718086"), 3.0)
		for y in range(int(rect.position.y + 32), int(rect.end.y), 64):
			draw_line(Vector2(rect.position.x + 8, y), Vector2(rect.end.x - 5, y - 7), Color("26373d"), 2.0)

func _dibujar_mancha(posicion: Vector2, radio: float) -> void:
	draw_circle(posicion, radio, Color(0.08, 0.11, 0.11, 0.45))
	draw_circle(posicion + Vector2(radio * 0.45, -radio * 0.25), radio * 0.52, Color(0.10, 0.13, 0.13, 0.34))
	draw_circle(posicion + Vector2(-radio * 0.55, radio * 0.32), radio * 0.28, Color(0.06, 0.08, 0.08, 0.38))
