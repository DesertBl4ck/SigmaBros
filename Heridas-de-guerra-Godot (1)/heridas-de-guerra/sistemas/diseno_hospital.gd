class_name DisenoHospital
extends RefCounted

const TAMANO := Vector2(3072, 2048)
const CELDA_NAVEGACION := Vector2(32, 32)
const COLOR_BASE := Color("10161b")

const SECTORES := [
	{"id": &"recepcion", "nombre": "RECEPCIÓN PRINCIPAL", "rect": Rect2(64, 64, 768, 736), "color": Color("34424a"), "patron": 0},
	{"id": &"administracion", "nombre": "ADMISIÓN Y CONSULTA", "rect": Rect2(864, 64, 448, 736), "color": Color("3b4141"), "patron": 1},
	{"id": &"terapia", "nombre": "SALA DE TERAPIA", "rect": Rect2(1728, 64, 544, 384), "color": Color("3b3a43"), "patron": 2},
	{"id": &"consultorios", "nombre": "CONSULTORIOS", "rect": Rect2(2304, 64, 704, 384), "color": Color("354348"), "patron": 1},
	{"id": &"enfermeria", "nombre": "ENFERMERÍA Y MEDICAMENTOS", "rect": Rect2(1728, 480, 1280, 320), "color": Color("30454a"), "patron": 3},
	{"id": &"hospitalizacion", "nombre": "HOSPITALIZACIÓN", "rect": Rect2(64, 1216, 768, 768), "color": Color("394046"), "patron": 0},
	{"id": &"comedor", "nombre": "COMEDOR", "rect": Rect2(864, 1216, 448, 768), "color": Color("464139"), "patron": 2},
	{"id": &"aislamiento", "nombre": "AISLAMIENTO", "rect": Rect2(1728, 1216, 544, 768), "color": Color("30383d"), "patron": 3},
	{"id": &"archivo", "nombre": "ARCHIVO MÉDICO", "rect": Rect2(2304, 1216, 352, 768), "color": Color("403c35"), "patron": 1},
	{"id": &"mantenimiento", "nombre": "MANTENIMIENTO", "rect": Rect2(2688, 1216, 320, 768), "color": Color("3c3934"), "patron": 3},
]

# Cada rectángulo corresponde tanto al dibujo como a una forma física y un oclusor.
# Los huecos entre segmentos son puertas y conexiones transitables deliberadas.
const MUROS := [
	# Límites exteriores.
	Rect2(0, 0, 3072, 32), Rect2(0, 2016, 3072, 32),
	Rect2(0, 0, 32, 2048), Rect2(3040, 0, 32, 2048),
	# Separación con el pasillo vertical central: cuadrante noroeste.
	Rect2(1312, 32, 32, 352), Rect2(1312, 480, 32, 224), Rect2(1312, 800, 32, 64),
	# Cuadrante noreste.
	Rect2(1696, 32, 32, 288), Rect2(1696, 416, 32, 288), Rect2(1696, 800, 32, 64),
	# Cuadrante suroeste; el hueco inferior contiene el atajo bloqueado.
	Rect2(1312, 1184, 32, 288), Rect2(1312, 1568, 32, 192), Rect2(1312, 1824, 32, 192),
	# Cuadrante sureste; el primer hueco es la puerta de acceso a aislamiento.
	Rect2(1696, 1184, 32, 288), Rect2(1696, 1536, 32, 480),
	# Separación con el pasillo horizontal central.
	Rect2(32, 800, 416, 32), Rect2(576, 800, 512, 32), Rect2(1216, 800, 96, 32),
	Rect2(1728, 800, 160, 32), Rect2(2016, 800, 480, 32), Rect2(2624, 800, 416, 32),
	Rect2(32, 1184, 416, 32), Rect2(576, 1184, 512, 32), Rect2(1216, 1184, 96, 32),
	Rect2(1728, 1184, 768, 32), Rect2(2624, 1184, 416, 32),
	# Recepción / administración.
	Rect2(832, 32, 32, 288), Rect2(832, 416, 32, 224), Rect2(832, 736, 32, 96),
	Rect2(32, 480, 288, 32), Rect2(448, 480, 384, 32),
	Rect2(864, 416, 160, 32), Rect2(1120, 416, 192, 32),
	# Terapia / consultorios / enfermería.
	Rect2(2272, 32, 32, 160), Rect2(2272, 288, 32, 192),
	Rect2(1728, 448, 256, 32), Rect2(2080, 448, 288, 32), Rect2(2464, 448, 576, 32),
	Rect2(2496, 480, 32, 128), Rect2(2496, 704, 32, 96),
	Rect2(2656, 32, 32, 160), Rect2(2656, 288, 32, 160),
	# Hospitalización y comedor con corredor secundario horizontal.
	Rect2(32, 1472, 224, 32), Rect2(352, 1472, 192, 32), Rect2(640, 1472, 192, 32),
	Rect2(32, 1696, 224, 32), Rect2(352, 1696, 192, 32), Rect2(640, 1696, 192, 32),
	Rect2(832, 1216, 32, 256), Rect2(832, 1568, 32, 448),
	Rect2(1088, 1216, 32, 192), Rect2(1088, 1504, 32, 160), Rect2(1088, 1760, 32, 256),
	# Aislamiento, archivo y mantenimiento.
	Rect2(2272, 1216, 32, 800),
	Rect2(2656, 1216, 32, 256), Rect2(2656, 1568, 32, 448),
	Rect2(1728, 1440, 160, 32), Rect2(1984, 1440, 288, 32),
	Rect2(1728, 1696, 160, 32), Rect2(1984, 1696, 288, 32),
	Rect2(2304, 1472, 128, 32), Rect2(2528, 1472, 128, 32),
]

const MUEBLES := [
	# Recepción y espera.
	{"tipo": &"recepcion", "pos": Vector2(352, 352), "tam": Vector2(320, 72), "solido": true},
	{"tipo": &"banco", "pos": Vector2(160, 672), "tam": Vector2(192, 48), "solido": true},
	{"tipo": &"banco", "pos": Vector2(496, 672), "tam": Vector2(192, 48), "solido": true},
	{"tipo": &"documentos", "pos": Vector2(416, 344), "tam": Vector2(48, 32), "solido": false},
	{"tipo": &"silla_ruedas", "pos": Vector2(736, 736), "tam": Vector2(48, 56), "solido": true},
	# Administración y consultorios.
	{"tipo": &"escritorio", "pos": Vector2(960, 288), "tam": Vector2(192, 72), "solido": true},
	{"tipo": &"archivero", "pos": Vector2(1216, 256), "tam": Vector2(64, 160), "solido": true},
	{"tipo": &"escritorio", "pos": Vector2(2448, 256), "tam": Vector2(160, 72), "solido": true},
	{"tipo": &"librero", "pos": Vector2(2368, 400), "tam": Vector2(96, 112), "solido": true},
	{"tipo": &"escritorio", "pos": Vector2(2784, 256), "tam": Vector2(160, 72), "solido": true},
	{"tipo": &"librero", "pos": Vector2(2720, 400), "tam": Vector2(96, 112), "solido": true},
	# Terapia: círculo de sillas y pizarrón.
	{"tipo": &"pizarron", "pos": Vector2(1984, 112), "tam": Vector2(192, 32), "solido": false},
	{"tipo": &"silla", "pos": Vector2(1904, 240), "tam": Vector2(40, 40), "solido": true},
	{"tipo": &"silla", "pos": Vector2(2016, 176), "tam": Vector2(40, 40), "solido": true},
	{"tipo": &"silla", "pos": Vector2(2144, 240), "tam": Vector2(40, 40), "solido": true},
	{"tipo": &"silla", "pos": Vector2(2144, 352), "tam": Vector2(40, 40), "solido": true},
	{"tipo": &"silla", "pos": Vector2(2016, 400), "tam": Vector2(40, 40), "solido": true},
	{"tipo": &"silla", "pos": Vector2(1904, 352), "tam": Vector2(40, 40), "solido": true},
	# Enfermería.
	{"tipo": &"mostrador", "pos": Vector2(1872, 640), "tam": Vector2(320, 64), "solido": true},
	{"tipo": &"gabinete", "pos": Vector2(2368, 560), "tam": Vector2(96, 128), "solido": true},
	{"tipo": &"carrito", "pos": Vector2(2208, 720), "tam": Vector2(56, 56), "solido": true},
	{"tipo": &"estante", "pos": Vector2(2784, 560), "tam": Vector2(96, 112), "solido": true},
	{"tipo": &"camilla", "pos": Vector2(2752, 736), "tam": Vector2(112, 64), "solido": true},
	# Hospitalización: dormitorios distintos.
	{"tipo": &"cama", "pos": Vector2(128, 1408), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"mesa", "pos": Vector2(224, 1408), "tam": Vector2(48, 48), "solido": true},
	{"tipo": &"cama", "pos": Vector2(448, 1408), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"documentos", "pos": Vector2(544, 1392), "tam": Vector2(48, 32), "solido": false},
	{"tipo": &"cama", "pos": Vector2(704, 1408), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"camilla", "pos": Vector2(128, 1632), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"cama", "pos": Vector2(448, 1632), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"cama", "pos": Vector2(704, 1632), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"mesa", "pos": Vector2(640, 1904), "tam": Vector2(64, 48), "solido": true},
	# Comedor y cocina.
	{"tipo": &"mesa_comedor", "pos": Vector2(928, 1360), "tam": Vector2(112, 112), "solido": true},
	{"tipo": &"mesa_comedor", "pos": Vector2(1184, 1360), "tam": Vector2(112, 112), "solido": true},
	{"tipo": &"mesa_comedor", "pos": Vector2(928, 1760), "tam": Vector2(112, 112), "solido": true},
	{"tipo": &"servicio", "pos": Vector2(992, 1952), "tam": Vector2(256, 48), "solido": true},
	# Aislamiento: mobiliario mínimo y reforzado.
	{"tipo": &"cama_aislamiento", "pos": Vector2(1792, 1376), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"cama_aislamiento", "pos": Vector2(2112, 1376), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"cama_aislamiento", "pos": Vector2(1792, 1632), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"cama_aislamiento", "pos": Vector2(2112, 1632), "tam": Vector2(112, 64), "solido": true},
	{"tipo": &"observacion", "pos": Vector2(1936, 1456), "tam": Vector2(96, 24), "solido": false},
	# Archivo médico.
	{"tipo": &"estante", "pos": Vector2(2352, 1376), "tam": Vector2(96, 112), "solido": true},
	{"tipo": &"estante", "pos": Vector2(2352, 1600), "tam": Vector2(96, 112), "solido": true},
	{"tipo": &"estante", "pos": Vector2(2352, 1824), "tam": Vector2(96, 112), "solido": true},
	{"tipo": &"cajas", "pos": Vector2(2560, 1952), "tam": Vector2(80, 64), "solido": true},
	# Mantenimiento.
	{"tipo": &"panel", "pos": Vector2(2752, 1328), "tam": Vector2(96, 112), "solido": true},
	{"tipo": &"tuberias", "pos": Vector2(2992, 1408), "tam": Vector2(32, 192), "solido": false},
	{"tipo": &"banco_trabajo", "pos": Vector2(2752, 1728), "tam": Vector2(160, 96), "solido": true},
	{"tipo": &"cajas", "pos": Vector2(2816, 1952), "tam": Vector2(96, 64), "solido": true},
]

const MANCHAS := [
	{"pos": Vector2(280, 250), "radio": 26.0}, {"pos": Vector2(740, 580), "radio": 18.0},
	{"pos": Vector2(1010, 690), "radio": 34.0}, {"pos": Vector2(1512, 420), "radio": 20.0},
	{"pos": Vector2(2040, 680), "radio": 30.0}, {"pos": Vector2(2870, 340), "radio": 22.0},
	{"pos": Vector2(560, 1560), "radio": 28.0}, {"pos": Vector2(970, 1840), "radio": 32.0},
	{"pos": Vector2(1830, 1840), "radio": 18.0}, {"pos": Vector2(2440, 1710), "radio": 26.0},
	{"pos": Vector2(2850, 1860), "radio": 36.0},
]
