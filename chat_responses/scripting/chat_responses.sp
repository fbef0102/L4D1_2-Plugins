#pragma semicolon 1
#pragma newdecls required
 
#include <sdktools>
#include <sdkhooks>
#include <basecomm>
#include <multicolors>

#define DATA_FILE "chat_responses.txt"
public Plugin myinfo =
{
	name = "Autoresponder",
	description = "Displays chat advertisements when specified text is said in player chat.",
	author = "Russianeer, HarryPotter",
	version = "1.1",
	url = "http://steamcommunity.com/profiles/76561198026784913"
}

public void OnPluginStart()
{
    AddCommandListener(Command_Say, "say");
    AddCommandListener(Command_Say, "say_team");
}

public Action Command_Say(int client, const char[] command, int argc)
{
    if(client == 0) return Plugin_Continue;

    if(BaseComm_IsClientGagged(client) == true) //this client has been gagged
        return Plugin_Continue;	
        
    char text[256];
    char buffers[3][64] = {
        " ",
        "{DEFAULT}",
        "File was not found: %s"
    };
    int startidx;
    GetCmdArg(1, text, sizeof(text));

    //PrintToChatAll("%s", text);

    // if (text[0] == '!' || text[0] == '/')
    // {
    //     return Plugin_Continue;
    // }

    ExplodeString(text[startidx], " ", buffers, 3, 64, false);
    char output[256];
    if (LoadAds(text[startidx], output, 256))
    {
        CPrintToChatAll("%s", output);
    }

    return Plugin_Continue;
}

bool LoadAds(char []command, char []output, int maxlength)
{
    KeyValues kv = CreateKeyValues("ChatResponses");
    char path[256];
    BuildPath(Path_SM, path, 256, "configs/%s", DATA_FILE);

    if (!FileToKeyValues(kv, path)) {
        LogError("[MI] Couldn't load %s config!", DATA_FILE);
        CloseHandle(kv);
        kv = null;
    }


    if (!KvJumpToKey(kv, command, false))
    {
        return false;
    }

    KvGetString(kv, "text", output, maxlength, "");
    CloseHandle(kv);
    kv = null;
    return true;
}
