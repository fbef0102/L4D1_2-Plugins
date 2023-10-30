/************************************************************************
*************************************************************************
Simple Chat Processor
Description
		Process chat and allows other plugins to manipulate chat.
*************************************************************************
*************************************************************************
This file is part of Simple Plugins project.

This plugin is free software: you can redistribute
it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or
later version.

This plugin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this plugin.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************
*************************************************************************
File Information
$Id$
$Author$
$Revision$
$Date$
$LastChangedBy$
$LastChangedDate$
$URL$
$Copyright: (c) Simple Plugins 2008-2009$
*************************************************************************
*************************************************************************
*/
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#undef REQUIRE_PLUGIN

#define PLUGIN_VERSION				"1.3h-2023/7/5"
#define SENDER_WORLD			0
#define MAXLENGTH_INPUT			128 	// Inclues \0 and is the size of the chat input box.
#define MAXLENGTH_NAME			64		// This is backwords math to get compability.  Sourcemod has it set at 32, but there is room for more.
#define MAXLENGTH_MESSAGE		256		// This is based upon the SDK and the length of the entire message, including tags, name, : etc.

#define CHATFLAGS_INVALID		0
#define CHATFLAGS_ALL			(1 << 0)
#define CHATFLAGS_TEAM			(1 << 1)
#define CHATFLAGS_SPEC			(1 << 2)
#define CHATFLAGS_DEAD			(1 << 3)

#define ADDSTRING(%1) g_hChatFormats.SetValue(%1, 1)

enum eMods {
	GameType_Unknown,
	GameType_L4D,
	GameType_L4D2,
};

ArrayList g_hDPArray = null;

/*eMods g_CurrentMod;
char g_sGameName[eMods][32] = {
	"Unknown",
	"Left 4 Dead",
	"Left 4 Dead 2",
};*/
StringMap
	  g_hChatFormats;
GlobalForward
	  g_fwdOnChatMessage
	, g_fwdOnChatMessagePost;
bool
	  g_bSayText2;
int
	  g_CurrentChatType = CHATFLAGS_INVALID;

public Plugin myinfo = {
	name = "Simple Chat Processor (Redux)",
	author = "Simple Plugins, Mini, HarryPotter",
	description = "Process chat and allows other plugins to manipulate chat.",
	version = PLUGIN_VERSION,
	url = "https://github.com/fbef0102/SM-Custom-ChatColors-Menu"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	MarkNativeAsOptional("GetUserMessageType");
	CreateNative("GetMessageFlags", Native_GetMessageFlags);
	RegPluginLibrary("scp");
	return APLRes_Success;
}

public void OnPluginStart() {
	CreateConVar("scp_version", PLUGIN_VERSION, "Plugin Version", FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_CHEAT);

	//g_CurrentMod = GetCurrentMod();
	g_hChatFormats = new StringMap();
	//LogMessage("[SCP] Recognized mod [%s].", g_sGameName[g_CurrentMod]);

	/**
	Hook the usermessage or error out if the mod doesn't support saytext2
	*/
	UserMsg umSayText2 = GetUserMessageId("SayText2");
	if (umSayText2 != INVALID_MESSAGE_ID) {
		g_bSayText2 = true;
		HookUserMessage(umSayText2, OnSayText2, true);
	}
	else {
		UserMsg umSayText = GetUserMessageId("SayText");
		if (umSayText != INVALID_MESSAGE_ID) {

			g_bSayText2 = false;
			HookUserMessage(umSayText, OnSayText, true);
		}
		else {
			LogError("[SCP] This mod appears not to support SayText2 or SayText.  Plugin disabled.");
			SetFailState("Error hooking usermessage saytext2 and saytext");
		}
	}

	/**
	Get mod type and load the correct translation file
	*/
	if (g_bSayText2) {
		char sGameDir[32];
		char sTranslationFile[PLATFORM_MAX_PATH];
		char sTranslationLocation[PLATFORM_MAX_PATH];

		GetGameFolderName(sGameDir, sizeof(sGameDir));
		Format(sTranslationFile, sizeof(sTranslationFile), "scp.%s.phrases", sGameDir);
		BuildPath(Path_SM, sTranslationLocation, sizeof(sTranslationLocation), "translations/%s.txt", sTranslationFile);

		if (FileExists(sTranslationLocation)) {
			//LogMessage("[SCP] Loading translation file [%s].", sTranslationFile);
			LoadTranslations(sTranslationFile);
			if (!GetChatFormats(sTranslationLocation)) {
				LogError("[SCP] Could not parse the translation file");
				SetFailState("Could not parse the translation file");
			}
		}
		else {
			LogError("[SCP] Translation file is not present: translations/%s.txt", sTranslationFile);
			SetFailState("Translation file is not present: translations/%s.txt", sTranslationFile);
		}
	}

	/**
	Create the global forwards for other plugins
	*/
	g_fwdOnChatMessage = new GlobalForward("OnChatMessage2", ET_Hook, Param_CellByRef, Param_Cell, Param_String, Param_Cell, Param_String, Param_Cell);
	g_fwdOnChatMessagePost = new GlobalForward("OnChatMessage_Post", ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_String);

	g_hDPArray = new ArrayList();
}

public Action OnSayText2(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) {
	/**
	Get the sender of the usermessage and bug out if it is not a player
	*/
	bool bProtobuf = (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf);
	int cpSender;
	if (bProtobuf) {
		cpSender = UserMessageToProtobuf(msg).ReadInt("ent_idx");
	}
	else {
		cpSender = msg.ReadByte();
	}

	
	if (cpSender == SENDER_WORLD) {
		return Plugin_Continue;
	}

	/**
	Get the chat bool.  This determines if sent to console as well as chat
	*/
	bool bChat;
	if (bProtobuf) {
		bChat = UserMessageToProtobuf(msg).ReadBool("chat");
	}
	else {
		bChat = !!msg.ReadByte();
	}

	/**
	Make sure we have a default translation string for the message
	This also determines the message type...
	*/
	char cpTranslationName[32];
	int buffer;
	if (bProtobuf) {
		UserMessageToProtobuf(msg).ReadString("msg_name", cpTranslationName, sizeof(cpTranslationName));
	}
	else {
		msg.ReadString(cpTranslationName, sizeof(cpTranslationName));
	}

	if (!g_hChatFormats.GetValue(cpTranslationName, buffer)) {
		return Plugin_Continue;
	}
	else {
		if (StrContains(cpTranslationName, "all", false) != -1) {
			g_CurrentChatType = g_CurrentChatType | CHATFLAGS_ALL;
		}

		if (StrContains(cpTranslationName, "team", false) != -1
		|| 	StrContains(cpTranslationName, "survivor", false) != -1
		||	StrContains(cpTranslationName, "infected", false) != -1
		||	StrContains(cpTranslationName, "Cstrike_Chat_CT", false) != -1
		||	StrContains(cpTranslationName, "Cstrike_Chat_T", false) != -1) {
			g_CurrentChatType = g_CurrentChatType | CHATFLAGS_TEAM;
		}

		if (StrContains(cpTranslationName, "spec", false) != -1) {
			g_CurrentChatType = g_CurrentChatType | CHATFLAGS_SPEC;
		}

		if (StrContains(cpTranslationName, "dead", false) != -1
			|| (GetClientTeam(cpSender) >= 2 && !IsPlayerAlive(cpSender))) {
			g_CurrentChatType = g_CurrentChatType | CHATFLAGS_DEAD;
		}
	}

	/**
	Get the senders name
	*/
	char cpSender_Name[MAXLENGTH_NAME];
	if (bProtobuf) {
		UserMessageToProtobuf(msg).ReadString("params", cpSender_Name, sizeof(cpSender_Name), 0);
	}
	else if (BfGetNumBytesLeft(msg)) {
		msg.ReadString(cpSender_Name, sizeof(cpSender_Name));
	}

	/**
	Get the message
	*/
	char cpMessage[MAXLENGTH_INPUT];
	if (bProtobuf) {
		UserMessageToProtobuf(msg).ReadString("params", cpMessage, sizeof(cpMessage), 1);
	}
	else if (BfGetNumBytesLeft(msg)) {
		msg.ReadString(cpMessage, sizeof(cpMessage));
	}

	/**
	Store the clients in an array so the call can manipulate it.
	*/
	ArrayList cpRecipients = new ArrayList();
	for (int i = 0; i < playersNum; i++) {
		cpRecipients.Push(players[i]);
	}

	/**
	Because the message could be changed but not the name
	we need to compare the original name to the returned name.
	We do this because we may have to add the team color code to the name,
	where as the message doesn't get a color code by default.
	*/
	char sOriginalName[MAXLENGTH_NAME];
	strcopy(sOriginalName, sizeof(sOriginalName), cpSender_Name);

	/**
	Start the forward for other plugins
	*/
	Action fResult;
	Call_StartForward(g_fwdOnChatMessage);
	Call_PushCellRef(cpSender);
	Call_PushCell(cpRecipients);
	Call_PushStringEx(cpSender_Name, sizeof(cpSender_Name), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(sizeof(cpSender_Name));
	Call_PushStringEx(cpMessage, sizeof(cpMessage), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(sizeof(cpMessage));
	int fError = Call_Finish(fResult);

	int chatFlags = g_CurrentChatType;
	g_CurrentChatType = CHATFLAGS_INVALID;

	if (fError != SP_ERROR_NONE) {
		ThrowNativeError(fError, "Forward failed");
		delete cpRecipients;
		return Plugin_Continue;
	}
	else if (fResult == Plugin_Continue) {
		delete cpRecipients;
		return Plugin_Continue;
	}
	else if (fResult == Plugin_Stop) {
		delete cpRecipients;
		return Plugin_Handled;
	}

	/**
	This is the check for a name change.  If it has not changed we add the team color code
	*/
	if (StrEqual(sOriginalName, cpSender_Name)) {
		Format(cpSender_Name, sizeof(cpSender_Name), "\x03%s", cpSender_Name);
	}

	/**
	Create a timer to print the message on the next gameframe
	*/
	DataPack cpPack = new DataPack();
	int numRecipients = cpRecipients.Length;

	cpPack.WriteCell(cpSender);

	for (int i = 0; i < numRecipients; i++) {
		int x = cpRecipients.Get(i);
		if (!IsValidClient(x)) {
			numRecipients--;
			cpRecipients.Erase(i);
		}
	}

	cpPack.WriteCell(numRecipients);
	for (int i = 0; i < numRecipients; i++) {
		int x = cpRecipients.Get(i);
		cpPack.WriteCell(x);
	}

	cpPack.WriteCell(bChat);
	cpPack.WriteString(cpTranslationName);
	cpPack.WriteString(cpSender_Name);
	cpPack.WriteString(cpMessage);
	g_hDPArray.Push(cpPack);
	cpPack.WriteCell(bProtobuf);
	cpPack.WriteCell(chatFlags);

	delete cpRecipients;

	/**
	Stop the original message
	*/
	return Plugin_Handled;
}

public Action OnSayText(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) {
	/**
	Get the sender of the usermessage and bug out if it is not a player
	*/
	bool bProtobuf = (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf);
	int cpSender;
	if (bProtobuf) {
		cpSender = UserMessageToProtobuf(msg).ReadInt("ent_idx");
	}
	else {
		cpSender = msg.ReadByte();
	}

	if (cpSender == SENDER_WORLD) {
		return Plugin_Continue;
	}

	/**
	Get the chat message
	*/
	char message[MAXLENGTH_INPUT];
	if (bProtobuf) {
		UserMessageToProtobuf(msg).ReadString("text", message, sizeof(message));
	}
	else {
		msg.ReadString(message, sizeof(message));
	}

	/**
	Get the chat bool.  This determines if sent to console as well as chat
	*/
	if (!bProtobuf) {
		msg.ReadBool();
	}

	/**
	Store the clients in an array so the call can manipulate it.
	*/
	ArrayList cpRecipients = new ArrayList();
	for (int i = 0; i < playersNum; i++) {
		cpRecipients.Push(players[i]);
	}

	char prefix[64], senderName[MAX_NAME_LENGTH], textMessage[MAXLENGTH_MESSAGE], buffer[MAXLENGTH_INPUT];
	GetClientName(cpSender, senderName, sizeof(senderName));
	Format(buffer, sizeof(buffer), "%s:", senderName);
	int pos = StrContains(message, buffer);

	if (pos == 0) {
		prefix[0] = '\0';
	}
	else {
		Format(prefix, pos + 1, "%s ", message);
	}

	g_CurrentChatType = CHATFLAGS_INVALID;

	if (StrContains(prefix, "(Team)") != -1) {
		g_CurrentChatType |= CHATFLAGS_TEAM;
	}

	if (GetClientTeam(cpSender) <= 1) {
		g_CurrentChatType |= CHATFLAGS_SPEC;
	}

	if (StrContains(prefix, "(Dead)") != -1) {
		g_CurrentChatType |= CHATFLAGS_DEAD;
	}

	if (g_CurrentChatType == CHATFLAGS_INVALID) {
		g_CurrentChatType = CHATFLAGS_ALL;
	}

	ReplaceString(message, sizeof(message), "\n", "");
	strcopy(textMessage, sizeof(textMessage), message[pos + strlen(senderName) + 2]);

	/**
	Start the forward for other plugins
	*/
	Action fResult;
	Call_StartForward(g_fwdOnChatMessage);
	Call_PushCellRef(cpSender);
	Call_PushCell(cpRecipients);
	Call_PushStringEx(senderName, sizeof(senderName), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(sizeof(senderName));
	Call_PushStringEx(textMessage, sizeof(textMessage), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(sizeof(textMessage));
	int fError = Call_Finish(fResult);

	int chatFlags = g_CurrentChatType;
	g_CurrentChatType = CHATFLAGS_INVALID;

	if (fError != SP_ERROR_NONE) {
		ThrowNativeError(fError, "Forward failed");
		delete cpRecipients;
		return Plugin_Continue;
	}
	
	if (fResult == Plugin_Continue) {
		delete cpRecipients;
		return Plugin_Continue;
	}

	if (fResult >= Plugin_Handled) {
		delete cpRecipients;
		return Plugin_Handled;
	}

	GetClientName(cpSender, buffer, sizeof(buffer));
	if (StrEqual(senderName, buffer)) {
		Format(senderName, sizeof(senderName), "\x03%s", senderName);
	}

	/**
	Create a timer to print the message on the next gameframe
	*/
	DataPack cpPack = new DataPack();

	int numRecipients = cpRecipients.Length;

	cpPack.WriteCell(cpSender);

	for (int i = 0; i < numRecipients; i++) {
		int x = cpRecipients.Get(i);
		if (!IsValidClient(x)) {
			numRecipients--;
			cpRecipients.Erase(i);
		}
	}

	cpPack.WriteCell(numRecipients);

	for (int i = 0; i < numRecipients; i++) {
		int x = cpRecipients.Get(i);
		cpPack.WriteCell(x);
	}

	cpPack.WriteString(prefix);
	cpPack.WriteString(senderName);
	cpPack.WriteString(textMessage);
	g_hDPArray.Push(cpPack);
	// We don't care about saving bProtobuf since we print SayText messages with PrintToChat
	cpPack.WriteCell(chatFlags);

	delete cpRecipients;

	/**
	Stop the original message
	*/
	return Plugin_Handled;
}

public void OnGameFrame() {
	for (int i = 0; i < g_hDPArray.Length; i++) {
		DataPack pack = g_hDPArray.Get(i);
		pack.Reset();

		char sSenderName[MAXLENGTH_NAME], sMessage[MAXLENGTH_INPUT];
		int client;
		ArrayList recipients = new ArrayList();
		if (g_bSayText2) {
			client = pack.ReadCell();
			int numClientsStart = pack.ReadCell();
			int numClientsFinish;
			int[] clients = new int[numClientsStart];

			for (int x = 0; x < numClientsStart; x++) {
				int buffer = pack.ReadCell();
				if (IsValidClient(buffer)) {
					clients[numClientsFinish++] = buffer;
					recipients.Push(buffer);
				}
			}

			bool bChat = view_as<bool>(pack.ReadCell());
			char sChatType[32];
			pack.ReadString(sChatType, sizeof(sChatType));
			pack.ReadString(sSenderName, sizeof(sSenderName));
			pack.ReadString(sMessage, sizeof(sMessage));

			char sTranslation[MAXLENGTH_MESSAGE];

			if (pack.ReadCell()) {
				g_CurrentChatType = pack.ReadCell();
				int target;
				Handle msg;
				for(int j = 0; j < numClientsFinish; j++)
				{
					target = clients[j];
					//LogMessage("target: %d", target);

					msg = StartMessageOne("SayText2", target, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
					FormatEx(sTranslation, sizeof(sTranslation), "%T", sChatType, target, sSenderName, sMessage);

					Protobuf pb = UserMessageToProtobuf(msg);
					pb.SetInt("ent_idx", client);
					pb.SetBool("chat", bChat);

					pb.SetString("msg_name", sTranslation);
					pb.AddString("params", "");
					pb.AddString("params", "");
					pb.AddString("params", "");
					pb.AddString("params", "");
					EndMessage();
				}
			}
			else {
				//LogMessage("L4D1/2 here");
				g_CurrentChatType = pack.ReadCell();
				int target;
				Handle msg;
				for(int j = 0; j < numClientsFinish; j++)
				{
					target = clients[j];
					//LogMessage("target: %d", target);

					msg = StartMessageOne("SayText2", target, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
					FormatEx(sTranslation, sizeof(sTranslation), "%T", sChatType, target, sSenderName, sMessage);
					BfWrite buf = UserMessageToBfWrite(msg);
					buf.WriteByte(client);
					buf.WriteByte(bChat);
					buf.WriteString(sTranslation);
					EndMessage();
				}
			}
		}
		else {
			client = pack.ReadCell();
			int numClientsStart = pack.ReadCell();
			int numClientsFinish;
			int[] clients = new int[numClientsStart];

			for (int x = 0; x < numClientsStart; x++) {
				int buffer = pack.ReadCell();
				if (IsValidClient(buffer)) {
					clients[numClientsFinish++] = buffer;
					recipients.Push(buffer);
				}
			}

			char sPrefix[MAXLENGTH_NAME];
			pack.ReadString(sPrefix, sizeof(sPrefix));
			pack.ReadString(sSenderName, sizeof(sSenderName));
			pack.ReadString(sMessage, sizeof(sMessage));

			char message[MAXLENGTH_MESSAGE];

			int teamColor;
			switch (GetClientTeam(client)) {
				case 0, 1: teamColor = 0xCCCCCC;
				case 2: teamColor = 0x4D7942;
				case 3: teamColor = 0xFF4040;
			}

			char buffer[32];
			Format(buffer, sizeof(buffer), "\x07%06X", teamColor);
			ReplaceString(sSenderName, sizeof(sSenderName), "\x03", buffer);
			ReplaceString(sMessage, sizeof(sMessage), "\x03", buffer);

			Format(message, sizeof(message), "\x01%s%s\x01: %s", sPrefix, sSenderName, sMessage);
			PrintToServer(message);

			for (int j = 0; j < numClientsFinish; j++) {
				PrintToChat(clients[j], "%s", message);
			}

			g_CurrentChatType = pack.ReadCell();
		}
		Call_StartForward(g_fwdOnChatMessagePost);
		Call_PushCell(client);
		Call_PushCell(recipients);
		Call_PushString(sSenderName);
		Call_PushString(sMessage);
		Call_Finish();
		g_CurrentChatType = CHATFLAGS_INVALID;

		delete recipients;
		delete pack;

		g_hDPArray.Erase(i);
	}
}

public int Native_GetMessageFlags(Handle plugin, int numParams) {
	return g_CurrentChatType;
}

stock bool IsValidClient(int client, bool nobots = true) {
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client))) {
		return false;
	}
	return IsClientInGame(client);
}

stock bool GetChatFormats(const char[] file) {
	SMCParser hParser = new SMCParser();
	char error[128];
	int line = 0, col = 0;

	hParser.OnEnterSection = Config_NewSection;
	hParser.OnKeyValue = Config_KeyValue;
	hParser.OnLeaveSection = Config_EndSection;
	hParser.OnEnd = Config_End;
	SMCError result = hParser.ParseFile(file, line, col);
	delete hParser;

	if (result != SMCError_Okay) {
		hParser.GetErrorString(result, error, sizeof(error));
		LogError("%s on line %d, col %d of %s", error, line, col, file);
	}

	return (result == SMCError_Okay);
}

public SMCResult Config_NewSection(Handle parser, const char[] section, bool quotes) {
	if (StrEqual(section, "Phrases")) {
		return SMCParse_Continue;
	}
	ADDSTRING(section);
	return SMCParse_Continue;
}

public SMCResult Config_KeyValue(Handle parser, const char[] key, const char[] value, bool key_quotes, bool value_quotes) {
	return SMCParse_Continue;
}

public SMCResult Config_EndSection(Handle parser) {
	return SMCParse_Continue;
}

public void Config_End(Handle parser, bool halted, bool failed) {
	//nothing
}

stock eMods GetCurrentMod() {
	char sGameType[64];
	GetGameFolderName(sGameType, sizeof(sGameType));

	if (StrEqual(sGameType, "left4dead", false) || StrEqual(sGameType, "l4d", false)) {
		return GameType_L4D;
	}
	if (StrEqual(sGameType, "left4dead2", false) || StrEqual(sGameType, "l4d2", false)) {
		return GameType_L4D2;
	}

	LogMessage("Unknown Game Folder: %s", sGameType);
	return GameType_Unknown;
}