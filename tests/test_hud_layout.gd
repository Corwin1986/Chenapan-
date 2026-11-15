extends SceneTree
var failures=0
func check(ok: bool,msg: String):
	if not ok:failures+=1;printerr("FAIL: "+msg)
func _initialize():call_deferred("run")
func run():
	var g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.start_game()
	g.collect_special("storm");g.collect_special("dogs")
	for i in range(3):check(g.special_rect(i).position.y==1180,"special tabs at bottom")
	g.handle_press(g.special_rect(2).get_center())
	check(g.dogs_timer>0 and g.special_slots.size()==2 and not g.drag_active,"bottom bone touch activates without moving")
	g.handle_press(g.special_rect(0).get_center())
	check(g.special_slots.size()==1,"bottom lightning touch consumes one charge")
	g.handle_press(Vector2(120,1200));check(not g.drag_active,"gift strip does not move player")
	g.handle_press(Vector2(360,120));check(g.drag_active,"freed upper space accepts movement")
	print("HUD_LAYOUT_FAILURES=",failures)
	g.free();quit(1 if failures else 0)
