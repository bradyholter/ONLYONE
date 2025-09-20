extends Node3D

var toggle = false

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_click"):
		toggle = !toggle
	if toggle == true and $ProgressBar.value > 0:
		$SpotLight3D.light_energy = 16
	else:
		$SpotLight3D.light_energy = 0

func _physics_process(delta : float) -> void:
	if $SpotLight3D.light_energy == 16:
		$ProgressBar.value -=.1
