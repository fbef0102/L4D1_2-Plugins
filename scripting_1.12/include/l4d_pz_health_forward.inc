#if defined _l4d_pz_health_forward_included_
	#endinput
#endif
#define _l4d_pz_health_forward_included_

/**
 * @brief Called when a player zombie spawns.
 * @note Dispatched in "CTerrorPlayer::SetClass" post detour callback.
 * @remarks Use entity prop "m_iHealth" to retrieve current health.
 * 
 * @param client			PZ client index
 * @param zombieclass		PZ class
 * @param zspawncmd			Spawned via "z_spawn*" command
 * @param health			Player HP
 * @param maxHealth			Player max HP
 * @param healthMult		Player HP multiplier
 * @param maxHealthMult		Player max HP multiplier
 * 
 * @noreturn
 */
forward void L4D_OnPZSpawnHealth(int client, int zombieclass, bool zspawncmd, int &health, int &maxHealth, float &healthMult, float &maxHealthMult);

/**
 * @brief Called when a far-away player zombie respawns via "E" .
 * @note Dispatched in "CTerrorPlayer::SetClass" post detour callback.
 * @remarks Use entity prop "m_iHealth" to retrieve current health.
 * @note Max health is restored to default by the game.
 * 
 * @param client			PZ client index
 * @param zombieclass		PZ class
 * @param prevhealth		PZ health before respawn
 * @param health			Player HP
 * @param maxHealth			Player max HP
 * @param healthMult		Player HP multiplier
 * @param maxHealthMult		Player max HP multiplier
 * 
 * @noreturn
 */
forward void L4D_OnPZRespawnHealth(int client, int zombieclass, int &health, int &maxHealth, float &healthMult, float &maxHealthMult);



public SharedPlugin __pl_l4d_pz_health_forward = 
{
	name = "l4d_pz_health_forward",
	file = "l4d_pz_health_forward.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};