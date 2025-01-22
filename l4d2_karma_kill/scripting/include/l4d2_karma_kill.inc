#if defined  _l4d2_karma_kill_included_
 #endinput
#endif
#define _l4d2_karma_kill_included_


/**
 * Description
 *
 * @param victim             Muse that was honored to model a karma event
 * @param attacker           Artist that crafted the karma event. The only way to check if attacker is valid is: if(attacker > 0)
 * @param KarmaName          Name of karma: "Charge", "Impact", "Jockey", "Slap", "Punch", "Smoke"
 * @param bBird              true if a bird charge event occured, false if a karma kill was detected or performed.
 * @param bKillConfirmed     Whether or not this indicates the complete death of the player. This is NOT just !IsPlayerAlive(victim)
 * @param bOnlyConfirmed     Whether or not only kill confirmed are allowed.
 *
 * @noreturn
 * @note					This can be called more than once. One for the announcement, one for the kill confirmed.
 *                          If you want to reward both killconfirmed and killunconfirmed you should reward when killconfirmed is false.
 *                          If you want to reward if killconfirmed you should reward when killconfirmed is true.
 *
 * @note					If the plugin makes a kill confirmed without a previous announcement without kill confirmed,
 *                          it compensates by sending two consecutive events, one without kill confirmed, one with kill confirmed.
 */
forward void KarmaKillSystem_OnKarmaEventPost(int victim, int attacker, const char[] KarmaName, bool bBird, bool bKillConfirmed, bool bOnlyConfirmed);

/**
 * Description
 *
 * @param victim             Player who got killed by the karma event. This can be anybody. Useful to revive the victim.
 * @param attacker           Artist that crafted the karma event. The only way to check if attacker is valid is: if(attacker > 0)
 * @param KarmaName          Name of karma: "Charge", "Impact", "Jockey", "Slap", "Punch", "Smoke", "Jump"
 * @param lastPos            Origin from which the jump began.
 * @param jumperWeapons		 Weapon Refs of the jumper at the moment of the jump. Every invalid slot is -1
 * @param jumperHealth    	 jumperHealth[0] and jumperHealth[1] = Health and Temp health from which the jump began.
 * @param jumperTimestamp    Timestamp from which the jump began.
 * @param jumperSteamId      jumper's Steam ID.
 * @param jumperName     	 jumper's name
 *
 * @note					 Some values may be exclusive to karma jumps, but all values needed to respawn the player are guaranteed to be there in every karma.
 * @noreturn
 *
 */
forward void KarmaKillSystem_OnRPGKarmaEventPost(int victim, int attacker, const char[] KarmaName, float lastPos[3], int jumperWeapons[64], int jumperHealth[2], float jumperTimestamp, char[] jumperSteamId, char[] jumperName);


/**
 * Description
 *
 * @param victim             Player who got killed by the karma jump. This can be anybody. Useful to revive the victim.
 * @param lastPos            Origin from which the jump began.
 * @param jumperWeapons		 Weapon Refs of the jumper at the moment of the jump. Every invalid slot is -1
 * @param jumperHealth    	 jumperHealth[0] and jumperHealth[1] = Health and Temp health from which the jump began.
 * @param jumperTimestamp    Timestamp from which the jump began.
 * @param jumperSteamId      jumper's Steam ID.
 * @param jumperName     	 jumper's name
 *
 * @noreturn
 *
 */
forward void KarmaKillSystem_OnKarmaJumpPost(int victim, float lastPos[3], int jumperWeapons[64], int jumperHealth[2], float jumperTimestamp, char[] jumperSteamId, char[] jumperName);


public SharedPlugin __pl_l4d2_karma_kill =
{
	name = "l4d2_karma_kill",
	file = "l4d2_karma_kill.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_karma_kill_SetNTVOptional()
{

}
#endif