extends Resource
class_name MapGenZone

## Rooms with one exit
@export var endrooms: Array[MapGenRoom]
## Single rooms with one exit
@export var endrooms_single: Array[MapGenRoom] = []
## Max size - 4, or mapgen won't generate
@export var endrooms_single_large: Array[MapGenRoom] = []
## Rooms with two exits, straight
@export var hallways: Array[MapGenRoom]
## Single rooms with two exits, straight
@export var hallways_single: Array[MapGenRoom] = []
## Rooms with two exits, corner
@export var corners: Array[MapGenRoom]
## Single rooms with two exits, corner
@export var corners_single: Array[MapGenRoom] = []
## Rooms with three exits
@export var trooms: Array[MapGenRoom]
## Single rooms with three exits
@export var trooms_single: Array[MapGenRoom] = []
## Rooms with four exits
@export var crossrooms: Array[MapGenRoom]
## Single rooms with four exits
@export var crossrooms_single: Array[MapGenRoom] = []

func _init(p_endrooms: Array[MapGenRoom] = [], p_hallways: Array[MapGenRoom] = [], p_corners: Array[MapGenRoom] = [],
p_trooms: Array[MapGenRoom] = [], p_crossrooms: Array[MapGenRoom] = []):
	endrooms = p_endrooms
	hallways = p_hallways
	corners = p_corners
	trooms = p_trooms
	crossrooms = p_crossrooms
