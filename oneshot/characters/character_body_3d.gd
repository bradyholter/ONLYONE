extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5

@export_group("headbob")
@export var headbob_frequency := 2.0
@export var headbob_amplitude := 0.04
var headbob_time := 0.0

var footstep_can_play := true
var footstep_landed

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0
	
	if Input.is_action_pressed("sprint") and $stamina.value > 0:
		velocity.x = direction.x * (SPEED * 2)
		velocity.z = direction.z * (SPEED * 2)
		$stamina.value -= 4
	else: 
		$stamina.value += .5
	if Input.is_action_pressed("sprint") and $stamina.value == 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	move_and_slide()
	
	headbob_time += delta * velocity.length() * float(is_on_floor())
	$Model/Camera3D.transform.origin = headbob(headbob_time)
	
	if not footstep_landed and is_on_floor(): #landed footstep
		%FootstepAudio3D.play()
	elif footstep_landed and not is_on_floor():
		%FootstepAudio3D
	footstep_landed = is_on_floor()
	
func headbob(headbob_time):
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(headbob_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = cos(headbob_time * headbob_frequency / 2) * headbob_amplitude
	
	var footstep_threshold = -headbob_amplitude * 0.002
	if headbob_position.y > footstep_threshold:
		footstep_can_play = true
	elif headbob_position.y < footstep_threshold and footstep_can_play:
		footstep_can_play = false
		%FootstepAudio3D.play()
	return headbob_position

var mouse_sensitivity = .002

@onready var camera_3d = $Model/Camera3D
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_3d.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(60))
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 
	
