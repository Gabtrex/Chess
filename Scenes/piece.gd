extends MeshInstance3D

@export var type : String = "Pawn"
var moved : bool = false
var previewMovement :PackedScene = load("res://Scenes/available_moves.tscn")
var currentPreviews : Array

func straightLineMovement(from : Vector2, max : int) -> Array[Vector2]:
	var allowedMoves : Array[Vector2]
	var calculs : Array[Vector2] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for i in range(4):
		var j : int = 1
		while !get_parent().getCurrentColor().find_key(Vector2(from.x + calculs[i].x * j, from.y + calculs[i].y * j)):
			if get_parent().getOtherColor().find_key(Vector2(from.x + calculs[i].x * j, from.y + calculs[i].y * j)):
				allowedMoves.append(Vector2(from.x + calculs[i].x * j, from.y + calculs[i].y * j))
				break
			allowedMoves.append(Vector2(from.x + calculs[i].x * j, from.y + calculs[i].y * j))
			j += 1
			if j >= max:
				break
	if allowedMoves.find(from):
		allowedMoves.erase(from)
	return allowedMoves

func diagonalMovement(from : Vector2, max : int) -> Array[Vector2]:
	var allowedMoves : Array[Vector2]
	var calculs : Array[Vector2i] = [Vector2i(1,1), Vector2i(-1,-1), Vector2i(-1,1), Vector2i(1,-1)]
	for i in range(4):
		var j : int = 1
		while !get_parent().getCurrentColor().find_key(Vector2(from.x + calculs[i].x * j, from.y + calculs[i].y * j)):
			if get_parent().getOtherColor().find_key(Vector2(from.x + calculs[i].x * j, from.y + calculs[i].y * j)):
				allowedMoves.append(Vector2(from.x + calculs[i].x * j, from.y + calculs[i].y * j))
				break
			allowedMoves.append(Vector2(from.x + calculs[i].x * j, from.y + calculs[i].y * j))
			j += 1
			if j >= max:
				break
	if allowedMoves.find(from):
		allowedMoves.erase(from)
	return allowedMoves

func calculateMovement(from : Vector2) -> Array[Vector2]:
	var allowedMoves : Array[Vector2]
	var whiteOrBlackMultiplication : int = 1
	
	#Checks the color
	if get_parent().getCurrentColorName() == "Black":
		whiteOrBlackMultiplication = -1
	
	#-----------# Pawn #-----------#
	if type == "Pawn":
		#Checks the moves
		if !get_parent().getCurrentColor().find_key(Vector2(from.x, from.y - 1 * whiteOrBlackMultiplication)) && !get_parent().getOtherColor().find_key(Vector2(from.x, from.y - 1 * whiteOrBlackMultiplication)):
			allowedMoves.append(Vector2(from.x, from.y - 1 * whiteOrBlackMultiplication))
			if moved == false && !get_parent().getCurrentColor().find_key(Vector2(from.x, from.y - 2 * whiteOrBlackMultiplication)) && !get_parent().getOtherColor().find_key(Vector2(from.x, from.y - 2 * whiteOrBlackMultiplication)):
				allowedMoves.append(Vector2(from.x, from.y - 2 * whiteOrBlackMultiplication))
		if get_parent().getOtherColor().find_key(Vector2(from.x - 1, from.y - 1 * whiteOrBlackMultiplication)):
			allowedMoves.append(Vector2(from.x -1, from.y - 1 * whiteOrBlackMultiplication))
		if get_parent().getOtherColor().find_key(Vector2(from.x + 1, from.y - 1 * whiteOrBlackMultiplication)):
			allowedMoves.append(Vector2(from.x + 1, from.y - 1 * whiteOrBlackMultiplication))
	#-----------# Rook #-----------#
	if type == "Rook":
		allowedMoves = straightLineMovement(from, 8)
	#-----------# Knight #-----------#
	if type == "Knight":
		var toVerify : Array[Vector2] = [Vector2(from.x + 2, from.y + 1), Vector2(from.x + 2, from.y - 1), Vector2(from.x - 2, from.y + 1), Vector2(from.x - 2, from.y - 1), Vector2(from.x + 1, from.y + 2), Vector2(from.x - 1, from.y + 2), Vector2(from.x + 1, from.y - 2), Vector2(from.x - 1, from.y - 2)]
		for i in toVerify:
			if !get_parent().getCurrentColor().find_key(i) || get_parent().getOtherColor().find_key(i):
				allowedMoves.append(i)
	#-----------# Bishop #-----------#
	if type == "Bishop":
		allowedMoves = diagonalMovement(from, 8)
	#-----------# Queen #-----------#
	if type == "Queen":
		allowedMoves = straightLineMovement(from, 8) + diagonalMovement(from, 8)
	#-----------# King #-----------#
	if type == "King":
		allowedMoves = straightLineMovement(from, 1) + diagonalMovement(from, 1)
		if len(allowedMoves)== 0:
			print("end of the game")
	
	var duppedAllowedMoves = allowedMoves.duplicate()
	for move in allowedMoves:
		if move.x > 8 || move.y < -8 || move.x < 0 || move.y > 0:
			duppedAllowedMoves.erase(move)
	
	return duppedAllowedMoves

func canMove(from : Vector2, to : Vector2) -> bool:
	# verifies if the to position matches any of these
	for moves in calculateMovement(from):
		if moves == to:
			return true
	return false

func _displayMoves(from : Vector2):
	for move in calculateMovement(from):
		var instantiatedMovementPreview = previewMovement.instantiate()
		
		currentPreviews.append(instantiatedMovementPreview)
		instantiatedMovementPreview.position = Vector3(move.x, instantiatedMovementPreview.position.y , move.y)
		get_parent().add_child(instantiatedMovementPreview)

func _removeDisplayMoves(from : Vector2):
	for instance in currentPreviews:
		instance.queue_free()
	currentPreviews = []
