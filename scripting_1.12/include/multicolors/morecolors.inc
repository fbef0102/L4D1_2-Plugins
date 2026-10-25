// MOAR COLORS
// By Dr. McKay
// Inspired by: https://forums.alliedmods.net/showthread.php?t=96831

#if defined _more_colors_included
 #endinput
#endif
#define _more_colors_included

#pragma newdecls optional

#define MORE_COLORS_VERSION     "3.0.0-MC"
#define MC_MAX_MESSAGE_LENGTH   256
#define MAX_BUFFER_LENGTH       (MC_MAX_MESSAGE_LENGTH * 4)
#define MAX_COLOR_TAG_LENGTH    32
#define COLOR_HASH_SIZE         512 // 512 slots for ~172 colors = 34% load factor (optimal performance, minimal collisions)

#define MCOLOR_RED              0xFF4040
#define MCOLOR_BLUE             0x99CCFF
#define MCOLOR_GRAY             0xCCCCCC
#define MCOLOR_GREEN            0x3EFF3E

#define MC_GAME_DODS           0

bool MC_SkipList[MAXPLAYERS+1];
int MC_TeamColors[][] = {{0xCCCCCC, 0x4D7942, 0xFF4040}}; // Multi-dimensional array for games that don't support SayText2. First index is the game index (as defined by the GAME_ defines), second index is team. 0 = spectator, 1 = team1, 2 = team2
char g_sColorKeys[COLOR_HASH_SIZE][32];
char g_sColorValues[COLOR_HASH_SIZE][16];
static int g_iColorHash[COLOR_HASH_SIZE];
static int g_iColorCount = 0;

static ConVar sm_show_activity;

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags.
 *
 * @param client		Client index.
 * @param message		Message (formatting rules).
 *
 * On error/Errors:		If the client is not connected an error will be thrown.
 */
stock void MC_PrintToChat(int client, const char[] message, any ...) {
	MC_InitFastColors();

	if (client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}

	if (!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}

	char buffer[MAX_BUFFER_LENGTH];
	char buffer2[MAX_BUFFER_LENGTH];

	SetGlobalTransTarget(client);
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 3);

	MC_ReplaceColorCodes(buffer2);
	MC_SendMessage(client, buffer2);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags.
 *
 * @param client		Client index.
 * @param message		Message (formatting rules).
 */
stock void MC_PrintToChatAll(const char[] message, any ...) {
	MC_InitFastColors();

	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];

	for (int i = 1; i <= MaxClients; ++i) {
		if (!IsClientInGame(i) || MC_SkipList[i]) {
			MC_SkipList[i] = false;
			continue;
		}

		SetGlobalTransTarget(i);
		Format(buffer, sizeof(buffer), "\x01%s", message);
		VFormat(buffer2, sizeof(buffer2), buffer, 2);

		MC_ReplaceColorCodes(buffer2);
		MC_SendMessage(i, buffer2);
	}
}

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param client		Client index.
 * @param author		Author index whose color will be used for teamcolor tag.
 * @param message		Message (formatting rules).
 *
 * On error/Errors:		If the client or author are not connected an error will be thrown
 */
stock void MC_PrintToChatEx(int client, int author, const char[] message, any ...) {
	MC_InitFastColors();

	if (client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}

	if (!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}

	if (author < 0 || author > MaxClients) {
		ThrowError("Invalid client index %i", author);
	}

	if ((author != 0) && !IsClientInGame(author)) {
		ThrowError("Client %i is not in game", author);
	}

	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 4);
	MC_ReplaceColorCodes(buffer2, author);
	MC_SendMessage(client, buffer2, author);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param author	  Author index whose color will be used for teamcolor tag.
 * @param message   Message (formatting rules).
 *
 * On error/Errors:   If the author is not connected an error will be thrown.
 */
stock void MC_PrintToChatAllEx(int author, const char[] message, any ...) {
	MC_InitFastColors();

	if (author < 0 || author > MaxClients) {
		ThrowError("Invalid client index %i", author);
	}

	if ((author != 0) && !IsClientInGame(author)) {
		ThrowError("Client %i is not in game", author);
	}

	char buffer[MAX_BUFFER_LENGTH];
	char buffer2[MAX_BUFFER_LENGTH];

	for (int i = 1; i <= MaxClients; ++i) {
		if (!IsClientInGame(i) || MC_SkipList[i]) {
			MC_SkipList[i] = false;
			continue;
		}

		SetGlobalTransTarget(i);
		Format(buffer, sizeof(buffer), "\x01%s", message);
		VFormat(buffer2, sizeof(buffer2), buffer, 3);

		MC_ReplaceColorCodes(buffer2, author);
		MC_SendMessage(i, buffer2, author);
	}
}

/**
 * Sends a SayText2 usermessage
 *
 * @param client	Client to send usermessage to
 * @param message	Message to send
 */
stock void MC_SendMessage(int client, const char[] message, int author = 0) {
	if (author == 0) {
		author = client;
	}

	char buffer[MC_MAX_MESSAGE_LENGTH];
	strcopy(buffer, sizeof(buffer), message);

	UserMsg index = GetUserMessageId("SayText2");
	if (index == INVALID_MESSAGE_ID) {
		if (GetEngineVersion() == Engine_DODS) {
			int team = GetClientTeam(author);
			if (team == 0) {
				ReplaceString(buffer, sizeof(buffer), "\x03", "\x04", false); // Unassigned gets green
			}
			else {
				char temp[16];
				Format(temp, sizeof(temp), "\x07%06X", MC_TeamColors[MC_GAME_DODS][team - 1]);
				ReplaceString(buffer, sizeof(buffer), "\x03", temp, false);
			}
		}

		PrintToChat(client, "%s", buffer);
		return;
	}

	Handle buf = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) {
		Protobuf pb = UserMessageToProtobuf(buf);
		pb.SetInt("ent_idx", author);
		pb.SetBool("chat", true);
		pb.SetString("msg_name", buffer);
		pb.AddString("params", "");
		pb.AddString("params", "");
		pb.AddString("params", "");
		pb.AddString("params", "");
	}
	else {
		BfWrite bf = UserMessageToBfWrite(buf);
		bf.WriteByte(author); // Message author
		bf.WriteByte(true); // Chat message
		bf.WriteString(buffer); // Message text
	}

	EndMessage();
}

/**
 * This function should only be used right in front of
 * MC_PrintToChatAll or MC_PrintToChatAllEx. It causes those functions
 * to skip the specified client when printing the message.
 * After printing the message, the client will no longer be skipped.
 *
 * @param client   Client index
 */
stock void MC_SkipNextClient(int client) {
	if (client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}

	MC_SkipList[client] = true;
}

/**
 * Replaces color tags in a string with color codes (used internally by MC_PrintToChat, MC_PrintToChatAll, MC_PrintToChatEx, and MC_PrintToChatAllEx
 *
 * @param buffer		String.
 * @param author		Optional client index to use for {teamcolor} tags, or 0 for none
 * @param removeTags	Optional boolean value to determine whether we're replacing tags with colors, or just removing tags, used by MC_RemoveTags
 * @param maxlen		Optional value for max buffer length, used by MC_RemoveTags
 *
 * On error/Errors:		If the client index passed for author is invalid or not in game.
 */
stock void MC_ReplaceColorCodes(char[] buffer, int author = 0, bool removeTags = false, int maxlen = MAX_BUFFER_LENGTH) {
	MC_InitFastColors();
	if (!removeTags) {
		MC_FastReplaceString(buffer, maxlen, "{default}", "\x01");

		if (author != 0) {
			if (author < 0 || author > MaxClients) {
				ThrowError("Invalid client index %i", author);
			}

			if (!IsClientInGame(author)) {
				ThrowError("Client %i is not in game", author);
			}

			MC_FastReplaceString(buffer, maxlen, "{teamcolor}", "\x03");
		}
	}
	else {
		MC_FastReplaceString(buffer, maxlen, "{default}", "");
		MC_FastReplaceString(buffer, maxlen, "{teamcolor}", "");
	}

	int outPos = 0;
	int len = strlen(buffer);
	int i = 0;

	char sOutputBuffer[MAX_BUFFER_LENGTH];
	char sTempTag[32];

	while (i < len && outPos < maxlen - 16) {
		if (buffer[i] == '{') {
			int start = i + 1;
			int end = -1;

			// Find closing brace
			for (int j = start; j < len && j < start + MAX_COLOR_TAG_LENGTH; j++) {
				if (buffer[j] == '}') {
					end = j;
					break;
				}
			}

			if (end != -1) {
				int tagLen = end - start;

				// Extract tag
				int copyLen = (tagLen < 31) ? tagLen : 31;
				for (int k = 0; k < copyLen; k++) {
					sTempTag[k] = buffer[start + k];
				}
				sTempTag[copyLen] = '\0';

				MC_StrToLower(sTempTag);

				char value[16];
				bool found = false;

				// Handle hex colors
				if (sTempTag[0] == '#' && (tagLen == 7 || tagLen == 9)) {
					if (tagLen == 7) {
						value[0] = '\x07';
						strcopy(value[1], 9, sTempTag[1]);
					} else {
						value[0] = '\x08';
						strcopy(value[1], 9, sTempTag[1]);
					}
					found = true;
				} else {
					found = MC_FastGetColor(sTempTag, value, sizeof(value));
				}

				if (found && !removeTags) {
					// Copy color code directly
					int valLen = strlen(value);
					for (int k = 0; k < valLen && outPos < maxlen - 1; k++) {
						sOutputBuffer[outPos++] = value[k];
					}
					i = end + 1;
					continue;
				} else if (removeTags) {
					i = end + 1;
					continue;
				}
			}
		}

		sOutputBuffer[outPos++] = buffer[i++];
	}

	sOutputBuffer[outPos] = '\0';
	strcopy(buffer, maxlen, sOutputBuffer);
}

/**
 * Gets a part of a string
 *
 * @param input			String to get the part from
 * @param output		Buffer to write to
 * @param maxlen		Max length of output buffer
 * @param start			Position to start at
 * @param numChars		Number of characters to return, or 0 for the end of the string
 */
stock void CSubString(const char[] input, char[] output, int maxlen, int start, int numChars = 0) {
	int i = 0;
	for (;;) {
		if (i == maxlen - 1 || i >= numChars || input[start + i] == '\0') {
			output[i] = '\0';
			return;
		}

		output[i] = input[start + i];
		i++;
	}
}

/**
 * Converts a string to lowercase
 *
 * @param buffer		String to convert
 */
stock void MC_StrToLower(char[] buffer) {
	for (int i = 0; buffer[i]; i++) {
		if (buffer[i] >= 'A' && buffer[i] <= 'Z') {
			buffer[i] |= 0x20;
		}
	}
}

/**
 * Adds a color to the colors hash table
 *
 * @param name			Color name, without braces
 * @param color			Hexadecimal representation of the color (0xRRGGBB)
 * @return				True if color was added successfully, false if a color already exists with that name
 */
stock bool MC_AddColor(const char[] name, int color) {
	MC_InitFastColors();

	char value[16];
	char newName[64];
	strcopy(newName, sizeof(newName), name);
	MC_StrToLower(newName);

	if (MC_FastGetColor(newName, value, sizeof(value))) {
		return false;
	}

	char colorValue[16];
	Format(colorValue, sizeof(colorValue), "\x07%06X", color);
	MC_FastSetColor(newName, colorValue);
	return true;
}

/**
 * Removes color tags from a message
 *
 * @param message		Message to remove tags from
 * @param maxlen		Maximum buffer length
 */
stock void MC_RemoveTags(char[] message, int maxlen) {
	MC_ReplaceColorCodes(message, 0, true, maxlen);
}

/**
 * Replies to a command with colors
 *
 * @param client		Client to reply to
 * @param message		Message (formatting rules)
 */
stock void MC_ReplyToCommand(int client, const char[] message, any ...) {
	char buffer[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), message, 3);

	if (client == 0) {
		MC_RemoveTags(buffer, sizeof(buffer));
		PrintToServer("%s", buffer);
	}
	else if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE) {
		MC_RemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "%s", buffer);
	}
	else {
		MC_PrintToChat(client, "%s", buffer);
	}
}

/**
 * Replies to a command with colors
 *
 * @param client		Client to reply to
 * @param author		Client to use for {teamcolor}
 * @param message		Message (formatting rules)
 */
stock void MC_ReplyToCommandEx(int client, int author, const char[] message, any ...) {
	char buffer[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), message, 4);

	if (client == 0) {
		MC_RemoveTags(buffer, sizeof(buffer));
		PrintToServer("%s", buffer);
	}
	else if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE) {
		MC_RemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "%s", buffer);
	}
	else {
		MC_PrintToChatEx(client, author, "%s", buffer);
	}
}

/**
 * Displays usage of an admin command to users depending on the
 * setting of the sm_show_activity cvar.
 *
 * This version does not display a message to the originating client
 * if used from chat triggers or menus.  If manual replies are used
 * for these cases, then this function will suffice.  Otherwise,
 * MC_ShowActivity2() is slightly more useful.
 * Supports color tags.
 *
 * @param client		Client index doing the action, or 0 for server.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @error
 */
stock int MC_ShowActivity(int client, const char[] format, any ...) {
	if (sm_show_activity == null) {
		sm_show_activity = FindConVar("sm_show_activity");
	}

	char tag[] = "[SM] ";

	char szBuffer[MC_MAX_MESSAGE_LENGTH];
	//char szCMessage[MC_MAX_MESSAGE_LENGTH];
	int value = sm_show_activity.IntValue;
	ReplySource replyto = GetCmdReplySource();

	char name[MAX_NAME_LENGTH] = "Console";
	char sign[MAX_NAME_LENGTH] = "ADMIN";
	bool display_in_chat = false;
	if (client != 0) {
		if (client < 0 || client > MaxClients || !IsClientConnected(client))
			ThrowError("Client index %d is invalid", client);

		GetClientName(client, name, sizeof(name));
		AdminId id = GetUserAdmin(client);
		if (id == INVALID_ADMIN_ID || !id.HasFlag(Admin_Generic, Access_Effective)) {
			sign = "PLAYER";
		}

		/* Display the message to the client? */
		if (replyto == SM_REPLY_TO_CONSOLE) {
			SetGlobalTransTarget(client);
			VFormat(szBuffer, sizeof(szBuffer), format, 3);

			MC_RemoveTags(szBuffer, sizeof(szBuffer));
			PrintToConsole(client, "%s%s", tag, szBuffer);
			display_in_chat = true;
		}
	}
	else {
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 3);

		MC_RemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s", tag, szBuffer);
	}

	if (!value) {
		return 1;
	}

	for (int i = 1; i <= MaxClients; ++i) {
		if (!IsClientInGame(i) || IsFakeClient(i) || (display_in_chat && i == client)) {
			continue;
		}

		AdminId id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID || !id.HasFlag(Admin_Generic, Access_Effective)) {
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2)) {
				char newsign[MAX_NAME_LENGTH];

				if ((value & 2) || (i == client)) {
					newsign = name;
				}
				else {
					newsign = sign;
				}

				VFormat(szBuffer, sizeof(szBuffer), format, 3);

				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else {
			/* Treat this as an admin user */
			bool is_root = id.HasFlag(Admin_Root, Access_Effective);
			if ((value & 4) || (value & 8) || ((value & 16) && is_root)) {
				char newsign[MAX_NAME_LENGTH];

				if ((value & 8) || ((value & 16) && is_root) || (i == client)) {
					newsign = name;
				}
				else {
					newsign = sign;
				}

				VFormat(szBuffer, sizeof(szBuffer), format, 3);

				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
	}

	return 1;
}

/**
 * Same as MC_ShowActivity(), except the tag parameter is used instead of "[SM] " (note that you must supply any spacing).
 * Supports color tags.
 *
 * @param client		Client index doing the action, or 0 for server.
 * @param tags			Tag to display with.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @error
 */
stock int MC_ShowActivityEx(int client, const char[] tag, const char[] format, any ...) {
	if (sm_show_activity == null) {
		sm_show_activity = FindConVar("sm_show_activity");
	}

	char szTag[MC_MAX_MESSAGE_LENGTH];
	strcopy(szTag, sizeof(szTag), tag);
	MC_RemoveTags(szTag, sizeof(szTag));

	char szBuffer[MC_MAX_MESSAGE_LENGTH];
	//char szCMessage[MC_MAX_MESSAGE_LENGTH];
	int value = sm_show_activity.IntValue;
	ReplySource replyto = GetCmdReplySource();

	char name[MAX_NAME_LENGTH] = "Console";
	char sign[MAX_NAME_LENGTH] = "ADMIN";
	bool display_in_chat = false;
	if (client != 0) {
		if (client < 0 || client > MaxClients || !IsClientConnected(client)) {
			ThrowError("Client index %d is invalid", client);
		}

		GetClientName(client, name, sizeof(name));
		AdminId id = GetUserAdmin(client);
		if (id == INVALID_ADMIN_ID || !id.HasFlag(Admin_Generic, Access_Effective)) {
			sign = "PLAYER";
		}

		/* Display the message to the client? */
		if (replyto == SM_REPLY_TO_CONSOLE) {
			SetGlobalTransTarget(client);
			VFormat(szBuffer, sizeof(szBuffer), format, 4);

			MC_RemoveTags(szBuffer, sizeof(szBuffer));
			PrintToConsole(client, "%s%s", szTag, szBuffer);
			display_in_chat = true;
		}
	}
	else {
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 4);

		MC_RemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s", szTag, szBuffer);
	}

	if (!value) {
		return 1;
	}

	for (int i = 1; i <= MaxClients; ++i) {
		if (!IsClientInGame(i) || IsFakeClient(i) || (display_in_chat && i == client)) {
			continue;
		}

		AdminId id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID || !id.HasFlag(Admin_Generic, Access_Effective)) {
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2)) {
				char newsign[MAX_NAME_LENGTH];

				if ((value & 2) || (i == client)) {
					newsign = name;
				}
				else {
					newsign = sign;
				}

				VFormat(szBuffer, sizeof(szBuffer), format, 4);

				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else {
			/* Treat this as an admin user */
			bool is_root = id.HasFlag(Admin_Root, Access_Effective);
			if ((value & 4) || (value & 8) || ((value & 16) && is_root)) {
				char newsign[MAX_NAME_LENGTH];

				if ((value & 8) || ((value & 16) && is_root) || (i == client)) {
					newsign = name;
				}
				else {
					newsign = sign;
				}

				VFormat(szBuffer, sizeof(szBuffer), format, 4);

				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
	}

	return 1;
}

/**
 * Displays usage of an admin command to users depending on the setting of the sm_show_activity cvar.
 * All users receive a message in their chat text, except for the originating client,
 * who receives the message based on the current ReplySource.
 * Supports color tags.
 *
 * @param client		Client index doing the action, or 0 for server.
 * @param tags			Tag to prepend to the message.
 * @param format		Formatting rules.
 * @param ...			Variable number of format parameters.
 * @error
 */
stock int MC_ShowActivity2(int client, const char[] tag, const char[] format, any ...) {
	if (sm_show_activity == null) {
		sm_show_activity = FindConVar("sm_show_activity");
	}

	char szTag[MC_MAX_MESSAGE_LENGTH];
	strcopy(szTag, sizeof(szTag), tag);
	MC_RemoveTags(szTag, sizeof(szTag));

	char szBuffer[MC_MAX_MESSAGE_LENGTH];
	//char szCMessage[MC_MAX_MESSAGE_LENGTH];
	int value = sm_show_activity.IntValue;
	// ReplySource replyto = GetCmdReplySource();

	char name[MAX_NAME_LENGTH] = "Console";
	char sign[MAX_NAME_LENGTH] = "ADMIN";

	if (client != 0) {
		if (client < 0 || client > MaxClients || !IsClientConnected(client)) {
			ThrowError("Client index %d is invalid", client);
		}

		GetClientName(client, name, sizeof(name));

		AdminId id = GetUserAdmin(client);
		if (id == INVALID_ADMIN_ID || !id.HasFlag(Admin_Generic, Access_Effective)) {
			sign = "PLAYER";
		}

		SetGlobalTransTarget(client);
		VFormat(szBuffer, sizeof(szBuffer), format, 4);

		/* We don't display directly to the console because the chat text
		 * simply gets added to the console, so we don't want it to print
		 * twice.
		 */
		MC_PrintToChatEx(client, client, "%s%s", szTag, szBuffer);
	}
	else {
		SetGlobalTransTarget(LANG_SERVER);
		VFormat(szBuffer, sizeof(szBuffer), format, 4);

		MC_RemoveTags(szBuffer, sizeof(szBuffer));
		PrintToServer("%s%s", szTag, szBuffer);
	}

	if (!value) {
		return 1;
	}

	for (int i = 1; i <= MaxClients; ++i) {
		if (!IsClientInGame(i) || IsFakeClient(i) || i == client) {
			continue;
		}

		AdminId id = GetUserAdmin(i);
		SetGlobalTransTarget(i);
		if (id == INVALID_ADMIN_ID || !id.HasFlag(Admin_Generic, Access_Effective)) {
			/* Treat this as a normal user. */
			if ((value & 1) | (value & 2)) {
				char newsign[MAX_NAME_LENGTH];

				if ((value & 2)) {
					newsign = name;
				}
				else {
					newsign = sign;
				}

				VFormat(szBuffer, sizeof(szBuffer), format, 4);

				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
		else {
			/* Treat this as an admin user */
			bool is_root = id.HasFlag(Admin_Root, Access_Effective);
			if ((value & 4) || (value & 8) || ((value & 16) && is_root)) {
				char newsign[MAX_NAME_LENGTH];


				if ((value & 8) || ((value & 16) && is_root)) {
					newsign = name;
				}
				else {
					newsign = sign;
				}

				VFormat(szBuffer, sizeof(szBuffer), format, 4);

				MC_PrintToChatEx(i, client, "%s%s: %s", tag, newsign, szBuffer);
			}
		}
	}

	return 1;
}

/**
 * Determines whether a color name exists
 *
 * @param color			The color name to check
 * @return				True if the color exists, false otherwise
 */
stock bool CColorExists(const char[] color) {
	MC_InitFastColors();
	char temp[16];
	char colorName[64];
	strcopy(colorName, sizeof(colorName), color);
	MC_StrToLower(colorName);
	return MC_FastGetColor(colorName, temp, sizeof(temp));
}

/**
 * Returns the hexadecimal representation of a client's team color (will initialize the hash table if needed)
 *
 * @param client		Client to get the team color for
 * @return				Client's team color in hexadecimal, or green if unknown
 * On error/Errors:		If the client index passed is invalid or not in game.
 */
stock int CGetTeamColor(int client) {
	if (client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}

	if (!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}

	MC_InitFastColors();

	int value;
	switch(GetClientTeam(client)) {
		case 1: {
			value = MCOLOR_GRAY;
		}
		case 2: {
			value = MCOLOR_RED;
		}
		case 3: {
			value = MCOLOR_BLUE;
		}
		default: {
			value = MCOLOR_GREEN;
		}
	}

	return value;
}

stock void MC_InitFastColors() {
	if (g_iColorCount > 0)
		return;

	MC_FastSetColor("aliceblue", "\x07F0F8FF");
	MC_FastSetColor("allies", "\x074D7942"); // same as Allies team in DoD:S
	MC_FastSetColor("ancient", "\x07EB4B4B"); // same as Ancient item rarity in Dota 2
	MC_FastSetColor("antiquewhite", "\x07FAEBD7");
	MC_FastSetColor("aqua", "\x0700FFFF");
	MC_FastSetColor("aquamarine", "\x077FFFD4");
	MC_FastSetColor("arcana", "\x07ADE55C"); // same as Arcana item rarity in Dota 2
	MC_FastSetColor("axis", "\x07FF4040"); // same as Axis team in DoD:S
	MC_FastSetColor("azure", "\x07007FFF");
	MC_FastSetColor("beige", "\x07F5F5DC");
	MC_FastSetColor("bisque", "\x07FFE4C4");
	MC_FastSetColor("black", "\x07000000");
	MC_FastSetColor("blanchedalmond", "\x07FFEBCD");
	MC_FastSetColor("blue", "\x0799CCFF"); // same as BLU/Counter-Terrorist team color
	MC_FastSetColor("blueviolet", "\x078A2BE2");
	MC_FastSetColor("brown", "\x07A52A2A");
	MC_FastSetColor("burlywood", "\x07DEB887");
	MC_FastSetColor("cadetblue", "\x075F9EA0");
	MC_FastSetColor("chartreuse", "\x077FFF00");
	MC_FastSetColor("chocolate", "\x07D2691E");
	MC_FastSetColor("collectors", "\x07AA0000"); // same as Collector's item quality in TF2
	MC_FastSetColor("common", "\x07B0C3D9"); // same as Common item rarity in Dota 2
	MC_FastSetColor("community", "\x0770B04A"); // same as Community item quality in TF2
	MC_FastSetColor("coral", "\x07FF7F50");
	MC_FastSetColor("cornflowerblue", "\x076495ED");
	MC_FastSetColor("cornsilk", "\x07FFF8DC");
	MC_FastSetColor("corrupted", "\x07A32C2E"); // same as Corrupted item quality in Dota 2
	MC_FastSetColor("crimson", "\x07DC143C");
	MC_FastSetColor("cyan", "\x0700FFFF");
	MC_FastSetColor("darkblue", "\x0700008B");
	MC_FastSetColor("darkcyan", "\x07008B8B");
	MC_FastSetColor("darkgoldenrod", "\x07B8860B");
	MC_FastSetColor("darkgray", "\x07A9A9A9");
	MC_FastSetColor("darkgrey", "\x07A9A9A9");
	MC_FastSetColor("darkgreen", "\x07006400");
	MC_FastSetColor("darkkhaki", "\x07BDB76B");
	MC_FastSetColor("darkmagenta", "\x078B008B");
	MC_FastSetColor("darkolivegreen", "\x07556B2F");
	MC_FastSetColor("darkorange", "\x07FF8C00");
	MC_FastSetColor("darkorchid", "\x079932CC");
	MC_FastSetColor("darkred", "\x078B0000");
	MC_FastSetColor("darksalmon", "\x07E9967A");
	MC_FastSetColor("darkseagreen", "\x078FBC8F");
	MC_FastSetColor("darkslateblue", "\x07483D8B");
	MC_FastSetColor("darkslategray", "\x072F4F4F");
	MC_FastSetColor("darkslategrey", "\x072F4F4F");
	MC_FastSetColor("darkturquoise", "\x0700CED1");
	MC_FastSetColor("darkviolet", "\x079400D3");
	MC_FastSetColor("deeppink", "\x07FF1493");
	MC_FastSetColor("deepskyblue", "\x0700BFFF");
	MC_FastSetColor("dimgray", "\x07696969");
	MC_FastSetColor("dimgrey", "\x07696969");
	MC_FastSetColor("dodgerblue", "\x071E90FF");
	MC_FastSetColor("exalted", "\x07CCCCCD"); // same as Exalted item quality in Dota 2
	MC_FastSetColor("firebrick", "\x07B22222");
	MC_FastSetColor("floralwhite", "\x07FFFAF0");
	MC_FastSetColor("forestgreen", "\x07228B22");
	MC_FastSetColor("frozen", "\x074983B3"); // same as Frozen item quality in Dota 2
	MC_FastSetColor("fuchsia", "\x07FF00FF");
	MC_FastSetColor("fullblue", "\x070000FF");
	MC_FastSetColor("fullred", "\x07FF0000");
	MC_FastSetColor("gainsboro", "\x07DCDCDC");
	MC_FastSetColor("genuine", "\x074D7455"); // same as Genuine item quality in TF2
	MC_FastSetColor("ghostwhite", "\x07F8F8FF");
	MC_FastSetColor("gold", "\x07FFD700");
	MC_FastSetColor("goldenrod", "\x07DAA520");
	MC_FastSetColor("gray", "\x07CCCCCC"); // same as spectator team color
	MC_FastSetColor("grey", "\x07CCCCCC");
	MC_FastSetColor("green", "\x073EFF3E");
	MC_FastSetColor("greenyellow", "\x07ADFF2F");
	MC_FastSetColor("haunted", "\x0738F3AB"); // same as Haunted item quality in TF2
	MC_FastSetColor("honeydew", "\x07F0FFF0");
	MC_FastSetColor("hotpink", "\x07FF69B4");
	MC_FastSetColor("immortal", "\x07E4AE33"); // same as Immortal item rarity in Dota 2
	MC_FastSetColor("indianred", "\x07CD5C5C");
	MC_FastSetColor("indigo", "\x074B0082");
	MC_FastSetColor("ivory", "\x07FFFFF0");
	MC_FastSetColor("khaki", "\x07F0E68C");
	MC_FastSetColor("lavender", "\x07E6E6FA");
	MC_FastSetColor("lavenderblush", "\x07FFF0F5");
	MC_FastSetColor("lawngreen", "\x077CFC00");
	MC_FastSetColor("legendary", "\x07D32CE6"); // same as Legendary item rarity in Dota 2
	MC_FastSetColor("lemonchiffon", "\x07FFFACD");
	MC_FastSetColor("lightblue", "\x07ADD8E6");
	MC_FastSetColor("lightcoral", "\x07F08080");
	MC_FastSetColor("lightcyan", "\x07E0FFFF");
	MC_FastSetColor("lightgoldenrodyellow", "\x07FAFAD2");
	MC_FastSetColor("lightgray", "\x07D3D3D3");
	MC_FastSetColor("lightgrey", "\x07D3D3D3");
	MC_FastSetColor("lightgreen", "\x0799FF99");
	MC_FastSetColor("lightpink", "\x07FFB6C1");
	MC_FastSetColor("lightsalmon", "\x07FFA07A");
	MC_FastSetColor("lightseagreen", "\x0720B2AA");
	MC_FastSetColor("lightskyblue", "\x0787CEFA");
	MC_FastSetColor("lightslategray", "\x07778899");
	MC_FastSetColor("lightslategrey", "\x07778899");
	MC_FastSetColor("lightsteelblue", "\x07B0C4DE");
	MC_FastSetColor("lightyellow", "\x07FFFFE0");
	MC_FastSetColor("lime", "\x0700FF00");
	MC_FastSetColor("limegreen", "\x0732CD32");
	MC_FastSetColor("linen", "\x07FAF0E6");
	MC_FastSetColor("magenta", "\x07FF00FF");
	MC_FastSetColor("maroon", "\x07800000");
	MC_FastSetColor("mediumaquamarine", "\x0766CDAA");
	MC_FastSetColor("mediumblue", "\x070000CD");
	MC_FastSetColor("mediumorchid", "\x07BA55D3");
	MC_FastSetColor("mediumpurple", "\x079370D8");
	MC_FastSetColor("mediumseagreen", "\x073CB371");
	MC_FastSetColor("mediumslateblue", "\x077B68EE");
	MC_FastSetColor("mediumspringgreen", "\x0700FA9A");
	MC_FastSetColor("mediumturquoise", "\x0748D1CC");
	MC_FastSetColor("mediumvioletred", "\x07C71585");
	MC_FastSetColor("midnightblue", "\x07191970");
	MC_FastSetColor("mintcream", "\x07F5FFFA");
	MC_FastSetColor("mistyrose", "\x07FFE4E1");
	MC_FastSetColor("moccasin", "\x07FFE4B5");
	MC_FastSetColor("mythical", "\x078847FF"); // same as Mythical item rarity in Dota 2
	MC_FastSetColor("navajowhite", "\x07FFDEAD");
	MC_FastSetColor("navy", "\x07000080");
	MC_FastSetColor("normal", "\x07B2B2B2"); // same as Normal item quality in TF2
	MC_FastSetColor("oldlace", "\x07FDF5E6");
	MC_FastSetColor("olive", "\x079EC34F");
	MC_FastSetColor("olivedrab", "\x076B8E23");
	MC_FastSetColor("orange", "\x07FFA500");
	MC_FastSetColor("orangered", "\x07FF4500");
	MC_FastSetColor("orchid", "\x07DA70D6");
	MC_FastSetColor("palegoldenrod", "\x07EEE8AA");
	MC_FastSetColor("palegreen", "\x0798FB98");
	MC_FastSetColor("paleturquoise", "\x07AFEEEE");
	MC_FastSetColor("palevioletred", "\x07D87093");
	MC_FastSetColor("papayawhip", "\x07FFEFD5");
	MC_FastSetColor("peachpuff", "\x07FFDAB9");
	MC_FastSetColor("peru", "\x07CD853F");
	MC_FastSetColor("pink", "\x07FFC0CB");
	MC_FastSetColor("plum", "\x07DDA0DD");
	MC_FastSetColor("powderblue", "\x07B0E0E6");
	MC_FastSetColor("purple", "\x07800080");
	MC_FastSetColor("rare", "\x074B69FF"); // same as Rare item rarity in Dota 2
	MC_FastSetColor("red", "\x07FF4040"); // same as RED/Terrorist team color
	MC_FastSetColor("rosybrown", "\x07BC8F8F");
	MC_FastSetColor("royalblue", "\x074169E1");
	MC_FastSetColor("saddlebrown", "\x078B4513");
	MC_FastSetColor("salmon", "\x07FA8072");
	MC_FastSetColor("sandybrown", "\x07F4A460");
	MC_FastSetColor("seagreen", "\x072E8B57");
	MC_FastSetColor("seashell", "\x07FFF5EE");
	MC_FastSetColor("selfmade", "\x0770B04A"); // same as Self-Made item quality in TF2
	MC_FastSetColor("sienna", "\x07A0522D");
	MC_FastSetColor("silver", "\x07C0C0C0");
	MC_FastSetColor("skyblue", "\x0787CEEB");
	MC_FastSetColor("slateblue", "\x076A5ACD");
	MC_FastSetColor("slategray", "\x07708090");
	MC_FastSetColor("slategrey", "\x07708090");
	MC_FastSetColor("snow", "\x07FFFAFA");
	MC_FastSetColor("springgreen", "\x0700FF7F");
	MC_FastSetColor("steelblue", "\x074682B4");
	MC_FastSetColor("strange", "\x07CF6A32"); // same as Strange item quality in TF2
	MC_FastSetColor("tan", "\x07D2B48C");
	MC_FastSetColor("teal", "\x07008080");
	MC_FastSetColor("thistle", "\x07D8BFD8");
	MC_FastSetColor("tomato", "\x07FF6347");
	MC_FastSetColor("turquoise", "\x0740E0D0");
	MC_FastSetColor("uncommon", "\x07B0C3D9"); // same as Uncommon item rarity in Dota 2
	MC_FastSetColor("unique", "\x07FFD700"); // same as Unique item quality in TF2
	MC_FastSetColor("unusual", "\x078650AC"); // same as Unusual item quality in TF2
	MC_FastSetColor("valve", "\x07A50F79"); // same as Valve item quality in TF2
	MC_FastSetColor("vintage", "\x07476291"); // same as Vintage item quality in TF2
	MC_FastSetColor("violet", "\x07EE82EE");
	MC_FastSetColor("wheat", "\x07F5DEB3");
	MC_FastSetColor("white", "\x07FFFFFF");
	MC_FastSetColor("whitesmoke", "\x07F5F5F5");
	MC_FastSetColor("yellow", "\x07FFFF00");
	MC_FastSetColor("yellowgreen", "\x079ACD32");
}

/**
 * Computes FNV-1a (Fowler-Noll-Vo) hash for a string
 * FNV-1a provides better avalanche characteristics than FNV-1
 * and is widely used in hash tables for its speed and distribution quality
 * 2166136261 is the FNV-1a 32-bit offset basis
 * 16777619 is the FNV-1a 32-bit prime multiplier
 *
 * @param str    String to hash
 * @return       32-bit hash value
 */
stock int MC_FastHash(const char[] str) {
	int hash = 2166136261;
	for (int i = 0; str[i]; i++) {
		hash ^= str[i];
		hash *= 16777619;
	}
	return hash & (COLOR_HASH_SIZE - 1);
}

/**
 * Inserts or updates a color in the hash table using linear probing
 * Updates existing keys, adds new ones, or silently fails if table is full
 * Uses FNV-1a hash with cycle detection to prevent infinite loops
 * Silent fail occurs only if: empty key/value, 256+ unique colors, or hash table completely full
 */
stock void MC_FastSetColor(const char[] key, const char[] value) {
	if (!key[0] || !value[0] || g_iColorCount >= COLOR_HASH_SIZE)
		return;

	int hash = MC_FastHash(key);
	int originalHash = hash;
	int probeCount = 0;

	// Linear probing with cycle detection
	do {
		int existingIndex = g_iColorHash[hash];

		// Found empty slot
		if (existingIndex == 0) {
			strcopy(g_sColorKeys[g_iColorCount], sizeof(g_sColorKeys[]), key);
			strcopy(g_sColorValues[g_iColorCount], sizeof(g_sColorValues[]), value);
			g_iColorHash[hash] = g_iColorCount + 1;
			g_iColorCount++;
			return;
		}

		// Check if key already exists (update case)
		existingIndex--;
		if (strcmp(g_sColorKeys[existingIndex], key, false) == 0) {
			strcopy(g_sColorValues[existingIndex], sizeof(g_sColorValues[]), value);
			return;
		}

		hash = (hash + 1) & (COLOR_HASH_SIZE - 1);
		probeCount++;

		// Prevent infinite loop if table is full
		if (probeCount >= COLOR_HASH_SIZE) {
			return; // Table is completely full, cannot insert
		}
	} while (hash != originalHash);
}

stock bool MC_FastGetColor(const char[] key, char[] output, int maxlen) {
	if (!key[0])
		return false;

	int hash = MC_FastHash(key);
	int originalHash = hash;

	do {
		int index = g_iColorHash[hash];
		if (index == 0)
			return false;

		index--;
		if (strcmp(g_sColorKeys[index], key, false) == 0) {
			strcopy(output, maxlen, g_sColorValues[index]);
			return true;
		}

		hash = (hash + 1) & (COLOR_HASH_SIZE - 1);
	} while (hash != originalHash);

	return false;
}

stock void MC_FastReplaceString(char[] text, int maxlen, const char[] search, const char[] replace) {
	if (!search[0] || !text[0])
		return;

	char localBuffer[MAX_BUFFER_LENGTH];

	int textLen = strlen(text);
	int searchLen = strlen(search);
	int replaceLen = strlen(replace);
	int tempPos = 0;
	int i = 0;

	while (i < textLen && tempPos < maxlen - 1) {
		if (i <= textLen - searchLen) {
			// Manual character comparison instead of strncmp
			bool match = true;
			for (int j = 0; j < searchLen; j++) {
				if (text[i + j] != search[j]) {
					match = false;
					break;
				}
			}

			if (match) {
				// Found match, copy replacement
				for (int k = 0; k < replaceLen && tempPos < maxlen - 1; k++) {
					localBuffer[tempPos++] = replace[k];
				}
				i += searchLen;
				continue;
			}
		}

		localBuffer[tempPos++] = text[i++];
	}

	localBuffer[tempPos] = '\0';
	strcopy(text, maxlen, localBuffer);
}
