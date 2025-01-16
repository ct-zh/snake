extends Node2D

func _ready():
	var food = ColorRect.new()
	food.size = Vector2(30, 30)
	food.color = Color(1, 0, 0.3)
	
	var tween = create_tween()
	tween.tween_property(food, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(food, "scale", Vector2(1.0, 1.0), 0.5)
	tween.set_loops()
	
	add_child(food)

func place_food(pos):
	position = pos * 32 
