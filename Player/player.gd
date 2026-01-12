extends RigidBody3D
class_name Player

@export var thrust:=1000.0
@export var torque:=100.0
var transitioning:=false


func _process(delta: float) -> void:
	if !transitioning:
		if Input.is_action_pressed("boost"):
			apply_central_force(basis.y*delta*thrust)
		if Input.is_action_pressed("rotate_left"):
			apply_torque(Vector3(0.0,0.0,delta*torque))
		if Input.is_action_pressed("rotate_right"):
			apply_torque(Vector3(0.0,0.0,-delta*torque))


func _on_body_entered(body: Node) -> void:
	if "Goal" in body.get_groups():
		print("You Win")
		if body.file_path!=null:
			level_complete(body.file_path)
		else:
			print("No next level found!")

	if "Bad" in body.get_groups():
		crash_sequence()

func crash_sequence()->void:
	print("KABOOM")
	transitioning=true
	await get_tree().create_timer(1).timeout
	transitioning=false
	get_tree().reload_current_scene.call_deferred()
	
func level_complete(next_level_file)->void:
	if transitioning==false:
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file(next_level_file)
		transitioning=false
