#if defined  _l4d_transition_forward_included_
 #endinput
#endif
#define _l4d_transition_forward_included_

public SharedPlugin __pl_l4d_transition_forward =
{
	name = "l4d_transition_forward",
	file = "l4d_transition_forward.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

/**
 * @brief Called when weapons are transitioned and restored from previous map (Post)
 * @note This will be called after the level-transitioning
 * @note This will be called once the level failed and restarted.
 * 
 * @param oldindex   		old entity index in last map
 * @param strClassSize      new entity index
 *
 * @noreturn
 */
/**
 * @Translate 中文說明
 * @brief 當遊戲恢復上一關的武器與物資時呼叫此涵式
 * @note 過關之後恢復上一關物品時觸發
 * @note 滅團之後重來恢復上一關物品時也會觸發
 *  
 * @param oldindex   		上一關的entity索引
 * @param strClassSize      新的entity索引
 * 
 * @noreturn
*/
forward void OnEntityTransitioned (int oldindex, int newindex); 
