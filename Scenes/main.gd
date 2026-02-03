extends Node3D

var WhitePos = {}
var BlackPos = {}
var WhichColor = {"White" : true, "Black" : false}

func _ready() -> void:
	for piece in get_children():
		if piece.name.find("White") != -1:
			WhitePos.set(piece, Vector2(piece.position.x, piece.position.z))
		if piece.name.find("Black") != -1:
			BlackPos.set(piece, Vector2(piece.position.x, piece.position.z))

func _switchColor():
	WhichColor["White"] = !WhichColor["White"]
	WhichColor["Black"] = !WhichColor["Black"]
	if !WhichColor["White"]:
		$AnimationPlayer.play("SwitchSides")
	else:
		$AnimationPlayer.play("SwitchSides", -1, -1, true)

func getCurrentColor() -> Dictionary:
	return WhitePos if WhichColor["White"] else BlackPos

func getOtherColor() -> Dictionary:
	return BlackPos if WhichColor["White"] else WhitePos

func getCurrentColorName() -> String:
	return WhichColor.find_key(true)
