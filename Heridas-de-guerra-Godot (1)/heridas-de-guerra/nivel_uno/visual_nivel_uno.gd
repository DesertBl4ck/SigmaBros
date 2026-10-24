class_name VisualNivelUno
extends Node2D

const VENTANAS := preload("res://recursos/hospital_normal/ventana_dia_noche.png")

var modo_noche := false
var modo_alucinacion := false

func _ready() -> void:
	z_index = -30
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func establecer_noche(valor: bool) -> void:
	modo_noche = valor
	queue_redraw()

func establecer_alucinacion(valor: bool) -> void:
	modo_alucinacion = valor
	queue_redraw()

func _draw() -> void:
	var base := Color("12171b") if modo_alucinacion else Color("d5d4c7")
	draw_rect(Rect2(Vector2.ZERO, DisenoNivelUno.TAMANO), base)
	_dibujar_habitaciones()
	_dibujar_pasillo()
	for muro in DisenoNivelUno.MUROS:
		_dibujar_muro(muro)
	for puerta in DisenoNivelUno.PUERTAS_PACIENTES:
		_dibujar_puerta_cerrada(puerta)
	_dibujar_ventana()
	if modo_alucinacion:
		_dibujar_deterioro()

func _dibujar_habitaciones() -> void:
	for indice in range(DisenoNivelUno.HABITACIONES.size()):
		var rect: Rect2 = DisenoNivelUno.HABITACIONES[indice]
		var color := Color("2b3438") if modo_alucinacion else (Color("c5d4ce") if indice % 2 == 0 else Color("d0d5c8"))
		draw_rect(rect, color)
		for y in range(int(rect.position.y), int(rect.end.y), 64):
			for x in range(int(rect.position.x), int(rect.end.x), 64):
				var alterno := ((x / 64) + (y / 64)) as int
				var baldosa := color.lightened(0.035) if alterno % 2 == 0 else color.darkened(0.025)
				draw_rect(Rect2(x + 1, y + 1, 62, 62), baldosa)
		if not modo_alucinacion:
			draw_rect(Rect2(rect.position + Vector2(0, 18), Vector2(rect.size.x, 8)), Color("e7e4d5"))
			draw_line(rect.position + Vector2(0, 30), Vector2(rect.end.x, rect.position.y + 30), Color("8ca49d"), 3.0)

func _dibujar_pasillo() -> void:
	var rect := Rect2(768, 448, 2592, 256)
	var color := Color("263137") if modo_alucinacion else Color("d8ddd5")
	draw_rect(rect, color)
	for y in range(448, 704, 64):
		for x in range(768, 3360, 64):
			var alterno := int((x + y) / 64)
			var variante := color.lightened(0.035) if alterno % 2 == 0 else color.darkened(0.03)
			draw_rect(Rect2(x + 1, y + 1, 62, 62), variante)
	# Guías arquitectónicas discretas, sin texto sobre el suelo.
	draw_rect(Rect2(768, 568, 2592, 16), Color("a7bcb4") if not modo_alucinacion else Color("354348"))
	for x in range(896, 3296, 256):
		draw_line(Vector2(x, 456), Vector2(x, 696), Color(0.4, 0.48, 0.45, 0.16), 1.0)

func _dibujar_muro(rect: Rect2) -> void:
	var oscuro := Color("172126") if modo_alucinacion else Color("839b96")
	var claro := Color("384b50") if modo_alucinacion else Color("dce4dc")
	draw_rect(rect, oscuro)
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), claro)
	if rect.size.x > rect.size.y:
		draw_line(rect.position + Vector2(0, 6), Vector2(rect.end.x, rect.position.y + 6), claro.lightened(0.18), 3.0)
	else:
		draw_line(rect.position + Vector2(6, 0), Vector2(rect.position.x + 6, rect.end.y), claro.lightened(0.18), 3.0)

func _dibujar_puerta_cerrada(punto: Vector2) -> void:
	var superior := punto.y < 600
	var rect := Rect2(punto.x - 42, punto.y - 22 if superior else punto.y - 10, 84, 32)
	draw_rect(rect, Color("20292c") if modo_alucinacion else Color("758d82"))
	draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), Color("354145") if modo_alucinacion else Color("b7c4b8"))
	draw_circle(Vector2(rect.end.x - 12, rect.position.y + 16), 3.0, Color("d0bd78"))

func _dibujar_ventana() -> void:
	var celda := Vector2(VENTANAS.get_size().x * 0.5, VENTANAS.get_size().y)
	var origen := Vector2(celda.x if modo_noche else 0.0, 0.0)
	draw_texture_rect_region(VENTANAS, Rect2(3460, 260, 320, 160), Rect2(origen, celda))

func _dibujar_deterioro() -> void:
	for mancha in DisenoNivelUno.MANCHAS_ALUCINACION:
		draw_circle(mancha.pos, mancha.radio, Color(0.09, 0.05, 0.045, 0.55))
		draw_circle(mancha.pos + Vector2(mancha.radio * 0.45, -8), mancha.radio * 0.45, Color(0.13, 0.07, 0.055, 0.35))
	for x in range(420, 3900, 430):
		var y := 260.0 + float((x * 37) % 520)
		draw_polyline(PackedVector2Array([
			Vector2(x, y), Vector2(x + 18, y + 22), Vector2(x + 6, y + 48),
			Vector2(x + 34, y + 70),
		]), Color("0c1114"), 4.0)
