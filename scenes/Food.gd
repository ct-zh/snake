extends Node2D

var cell_size = 32  # 添加网格大小变量
var food_rect: ColorRect

func _ready():
	food_rect = ColorRect.new()
	food_rect.size = Vector2(30, 30)  # 稍小于格子大小，留出边框
	food_rect.color = Color(1, 0, 0.3)  # 粉红色
	food_rect.position = Vector2(-15, -15)  # 居中显示
	add_child(food_rect)
	
	# 创建呼吸动画效果
	var tween = create_tween()
	tween.tween_property(food_rect, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(food_rect, "scale", Vector2(1.0, 1.0), 0.5)
	tween.set_loops()

func place_food(grid_pos):
	# 将网格坐标转换为实际位置
	position = grid_pos * cell_size
	print("食物放置在网格坐标：", grid_pos, "，实际位置：", position)
