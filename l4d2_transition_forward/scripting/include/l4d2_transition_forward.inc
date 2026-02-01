#if defined  _l4d2_transition_forward_included_
 #endinput
#endif
#define _l4d2_transition_forward_included_

public SharedPlugin __pl_l4d2_transition_forward =
{
	name = "l4d2_transition_forward",
	file = "l4d2_transition_forward.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

/**
 * @brief Called when player inventory weapons are about to be saved.
 * @remarks Called before the event "map_transition"
 * @remarks Held items also trigger (e.g. weapon_gascan, weapon_gnome etc)
 * 
 * @param client		client index
 * @param entity		Transitioning entity index
 *
 * @noreturn
 */
/**
 * @Translate 中文說明
 * @brief 當遊戲即將保存玩家攜帶的武器與物資時呼叫此涵式
 * @remarks 在事件"map_transition"之前
 * @remarks 手持物品也會觸發 (如: 汽油、瓦斯桶等)
 *  
 * @param client		玩家索引
 * @param entity		entity索引
 * 
 * @noreturn
*/
forward void L4D2_OnInventoryWeaponTransitioning(int player, int entity);

/**
 * @brief Called when player inventory weapons are transitioned and restored from previous map (Post)
 * @note This will be called after the level-transitioning
 * @note This will be called once the level failed and restarted.
 * @remarks Held items also trigger (e.g. weapon_gascan, weapon_gnome etc)
 * 
 * @param newindex      	new entity index
 * @param oldindex   		old entity index in last map
 *
 * @noreturn
 */
/**
 * @Translate 中文說明
 * @brief 當遊戲恢復玩家上一關攜帶的武器與物資時呼叫此涵式
 * @note 過關之後恢復玩家上一關物品時觸發
 * @note 滅團之後重來恢復玩家上一關物品時也會觸發
 * @remarks 手持物品也會觸發 (如: 汽油、瓦斯桶等)
 *  
 * @param newindex      	新的entity索引
 * @param oldindex   		上一關的entity索引
 * 
 * @noreturn
*/
forward void L4D2_OnInventoryWeaponTransitioned(int newindex, int oldindex); 
