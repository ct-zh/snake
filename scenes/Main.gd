extends Node2D

var Snake = preload("res://scenes/Snake.tscn")
var Food = preload("res://scenes/Food.tscn")
var UI = preload("res://scenes/UI.tscn")

var cell_size = 32  # 每个网格的大小
var grid_size = Vector2(20, 15)  # 游戏区域大小

func _ready():
	randomize()  # 初始化随机数生成器
	# 添加UI
	var ui = UI.instantiate()
	add_child(ui)
	
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
	var snake = get_node("Snake")
	var pos
	var valid = false
	
	while !valid:
		valid = true
		pos = Vector2(
			randi() % int(grid_size.x),
			randi() % int(grid_size.y)
		)
		
		# 检查是否与蛇身重叠
		if snake:
			for segment in snake.body:
				if segment.position == pos * cell_size:
					valid = false
					break
	
	return pos 
