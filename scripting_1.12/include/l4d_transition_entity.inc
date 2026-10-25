#if defined _l4d_transition_entity_included_
	#endinput
#endif
#define _l4d_transition_entity_included_

/**
 * @brief Called when "info_changelevel" is about to save entities.
 * @note Called before event "map_transition".
 * @note Not called in versus mode.
 * 
 * @param info_changelevel		Transition performer.
 *
 * @noreturn
 */
forward void L4D_OnBeginSaveEntities(int info_changelevel);

/**
 * @brief Called when an entity is checked to be saved or not for next map.
 * @note Has no effect on entities that are not weapons, weapon spawns or "prop_physics".
 * @note Not called in versus mode.
 * 
 * @param entity		Entity index
 * @param save			Save result
 *
 * @return Plugin_Changed to override save result, Plugin_Continue otherwise.
 */
forward Action L4D_OnEntitySaveable(int entity, bool &save);

/**
 * @brief Called when a weapon/spawner/prop in checkpoint is being saved for next level.
 * @remarks For player inventory see "L4D_OnPlayerItemTransitioning".
 * @note Called before event "map_transition".
 * @note Not called in versus mode.
 * 
 * @param entity		Transitioning entity index
 *
 * @noreturn
 */
forward void L4D_OnEntityTransitioning(int entity);

/**
 * @brief Called when a weapon/spawner/prop is restored from the previous level (Post-spawned).
 * @remarks For player inventory see "L4D_OnPlayerItemTransitioned".
 * @remarks Always called after level transitions or restarts except in versus mode.
 * @note Chance that the entity is marked for deletion if for some reason something bad happens during restore.
 * @note Not called in versus mode.
 * 
 * @param entity		New entity index
 * @param oldindex		Old entity index in last level
 *
 * @noreturn
 */
forward void L4D_OnEntityTransitioned(int entity, int oldindex);

/**
 * @brief Called when a humen/bot survivor's info is being saved for next level.
 * @remarks Called after event "map_transition".
 * @note Called also in versus mode.
 * 
 * @param client		Transitioning client index
 *
 * @noreturn
 */
forward void L4D_OnPlayerTransitioning(int client);

/**
 * @brief Called when a humen/bot survivor's info is restored from the previous level (Post-spawned).
 * @remarks Always called after level transitions or restarts except in versus mode.
 * @note For survivor bots, their player name might not be correct.
 * @note For infected, the player might not be alive at the moment.
 * @note Use a delay to avoid conflicts setting "m_bIsOnThirdStrike" and health (Healing Gnome Mode).
 * @note Called for survivor bots in versus mode, but will not restore any inventory.
 * @note (L4D2) for 4+ survivors the info might not belong to this client.
 * 
 * @param client		New client index
 * @param oldindex		Client index saved in last level
 * @param olduserid		Client userID saved in last level
 *
 * @noreturn
 */
forward void L4D_OnPlayerTransitioned(int client, int oldindex, int olduserid);

/**
 * @brief Called when a humen/bot survivor's item is being saved for next level.
 * @remarks Called after event "map_transition".
 * 
 * @param client		Weapon owner index
 * @param weapon		Transitioning weapon index
 *
 * @noreturn
 */
forward void L4D_OnPlayerItemTransitioning(int client, int weapon);

/**
 * @brief Called when a humen/bot survivor's item is restored from the previous level (Post-spawned).
 * @remarks Always called after level transitions or restarts except in versus mode.
 * @note For secondary weapon it might have been marked for deletion if the player has a hidden secondary weapon.
 * @note (L4D2) for 4+ survivors the info might not belong to this client.
 * 
 * @param client		Weapon owner index
 * @param weapon		New weapon index
 * @param oldindex		Weapon index saved in last level
 *
 * @noreturn
 */
forward void L4D_OnPlayerItemTransitioned(int client, int weapon, int oldindex);

/**
 * @brief Called when a humen/bot survivor's item from the previous level is spawned (Before equipped by player).
 * @remarks Always called after level transitions or restarts except in versus mode.
 * @note For secondary weapon it might have been marked for deletion if the player has a hidden secondary weapon.
 * @note (L4D2) for 4+ survivors the info might not belong to this client.
 * 
 * @param client		Weapon owner index
 * @param weapon		New weapon index
 * @param oldindex		Weapon index saved in last level
 *
 * @noreturn
 */
forward void L4D_OnPlayerItemTransitionSpawned(int client, int weapon, int oldindex);


public SharedPlugin __pl_l4d_transition_entity = 
{
	name = "l4d_transition_entity",
	file = "l4d_transition_entity.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_transition_entity_SetNTVOptional()
{
}
#endif
