extends Node3D

const card_scene = preload("res://Scenes/Card/Card.tscn")

const card_resources = [
	preload("res://Cards/Resources/ThreeDArtist1.tres"),
	preload("res://Cards/Resources/Actor2.tres"),
	preload("res://Cards/Resources/AerospaceEngineer3.tres"),
	preload("res://Cards/Resources/Arborist4.tres"),
	preload("res://Cards/Resources/BeeKeeper5.tres"),
	preload("res://Cards/Resources/Biologist6.tres"),
	preload("res://Cards/Resources/Botanist7.tres"),
	preload("res://Cards/Resources/Chemist8.tres"),
	preload("res://Cards/Resources/CivilEngineer9.tres"),
	preload("res://Cards/Resources/Dentist10.tres"),
	preload("res://Cards/Resources/ElectricalEngineer11.tres"),
	preload("res://Cards/Resources/Fisherman12.tres"),
	preload("res://Cards/Resources/Gardener13.tres"),
	preload("res://Cards/Resources/Geologist14.tres"),
	preload("res://Cards/Resources/MartialArtist15.tres"),
	preload("res://Cards/Resources/MechanicalEngineer16.tres"),
	preload("res://Cards/Resources/Musician17.tres"),
	preload("res://Cards/Resources/Mycologist18.tres"),
	preload("res://Cards/Resources/Nurse19.tres"),
	preload("res://Cards/Resources/Painter20.tres"),
	preload("res://Cards/Resources/Pharmacist21.tres"),
	preload("res://Cards/Resources/Physician22.tres"),
	preload("res://Cards/Resources/Psychologist23.tres"),
	preload("res://Cards/Resources/Rancher24.tres"),
	preload("res://Cards/Resources/SoftwareEngineer25.tres")
]

func deck_init(random_arr_indices: PackedByteArray) -> void:
	for index in range(len(random_arr_indices)):
		var card = card_scene.instantiate()
		var card_resource = card_resources[random_arr_indices[index]]

		card.card_resource = card_resource
		card.zone = Global.CARD_ZONE.DECK
		card.name = "card-" + str(card_resource.id)

		add_child(card)
		card.rotation_degrees = Vector3(0, 90, -180)
		card.position.y = float(index) * .015
