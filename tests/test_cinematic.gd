extends SceneTree
var failures=0
var cue_count=0
func check(ok: bool,msg: String):
	if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func run():
	var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.intro.set_process(false);g.test_mode=true
	check(g.mode=="menu" and not g.intro.active,"no cinematic on app launch")
	g.handle_press(Vector2(200,940))
	check(g.mode=="cinematic" and g.intro.active and g.intro.visible,"main-menu new game starts cinematic")
	check(not g.ads.in_round,"game round not started during intro")
	var score=g.score;var timer=g.time
	g._process(0.05);check(g.score==score and g.time==timer,"intro does not advance gameplay or score")
	g.handle_press(Vector2(300,500));check(g.mode=="cinematic","tapping action area does not skip")
	g.intro.cue.connect(_on_cue)
	g.intro.advance(7);check(g.intro.segment()==1,"school follows bakery")
	g.intro.advance(4);check(cue_count==1,"slingshot impact starts alarm cue")
	g.intro.advance(6);check(g.intro.segment()==2,"post follows evacuation")
	g.intro.advance(7.5);check(g.intro.segment()==3,"police follows mail mixing")
	g.intro.advance(8);check(g.intro.segment()==4,"church follows police")
	g.intro.advance(8);check(g.intro.segment()==5,"cafe follows church")
	g.intro.advance(8);check(g.intro.segment()==6,"village chase follows cafe")
	check(g.intro.CHILD_HEIGHT==290,"pupils keep hero height")
	g.intro.advance(6.5)
	check(g.mode=="mock_ad" and not g.intro.visible and not g.intro.active,"finished intro leads to existing mock ad")
	g.intro.skip();check(g.mode=="mock_ad","duplicate completion harmless")
	g.close_mock_ad();check(g.mode=="play" and g.time==0 and g.score==0,"game begins after ad close")
	g.life=0;g.finish(false);g.handle_press(Vector2(250,850))
	check(g.mode=="play" and not g.intro.active,"retry skips cinematic and initial ad")
	g.life=0;g.score=950;g.finish(false);g.handle_press(Vector2(250,1030));g.close_mock_ad()
	check(g.mode=="play" and g.score==950 and not g.intro.active,"continue skips cinematic and preserves score")
	g.mode="menu";g.handle_press(Vector2(200,940));check(g.intro.elapsed==0,"new menu departure replays from beginning")
	g.intro.suspended=true;g.intro.advance(2);check(g.intro.elapsed==0,"background suspends timeline")
	g.intro.suspended=false;g.intro.advance(1);check(g.intro.elapsed==1,"foreground resumes timeline")
	g.handle_press(Vector2(620,60));check(g.mode=="mock_ad","skip button goes to start ad")
	g.close_mock_ad();g.mode="menu"
	var enter=InputEventKey.new();enter.keycode=KEY_ENTER;enter.pressed=true
	g._unhandled_input(enter);check(g.mode=="cinematic","keyboard menu start also plays intro")
	var back=InputEventKey.new();back.keycode=KEY_ESCAPE;back.pressed=true
	g._unhandled_input(back);check(g.mode=="mock_ad","back key safely skips intro")
	print("CINEMATIC_FAILURES=",failures)
	g.music_player.stop()
	g.free()
	await process_frame
	quit(1 if failures else 0)

func _on_cue(_kind):
	cue_count+=1
