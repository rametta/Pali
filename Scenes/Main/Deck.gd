extends Node3D

const card_scene = preload("res://Scenes/Card/Card2.tscn")

const a = preload("res://Cards/Resources/3DArtist1.tres")
const b = preload("res://Cards/Resources/Actor2.tres")
const c = preload("res://Cards/Resources/AerospaceEngineer3.tres")
const d = preload("res://Cards/Resources/Arborist4.tres")
const e = preload("res://Cards/Resources/BeeKeeper5.tres")
const f = preload("res://Cards/Resources/Biologist6.tres")
const g = preload("res://Cards/Resources/Botanist7.tres")
const h = preload("res://Cards/Resources/Chemist8.tres")
const i = preload("res://Cards/Resources/CivilEngineer9.tres")
const j = preload("res://Cards/Resources/Dentist10.tres")
const k = preload("res://Cards/Resources/ElectricalEngineer11.tres")
const l = preload("res://Cards/Resources/Fisherman12.tres")
const m = preload("res://Cards/Resources/Gardener13.tres")
const n = preload("res://Cards/Resources/Geologist14.tres")
const o = preload("res://Cards/Resources/MartialArtist15.tres")
const p = preload("res://Cards/Resources/MechanicalEngineer16.tres")
const q = preload("res://Cards/Resources/Musician17.tres")
const r = preload("res://Cards/Resources/Mycologist18.tres")
const s = preload("res://Cards/Resources/Nurse19.tres")
const t = preload("res://Cards/Resources/Painter20.tres")
const u = preload("res://Cards/Resources/Pharmacist21.tres")
const v = preload("res://Cards/Resources/Physician22.tres")
const w = preload("res://Cards/Resources/Psychologist23.tres")
const x = preload("res://Cards/Resources/Rancher24.tres")
const y = preload("res://Cards/Resources/SoftwareEngineer25.tres")

const cards = [a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y]

func deck_init() -> void:
	for index in range(len(cards)):
		var card = card_scene.instantiate()
		var card_resource = cards[index]
		
		card.card_resource = card_resource
		card.zone = Global.CARD_ZONE.DECK
		
		add_child(card)
		card.rotation_degrees = Vector3(0, 90, -180)
		card.position.y = float(index) * .015
		
#		var tween = get_tree().create_tween()
#		tween.tween_interval(i * .15)
#		tween.tween_property(card, "position:y", i * .015, .15)
