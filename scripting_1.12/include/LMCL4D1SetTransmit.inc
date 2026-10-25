/*
*	
*	LMC_L4D2_SetTransmit() module "LMCL4D2SetTransmit" required to use native, Library is called "LMCL4D2SetTransmit"
*	
*	https://github.com/LuxLuma/Luxs-Model-Changer
*/

#if defined _LMCL4D1SetTransmit_included
#endinput
#endif
#define _LMCL4D1SetTransmit_included

#define LMCL4D1SetTransmit_version "1.0"

/**
*	Unhook/hook LMC's SetTransmit in LMCL4D1SetTransmit module
*	
*	@param iClient		Client index owner of the iEntity 
*	@param iEntity		Entity to hook/unhook
*	@param Unhook/hook	True to HookEntity, false to Unhook entity
*	@no return
*/
native bool LMC_L4D1_SetTransmit(int iClient, int iEntity, bool HookAction=true);

public SharedPlugin __pl_LMCL4D1SetTransmit = 
{
	name = "LMCL4D1SetTransmit",
	file = "LMCL4D1SetTransmit.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_LMCL4D1SetTransmit_SetNTVOptional()
{
	MarkNativeAsOptional("LMC_L4D1_SetTransmit");
}
#endif