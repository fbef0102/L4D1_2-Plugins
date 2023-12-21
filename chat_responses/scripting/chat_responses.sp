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
	version = "1.1-2023/12/21",
	url = "http://steamcommunity.com/profiles/76561198026784913"
}


StringMap g_sChatResponse;
public void OnPluginStart()
{
    g_sChatResponse = new StringMap();
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
    if (!(client > 0 && client <= MaxClients && IsClientInGame(client)))
        return;
        
    char buffers[2][64] = {
        " ",
        " ",
    };
    int startidx;

    ExplodeString(sArgs[startidx], " ", buffers, 2, 64, false);
    char output[256];
    StringToLowerCase(buffers[0]);
    if (g_sChatResponse.GetString(buffers[0], output, sizeof(output)) == true)
    {
        CPrintToChatAll("%s", output);
    }
}

public void OnConfigsExecuted()
{
    LoadConfig();
}

void LoadConfig()
{
    KeyValues hFile = CreateKeyValues("ChatResponses");
    char path[256];
    BuildPath(Path_SM, path, 256, "configs/%s", DATA_FILE);

    if (!FileToKeyValues(hFile, path)) {
        LogError("[MI] Couldn't load %s config!", DATA_FILE);
        delete hFile;
    }

    char sCommandName[64];
    char sTextName[64];
    if( hFile.GotoFirstSubKey() )
    {
        do
        {
            hFile.GetSectionName(sCommandName, sizeof(sCommandName));
            hFile.GetString("text", sTextName, sizeof(sTextName), "No Text");
            
            StringToLowerCase(sCommandName);
            g_sChatResponse.SetString(sCommandName, sTextName);
        } while(hFile.GotoNextKey());
    } 

    delete hFile;
}

void StringToLowerCase(char[] input)
{
    for (int i = 0; i < strlen(input); i++)
    {
        input[i] = CharToLower(input[i]);
    }
}