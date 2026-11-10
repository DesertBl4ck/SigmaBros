class_name DisenoNivelUno
extends RefCounted

const TAMANO := Vector2(4096, 1152)

const HABITACIONES := [
	Rect2(32, 160, 704, 832),
	Rect2(896, 64, 480, 352), Rect2(1440, 64, 480, 352),
	Rect2(1984, 64, 480, 352), Rect2(2528, 64, 480, 352),
	Rect2(896, 736, 480, 352), Rect2(1440, 736, 480, 352),
	Rect2(1984, 736, 480, 352), Rect2(2528, 736, 480, 352),
	Rect2(3360, 160, 704, 832),
]

# Solo el consultorio, el pasillo y el dormitorio del protagonista son transitables.
# Las habitaciones laterales se ven desde el pasillo, pero sus puertas permanecen cerradas.
const MUROS := [
	Rect2(0, 0, 4096, 32), Rect2(0, 1120, 4096, 32),
	Rect2(0, 0, 32, 1152), Rect2(4064, 0, 32, 1152),
	# Consultorio.
	Rect2(32, 128, 736, 32), Rect2(32, 992, 736, 32),
	Rect2(32, 128, 32, 896),
	Rect2(736, 128, 32, 416), Rect2(736, 672, 32, 352),
	# Pasillo principal, con una única salida en cada extremo.
	Rect2(768, 416, 2592, 32), Rect2(768, 704, 2592, 32),
	# Dormitorio del protagonista.
	Rect2(3360, 128, 704, 32), Rect2(3360, 992, 704, 32),
	Rect2(4064, 128, 32, 896),
	Rect2(3328, 128, 32, 416), Rect2(3328, 672, 32, 352),
	# Divisiones de habitaciones visibles.
	Rect2(864, 32, 32, 384), Rect2(1376, 32, 32, 384),
	Rect2(1408, 32, 32, 384), Rect2(1920, 32, 32, 384),
	Rect2(1952, 32, 32, 384), Rect2(2464, 32, 32, 384),
	Rect2(2496, 32, 32, 384), Rect2(3008, 32, 32, 384),
	Rect2(864, 736, 32, 384), Rect2(1376, 736, 32, 384),
	Rect2(1408, 736, 32, 384), Rect2(1920, 736, 32, 384),
	Rect2(1952, 736, 32, 384), Rect2(2464, 736, 32, 384),
	Rect2(2496, 736, 32, 384), Rect2(3008, 736, 32, 384),
]

const MUEBLES := [
	# Consultorio del psicólogo.
	{"tipo": &"sofa", "pos": Vector2(208, 472), "tam": Vector2(184, 104), "solido": true},
	{"tipo": &"escritorio", "pos": Vector2(496, 448), "tam": Vector2(224, 104), "solido": true},
	{"tipo": &"silla", "pos": Vector2(496, 592), "tam": Vector2(64, 76), "solido": true},
	{"tipo": &"gabinete", "pos": Vector2(680, 352), "tam": Vector2(96, 152), "solido": true},
	{"tipo": &"planta", "pos": Vector2(112, 304), "tam": Vector2(72, 96), "solido": true},
	{"tipo": &"reloj", "pos": Vector2(128, 208), "tam": Vector2(64, 64), "solido": false},
	# Mobiliario del pasillo; deja libre una franja central amplia.
	{"tipo": &"sofa", "pos": Vector2(1120, 508), "tam": Vector2(168, 72), "solido": true},
	{"tipo": &"planta", "pos": Vector2(1512, 500), "tam": Vector2(56, 72), "solido": true},
	{"tipo": &"carrito", "pos": Vector2(2180, 510), "tam": Vector2(72, 74), "solido": true},
	{"tipo": &"sofa", "pos": Vector2(2784, 696), "tam": Vector2(168, 72), "solido": true},
	{"tipo": &"planta", "pos": Vector2(3160, 688), "tam": Vector2(56, 72), "solido": true},
	# Camas y mesillas visibles en las habitaciones de pacientes.
	{"tipo": &"cama", "pos": Vector2(1040, 336), "tam": Vector2(92, 164), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(1200, 336), "tam": Vector2(58, 70), "solido": true},
	{"tipo": &"cama", "pos": Vector2(1584, 336), "tam": Vector2(92, 164), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(1760, 336), "tam": Vector2(58, 70), "solido": true},
	{"tipo": &"cama", "pos": Vector2(2128, 336), "tam": Vector2(92, 164), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(2304, 336), "tam": Vector2(58, 70), "solido": true},
	{"tipo": &"cama", "pos": Vector2(2672, 336), "tam": Vector2(92, 164), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(2848, 336), "tam": Vector2(58, 70), "solido": true},
	{"tipo": &"cama", "pos": Vector2(1040, 1032), "tam": Vector2(92, 164), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(1200, 1032), "tam": Vector2(58, 70), "solido": true},
	{"tipo": &"cama", "pos": Vector2(1584, 1032), "tam": Vector2(92, 164), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(1760, 1032), "tam": Vector2(58, 70), "solido": true},
	{"tipo": &"cama", "pos": Vector2(2128, 1032), "tam": Vector2(92, 164), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(2304, 1032), "tam": Vector2(58, 70), "solido": true},
	{"tipo": &"cama", "pos": Vector2(2672, 1032), "tam": Vector2(92, 164), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(2848, 1032), "tam": Vector2(58, 70), "solido": true},
	# Dormitorio del soldado.
	{"tipo": &"cama", "pos": Vector2(3696, 600), "tam": Vector2(108, 184), "solido": true},
	{"tipo": &"mesa_noche", "pos": Vector2(3832, 600), "tam": Vector2(68, 82), "solido": true},
	{"tipo": &"pastillas", "pos": Vector2(3832, 526), "tam": Vector2(42, 48), "solido": false},
	{"tipo": &"gabinete", "pos": Vector2(3984, 400), "tam": Vector2(92, 148), "solido": true},
	{"tipo": &"silla", "pos": Vector2(3464, 776), "tam": Vector2(64, 76), "solido": true},
	{"tipo": &"planta", "pos": Vector2(3976, 896), "tam": Vector2(64, 86), "solido": true},
]

const PUERTAS_PACIENTES := [
	Vector2(1136, 416), Vector2(1680, 416), Vector2(2224, 416), Vector2(2768, 416),
	Vector2(1136, 736), Vector2(1680, 736), Vector2(2224, 736), Vector2(2768, 736),
]

const MANCHAS_ALUCINACION := [
	{"pos": Vector2(320, 760), "radio": 38.0}, {"pos": Vector2(980, 584), "radio": 24.0},
	{"pos": Vector2(1640, 620), "radio": 34.0}, {"pos": Vector2(2380, 540), "radio": 28.0},
	{"pos": Vector2(3020, 640), "radio": 42.0}, {"pos": Vector2(3700, 820), "radio": 36.0},
]
