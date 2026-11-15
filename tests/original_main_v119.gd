extends Node2D
## Village vs Chenapan — Android. No ads, no network permissions.
const INK = Color("392b3c")
const PAPER = Color("fff4db")
const TEAL = Color("248b89")
const CORAL = Color("e66555")
const GOLD = Color("efbc47")
const PURPLE = Color("805091")
const SKY = Color("b5dee0")
const LANES = [-0.8, -0.4, 0.0, 0.4, 0.8]
const NAMES = ["Baguettator", "Mme Brioche", "Lili Croissant", "Mme Dictée", "M. Craie", "Proviseur Tampon", "Facteur Express", "Mme Timbre", "Jo Colissimo"]
const BUBBLE_LINES = ["Encore lui ?", "Attrapez-le !", "Petit garnement !", "Viens ici !", "Vauriens !", "Voyous !", "Petit bandit !", "Tu vas m’entendre !", "Gare à toi !", "Houste !", "Du balai !"]
var special_slots: Array[String] = []
var continues_used = 0
var mock_action = ""
var enemy_spawn_clock = 1.4
var spawn_group_remainder = 0.0
const SCENERY_SPEED = 0.12
var dogs_timer = 0.0
var last_dog_milestone = 0
var last_storm_milestone = 0
var chatter_count = 0
var chatter_rng = RandomNumberGenerator.new()
const SHOPS = ["BOULANGERIE", "ÉCOLE", "LA POUSTE", "POLICE", "POMPIERS", "CAFÉ", "RESTAURANT", "BOUCHERIE", "ÉGLISE"]
const ENEMY_SPRITES = [[2,3,4],[5,6,7],[8,9,10],[12],[13],[14,15,18],[16,17,19],[20,21],[22,23,24]]
const QUIPS = ["QUI A VOLÉ LES CROISSANTS ?!", "JE VAIS APPELER TES PARENTS !", "COLIS POUR LE PETIT MALIN !", "HALTE LÀ !", "ÇA VA CHAUFFER !", "REVIENS ICI, GARNEMENT !", "TU VAS PASSER À LA CASSEROLE !", "QUI A PRIS MES SAUCISSES ?!", "REVIENS ICI, GARNEMENT !"]
const ELEMENTS = ["GALETS", "FEU", "GLACE", "ÉLECTRICITÉ"]
const ELEMENT_COLORS = [Color("8a7d71"), Color("ff7845"), Color("59c7df"), Color("dfbd42")]
const ROUND_LENGTH = 120.0
const BASE_SHOT_INTERVAL = 0.50
const PROJECTILE_SPEED = 900.0
var street
var clergy_tex: Texture2D = preload("res://assets/clergy_v26.png")
var angry_tex: Texture2D = preload("res://assets/angry_final_v24.png")
var villagers_tex: Texture2D = preload("res://assets/villagers_v23.png")
var butchers_tex: Texture2D = preload("res://assets/butchers_v23.png")
var character_tex: Texture2D = preload("res://assets/characters.png")
var fixed_road_tex: Texture2D = preload("res://assets/village_option5.png")
var sidewalk_tex: Texture2D = preload("res://assets/sidewalk_cobbles.png")
var sidewalk_props_tex: Texture2D = preload("res://assets/sidewalk_props.png")
var building_tex: Texture2D = preload("res://assets/buildings_v3.png")
var body_font: Font = preload("res://assets/comic_body.ttf")
var title_font: Font = preload("res://assets/comic_title.ttf")
var art_tex: Texture2D = preload("res://assets/art_textures.png")
var gear_tex: Texture2D = preload("res://assets/gear.png")
var mode = "menu"
var time = 0.0
var anim = 0.0
var scroll = 0.0
var player_lane = 2
var player_x = -0.255
var life = 100.0
var stones = 1
var element = 0
var element_boost = 1.0
var charges = 1
var score = 0
const SPAWN_INTERVALS = [2.4,1.6,1.2,0.95,0.8,0.65,0.55]
var spawn_upgrade_age = 18.0
var spawn_previous_base = 2.4
var sling_level = 0
var next_sling_score = 2000
var sling_event_index = 0
const SLING_MILESTONES = [2000,5000,10000,15000,20000,25000]
const SLING_COLORS = [Color("936137"),Color("47ae60"),Color("398ddd"),Color("e84e43"),Color("252331"),Color("9853c9"),Color("edb92f")]
var kill_points = 0
var player_p = 1.0
var finger_depth = 1.0
var swipe_anchor_y = 0.0
var best = 0
var kills = 0
var combo = 0
var best_combo = 0
var wave = 0
var shoot_clock = 0.0
var building_clock = 0.0
var pickup_clock = 1.0
var invincible = 0.0
var slow_timer = 0.0
var power_timer = 0.0
var shield = false
var flash = 0.0
var notice = ""
var notice_timer = 0.0
var next_enemy_id = 0
var last_confiscation = false
var boss_spawned = false
var boss_defeated = false
var sound_enabled = true
var help_page = 0
var language = "fr"
var language_selected = false
var menu_translations: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://localization/menus.json"))
var cjk_font: Font = preload("res://assets/ui_cjk.ttc")
const UI_MODES = ["menu","help","privacy","pause","end","win","mock_ad","language","notebook"]
const LANGUAGE_CODES = ["fr","en","es","zh"]
var drag_active = false
var finger_target = 0.0
var gift_categories: Array = []
var swipe_anchor = 0.0
var swipe_used = false
var move_cooldown = 0.0
var jump_timer = 0.0
var fallen: Array = []
var last_gift = ""
var gift_timer = 0.0
var egg = false
var capture_sprite = 7
var capture_timer = 0.0
var muted_for_focus = false
var buildings: Array = []
var enemies: Array = []
var bullets: Array = []
var pickups: Array = []
var particles: Array = []
var words: Array = []
var zaps: Array = []
var tone_cache = {}
var sound_players: Array = []
var audio_index = 0
var music_player: AudioStreamPlayer
var movement_finger = -1
var rng = RandomNumberGenerator.new()
var stats = {"shots":0, "boxes":0, "damage":0, "spawned":0}
var test_mode = false
var ads: Node
var privacy_return_mode = "menu"
var intro: Node2D
var notebook
const PROFESSION_LINES = [
 ["Reviens ici, petit voleur !", "Pas mes croissants !"],
 ["Tu me copieras cent lignes !", "Direction le bureau !"],
 ["Pas encore mes lettres !", "Retour à l’expéditeur !"],
 ["Halte au chenapan !", "On t’a à l’œil !"],
 ["Fausse alerte, vraie poursuite !", "Ça va chauffer !"],
 ["Rends les cacahuètes !", "Pas touche au comptoir !"],
 ["L’addition, petit malin !", "Reviens en cuisine !"],
 ["Pas mes saucisses !", "File par ici !"],
 ["Encore du poivre ?!", "Quelle petite canaille !"]
]

func _ready():
	street=preload("res://scenery/town.gd").new()
	street.g=self
	street.z_index=-10
	add_child(street)
	ads = preload("res://monetization/ad_service.gd").new()
	add_child(ads)
	ads.reward_validated.connect(_on_ad_reward)
	rng.randomize()
	chatter_rng.randomize()
	RenderingServer.set_default_clear_color(SKY)
	get_tree().auto_accept_quit = false
	var cfg = ConfigFile.new()
	if cfg.load("user://progress.cfg") == OK:
		best = int(cfg.get_value("game", "survival_best", 0))
		language = str(cfg.get_value("game", "language", "fr"))
		language_selected = cfg.has_section_key("game", "language") and language in LANGUAGE_CODES
		if not language_selected: language="fr"
		sound_enabled = true # Device volume is the only user sound control.
	for i in range(8):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sound_players.append(p)
	music_player = AudioStreamPlayer.new()
	music_player.stream = preload("res://assets/village_chiptune.wav")
	music_player.volume_db = -12.0
	add_child(music_player)
	intro=preload("res://cinematics/intro_cinematic.gd").new()
	add_child(intro)
	intro.finished.connect(_on_intro_finished)
	intro.cue.connect(_on_intro_cue)
	notebook=preload("res://progression/notebook.gd").new()
	notebook.setup(self)
	seed_village()
	if not language_selected: mode="language"
	if "--smoke" in OS.get_cmdline_user_args():
		test_mode = true
		start_game()
	if "--screenshot" in OS.get_cmdline_user_args():
		start_game()
		time = 24.0
		stones = 4
		element = 1
		for i in range(7):
			spawn_enemy(i % 3, 0.25 + float(i) * 0.085, -1 if i%2==0 else 1, i%3)

func seed_village():
	buildings.clear()
	pass

func start_game():
	if notebook!=null:notebook.begin_round()
	last_dog_milestone=0;last_storm_milestone=0
	special_slots.clear(); continues_used=0; enemy_spawn_clock=1.4; dogs_timer=0.0; spawn_group_remainder=0.0
	ads.begin_round()
	mode = "play"
	time = 0.0
	scroll = 0.0
	player_lane = 2
	player_x = LANES[player_lane]
	life = 100
	stones = 1
	element = 0
	element_boost = 1.0
	charges = 0
	score = 0
	sling_level=0;next_sling_score=2000;sling_event_index=0
	spawn_upgrade_age=18.0;spawn_previous_base=2.4
	kill_points=0;player_p=1.0;finger_depth=1.0
	kills = 0
	combo = 0
	best_combo = 0
	wave = 0
	chatter_count = 0
	shoot_clock = BASE_SHOT_INTERVAL
	building_clock = 4.0
	pickup_clock = 8.0
	invincible = 0.0
	slow_timer = 0.0
	power_timer = 0.0
	shield = false
	flash = 0.0
	boss_spawned = false
	boss_defeated = false
	last_confiscation = false
	enemies.clear()
	bullets.clear()
	pickups.clear()
	particles.clear()
	words.clear()
	zaps.clear()
	stats = {"shots":0,"boxes":0,"damage":0,"spawned":0}
	egg=false; fallen.clear(); jump_timer=0; capture_timer=0; gift_timer=0; last_gift=""; drag_active=false; gift_categories.clear(); finger_target=player_x; movement_finger=-1
	seed_village()
	street.sync()
	buildings.append({"p":0.18,"side":-1,"kind":0,"triggered":false,"left":0,"clock":0.0,"serial":0})
	say("Glisse pour viser : les tirs partent droit devant !", 5.5)
	beep("start")

func _notification(what):
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_GO_BACK_REQUEST,NOTIFICATION_WM_CLOSE_REQUEST] and notebook!=null:notebook.save_data()
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if mode == "play":
			drag_active=false
			mode = "pause"
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if mode == "notebook": mode=notebook.book_return
		elif mode == "cinematic": intro.skip()
		elif mode == "mock_ad": close_mock_ad()
		elif mode == "play": mode = "pause"
		elif mode == "pause": mode = "menu"
		elif mode == "privacy": mode = privacy_return_mode
		elif mode == "help": mode = "menu"
		else: get_tree().quit()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if mode == "notebook": mode=notebook.book_return
			elif mode == "language":
				if language_selected: mode="menu"
			elif mode == "cinematic": intro.skip()
			elif mode == "mock_ad": close_mock_ad()
			elif mode == "play": mode = "pause"
			elif mode == "pause": mode = "play"
			elif mode == "privacy": mode = privacy_return_mode
			else: mode = "menu"
		elif event.keycode == KEY_ENTER:
			if mode == "menu": begin_intro()
			elif mode == "end" or mode == "win": start_game()
		elif event.keycode == KEY_LEFT or event.keycode == KEY_A:
			step_lane(-1)
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D:
			step_lane(1)
		elif event.keycode in [KEY_UP,KEY_W] and mode=="play":
			player_p=clampf(player_p-0.06,0.62,1.02);finger_depth=player_p
		elif event.keycode in [KEY_DOWN,KEY_S] and mode=="play":
			player_p=clampf(player_p+0.06,0.62,1.02);finger_depth=player_p
		elif event.keycode == KEY_SPACE and mode == "play": thunder()
	if event is InputEventScreenTouch:
		if event.pressed: handle_press(event.position, event.index)
		elif event.index == movement_finger:
			drag_active = false; swipe_used = false; movement_finger = -1
	if event is InputEventScreenDrag and event.index == movement_finger and drag_active and mode == "play":
		set_drag_position(event.position)
	if event is InputEventMouseButton and not DisplayServer.is_touchscreen_available():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: handle_press(event.position)
			else: drag_active = false; swipe_used = false
	if event is InputEventMouseMotion and drag_active and mode == "play":
		set_drag_position(event.position)

func handle_press(pos: Vector2, pointer_id: int = 0):
	if mode=="notebook":notebook.handle_book(pos);return
	if mode=="language":
		for i in range(4):
			if Rect2(110,440+i*120,500,90).has_point(pos):
				language=LANGUAGE_CODES[i];language_selected=true;save_progress();mode="menu"
		return
	if mode=="cinematic":
		if intro.SKIP_RECT.has_point(pos): intro.skip()
		return
	if mode == "mock_ad":
		if Rect2(620,28,72,72).has_point(pos): close_mock_ad()
		return
	if mode == "menu":
		if Rect2(70,790,580,82).has_point(pos): begin_intro()
		elif Rect2(70,895,280,66).has_point(pos): notebook.open_book()
		elif Rect2(370,895,280,66).has_point(pos): mode="help";help_page=0
		elif Rect2(70,984,580,62).has_point(pos): begin_intro(true)
		elif Rect2(70,1070,580,62).has_point(pos):mode="language"
		elif Rect2(70,1156,580,62).has_point(pos):open_privacy("menu")
		return
	if mode == "privacy":
		if Rect2(100,575,520,65).has_point(pos): ads.set_age_group("minor")
		elif Rect2(100,655,520,65).has_point(pos): ads.set_age_group("adult")
		elif Rect2(100,735,520,65).has_point(pos): ads.set_age_group("unknown")
		elif Rect2(100,870,520,65).has_point(pos): ads.opt_out()
		elif Rect2(100,960,520,65).has_point(pos): ads.open_privacy_options()
		elif Rect2(100,1100,520,70).has_point(pos): mode=privacy_return_mode
		return
	if mode == "help":
		if Rect2(240,1150,240,70).has_point(pos): mode = "menu"
		elif Rect2(40,1150,170,70).has_point(pos): help_page=maxi(0,help_page-1)
		elif Rect2(510,1150,170,70).has_point(pos): help_page=mini(HELP_PAGES.size()-1,help_page+1)
		return
	if mode == "pause":
		if Rect2(125,565,470,76).has_point(pos): mode = "play"
		elif Rect2(125,659,470,64).has_point(pos):
			ads.abandon_round(); mode = "menu"
		elif Rect2(125,742,470,60).has_point(pos): open_privacy("pause")
		return
	if mode == "end" or mode == "win":
		notebook.handle_summary(pos)
		return
	if mode == "play":
		if Rect2(620,18,76,64).has_point(pos): mode = "pause"; return
		for i in range(special_slots.size()):
			if special_rect(i).has_point(pos): use_special(i); return
		if pos.y < 86 or pos.y>=1180: return
		if not drag_active:
			movement_finger = pointer_id
			drag_active = true
			swipe_anchor = pos.x
			swipe_anchor_y=pos.y
			finger_depth=player_p
			swipe_used = false
			finger_target=player_x

func step_lane(direction: int):
	if mode!="play" or move_cooldown>0:return
	player_lane=clampi(player_lane+direction,0,4)
	player_x=LANES[player_lane]
	move_cooldown=0.22 if slow_timer<=0 else 0.44

func set_lane(x: float):
	if not drag_active:return
	finger_target=clampf(finger_target+(x-swipe_anchor)/389.047619,-0.8,0.8)
	swipe_anchor=x

func set_drag_position(pos: Vector2):
	if not drag_active:return
	var width=absf(road_point(1.0,finger_depth).x-road_point(0.0,finger_depth).x)
	finger_target=clampf(finger_target+(pos.x-swipe_anchor)/maxf(width,1.0),-0.8,0.8)
	var target_y=road_point(finger_target,finger_depth).y+pos.y-swipe_anchor_y
	var lo=0.62;var hi=1.02
	for i in range(14):
		var mid=(lo+hi)*0.5
		if road_point(finger_target,mid).y<target_y:lo=mid
		else:hi=mid
	finger_depth=(lo+hi)*0.5
	swipe_anchor=pos.x;swipe_anchor_y=pos.y

func toggle_sound():
	sound_enabled = true
	save_progress()

func _process(delta):
	var dt = minf(delta,0.1)
	anim += dt
	if anim>3.0:
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--capture="):
				get_viewport().get_texture().get_image().save_png(arg.trim_prefix("--capture="))
				get_tree().quit()
	if music_player != null:
		if mode in ["play","cinematic"] and sound_enabled:
			if not music_player.playing: music_player.play()
			music_player.stream_paused = false
		else: music_player.stream_paused = true
	if mode != "play":
		drag_active = false
		movement_finger = -1
	if mode == "play":
		update_game(dt)
		if notebook!=null:notebook.tick(dt)
	elif mode == "caught":
		capture_timer+=dt
		if capture_timer>=1.5:finish(false)
	elif mode == "menu": scroll += dt*SCENERY_SPEED
	queue_redraw()

func update_game(dt: float):
	spawn_upgrade_age=minf(18.0,spawn_upgrade_age+dt)
	dogs_timer=maxf(0.0,dogs_timer-dt)
	time += dt
	score=int(time)*10+kill_points
	update_special_milestones()
	update_slingshot_milestones()
	move_cooldown=maxf(0,move_cooldown-dt)
	jump_timer=maxf(0,jump_timer-dt)
	if gift_timer>0:
		gift_timer=maxf(0,gift_timer-dt)
		if gift_timer<=0:clear_effect()
	if drag_active:
		player_x=move_toward(player_x,finger_target,dt*player_speed())
		player_p=move_toward(player_p,finger_depth,dt*player_speed()*0.08)
	for f in fallen:
		f.age+=dt; f.pos.y+=dt*380
	fallen=fallen.filter(func(f):return f.age<1.8)
	scroll += dt*SCENERY_SPEED
	street.sync()
	if street.street_shift>0:
		for e in enemies:
			if e.has("world_z"):
				e.world_z-=street.street_shift
				e.door_world.z-=street.street_shift
				e.source_street=street.street_index
	if dogs_timer>0:clear_assailants("dogs")
	invincible = maxf(0.0, invincible-dt)
	slow_timer = maxf(0.0, slow_timer-dt)
	power_timer = maxf(0.0, power_timer-dt)
	flash = maxf(0.0,flash-dt)
	notice_timer = maxf(0.0,notice_timer-dt)
	update_enemy_spawns(dt)
	pickup_clock-=dt
	if pickup_clock<=0:
		spawn_gift()
		pickup_clock=rng.randf_range(7.5,8.5)
	for p in pickups:
		p.p+=dt*0.13
		if absf(p.p-player_p)<=0.09 and absf(player_x-LANES[p.lane])<0.16:
			if p.kind=="slingshot":collect_slingshot(p.level)
			elif p.kind in ["dogs","storm"]: collect_special(p.kind)
			else: apply_pickup(p.kind,p.get("category",""))
			p.p=2.0
	pickups = pickups.filter(func(p): return p.p<1.16)
	var enemy_multiplier=enemy_speed_multiplier()
	for e in enemies:
		if e.hp<=0: continue
		e.age+=dt
		e.hit=maxf(0.0,e.hit-dt)
		e.frozen=maxf(0.0,e.frozen-dt)
		e.slow=maxf(0.0,e.slow-dt)
		var freeze_scale = 0.0 if e.frozen>0 else (0.5 if e.slow>0 else 1.0)
		var movement_dt=dt*enemy_multiplier*freeze_scale
		e.entry_progress+=dt*freeze_scale/0.75
		e.run_phase=e.get("run_phase",float(e.id))+movement_dt*12.0
		update_enemy_steering(e,movement_dt)
		if update_enemy_attack(e,dt):pass
		elif e.has("world_z"):
			# Feet and doors share world coordinates; camera motion naturally closes distance.
			e.world_z-=movement_dt*(1.6+e.variant*0.2)
			e.p=1.0-(e.world_z-street.distance)/30.0
		else:e.p+=movement_dt*e.speed
		if e.burn>0:
			e.burn-=dt
			e.burn_tick-=dt
			if e.burn_tick<=0:
				e.burn_tick=0.5
				damage_enemy(e,0.5*element_boost)
		if e.p>=player_p-0.04 and e.p<player_p+0.10 and absf(e.x-player_x)<0.18:
			if invincible<=0: hurt()
			if life>0:
				jump_timer=0.65
				fallen.append({"sprite":e.sprite,"pos":enemy_pos(e),"age":0.0})
			else:
				capture_sprite=e.sprite; mode="caught"; capture_timer=0
			e.hp=-1
		elif e.p>1.15:e.hp=-1
	enemies = enemies.filter(func(e): return e.hp>0 and e.p<1.4)
	if mode == "play" and life > 0:
		shoot_clock -= dt
		if shoot_clock <= 0.000001:
			fire_salvo()
			shoot_clock += shot_interval()
	update_projectiles(dt)
	for p in particles:
		p.pos+=p.vel*dt; p.vel.y+=dt*180; p.life-=dt
	particles=particles.filter(func(p): return p.life>0)
	for w in words: w.pos.y-=dt*35; w.life-=dt
	words=words.filter(func(w):return w.life>0)
	for z in zaps: z.life-=dt
	zaps=zaps.filter(func(z):return z.life>0)
	if life<=0 and mode=="play": mode="caught"; capture_timer=0

func spawn_enemy(kind: int,p: float,side: int,variant: int,boss=false):
	var v = variant%3
	var hp = 3.0
	if boss: hp=42.0
	next_enemy_id+=1
	var e = {"id":next_enemy_id,"kind":kind,"variant":v,"sprite":ENEMY_SPRITES[kind][variant%ENEMY_SPRITES[kind].size()],"p":p,"x":side*(1.0+0.3*(90+180*p)/(63.333333+325.714286*p)),"startx":side*(1.0+0.3*(90+180*p)/(63.333333+325.714286*p)),"lane":LANES[rng.randi_range(0,4)],"age":0.0,"entry_progress":0.0,"hp":hp,"maxhp":hp,"speed":0.105+float(v)*0.012,"hit":0.0,"slow":0.0,"frozen":0.0,"burn":0.0,"burn_tick":0.5,"warned":false,"boss":boss}
	if boss: e.speed=0.065
	chatter_count+=1
	e.bubble=PROFESSION_LINES[kind][chatter_rng.randi_range(0,1)] if chatter_count%10==0 else ""
	enemies.append(e)
	stats.spawned+=1

func add_pickup(lane: int,kind: String,p: float):
	pickups.append({"lane":lane,"kind":kind,"p":p,"category":next_gift_category() if kind=="mystery" else ""})

func shot_interval() -> float:
	return BASE_SHOT_INTERVAL * (0.5 if last_gift == "energy" else 1.0) / float(sling_level+1)

func fire_salvo():
	if mode != "play" or life <= 0: return
	var origin = road_point(player_x,player_p)-Vector2(0,82)
	for i in range(stones):
		# Parallel trajectories: only the player's position determines aim.
		bullets.append({"pos":origin+Vector2((i-(stones-1)*0.5)*16,0),"life":2.0,"element":4 if egg else element,"power":1.0})
	stats.shots += stones
	beep("shot")

func update_projectiles(dt: float):
	for shot in bullets:
		shot.life -= dt
		var previous: Vector2 = shot.pos
		shot.pos += Vector2.UP * PROJECTILE_SPEED * dt
		var target: Dictionary = {}
		var nearest = INF
		# Sweep the whole segment, hitting the first body crossed, never homing.
		for e in enemies:
			if e.hp <= 0 or e.p > 1.13: continue
			var size = (78.0 + 118.0*e.p) * (1.48 if e.boss else 1.0)
			var feet = enemy_pos(e)
			var body = Rect2(feet-Vector2(size*0.24,size*0.90),Vector2(size*0.48,size*0.82)).grow(6.0)
			if previous.x < body.position.x or previous.x > body.end.x: continue
			if previous.y < body.position.y or shot.pos.y > body.end.y: continue
			var distance = maxf(0.0,previous.y-body.end.y)
			if distance < nearest:
				nearest=distance
				target=e
		if not target.is_empty():
			hit_enemy(target,shot.element,shot.power)
			shot.life=0.0
	bullets=bullets.filter(func(s): return s.life>0 and s.pos.y>150)

func hit_enemy(e: Dictionary,el: int,power: float):
	var multiplier=[1.0,3.0,1.0,2.0,0.5][el]
	damage_enemy(e,power*multiplier)
	burst(enemy_pos(e)-Vector2(0,45),[GOLD,CORAL,SKY,GOLD,Color("a9c66b")][el],5)
	if el==2:e.frozen=3.0
	if el==3:e.slow=3.0

func damage_enemy(e: Dictionary,amount: float):
	if e.hp<=0:return
	e.hp-=amount
	e.hit=0.12
	if e.hp<=0:
		kills+=1
		if notebook!=null:notebook.event("kills")
		combo+=1
		best_combo=maxi(best_combo,combo)
		kill_points+=100
		score=int(time)*10+kill_points
		if e.boss: boss_defeated=true
		burst(enemy_pos(e)-Vector2(0,35),GOLD,12)
		float_word("+100 !",enemy_pos(e)-Vector2(0,65),INK)
		beep("pop")

func hurt():
	life=maxf(0.0,life-10.0)
	stats.damage+=1
	if notebook!=null:notebook.on_damage()
	combo=0
	flash=0.16
	beep("hurt")

func clear_effect():
	var previous_interval = shot_interval()
	stones=1; element=0; egg=false; slow_timer=0; gift_timer=0; last_gift=""
	shoot_clock *= shot_interval() / previous_interval
	for e in enemies:e.frozen=0; e.slow=0
	for shot in bullets:shot.element=0

func next_gift_category() -> String:
	if gift_categories.is_empty():
		gift_categories=["bonus","bonus","bonus","bonus","bonus","malus","malus","malus","malus","malus"]
		for i in range(9,0,-1):
			var j=rng.randi_range(0,i)
			var tmp=gift_categories[i]; gift_categories[i]=gift_categories[j]; gift_categories[j]=tmp
	return gift_categories.pop_back()

func apply_pickup(kind: String,category: String=""):
	var previous_stones=stones
	if kind=="mystery":
		if category=="":category=next_gift_category()
		var choices=["double","triple","fire","ice","electric","heart","energy"] if category=="bonus" else ["egg","soda","trap"]
		if category=="malus" and stones>=2:choices.append("minus")
		kind=choices[rng.randi_range(0,choices.size()-1)]
	if kind=="minus" and stones<2:return
	stats.boxes+=1
	if notebook!=null:notebook.event("boxes")
	clear_effect()
	last_gift=kind; gift_timer=15.0
	match kind:
		"double":stones=2
		"triple":stones=3
		"minus":stones=maxi(1,previous_stones-2)
		"fire":element=1
		"ice":element=2
		"electric":element=3
		"egg":egg=true
		"soda":slow_timer=15.0
		"energy":shoot_clock *= 0.5
		"trap":life=maxf(0.0,life*0.8); gift_timer=3.0; flash=0.25
		"heart":life=minf(100.0,life+20.0); gift_timer=3.0
	if kind=="trap" and notebook!=null:notebook.on_damage()
	beep("hurt" if kind in ["minus","egg","soda","trap"] else "bonus")

func gift_name(kind: String) -> String:
	return {"double":"DOUBLE GALETS", "triple":"TRIPLE GALETS", "minus":"MOINS DE GALETS", "fire":"PIERRES DE FEU", "ice":"BOULES DE NEIGE", "electric":"PIERRES FOUDRE", "egg":"ŒUFS GUM", "soda":"SODA COLLANT", "trap":"PIÈGE À LOUP", "heart":"CŒUR : +20 VIE", "energy":"BOISSON ÉNERGIE"}.get(kind,"")

func gift_description(kind: String) -> String:
	return {"double":"2 cailloux par tir", "triple":"3 cailloux par tir", "minus":"−2 projectiles · minimum 1", "fire":"Dégâts ×3 : 1 impact suffit", "ice":"Dégâts normaux + gel 3 s", "electric":"Dégâts ×2 + ennemi ralenti 3 s", "egg":"Dégâts ÷2 : 6 impacts nécessaires", "soda":"Déplacement ralenti à 39 %", "trap":"−20 % de la vie restante", "heart":"+20 points de vie · maximum 100", "energy":"Cadence de tir ×2 pendant 15 s"}.get(kind,"")

func thunder():
	# Legacy keyboard shortcut: spend a stored lightning, never a free charge.
	var slot = special_slots.find("storm")
	if slot>=0: use_special(slot)
	return

func finish(won: bool):
	mode="win" if won else "end"
	best=maxi(best,score)
	save_progress()
	if notebook!=null:notebook.end_round()
	beep("start" if won else "hurt")
	ads.finish_round()

func save_progress():
	var cfg=ConfigFile.new()
	cfg.set_value("game","survival_best",best)
	cfg.set_value("game","sound",sound_enabled)
	if language_selected: cfg.set_value("game","language",language)
	cfg.save("user://progress.cfg")

func say(s: String,duration=2.5):
	notice=s
	notice_timer=duration

func float_word(s: String,pos: Vector2,color: Color):
	words.append({"text":s,"pos":pos,"color":color,"life":0.8})

func burst(pos: Vector2,col: Color,count: int):
	for i in range(count):
		particles.append({"pos":pos,"vel":Vector2(rng.randf_range(-100,100),rng.randf_range(-170,40)),"life":rng.randf_range(0.3,0.7),"color":col,"size":rng.randf_range(3,7)})

func beep(kind: String):
	if not sound_enabled or test_mode:return
	if not tone_cache.has(kind):
		var freq = {"shot":430.0,"pop":650.0,"bonus":880.0,"hurt":145.0,"door":250.0,"start":550.0,"thunder":75.0,"alarm":1050.0}.get(kind,440.0)
		var duration = 0.45 if kind=="alarm" else (0.055 if kind=="shot" else (0.32 if kind=="thunder" else 0.16))
		var data=PackedByteArray()
		var samples=int(22050*duration)
		data.resize(samples*2)
		for i in range(samples):
			var t=float(i)/22050.0
			var env=pow(1.0-float(i)/samples,2)
			var value=sin(TAU*(freq*t+freq*0.8*t*t))*env*0.24
			if kind=="alarm": value=(sin(TAU*1050*t)+0.35*sin(TAU*1673*t))*env*(0.5+0.5*sin(TAU*28*t))*0.18
			if kind=="shot": value*=0.32
			data.encode_s16(i*2,int(value*32767))
		var wav=AudioStreamWAV.new()
		wav.format=AudioStreamWAV.FORMAT_16_BITS
		wav.mix_rate=22050
		wav.data=data
		tone_cache[kind]=wav
	var p=sound_players[audio_index%8]
	audio_index+=1
	p.stream=tone_cache[kind]
	p.play()

# ---------- Rendering: a broad continuous street, four unmarked positions ----------
func road_point(x: float,p: float) -> Vector2:
	if street!=null and street.camera!=null:return street.actor_point(x,p)
	return Vector2(360+x*(63.333333+325.714286*p),350+720*maxf(p,0))

func enemy_pos(e: Dictionary) -> Vector2:
	if e.has("world_z"):
		return street.project(Vector3(-e.x*4.3,0,e.world_z))
	return road_point(e.x,e.p)

func rounded(rect: Rect2,col: Color,radius=16.0,border=0.0,border_color=INK):
	var s=StyleBoxFlat.new()
	s.bg_color=col
	s.set_corner_radius_all(int(radius))
	s.set_border_width_all(int(border))
	s.border_color=border_color
	draw_style_box(s,rect)
	if col.r>0.9 and col.g>0.85 and rect.size.x>200 and rect.size.y>40:
		var inset=rect.grow(-5)
		draw_texture_rect_region(art_tex,inset,Rect2(Vector2(0,art_tex.get_height()/2.0),art_tex.get_size()/2),Color(1,1,1,col.a))


func ui_text(value: String) -> String:
	if mode not in UI_MODES or language=="fr":return value
	return menu_translations.get(value,{}).get(language,value)

func ui_font(font: Font=null) -> Font:
	if mode in UI_MODES and (language=="zh" or mode=="language"):return cjk_font
	return body_font if font==null else font

func fitted_size(value: String,font: Font,size: int,width: float) -> int:
	while size>12 and font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>width:size-=1
	return size

func label(s: String,pos: Vector2,size: int=22,col: Color=INK,font: Font=null):
	s=ui_text(s)
	var f=ui_font(font)
	if mode in UI_MODES:size=fitted_size(s,f,size,678-pos.x)
	draw_string(f,pos,s,HORIZONTAL_ALIGNMENT_LEFT,-1,size,col)

func centered(s: String,y: float,size: int=22,col: Color=INK,font: Font=null):
	s=ui_text(s)
	var f=ui_font(font)
	if mode in UI_MODES:size=fitted_size(s,f,size,636)
	var width=f.get_string_size(s,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	draw_string(f,Vector2((720-width)/2,y),s,HORIZONTAL_ALIGNMENT_LEFT,-1,size,col)

func draw_language():
	draw_rect(Rect2(0,0,720,1280),PAPER)
	centered("FRANÇAIS · ENGLISH",235,29,TEAL)
	centered("ESPAÑOL · 简体中文",280,29,TEAL)
	centered("Choisis ta langue / Choose your language",340,22)
	centered("Elige tu idioma / 请选择语言",380,22)
	var names=["Français","English","Español","简体中文"]
	for i in range(4):button(Rect2(110,440+i*120,500,90),names[i],TEAL if LANGUAGE_CODES[i]==language and language_selected else PURPLE)

func atlas_sprite(index: int,feet: Vector2,height: float,tint=Color.WHITE,angle=0.0,gait=-1.0):
	var texture=character_tex
	if notebook!=null and index in [0,1,11]:texture=notebook.hero_texture(character_tex)
	var grid=Vector2(4,3)
	var local_index=index
	if index>=22:
		texture=clergy_tex;grid=Vector2(3,1);local_index=index-22
	elif index>=2 and index!=11:
		texture=angry_tex;grid=Vector2(4,2)
		local_index=0
		for kind in range(ENEMY_SPRITES.size()):
			if ENEMY_SPRITES[kind].has(index):local_index=kind;break
	var cell=texture.get_size()/grid
	var source=Rect2(Vector2(local_index%int(grid.x),int(local_index/int(grid.x)))*cell,cell)
	var width=height*cell.x/cell.y
	draw_set_transform(feet,angle)
	if gait<0:
		draw_texture_rect_region(texture,Rect2(-width/2,-height,width,height),source,tint)
	else:
		# Textured articulated grid: alternate feet and swing arms, keeping head/face intact.
		for row in range(6):
			for col in range(4):
				var vertices=PackedVector2Array();var uv=PackedVector2Array()
				for corner in [Vector2(col,row),Vector2(col+1,row),Vector2(col+1,row+1),Vector2(col,row+1)]:
					var q=corner/Vector2(4,6)
					var point=Vector2((q.x-0.5)*width,(q.y-1.0)*height)
					var leg=smoothstep(0.58,0.95,q.y)
					var side=clampf((q.x-0.5)*4.0,-1.0,1.0)
					point.x+=sin(gait)*height*0.025*leg*absf(side)
					point.y-=sin(gait)*height*0.035*leg*side
					point.x+=sin(gait+PI)*height*0.018*sin(q.y*PI)*absf(side)
					vertices.append(point);uv.append((source.position+q*cell)/texture.get_size())
				draw_polygon(vertices,PackedColorArray([tint]),uv,texture)
	draw_set_transform(Vector2.ZERO)

func _draw():
	draw_village()
	if mode=="cinematic":return
	if mode=="mock_ad": draw_mock_ad();return
	if mode=="language": draw_language();return
	if mode=="menu": draw_menu();return
	if mode=="notebook":notebook.draw_book();return
	if mode=="help": draw_help();return
	if mode=="privacy": draw_privacy();return
	draw_entities()
	if dogs_timer>0: draw_dog_pack()
	for e in enemies:
		if e.hp>0 and e.get("bubble","")!="" and e.age>=1.2 and e.age<4.2:draw_speech(e)
	if mode=="play" and street.transition_alpha()>0:
		var a=street.transition_alpha()
		draw_rect(Rect2(0,0,720,1280),Color(0.16,0.12,0.13,a))
	draw_hud()
	if flash>0: draw_rect(Rect2(0,0,720,1280),Color(1,0.95,0.7,minf(flash*1.8,0.5)))
	if mode=="pause": draw_pause()
	elif mode=="end" or mode=="win": draw_end()

func street_project(side_x: float, z: float, elevation: float=0.0) -> Vector2:
	return Vector2(360+side_x*190.0/z,210+(420.0-elevation)/z)

func street_kind(plot: int, side: int) -> int:
	var sequence=[0,1,2,3,4,5,6,7]
	return sequence[posmod(plot+(5 if side>0 else 0),sequence.size())]

func draw_village():
	if street!=null:street.sync()

func draw_entities():
	var objects: Array=[]
	for e in enemies: objects.append({"p":e.p,"type":"enemy","data":e})
	for p in pickups: objects.append({"p":p.p,"type":"pickup","data":p})
	objects.append({"p":player_p,"type":"player"})
	objects.sort_custom(func(a,b):return a.p<b.p)
	for obj in objects:
		if obj.type=="enemy": draw_enemy(obj.data)
		elif obj.type=="player":draw_player()
		else: draw_pickup(obj.data)
	for shot in bullets:
		var col=[Color("8a7d71"),CORAL,SKY,GOLD,Color("f1edc9")][shot.element]
		draw_line(shot.pos+Vector2(0,15),shot.pos,Color(col,0.45),4)
		draw_projectile(shot.element,shot.pos)
	var feet=road_point(player_x,player_p)
	for f in fallen:
		atlas_sprite(f.sprite,f.pos,180,Color(1,1,1,clampf(1.8-f.age,0,1)),f.age*6)
	if mode=="caught":
		atlas_sprite(capture_sprite,feet+Vector2(18,4),210)
		atlas_sprite(1,feet+Vector2(-20,-60),115,Color.WHITE,-0.35)
	for p in particles:draw_circle(p.pos,p.size,Color(p.color,minf(1,p.life*3)))
	for z in zaps:
		var mid=(z.a+z.b)*0.5+Vector2(24,-16)
		draw_polyline(PackedVector2Array([z.a,mid,mid+Vector2(-35,17),z.b]),GOLD,5,true)
	for w in words:label(w.text,w.pos,22,Color(w.color,minf(1,w.life*2)),title_font)

func draw_slingshot(pos: Vector2,size: float,level: int):
	var handle=PackedVector2Array([pos+Vector2(0,0.44)*size,pos+Vector2(0,0.02)*size,pos+Vector2(-0.3,-0.4)*size])
	var branch=PackedVector2Array([pos+Vector2(0,0.02)*size,pos+Vector2(0.3,-0.4)*size])
	for points in [handle,branch]:
		draw_polyline(points,PAPER,size*0.19,true)
		draw_polyline(points,INK,size*0.15,true)
		draw_polyline(points,SLING_COLORS[level],size*0.10,true)
	draw_line(pos+Vector2(-0.3,-0.4)*size,pos+Vector2(0,-0.18)*size,GOLD,3,true)
	draw_line(pos+Vector2(0,-0.18)*size,pos+Vector2(0.3,-0.4)*size,GOLD,3,true)
	draw_circle(pos+Vector2(0,-0.18)*size,size*0.07,INK)

func draw_player():
	var feet=road_point(player_x,player_p)
	draw_set_transform(feet,0,Vector2(1,0.3))
	draw_circle(Vector2(0,0),32,Color(0.2,0.15,0.2,0.2))
	draw_set_transform(Vector2.ZERO)
	var tint=Color.WHITE
	if invincible>0 and int(anim*12)%2==0:tint.a=0.35
	atlas_sprite(0 if int(anim*6)%2==0 else 11,feet-Vector2(0,absf(sin(anim*12))*3+sin(jump_timer/0.65*PI)*100),164,tint,sin(anim*9)*0.025)
	if sling_level>0:draw_slingshot(feet+Vector2(48,-80),36,sling_level)
	# Equipment upgrades visibly attach to the yellow backpack.
	if element>0:
		var pack=Rect2(feet.x-17,feet.y-88,34,34)
		rounded(pack,ELEMENT_COLORS[element],7,2)
		draw_icon(["","fire","ice","electric"][element],pack.get_center(),11)
	if notebook!=null and notebook.equipped.sling!="":
		var ribbon=feet+Vector2(48,-65)
		draw_polyline(PackedVector2Array([ribbon+Vector2(-7,0),ribbon+Vector2(5,12),ribbon+Vector2(-1,22)]),notebook.reward_color("sling"),4,true)
	if shield:draw_arc(feet-Vector2(0,65),78,0,TAU,40,Color(0.4,0.85,1,0.7),4)

func draw_enemy(e: Dictionary):
	var feet=enemy_pos(e)
	var size=78+118*e.p
	if e.boss:size*=1.48
	var phase=e.get("run_phase",e.age*12+e.id)
	var bob=absf(sin(phase))*4*e.p if e.frozen<=0 else 0.0
	var tint=Color.WHITE
	if e.hit>0:tint=Color(1.0,0.65,0.52)
	elif e.frozen>0:tint=Color(0.5,0.86,1)
	draw_set_transform(feet,0,Vector2(1,0.3))
	draw_circle(Vector2.ZERO,size*0.2,Color(0.2,0.15,0.18,0.17))
	draw_set_transform(Vector2.ZERO)
	atlas_sprite(e.sprite,feet-Vector2(0,bob),size,tint,(-0.08 if e.hit>0 else sin(phase)*0.018),phase if e.frozen<=0 else -1.0)
	if e.hp>0:
		var bw=size*0.65
		rounded(Rect2(feet.x-bw/2,feet.y-size-13,bw,7),INK,3)
		rounded(Rect2(feet.x-bw/2+1,feet.y-size-12,(bw-2)*maxf(0,e.hp/e.maxhp),5),CORAL,2)
	if e.boss:
		label("LE PROVISEUR",feet-Vector2(68,size+23),16,INK,title_font)
	if e.get("attack_state","")=="warning":
		var target=road_point(e.attack_target.x,e.attack_target.y)
		draw_line(feet,target,Color(0.9,0.35,0.22,0.35),3.0,true)
		draw_arc(target,18.0,0,TAU,24,CORAL,3.0,true)
	if e.warned:
		label("!",feet+Vector2(-7,-size-18),26,CORAL,title_font)
	if e.frozen>0:
		var center=feet-Vector2(0,size*0.45)
		draw_circle(center,size*0.44,Color(0.3,0.8,1,0.16))
		draw_arc(center,size*0.44,0,TAU,20,Color(0.6,0.95,1,0.9),3)
		for i in range(3):
			var flake=center+Vector2((i-1)*size*0.28,-size*0.25)
			for axis in range(3):
				var arm=Vector2.from_angle(axis*PI/3)*6
				draw_line(flake-arm,flake+arm,Color.WHITE,2)

func gear(index: int,pos: Vector2,size: float,tint=Color.WHITE):
	var cell=gear_tex.get_size()/Vector2(4,2)
	draw_texture_rect_region(gear_tex,Rect2(pos-Vector2.ONE*size/2,Vector2.ONE*size),Rect2(Vector2(index%4,index/4)*cell,cell),tint)

func draw_pickup(p: Dictionary):
	if p.kind=="slingshot":
		var pos=road_point(LANES[p.lane],p.p)-Vector2(0,25+absf(sin(anim*3))*5)
		var size=40+45*p.p
		draw_circle(pos,size*0.65,Color(1,0.95,0.7,0.3))
		draw_arc(pos,size*0.65,0,TAU,24,SLING_COLORS[p.level],3)
		draw_slingshot(pos,size,p.level)
		label("×%d"%(p.level+1),pos+Vector2(-14,size*0.92),22,INK,title_font)
		return
	if p.kind in ["dogs","storm"]:
		draw_special_gift(p.kind,road_point(LANES[p.lane],p.p),40+56*p.p)
		return
	var pos=road_point(LANES[p.lane],p.p)
	var size=36+54*p.p
	pos.y-=size*0.4+absf(sin(anim*3+p.p*5))*4
	var index={"stone":0,"fire":1,"ice":2,"electric":3,"mystery":4}.get(p.kind,0)
	gear(index,pos,size)
	if p.kind=="stone":
		draw_string_outline(title_font,pos+Vector2(-14,size*0.45),"+1",HORIZONTAL_ALIGNMENT_LEFT,-1,26,5,PAPER)
		label("+1",pos+Vector2(-14,size*0.45),26,INK,title_font)

func draw_icon(kind: String,pos: Vector2,size: float):
	draw_element_stone({"stone":0,"fire":1,"ice":2,"electric":3}.get(kind,0),pos,size/10.0)

func draw_heart(pos: Vector2,full: bool):
	gear(5,pos,48,Color.WHITE if full else Color(0.5,0.45,0.42,0.35))

func draw_hud():
	rounded(Rect2(18,18,684,64),PAPER,14,3)
	label("VIE %d %%"%int(ceil(life)),Vector2(32,44),21,INK,title_font)
	rounded(Rect2(32,56,136,10),INK,4)
	rounded(Rect2(34,58,132*life/100.0,6),CORAL,3)
	label("%05d"%score,Vector2(190,48),27,INK,title_font)
	label("POINTS",Vector2(192,67),11,Color("78625b"))
	label("VILLAGE DE TRAVERS",Vector2(330,43),17,TEAL,title_font)
	label("%d s"%int(time),Vector2(540,58),18,INK)
	rounded(Rect2(624,22,68,56),INK,12)
	draw_rect(Rect2(646,37,7,25),PAPER)
	draw_rect(Rect2(662,37,7,25),PAPER)
	var gift_width=684-maxi(1,special_slots.size())*74
	rounded(Rect2(18,1180,gift_width,64),PAPER,12,3)
	if gift_timer>0:
		var bad=last_gift in ["minus","egg","soda","trap"]
		var color=CORAL if bad else TEAL
		draw_gift(last_gift,Vector2(49,1212),48)
		label(gift_name(last_gift),Vector2(82,1204),21,color,title_font)
		var description=gift_description(last_gift)
		var font_size=16
		while body_font.get_string_size(description,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>gift_width-88 and font_size>12:font_size-=1
		label(description,Vector2(82,1227),font_size,INK)
		var duration=3.0 if last_gift in ["heart","trap"] else 15.0
		rounded(Rect2(82,1235,(gift_width-100)*gift_timer/duration,4),color,2)
	else:
		label("Glisse dans les 4 directions",Vector2(32,1205),21,TEAL,title_font)
		label("Lance-pierre ×%d · %.0f salves/s"%[sling_level+1,1.0/shot_interval()],Vector2(32,1230),16,INK)
	for i in range(special_slots.size()):
		var rect=special_rect(i)
		rounded(rect,GOLD if special_slots[i]=="storm" else CORAL,12,3)
		draw_special_symbol(special_slots[i],rect.get_center(),38)

func button(rect: Rect2,text: String,col=TEAL):
	rounded(Rect2(rect.position+Vector2(0,5),rect.size),INK,18)
	rounded(rect,col,18,2)
	text=ui_text(text)
	var f=ui_font(title_font)
	var size=fitted_size(text,f,34 if rect.size.y>70 else 25,rect.size.x-28)
	var width=f.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	draw_string(f,Vector2(rect.get_center().x-width/2,rect.get_center().y+size*0.35),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,PAPER)

func draw_menu():
	draw_rect(Rect2(0,0,720,1280),Color(0.98,0.94,0.84,0.25))
	rounded(Rect2(42,35,636,220),PAPER,25,3)
	centered("VILLAGE VS",106,54,INK,title_font)
	centered("CHENAPAN",177,75,INK,title_font)
	centered("Recherché pour excès de bêtises",225,22,TEAL)
	atlas_sprite(2,Vector2(135,598),220,Color.WHITE,-0.10)
	atlas_sprite(5,Vector2(580,588),220,Color.WHITE,0.08)
	atlas_sprite(1,Vector2(360,654),310)
	rounded(Rect2(70,654,580,112),PAPER,18,2)
	centered(notebook.title(),693,28,PURPLE,title_font)
	centered(ui_text("%d / 12 défis relevés")%notebook.done.size(),728,21,TEAL)
	centered(ui_text("RECORD  %d")%best,753,17,INK)
	button(Rect2(70,790,580,82),"NOUVELLE PARTIE")
	button(Rect2(70,895,280,66),"MON CARNET",PURPLE)
	button(Rect2(370,895,280,66),"COMMENT JOUER",INK)
	button(Rect2(70,984,580,62),"INTRO + PARTIE",INK)
	button(Rect2(70,1070,580,62),"LANGUE",PURPLE)
	button(Rect2(70,1156,580,62),"CONFIDENTIALITÉ",INK)

const HELP_PAGES = [
	["JOUER ET SURVIVRE", [
	["DÉPLACE-TOI POUR VISER", "Glisse dans les quatre directions.", "Relâche pour arrêter le garçon."],
	["LES TIRS PARTENT TOUT SEULS", "Droit devant : 2 salves par seconde au départ.", "Place-toi face aux assaillants pour les toucher."],
	["LES POINTS", "+10 points par seconde de survie.", "+100 points par assaillant vaincu."],
	["LA VIE", "Un assaillant inflige 10 dégâts, une seule fois.", "Un assaillant qui sort en bas ne coûte pas de vie."],
	["LES CADEAUX CLASSIQUES", "Un seul effet à la fois : le nouveau remplace l'ancien.", "Durée : 15 s, sauf cœur et piège, immédiats."],
	["UNE NOUVELLE CHANCE", "Deux reprises maximum par partie, via une pub.", "Les points sont conservés lors d'une reprise."]]],
	["TOUS LES BONUS", [
	["DOUBLE GALETS", "2 galets par salve pendant 15 secondes.", ""],
	["TRIPLE GALETS", "3 galets par salve pendant 15 secondes.", ""],
	["PIERRES DE FEU", "Dégâts ×3 pendant 15 secondes.", ""],
	["PIERRES DE GLACE", "Dégâts normaux et gel de l'ennemi pendant 3 s.", "Cadeau actif pendant 15 secondes."],
	["PIERRES FOUDRE", "Dégâts ×2 et vitesse de l'ennemi divisée par 2, 3 s.", "Cadeau actif 15 s ; ce n'est pas une attaque spéciale."],
	["BOISSON ÉNERGIE", "Cadence ×2 pendant 15 secondes.", "Se combine avec le lance-pierre déjà obtenu."],
	["CŒUR", "+20 points de vie immédiatement, maximum 100.", ""]]],
	["TOUS LES MALUS", [
	["ŒUFS GUM", "Dégâts divisés par 2 pendant 15 secondes.", "Il faut donc davantage d'impacts pour vaincre."],
	["SODA COLLANT", "Déplacements ramenés à 39 % de leur vitesse.", "Durée : 15 secondes."],
	["MOINS DE GALETS", "Retire 2 galets par salve, sans descendre sous 1.", "Peut apparaître si tu tires déjà plusieurs galets."],
	["PIÈGE À LOUP", "Retire 20 % de la vie restante immédiatement.", "Exemple : 50 points de vie deviennent 40."],
	["LE HASARD DES CADEAUX", "Chaque série mélange 5 bonus et 5 malus.", "Plusieurs malus peuvent donc se suivre."]]],
	["LES LANCE-PIERRES", [
	["2 000 POINTS", "1re occasion : vert, cadence ×2.", ""],
	["5 000 POINTS", "2e occasion : bleu, cadence ×3.", ""],
	["10 000 POINTS", "3e occasion : rouge, cadence ×4.", ""],
	["15 000 POINTS", "4e occasion : noir, cadence ×5.", ""],
	["20 000 POINTS", "5e occasion : violet, cadence ×6.", ""],
	["25 000 POINTS", "6e et dernière occasion : doré, cadence ×7.", ""],
	["SI TU EN RATES UN", "L'occasion est perdue ; le prochain propose le rang",
	"manquant. Tu n'atteindras donc pas le dernier rang."]]],
	["LE CADEAU DES CHIENS", [
	["LE CADEAU ROUGE", "Première apparition à 1 000 points, puis tous les",
	"3 000 points : 4 000, 7 000, 10 000, etc."],
	["RAMASSE-LE POUR LE GARDER", "Un onglet avec un os apparaît dans la barre.", "Les autres cadeaux ne l'effacent pas."],
	["APPUYE SUR L'OS", "La meute arrive et élimine tous les assaillants.", "Une seule utilisation : l'onglet disparaît ensuite."],
	["PAS DE CUMUL DE MEUTES", "Aucun nouveau cadeau chien tant qu'un est gardé",
	"ou déjà présent sur le terrain."],
	["SI TU LE RATES", "Il faut attendre le prochain palier prévu.", "Il ne réapparaît pas immédiatement."],
	["LES AMÉLIORATIONS RESTENT", "Les lance-pierres sont conservés pendant la partie.", "Ils ne remplacent ni le cadeau classique ni les chiens."]]],
	["LE CARNET DE BÊTISES", [
	["TROIS DÉFIS À LA FOIS", "Le carnet propose 12 défis au total.", "Les suivants arrivent au début d'une nouvelle partie."],
	["UNE PROGRESSION SAUVEGARDÉE", "Certains défis se cumulent entre les parties.", "Les défis en une partie repartent de zéro au prochain départ."],
	["TA RÉPUTATION GRANDIT", "Un défi relevé compte pour ta réputation.", "Les titres changent après 3, 6 et 12 défis."],
	["TON VESTIAIRE", "Débloque des tenues, cartables et rubans.", "Choisis-les dans MON CARNET puis VESTIAIRE."],
	["LE MÊME DÉFI POUR TOUS", "Les accessoires ne changent ni les dégâts ni la cadence.", "La couleur de rang du lance-pierre reste visible."],
	["REJOUER ET PARTAGER", "REJOUER relance directement une nouvelle partie.", "PARTAGER ouvre le partage de ton résultat."]]]
]

func draw_help():
	draw_rect(Rect2(0,0,720,1280),Color(1,0.96,0.87,0.98))
	centered("LE PETIT GUIDE",85,35,INK,title_font)
	centered(HELP_PAGES[help_page][0],140,27,TEAL,title_font)
	if help_page==3:centered("Rangs indiqués si toutes les occasions sont ramassées.",175,16,INK)
	var rows=HELP_PAGES[help_page][1]
	for i in range(rows.size()):
		var y=230+i*120
		label(rows[i][0],Vector2(42,y),23,TEAL,title_font)
		label(rows[i][1],Vector2(42,y+34),18,INK)
		label(rows[i][2],Vector2(42,y+62),18,INK)
	centered("%d / %d"%[help_page+1,HELP_PAGES.size()],1115,20,INK)
	if help_page>0:button(Rect2(40,1150,170,70),"PRÉCÉDENT",PURPLE)
	button(Rect2(240,1150,240,70),"C'EST COMPRIS !")
	if help_page<HELP_PAGES.size()-1:button(Rect2(510,1150,170,70),"SUIVANT",PURPLE)
	centered("Son : règle le volume avec les boutons du téléphone.",1260,16,INK)

func draw_pause():
	draw_rect(Rect2(0,0,720,1280),Color(0.14,0.1,0.16,0.65))
	rounded(Rect2(75,400,570,510),PAPER,24,3)
	centered("PETITE RÉCRÉ",478,37,INK,title_font)
	centered("Le village attendra.",519,20,INK)
	button(Rect2(125,565,470,76),"REPRENDRE")
	button(Rect2(125,659,470,64),"RETOUR AU VILLAGE",INK)
	button(Rect2(125,742,470,60),"CONFIDENTIALITÉ",PURPLE)

func draw_end():
	notebook.draw_summary()

func open_privacy(return_mode: String):
	privacy_return_mode=return_mode
	mode="privacy"

func _on_ad_reward(reward: String):
	# Dormant in phase 1. Native provider alone can validate this callback.
	if reward=="revive_once" and mode=="end":
		life=20
		invincible=3.0
		mode="play"
		ads.in_round=true
		say("Une seconde chance : 1 cœur !",2.5)

func draw_privacy():
	draw_rect(Rect2(0,0,720,1280),PAPER)
	centered("CONFIDENTIALITÉ",95,34,INK,title_font)
	centered("Tu peux jouer sans rien renseigner.",145,20,TEAL)
	var lines=["Cette version ne contient aucun SDK publicitaire.","Aucune publicité, aucun suivi et aucun compte.","Le record et les réglages restent sur ton appareil.","Aucune date de naissance n'est demandée."]
	for i in range(lines.size()):centered(lines[i],220+i*38,19,INK)
	rounded(Rect2(65,380,590,135),Color("e1eee5"),18)
	centered("Catégorie facultative, conservée localement",421,19,INK)
	var profile={"unknown":"Non renseignée","minor":"Moins de 18 ans","adult":"18 ans ou plus"}.get(ads.privacy.age_group,"Non renseignée")
	centered(ui_text("Choix actuel : %s")%ui_text(profile),465,22,TEAL,title_font)
	button(Rect2(100,575,520,65),"MOINS DE 18 ANS",TEAL)
	button(Rect2(100,655,520,65),"18 ANS OU PLUS",TEAL)
	button(Rect2(100,735,520,65),"NE PAS RENSEIGNER",TEAL)
	centered("Ce choix n'autorise aucune publicité.",839,18,INK)
	button(Rect2(100,870,520,65),"CONSERVER LA PUBLICITÉ DÉSACTIVÉE",INK)
	rounded(Rect2(100,960,520,65),Color("ded7c7"),16)
	centered("Consentement publicitaire : non installé",1001,18,INK)
	centered("Aucun formulaire de consentement n'est nécessaire ici.",1063,16,INK)
	button(Rect2(100,1100,520,70),"RETOUR",TEAL)
	centered("Âge inconnu ou mineur : protection par défaut.",1224,17,INK)

func survival_icon(index: int,pos: Vector2,size: float):
	var texture: Texture2D=preload("res://assets/survival_icons.png")
	var cell=texture.get_size()/Vector2(4,2)
	draw_texture_rect_region(texture,Rect2(pos-Vector2.ONE*size/2,Vector2.ONE*size),Rect2(Vector2(index%4,index/4)*cell+Vector2.ONE*5,cell-Vector2.ONE*10))

func draw_energy_can(pos: Vector2,size: float):
	# Original unbranded can, using the game's ink/paper/teal palette.
	draw_set_transform(pos,-0.13,Vector2.ONE*size/86.0)
	rounded(Rect2(-24,-35,48,70),TEAL,9,3,INK)
	rounded(Rect2(-19,-28,8,54),Color(0.65,1,0.83,0.45),4)
	draw_ellipse_cap(Vector2(0,-35),Vector2(23,6),PAPER)
	draw_ellipse_cap(Vector2(0,35),Vector2(22,5),PAPER)
	draw_arc(Vector2(0,-35),4,0,TAU,12,INK,2)
	var bolt=PackedVector2Array([Vector2(6,-25),Vector2(-10,-5),Vector2(-1,-5),Vector2(-7,12),Vector2(14,-12),Vector2(4,-12)])
	draw_colored_polygon(bolt,GOLD)
	draw_polyline(PackedVector2Array([bolt[0],bolt[1],bolt[2],bolt[3],bolt[4],bolt[5],bolt[0]]),INK,2,true)
	label("×2",Vector2(-13,29),23,PAPER,title_font)
	draw_set_transform(Vector2.ZERO)

func draw_ellipse_cap(pos: Vector2,scale_xy: Vector2,col: Color):
	var points=PackedVector2Array()
	for i in range(25):
		var angle=TAU*i/24.0
		points.append(pos+Vector2(cos(angle)*scale_xy.x,sin(angle)*scale_xy.y))
	draw_colored_polygon(points,col)
	draw_polyline(points,INK,2,true)

func draw_gift(kind: String,pos: Vector2,size: float):
	if kind=="energy":draw_energy_can(pos,size); return
	if kind=="heart":gear(5,pos,size); return
	if kind in ["ice","fire","electric","egg"]:
		draw_element_stone({"fire":1,"ice":2,"electric":3,"egg":4}[kind],pos,size/34.0);return
	survival_icon({"double":0,"triple":1,"minus":0,"egg":2,"soda":3,"trap":4,"ice":5,"fire":6,"electric":7}.get(kind,0),pos,size)
	if kind=="minus":label("−2",pos+Vector2(-18,20),28,CORAL,title_font)

func draw_projectile(el: int,pos: Vector2):
	draw_element_stone(el,pos,1.0)

func draw_element_stone(el: int,pos: Vector2,scale_size: float):
	draw_set_transform(pos,0,Vector2.ONE*scale_size)
	if el==1:
		draw_circle(Vector2.ZERO,17,Color(1.0,0.35,0.06,0.3))
		var flame=PackedVector2Array([Vector2(-12,-10),Vector2(-19,0),Vector2(-12,9),Vector2(-8,23+sin(anim*17)*4),Vector2(0,12),Vector2(7,27+cos(anim*15)*4),Vector2(12,9),Vector2(19,-2),Vector2(11,-11)])
		draw_colored_polygon(flame,Color("f47925"))
		draw_circle(Vector2.ZERO,12,Color("ffd359"))
		for i in range(5):
			var x=(i-2)*4.0
			var length=18+sin(anim*18+i*2)*5
			draw_colored_polygon(PackedVector2Array([Vector2(x-5,3),Vector2(x+sin(anim*13+i)*4,length),Vector2(x+5,2)]),Color("ed5d26"))
			draw_line(Vector2(x,4),Vector2(x,length*0.7),Color("ffd05b"),3,true)
	elif el==2:
		for i in range(6):
			var dir=Vector2.from_angle(i*TAU/6+anim*0.6)
			draw_colored_polygon(PackedVector2Array([dir*7+dir.orthogonal()*3,dir*18,dir*7-dir.orthogonal()*3]),Color("92e8fa"))
	elif el==3:
		for i in range(3):
			var angle=anim*4+i*TAU/3
			var arc=PackedVector2Array()
			for j in range(7):arc.append(Vector2.from_angle(angle+j*0.22)*(14+(j%2)*5))
			draw_polyline(arc,Color("f6c52e"),3,true)
			draw_polyline(arc,Color("fff5a1"),1,true)
	if el==4:
		draw_ellipse_cap(Vector2.ZERO,Vector2(9,12),Color("fff2c8"))
		draw_arc(Vector2.ZERO,7,3.4,4.8,8,Color.WHITE,2)
	else:
		var stone=PackedVector2Array([Vector2(-9,-3),Vector2(-5,-9),Vector2(4,-8),Vector2(10,-2),Vector2(7,6),Vector2(-3,9),Vector2(-10,4)])
		draw_colored_polygon(stone,Color("8c8983"))
		draw_polyline(stone+PackedVector2Array([stone[0]]),INK,2,true)
		draw_colored_polygon(PackedVector2Array([Vector2(-7,-3),Vector2(-3,-7),Vector2(4,-5),Vector2(0,-1)]),Color("c9c5b6"))
		draw_line(Vector2(1,5),Vector2(6,2),Color("605e59"),2,true)
	draw_set_transform(Vector2.ZERO)

func draw_speech(e: Dictionary):
	var words_text: String=e.bubble
	var font_size=25
	var width=body_font.get_string_size(words_text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x+30
	var head=enemy_pos(e)-Vector2(0,78+118*e.p+20)
	var box=Rect2(clampf(head.x-width/2,12,708-width),maxf(268,head.y-67),width,48)
	var base=clampf(head.x,box.position.x+15,box.end.x-15)
	var tip=Vector2(head.x, maxf(box.end.y+12,head.y))
	var tail=PackedVector2Array([Vector2(base-10,box.end.y-3),tip,Vector2(base+10,box.end.y-3)])
	draw_colored_polygon(tail,PAPER)
	draw_polyline(PackedVector2Array([tail[0],tail[1],tail[2]]),INK,2.5,true)
	rounded(box,PAPER,17,2.5)
	label(words_text,box.position+Vector2(15,32),font_size,INK)

func progression_multiplier() -> float:
	return 1.0+1.5*float(score)/(float(score)+1200.0)

func enemy_speed_multiplier() -> float:
	var base_speed=1.0+1.8*float(score)/(float(score)+2500.0)
	# Exclusive movement milestones, independent of arrival group size.
	var milestone_speed=1.5 if score>=30000 else (1.2 if score>=20000 else 1.0)
	return base_speed*milestone_speed

func player_speed() -> float:
	return 0.7*(1.4 if last_gift=="soda" else 3.6)/1.5*progression_multiplier()

func update_enemy_steering(e: Dictionary,movement_dt: float):
	if e.frozen>0:return
	if e.entry_progress<1.0:
		e.x=lerpf(e.startx,e.lane,smoothstep(0.0,1.0,e.entry_progress))
		return
	if not e.has("route_velocity"):
		# Predetermined paths, independent of the player's position and score.
		e.route_velocity=0.0 if e.id%3==0 else (0.20 if e.id%3==1 else -0.20)
	if e.get("attack_state","")=="charge":return
	e.x+=e.route_velocity*movement_dt
	# Bounce at the roadway edges, never at the centre or the firing line.
	if e.x>0.82:e.x=1.64-e.x;e.route_velocity=-absf(e.route_velocity)
	elif e.x< -0.82:e.x=-1.64-e.x;e.route_velocity=absf(e.route_velocity)
	if e.get("attack_state","")!="":return
	# Only an already-nearby assailant may try to catch the child.
	if e.p>=player_p-0.24 and e.p<player_p-0.08 and absf(e.x-player_x)<0.24:
		e.attack_state="warning";e.attack_clock=0.0;e.warned=true
		e.attack_target=Vector2(player_x,player_p+0.02)

func update_enemy_attack(e: Dictionary,dt: float) -> bool:
	var state=e.get("attack_state","")
	if state not in ["warning","charge"]:return false
	if e.frozen>0:
		if state=="charge" and e.has("world_z"):e.world_z=street.distance+(1.0-e.p)*30.0
		return state=="charge"
	e.attack_clock+=dt*(0.5 if e.slow>0 else 1.0)
	if state=="warning":
		# Keep running during the signal: no waiting on the player's firing line.
		if e.attack_clock<0.35:return false
		e.attack_state="charge";e.attack_clock=0.0
		e.attack_from=Vector2(e.x,e.p)
	var progress=clampf(e.attack_clock/0.35,0.0,1.0)
	var position=e.attack_from.lerp(e.attack_target,progress)
	e.x=position.x;e.p=position.y
	if progress>=1.0:
		e.attack_state="done";e.warned=false
		# Resume the original diagonal, including beyond the centre.
	if e.has("world_z"):e.world_z=street.distance+(1.0-e.p)*30.0
	return true

func choose_entry_lane(start_x: float) -> float:
	# Least occupied lane on the doorway's side; never cross the full street.
	var choices=[0,1,2] if start_x<0 else [2,3,4]
	var best_lane=choices[wave%choices.size()]
	var best_load=INF
	for offset in range(choices.size()):
		var index=choices[(wave+offset)%choices.size()]
		var count=0
		for e in enemies:
			if e.hp>0 and absf(e.lane-LANES[index])<0.1:count+=1
		if count<best_load:best_load=count;best_lane=index
	return LANES[best_lane]

func max_active_enemies() -> int:
	var ceiling=15 if score>=50000 else (12 if score>=40000 else 10)
	return mini(ceiling,3+maxi(0,int((score-500)/250)))

func spawn_base_interval() -> float:
	var blend=clampf((spawn_upgrade_age-8.0)/10.0,0.0,1.0)
	return lerpf(spawn_previous_base,SPAWN_INTERVALS[sling_event_index],blend)

func enemy_spawn_interval() -> float:
	# Score adds at most 20% arrival frequency; temporary gifts never raise pressure.
	return spawn_base_interval()/(1.0+0.2*clampf(float(score)/25000.0,0.0,1.0))

func nearby_threat_count() -> int:
	var count=0
	for e in enemies:
		if e.hp<=0 or e.frozen>0 or e.p>player_p+0.1:continue
		var rate=enemy_speed_multiplier()*e.speed
		if e.has("world_z"):
			rate=(2.0*(1.0+2.0*time/(time+200.0))+enemy_speed_multiplier()*(1.6+e.variant*0.2))/30.0
		if e.slow>0:rate*=0.5
		if (player_p-e.p)/maxf(0.01,rate)<=2.0:count+=1
	return count

func next_enemy_group_size() -> int:
	var tier=maxi(0,int((score-30000)/10000))
	# Carry fractional people into the next wave; exact average growth without rounding drift.
	spawn_group_remainder+=pow(1.5,tier)
	var count=int(floor(spawn_group_remainder+0.000001))
	spawn_group_remainder-=count
	return count

func update_enemy_spawns(dt: float):
	if dogs_timer>0:
		enemy_spawn_clock=enemy_spawn_interval()
		return
	var interval=enemy_spawn_interval()
	var alive=0
	for e in enemies:
		if e.hp>0:alive+=1
	var nearby=nearby_threat_count()
	# The proximity guard ends at 30,000; the score-based ceiling remains enforced.
	if score<30000 and nearby>=3:interval*=1.3
	enemy_spawn_clock=maxf(0.0,minf(enemy_spawn_clock,interval)-dt)
	if alive==0:enemy_spawn_clock=minf(enemy_spawn_clock,1.0)
	var capacity=max_active_enemies()
	if alive>=capacity or (score<30000 and nearby>=4):return
	if enemy_spawn_clock>0:return
	var doors=visible_doors()
	if doors.is_empty():return
	var source=doors[wave%doors.size()]
	var group_size=mini(next_enemy_group_size(),capacity-alive)
	for member in range(group_size):
		source=doors[wave%doors.size()]
		spawn_from_door(source,wave%3)
		wave+=1
	enemy_spawn_clock=interval
	say(QUIPS[source.kind],2.2)
	beep("door")

func visible_doors() -> Array:
	return street.visible_doors()

func spawn_from_door(door: Dictionary,variant: int):
	spawn_enemy(door.kind,door.p,door.side,variant)
	var e=enemies.back()
	e.x=door.x;e.startx=door.x
	e.lane=choose_entry_lane(door.x)
	e.straight=score>=15000
	e.source_plot=door.plot;e.source_side=door.side;e.door_world_z=door.world_z
	e.source_kind=door.kind
	e.door_world=door.world
	e.world_z=door.world.z
	e.source_street=street.street_index


func special_pending(kind: String) -> bool:
	if special_slots.has(kind):return true
	for p in pickups:
		if p.kind==kind and p.p<1.16:return true
	return false

func update_special_milestones():
	var dog_milestone=0 if score<1000 else 1+int((score-1000)/3000)
	if dog_milestone>last_dog_milestone:
		last_dog_milestone=dog_milestone
		if not special_pending("dogs"):
			pickups.append({"lane":rng.randi_range(0,4),"kind":"dogs","p":0.12,"category":"bonus"})

func update_slingshot_milestones():
	# Six fixed opportunities only. Missing an item never creates a replacement event.
	while sling_event_index<SLING_MILESTONES.size() and score>=SLING_MILESTONES[sling_event_index]:
		spawn_previous_base=spawn_base_interval()
		spawn_upgrade_age=0.0
		sling_event_index+=1
		var pending=0
		for pickup in pickups:
			if pickup.kind=="slingshot" and pickup.p<1.16:pending+=1
		if sling_level<6:
			pickups.append({"lane":rng.randi_range(0,4),"kind":"slingshot","p":-0.2-0.3*pending,"level":sling_level+1})
	next_sling_score=SLING_MILESTONES[sling_event_index] if sling_event_index<SLING_MILESTONES.size() else -1

func collect_slingshot(level: int):
	if level!=sling_level+1 or level>6:return
	var previous=shot_interval()
	sling_level=level
	if notebook!=null:notebook.event("slings")
	for pickup in pickups:
		if pickup.kind=="slingshot":pickup.level=mini(6,sling_level+1)
	shoot_clock*=shot_interval()/previous
	float_word("LANCE-PIERRE ×%d"%(level+1),road_point(player_x,player_p)-Vector2(0,155),SLING_COLORS[level])
	beep("pop")

func spawn_gift():
	pickups.append({"lane":rng.randi_range(0,4),"kind":"mystery","p":0.12,"category":next_gift_category()})

func collect_special(kind: String):
	if kind!="dogs":return
	special_slots.append("dogs")
	stats.boxes+=1
	beep("bonus")

func special_rect(index: int) -> Rect2:
	return Rect2(702-maxi(1,special_slots.size())*74+8+index*74,1180,66,64)

func use_special(index: int):
	if mode!="play" or index<0 or index>=special_slots.size():return
	var kind=special_slots[index]
	special_slots.remove_at(index)
	if kind=="dogs":
		if notebook!=null:notebook.event("dogs")
		dogs_timer=2.6
		enemy_spawn_clock=enemy_spawn_interval()
	else:flash=0.35
	clear_assailants(kind)
	beep("thunder")

func clear_assailants(kind: String):
	# No distance, profession, status or HP exception, including doors and bosses.
	for e in enemies:
		if e.hp<=0:continue
		if kind=="storm":zaps.append({"a":Vector2(360,150),"b":enemy_pos(e),"life":0.5})
		else:fallen.append({"sprite":e.sprite,"pos":enemy_pos(e),"age":0.0})
		damage_enemy(e,e.hp)
	# Remove defeated actors now, before another render or collision update.
	enemies=enemies.filter(func(e):return e.hp>0)


func open_mock_ad(action: String):
	if action=="continue" and (mode!="end" or continues_used>=2):return
	if action=="start" and mode!="menu":return
	mock_action=action
	mode="mock_ad"
	drag_active=false;movement_finger=-1

func close_mock_ad():
	if mode!="mock_ad":return
	var action=mock_action;mock_action=""
	if action=="start":start_game()
	elif action=="continue" and continues_used<2:
		continues_used+=1
		life=100;invincible=3.0;capture_timer=0
		mode="play";ads.in_round=true
		drag_active=false;movement_finger=-1;finger_target=player_x;finger_depth=player_p

func draw_mock_ad():
	draw_rect(Rect2(0,0,720,1280),PAPER)
	centered("ICI PUB",540,78,TEAL,title_font)
	centered("Simulation · aucune vraie publicité",610,24,INK)
	centered("Ferme avec la croix pour continuer",660,23,INK)
	if mock_action=="continue":centered("Reprise avec ton score et 100 % de vie",715,23,INK)
	rounded(Rect2(620,28,72,72),INK,14)
	draw_line(Vector2(641,49),Vector2(671,79),PAPER,5,true)
	draw_line(Vector2(671,49),Vector2(641,79),PAPER,5,true)

func draw_special_symbol(kind: String,pos: Vector2,size: float):
	if kind=="storm":
		var points=PackedVector2Array([pos+Vector2(0.1,-0.5)*size,pos+Vector2(-0.4,0.1)*size,pos+Vector2(0,0.1)*size,pos+Vector2(-0.1,0.5)*size,pos+Vector2(0.4,-0.1)*size,pos+Vector2(0,-0.1)*size])
		draw_colored_polygon(points,PAPER);draw_polyline(points,INK,3,true)
	else:
		draw_line(pos-Vector2(size*0.3,0),pos+Vector2(size*0.3,0),INK,13,true)
		draw_line(pos-Vector2(size*0.3,0),pos+Vector2(size*0.3,0),PAPER,8,true)
		for x in [-0.35,0.35]:
			for y in [-0.09,0.09]:
				draw_circle(pos+Vector2(x,y)*size,7,INK);draw_circle(pos+Vector2(x,y)*size,5,PAPER)

func draw_special_gift(kind: String,pos: Vector2,size: float):
	rounded(Rect2(pos-Vector2.ONE*size/2,Vector2.ONE*size),CORAL if kind=="dogs" else GOLD,10,3)
	draw_rect(Rect2(pos.x-size*0.08,pos.y-size/2,size*0.16,size),PAPER)
	if kind=="dogs":draw_dog(pos+Vector2(0,size*0.45),size*0.95,0,true)
	else:draw_special_symbol(kind,pos,size*0.65)

func draw_dog(pos: Vector2,size: float,phase: float,head_only=false):
	var fur=Color("c88d50")
	if not head_only:
		rounded(Rect2(pos-Vector2(size*0.3,size*0.42),Vector2(size*0.6,size*0.42)),fur,13,3)
		for side in [-1,1]:
			draw_line(pos+Vector2(side*size*0.2,-size*0.08),pos+Vector2(side*size*0.28,sin(phase+side)*size*0.14),INK,7,true)
		draw_line(pos+Vector2(size*0.28,-size*0.3),pos+Vector2(size*0.48,-size*0.5+sin(phase)*8),INK,7,true)
	var head=pos-Vector2(0,size*0.48)
	draw_circle(head,size*0.31,INK);draw_circle(head,size*0.28,fur)
	for side in [-1,1]:
		draw_circle(head+Vector2(side*size*0.26,-size*0.08),size*0.13,INK)
		draw_circle(head+Vector2(side*size*0.11,-size*0.04),size*0.07,PAPER)
		draw_circle(head+Vector2(side*size*0.11,-size*0.04),size*0.028,INK)
	draw_circle(head+Vector2(0,size*0.1),size*0.07,INK)
	draw_line(head+Vector2(0,size*0.18),head+Vector2(size*0.05,size*0.3),CORAL,7,true)

func draw_dog_pack():
	var progress=1.0-dogs_timer/2.6
	for i in range(7):
		var y=1300-progress*1400+(i%3)*65
		draw_dog(Vector2(95+i*85,y),86,sin(anim*18+i)*3)
	label("OUAF ! OUAF !",Vector2(215,380),34,CORAL,title_font)

func begin_intro(force_intro: bool=false):
	if mode!="menu":return
	if notebook.intro_seen and not force_intro:start_game();return
	mode="cinematic";drag_active=false;movement_finger=-1
	intro.begin()

func _on_intro_finished():
	if mode!="cinematic":return
	notebook.intro_seen=true
	notebook.save_data()
	mode="menu"
	open_mock_ad("start")

func _on_intro_cue(kind: String):
	if kind=="alarm" and mode=="cinematic":beep("alarm")
