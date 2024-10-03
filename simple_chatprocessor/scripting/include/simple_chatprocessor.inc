#if defined _simple_chatprocessor_included
  #endinput
#endif
#define _simple_chatprocessor_included

#define MAXLENGTH_INPUT				128 	// Inclues \0 and is the size of the chat input box.
#define MAXLENGTH_NAME				64		// This is backwords math to get compability.  Sourcemod has it set at 32, but there is room for more.
#define MAXLENGTH_MESSAGE			256		// This is based upon the SDK and the length of the entire message, including tags, name, : etc.

#define CHATFLAGS_INVALID			0
#define CHATFLAGS_ALL				(1<<0)
#define CHATFLAGS_TEAM				(1<<1)
#define CHATFLAGS_SPEC				(1<<2)
#define CHATFLAGS_DEAD				(1<<3)

/**
 * When a player types a chat message
 *
 * NOTES:
 * OnChatMessage is not working anymore, Use instead OnChatMessage2
 *
 * @param 		author						The client index of the player who sent the chat message (Byref)
 * @param 		recipients					The handle to the client index adt array of the players who should recieve the chat message
 * @param 		name						The client's name of the player who sent the chat message (Byref)
 * @param 		message						The contents of the chat message (Byref)
 * @return									Plugin_Stop to block chat message, Plugin_Changed to use overwritten values from plugin, Plugin_Continue otherwise
 */
#pragma deprecated Use this instead: OnChatMessage2(int originalAuthor, int &author, ArrayList recipients, char[] name, int maxlength_name, char[] message, int maxlength_message);
forward Action OnChatMessage(int &author, ArrayList recipients, char[] name, char[] message);

/**
 * Called after all OnChatMessage forwards have been fired and the message is being broadcast.
 *
 * NOTES:
 * Use MAXLENGTH_  constants above for formating the strings
 * Do not rely on the recipients handle to exist beyond the forward
 * OnChatMessage_Post is not working anymore, Use instead: OnChatMessage2_Post
 *
 * @param 		author						The client index of the player who sent the chat message
 * @param 		recipients					The handle to the client index adt array of the players who are receiting the chat message
 * @param 		name						The client's name of the player who sent the chat message (after any replacements)
 * @param 		message						The contents of the chat message (after any replacements)
 * 
 * @noreturn
 */
#pragma deprecated Use this instead: OnChatMessage2_Post(int originalAuthor, int author, ArrayList recipients, const char[] name, const char[] message);
forward void OnChatMessage_Post(int author, ArrayList recipients, const char[] name, const char[] message);

/**
 * When a player types a chat message
 *
 * NOTES:
 * Use MAXLENGTH_  constants above for formating the strings
 * Do not rely on the recipients handle to exist beyond the forward
 * Do not start another usermessage (PrintToChat) within this forward
 *
 * @param 		originalAuthor				The real client index of the player who sent the chat message
 * @param 		author						The client index of the player who speaks for the original author. (Byref)
 * 												Modify if necessary, For example, to use different colors from another team 
 * @param 		recipients					The handle to the client index adt array of the players who should recieve the chat message
 * @param 		name						The client's name of the player who sent the chat message (Byref)
 * @param 		maxlength_name				Maximum length of name string to store to
 * @param 		message						The contents of the chat message (after any replacements)
 * @param 		maxlength_message			Maximum length of message string to store to
 * 
 * @return									Plugin_Stop to block chat message, Plugin_Changed to use overwritten values from plugin, Plugin_Continue otherwise
 */
forward Action OnChatMessage2(int originalAuthor, int &author, ArrayList recipients, char[] name, int maxlength_name, char[] message, int maxlength_message);

/**
 * Called after all OnChatMessage2 forwards have been fired and the message is being broadcast.
 * @remarks This forward will not trigger if the relative pre-hook forward has been blocked with Plugin_Stop

 * NOTES:
 * Use MAXLENGTH_  constants above for formating the strings
 * Do not rely on the recipients handle to exist beyond the forward
 *
 * @param 		originalAuthor				The real client index of the player who sent the chat message
 * @param 		author						The client index of the player who speaks for the original author.
 * 												Modify if necessary, For example, to use different colors from another team 
 * @param 		recipients					The handle to the client index adt array of the players who are receiting the chat message
 * @param 		name						The client's name of the player who sent the chat message (after any replacements)
 * @param 		message						The contents of the chat message (after any replacements)
 * 
 * @noreturn
 */
forward void OnChatMessage2_Post(int originalAuthor, int author, ArrayList recipients, const char[] name, const char[] message);


/**
 * Gets the current flags for the chat message
 * Should only be called within OnChatMessage2() or OnChatMessage2_Post()
 *
 * @return		The current type of chat message (see constants) 
 */
native int GetMessageFlags();

 
 
/**
Shared plugin information
**/
public SharedPlugin __pl_scp = {
	name = "simple_chatprocessor",
	file = "simple_chatprocessor.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_simple_chatprocessor_SetNTVOptional()
{
	MarkNativeAsOptional("GetMessageFlags");
}
#endif