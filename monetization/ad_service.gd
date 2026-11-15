extends Node
## Independent, fail-closed monetization coordinator. No networking in phase 1.
signal reward_validated(reward: String)
signal availability_changed
signal privacy_changed
signal ad_finished
const Config = preload("res://monetization/ad_config.gd")
const Privacy = preload("res://monetization/privacy_state.gd")
const Provider = preload("res://monetization/ad_provider.gd")
var config = Config.new()
var privacy = Privacy.new()
var provider: Node
var platform = OS.get_name()
var in_round = false
var round_id = 0
var last_finished_round = -1
var completed_rounds = 0
var sequence = 0
var active_token = 0
var active_format = ""
var pending_reward = ""
var reward_claimed = false
var reward_used_this_round = false
var active_revision = -1
var busy_seconds = 0.0
var initialized = false
var last_error = ""
func _ready():
	privacy.load_local()
	attach_provider(Provider.new())
func attach_provider(p: Node):
	if provider!=null:
		provider.revoke_and_clear()
		provider.queue_free()
	provider=p
	add_child(provider)
	provider.reward_earned.connect(_on_reward_earned)
	provider.closed.connect(_on_closed)
	provider.failed.connect(_on_failed)
	provider.loaded.connect(func(_format):availability_changed.emit())
	provider.privacy_updated.connect(_on_privacy_updated)
	initialized=false
func _process(dt: float):
	if active_token!=0:
		busy_seconds+=dt
		if busy_seconds>120:
			_on_failed(active_format,active_token,"callback_timeout")
func block_reason(format: String) -> String:
	if not config.enabled: return "prototype_ads_disabled"
	if not config.native_integration_verified: return "native_integration_not_verified"
	if provider==null or not provider.is_native: return "native_adapter_not_installed"
	if not config.format_enabled(format): return "format_disabled"
	if not config.configured(platform,format): return "missing_or_non_test_ids"
	if privacy.ads_opt_out: return "user_opted_out"
	if platform=="iOS" and config.ios_kids_category and not config.ios_kids_ads_reviewed:
		return "ios_kids_review_required"
	if privacy.protected_audience():
		if not config.child_contextual_ads_reviewed or not config.child_formats_reviewed:
			return "child_and_unknown_age_review_required"
	if not privacy.session_can_request_ads or not privacy.session_legal_basis_reviewed:
		return "privacy_not_authorized"
	return ""
func prepare(format: String):
	if not block_reason(format).is_empty():return
	if not initialized:
		provider.configure_policy(privacy.request_policy())
		initialized=provider.initialize(config.ids[platform])
	if initialized:provider.load_ad(format)
func begin_round():
	round_id+=1
	in_round=true
	reward_used_this_round=false
	_cancel_pending()
	provider.hide_banner()
func finish_round():
	if not in_round or last_finished_round==round_id:return
	in_round=false
	last_finished_round=round_id
	completed_rounds+=1
	var interval=maxi(3,config.interstitial_every_rounds)
	if completed_rounds%interval!=0:return
	# If unavailable at this exact boundary, skip. Never show on a late load callback.
	_try_show("interstitial")
func abandon_round():
	in_round=false
	_cancel_pending()
func can_offer_reward() -> bool:
	return not in_round and not reward_used_this_round and active_token==0 and block_reason("rewarded").is_empty() and initialized and provider.is_ready("rewarded")
func request_reward(reward: String,user_initiated: bool) -> bool:
	if not user_initiated or reward!="revive_once" or not can_offer_reward():return false
	pending_reward=reward
	if not _try_show("rewarded"):
		pending_reward=""
		return false
	return true
func _try_show(format: String) -> bool:
	if in_round or active_token!=0 or not block_reason(format).is_empty():return false
	if not initialized or not provider.is_ready(format):return false
	sequence+=1
	active_token=sequence
	active_format=format
	active_revision=privacy.revision
	reward_claimed=false
	busy_seconds=0.0
	if not provider.show(format,active_token):
		_cancel_pending()
		return false
	return true
func _on_reward_earned(token: int):
	if token!=active_token or active_token==0 or active_format!="rewarded":return
	if reward_claimed or pending_reward.is_empty() or in_round:return
	if active_revision!=privacy.revision or not block_reason("rewarded").is_empty():return
	reward_claimed=true
	reward_used_this_round=true
	reward_validated.emit(pending_reward)
func _on_closed(format: String,token: int):
	if token!=active_token or format!=active_format:return
	_cancel_pending()
	ad_finished.emit()
func _on_failed(format: String,token: int,reason: String):
	last_error=reason
	if token!=0 and token==active_token and format==active_format:
		_cancel_pending()
		ad_finished.emit()
	availability_changed.emit()
func _cancel_pending():
	active_token=0
	active_format=""
	pending_reward=""
	reward_claimed=false
	busy_seconds=0.0
func set_age_group(value: String):
	privacy.set_age_group(value)
	privacy.save_local()
	_revoke()
func opt_out():
	privacy.ads_opt_out=true
	privacy.invalidate()
	privacy.save_local()
	_revoke()
func _revoke():
	_cancel_pending()
	initialized=false
	provider.revoke_and_clear()
	privacy_changed.emit()
	availability_changed.emit()
func open_privacy_options() -> bool:
	# No pretend consent form: current APK has no UMP SDK.
	if not config.enabled or not config.native_integration_verified or not provider.is_native:return false
	return provider.show_privacy_options()
func _on_privacy_updated(can_request_ads: bool,legal_basis_reviewed: bool):
	_cancel_pending()
	privacy.invalidate()
	privacy.session_can_request_ads=can_request_ads
	privacy.session_legal_basis_reviewed=legal_basis_reviewed
	# User opt-out is independent; UMP callbacks must never override it silently.
	initialized=false
	provider.revoke_and_clear()
	privacy_changed.emit()
func set_banner_visible(visible: bool):
	if not visible or in_round or not block_reason("banner").is_empty():
		provider.hide_banner()
		return
	# Provider.show accepts banner only after an explicit safe menu placement exists.
	_try_show("banner")
