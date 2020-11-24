extends KinematicBody2D


const RUN_SPEED_MAX = 90.0
const RUN_ACC = 350.0
const GRAVITY = 600.0
const JUMP_FORCE = -220.0
const JUMP_TIME = .1
const COYOTE_TIME = .1
const JUMP_SPBOOST_MULTIPLIER = 1.5
const JUMP_SPBOOST_MAX = 1000.0
const STICKY_LANDING_MIN = 20.0
const STICKY_LANDING_FORCE = 70.0
const GRAVMOD_SHORTHOP_MULTIPLIER = 4.0
const GRAVMOD_SHORTHOP_BEGIN = JUMP_FORCE
const GRAVMOD_SHORTHOP_END = JUMP_FORCE * .35
const GRAVMOD_BIGLEAP_MULTIPLIER = .75
const GRAVMOD_BIGLEAP_BEGIN = JUMP_FORCE * .25
const GRAVMOD_BIGLEAP_END = -GRAVMOD_BIGLEAP_BEGIN

const RUN_FRIC_TEMP = .75
const AIR_FRIC_TEMP = .9
const CORRECTION_FRIC_TEMP = .95

var velocity: Vector2
var direction: int
var jump_timer: float
var coyote_timer: float

var grounded: bool


func _physics_process(delta):
	direction = (
		int(Input.is_action_pressed("ui_right")) -
		int(Input.is_action_pressed("ui_left"))
	)
	
	# Acceleration and friction nonsense
	
	# please clean up this mess, future me
	# oh god oh fuck
	if abs(velocity.x) > RUN_SPEED_MAX:
#		if direction == 0:
#			velocity.x -= min(
#				abs(velocity.x) - RUN_SPEED_MAX,
#				1 - (abs(velocity.x) * CORRECTION_FRIC_TEMP * delta)
#			) * sign(velocity.x)
#		elif sign(direction) == sign(velocity.x):
#			pass
#		else:
#			pass
		print(min(
			abs(velocity.x) - RUN_SPEED_MAX,
			abs(velocity.x) * (1 - CORRECTION_FRIC_TEMP)
		) * sign(velocity.x))
		velocity.x -= min(
			abs(velocity.x) - RUN_SPEED_MAX,
			abs(velocity.x) * (1 - CORRECTION_FRIC_TEMP)
		) * sign(velocity.x)
	else:
		if (not direction) or direction * velocity.x < 0:
			# will have to figure out how to timestep this later
			# need to learn calculus apparently?
			velocity.x *= RUN_FRIC_TEMP if is_on_floor() else AIR_FRIC_TEMP
		if direction:
			velocity.x += RUN_ACC * delta * direction
			velocity.x = clamp(velocity.x, -RUN_SPEED_MAX, RUN_SPEED_MAX)
	
	# Landing and Sticky Landing
	
	if is_on_floor():
		if not grounded:
			var speed_excess: float = abs(velocity.x) - STICKY_LANDING_MIN
			if direction == 0 and speed_excess > 0:
				velocity.x -= sign(velocity.x) * min(STICKY_LANDING_FORCE, speed_excess)
			grounded = true
	elif grounded:
		grounded = false
	
	# Variable Height Jump
	
	var current_gravity: float = GRAVITY
	
	if not grounded:
		if Input.is_action_pressed("ui_accept"):
			if GRAVMOD_BIGLEAP_BEGIN < velocity.y and velocity.y < GRAVMOD_BIGLEAP_END:
				current_gravity *= GRAVMOD_BIGLEAP_MULTIPLIER
		elif GRAVMOD_SHORTHOP_BEGIN < velocity.y and velocity.y < GRAVMOD_SHORTHOP_END:
			current_gravity *= GRAVMOD_SHORTHOP_MULTIPLIER
	
	velocity.y += current_gravity * delta
	
	# Jump
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_timer = JUMP_TIME
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	if jump_timer and coyote_timer:
		velocity.y = JUMP_FORCE
		if velocity.x < JUMP_SPBOOST_MAX:
			velocity.x *= JUMP_SPBOOST_MULTIPLIER
			velocity.x = clamp(velocity.x, -JUMP_SPBOOST_MAX, JUMP_SPBOOST_MAX)
		jump_timer = 0
		coyote_timer = 0
	else:
		jump_timer = max(jump_timer - delta, 0.0)
		coyote_timer = max(coyote_timer - delta, 0.0)
	
	move_and_slide(velocity, Vector2.UP)
	if is_on_wall():
		velocity.x = 0
	if is_on_ceiling():
		velocity.y = 0
	if is_on_floor():
		velocity.y = 0
