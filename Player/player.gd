extends RigidBody3D
class_name Player

@export var thrust:=1000.0
@export var torque:=100.0
var transitioning:=false
@onready var death: AudioStreamPlayer = $Death
@onready var success: AudioStreamPlayer = $Success
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var main_booster: GPUParticles3D = $MainBooster
@onready var right_turn: GPUParticles3D = $RightTurn
@onready var left_turn: GPUParticles3D = $LeftTurn
@onready var success_particles: GPUParticles3D = $SuccessParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@export var starting_fuel:=100
var yes:=0
var ui: CanvasLayer
var fuel:int:
	set(new_fuel):
		fuel=new_fuel
		ui.update_fuel(new_fuel)
		
func _ready() -> void:
	ui=get_tree().get_first_node_in_group("ui")
	fuel=starting_fuel

func _process(delta: float) -> void:
	if !transitioning:
		if Input.is_action_pressed("boost")and fuel>0:
			fuel-=1
			main_booster.emitting=true
			apply_central_force(basis.y*delta*thrust)
			if not rocket_audio.is_playing():
				rocket_audio.play()
		else:
			rocket_audio.stop()
			main_booster.emitting=false
	
		if Input.is_action_pressed("rotate_left"):
			if fuel>0.5:
				apply_torque(Vector3(0.0,0.0,delta*torque))
				fuel-=0.5
				right_turn.emitting=true
		else:
			right_turn.emitting=false
			
		if Input.is_action_pressed("rotate_right"):
			if fuel>0.5:
				apply_torque(Vector3(0.0,0.0,-delta*torque))
				fuel-=0.5
				left_turn.emitting=true
		else:
			left_turn.emitting=false


func _on_body_entered(body: Node) -> void:
	if "Goal" in body.get_groups():
		print("You Win")
		if body.file_path!=null:
			rocket_audio.stop()
			main_booster.emitting=false
			right_turn.emitting=false
			left_turn.emitting=false
			if yes==0:
				success_particles.emitting=true
			level_complete(body.file_path)
		else:
			print("No next level found!")

	if "Bad" in body.get_groups():
		rocket_audio.stop()
		main_booster.emitting=false
		right_turn.emitting=false
		left_turn.emitting=false
		if yes==0:
			explosion_particles.emitting=true
		crash_sequence()

func crash_sequence()->void:
	if yes==0:
		death.play()
	print("KABOOM")
	transitioning=true
	yes=1
	await get_tree().create_timer(2.5).timeout
	transitioning=false
	get_tree().reload_current_scene.call_deferred()
	yes=0
	rocket_audio.stop()
	main_booster.emitting=false
	
func level_complete(next_level_file)->void:
	if yes==0:
		success.play()
	transitioning=true
	yes=1
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file(next_level_file)
	transitioning=false
	yes=0
