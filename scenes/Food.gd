extends Node2D

func _ready():
    var food = ColorRect.new()
    food.size = Vector2(30, 30)
    food.color = Color.RED
    add_child(food)

func place_food(pos):
    position = pos * 32 