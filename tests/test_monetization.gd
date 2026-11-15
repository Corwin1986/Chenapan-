extends SceneTree
const Service=preload("res://monetization/ad_service.gd")
const BaseProvider=preload("res://monetization/ad_provider.gd")
class FakeProvider extends BaseProvider:
	var ad_available=true
	var shown=[]
	var initialize_calls=0
	var loaded_count=0
	var applied={}
	func _init():is_native=true
	func configure_policy(policy: Dictionary):applied=policy
	func initialize(_ids: Dictionary)->bool:initialize_calls+=1;return true
	func is_ready(_format: String)->bool:return ad_available
	func load_ad(_format: String):loaded_count+=1
	func show(format: String,token: int)->bool:
		shown.append([format,token]);return ad_available
var failures=0
var rewards=0
func check(ok: bool,label: String):
	if not ok:failures+=1;printerr("FAIL: "+label)
func _initialize():call_deferred("run")
func run():
	var s=Service.new();root.add_child(s)
	var f=FakeProvider.new();s.attach_provider(f)
	s.reward_validated.connect(func(_reward):rewards+=1)
	# No calls into SDK or network, even if a provider exists, with shipped defaults.
	s.prepare("interstitial")
	for i in range(8):s.begin_round();s.finish_round()
	check(f.initialize_calls==0 and f.shown.is_empty(),"disabled build never initializes or shows ads")
	check(not s.can_offer_reward(),"no misleading reward button when unavailable")
	s.config.enabled=true;s.config.native_integration_verified=true
	s.platform="Android"
	s.config.ids.Android={"app":"ca-app-pub-3940256099942544~fake","interstitial":"ca-app-pub-3940256099942544/fake","rewarded":"ca-app-pub-3940256099942544/fake","banner":"ca-app-pub-3940256099942544/fake"}
	s.privacy.ads_opt_out=false
	s.privacy.session_can_request_ads=true;s.privacy.session_legal_basis_reviewed=true
	s.privacy.age_group="unknown"
	check(s.block_reason("interstitial")=="child_and_unknown_age_review_required","unknown age protected even with consent")
	s.privacy.age_group="minor"
	check(not s.block_reason("rewarded").is_empty(),"minor blocked even with consent")
	s.privacy.age_group="adult"
	s.privacy.session_can_request_ads=false
	check(s.block_reason("interstitial")=="privacy_not_authorized","adult requires native privacy result")
	s.privacy.session_can_request_ads=true
	s.prepare("interstitial")
	check(f.initialize_calls==1 and f.applied.non_personalized and not f.applied.tracking_allowed,"policy configured before advertising")
	s.completed_rounds=0
	for i in range(3):s.begin_round();s.finish_round();s.finish_round()
	check(f.shown.is_empty(),"no ads first three rounds or duplicate finish")
	s.begin_round()
	check(not s._try_show("interstitial"),"never show during gameplay")
	s.finish_round()
	check(f.shown.size()==1 and f.shown[0][0]=="interstitial","fourth completed round")
	f.closed.emit("interstitial",s.active_token)
	f.ad_available=false
	for i in range(4):s.begin_round();s.finish_round()
	check(f.shown.size()==1,"no-fill skips boundary")
	f.ad_available=true;f.loaded.emit("interstitial")
	check(f.shown.size()==1,"late load does not interrupt next game")
	check(not s.request_reward("revive_once",false),"reward requires deliberate action")
	check(s.request_reward("revive_once",true),"optional rewarded ad starts when ready")
	var token=s.active_token
	f.closed.emit("rewarded",token)
	f.reward_earned.emit(token)
	check(rewards==0,"closing or late callback does not grant reward")
	check(s.request_reward("revive_once",true),"retry after cancellation")
	token=s.active_token
	f.reward_earned.emit(token);f.reward_earned.emit(token)
	check(rewards==1,"exactly one reward per verified callback token")
	f.closed.emit("rewarded",token)
	check(not s.can_offer_reward(),"only one rewarded revive per round")
	s.begin_round();s.finish_round()
	s.request_reward("revive_once",true);token=s.active_token
	s.privacy.invalidate();s._revoke();f.reward_earned.emit(token)
	check(rewards==1 and s.active_token==0,"privacy change invalidates pending reward")
	s.privacy.session_can_request_ads=true;s.privacy.session_legal_basis_reviewed=true
	s.prepare("rewarded");s.request_reward("revive_once",true)
	s._process(121)
	check(s.active_token==0,"missing callback cannot block game indefinitely")
	s.platform="iOS";s.config.ids.iOS=s.config.ids.Android.duplicate()
	s.config.ios_kids_category=true
	check(s.block_reason("rewarded")=="ios_kids_review_required","iOS Kids is independently blocked")
	s.platform="Android";s.config.ids.Android.rewarded="ca-app-pub-1111111111111111/1234567890"
	check(s.block_reason("rewarded")=="missing_or_non_test_ids","development rejects production identifiers")
	check(not s.config.banner_enabled,"banner off by default")
	s.free()
	print("MONETIZATION_TEST_FAILURES=",failures)
	quit(1 if failures else 0)
