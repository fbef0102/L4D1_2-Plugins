#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sourcescramble>

public Plugin myinfo =
{
    name = "Bot Charger Level damage fix",
    author = "umlka, Harry",
    description = "Makes AI Charger take damage like human SI while charging.",
    version = "1.0h -2024/8/11",
    url = "https://github.com/umlka/l4d2/tree/main/charging_takedamage_patch"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
        return APLRes_SilentFailure;
    }

    RegPluginLibrary("charging_takedamage_patch");

    return APLRes_Success;
}

methodmap GameDataWrapper < GameData {
	public GameDataWrapper(const char[] file) {
		GameData gd = new GameData(file);
		if (!gd) SetFailState("Missing gamedata \"%s\"", file);
		return view_as<GameDataWrapper>(gd);
	}
	public MemoryPatch CreatePatchOrFail(const char[] name, bool enable = false) {
		MemoryPatch hPatch = MemoryPatch.CreateFromConf(this, name);
		if (!(enable ? hPatch.Enable() : hPatch.Validate()))
			SetFailState("Failed to patch \"%s\"", name);
		return hPatch;
	}
}

public void OnPluginStart()
{
    GameDataWrapper gd = new GameDataWrapper("charging_takedamage_patch");
    gd.CreatePatchOrFail("Charger::OnTakeDamage::m_flDamage", true);
    delete gd;
}
