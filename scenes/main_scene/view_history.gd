extends Panel

@onready var history_list = $ScrollContainer/history_list
@onready var content = $ScrollContainer/history_list/content  # the Label node you want to duplicate

func _ready():
	content.visible = false
	_load_history()

func _clear_history_list():
	for child in history_list.get_children():
		if child != content:
			child.queue_free()

func _load_history():
	_clear_history_list()

	var folder_path = "user://code_conquer_saves_gameplay"
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Cannot access folder: %s" % folder_path)
		return

	var line_tuples = []  # Will store (date_str, line)

	dir.list_dir_begin()
	var filename = dir.get_next()
	while filename != "":
		if filename.ends_with("_game_history.txt"):
			var file_path = "%s/%s" % [folder_path, filename]
			if FileAccess.file_exists(file_path):
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					while not file.eof_reached():
						var line = file.get_line()
						if line.strip_edges() != "":
							var date_str = _extract_date(line)
							if date_str != "":
								line_tuples.append([date_str, line])
					file.close()
				else:
					push_error("Failed to open file: %s" % file_path)
		filename = dir.get_next()
	dir.list_dir_end()

	if line_tuples.size() == 0:
		print("No game history lines found in folder.")
		return

	# Sort by date string ascending
	line_tuples.sort()  # sorts by first element in tuple i.e. date_str ascending

	# Reverse for latest first
	line_tuples.reverse()

	# Debug print
	print("After sorting:")
	for tuple in line_tuples:
		print(tuple[0], tuple[1])

	for tuple in line_tuples:
		var line = tuple[1]
		var new_label = content.duplicate()
		new_label.visible = true

		var decorated_line = line
		decorated_line = decorated_line.replace("Player:", "👤 Player:")
		decorated_line = decorated_line.replace("Difficulty:", "🎚️ Difficulty:")
		decorated_line = decorated_line.replace("Time:", "⏱️ Game Time:")
		decorated_line = decorated_line.replace("Deaths:", "💀 Deaths:")
		decorated_line = decorated_line.replace("Doors:", "🚪 Unlock Doors:")
		decorated_line = decorated_line.replace("Chests:", "🎁 Unlock Chests:")
		decorated_line = decorated_line.replace("Drones:", "🤖 Killed Drones:")
		decorated_line = decorated_line.replace("Robots:", "🦾 Killed Robots:")

		new_label.text = decorated_line
		history_list.add_child(new_label)
		# no need to move_child if you add in newest-to-oldest order

func _compare_by_date(a: String, b: String) -> int:
	var date_str_a = _extract_date(a)
	var date_str_b = _extract_date(b)
	# Debug print to confirm:
	print("Comparing:", date_str_a, "<->", date_str_b)

	if date_str_a > date_str_b:
		return 1
	elif date_str_a < date_str_b:
		return -1
	else:
		return 0

func _extract_date(line: String) -> String:
	var start = line.find("[")
	var end = line.find("]")
	if start == -1 or end == -1 or end <= start:
		return ""
	return line.substr(start + 1, end - start - 1).strip_edges()
