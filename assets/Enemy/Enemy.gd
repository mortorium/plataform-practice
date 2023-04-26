extends KinematicBody2D

export (int, 1, 10) var health : int = 3

func _ready():
	$AnimatedSprite.play("Iddle")


func _process(delta):
	if health <= 0:
		queue_free()


func damage_ctrl():
	health -= 1
	print("vida del enemigo: " + str(health))
