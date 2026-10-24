class_name Inventario
extends Node

signal cambiado

const CAPACIDAD := 5
const TARJETA := &"tarjeta_acceso"
const LINTERNA := &"linterna"
const ICONO_TARJETA := preload("res://recursos/spr_tarjeta_acceso/00.png")
const ICONO_LINTERNA := preload("res://recursos/spr_linterna/00.png")
var espacios: Array[StringName] = [&"", &"", &"", &"", &""]
var seleccionado: int = 0

func puede_agregar(objeto: StringName) -> bool:
	return objeto != &"" and espacios.has(&"") and not (objeto == LINTERNA and contiene(LINTERNA))

func agregar(objeto: StringName) -> bool:
	if not puede_agregar(objeto):
		return false
	espacios[espacios.find(&"")] = objeto
	cambiado.emit()
	return true

func contiene(objeto: StringName) -> bool:
	return espacios.has(objeto)

func seleccionar(indice: int) -> void:
	if indice >= 0 and indice < CAPACIDAD and indice != seleccionado:
		seleccionado = indice
		cambiado.emit()

func objeto_seleccionado() -> StringName:
	return espacios[seleccionado]

func quitar_seleccionado() -> StringName:
	var objeto := objeto_seleccionado()
	espacios[seleccionado] = &""
	cambiado.emit()
	return objeto

static func icono(objeto: StringName) -> Texture2D:
	match objeto:
		TARJETA:
			return ICONO_TARJETA
		LINTERNA:
			return ICONO_LINTERNA
	return null

static func nombre_objeto(objeto: StringName) -> String:
	match objeto:
		TARJETA:
			return "Tarjeta de acceso"
		LINTERNA:
			return "Linterna"
	return String(objeto)

static func descripcion_objeto(objeto: StringName) -> String:
	match objeto:
		TARJETA:
			return "Abre la puerta médica al pulsar E. No se consume al usarla."
		LINTERNA:
			return "Equipada en la mano mientras la lleves. Pulsa F para encenderla o apagarla."
	return "" if objeto == &"" else "Objeto guardado en el inventario."
