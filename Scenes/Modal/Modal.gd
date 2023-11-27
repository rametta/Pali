extends Control

signal primary_pressed()
signal secondary_pressed()

@export var text: Label
@export var primary_btn: Button
@export var secondary_btn: Button


func _on_primary_btn_pressed():
	primary_pressed.emit()


func _on_secondary_btn_pressed():
	secondary_pressed.emit()
