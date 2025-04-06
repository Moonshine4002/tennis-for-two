extends Panel

@export var data: Dictionary = {
	"Main Game_Progress":
	[
		"Gameplay_alpha",
		"Control_20%",
		"Art_20%",
		"Music_0%",
		"Physics_80%",
		"Network_80%",
		"UI_50%",
		"HUD_20%",
		"Camera_0%",
		"Render_alpha",
		"Tutorial_0%",
		"Cover_20%",
	],
	"More Games_0%": [],
	"Archive_Progress":
	[
		"Tennis for Two[OLD]_stable",
		"Snooker_80%",
		"Break the Bricks_beta",
	]
}


func _ready() -> void:
	$Tree.columns = 2
	var root: TreeItem = $Tree.create_item()
	$Tree.hide_root = true
	for key: String in data:
		var sub_root: TreeItem = $Tree.create_item(root)
		var strs_title = key.split("_")
		for i in $Tree.columns:
			sub_root.set_text(i, strs_title[i])
		for value: String in data[key]:
			var item: TreeItem = $Tree.create_item(sub_root)
			var strs = value.split("_")
			for i in $Tree.columns:
				item.set_text(i, strs[i])
