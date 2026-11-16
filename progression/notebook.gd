extends RefCounted
# Persistent cosmetic economy; no influence on gameplay RNG or combat.
const TEST_ALL_CLOTHES=false
var purchased_equipment={}
const SAVE_PATH="user://wardrobe.cfg"
const TASKS=[
 {"id":"first_steps","title":"LA TERREUR DU QUARTIER","text":"Vaincs 50 assaillants, sur plusieurs parties.","event":"kills","goal":50,"run":false,"coins":100},
 {"id":"untouched","title":"ATTRAPE-MOI SI TU PEUX","text":"Tiens 40 secondes sans perdre de vie.","event":"clean","goal":40,"run":true,"coins":100},
 {"id":"parcels","title":"LES POCHES PLEINES","text":"Ramasse 20 cadeaux, sur plusieurs parties.","event":"boxes","goal":20,"run":false,"coins":100},
 {"id":"dogs_first","title":"LES COPAINS À QUATRE PATTES","text":"Utilise les chiens 3 fois, sur plusieurs parties.","event":"dogs","goal":3,"run":false,"coins":100},
 {"id":"crowd","title":"TOUT LE VILLAGE Y PASSE","text":"Vaincs 100 assaillants dans une seule partie.","event":"kills","goal":100,"run":true,"coins":100},
 {"id":"dogs_team","title":"CHEF DE MEUTE","text":"Utilise les chiens 5 fois, sur plusieurs parties.","event":"dogs","goal":5,"run":false,"coins":100},
 {"id":"harvest","title":"LA GRANDE RÉCOLTE","text":"Ramasse 10 cadeaux dans une seule partie.","event":"boxes","goal":10,"run":true,"coins":100},
 {"id":"reputation","title":"LA MAUVAISE RÉPUTATION","text":"Atteins 50 000 points dans une seule partie.","event":"score","goal":50000,"run":true,"coins":100},
 {"id":"expert","title":"LES MAINS EN OR","text":"Récupère les 6 lance-pierres, jusqu'au doré.","event":"slings","goal":6,"run":true,"coins":200},
 {"id":"clean_master","title":"INSAISISSABLE","text":"Tiens 2 minutes sans perdre de vie.","event":"clean","goal":120,"run":true,"coins":200},
 {"id":"legend","title":"LA LÉGENDE DU CHENAPAN","text":"Atteins 120 000 points dans une seule partie.","event":"score","goal":120000,"run":true,"coins":200},
 {"id":"fire_master","title":"CHAUD DEVANT !","text":"Vaincs 50 assaillants avec les boules de feu.","event":"fire_kills","goal":50,"run":false,"coins":500},
 {"id":"ice_master","title":"UN FROID DE CANARD","text":"Vaincs 50 assaillants avec les boules de glace.","event":"ice_kills","goal":50,"run":false,"coins":500},
 {"id":"electric_master","title":"COUP DE FOUDRE","text":"Vaincs 50 assaillants avec les boules de foudre.","event":"electric_kills","goal":50,"run":false,"coins":500},
 {"id":"egg_master","title":"L’OMELETTE DU VILLAGE","text":"Vaincs 100 assaillants avec les œufs.","event":"egg_kills","goal":100,"run":false,"coins":500}
]
const RANKS=["PETIT FARCEUR","CANCRE DU QUARTIER","TERREUR DU VILLAGE","CHENAPAN LÉGENDAIRE"]
const THRESHOLDS=[0,3,6,11]
const CATEGORIES=["shoes","shorts","tops","hats","backpacks","costumes"]
const CATEGORY_NAMES=["BASKETS","SHORTS","HAUTS","TÊTES","SACS À DOS","TENUES"]
var g
var renderer
var catalog: Array=[]
var owned: Array=[]
var equipped={"shoes":"","shorts":"","tops":"","hats":"","backpacks":"","costumes":""}
var coins=0
var earned=0
var spent=0
var total_completed=0
var daily_date=""
var daily_completed=0
var daily_earned=0
var daily_best=0
var daily_rounds=0
var daily_bonus_claimed=false
var day_poll_clock=0.0
var legacy_completed=0
var done: Array=[]
var task_cursor=0
var cycle=0
var values: Dictionary={}
var active: Array=[]
var newly_done: Array=[]
var round_coins=0
var clean_seconds=0.0
var previous_life=100.0
var wait_new_run=false
var rounds=0
var run_finished=false
var intro_seen=false
var save_path=SAVE_PATH
var dirty=false
var save_clock=0.0
var last_save_error=OK
var selected_tab=0
var category_index=0
var preview_back=false
var dressing_open=false
var shop_index=0
var dress_index=0
var book_return="menu"
var notice=""
var modal=""
var modal_item=""
var toast=""
var toast_clock=0.0
var share_notice=""
var web_share_callback
var sharing=false

func setup(game,path: String=SAVE_PATH):
 g=game;save_path=path
 catalog=JSON.parse_string(FileAccess.get_file_as_string("res://progression/catalog.json"))
 load_data()
 ensure_day()
 purchased_equipment=equipped.duplicate()
 refresh_active()
 renderer=load("res://progression/wardrobe_renderer.gd").new()
 renderer.setup(self)

func ensure_day(today: String=""):
 if today=="":today=Time.get_date_string_from_system(false)
 # Local calendar day. Moving the clock backwards must not award another daily bonus.
 if daily_date!="" and today<=daily_date:return
 daily_date=today;daily_completed=0;daily_earned=0;daily_best=0;daily_rounds=0;daily_bonus_claimed=false
 # The current challenge, its progress, wallet and equipment survive midnight.
 dirty=true
 save_data()
func poll_day(dt: float):
 day_poll_clock+=dt
 if day_poll_clock>=1.0:day_poll_clock=0.0;ensure_day()
func register_kill(projectile: int):
 # One kill contributes to the active challenge only. Dogs/storm kills have no projectile.
 var key={1:"fire_kills",2:"ice_kills",3:"electric_kills",4:"egg_kills"}.get(projectile,"")
 if task().event=="kills":event("kills")
 elif key!="":event(key)

func task() -> Dictionary:return TASKS[task_cursor]
func refresh_active():active=[task().id]
func task_index(id: String) -> int:
 for i in TASKS.size():
  if TASKS[i].id==id:return i
 return -1
func current_value() -> int:return int(values.get(task().id,0))
func load_data():
 var cfg=ConfigFile.new()
 if cfg.load(save_path)!=OK and cfg.load(save_path+".bak")!=OK:
  if save_path==SAVE_PATH:
   var old=ConfigFile.new()
   if old.load("user://notebook.cfg")==OK:
    intro_seen=bool(old.get_value("notebook","intro_seen",false))
    rounds=int(old.get_value("notebook","rounds",0))
    legacy_completed=old.get_value("notebook","completed",[]).size()
  return
 daily_date=str(cfg.get_value("daily","date",""))
 daily_completed=maxi(0,int(cfg.get_value("daily","completed",0)))
 daily_earned=maxi(0,int(cfg.get_value("daily","earned",0)))
 daily_best=maxi(0,int(cfg.get_value("daily","best",0)))
 daily_rounds=maxi(0,int(cfg.get_value("daily","rounds",0)))
 daily_bonus_claimed=bool(cfg.get_value("daily","bonus_claimed",false))
 coins=maxi(0,int(cfg.get_value("collection","coins",0)))
 earned=maxi(0,int(cfg.get_value("collection","earned",coins)))
 spent=maxi(0,int(cfg.get_value("collection","spent",0)))
 task_cursor=clampi(int(cfg.get_value("collection","task_cursor",0)),0,TASKS.size()-1)
 cycle=maxi(0,int(cfg.get_value("collection","cycle",0)))
 total_completed=maxi(0,int(cfg.get_value("collection","total_completed",0)))
 legacy_completed=maxi(0,int(cfg.get_value("collection","legacy_completed",0)))
 rounds=maxi(0,int(cfg.get_value("collection","rounds",0)))
 intro_seen=bool(cfg.get_value("collection","intro_seen",false))
 wait_new_run=bool(cfg.get_value("collection","wait_new_run",false))
 values={task().id:clampi(int(cfg.get_value("collection","value",0)),0,task().goal)}
 var saved_owned=cfg.get_value("collection","owned",[])
 if saved_owned is Array:
  for item in catalog:
   if saved_owned.has(item.id):owned.append(item.id)
 var saved_equipped=cfg.get_value("collection","equipped",{})
 if saved_equipped is Dictionary:
  for cat in CATEGORIES:
   var id=str(saved_equipped.get(cat,""))
   if owned.has(id) and item_by_id(id).get("category","")==cat:equipped[cat]=id
 var saved_done=cfg.get_value("collection","done",[])
 if saved_done is Array:
  for id in saved_done:
   if task_index(str(id))>=0 and not done.has(id):done.append(id)

func save_data() -> bool:
 var cfg=ConfigFile.new()
 var data={"schema":3,"coins":coins,"earned":earned,"spent":spent,"task_cursor":task_cursor,"cycle":cycle,"value":current_value(),"total_completed":total_completed,"legacy_completed":legacy_completed,"owned":owned,"equipped":purchased_equipment if TEST_ALL_CLOTHES else equipped,"done":done,"rounds":rounds,"intro_seen":intro_seen,"wait_new_run":wait_new_run}
 for key in data:cfg.set_value("collection",key,data[key])
 var daily={"date":daily_date,"completed":daily_completed,"earned":daily_earned,"best":daily_best,"rounds":daily_rounds,"bonus_claimed":daily_bonus_claimed}
 for key in daily:cfg.set_value("daily",key,daily[key])
 last_save_error=cfg.save(save_path+".tmp")
 if last_save_error!=OK:return false
 if FileAccess.file_exists(save_path):DirAccess.copy_absolute(save_path,save_path+".bak")
 last_save_error=DirAccess.rename_absolute(save_path+".tmp",save_path)
 if last_save_error==OK:dirty=false
 return last_save_error==OK

func begin_round():
 ensure_day()
 refresh_active();newly_done.clear();round_coins=0;clean_seconds=0.0
 previous_life=g.life;run_finished=false;share_notice="";wait_new_run=false
 if task().run:values[task().id]=0
 dirty=true

func event(key: String,amount: float=1.0,absolute: bool=false):
 ensure_day()
 var t=task()
 if wait_new_run or t.event!=key:return
 var value=float(values.get(t.id,0))
 if absolute:value=amount
 else:value+=amount
 values[t.id]=clampf(value,0,t.goal);dirty=true
 if value>=t.goal:complete_task()

func complete_task():
 ensure_day()
 var t=task()
 # Move the cursor and credit once in the same atomic save. Excess events never carry over.
 coins+=t.coins;earned+=t.coins;round_coins+=t.coins;total_completed+=1
 daily_completed+=1;daily_earned+=t.coins
 var daily_bonus=daily_completed>=11 and not daily_bonus_claimed
 if daily_bonus:
  daily_bonus_claimed=true;coins+=500;earned+=500;daily_earned+=500;round_coins+=500
 if not done.has(t.id):done.append(t.id)
 newly_done.append(t.id)
 toast=g.ui_text("DÉFI RELEVÉ ! +%d PIÈCES")%t.coins;toast_clock=4.0
 if daily_bonus:toast=g.ui_text("11 DÉFIS DU JOUR ! BONUS +500 PIÈCES");toast_clock=6.0
 task_cursor+=1
 if task_cursor>=TASKS.size():task_cursor=0;cycle+=1
 values={task().id:0};clean_seconds=0.0
 wait_new_run=(task().event=="slings" and g.sling_level>0) or (task().event=="score" and g.score>=task().goal)
 refresh_active();save_data()

func skip_task() -> bool:
 var before=[task_cursor,cycle,values.duplicate(true),clean_seconds,wait_new_run]
 task_cursor+=1
 if task_cursor>=TASKS.size():task_cursor=0;cycle+=1
 values={task().id:0};clean_seconds=0.0
 wait_new_run=(task().event=="slings" and g.sling_level>0) or (task().event=="score" and g.score>=task().goal)
 refresh_active()
 if not save_data():
  task_cursor=before[0];cycle=before[1];values=before[2];clean_seconds=before[3];wait_new_run=before[4]
  refresh_active();return false
 toast="";toast_clock=0;return true

func tick(dt: float):
 ensure_day()
 if g.score>daily_best:daily_best=g.score;dirty=true
 toast_clock=maxf(0,toast_clock-dt)
 if g.life<previous_life:clean_seconds=0.0
 else:clean_seconds+=dt
 previous_life=g.life
 # One evaluation per frame, preventing completion cascades through different objectives.
 if task().event=="score":event("score",g.score,true)
 elif task().event=="clean":event("clean",floorf(clean_seconds),true)
 save_clock+=dt
 if save_clock>=10:
  save_clock=0
  if dirty:save_data()
func on_damage():
 clean_seconds=0;previous_life=g.life
 if task().event=="clean":values[task().id]=0;dirty=true
func end_round():
 ensure_day()
 daily_best=maxi(daily_best,g.score)
 if task().event=="score":event("score",g.score,true)
 if not run_finished:rounds+=1;daily_rounds+=1;run_finished=true
 save_data()
func rank_index() -> int:
 var r=0
 for i in THRESHOLDS.size():
  if daily_completed>=THRESHOLDS[i]:r=i
 return r
func title() -> String:return RANKS[rank_index()]
func item_by_id(id: String) -> Dictionary:
 for item in catalog:
  if item.id==id:return item
 return {}
func items_for(cat: String) -> Array:
 return catalog.filter(func(item):return item.category==cat)
func next_item(cat: String) -> Dictionary:
 for item in items_for(cat):
  if not owned.has(item.id):return item
 return {}
func visible_items(cat: String) -> Array:
 if TEST_ALL_CLOTHES:return items_for(cat)
 var result=[]
 for item in items_for(cat):
  if can_wear(item.id):result.append(item)
 var upcoming=next_item(cat)
 if not upcoming.is_empty():result.append(upcoming)
 return result
func buy(id: String) -> bool:
 if TEST_ALL_CLOTHES:return false
 var item=item_by_id(id)
 if item.is_empty() or owned.has(id):return false
 if next_item(item.category).get("id","")!=id or coins<item.price:return false
 coins-=item.price;spent+=item.price;owned.append(id)
 if not save_data():
  coins+=item.price;spent-=item.price;owned.erase(id);return false
 return true
func can_wear(id: String) -> bool:
 return TEST_ALL_CLOTHES or owned.has(id)
func equip_item(id: String) -> bool:
 var item=item_by_id(id)
 if item.is_empty() or not can_wear(id):return false
 var before=equipped.duplicate()
 equipped[item.category]=id
 if item.category!="costumes":equipped.costumes=""
 if not save_data():equipped=before;return false
 renderer.invalidate();return true
func remove_item(cat: String):
 var before=equipped.duplicate();equipped[cat]=""
 if not save_data():equipped=before
 renderer.invalidate()

func open_book(from_mode: String="menu"):
 book_return=from_mode;selected_tab=0;g.mode="notebook";share_notice="";notice="";modal=""
func fit_label(text: String,rect: Rect2,size: int=24,col: Color=Color("34263c"),font: Font=null):
 text=g.ui_text(text)
 var f=g.ui_font(font)
 size=g.fitted_size(text,f,size,rect.size.x)
 g.draw_string(f,Vector2(rect.position.x+(rect.size.x-f.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x)/2,rect.position.y),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,col)
func coins_text() -> String:return g.ui_text("%d PIÈCES")%coins
func draw_book():
 g.draw_rect(Rect2(0,0,720,1280),g.PAPER)
 g.rounded(Rect2(24,22,672,208),g.INK,24)
 g.label("LE CARNET QUOTIDIEN",Vector2(48,73),37,g.PAPER,g.title_font)
 g.label(title(),Vector2(48,117),25,g.GOLD,g.title_font)
 g.label(coins_text(),Vector2(48,164),33,g.GOLD,g.title_font)
 g.label("VERSION TEST : TOUT EST DISPONIBLE" if TEST_ALL_CLOTHES else "Des vêtements, aucun bonus de puissance.",Vector2(48,203),19,g.PAPER)
 var tabs=["DÉFI","ACHETER","VESTIAIRE","PALMARÈS"]
 for i in tabs.size():g.button(Rect2(24+i*174,250,150,62),tabs[i],g.TEAL if selected_tab==i else g.INK)
 if selected_tab==0:draw_tasks()
 elif selected_tab==1:draw_shop()
 elif selected_tab==2:draw_dressing()
 else:draw_honors()
 if last_save_error!=OK:g.centered("Sauvegarde indisponible sur cet appareil.",1148,18,g.CORAL)
 elif notice!="" and selected_tab!=1:g.centered(notice,1148,18,g.TEAL)
 g.button(Rect2(80,1185,560,64),"RETOUR",g.INK)
 if modal!="":draw_modal()
func draw_tasks():
 var t=task()
 g.rounded(Rect2(34,360,652,480),Color.WHITE,22,2)
 fit_label(t.title,Rect2(54,422,612,40),31,g.INK,g.title_font)
 fit_label(t.text,Rect2(54,483,612,40),25)
 g.centered("Une seule partie" if t.run else "Cumul conservé entre les jours",532,21,g.PURPLE)
 g.centered(g.ui_text("Progression : %d / %d")%[current_value(),t.goal],607,32,g.TEAL)
 g.rounded(Rect2(68,642,584,24),Color("e7ddca"),12)
 if current_value()>0:g.rounded(Rect2(68,642,584.0*current_value()/t.goal,24),g.TEAL,12)
 g.centered(g.ui_text("RÉCOMPENSE : %d PIÈCES")%t.coins,740,32,g.PURPLE,g.title_font)
 if wait_new_run:g.centered("Démarre une nouvelle partie pour ce défi.",796,20,g.CORAL)
 g.centered("Termine ou passe ce défi pour découvrir le suivant.",903,23,g.INK)
 g.centered("Passer est gratuit et ne rapporte aucune pièce.",945,21)
 g.centered("Les défis reviennent pour gagner d'autres pièces.",1000,20,g.TEAL)
 g.button(Rect2(110,1040,500,67),"JOUER")
 g.button(Rect2(110,1120,500,50),"PASSER CE DÉFI",g.PURPLE)
func category_rect(i: int) -> Rect2:
 return Rect2(24+i*113,332,107,56)
func draw_categories():
 for i in CATEGORIES.size():
  var r=category_rect(i)
  g.rounded(r,g.TEAL if category_index==i else g.PURPLE,12)
  fit_label(CATEGORY_NAMES[i],Rect2(r.position.x+5,r.position.y+36,r.size.x-10,40),20,g.PAPER,g.title_font)
func shop_item() -> Dictionary:
 var visible=items_for(CATEGORIES[category_index])
 if visible.is_empty():return {}
 shop_index=clampi(shop_index,0,visible.size()-1)
 return visible[shop_index]
func shop_cell(i: int) -> Rect2:
 return Rect2(28+(i%4)*170,420+int(i/4)*124,154,112)
func shop_locked(item: Dictionary) -> bool:
 if TEST_ALL_CLOTHES:return false
 return not owned.has(item.id) and item.id!=visible_items(CATEGORIES[category_index])[-1].id
func draw_shop():
 draw_categories()
 var options=items_for(CATEGORIES[category_index])
 for i in options.size():
  var item=options[i];var r=shop_cell(i);var locked=shop_locked(item)
  g.rounded(r,Color("dcd3c6") if locked else Color.WHITE,12,2)
  if i==shop_index and not locked:g.draw_rect(r.grow(2),g.TEAL,false,3)
  var art=Rect2(r.position+Vector2(9,6),Vector2(136,82))
  if locked:
   renderer.draw_locked(item,art)
   var c=r.get_center()
   g.draw_arc(c+Vector2(0,-12),12,PI,TAU,20,g.INK,5,true)
   g.rounded(Rect2(c+Vector2(-18,-13),Vector2(36,30)),g.INK,6)
   g.draw_circle(c+Vector2(0,-2),4,g.GOLD)
  else:
   renderer.draw_item(item,art)
   if not can_wear(item.id):
    var badge=r.position+Vector2(r.size.x-22,21)
    g.draw_circle(badge,19,g.PAPER)
    g.draw_arc(badge+Vector2(0,-5),7,PI,TAU,16,g.INK,3,true)
    g.rounded(Rect2(badge+Vector2(-10,-5),Vector2(20,16)),g.INK,4)
    g.draw_circle(badge+Vector2(0,1),2,g.GOLD)

   fit_label("ESSAYER" if TEST_ALL_CLOTHES else "ARTICLE POSSÉDÉ" if owned.has(item.id) else g.ui_text("%d PIÈCES")%item.price,Rect2(r.position.x+4,r.end.y-8,r.size.x-8,25),18,g.TEAL,g.title_font)
 var selected=shop_item()
 if not selected.is_empty() and not shop_locked(selected):
  fit_label(selected.name,Rect2(40,1070,640,36),26,g.INK,g.title_font)
  g.button(Rect2(100,1090,520,62),"CHOISIR DANS VESTIAIRE" if can_wear(selected.id) else "ACHETER",g.TEAL if can_wear(selected.id) or coins>=selected.price else g.INK)
func draw_quest_hud():
 var t=task()
 g.rounded(Rect2(18,91,684,73),g.PAPER,12,2)
 fit_label(t.text,Rect2(30,117,660,28),21,g.INK)
 g.centered("%d / %d"%[current_value(),t.goal],148,26,g.TEAL,g.title_font)
func dress_options() -> Array:
 var result=[{}]
 for item in items_for(CATEGORIES[category_index]):
  if can_wear(item.id):result.append(item)
 return result
func dress_item() -> Dictionary:
 var options=dress_options();dress_index=clampi(dress_index,0,options.size()-1);return options[dress_index]
func draw_dressing():
 if not dressing_open:
  renderer.draw_hero(1,Vector2(360,820),390)
  g.centered("TA TENUE ACTUELLE",425,29,g.TEAL,g.title_font)
  g.button(Rect2(100,923,520,70),"ÉQUIPER",g.TEAL)
  g.centered("Choisis parmi les articles que tu possèdes.",1080,22)
  return
 draw_categories()
 var item=dress_item()
 g.centered("ESSAYAGE",425,26,g.TEAL,g.title_font)
 var preview=equipped.duplicate()
 preview[CATEGORIES[category_index]]=item.get("id","")
 if CATEGORIES[category_index]!="costumes":preview.costumes=""
 renderer.draw_hero(0 if preview_back else 1,Vector2(360,760),300,Color.WHITE,0,preview)
 g.button(Rect2(230,780,70,50),"‹",g.TEAL)
 g.button(Rect2(420,780,70,50),"›",g.TEAL)
 fit_label("DOS" if preview_back else "FACE",Rect2(305,813,110,26),20,g.TEAL,g.title_font)
 g.button(Rect2(34,565,76,66),"‹",g.PURPLE);g.button(Rect2(610,565,76,66),"›",g.PURPLE)
 fit_label(item.get("name","TENUE D'ORIGINE"),Rect2(44,870,632,40),30,g.INK,g.title_font)
 g.centered("Aucun achat dans cette catégorie." if dress_options().size()==1 else "Aperçu : confirme pour porter cet article.",904,18)
 var is_equipped=equipped[CATEGORIES[category_index]]==item.get("id","")
 g.button(Rect2(100,923,520,70),"ÉQUIPÉ" if is_equipped else "ÉQUIPER",g.INK if is_equipped else g.TEAL)
 g.button(Rect2(100,1010,520,62),"TENUE D'ORIGINE",g.PURPLE)
 g.centered("Équiper une pièce retire le costume complet.",1110,19)
func draw_honors():
 g.centered("PALMARÈS DU JOUR",347,25,g.TEAL,g.title_font)
 for i in RANKS.size():
  var y=370+i*99
  g.rounded(Rect2(36,y,648,88),g.INK if i==rank_index() else Color.WHITE,16,2)
  g.label(RANKS[i],Vector2(62,y+35),26,g.GOLD if i==rank_index() else g.INK,g.title_font)
  g.label(g.ui_text("%d défis relevés")%THRESHOLDS[i],Vector2(62,y+65),19,g.PAPER if i==rank_index() else g.TEAL)
 g.centered(g.ui_text("Défis du jour : %d / 11")%daily_completed,805,26,g.TEAL,g.title_font)
 g.centered("BONUS +500 PIÈCES REÇU !" if daily_bonus_claimed else "11 défis réussis aujourd’hui = +500 pièces",850,23,g.PURPLE,g.title_font)
 g.centered(g.ui_text("Record du jour : %d points")%daily_best,904,23)
 g.centered(g.ui_text("Pièces gagnées aujourd’hui : %d")%daily_earned,944,21)
 g.centered(g.ui_text("Parties terminées aujourd’hui : %d")%daily_rounds,984,21)
 g.centered(g.ui_text("Articles possédés : %d / %d")%[owned.size(),catalog.size()],1024,21)
 g.centered("Remise à zéro à minuit, heure du téléphone.",1080,20,g.TEAL)
 g.centered("Pièces, achats et défi en cours conservés.",1117,20)
func draw_modal():
 g.draw_rect(Rect2(0,0,720,1280),Color(0,0,0,0.65))
 g.rounded(Rect2(40,390,640,505),g.PAPER,24,3)
 var item=item_by_id(modal_item)
 g.centered("ACHAT EFFECTUÉ !" if modal=="bought" else "CONFIRMER L'ACHAT",450,32,g.TEAL,g.title_font)
 renderer.draw_item(item,Rect2(250,474,220,172))
 fit_label(item.name,Rect2(64,690,592,40),27,g.INK,g.title_font)
 g.centered("Veux-tu le porter maintenant ?" if modal=="bought" else g.ui_text("Acheter pour %d pièces ?")%item.price,738,24)
 g.button(Rect2(64,790,280,64),"PLUS TARD" if modal=="bought" else "ANNULER",g.INK)
 g.button(Rect2(376,790,280,64),"ÉQUIPER" if modal=="bought" else "ACHETER",g.TEAL)
func handle_book(pos: Vector2):
 if modal!="":
  if Rect2(64,790,280,64).has_point(pos):modal="";return
  if Rect2(376,790,280,64).has_point(pos):
   if modal=="bought":equip_item(modal_item);modal=""
   elif buy(modal_item):modal="bought";notice="Achat enregistré."
   else:modal="";notice="Achat impossible. Vérifie tes pièces."
  return
 if Rect2(80,1185,560,64).has_point(pos):g.mode=book_return;return
 for i in 4:
  if Rect2(24+i*174,250,150,62).has_point(pos):
   selected_tab=i;notice=""
   if i==2:dressing_open=false
   if i==1:shop_index=maxi(0,visible_items(CATEGORIES[category_index]).size()-1)
   return
 if selected_tab==0:
  if Rect2(110,1040,500,67).has_point(pos):g.start_game()
  elif Rect2(110,1120,500,50).has_point(pos):skip_task()
  return
 if selected_tab not in [1,2]:return
 if selected_tab==2 and not dressing_open:
  if Rect2(100,923,520,70).has_point(pos):dressing_open=true;dress_index=0
  return
 for i in CATEGORIES.size():
  if category_rect(i).has_point(pos):
   category_index=i;shop_index=maxi(0,visible_items(CATEGORIES[i]).size()-1);dress_index=0
   if CATEGORIES[i]=="backpacks":preview_back=true
   return
 if selected_tab==1:
  var options=items_for(CATEGORIES[category_index])
  for i in options.size():
   if shop_cell(i).has_point(pos):
    if not shop_locked(options[i]):shop_index=i
    return
  if Rect2(100,1090,520,62).has_point(pos):
   var item=shop_item()
   if shop_locked(item):return
   if can_wear(item.id):
    selected_tab=2;dressing_open=true
    var available=dress_options()
    for i in available.size():
     if available[i].get("id","")==item.id:dress_index=i
   elif coins>=item.price:modal="buy";modal_item=item.id

 else:
  if Rect2(230,780,70,50).has_point(pos) or Rect2(420,780,70,50).has_point(pos):
   preview_back=not preview_back;return
  var options=dress_options()
  if Rect2(34,565,76,66).has_point(pos):dress_index=posmod(dress_index-1,options.size())
  elif Rect2(610,565,76,66).has_point(pos):dress_index=posmod(dress_index+1,options.size())
  elif Rect2(100,923,520,70).has_point(pos):
   var item=dress_item()
   if item.is_empty():remove_item(CATEGORIES[category_index])
   else:equip_item(item.id)
  elif Rect2(100,1010,520,62).has_point(pos):
   var before=equipped.duplicate()
   for cat in CATEGORIES:equipped[cat]=""
   if not save_data():equipped=before
   renderer.invalidate();dress_index=0
func draw_toast():
 if toast_clock<=0:return
 g.rounded(Rect2(64,182,592,64),g.PAPER,16,2)
 g.centered(toast,225,28,g.TEAL,g.title_font)
func draw_summary():
 g.draw_rect(Rect2(0,0,720,1280),Color(0.14,0.1,0.16,0.82))
 g.rounded(Rect2(30,50,660,1170),g.PAPER,24,3)
 g.centered("LIBRE COMME L'AIR !" if g.mode=="win" else "ATTRAPÉ !",112,44,g.INK,g.title_font)
 g.centered(captor_line(),152,21)
 g.centered("VILLAGE VS CHENAPAN",180,16,g.PURPLE,g.title_font)
 g.centered(g.ui_text("%d POINTS")%g.score,234,48,g.TEAL,g.title_font)
 g.centered(g.ui_text("Record : %d points")%g.best,272,23)
 g.centered(title(),310,25,g.PURPLE,g.title_font)
 g.centered(g.ui_text("%d assaillants vaincus · %d cadeaux")%[g.kills,g.stats.boxes],355,20)
 g.centered(g.ui_text("Cette partie : +%d pièces")%round_coins,408,30,g.TEAL,g.title_font)
 g.centered(coins_text(),451,25,g.PURPLE)
 var t=task()
 g.rounded(Rect2(52,488,616,215),Color("f0e5d0"),16)
 g.centered("DÉFI EN COURS",526,22,g.TEAL,g.title_font)
 fit_label(t.title,Rect2(70,572,580,40),26,g.INK,g.title_font)
 g.centered(g.ui_text("Progression : %d / %d")%[current_value(),t.goal],623,23)
 g.centered(g.ui_text("RÉCOMPENSE : %d PIÈCES")%t.coins,668,23,g.PURPLE)
 g.centered("Tes pièces et tes achats sont sauvegardés.",755,21)
 g.button(Rect2(70,790,580,80),"REJOUER")
 g.button(Rect2(70,888,280,62),"MON CARNET",g.PURPLE)
 g.button(Rect2(370,888,280,62),"PARTAGER",g.INK)
 g.button(Rect2(70,970,580,62),"MENU",g.INK)
 if share_notice!="":g.centered(share_notice,1165,18)

func captor_line() -> String:
 if g.mode=="win":return "Le village n'a pas dit son dernier mot."
 for kind in g.ENEMY_SPRITES.size():
  if g.ENEMY_SPRITES[kind].has(g.capture_sprite):return ["Le boulanger t'a rattrapé !","L'école t'a rattrapé !","La poste t'a rattrapé !","La police t'a rattrapé !","Les pompiers t'ont rattrapé !","Le bistrot t'a rattrapé !","Le restaurant t'a rattrapé !","Le boucher t'a rattrapé !","La paroisse t'a rattrapé !"][kind]
 return "Le village t'a rattrapé !"

func handle_summary(pos: Vector2):
 if Rect2(70,790,580,80).has_point(pos):g.start_game()
 elif Rect2(70,888,280,62).has_point(pos):open_book(g.mode)
 elif Rect2(370,888,280,62).has_point(pos):share_score()
 elif Rect2(70,970,580,62).has_point(pos):g.mode="menu"

func share_score():
 if sharing:return
 sharing=true
 var text="Village vs Chenapan · %d points · %s\n%s"%[g.score,g.ui_text(title()),"https://village-vs-chenapan-test-web.timelessjay.chatgpt.site"]
 # Capture only the result card, not navigation or other applications.
 await RenderingServer.frame_post_draw
 var image=g.get_viewport().get_texture().get_image()
 var size=image.get_size()
 var card=image.get_region(Rect2i(int(size.x*30.0/720),int(size.y*50.0/1280),int(size.x*660.0/720),int(size.y*720.0/1280)))
 var png=card.save_png_to_buffer()
 if OS.has_feature("web"):
  web_share_callback=JavaScriptBridge.create_callback(_on_web_share)
  var window=JavaScriptBridge.get_interface("window")
  window.chenapanShareDone=web_share_callback
  var encoded=Marshalls.raw_to_base64(png)
  JavaScriptBridge.eval("""(async()=>{
   const data=Uint8Array.from(atob(%s),c=>c.charCodeAt(0));
   const file=new File([data],'Chenapan-score.png',{type:'image/png'});
   const finish=s=>window.chenapanShareDone(s);
   try {
    if(navigator.share && navigator.canShare && navigator.canShare({files:[file]})) {
     await navigator.share({title:'Village vs Chenapan',text:%s,files:[file]});finish('shared');
    } else {
     const url=URL.createObjectURL(file);const link=document.createElement('a');
     link.href=url;link.download='Chenapan-score.png';link.click();
     setTimeout(()=>URL.revokeObjectURL(url),60000);finish('downloaded');
    }
   }catch(e){finish(e.name==='AbortError'?'cancelled':'failed');}
  })();"""%[JSON.stringify(encoded),JSON.stringify(text)],true)
  return
 if OS.get_name()=="Android" and Engine.has_singleton("AndroidRuntime"):
  var runtime=Engine.get_singleton("AndroidRuntime")
  var activity=runtime.getActivity()
  var intent_class=JavaClassWrapper.wrap("android.content.Intent")
  var intent=intent_class.Intent()
  intent.setAction(intent_class.ACTION_SEND)
  intent.setType("text/plain")
  intent.putExtra(intent_class.EXTRA_TEXT,text)
  var path="user://chenapan-score.png"
  if card.save_png(path)==OK:
   var package_info=activity.getPackageManager().getPackageInfo(activity.getPackageName(),8)
   var authority=""
   if package_info!=null:
    for provider in package_info.providers:
     if provider.name=="androidx.core.content.FileProvider":authority=provider.authority;break
   if authority!="":
    var provider_class=JavaClassWrapper.wrap("androidx.core.content.FileProvider")
    var file_class=JavaClassWrapper.wrap("java.io.File")
    var file=file_class.File(ProjectSettings.globalize_path(path))
    var uri=provider_class.getUriForFile(activity,authority,file)
    if uri!=null:
     intent.setType("image/png")
     intent.putExtra(intent_class.EXTRA_STREAM,uri)
     intent.addFlags(1)
  activity.startActivity(intent_class.createChooser(intent,"Village vs Chenapan"))
  share_notice="Choisis à qui partager ton score."
 else:
  DisplayServer.clipboard_set(text)
  card.save_png("user://chenapan-score.png")
  share_notice="Score copié : colle-le dans ton message."
 sharing=false

func _on_web_share(args: Array):
 sharing=false
 var state=str(args[0]) if not args.is_empty() else "failed"
 share_notice={"shared":"Carte partagée !","downloaded":"Carte téléchargée : envoie-la à tes amis.","cancelled":"Partage annulé.","failed":"Partage indisponible. Réessaie dans Safari ou Chrome."}.get(state,"")
