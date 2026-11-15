extends SceneTree
var failures=0
func check(ok: bool,msg: String):
 if not ok:failures+=1;printerr(msg)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.gd').new();root.add_child(g);g.set_process(false);g.test_mode=true
 g.mode='language';g.language_selected=false
 var ev=InputEventKey.new();ev.pressed=true;ev.keycode=KEY_ESCAPE;g._unhandled_input(ev)
 check(g.mode=='language','First choice cannot be skipped')
 for code in ['en','es','zh']:
  g.language=code;g.mode='help'
  for page in g.HELP_PAGES:
   check(g.menu_translations.has(page[0]),'Missing heading '+page[0])
   for row in page[1]:
    for value in row:
     if value=='':continue
     check(g.menu_translations.has(value),'Missing guide text '+value)
     var translated=g.ui_text(value)
     var font=g.ui_font();var size=g.fitted_size(translated,font,18,636)
     check(size>=16,'Guide text too small '+code+': '+translated)
     for i in range(translated.length()):check(font.has_char(translated.unicode_at(i)),'Missing glyph '+code+': '+translated[i])
 g.mode='language';g.handle_press(Vector2(350,840));check(g.language=='zh' and g.mode=='menu','Chinese selected')
 var cfg=ConfigFile.new();cfg.load('user://progress.cfg');check(cfg.get_value('game','language','')=='zh','Language persisted')
 g.mode='menu';g.handle_press(Vector2(350,1100));check(g.mode=='language','Reopen language selection')
 g.handle_press(Vector2(350,480));check(g.language=='fr','French selected')
 g.start_game();check(g.max_active_enemies()==3,'Initial cap unchanged')
 g.score=50000;check(g.max_active_enemies()==15,'Late cap unchanged')
 g.mode='play';g.language='en';check(g.ui_text('NOUVELLE PARTIE')=='NOUVELLE PARTIE','Game text outside scope unchanged')
 print('LOCALIZATION_FAILURES=',failures);g.free();quit(1 if failures else 0)
