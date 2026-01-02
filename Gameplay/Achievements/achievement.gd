extends Resource
class_name Achievement

enum ID {Touch_Grass, Test_Achievement}


@export var name : String
@export var description: String
@export var icon: Texture2D
@export var id: ID
var obtained: bool
