extends KinematicBody2D


# TO DO:

# Sync animation change with frame change

# When you exit a dash:
#   if you hold jump, bounce
#   if you hold dash, roll

# Don't cancel the momentum when going down, instead, if it's higher than the
# max fall speed (on context), apply friction (also applies for wall sliding)

# if the up velocity is too high, don't move from that velocity, but still keep it
# in memory, move from a min()

# Make it easier to regain the dash when on the ground
# (to be able to extend roll etc. even when coyote jumping)


export var facing_left: bool

# Physics constants

const RUN_SPEED_MAX = 90.0
const RUN_ACC = 380.0
const RUN_AIR_ACC = RUN_ACC * .75
const GRAVITY = 640.0
const JUMP_FORCE = -230.0
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
const WALLSLIDE_MAX_SPEED = 50.0
const WALLSLIDE_FCOUNT = 2

const RUN_FRIC_TEMP = .72
const AIR_FRIC_TEMP = .83
const CORRECTION_FRIC_TEMP = .95
const CORRECTION_FRIC_ATTENUATED_TEMP = .975

# Animation constants

const RUNNING_THRESHOLD = 10.0
const FALLING_THRESHOLD = 0.0


const DASH_DELAY = .04
const DASH_SPEED = 380.0
const DASH_DURATION = .12
const DASH_EXIT_SPEED = 130.0

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

var grounded: bool
var wallsliding: bool
var wallslide_fcounter: int
var last_ground_y: float
var last_wall_normal: int
var jumping: bool

var dashing_allowed: bool
var dashing_refreshed: bool
var dash_direction: Vector2
var dash_cancel_timer: float
var dash_waiting: bool
var dashing: bool
var dash_timer: float
var facing: int

onready var animation_player = $AnimationPlayer
onready var anim_container = $SpriteContainer
onready var anim_idle = $SpriteContainer/SpriteIdle
onready var anim_run = $SpriteContainer/SpriteRun
onready var anim_jump = $SpriteContainer/SpriteJump
onready var anim_hangtime = $SpriteContainer/SpriteHangtime
onready var anim_fall = $SpriteContainer/SpriteFall

onready var anim_current
onready var anim_list = [anim_idle, anim_run, anim_jump, anim_hangtime, anim_fall]

var anim_queue
var animplayer_current_TEMP

func _ready():
	set_anim(anim_idle, "Idle")
	animation_player.play("Idle")
	dashing_allowed = true
	dashing_refreshed = true
	facing = -1 if facing_left else 1


func _physics_process(delta):
	direction_x = (
		int(Input.is_action_pressed("Right")) -
		int(Input.is_action_pressed("Left"))
	)
	direction_y = (
		int(Input.is_action_pressed("Down")) -
		int(Input.is_action_pressed("Up"))
	)
	if direction_x == sign(velocity.x) and direction_x != 0:
		facing = direction_x
	
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
	elif test_move(transform, Vector2(0, get_safe_margin())):
		grounded = true
	elif grounded:
		grounded = false
	
	if grounded:
		jumping = false
	if grounded and dashing_allowed:
		dashing_refreshed = true
	
	# Replace this mess (and also in the walljump code) with a "facing" variable
	# This will also make animations easier to implement
	# Note from the future: lmao no that didn't help you're still stuck with this mess
	if is_on_wall():
		if test_move(
			transform,
			Vector2(sign(velocity.x) * get_safe_margin(), 0)
		):
			last_wall_normal = -int(sign(velocity.x))
		else:
			last_wall_normal = int(sign(velocity.x))
		if not wallsliding:
			wallsliding = true
			velocity.y = min(velocity.y, WALLSLIDE_MIN_SPEED)
		wallslide_fcounter = WALLSLIDE_FCOUNT
	elif wallsliding:
		wallslide_fcounter -= 1
		if wallslide_fcounter <= 0:
			wallsliding = false
	
	# Acceleration and friction nonsense
	
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
			if wallsliding and not velocity.y < 0:
				current_gravity = WALLSLIDE_GRAVITY
			elif jumping:
				if Input.is_action_pressed("Accept"):
					if GRAVMOD_BIGLEAP_BEGIN < velocity.y and velocity.y < GRAVMOD_BIGLEAP_END:
						current_gravity *= GRAVMOD_BIGLEAP_MULTIPLIER
				elif GRAVMOD_SHORTHOP_BEGIN < velocity.y and velocity.y < GRAVMOD_SHORTHOP_END:
					current_gravity *= GRAVMOD_SHORTHOP_MULTIPLIER
			if direction_y == 1 and velocity.y >= FASTFALL_BEGIN:
				current_gravity *= FASTFALL_MULTIPLIER
		
		velocity.y = min(
			velocity.y + current_gravity * delta,
			FASTFALL_SPEED if direction_y == 1 else FALL_SPEED
		)
	
	# Jump
	
	if Input.is_action_just_pressed("Accept"):
		jump_timer = JUMP_TIME
	if grounded:
		coyote_timer = COYOTE_TIME
		last_ground_y = position.y
	
	if in_control_y:		
		if jump_timer and coyote_timer:
			jump_timer = 0
			coyote_timer = 0
			move_and_collide(Vector2(0, last_ground_y - position.y))
			velocity.y = JUMP_FORCE
			if abs(velocity.x) < JUMP_SPBOOST_MAX:
				velocity.x *= JUMP_SPBOOST_MULTIPLIER
				velocity.x = clamp(velocity.x, -JUMP_SPBOOST_MAX, JUMP_SPBOOST_MAX)
			jump_timer = 0
			coyote_timer = 0
			grounded = false
			on_jump()
		else:
			jump_timer = max(jump_timer - delta, 0.0)
			coyote_timer = max(coyote_timer - delta, 0.0)
		
		# Walljump
		
		if jump_timer:
			var wall_normal: int
			if test_move(transform, Vector2(WALLJUMP_MARGIN, 0)):
				wall_normal = -1
				last_wall_normal = wall_normal
			elif test_move(transform, Vector2(-WALLJUMP_MARGIN, 0)):
				wall_normal = 1
				last_wall_normal = wall_normal
			
			if wall_normal:
				jump_timer = 0
				velocity.y = WALLJUMP_FORCE
				velocity.x = (WALLJUMP_PUSH if direction_x else
					WALLJUMP_PUSH_NEUTRAL) * wall_normal
				in_control_x = false
				in_control_y = false
				if direction_x:
					no_control_x_timer = WALLJUMP_CONTROL_REMOVED_TIME
					no_control_y_timer = WALLJUMP_CONTROL_REMOVED_TIME
					facing = int(wall_normal)
				else:
					no_control_x_timer = WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
					no_control_y_timer = WALLJUMP_CONTROL_REMOVED_TIME_NEUTRAL
				grounded = false
				on_jump()
	
	# Dash
	
	if Input.is_action_just_pressed("Cancel") and dashing_allowed and dashing_refreshed:
		dashing_allowed = false
		dashing_refreshed = false
		dash_cancel_timer = DASH_DELAY
		dash_waiting = true
	if dash_waiting:
		dash_cancel_timer -= delta
		if dash_cancel_timer <= 0:
			dash_waiting = false
			dashing = true
			apply_gravity = false
			in_control_x = false
			in_control_y = false
			coyote_timer = 0
			no_gravity_timer = DASH_DURATION
			no_control_x_timer = DASH_DURATION
			no_control_y_timer = DASH_DURATION
			dash_timer = DASH_DURATION
			dash_direction = Vector2(direction_x, direction_y).normalized()
			if dash_direction == Vector2.ZERO:
				dash_direction = Vector2(facing, 0)
			velocity = dash_direction * DASH_SPEED
			on_dash()
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false
			dashing_allowed = true
			var exit_vel = (dash_direction * DASH_EXIT_SPEED).abs()
			velocity.x = min(abs(velocity.x), exit_vel.x) * sign(velocity.x)
			velocity.y = min(abs(velocity.y), exit_vel.y) * sign(velocity.y)
	
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
	
	
	# Animations
	
	if grounded:
		if abs(velocity.x) > RUNNING_THRESHOLD and not wallsliding:
			set_anim(anim_run, "Run")
		else:
			set_anim(anim_idle, "Idle")
	else:
		if anim_current == anim_run or anim_current == anim_idle:
			set_anim(anim_idle, "Hangtime")
		if velocity.y >= FALLING_THRESHOLD:
			set_anim(anim_fall, "Fall")
	
	if anim_container.scale.x == -1:
		if facing > 0:
			anim_container.scale.x = 1
	elif facing < 0:
		anim_container.scale.x = -1


func set_anim(new_anim: Sprite, anim: String):
	if not anim_current == new_anim:
		for spr in anim_list:
			if spr != new_anim:
				spr.visible = false
			else:
				spr.visible = true
		anim_current = new_anim
	if not animation_player.assigned_animation == anim:
		anim_queue = anim
	if not animation_player.is_playing():
		fetch_animation()


func fetch_animation():
	if anim_queue != null:
		animation_player.play(anim_queue)
		anim_queue = null


func animationplayer_set_hangtime():
	set_anim(anim_hangtime, "Hangtime")


func on_jump():
	jumping = true
	set_anim(anim_jump, "Jump")
	dashing = false
	dashing_allowed = true


func on_dash():
	jumping = false
