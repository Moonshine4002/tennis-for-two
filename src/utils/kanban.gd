extends Panel

@export var data: Array[Array] = [
	["Task", "Progress"],
	["Gameplay", "alpha"],
	["Physics", "alpha"],
	["Network", "beta"],
	["UI", "50%"],
	["Tutorial", "0%"],
	["Cover", "20%"],
	["Music", "0%"],
	["More :)", "0%"],
]


func _ready() -> void:
	$Tree.columns = 2
	for value: Array[String] in data:
		var item: TreeItem = $Tree.create_item()
		for i in $Tree.columns:
			item.set_text(i, value[i])
