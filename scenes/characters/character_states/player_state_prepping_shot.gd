class_name PlayerStatePreppingShot
extends PlayerState

const DURATION_MAX_BONUS := 1000.0 #1000.0ms = 1.0second - add screen shake?
const EASE_REWARD_FACTOR := 2.0

var shot_direction := Vector2.ZERO
var time_start_shot := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play("prep_kick")
	# when the player stops moving to shoot it feels crap,
	# but the oscilations on the ball will have to stop when shooting
	# also if the player holds down the shoot for too long the ball would have to run away
	# perhaps have a max hold time and automatically shoot after that
	player.velocity = Vector2.ZERO
	time_start_shot = Time.get_ticks_msec()
	shot_direction = player.heading
	
func _physics_process(delta: float) -> void:
	shot_direction += KeyUtils.get_input_vector(player.control_scheme) * delta
	if KeyUtils.is_action_just_released(player.control_scheme, KeyUtils.Action.SHOOT):
		var duration_press = clampf(Time.get_ticks_msec() - time_start_shot, 0.0, DURATION_MAX_BONUS)
		var ease_time = duration_press / DURATION_MAX_BONUS
		# ease gives an exponential bonus for how long you press up to DURATION_MAX_BONUS
		var bonus = ease(ease_time, EASE_REWARD_FACTOR)
		var shot_power = player.power * (1 + bonus)
		# normalizing gives it a length of 1. see tutorial 05/24
		shot_direction = shot_direction.normalized()
		var data = PlayerStateData.build().set_shot_power(shot_power).set_shot_direction(shot_direction)
		transition_state(Player.State.SHOOTING, data)
