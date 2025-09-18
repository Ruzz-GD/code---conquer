extends Panel

@onready var history_list = $ScrollContainer/history_list
@onready var template_panel = $ScrollContainer/history_list/Panel

func _ready():
	template_panel.visible = false
	_populate_history_list()

func _clear_history_list():
	for child in history_list.get_children():
		if child != template_panel:
			child.queue_free()

func _populate_history_list():
	_clear_history_list()

	var folder_path = "user://code_conquer_saves_gameplay"
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Cannot access folder: %s" % folder_path)
		return

	var histories: Array = []

	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != "":
		if filename.ends_with("_game_history.txt"):
			var file_path = "%s/%s" % [folder_path, filename]
			if FileAccess.file_exists(file_path):
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					while not file.eof_reached():
						var line = file.get_line().strip_edges()
						if line != "":
							var date_str = _extract_date(line)
							if date_str != "":
								histories.append({
									"raw_line": line,
									"date": date_str
								})
					file.close()
		filename = dir.get_next()
	dir.list_dir_end()

	if histories.is_empty():
		print("No game history lines found.")
		return

	# newest first
	histories.sort_custom(func(a, b): return a["date"] > b["date"])

	for history in histories:
		_add_history_row(history["raw_line"], history["date"])

func _add_history_row(line: String, date_str: String) -> void:
	var new_row = template_panel.duplicate()
	new_row.visible = true

	# ✅ Direct children of Panel
	var playername = new_row.get_node_or_null("playername")
	var gamedifficulty = new_row.get_node_or_null("gamedifficulty")
	var gametime = new_row.get_node_or_null("gametime")
	var deathcount = new_row.get_node_or_null("deathcount")
	var unlockdoors = new_row.get_node_or_null("unlockdoors")
	var unlockchests = new_row.get_node_or_null("unlockchests")
	var killeddrones = new_row.get_node_or_null("killeddrones")
	var killedrobots = new_row.get_node_or_null("killedrobots")
	var date = new_row.get_node_or_null("date")

	# ✅ Fill values with emojis
	if playername: playername.text = "👤 " + "Player Name - " + _extract_value(line, "Player:")
	if gamedifficulty: gamedifficulty.text = "🎚️ " + "Game Difficulty - "+ _extract_value(line, "Difficulty:")
	if gametime: gametime.text = "⏱️ " + "Game Time - " + _extract_value(line, "Time:")
	if deathcount: deathcount.text = "💀 " + "Death Count - " + _extract_value(line, "Deaths:")
	if unlockdoors: unlockdoors.text = "🚪 " + "Unlock Doors - " + _extract_value(line, "Doors:")
	if unlockchests: unlockchests.text = "🎁 " + "Unlock Chests - "+ _extract_value(line, "Chests:")
	if killeddrones: killeddrones.text = "🤖 " + "Killed Drones - " +_extract_value(line, "Drones:")
	if killedrobots: killedrobots.text = "🦾 " + "Killed Robots - "+_extract_value(line, "Robots:")
	if date: date.text = "📅 " + "Date - " + date_str

	history_list.add_child(new_row)

func _extract_value(line: String, key: String) -> String:
	if line.find(key) == -1:
		return ""
	var part = line.split(key, false, 1)
	if part.size() < 2:
		return ""
	return part[1].split("|")[0].strip_edges()

func _extract_date(line: String) -> String:
	var start = line.find("[")
	var end = line.find("]")
	if start == -1 or end == -1 or end <= start:
		return ""
	return line.substr(start + 1, end - start - 1).strip_edges()
