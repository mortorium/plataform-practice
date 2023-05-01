extends Area2D

export(String, "coin", "chest") var type : String
onready var active : bool = true

func _ready():
	$AnimationPlayer.play("Iddle")


func _on_Coin_body_entered(body):
	if body.is_in_group("Player"):
		$AnimationPlayer.play("Join")


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"Join":
			if active:
				active = false
				
				match type:
					"coin":
						Nodo.coins += 1
					"chest":
						Nodo.coins += 100


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Join":
			queue_free()
