#if defined _l4d2_block_no_steam_logon_included
    #endinput
#endif
#define _l4d2_block_no_steam_logon_included

enum EAuthSessionResponse
{
    Response_OK = 0,    // everything is fine.
    Response_UnknownError = 1,  // also steam no logon?
    Response_NotOwnThisGame = 2,
    Response_VACBanned = 3,
    Response_InAnotherLocation = 4,
    Response_TimedOut = 5,
    Response_UnknownError2 = 6, // also steam no logon?
    Response_UnknownError3 = 7, // also steam no logon?
    Response_NoSteamLogon = 8,
}

/**
 * Called when the game tries to validate an auth ticket response.
 * 
 * @param sName - name of the client.
 * @param response - response from steam. should be a bad response.
 * 
 * @noreturn
*/
forward void OnValidateAuthTicketResponseHelper(EAuthSessionResponse response, const char[] sName);

public SharedPlugin __pl_l4d2_block_no_steam_logon =
{
	name = "l4d2_block_no_steam_logon",
	file = "l4d2_block_no_steam_logon.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};