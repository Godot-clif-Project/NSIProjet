extends KinematicBody2D


# Might want to use polynomial functions for the physics - at least on the X axis
# Easier to timestep, easier to control
# But: easy to run into problems when the speed is too high

# fuck i broke walljumps


const RUN_SPEED_MAX = 90.0
const RUN_ACC = 380.0
const RUN_AIR_ACC = RUN_ACC * .65
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
const GRAVMOD_BIGLEAP_MULTIPLIER = .7
const GRAVMOD_BIGLEAP_BEGIN = JUMP_FORCE * .2
const GRAVMOD_BIGLEAP_END = -GRAVMOD_BIGLEAP_BEGIN
const WALLJUMP_FORCE = JUMP_FORCE * .8
const WALLJUMP_PUSH = JUMP_SPBOOST_MAX
const WALLJUMP_PUSH_NEUTRAL = JUMP_SPBOOST_MAX
const WALLJUMP_MARGIN = 1.5
const WALLJUMP_CONTROL_REMOVED_TIME = .15
const WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL = 0.0
const VELOCITY_CONSERVATION_TIME = .065
const FALL_SPEED = -JUMP_FORCE * 1.15
const FASTFALL_SPEED = -JUMP_FORCE * 1.5
const FASTFALL_MULTIPLIER = 1.2
const FASTFALL_BEGIN = 0
const WALLSLIDE_MIN_SPEED = 30.0
const WALLSLIDE_GRAVITY = 400.0
const WALLSLIDE_MAX_SPEED = 100.0
const WALLSLIDE_TIME = .085
const STUPID_WALL_CHECK_DISTANCE = .5

const RUN_FRIC_TEMP = .75
const AIR_FRIC_TEMP = .85
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
var direction_x: int
var direction_y: int
var jump_timer: float
var coyote_timer: float
var wallslide_timer: float

var grounded: bool
var last_ground_y: int
var wallsliding: bool
var last_wall_normal: int


func _physics_process(delta):
	direction_x = (
		int(Input.is_action_pressed("Right")) -
		int(Input.is_action_pressed("Left"))
	)
	direction_y = (
		int(Input.is_action_pressed("Down")) -
		int(Input.is_action_pressed("Up"))
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
	
	# Landing and Sticky Landing
	
	if is_on_floor():
		if not grounded:
			var speed_excess: float = abs(velocity.x) - STICKY_LANDING_MIN
			if direction_x == 0 and speed_excess > 0:
				velocity.x -= sign(velocity.x) * min(STICKY_LANDING_FORCE, speed_excess)
			grounded = true
	elif grounded:
		grounded = false
	
	# Replace this mess (and also in the walljump code) with a "facing" variable
	# This will also make animations easier to implement 
	if is_on_wall():
		if test_move(
			transform,
			Vector2(sign(velocity.x) * STUPID_WALL_CHECK_DISTANCE, 0)
		):
			last_wall_normal = -int(sign(velocity.x))
		else:
			last_wall_normal = int(sign(velocity.x))
		wallslide_timer = WALLSLIDE_TIME
		if not wallsliding:
			wallsliding = true
			velocity.y = min(velocity.y, WALLSLIDE_MIN_SPEED)
	elif wallsliding:
		wallslide_timer -= delta
		if wallslide_timer <= 0:
			wallsliding = false
	
	# Acceleration and friction nonsense
	
	# please clean up this mess, future me
	# oh god oh fuck
	if in_control_x:
		if abs(velocity.x) > RUN_SPEED_MAX:
			if direction_x == 0:
				velocity.x -= min(
					abs(velocity.x) - RUN_SPEED_MAX,
					abs(velocity.x) * (1 - CORRECTION_FRIC_TEMP)
				) * sign(velocity.x)
			elif sign(direction_x) == sign(velocity.x):
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
			if (not direction_x) or direction_x * velocity.x < 0:
				# will have to figure out how to timestep this later
				# need to learn calculus apparently?
				velocity.x *= RUN_FRIC_TEMP if is_on_floor() else AIR_FRIC_TEMP
			if direction_x:
				velocity.x += (RUN_ACC if grounded else RUN_AIR_ACC) * delta * direction_x
				velocity.x = clamp(velocity.x, -RUN_SPEED_MAX, RUN_SPEED_MAX)
	
	# Variable Height Jump and Fastfalling and Wallsliding
	
	if apply_gravity:
		var current_gravity: float = GRAVITY
		
		if direction_y == 1 and velocity.y > FASTFALL_BEGIN:
			current_gravity *= FASTFALL_MULTIPLIER
		
		if not grounded and in_control_y:
			print(velocity.y)
			if (not wallsliding) or direction_y == 1 or velocity.y < 0:
				if Input.is_action_pressed("Accept"):
					if GRAVMOD_BIGLEAP_BEGIN < velocity.y and velocity.y < GRAVMOD_BIGLEAP_END:
						current_gravity *= GRAVMOD_BIGLEAP_MULTIPLIER
				elif GRAVMOD_SHORTHOP_BEGIN < velocity.y and velocity.y < GRAVMOD_SHORTHOP_END:
					current_gravity *= GRAVMOD_SHORTHOP_MULTIPLIER
			else:
				current_gravity = WALLSLIDE_GRAVITY
		
		velocity.y = min(
			velocity.y + current_gravity * delta,
			FASTFALL_SPEED if direction_y == 1 else FALL_SPEED
		)
	
	# Jump
	if in_control_y:
		if Input.is_action_just_pressed("Accept"):
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
			var wall_normal: int
			if not wallsliding:
				if test_move(transform, Vector2(sign(velocity.x) * WALLJUMP_MARGIN, 0)):
					wall_normal = -sign(velocity.x)
					last_wall_normal = wall_normal
				elif test_move(transform, Vector2(-sign(velocity.x) * WALLJUMP_MARGIN, 0)):
					wall_normal = sign(velocity.x)
					last_wall_normal = wall_normal
			else:
				wall_normal = last_wall_normal
			if wall_normal:
				jump_timer = 0
				velocity.y = WALLJUMP_FORCE
				velocity.x = (WALLJUMP_PUSH if direction_x else
					WALLJUMP_PUSH_NEUTRAL) * wall_normal
				in_control_x = false
				in_control_y = false
				no_control_x_timer = (
					WALLJUMP_CONTROL_REMOVED_TIME if direction_x
					else WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
				)
				no_control_y_timer = (
					WALLJUMP_CONTROL_REMOVED_TIME if direction_x
					else WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
				)
	
	# Apply velocity
	
	move_and_slide(velocity, Vector2.UP)
	if is_on_ceiling():
		if velocity_conservation_timer.y > 0:
			velocity_conservation_timer.y -= delta
		if velocity_conservation_timer.y <= 0:
			velocity.y = 0
	else:
		velocity_conservation_timer.y = VELOCITY_CONSERVATION_TIME
	if is_on_floor():
		velocity.y = 0
	if is_on_wall():
		if velocity_conservation_timer.x > 0:
			velocity_conservation_timer.x -= delta
		if velocity_conservation_timer.x <= 0:
			velocity.x = 0
	else:
		velocity_conservation_timer.x = VELOCITY_CONSERVATION_TIME
