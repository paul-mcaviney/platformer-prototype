extends CharacterBody3D


const SPEED = 6.5
const JUMP_VELOCITY = 13
const CAM_ROTATION_SPEED = 0.0008

@export var camera_speed = 0.09

var player_transform : Transform3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	# Rotate camera
	#if Input.is_action_pressed("camera_left"):
		#$Camera_Controller.rotate_y(rad_to_deg(-CAM_ROTATION_SPEED))	
	#if Input.is_action_pressed("camera_right"):
		#$Camera_Controller.rotate_y(rad_to_deg(CAM_ROTATION_SPEED))	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() or Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# For some reason the code below makes the controls go all weird
	#var input_dir := Input.get_vector("move_down","move_left","move_right","move_up")
	
	
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	# Rotate character mesh so oriented towards movement direction in relation to camera
	if input_dir != Vector2.ZERO:
		$MeshInstance3D.rotation_degrees.y = $Camera_Controller.rotation_degrees.y  - rad_to_deg(input_dir.angle()) - 90
	
	# Rotate character to align with the floor
	if is_on_floor():
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform = global_transform.interpolate_with(player_transform, 0.3)
	else:
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(player_transform, 0.3)
	
	# update velocity and move the character
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# Make camera controller match player position
	$Camera_Controller.position = lerp($Camera_Controller.position, position, camera_speed)


func align_with_floor(floor_normal):
	player_transform = global_transform
	player_transform.basis.y = floor_normal
	player_transform.basis.x = -player_transform.basis.z.cross(floor_normal)
	player_transform.basis = player_transform.basis.orthonormalized()


#func _on_fall_zone_body_entered(_body: Node3D) -> void:
	#change_scene.bind("res://level_1.tscn").call_deferred()
	#
#
#func change_scene(scene):
	#get_tree().change_scene_to_file(scene)
