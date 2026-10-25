#if defined  _l4d2_vote_change_included_
 #endinput
#endif
#define _l4d2_vote_change_included_

/**
 * @brief Display menu to client
 * 
 * @param index			Client index	
 * @param menu			Menu type, 1=Main Vote, 2=Difficulty, 3=Custom Vote, check source code for more
 */
native void l4d2_vote_change_Menu(int client, int menu)


public SharedPlugin __pl_l4d2_vote_change =
{
	name = "l4d2_vote_change",
	file = "l4d2_vote_change.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_vote_change_SetNTVOptional()
{
	MarkNativeAsOptional("l4d2_vote_change_Menu");
}
#endif