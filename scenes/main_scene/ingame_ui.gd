extends Control

@onready var ingame_setting_modal = $"ingame-setting-modal"
@onready var resume_btn = $"ingame-setting-modal/resume-btn"
@onready var info_route = $"../info-route"

func _ready() -> void:
	ingame_setting_modal.visible = false
	info_route.visible = false

func _on_ingame_setting_pressed() -> void:
	ingame_setting_modal.visible = true

func _on_resumebtn_pressed() -> void:
	ingame_setting_modal.visible = false
	
func _on_quitbtn_pressed():
	GameManager.reset_game()
	ingame_setting_modal.visible = false
	
func _on_infobtn_pressed() -> void:
	info_route.visible = true
