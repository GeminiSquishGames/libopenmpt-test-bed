extends Sprite2D


func _on_timer_timeout():
    modulate.h = modulate.h + 0.83333
    modulate.s = modulate.s + 0.125
