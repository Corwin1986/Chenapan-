extends SceneTree
var g
func _initialize():call_deferred("run")
func capture(name):
 g.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/scratch/57088ccfaa20/dist129/"+name+".png")
func run():
 g=load("res://main.gd").new();root.add_child(g);g.set_process(false);g.test_mode=true;g.language="fr"
 var n=g.notebook;n.save_path="user://verify129.cfg";n.owned=[];n.coins=0
 for cat in n.CATEGORIES:n.equipped[cat]=""
 g.mode="notebook";n.selected_tab=1;n.category_index=0;n.shop_index=0
 await capture("baskets_verrouillees")
 var prices=[500,500,500,1000,1000,2500]
 for c in n.CATEGORIES.size():
  n.category_index=c;var options=n.items_for(n.CATEGORIES[c]);n.coins=prices[c]*2
  for item in options:assert(item.price==prices[c])
  assert(not n.shop_locked(options[0]));assert(n.shop_locked(options[1]))
  assert(not n.can_wear(options[0].id));assert(not n.equip_item(options[0].id))
  assert(not n.buy(options[1].id));assert(n.buy(options[0].id));assert(n.coins==prices[c])
  assert(n.can_wear(options[0].id));assert(not n.shop_locked(options[1]));assert(n.shop_locked(options[2]))
  assert(n.equip_item(options[0].id));assert(n.dress_options().size()==2)
 n.category_index=0;n.shop_index=1
 await capture("baskets_apres_achat")
 n.category_index=4;n.shop_index=1
 await capture("sacs_apres_achat")
 assert(n.save_data())
 var restored=load("res://progression/notebook.gd").new();restored.setup(g,n.save_path)
 var old_owned=n.owned.duplicate();old_owned.sort();var new_owned=restored.owned.duplicate();new_owned.sort()
 assert(old_owned==new_owned and restored.coins==n.coins and restored.equipped==n.equipped)
 assert(not restored.can_wear("costumes_09"))
 assert(not g.has_method("open_mock_ad"));assert(not g.has_method("_on_ad_reward"))
 g.mode="cinematic";g._on_intro_finished();assert(g.mode=="play")
 g.mode="end";n.handle_summary(Vector2(200,1080));assert(g.mode=="end")
 await capture("fin_sans_pub")
 g.open_privacy("menu");await capture("confidentialite")
 print("RELEASE129_OK: prices six categories, sequential locks/purchases, persistence, no ad/revive paths, intro starts gameplay")
 g.free();quit()
