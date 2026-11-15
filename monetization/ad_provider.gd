extends Node
## Native adapter contract. The shipped implementation never initializes an SDK.
## A future adapter must apply request policy BEFORE native initialization/loading,
## disable automatic native startup/ID collection, refresh UMP and normalize callbacks.
signal loaded(format: String)
signal failed(format: String, token: int, reason: String)
signal closed(format: String, token: int)
signal reward_earned(token: int)
signal privacy_updated(can_request_ads: bool, legal_basis_reviewed: bool)
var is_native = false
func configure_policy(_policy: Dictionary): pass
func initialize(_platform_ids: Dictionary) -> bool: return false
func load_ad(format: String): failed.emit(format,0,"native_adapter_not_installed")
func is_ready(_format: String) -> bool: return false
func show(_format: String,_token: int) -> bool: return false
func show_privacy_options() -> bool: return false
func revoke_and_clear(): pass
func hide_banner(): pass
