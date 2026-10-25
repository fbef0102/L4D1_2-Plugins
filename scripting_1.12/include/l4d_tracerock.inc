#if defined  _l4d_tracerock_included_
 #endinput
#endif
#define _l4d_tracerock_included_

/**
* @brief Called whenever tank already threw the trace rock
*
* @param tank			tank client index
* @param rock			the rock entity index
*
* @noreturn
*/
forward void L4D_OnTraceRockCreated(int tank, int rock);

public SharedPlugin __pl_l4d_tracerock =
{
	name = "l4d_tracerock",
	file = "l4d_tracerock.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_tracerock_SetNTVOptional()
{
	
}
#endif