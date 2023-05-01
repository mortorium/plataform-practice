extends Area2D

export (PackedScene) var Shoot

onready var player : KinematicBody2D = get_tree().get_nodes_in_group("Player")[0] #referencia al nodo Player
var motion : float


func _ready():
	$AnimatedSprite.play("Iddle")


func _process(delta):
	motion_ctrl()
	tween_ctrl()


func _input(event):
	if event.is_action_pressed("shoot"):
		shoot_ctrl()


func motion_ctrl():
	if player.get_node("Sprite").flip_h:
		scale.x = -1
		motion = player.global_position.x + 20
	else:
		scale.x = 1
		motion = player.global_position.x - 20


func tween_ctrl():
	$Tween.interpolate_property(
	self, #Objeto Afectado
	"global_position", #Propiedad Afectada
	global_position, #Valor Inicial
	Vector2(motion, player.global_position.y - 8), #Valor Final
	0.2, #Tiempo que transcurre entre uno y otro
	Tween.TRANS_SINE, #Transicion Inicial
	Tween.EASE_OUT #Transicion Final
	)
	$Tween.start()

func shoot_ctrl():
	var shoot = Shoot.instance()
	shoot.global_position = $ShootSpawn.global_position
	
	if player.get_node("Sprite").flip_h:
		shoot.scale.x = -1
		shoot.direction = -224
	else:
		shoot.scale.x = 1
		shoot.direction = 224
	
	get_tree().call_group("Level", "add_child", shoot)
