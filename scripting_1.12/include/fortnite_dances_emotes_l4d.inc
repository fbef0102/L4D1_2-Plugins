#if defined  _fortnite_dances_emotes_l4d_included_
 #endinput
#endif
#define _fortnite_dances_emotes_l4d_included_

/* Natives */

/**
 * Checks client's dance status
 *
 * @param client    Client index
 * @return          True if is danceing, false otherwise
 */
native bool fortnite_dances_emotes_l4d_IsClientEmoting(int client);

/**
 * @brief When a client is about to do the dance
 *
 * @param client    Client index
 * 
 * @return				Plugin_Handled to block the target player from doing the dance, Plugin_Continue otherwise
 */
forward Action fortnite_dances_emotes_l4d_OnEmote_Pre(int client);

/**
 * @brief When a client starts to do the dance
 * @remarks This forward will not trigger if the relative pre-hook forward has been blocked with Plugin_Handled
 *
 * @param client    Client index
 */
forward void fortnite_dances_emotes_l4d_OnEmote_Post(int client);

/**
 * @brief When a client ends the dance
 *
 * @param client    Client index
 */
forward void fortnite_dances_emotes_l4d_OnEnd(int client);

public SharedPlugin __pl_fortnite_dances_emotes_l4d =
{
	name = "fortnite_dances_emotes_l4d",
	file = "fortnite_dances_emotes_l4d.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_fortnite_dances_emotes_l4d_SetNTVOptional()
{
	MarkNativeAsOptional("fortnite_dances_emotes_l4d_IsClientEmoting");
}
#endif