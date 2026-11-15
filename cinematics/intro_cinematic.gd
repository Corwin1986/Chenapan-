extends Node2D
## Approved standalone cinematic V3, with the existing start/skip contract.
signal finished
signal cue(kind: String)
const DURATION = 60.0
const SKIP_RECT = Rect2(548,33,150,65)
var elapsed = 0.0
var active = false
var suspended = false
var player: VideoStreamPlayer
var saved_music_db = -12.0
var music: AudioStreamPlayer

func _ready():
	visible = false
	z_index = 20
	player = VideoStreamPlayer.new()
	player.stream = preload("res://cinematics/intro_validated_v3.ogv")
	player.expand = true
	player.size = Vector2(720,1280)
	player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player.finished.connect(skip)
	add_child(player)
	var panel = Panel.new()
	panel.position = SKIP_RECT.position
	panel.size = SKIP_RECT.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color("392b3c")
	style.set_corner_radius_all(15)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var label = Label.new()
	label.text = "PASSER"
	label.size = SKIP_RECT.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font",preload("res://assets/comic_title.ttf"))
	label.add_theme_font_size_override("font_size",27)
	label.add_theme_color_override("font_color",Color("fff4db"))
	panel.add_child(label)

func begin():
	if active:
		player.stop()
	else:
		music = get_parent().get("music_player") as AudioStreamPlayer
		if is_instance_valid(music):
			saved_music_db = music.volume_db
			music.volume_db = -80.0
	elapsed = 0.0
	active = true
	suspended = false
	visible = true
	player.paused = false
	player.play()

func skip():
	if not active: return
	active = false
	visible = false
	player.stop()
	_restore_music()
	finished.emit()

func _restore_music():
	if is_instance_valid(music): music.volume_db = saved_music_db

func _process(_delta):
	if active and not suspended:
		elapsed = player.stream_position

func _notification(what):
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		suspended = true
		if is_instance_valid(player) and active: player.paused = true
	elif what in [NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN]:
		suspended = false
		if is_instance_valid(player) and active: player.paused = false

func _exit_tree():
	_restore_music()
