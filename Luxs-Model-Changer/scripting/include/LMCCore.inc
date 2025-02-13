/*
*	LMCCore Library is called "LMCCore" (Deprecated lib name is "L4D2ModelChanger")
*	for anyone looking to do a dynamic use of LMC
*	
*	https://github.com/LuxLuma/Luxs-Model-Changer
*	
*	if you plan on using deprecated functions you will need to use an olderbuild from before 2.0.3
*	https://github.com/LuxLuma/Luxs-Model-Changer/releases
*	
*	
*	Library Names:				Plugin Names:					Info:
*	"LMCCore"					(LMCCore.smx)					Core of LMC
*	"LMCCDeathHandler"			(LMCCDeathHandler.smx)			Handles client deathmodels and ragdolls
*	"LMCEDeathHandler"			(LMCEDeathHandler.smx)			Handles entity ragdolls
*	"LMCL4D2SetTransmit"		(LMCL4D2SetTransmit.smx)		Handles L4D2 SetTransmitting
*/


#if defined _LMCCore_included
#endinput
#endif
#define _LMCCore_included


#define LMCCore_version "3.1.1"


/**
*   @note Entity Overlays have different array from Client overlays
*
*   @param  iEntity     Entity Index Gets entity model overlay
*   @return             Entity Index, -1 on invalid.
*/
native int LMC_GetEntityOverlayModel(int iEntity);

/**
*   @note Don't use this on Clients because it would not hide the model in Firstperson and is less securty for Clients if used.
*
*   @param  iEntity     Entity Index.
*   @param  sModel      Model Path of the model you wish to apply.
*   @return             Overlay Model index, -1 on unable create.
*/
native int LMC_SetEntityOverlayModel(int iEntity, const char[] sModel);

/**
*   @param  iClient     Client Index.
*   @return             Entity Index, -1 on invalid.
*/
native int LMC_GetClientOverlayModel(int iClient);

/**
*	@note should call LMC_L4D2_SetTransmit() after this if you wish it to be SetTransmitted
*	
*   @param  iClient						Client Index.
*   @param  sModel						Model Path of the model you wish to apply.
*   @return								Overlay Model index, -1 on unable create.
*/
native int LMC_SetClientOverlayModel(int iClient, const char[] sModel);

/**
*	Reset's entity's rendermode and Entity(colour) back to default(able to see)
*	
*	@param iClient	Client Index
*	@no return
*/
native void LMC_ResetRenderMode(int iClient);

/**
*   @note this is called instead of LMC_OnClientModelApplied if the overlay model already exists.
*
*   @param  iClient     Client Index.
*   @param  iEntity     Entity Reference, of OverlayModel
*   @param  sModel      Model Path Of Entity.
*   @no return
*/
forward void LMC_OnClientModelChanged(int iClient, int iEntity, const char sModel[PLATFORM_MAX_PATH]);

/**
*   @Note This is Called Instead of LMC_OnClientModelChanged if overlaymodel entity does not exist.
*   @Note This will be called if the base model is change(Client model) to stop messed up bones clientside, if you don't wan't this to be called Prevent the model from changing.
*
*   @param  iClient         Client Index.
*   @param  iEntity         Entity Index, of OverlayModel
*   @param  sModel          Model Path Of Entity.
*   @param  bBaseReattach   Was model reattach true if so, false otherwise(When the basemodel is changed to remove any clientside errors of missplaced bones)
*   @no return
*/
forward void LMC_OnClientModelApplied(int iClient, int iEntity, const char sModel[PLATFORM_MAX_PATH], bool bBaseReattach);

/**
*   @note This is Only called for Client models not for entity models
*
*   @param  iClient     Client Index who had the model.
*   @param  iEntity     Entity Index of OverlayModel
*   @no return
*/
forward void LMC_OnClientModelDestroyed(int iClient, int iEntity);

/**
*   @note Used for in-line string translation.
*
*   @param  iClient     Client Index, translation is apllied to.
*   @param  format      String formatting rules. By default, you should pass at least "%t" specifier.
*   @param  ...			Variable number of format parameters.
*   @return char[192]	Resulting string. Note: output buffer is hardly limited.
*/
stock char[] LMC_Translate(int iClient, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(iClient);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}

/**
*   @note Used for in-line string translation.
*
*   @param  iClient     Client Index, translation is apllied to.
*   @param  format      String formatting rules. By default, you should pass at least "%t" specifier.
*   @param  ...			Variable number of format parameters.
*   @return char[192]	Resulting string. Note: output buffer is hardly limited.
*/
stock char[] LMC_TranslateNoColor(int iClient, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(iClient);
	VFormat(buffer, sizeof(buffer), format, 3);
	LMC_RemoveColor(buffer, sizeof(buffer));
	return buffer;
}

/**
*   @note Prints a message to a specific client in the chat area. Supports named colors in translation file.
*
*   @param  iClient     Client Index.
*   @param  format		Formatting rules.
*   @param  ...			Variable number of format parameters.
*   @no return
*/
stock void LMC_CPrintToChat(int iClient, const char[] format, any ...)
{
    char buffer[192];
    SetGlobalTransTarget(iClient);
    VFormat(buffer, sizeof(buffer), format, 3);
    LMC_ReplaceColor(buffer, sizeof(buffer));
    PrintToChat(iClient, "\x01%s", buffer);
}

/**
*   @note Prints a message to all clients in the chat area. Supports named colors in translation file.
*
*   @param  format		Formatting rules.
*   @param  ...			Variable number of format parameters.
*   @no return
*/
stock void LMC_CPrintToChatAll(const char[] format, any ...)
{
    char buffer[192];
    for( int i = 1; i <= MaxClients; i++ )
    {
        if( IsClientInGame(i) && !IsFakeClient(i) )
        {
            SetGlobalTransTarget(i);
            VFormat(buffer, sizeof(buffer), format, 2);
            LMC_ReplaceColor(buffer, sizeof(buffer));
            PrintToChat(i, "\x01%s", buffer);
        }
    }
}

/**
*   @note Converts named color to control character. Used internally by string translation functions.
*
*   @param  char[]		Input/Output string for convertion.
*   @param  maxLen		Maximum length of string buffer (includes NULL terminator).
*   @no return
*/
stock void LMC_ReplaceColor(char[] message, int maxLen)
{
    ReplaceString(message, maxLen, "{white}", "\x01", false);
    ReplaceString(message, maxLen, "{cyan}", "\x03", false);
    ReplaceString(message, maxLen, "{orange}", "\x04", false);
    ReplaceString(message, maxLen, "{green}", "\x05", false);
}

/**
* @note Removes named color to empty string. Used internally by string translation functions.
*
*   @param  char[]		Input/Output string for convertion.
*   @param  maxLen		Maximum length of string buffer (includes NULL terminator).
*   @no return
*/
stock void LMC_RemoveColor(char[] message, int maxLen)
{
    ReplaceString(message, maxLen, "{white}", "", false);
    ReplaceString(message, maxLen, "{cyan}", "", false);
    ReplaceString(message, maxLen, "{orange}", "", false);
    ReplaceString(message, maxLen, "{green}", "", false);
}

/**
*   @note Prints a hint message to all clients. Supports individual string translation for each client.
*
*   @param  format		Formatting rules.
*   @param  ...			Variable number of format parameters.
*   @no return
*/
stock void LMC_CPrintHintTextToAll(const char[] format, any ...)
{
    char buffer[192];
    for( int i = 1; i <= MaxClients; i++ )
    {
        if( IsClientInGame(i) && !IsFakeClient(i) )
        {
            SetGlobalTransTarget(i);
            VFormat(buffer, sizeof(buffer), format, 2);
            PrintHintText(i, buffer);
        }
    }
}

/**
*   @note Prints a center screen message to all clients. Supports individual string translation for each client.
*
*   @param  format		Formatting rules.
*   @param  ...			Variable number of format parameters.
*   @no return
*/
stock void LMC_CPrintCenterTextAll(const char[] format, any ...)
{
    char buffer[192];
    for( int i = 1; i <= MaxClients; i++ )
    {
        if( IsClientInGame(i) && !IsFakeClient(i) )
        {
            SetGlobalTransTarget(i);
            VFormat(buffer, sizeof(buffer), format, 2);
            PrintCenterText(i, buffer);
        }
    }
}

//https://github.com/alliedmodders/hl2sdk/blob/0ef5d3d482157bc0bb3aafd37c08961373f87bfd/public/const.h#L281-L298
// entity effects
enum
{
	EF_BONEMERGE			= 0x001,	// Performs bone merge on client side
	EF_BRIGHTLIGHT 			= 0x002,	// DLIGHT centered at entity origin
	EF_DIMLIGHT 			= 0x004,	// player flashlight
	EF_NOINTERP				= 0x008,	// don't interpolate the next frame
	EF_NOSHADOW				= 0x010,	// Don't cast no shadow
	EF_NODRAW				= 0x020,	// don't draw entity
	EF_NORECEIVESHADOW		= 0x040,	// Don't receive no shadow
	EF_BONEMERGE_FASTCULL	= 0x080,	// For use with EF_BONEMERGE. If this is set, then it places this ent's origin at its
										// parent and uses the parent's bbox + the max extents of the aiment.
										// Otherwise, it sets up the parent's bones every frame to figure out where to place
										// the aiment, which is inefficient because it'll setup the parent's bones even if
										// the parent is not in the PVS.
	EF_ITEM_BLINK			= 0x100,	// blink an item so that the user notices it.
	EF_PARENT_ANIMATES		= 0x200,	// always assume that the parent entity is animating
	EF_MAX_BITS = 10
};

/*
*	Recreated "SetAttached" entity input from "prop_dynamic_ornament"
*/
stock void SetAttached(int iEntToAttach, int iEntToAttachTo)
{
	SetVariantString("!activator");
	AcceptEntityInput(iEntToAttach, "SetParent", iEntToAttachTo);
	
	SetEntityMoveType(iEntToAttach, MOVETYPE_NONE);
	
	SetEntProp(iEntToAttach, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES);
	
	//thanks smlib for flag understanding
	int iFlags = GetEntProp(iEntToAttach, Prop_Data, "m_usSolidFlags", 2);
	iFlags = iFlags |= 0x0004;
	SetEntProp(iEntToAttach, Prop_Data, "m_usSolidFlags", iFlags, 2);
	
	TeleportEntity(iEntToAttach, view_as<float>({0.0, 0.0, 0.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
}

/*
*	Recreated "Detach" entity input from "prop_dynamic_ornament"
*	I have not included the EF_NODRAW effect flag, unlike the input
*/
stock void Detach(int iEntity)
{
	AcceptEntityInput(iEntity, "ClearParent");
	
	//thanks smlib for flag understanding
	int iFlags = GetEntProp(iEntity, Prop_Data, "m_usSolidFlags", 2);
	iFlags = iFlags |= 0x0004;
	SetEntProp(iEntity, Prop_Data, "m_usSolidFlags", iFlags, 2);
	
	SetEntityMoveType(iEntity, MOVETYPE_NONE);
}









/**
*   Deprecated function will thorw error from LMC_Core if called.
*
*   Show and Hide Client overlay models.
*   Note@If client changes model with menu that could effect the hidden toggle.
*
*   @param  iClient     Client Index
*   @param  bHide       true = hide \ false = unhide (toggle effect)
*   @return true        If action was successful false othewise.
*/
#pragma deprecated no longer used since 2.0.3
native bool LMC_HideClientOverlayModel(int iEntity, bool bHide);


/**
*   Deprecated forward will not be called in version 2.0.3+
*
*   before Cookie saving and cvar checks
*   @note block this will not save the model the client has selected and cookie wont be updated.
*   @note LMC_OnClientModelAppliedPre wont be called if changing model here.
*   @note LMC_OnClientModelApplied will be called using this forward.
*
*   This Can not be blocked by plugin (unless LMC is modified)
*
*   @param  iClient     Client Index.
*   @param  sModel      return Plugin_Changed Model Path to change model
*   @return Plugin_Handled/Plugin_Stop to block, Plugin_Changed to change model to sModel
*/
#pragma deprecated no longer used since 2.0.3
forward Action LMC_OnClientModelSelected(int iClient, char sModel[PLATFORM_MAX_PATH]);

enum LMCModelType
{
	LMCModelType_NoModel = 1,
	LMCModelType_WitchNormal,
	LMCModelType_WitchBride,
	LMCModelType_InfectedBoomer,
	LMCModelType_InfectedBoomette,
	LMCModelType_InfectedHunter,
	LMCModelType_InfectedSmoker,
	LMCModelType_InfectedRiotcop,
	LMCModelType_InfectedMudman,
	LMCModelType_NPCPilot,
	LMCModelType_InfectedCeda,
	LMCModelType_InfectedClown,
	LMCModelType_InfectedJimmyGibs,
	LMCModelType_InfectedFallenSurvivor,
	LMCModelType_InfectedRandomCommon,
	LMCModelType_SurvivorNick,
	LMCModelType_SurvivorRochelle,
	LMCModelType_SurvivorCoach,
	LMCModelType_SurvivorEllis,
	LMCModelType_SurvivorBill,
	LMCModelType_SurvivorZoey,
	LMCModelType_SurvivorFrancis,
	LMCModelType_SurvivorLouis,
	LMCModelType_InfectedTank,
	LMCModelType_InfectedTankDLC3,
}

/**
*   Deprecated forward will not be called in version 2.0.3+
*
*   Before LMC_OnClientModelApplied but after LMC_OnModelSelected
*   @note Cookie will have already besaved and won't effect and model won't be saved for next respawn.
*   You can only Set models  that are already defined in l4d2modelchanger use LMC_OnModelSelected
*   to use other models.
*
*   @note this will obey cvars set in l4d2modelchanger use LMC_OnModelSelected to change to any model
*
*   @param  iClient     Client Index.
*   @param  iModelType  ModelIndex  Refer to LMCModelType enum
*   @return Plugin_Handled/Plugin_Stop to block, Plugin_Changed to change model Index
*/
#pragma deprecated no longer used since 2.0.3
forward Action LMC_OnClientModelAppliedPre(int iClient, LMCModelType &iModel);

public SharedPlugin __pl_LMCCore = 
{
	name = "LMCCore",
	file = "LMCCore.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_LMCCore_SetNTVOptional()
{
	MarkNativeAsOptional("LMC_GetEntityOverlayModel");
	MarkNativeAsOptional("LMC_SetEntityOverlayModel");
	MarkNativeAsOptional("LMC_GetClientOverlayModel");
	MarkNativeAsOptional("LMC_SetClientOverlayModel");
	MarkNativeAsOptional("LMC_ResetRenderMode");
	MarkNativeAsOptional("LMC_HideClientOverlayModel");
}
#endif
