#if defined _l4d_CreateSurvivorBot_included
 #endinput
#endif
#define _l4d_CreateSurvivorBot_included

/**
 * Try to spawn a survivor bot without limit
 * 
 * Note: If not enough player slots, it will fail to spawn
 *
 * @return				Client index of bot or -1 on failure
 */
native int CreateSurvivorBot();

public SharedPlugin __pl_shope =
{
	name = "l4d_CreateSurvivorBot",
	file = "l4d_CreateSurvivorBot.smx",
	#if defined REQUIRE_PLUGIN
	required = 1
	#else
	required = 0
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_CreateSurvivorBot_SetNTVOptional()
{
	MarkNativeAsOptional("CreateSurvivorBot");
}
#endif