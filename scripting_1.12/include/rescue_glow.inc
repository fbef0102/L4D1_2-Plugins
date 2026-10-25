#if defined _rescue_glow_included
 #endinput
#endif
#define _rescue_glow_included

public SharedPlugin __pl_rescue_glow = 
{
    name = "rescue_glow",
    file = "rescue_glow.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_rescue_glow_SetNTVOptional()
{
    MarkNativeAsOptional("RescueGlow_HasGlow");
}
#endif

/**
 * @brief check if a client has set the rescue glow
 *
 * @param client        client index
 *
 * @return	true if is
 *
 */
native bool RescueGlow_HasGlow(int client);

/**
 * @brief Called when added a rescue glow
 *
 * @param client		client index
 *
 * @noreturn
 */
forward void RescueGlow_OnAdded(int client);

/**
 * @brief Called when removed a rescue glow
 *
 * @param client		client index
 *
 * @noreturn
 */
forward void RescueGlow_OnRemoved(int client);