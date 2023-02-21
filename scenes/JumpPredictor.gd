extends Node2D

#var curve: Curve2D = Curve2D.new()
var points = []

# one jump took my X pos from
# 166.333 -> 216.373

# Y is positive going down (origin top-left)
# X is positive going right

# called from player script, from _physics_process (every physics frame)
func SetJumpEndingPos(delta: float, pos: Vector2, vVelocity: Vector2, vGravity: Vector2, fGravity: float, fJumpForce: float):
	points.clear()
	points.append(pos)
	
	var space_state = get_world_2d().direct_space_state
	var current_pos_iter = pos

	# "apply" jump impulse once
	# Y negative is up which is why we subtract
	vVelocity -= vGravity * fJumpForce * 1.0 # <- fJumpMultiplier is 1

	var fMaxSpeed := 500.0
	# "simulate" the airborne velocity for a few iterations
	for i in range(50):
		vVelocity.x = clamp(vVelocity.x, -fMaxSpeed, fMaxSpeed)
		vVelocity.y = clamp(vVelocity.y, -fMaxSpeed, fMaxSpeed)
		var gravityPull = vGravity*fGravity*delta
		vVelocity += gravityPull
		# instead of move_and_slide just increment the pos
		current_pos_iter += vVelocity*delta
		points.append(current_pos_iter)
		var result = space_state.intersect_ray(pos, current_pos_iter)
		pos = current_pos_iter
		if result:
			#print("Hit at point: ", result.position)
			#points.append(result.position)
			#break
			pass
			
	if len(points) < 1:
		points.append(current_pos_iter)
	#print("")



func _ready():
	pass
	
	
func _process(_delta):
	update()
func _draw():
	#print("drawing: " + str(curve.get_baked_points()))
	#print("num points " + str(len(curve.get_baked_points())))
	for i in range(len(points)-1):
		draw_line(to_local(points[i]), to_local(points[i+1]), Color.red)
		#draw_circle(to_local(points[i]), 1.0, Color.red)
	#draw_polyline(curve.get_baked_points(), Color.red, 2.0)

	
