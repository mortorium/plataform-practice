extends KinematicBody2D

const SPEED = 128
const FLOOR = Vector2(0, -1) #direccon del suelo
const GRAVITY = 16 #establecemos la fuerza de gravedad
const JUMP_HEIGHT = 384
const BOUNCING_JUMP = 112 #fuerza de rebote en la pared
const CAST_WALL = 10 #distancia de colision contra la pared
onready var motion = Vector2.ZERO
var can_move : bool #es para saber si el Player se puede mover


func _process(delta):
	motion_ctrl()


func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis


func motion_ctrl():
	motion.y += GRAVITY
	
	if can_move:
		if get_axis().x == 1:
			$RayCast.cast_to.y = CAST_WALL #pa controlar la direccion del raycast
			$AnimatedSprite.flip_h = false
		elif get_axis().x == -1:
			$RayCast.cast_to.y = -CAST_WALL #invertimos el raycast
			$AnimatedSprite.flip_h = true
		
		if get_axis().x != 0:
			motion.x = get_axis().x * SPEED
		else:
			motion.x = 0
	
	if is_on_floor():
		can_move = true
		
		if get_axis().x != 0:
			$AnimatedSprite.play("Run")
			$Particles.emitting = true #esto pa emitir particulas cuando se mueve el Player
		else:
			$AnimatedSprite.play("Iddle")
			$Particles.emitting = false
			
		if Input.is_action_just_pressed("ui_accept"):
			motion.y -= JUMP_HEIGHT
	else:
		$Particles.emitting = false
		
		if motion.y < 0:
			$AnimatedSprite.play("Jump")
		else:
			$AnimatedSprite.play("Fall")
	
	if $RayCast.is_colliding():
		can_move = false
		
		var col = $RayCast.get_collider() #variable para guardar las colisiones
		
		if col.is_in_group("Wall") and Input.is_action_just_pressed("ui_accept"):
			motion.y -= JUMP_HEIGHT
			
			if $AnimatedSprite.flip_h:
				motion.x += BOUNCING_JUMP
				$AnimatedSprite.flip_h = false
			else:
				motion.x -= BOUNCING_JUMP
				$AnimatedSprite.flip_h = true
				
				"""el if de aqui arriba es para dar efecto de que reboto en la pared
				por eso volteamos el sprite"""
				
	motion = move_and_slide(motion, FLOOR)
