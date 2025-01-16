extends Node2D

var Snake = preload("res://scenes/Snake.tscn")
var Food = preload("res://scenes/Food.tscn")

var cell_size = 32  # 每个网格的大小
var grid_size = Vector2(20, 15)  # 游戏区域大小

func _ready():
    randomize()  # 初始化随机数生成器
    spawn_snake()
    spawn_food() 

func spawn_snake():
    var snake_instance = Snake.instantiate()
    add_child(snake_instance)

func spawn_food():
    var food_instance = Food.instantiate()
    var valid_position = get_random_position()
    food_instance.place_food(valid_position)
    add_child(food_instance)

func get_random_position():
    var x = randi() % int(grid_size.x)
    var y = randi() % int(grid_size.y)
    return Vector2(x, y) 