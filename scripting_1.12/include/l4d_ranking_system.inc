#if defined  _l4d_ranking_system_included_
 #endinput
#endif
#define _l4d_ranking_system_included_

public SharedPlugin __pl_l4d_ranking_system =
{
	name = "l4d_ranking_system",
	file = "l4d_ranking_system.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_ranking_system_SetNTVOptional()
{
	MarkNativeAsOptional("Rank_System_GetRankTitle");
}
#endif

/**
 * Get Rank Title for client
 * 
 * @param client	Client to get rank title
 * @param str       String to store rank title.
 * @param size      size of String to store.
 * 
 * @return		   True if suceed, false if not
 */
native bool Rank_System_GetRankTitle(int client, char[] str, int size);