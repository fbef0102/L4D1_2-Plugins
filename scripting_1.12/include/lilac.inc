#if defined  _lilac_included_
 #endinput
#endif
#define _lilac_included_

/* In case anyone wants to change this later on in a pull request or whatever,
 * DON'T DON'T DON'T DON'T DON'T DON'T DON'T DON'T DON'T DON'T DON'T!!!
 * ...  DON'T...
 * These values cannot be changed due to forwards,
 *     changing them will cause issues for other plugins.
 * You can add new stuff, but not change the number of anything here. */

enum /*Lilac_DetectionType*/
{
	CHEAT_ANGLES 			= 0,
	CHEAT_CHATCLEAR         = 1,
	CHEAT_CONVAR            = 2,
	CHEAT_NOLERP            = 3,
	CHEAT_BHOP              = 4,
	CHEAT_AIMBOT            = 5,
	CHEAT_AIMLOCK           = 6,
	CHEAT_ANTI_DUCK_DELAY   = 7,
	CHEAT_NOISEMAKER_SPAM   = 8,
	CHEAT_MACRO             = 9,/* Macros aren't actually cheats, but are forwarded as such. */
	CHEAT_NEWLINE_NAME      = 10,
	CHEAT_MAX               = 11,
}

/**
 * @brief Called when plugin is about to detect if client is cheating (Pre-hook)
 * 
 * @param client		Client index
 * @param cheat			The Lilac Detection Type, check lilac.inc to see Lilac_DetectionType list
 * 
 * @return				Plugin_Handled to block detection on this client, Plugin_Continue otherwise
 */
forward Action lilac_allow_cheat_detection(int client, int cheat)

/**
 * @brief Called when plugin is about to detect if client is cheating (Post-hook)
 * @remarks This forward will not trigger if the relative pre-hook forward has been blocked with Plugin_Handled
 * 
 * @param client		Client index
 * @param type			The Lilac DetectionType, check lilac.inc to see Lilac_DetectionType list
 * 
 * @noreturn
 */
forward void lilac_cheater_detected(int client, int cheat);

/**
 * @brief Called when client is about to be banned by lilac
 * 
 * @param client		Client index
 * @param type			The Lilac DetectionType, check lilac.inc to see Lilac_DetectionType list
 * 
 * @noreturn
 */
forward void lilac_cheater_banned(int client, int cheat);

public SharedPlugin __pl_lilac =
{
	name = "lilac",
	file = "lilac.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_lilac_SetNTVOptional()
{
	
}
#endif