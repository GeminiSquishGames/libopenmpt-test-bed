extends AudioStreamPlayer


func fade_bgm(speed : float = 5.0):
    # trying a tween for song fade
    var tween = get_tree().create_tween()
    tween.tween_property(self,"volume_db",-80.0,speed)
