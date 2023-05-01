extends Area2D

var direction : int
onready var can_move : bool = true



func _ready():
	$AnimationPlayer.play("Shoot")
	$AudioStreamPlayer2D.play()


func _process(delta):
	#su unica funcion es moverse en direccion x, la cual es definida por quien dispara
	if can_move:
		global_position.x += direction * delta


func _on_VisibilityNotifier2D_screen_exited():
	queue_free() #si sale de la pantalla, se elimina


func _on_Shoot_body_entered(body): #el area emite la señal body_entered
	if body.is_in_group("Enemy"): #si el cuerpo que colisiona esta en el grupo enemy
		body.damage_ctrl(1) #llamamos a la funcion damage_ctrl y le pasamos el daño como parametro
		$AnimationPlayer.play("Explosion")
	elif body.is_in_group("Wall"):
		$AnimationPlayer.play("Explosion")


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"Explosion":
			can_move = false


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Explosion":
			queue_free()
