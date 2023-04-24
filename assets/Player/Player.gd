extends KinematicBody2D

const SPEED = 128
const FLOOR = Vector2(0, -1) #direccon del suelo
const GRAVITY = 16 #establecemos la fuerza de gravedad
const JUMP_HEIGHT = 384
const BOUNCING_JUMP = 112 #fuerza de rebote en la pared
#const CAST_WALL = 10 #distancia de colision contra la pared
#const CAST_ENEMY = 20 #distance de colision contra enemigos
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
		elif get_axis().x == 1:
			$Sprite.flip_h = false
			playback.travel("run")
		elif get_axis().x == -1:
			playback.travel("run")
			$Sprite.flip_h = true
		
		match playback.get_current_node():
			"Iddle":
				motion.x = 0
				$Particles.emitting = false
			"run":
				$Particles.emitting = true
		
		#Como pusimos los raycast dentro de un nodo position2D ahora solo tenemos
		#que voltear dicho nodo
		match $Sprite.flip_h:
			true:
				$Raycasts.scale.x = 1
			false:
				$Raycasts.scale.x = -1
		
	motion = move_and_slide(motion, FLOOR)


func jump_ctrl():
	match is_on_floor():
		true:
			can_move = true
			if Input.is_action_just_pressed("ui_accept"):
				motion.y -= JUMP_HEIGHT
		false:
			$Particles.emitting = false
			if motion.y < 0:
				playback.travel("Jump")
			else:
				playback.travel("Fall")
			
			if $Raycasts/Wall.is_colliding():
				var body = $Raycasts/Wall.get_collider() #variable para guardar las colisiones
				print("wall")
				if body.is_in_group("Wall"): #comprobamos si esta en el grupo wall
					print("wall")
					if Input.is_action_just_pressed("ui_accept"):
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
	var body = $Raycasts/Hit.get_collider()
	
	if is_on_floor():
		if get_axis().x == 0 and Input.is_action_pressed("attack"):
			match playback.get_current_node():
				"Iddle":
					playback.travel("Attack-1")
				"Attack-1":
					playback.travel("Attack-2")
				"Attack-2":
					playback.travel("Attack-3")
	
	if $Raycasts/Hit.is_colliding() and body.is_in_group("Enemy"):
		print("Colisiona con Enemy")
		body.queue_free()
