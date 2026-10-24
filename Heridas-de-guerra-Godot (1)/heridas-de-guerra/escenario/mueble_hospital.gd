class_name MuebleHospital
extends StaticBody2D

const ATLAS := preload("res://recursos/hospital_abandonado/atlas_mobiliario.png")
const REGIONES := {
	&"recepcion": Rect2(18, 45, 300, 300), &"mostrador": Rect2(18, 45, 300, 300),
	&"banco": Rect2(330, 65, 310, 260), &"camilla": Rect2(645, 35, 300, 320),
	&"cama": Rect2(645, 35, 300, 320), &"cama_aislamiento": Rect2(645, 35, 300, 320),
	&"silla_ruedas": Rect2(970, 45, 275, 310),
	&"escritorio": Rect2(18, 350, 325, 325), &"archivero": Rect2(355, 335, 285, 345),
	&"librero": Rect2(355, 335, 285, 345), &"estante": Rect2(355, 335, 285, 345),
	&"gabinete": Rect2(645, 335, 275, 345), &"carrito": Rect2(965, 350, 280, 325),
	&"silla": Rect2(28, 680, 280, 280), &"mesa_comedor": Rect2(320, 675, 325, 300),
	&"servicio": Rect2(640, 690, 330, 285), &"panel": Rect2(35, 950, 290, 304),
	&"tuberias": Rect2(335, 945, 300, 309), &"banco_trabajo": Rect2(625, 955, 345, 299),
	&"cajas": Rect2(950, 955, 304, 299),
}

var tipo: StringName
var tamano: Vector2
var solido := true

func configurar(datos: Dictionary) -> void:
	tipo = datos.tipo
	tamano = datos.tam
	position = datos.pos
	solido = datos.solido
	z_index = 0
	if solido:
		collision_layer = 1
		collision_mask = 6
		# La colisión cubre toda la silueta del mueble y un margen mínimo al
		# frente. El jugador puede rodearlo, pero nunca entrar en su dibujo.
		var forma := RectangleShape2D.new()
		forma.size = Vector2(maxf(16.0, tamano.x - 4.0), tamano.y + 12.0)
		var colision := CollisionShape2D.new()
		colision.name = "CollisionShape2D"
		colision.position = Vector2(0, (-tamano.y + 12.0) * 0.5)
		colision.shape = forma
		add_child(colision)
	queue_redraw()

func _draw() -> void:
	var r := Rect2(-tamano.x * 0.5, -tamano.y, tamano.x, tamano.y)
	if _dibujar_desde_atlas(r):
		return
	match tipo:
		&"recepcion", &"mostrador", &"servicio":
			_dibujar_mostrador(r)
		&"banco":
			_dibujar_banco(r)
		&"escritorio", &"banco_trabajo":
			_dibujar_escritorio(r)
		&"archivero", &"gabinete", &"librero", &"estante":
			_dibujar_estante(r)
		&"silla", &"silla_ruedas":
			_dibujar_silla(r, tipo == &"silla_ruedas")
		&"camilla", &"cama", &"cama_aislamiento":
			_dibujar_cama(r, tipo == &"cama_aislamiento")
		&"mesa", &"mesa_comedor":
			_dibujar_mesa(r)
		&"carrito":
			_dibujar_carrito(r)
		&"pizarron", &"observacion":
			_dibujar_pizarron(r)
		&"documentos":
			_dibujar_documentos(r)
		&"cajas":
			_dibujar_cajas(r)
		&"panel":
			_dibujar_panel(r)
		&"tuberias":
			_dibujar_tuberias(r)
		_:
			_dibujar_mesa(r)

func _dibujar_desde_atlas(r: Rect2) -> bool:
	if not REGIONES.has(tipo):
		return false
	var region: Rect2 = REGIONES[tipo]
	# Cada región se recorta individualmente para que ninguna pata, borde o
	# sombra de la celda vecina aparezca alrededor del mueble.
	draw_texture_rect_region(ATLAS, r.grow(6.0), region)
	return true

func _marco(r: Rect2, base: Color, borde: Color) -> void:
	draw_rect(r, Color("101619"))
	draw_rect(Rect2(r.position + Vector2(3, 3), r.size - Vector2(6, 6)), base)
	draw_line(r.position + Vector2(4, 4), Vector2(r.end.x - 4, r.position.y + 4), borde, 3.0)
	draw_line(Vector2(r.position.x + 4, r.end.y - 4), r.end - Vector2(4, 4), base.darkened(0.35), 3.0)

func _dibujar_mostrador(r: Rect2) -> void:
	_marco(r, Color("435258"), Color("7d898a"))
	for x in range(int(r.position.x + 24), int(r.end.x), 48):
		draw_line(Vector2(x, r.position.y + 9), Vector2(x, r.end.y - 5), Color("29373b"), 2.0)
	_dibujar_documentos(Rect2(r.position + Vector2(r.size.x * 0.35, -8), Vector2(46, 28)))

func _dibujar_banco(r: Rect2) -> void:
	_marco(r, Color("39464a"), Color("69797c"))
	draw_rect(Rect2(r.position + Vector2(8, r.size.y * 0.45), Vector2(r.size.x - 16, 8)), Color("222d31"))
	for x in [r.position.x + 18, r.end.x - 24]:
		draw_rect(Rect2(x, r.end.y - 4, 6, 12), Color("22292c"))

func _dibujar_escritorio(r: Rect2) -> void:
	_marco(r, Color("554a3c"), Color("8a765b"))
	draw_rect(Rect2(r.position + Vector2(10, 12), Vector2(42, 24)), Color("6d5d48"))
	draw_rect(Rect2(r.end.x - 52, r.position.y + 12, 38, 28), Color("303a3d"))
	_dibujar_documentos(Rect2(r.position + Vector2(r.size.x * 0.45, 8), Vector2(40, 26)))

func _dibujar_estante(r: Rect2) -> void:
	_marco(r, Color("465057"), Color("77838a"))
	for y in range(int(r.position.y + 22), int(r.end.y), 26):
		draw_line(Vector2(r.position.x + 5, y), Vector2(r.end.x - 5, y), Color("202a2f"), 4.0)
		for x in range(int(r.position.x + 12), int(r.end.x - 8), 18):
			draw_rect(Rect2(x, y - 15, 10, 13), Color("765f48") if (x + y) % 3 else Color("556b68"))

func _dibujar_silla(r: Rect2, ruedas: bool) -> void:
	_marco(r, Color("3d4a4e"), Color("69787a"))
	draw_rect(Rect2(r.position.x + 7, r.position.y - 9, r.size.x - 14, 12), Color("273337"))
	if ruedas:
		draw_circle(Vector2(r.position.x + 3, r.end.y), 7, Color("171d20"))
		draw_circle(Vector2(r.end.x - 3, r.end.y), 7, Color("171d20"))

func _dibujar_cama(r: Rect2, aislamiento: bool) -> void:
	_marco(r, Color("6b7778") if not aislamiento else Color("555d5e"), Color("a4adab"))
	draw_rect(Rect2(r.position + Vector2(8, 7), Vector2(r.size.x * 0.32, r.size.y - 14)), Color("b2b8ad") if not aislamiento else Color("81857e"))
	draw_line(Vector2(r.position.x + 6, r.end.y + 2), Vector2(r.end.x - 6, r.end.y + 2), Color("262f32"), 5.0)

func _dibujar_mesa(r: Rect2) -> void:
	_marco(r, Color("554e42"), Color("827667"))
	for esquina in [r.position + Vector2(6, 6), Vector2(r.end.x - 10, r.position.y + 6), Vector2(r.position.x + 6, r.end.y - 10), r.end - Vector2(10, 10)]:
		draw_rect(Rect2(esquina, Vector2(5, 5)), Color("272b2b"))

func _dibujar_carrito(r: Rect2) -> void:
	_marco(r, Color("6f7d7c"), Color("b4bfba"))
	draw_rect(Rect2(r.position + Vector2(8, 10), r.size - Vector2(16, 28)), Color("263338"))
	draw_circle(Vector2(r.position.x + 8, r.end.y + 2), 5, Color("14191b"))
	draw_circle(Vector2(r.end.x - 8, r.end.y + 2), 5, Color("14191b"))

func _dibujar_pizarron(r: Rect2) -> void:
	_marco(r, Color("273d3b"), Color("6a7c77"))
	for x in range(int(r.position.x + 16), int(r.end.x - 12), 32):
		draw_line(Vector2(x, r.position.y + 10), Vector2(x + 18, r.position.y + 13), Color("92a49d"), 2.0)

func _dibujar_documentos(r: Rect2) -> void:
	draw_rect(r, Color("b4ad91"))
	draw_rect(Rect2(r.position + Vector2(5, 5), r.size - Vector2(10, 10)), Color("d0c6a1"))
	for y in range(int(r.position.y + 9), int(r.end.y - 5), 6):
		draw_line(Vector2(r.position.x + 9, y), Vector2(r.end.x - 8, y), Color("6c6b5c"), 1.0)

func _dibujar_cajas(r: Rect2) -> void:
	var mitad := r.size.x * 0.52
	_marco(Rect2(r.position, Vector2(mitad, r.size.y)), Color("695942"), Color("958066"))
	_marco(Rect2(Vector2(r.position.x + mitad - 5, r.position.y + r.size.y * 0.22), Vector2(r.size.x - mitad + 5, r.size.y * 0.78)), Color("5e503d"), Color("88745a"))

func _dibujar_panel(r: Rect2) -> void:
	_marco(r, Color("39454a"), Color("778388"))
	for x in range(int(r.position.x + 15), int(r.end.x - 10), 25):
		draw_circle(Vector2(x, r.position.y + 18), 4, Color("a25846") if x % 2 else Color("829366"))
		draw_line(Vector2(x, r.position.y + 30), Vector2(x, r.end.y - 8), Color("1e292d"), 3.0)

func _dibujar_tuberias(r: Rect2) -> void:
	for x in [r.position.x + 8, r.position.x + 20]:
		draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), Color("667174"), 7.0)
		for y in range(int(r.position.y + 24), int(r.end.y), 48):
			draw_rect(Rect2(x - 6, y, 12, 6), Color("323b3e"))
