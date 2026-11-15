extends SceneTree
var failures=0
func check(value: bool,msg: String):
 if not value:failures+=1;printerr(msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true
 check(g.sound_enabled,'Sound enabled at launch')
 g.handle_press(Vector2(610,1175));check(g.sound_enabled,'Old menu sound area does not mute')
 g.handle_press(Vector2(250,1030));check(g.mode=='help' and g.help_page==0,'Guide opens on page 1')
 for i in range(4):g.handle_press(Vector2(580,1180))
 check(g.help_page==4,'Guide reaches dogs page')
 g.handle_press(Vector2(580,1180));check(g.help_page==4,'Guide page upper bound')
 for page in g.HELP_PAGES:
  for row in page[1]:
   for i in [1,2]:check(g.body_font.get_string_size(row[i],HORIZONTAL_ALIGNMENT_LEFT,-1,18).x<=636,'Guide line overflow: '+row[i])
 g.handle_press(Vector2(300,1180));check(g.mode=='menu','Guide close')
 check(g.intro.CHILD_HEIGHT==290,'Larger children')
 print('RELEASE_V113_FAILURES=',failures)
 g.free();quit(1 if failures else 0)
