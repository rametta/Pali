extends Resource

class_name CardResource

enum Category {
	Scientist,
	Engineer,
	Farmer,
	Artist,
	Medical
}

enum Tag {
	Nature,
	Goggles,
	WhiteCoat,
	Physical,
	Mental
}

@export var id: int
@export var title: String
@export var color: Color
@export var texture: Texture2D
@export var value: int
@export var category: Category
@export var tags: Array[Tag]
@export var relations: Array[CardRelation]

