extends KinematicBody2D


const RUN_SPEED_MAX = 90.0
const RUN_ACC = 380.0
const GRAVITY = 620.0
const JUMP_FORCE = -220.0
const JUMP_TIME = .1
const COYOTE_TIME = .1
const JUMP_SPBOOST_MULTIPLIER = 1.3
const JUMP_SPBOOST_MAX = RUN_SPEED_MAX * JUMP_SPBOOST_MULTIPLIER
const STICKY_LANDING_MIN = 20.0
const STICKY_LANDING_FORCE = 70.0
const GRAVMOD_SHORTHOP_MULTIPLIER = 4.8
const GRAVMOD_SHORTHOP_BEGIN = JUMP_FORCE
const GRAVMOD_SHORTHOP_END = JUMP_FORCE * .28
const GRAVMOD_BIGLEAP_MULTIPLIER = .6
const GRAVMOD_BIGLEAP_BEGIN = JUMP_FORCE * .2
const GRAVMOD_BIGLEAP_END = -GRAVMOD_BIGLEAP_BEGIN
const WALLJUMP_FORCE = JUMP_FORCE * .8
const WALLJUMP_PUSH = JUMP_SPBOOST_MAX
const WALLJUMP_PUSH_NEUTRAL = JUMP_SPBOOST_MAX
const WALLJUMP_MARGIN = 1.5
const WALLJUMP_CONTROL_REMOVED_TIME = .18
const WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL = 0.0
const VELOCITY_CONSERVATION_TIME = .07

const RUN_FRIC_TEMP = .75
const AIR_FRIC_TEMP = .8
const CORRECTION_FRIC_TEMP = .95
const CORRECTION_FRIC_ATTENUATED_TEMP = .975

var in_control_x: bool = true
var in_control_y: bool = true
var no_control_x_timer: float
var no_control_y_timer: float
var apply_gravity: bool = true
var no_gravity_timer: float

var velocity_conservation_timer = Vector2(VELOCITY_CONSERVATION_TIME, VELOCITY_CONSERVATION_TIME)

var velocity: Vector2
var direction: int
var jump_timer: float
var coyote_timer: float

var grounded: bool
var last_ground_y: int


func _physics_process(delta):
	direction = (
		int(Input.is_action_pressed("ui_right")) -
		int(Input.is_action_pressed("ui_left"))
	)
	
	if not in_control_x:
		no_control_x_timer -= delta
		if no_control_x_timer <= 0:
			no_control_x_timer = 0
			in_control_x = true
	if not in_control_y:
		no_control_y_timer -= delta
		if no_control_y_timer <= 0:
			no_control_y_timer = 0
			in_control_y = true
	if not apply_gravity:
		no_gravity_timer -= delta
		if no_gravity_timer <= 0:
			no_gravity_timer = 0
			apply_gravity = true
	
	# Acceleration and friction nonsense
	
	# please clean up this mess, future me
	# oh god oh fuck
	if in_control_x:
		if abs(velocity.x) > RUN_SPEED_MAX:
			if direction == 0:
				velocity.x -= min(
					abs(velocity.x) - RUN_SPEED_MAX,
					abs(velocity.x) * (1 - CORRECTION_FRIC_TEMP)
				) * sign(velocity.x)
			elif sign(direction) == sign(velocity.x):
				velocity.x -= min(
					abs(velocity.x) - RUN_SPEED_MAX,
					abs(velocity.x) * (1 - CORRECTION_FRIC_ATTENUATED_TEMP)
				) * sign(velocity.x)
			else:
				velocity.x -= min(
					abs(velocity.x) - RUN_SPEED_MAX,
					abs(velocity.x) * (1 - CORRECTION_FRIC_TEMP * AIR_FRIC_TEMP)
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
	
	if apply_gravity:
		var current_gravity: float = GRAVITY
		
		if not grounded and in_control_y:
			if Input.is_action_pressed("ui_accept"):
				if GRAVMOD_BIGLEAP_BEGIN < velocity.y and velocity.y < GRAVMOD_BIGLEAP_END:
					current_gravity *= GRAVMOD_BIGLEAP_MULTIPLIER
			elif GRAVMOD_SHORTHOP_BEGIN < velocity.y and velocity.y < GRAVMOD_SHORTHOP_END:
				current_gravity *= GRAVMOD_SHORTHOP_MULTIPLIER
		
		velocity.y += current_gravity * delta
	
	# Jump
	if in_control_y:
		if Input.is_action_just_pressed("ui_accept"):
			jump_timer = JUMP_TIME
		if grounded:
			coyote_timer = COYOTE_TIME
			last_ground_y = position.y
		
		if jump_timer and coyote_timer:
			jump_timer = 0
			coyote_timer = 0
			position.y = last_ground_y
			velocity.y = JUMP_FORCE
			if velocity.x < JUMP_SPBOOST_MAX:
				velocity.x *= JUMP_SPBOOST_MULTIPLIER
				velocity.x = clamp(velocity.x, -JUMP_SPBOOST_MAX, JUMP_SPBOOST_MAX)
			jump_timer = 0
			coyote_timer = 0
		else:
			jump_timer = max(jump_timer - delta, 0.0)
			coyote_timer = max(coyote_timer - delta, 0.0)
		
		# Walljump
		
		if jump_timer:
			if test_move(transform, Vector2.LEFT * WALLJUMP_MARGIN):
				jump_timer = 0
				velocity.y = WALLJUMP_FORCE
				velocity.x = WALLJUMP_PUSH if direction else WALLJUMP_PUSH_NEUTRAL
				in_control_x = false
				in_control_y = false
				no_control_x_timer = (
					WALLJUMP_CONTROL_REMOVED_TIME if direction
					else WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
				)
				no_control_y_timer = (
					WALLJUMP_CONTROL_REMOVED_TIME if direction
					else WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
				)
				
			elif test_move(transform, Vector2.RIGHT * WALLJUMP_MARGIN):
				jump_timer = 0
				velocity.y = WALLJUMP_FORCE
				velocity.x = -WALLJUMP_PUSH if direction else -WALLJUMP_PUSH_NEUTRAL
				in_control_x = false
				in_control_y = false
				no_control_x_timer = (
					WALLJUMP_CONTROL_REMOVED_TIME if direction
					else WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
				)
				no_control_y_timer = (
					WALLJUMP_CONTROL_REMOVED_TIME if direction
					else WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
				)
	
	# Apply velocity
	
	move_and_slide(velocity, Vector2.UP)
	if is_on_ceiling() or is_on_floor():
		if velocity_conservation_timer.y > 0:
			velocity_conservation_timer.y -= delta
		if velocity_conservation_timer.y <= 0:
			velocity.y = 0
	else:
		velocity_conservation_timer.y = VELOCITY_CONSERVATION_TIME
	if is_on_wall():
		if velocity_conservation_timer.x > 0:
			velocity_conservation_timer.x -= delta
		if velocity_conservation_timer.x <= 0:
			velocity.x = 0
	else:
		velocity_conservation_timer.x = VELOCITY_CONSERVATION_TIME
