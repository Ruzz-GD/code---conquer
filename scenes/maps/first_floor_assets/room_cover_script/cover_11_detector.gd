extends Area2D

@onready var room_cover = $"../cover-11"

func _ready():

	if room_cover:
		print("✅ Room cover assigned successfully:", room_cover)
		print("🖌 Initial modulate:", room_cover.modulate)  # Prints initial color
		room_cover.modulate = Color(0, 0, 0, 1)  # Start darkened
		print("🎨 Updated modulate:", room_cover.modulate)  # Confirms the change
	else:
		print("❌ ERROR: Could not find ColorRect-Main-Room. Check node structure!")

func _on_body_entered(body):
	print("Something entered:", body.name)
	if body.is_in_group("player"):
		print("✅ Player entered the room!")
		if room_cover:
			print("🌀 Fading out room cover...")
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(room_cover, "modulate", Color(0, 0, 0, 0), 1.0)  # Fade out
			await tween.finished
			print("✅ Room fully revealed:", room_cover.modulate)

func _on_body_exited(body):
	print("Something exited:", body.name)
	if body.is_in_group("player"):
		print("❌ Player left the room!")
		if room_cover:
			print("🌀 Fading room cover back in...")
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(room_cover, "modulate", Color(0, 0, 0, 1), 1.0)  # Fade in
			await tween.finished
			print("🌑 Room is dark again:", room_cover.modulate)
