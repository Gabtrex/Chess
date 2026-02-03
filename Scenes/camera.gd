extends Camera3D

var selectedAPiece : bool = false
var selPiece : MeshInstance3D
var canPlay : bool = true
var hover : PackedScene = load("res://Scenes/hover.tscn")
var previousHoverInstance : MeshInstance3D
var selPieceZone : PackedScene = load("res://Scenes/selected_piece.tscn")
var instantiatedSelPieceZone = selPieceZone.instantiate()

func _process(delta: float) -> void:
	#Hover animation
	$RayCast3D.target_position = project_local_ray_normal(get_viewport().get_mouse_position()) * 100
	$RayCast3D.force_raycast_update()
	
	if $RayCast3D.is_colliding():
		var instantiatedHover = hover.instantiate()
		if previousHoverInstance != null:
			if previousHoverInstance.position != Vector3($RayCast3D.get_board_position().x, previousHoverInstance.position.y, $RayCast3D.get_board_position().z):
				previousHoverInstance.queue_free()
				instantiatedHover.position = Vector3($RayCast3D.get_board_position().x, instantiatedHover.position.y, $RayCast3D.get_board_position().z)
				get_parent().add_child(instantiatedHover)
				previousHoverInstance = instantiatedHover
		else:
			instantiatedHover.position = Vector3($RayCast3D.get_board_position().x, instantiatedHover.position.y, $RayCast3D.get_board_position().z)
			get_parent().add_child(instantiatedHover)
			previousHoverInstance = instantiatedHover

func _input(event: InputEvent) -> void:
	#Moving Pieces
	if event.is_action_pressed("Click"):
		if canPlay:
			if $RayCast3D.is_colliding():
				if selectedAPiece:
					if !get_parent().getCurrentColor().find_key(Vector2($RayCast3D.get_board_position().x, $RayCast3D.get_board_position().z)):
						if selPiece.canMove(Vector2(selPiece.position.x,selPiece.position.z), Vector2($RayCast3D.get_board_position().x,$RayCast3D.get_board_position().z)):
							selectedAPiece = false
							instantiatedSelPieceZone.queue_free()
							get_parent().getCurrentColor().set(selPiece, Vector2($RayCast3D.get_board_position().x, $RayCast3D.get_board_position().z))
							selPiece.moved = true
							selPiece._removeDisplayMoves(Vector2(selPiece.position.x, selPiece.position.z))
							
							#tween animation for the piece
							var tween = create_tween()
							tween.tween_property(selPiece, "position", Vector3($RayCast3D.get_board_position().x, selPiece.position.y, $RayCast3D.get_board_position().z), .25)
							if get_parent().getOtherColor().find_key(Vector2($RayCast3D.get_board_position().x, $RayCast3D.get_board_position().z)) != null:
								get_parent().getOtherColor().find_key(Vector2($RayCast3D.get_board_position().x, $RayCast3D.get_board_position().z)).queue_free()
								get_parent().getOtherColor().erase(get_parent().getOtherColor()[get_parent().getOtherColor().find_key(Vector2($RayCast3D.get_board_position().x, $RayCast3D.get_board_position().z))])
							
							#change sides
							get_parent()._switchColor()
							canPlay = false
							$CDBeforePlaying.start()
							await $CDBeforePlaying.timeout
							canPlay = true
					else:
						instantiatedSelPieceZone.queue_free()
						selectedAPiece = true
						selPiece._removeDisplayMoves(Vector2(selPiece.position.x, selPiece.position.z))
						selPiece = get_parent().getCurrentColor().find_key(Vector2($RayCast3D.get_board_position().x, $RayCast3D.get_board_position().z))
						selPiece._displayMoves(Vector2(selPiece.position.x, selPiece.position.z))
						instantiatedSelPieceZone = selPieceZone.instantiate()
						instantiatedSelPieceZone.position = Vector3($RayCast3D.get_board_position().x, instantiatedSelPieceZone.position.y, $RayCast3D.get_board_position().z)
						get_parent().add_child(instantiatedSelPieceZone)
				else:
					if get_parent().getCurrentColor().find_key(Vector2($RayCast3D.get_board_position().x, $RayCast3D.get_board_position().z)) != null:
						selectedAPiece = true
						selPiece = get_parent().getCurrentColor().find_key(Vector2($RayCast3D.get_board_position().x, $RayCast3D.get_board_position().z))
						selPiece._displayMoves(Vector2(selPiece.position.x, selPiece.position.z))
						instantiatedSelPieceZone = selPieceZone.instantiate()
						instantiatedSelPieceZone.position = Vector3($RayCast3D.get_board_position().x, instantiatedSelPieceZone.position.y, $RayCast3D.get_board_position().z)
						get_parent().add_child(instantiatedSelPieceZone)
