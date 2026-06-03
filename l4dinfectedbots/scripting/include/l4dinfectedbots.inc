#if defined _l4dinfectedbots_included
 #endinput
#endif
#define _l4dinfectedbots_included

/**
 * Query integer configuration values from l4dinfectedbots plugin's current settings.
 *
 * @param key    Configuration key name (see list below)
 * @return       Integer value of the config key, or -1 with error on unknown key.
 *
 * Supported keys (int):
 *   "smoker_limit", "boomer_limit", "hunter_limit", "spitter_limit",
 *   "jockey_limit", "charger_limit", "max_specials", "max_specials_tank_including",
 *   "smoker_weight", "boomer_weight", "hunter_weight", "spitter_weight",
 *   "jockey_weight", "charger_weight", "scale_weights",
 *   "smoker_health", "boomer_health", "hunter_health", "spitter_health",
 *   "jockey_health", "charger_health",
 *   "tank_limit", "tank_limit_override", "tank_spawn_probability",
 *   "tank_health", "tank_spawn_final",
 *   "witch_max_limit", "witch_spawn_final",
 *   "spawn_same_frame", "spawn_safe_zone", "spawn_where_method",
 *   "spawn_disable_bots", "tank_disable_spawn", "coordination",
 *   "coop_versus_enable", "coop_versus_tank_playable", "coop_versus_announce",
 *   "coop_versus_human_limit", "coop_versus_human_light", "coop_versus_human_ghost"
 */
native int L4DInfectedBots_GetConfigInt(const char[] key);

/**
 * Query float configuration values from l4dinfectedbots plugin's current settings.
 *
 * @param key    Configuration key name (see list below)
 * @return       Float value of the config key, or 0.0 with error on unknown key.
 *
 * Supported keys (float):
 *   "spawn_time_min", "spawn_time_max", "initial_spawn_time", "life",
 *   "spawn_range_min", "spawn_time_increase_on_human_infected",
 *   "witch_spawn_time_min", "witch_spawn_time_max", "witch_life",
 *   "coop_versus_spawn_time_min", "coop_versus_spawn_time_max",
 *   "coop_versus_cool_down"
 */
native float L4DInfectedBots_GetConfigFloat(const char[] key);

/**
 * Query string configuration values from l4dinfectedbots plugin's current settings.
 *
 * @param key    Configuration key name
 * @param value  Buffer to store the string value
 * @param maxlen Maximum length of the buffer
 * @return       1 on success, 0 on error (unknown key or key is not a string)
 *
 * Supported keys (string):
 *   "coop_versus_join_access"
 */
native int L4DInfectedBots_GetConfigString(const char[] key, char[] value, int maxlen);

/**
 * Do not edit below this line
 */
public SharedPlugin __pl_l4dinfectedbots =
{
	name = "l4dinfectedbots",
	file = "l4dinfectedbots.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4dinfectedbots_SetNTVOptional()
{
	MarkNativeAsOptional("L4DInfectedBots_GetConfigInt");
	MarkNativeAsOptional("L4DInfectedBots_GetConfigFloat");
	MarkNativeAsOptional("L4DInfectedBots_GetConfigString");
}
#endif
