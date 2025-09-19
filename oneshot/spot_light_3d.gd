extends SpotLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if input.is_action_just_pressed("ui_click"):
		$SpotLight3d energy = 0
