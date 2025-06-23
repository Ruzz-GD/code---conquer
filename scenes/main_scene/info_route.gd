extends ColorRect

@onready var conrtol_info = $"info-page/MarginContainer/control-info"
@onready var lab_info = $"info-page/MarginContainer/lab-info"

func _ready() -> void:
	conrtol_info.visible = true
	lab_info.visible = false
	


func _on_controlinfobtn_pressed() -> void:
	conrtol_info.visible = true
	lab_info.visible = false


func _on_labinfobtn_pressed() -> void:
	conrtol_info.visible = false
	lab_info.visible = true


func _on_back_pressed() -> void:
	hide()
