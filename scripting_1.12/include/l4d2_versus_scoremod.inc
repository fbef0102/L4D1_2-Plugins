#if defined _l4d2_versus_scoremod
	#endinput
#endif
#define _l4d2_versus_scoremod

native int L4D2VS_GetHealthBonus();
native int L4D2VS_GetDamageBonus();
native int L4D2VS_GetPillsBonus();
native int L4D2VS_GetAdrenalinesBonus();
native int L4D2VS_GetKitsBonus();

native int L4D2VS_GetMaxHealthBonus();
native int L4D2VS_GetMaxDamageBonus();
native int L4D2VS_GetMaxPillsBonus();
native int L4D2VS_GetMaxAdrenalinesBonus();
native int L4D2VS_GetMaxKitsBonus();

public SharedPlugin __pl_l4d2_versus_scoremod =
{
	name = "l4d2_versus_scoremod",
	file = "l4d2_versus_scoremod.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_versus_scoremod_SetNTVOptional()
{
	MarkNativeAsOptional("L4D2VS_GetHealthBonus");
	MarkNativeAsOptional("L4D2VS_GetDamageBonus");
	MarkNativeAsOptional("L4D2VS_GetPillsBonus");
	MarkNativeAsOptional("L4D2VS_GetAdrenalinesBonus");
	MarkNativeAsOptional("L4D2VS_GetKitsBonus");

	MarkNativeAsOptional("L4D2VS_GetMaxHealthBonus");
	MarkNativeAsOptional("L4D2VS_GetMaxDamageBonus");
	MarkNativeAsOptional("L4D2VS_GetMaxPillsBonus");
	MarkNativeAsOptional("L4D2VS_GetMaxAdrenalinesBonus");
	MarkNativeAsOptional("L4D2VS_GetMaxKitsBonus");
}
#endif
