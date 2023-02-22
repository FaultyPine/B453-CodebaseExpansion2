extends Node2D

onready var playerRoot = get_node("../")
const airborneIterations = 50
var points = []

# one jump took my X pos from
# 166.333 -> 216.373

# Y is positive going down (origin top-left)
# X is positive going right

# called from player script, from _physics_process (every physics frame)
func SetJumpEndingPos(delta: float, pos: Vector2, vVelocity: Vector2, vGravity: Vector2, fGravity: float, fJumpForce: float, fMaxSpeed: float):
	# clear points and add the initial starting pos
	points.clear()
	points.append(pos)
	# so we can do raycasts later
	var space_state = get_world_2d().direct_space_state
	# start at current player position
	var current_pos_iter = pos

	# "apply" jump impulse once
	# Y negative is up which is why we subtract
	vVelocity -= vGravity * fJumpForce

	# "simulate" the airborne velocity for some number of iterations
	for i in range(airborneIterations):
		# doing the same physics calculations that are done for the player normally
		vVelocity.x = clamp(vVelocity.x, -fMaxSpeed, fMaxSpeed)
		vVelocity.y = clamp(vVelocity.y, -fMaxSpeed, fMaxSpeed)
		var gravityPull = vGravity*fGravity*delta
		vVelocity += gravityPull
		# instead of move_and_slide, incrementing the pos and taking frame delta into account is equivalent
		# https://godotengine.org/qa/38408/need-clearance-does-move_and_slide-already-use-delta
		# "move_and_slide() internally multiplies the passed motion vector by delta"
		current_pos_iter += vVelocity*delta
		# after "moving" ourselves according to physics, store the current position so we can track the
		# arc of the player's simulated motion
		points.append(current_pos_iter)
		# check if we've intersected some geometry, if so we should be falling or we've hit the ground
		var result = space_state.intersect_ray(pos, current_pos_iter, [playerRoot]) # ignore player
		if result:
			# if we've hit something (ground), store the final point and stop simulating physics
			points.append(result.position)
			break
			#print("Hit at point: ", result.position)
		# store previous position for raycast checks
		pos = current_pos_iter
			
			
	if len(points) < 1:
		points.append(current_pos_iter)



func _ready():
	pass
	
	
func _process(_delta):
	update() # ensure _draw gets called every frame
	
func draw_X(pos: Vector2, size: float, color: Color):
	var offset1 = Vector2(1,1) * size
	draw_line(pos + offset1, pos - offset1, color)
	var offset2 = Vector2(-1, 1) * size
	draw_line(pos + offset2, pos - offset2, color)
	
	
func _draw():
	#print("drawing: " + str(curve.get_baked_points()))
	#print("num points " + str(len(curve.get_baked_points())))
	var lineCol: Color = Color.red
	lineCol.a = 0.5
	var xCol: Color = Color.white
	xCol.a = 0.5
	for i in range(len(points)-1):
		draw_line(to_local(points[i]), to_local(points[i+1]), lineCol)
	draw_X(to_local(points[-1]), 4.0, xCol)
		#draw_circle(to_local(points[i]), 1.0, Color.red)
	#draw_polyline(curve.get_baked_points(), Color.red, 2.0)

	
