extends KinematicBody2D

const SPEED = 128
const FLOOR = Vector2(0, -1) #direccon del suelo
const GRAVITY = 16 #establecemos la fuerza de gravedad
const JUMP_HEIGHT = 384
const BOUNCING_JUMP = 112 #fuerza de rebote en la pared
const CAST_WALL = 10 #distancia de colision contra la pared
const CAST_ENEMY = 20 #distance de colision contra enemigos
onready var motion = Vector2.ZERO
var can_move : bool #es para saber si el Player se puede mover

"""STATE MACHINE"""
var playback : AnimationNodeStateMachinePlayback


func _ready():
	playback = $AnimationTree.get("parameters/playback") #obtenemos el parametro del playback del
	#nodo animation tree
	playback.start("Iddle") #Lo iniciamos en estado Iddle
	$AnimationTree.active = true #y o


func _process(delta):
	motion_ctrl()
	direction_ctrl()
	jump_ctrl()
	attack_ctrl()


func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis


func motion_ctrl():
	motion.y += GRAVITY
	
	if can_move: #aqui indicamos que se puede mover solo si can_move devuelve true
		motion.x = get_axis().x * SPEED
		
		if get_axis().x == 0:
			playback.travel("Iddle")
		else:
			playback.travel("run")
		
		match playback.get_current_node():
			"Iddle":
				motion.x = 0
				$Particles.emitting = false
			"run":
				$Particles.emitting = true
		
		if get_axis().x == 1:
			$Sprite.flip_h = false
		elif get_axis().x == -1:
			$Sprite.flip_h = true
			
	motion = move_and_slide(motion, FLOOR)

#con esta funcion mantenemos cierto orden en la direccion de los raycast
func direction_ctrl():
	match $Sprite.flip_h:
		true:
			$RayCast.cast_to.x = -CAST_WALL
			$RayAttack.cast_to.x = -CAST_ENEMY
		false:
			$RayCast.cast_to.x = CAST_WALL
			$RayAttack.cast_to.x = CAST_ENEMY

func jump_ctrl():
	match is_on_floor():
		true:
			can_move = true
			$RayCast.enabled = false
			if Input.is_action_just_pressed("ui_accept"):
				motion.y -= JUMP_HEIGHT
		false:
			$Particles.emitting = false
			$RayCast.enabled = true
			if motion.y < 0:
				playback.travel("Jump")
			else:
				playback.travel("Fall")
			
			if $RayCast.is_colliding():
				can_move = false

				var col = $RayCast.get_collider() #variable para guardar las colisiones

				if col.is_in_group("Wall") and Input.is_action_just_pressed("ui_accept"):
					motion.y -= JUMP_HEIGHT

					if $Sprite.flip_h:
						motion.x += BOUNCING_JUMP
						$Sprite.flip_h = false
					else:
						motion.x -= BOUNCING_JUMP
						$Sprite.flip_h = true
					"""el if de aqui arriba es para dar efecto de que reboto en la pared
					por eso volteamos el sprite"""
				
#funcion para controlar los ataques del player
func attack_ctrl():
	if is_on_floor():
		if get_axis().x == 0 and Input.is_action_pressed("attack"):
			match playback.get_current_node():
				"Iddle":
					playback.travel("Attack-1")
				"Attack-1":
					playback.travel("Attack-2")
				"Attack-2":
					playback.travel("Attack-3")
	
	#activar o desactivar RayAttack 
	if playback.get_current_node() == "Attack-1" or playback.get_current_node() == "Attack-2" or \
	 playback.get_current_node() == "Attack-3":
		$RayAttack.enabled = true
	else:
		$RayAttack.enabled = false
	
	#Funcion temporal pa saber si funciona
	var col = $RayAttack.get_collider()
	
	if $RayAttack.is_colliding() and col.is_in_group("Enemy"):
		col.queue_free()
