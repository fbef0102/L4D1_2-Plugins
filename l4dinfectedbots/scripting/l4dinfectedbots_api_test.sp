#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <l4dinfectedbots>

#define PLUGIN_NAME "L4D Infected Bots API Test"
#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "API Test",
	description = "Tests L4DInfectedBots_GetConfig natives",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_testapi", Command_TestAPI, "Test L4DInfectedBots API natives");
}

Action Command_TestAPI(int client, int args)
{
	PrintToServer("====== L4DInfectedBots API Test ======");

	bool available = LibraryExists("l4dinfectedbots");
	PrintToServer("Library 'l4dinfectedbots' exists: %s", available ? "YES" : "NO");

	if (!available)
	{
		PrintToServer("ERROR: l4dinfectedbots plugin is NOT loaded!");
		if (client > 0 && IsClientInGame(client))
			PrintToChat(client, "[API Test] l4dinfectedbots plugin NOT loaded - check server console");
		return Plugin_Handled;
	}

	// ---- Test GetConfigInt ----
	char intKeys[][] = {
		"smoker_limit", "boomer_limit", "hunter_limit",
		"spitter_limit", "jockey_limit", "charger_limit",
		"max_specials", "max_specials_tank_including",
		"smoker_weight", "boomer_weight", "hunter_weight",
		"spitter_weight", "jockey_weight", "charger_weight", "scale_weights",
		"smoker_health", "boomer_health", "hunter_health",
		"spitter_health", "jockey_health", "charger_health",
		"tank_limit", "tank_limit_override", "tank_spawn_probability",
		"tank_health", "tank_spawn_final",
		"witch_max_limit", "witch_spawn_final",
		"spawn_same_frame", "spawn_safe_zone", "spawn_where_method",
		"spawn_disable_bots", "tank_disable_spawn", "coordination",
		"coop_versus_enable", "coop_versus_tank_playable",
		"coop_versus_announce", "coop_versus_human_limit",
		"coop_versus_human_light", "coop_versus_human_ghost"
	};

	int intPass = 0, intFail = 0;
	PrintToServer("\n--- GetConfigInt (%d keys) ---", sizeof(intKeys));
	for (int i = 0; i < sizeof(intKeys); i++)
	{
		int val = L4DInfectedBots_GetConfigInt(intKeys[i]);
		PrintToServer("  [%d/%d] %s = %d", i + 1, sizeof(intKeys), intKeys[i], val);
		intPass++;
	}
	PrintToServer("  GetConfigInt: %d pass, %d fail", intPass, intFail);

	// Test invalid key
	PrintToServer("  Testing invalid key 'nonexistent'...");
	int badVal = L4DInfectedBots_GetConfigInt("nonexistent");
	PrintToServer("  Invalid key returned: %d (expected native error above)", badVal);

	// ---- Test GetConfigFloat ----
	char floatKeys[][] = {
		"spawn_time_min", "spawn_time_max", "initial_spawn_time",
		"life", "spawn_range_min", "spawn_time_increase_on_human_infected",
		"witch_spawn_time_min", "witch_spawn_time_max", "witch_life",
		"coop_versus_spawn_time_min", "coop_versus_spawn_time_max",
		"coop_versus_cool_down"
	};

	int floatPass = 0, floatFail = 0;
	PrintToServer("\n--- GetConfigFloat (%d keys) ---", sizeof(floatKeys));
	for (int i = 0; i < sizeof(floatKeys); i++)
	{
		float val = L4DInfectedBots_GetConfigFloat(floatKeys[i]);
		PrintToServer("  [%d/%d] %s = %.1f", i + 1, sizeof(floatKeys), floatKeys[i], val);
		floatPass++;
	}
	PrintToServer("  GetConfigFloat: %d pass, %d fail", floatPass, floatFail);

	// Test invalid float key
	PrintToServer("  Testing invalid key 'nonexistent_float'...");
	float badFloat = L4DInfectedBots_GetConfigFloat("nonexistent_float");
	PrintToServer("  Invalid key returned: %.1f (expected native error above)", badFloat);

	// ---- Test GetConfigString ----
	char strKeys[][] = { "coop_versus_join_access" };

	int strPass = 0, strFail = 0;
	PrintToServer("\n--- GetConfigString (%d keys) ---", sizeof(strKeys));
	for (int i = 0; i < sizeof(strKeys); i++)
	{
		char buffer[64];
		int ok = L4DInfectedBots_GetConfigString(strKeys[i], buffer, sizeof(buffer));
		PrintToServer("  [%d/%d] %s = \"%s\" (ret=%d)", i + 1, sizeof(strKeys), strKeys[i], buffer, ok);
		if (ok) strPass++; else strFail++;
	}
	PrintToServer("  GetConfigString: %d pass, %d fail", strPass, strFail);

	// Test invalid string key
	PrintToServer("  Testing invalid key 'nonexistent_str'...");
	char badStr[64];
	int badRet = L4DInfectedBots_GetConfigString("nonexistent_str", badStr, sizeof(badStr));
	PrintToServer("  Invalid key returned: \"%s\" (ret=%d, expected native error above)", badStr, badRet);

	// ---- Summary ----
	PrintToServer("\n====== API Test Summary ======");
	int totalPass = intPass + floatPass + strPass;
	int totalKeys = sizeof(intKeys) + sizeof(floatKeys) + sizeof(strKeys);
	PrintToServer("  Total: %d/%d keys retrieved successfully", totalPass, totalKeys);
	PrintToServer("  GetConfigInt:  %d/%d", intPass, sizeof(intKeys));
	PrintToServer("  GetConfigFloat: %d/%d", floatPass, sizeof(floatKeys));
	PrintToServer("  GetConfigString: %d/%d", strPass, sizeof(strKeys));
	PrintToServer("==============================");

	if (client > 0 && IsClientInGame(client))
		PrintToChat(client, "[API Test] %d/%d keys OK - check server console for details", totalPass, totalKeys);

	return Plugin_Handled;
}
