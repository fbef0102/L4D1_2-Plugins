/*
*	If you wish to have EntityDeathHandler to manager entity(not clients) ragdolls you should require the library "LMCL4D2EDeathHandler"
*	LMC_OnClientDeathModelCreated module is required to get forwarded, Library is called "LMCL4D2CDeathHandler"
*	
*	
*	https://github.com/LuxLuma/Luxs-Model-Changer
*/

#if defined _LMCL4D2CDeathHandler_included
#endinput
#endif
#define _LMCL4D2CDeathHandler_included

#define LMCL4D2CDeathHandler_include_version "1.0.1"

/**
*	@Note only called if LMCL4D2CDeathHandler module is installed
*	
*	Deathmodels are "survivor_death_model" that can be used with defibrillator.
*	
*	@param 	iClient		Client Index who died.
*	@param 	iEntity		Entity Index of Deathmodel for client who died
*	@param	iOverlayModel 	Entity Index of Deathmodel overlaymodel -1 if don't exist
*	@no return
*/
forward void LMC_OnClientDeathModelCreated(int iClient, int iDeathModel, int iOverlayModel);

public SharedPlugin __pl_LMCL4D2CDeathHandler  =
{
    name = "LMCL4D2CDeathHandler",
    file = "LMCL4D2CDeathHandler.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};
