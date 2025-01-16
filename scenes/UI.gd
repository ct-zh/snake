extends CanvasLayer

var score = 0

func _ready():
	update_score(0)

func update_score(new_score):
	score = new_score
	$ScoreLabel.text = "分数: %d" % score

func show_game_over():
	$GameOverLabel.show()
	$RestartButton.show()

func hide_game_over():
	$GameOverLabel.hide()
	$RestartButton.hide()

func _on_restart_button_pressed():
	get_tree().reload_current_scene() 
