extends Resource
class_name Achievement

enum ID {DoubleFisting, AllTheBeers,}


@export var name : String
@export var description: String
@export var icon: Texture2D
@export var material: Material
@export var id: ID
var obtained: bool
