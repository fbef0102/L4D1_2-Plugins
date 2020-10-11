#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define PLUGIN_VERSION "1.6"

enum GameModeStatus
{
	GMS_UNKNOWN = 0,
	GMS_COOP = 1,
	GMS_VERSUS = 2,
	GMS_SURVIVAL = 3,
	GMS_SCAVENGE = 4
};

enum MapStatus
{
	MS_UNKNOWN = 0,
	MS_REGULAR = 1,
	MS_FINALE = 2,
	MS_ESCAPE = 3,
	MS_LEAVING = 4,
	MS_ROUNDEND = 5
};

char sLabels[5][] =
{
	"regular", "finale", "1stwave", "2ndwave", "escape"
};

GameModeStatus gmsBase;
MapStatus msBase;
int iMaxZombies, iFrustration[MAXPLAYERS+1], iMTHealthCoop[5], iMTHealthVersus[5], iMTHealthSurvival,
	iMTHealthScavenge, iMTCountCoop[5], iMTCountVersus[5], iMTCountSurvival, iMTCountScavenge,
	iFinaleWave, iTankHP, iTankCount, iMaxTankCount;

bool bRoundBegan, bRoundFinished, bFrustrated[MAXPLAYERS+1], bIsTank[MAXPLAYERS+1], bMTOn, bMTAnnounce,
	bMTSameSpawn[3], bMTDisplay, bFirstSpawned;

float fTankPos[3], fMTSpawnDelay[2];
ConVar hMTOn, hMTHealthCoop[5], hMTHealthVersus[5], hMTHealthSurvival, hMTHealthScavenge, hMTCountCoop[5],
	hMTCountVersus[5], hMTCountSurvival, hMTCountScavenge, hMTAnnounce, hMTSameSpawn[3], hMTSpawnDelay[2],
	hMTDisplay, hGameMode;

Panel pMTList;
static Handle hCreateTank;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	char sGameName[12];
	GetGameFolderName(sGameName, sizeof(sGameName));
	if (StrEqual(sGameName, "left4dead2", false))
	{
		return APLRes_Success;
	}
	
	strcopy(error, err_max, "[MT] Plugin Supports L4D2 Only!");
	return APLRes_SilentFailure;
}

public Plugin myinfo =
{
	name = "MultiTanks - Improved",
	author = "Red Alex, cravenge, Harry Potter",
	description = "This Time, Let All Hell Break Loose!",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/forumdisplay.php?f=108"
};

public void OnPluginStart()
{
	Handle hGameConf = LoadGameConfigFile("multitanks_a");
	if( hGameConf != null )
	{
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "NextBotCreatePlayerBot<Tank>"))
			SetFailState("Unable to find NextBotCreatePlayerBot<Tank> signature in gamedata file.");
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateTank = EndPrepSDKCall();
		if (hCreateTank == null)
			SetFailState("Cannot initialize NextBotCreatePlayerBot<Tank> SDKCall, signature is broken.") ;
	}
	else
	{
		SetFailState("Unable to find l4dinfectedbots.txt gamedata file.");
	}

	hGameMode = FindConVar("mp_gamemode");
	hGameMode.AddChangeHook(OnMTCVarsChanged);
	
	gmsBase = GetGameModeInfo();
	
	iMaxZombies = (FindConVar("super_versus_version") != null) ? FindConVar("super_versus_infected_limit").IntValue : FindConVar("z_max_player_zombies").IntValue;
	FindConVar("super_versus_version") != null ? FindConVar("super_versus_infected_limit").AddChangeHook(OnMTCVarsChanged) : FindConVar("z_max_player_zombies").AddChangeHook(OnMTCVarsChanged);
	
	CreateConVar("multitanks_version", PLUGIN_VERSION, "MultiTanks Version", FCVAR_NOTIFY|FCVAR_SPONLY|FCVAR_DONTRECORD);
	hMTOn = CreateConVar("multitanks_on", "1", "Enable/Disable Plugin", FCVAR_NOTIFY|FCVAR_SPONLY);
	hMTHealthSurvival = CreateConVar("multitanks_health_survival", "17500", "Health Of Tanks (Survival)", FCVAR_NOTIFY|FCVAR_SPONLY);
	hMTCountSurvival = CreateConVar("multitanks_count_survival", "2", "Total Count Of Tanks (Survival)", FCVAR_NOTIFY|FCVAR_SPONLY);
	hMTHealthScavenge = CreateConVar("multitanks_health_scavenge", "17500", "Health Of Tanks (Scavenge)", FCVAR_NOTIFY|FCVAR_SPONLY);
	hMTCountScavenge = CreateConVar("multitanks_count_scavenge", "2", "Total Count Of Tanks (Scavenge)", FCVAR_NOTIFY|FCVAR_SPONLY);
	hMTAnnounce = CreateConVar("multitanks_announce", "1", "Enable/Disable Announcements", FCVAR_NOTIFY|FCVAR_SPONLY);
	hMTDisplay = CreateConVar("multitanks_display", "0", "Enable/Disable HUD Display", FCVAR_NOTIFY|FCVAR_SPONLY);
	
	iMTHealthSurvival = hMTHealthSurvival.IntValue;
	iMTCountSurvival = hMTCountSurvival.IntValue;
	iMTHealthScavenge = hMTHealthScavenge.IntValue;
	iMTCountScavenge = hMTCountScavenge.IntValue;
	
	bMTOn = hMTOn.BoolValue;
	bMTAnnounce = hMTAnnounce.BoolValue;
	bMTDisplay = hMTDisplay.BoolValue;
	
	hMTOn.AddChangeHook(OnMTCVarsChanged);
	hMTHealthSurvival.AddChangeHook(OnMTCVarsChanged);
	hMTCountSurvival.AddChangeHook(OnMTCVarsChanged);
	hMTHealthScavenge.AddChangeHook(OnMTCVarsChanged);
	hMTCountScavenge.AddChangeHook(OnMTCVarsChanged);
	hMTAnnounce.AddChangeHook(OnMTCVarsChanged);
	hMTDisplay.AddChangeHook(OnMTCVarsChanged);
	
	char sDescriptions[3][128];
	for (int i = 0; i < 2; i++)
	{
		StripQuotes(sLabels[i]);
		
		Format(sDescriptions[0], 128, "multitanks_spawn_delay_%s", sLabels[(i == 0) ? i : i + 3]);
		switch (i)
		{
			case 0:
			{
				strcopy(sDescriptions[1], 128, "5.0");
				strcopy(sDescriptions[2], 128, "Delay Of Spawning Tanks");
			}
			case 1:
			{
				strcopy(sDescriptions[1], 128, "2.5");
				strcopy(sDescriptions[2], 128, "Delay Of Spawning Tanks In Finale Escapes");
			}
		}
		
		hMTSpawnDelay[i] = CreateConVar(sDescriptions[0], sDescriptions[1], sDescriptions[2], FCVAR_NOTIFY|FCVAR_SPONLY);
		fMTSpawnDelay[i] = hMTSpawnDelay[i].FloatValue;
		hMTSpawnDelay[i].AddChangeHook(OnMTCVarsChanged);
	}
	
	for (int i = 0; i < 5; i++)
	{
		StripQuotes(sLabels[i]);
		
		Format(sDescriptions[0], 128, "multitanks_health_coop_%s", sLabels[i]);
		switch (i)
		{
			case 0:
			{
				strcopy(sDescriptions[1], 128, "17500");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In Regular Maps");
			}
			case 1:
			{
				strcopy(sDescriptions[1], 128, "20000");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In Finale Maps");
			}
			case 2:
			{
				strcopy(sDescriptions[1], 128, "25000");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In First Wave Finales");
			}
			case 3:
			{
				strcopy(sDescriptions[1], 128, "27500");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In Second Wave Finales");
			}
			case 4:
			{
				strcopy(sDescriptions[1], 128, "22500");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In Finale Escapes");
			}
		}
		
		hMTHealthCoop[i] = CreateConVar(sDescriptions[0], sDescriptions[1], sDescriptions[2], FCVAR_NOTIFY|FCVAR_SPONLY);
		
		Format(sDescriptions[0], 128, "multitanks_count_coop_%s", sLabels[i]);
		strcopy(sDescriptions[1], 128, "1");
		switch (i)
		{
			case 0: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In Regular Maps");
			case 1: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In Finale Maps");
			case 2: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In First Wave Finales");
			case 3: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In Second Wave Finales");
			case 4: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In Finale Escapes");
		}
		
		hMTCountCoop[i] = CreateConVar(sDescriptions[0], sDescriptions[1], sDescriptions[2], FCVAR_NOTIFY|FCVAR_SPONLY);
		
		iMTHealthCoop[i] = hMTHealthCoop[i].IntValue;
		iMTCountCoop[i] = hMTCountCoop[i].IntValue;
		
		hMTHealthCoop[i].AddChangeHook(OnMTCVarsChanged);
		hMTCountCoop[i].AddChangeHook(OnMTCVarsChanged);
		
		Format(sDescriptions[0], 128, "multitanks_health_versus_%s", sLabels[i]);
		switch (i)
		{
			case 0:
			{
				strcopy(sDescriptions[1], 128, "15000");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In Regular Maps (Versus)");
			}
			case 1:
			{
				strcopy(sDescriptions[1], 128, "17500");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In Finale Maps (Versus)");
			}
			case 2:
			{
				strcopy(sDescriptions[1], 128, "22500");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In First Wave Finales (Versus)");
			}
			case 3:
			{
				strcopy(sDescriptions[1], 128, "25000");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In Second Wave Finales (Versus)");
			}
			case 4:
			{
				strcopy(sDescriptions[1], 128, "20000");
				strcopy(sDescriptions[2], 128, "Health Of Tanks In Finale Escapes (Versus)");
			}
		}
		
		hMTHealthVersus[i] = CreateConVar(sDescriptions[0], sDescriptions[1], sDescriptions[2], FCVAR_NOTIFY|FCVAR_SPONLY);
		
		Format(sDescriptions[0], 128, "multitanks_count_versus_%s", sLabels[i]);
		strcopy(sDescriptions[1], 128, "2");
		switch (i)
		{
			case 0: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In Regular Maps (Versus)");
			case 1: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In Finale Maps (Versus)");
			case 2: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In First Wave Finales (Versus)");
			case 3: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In Second Wave Finales (Versus)");
			case 4: strcopy(sDescriptions[2], 128, "Total Count Of Tanks In Finale Escapes (Versus)");
		}
		
		hMTCountVersus[i] = CreateConVar(sDescriptions[0], sDescriptions[1], sDescriptions[2], FCVAR_NOTIFY|FCVAR_SPONLY);
		
		iMTHealthVersus[i] = hMTHealthVersus[i].IntValue;
		iMTCountVersus[i] = hMTCountVersus[i].IntValue;
		
		hMTHealthVersus[i].AddChangeHook(OnMTCVarsChanged);
		hMTCountVersus[i].AddChangeHook(OnMTCVarsChanged);
		
		if (i == 0 || i == 1 || i == 4)
		{
			Format(sDescriptions[0], 128, "multitanks_same_spawn_%s", sLabels[i]);
			strcopy(sDescriptions[1], 128, "0");
			switch (i)
			{
				case 0: strcopy(sDescriptions[2], 128, "Enable/Disable Same Spawn Of Tanks In Regular Maps");
				case 1: strcopy(sDescriptions[2], 128, "Enable/Disable Same Spawn Of Tanks In Finale Maps");
				case 4: strcopy(sDescriptions[2], 128, "Enable/Disable Same Spawn Of Tanks In Finale Escapes");
			}
			
			hMTSameSpawn[(i == 4) ? i - 2 : i] = CreateConVar(sDescriptions[0], sDescriptions[1], sDescriptions[2], FCVAR_NOTIFY|FCVAR_SPONLY);
			bMTSameSpawn[(i == 4) ? i - 2 : i] = hMTSameSpawn[(i == 4) ? i - 2 : i].BoolValue;
			hMTSameSpawn[(i == 4) ? i - 2 : i].AddChangeHook(OnMTCVarsChanged);
		}
	}
	
	AutoExecConfig(true, "multitanks");
	
	HookEvent("round_start", OnRoundEvents);
	HookEvent("round_end", OnRoundEvents);
	
	HookEvent("finale_start", OnFinaleEvents);
	HookEvent("finale_escape_start", OnFinaleEvents);
	HookEvent("finale_vehicle_leaving", OnFinaleEvents);
	
	HookEvent("tank_frustrated", OnTankFrustrated);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("tank_spawn", OnTankSpawn);
}

public void OnMTCVarsChanged(ConVar cvar, const char[] sOldValue, const char[] sNewValue)
{
	bMTOn = hMTOn.BoolValue;
	bMTAnnounce = hMTAnnounce.BoolValue;
	bMTDisplay = hMTDisplay.BoolValue;
	
	for (int i = 0; i < 5; i++)
	{
		if (i == 0 || i == 1 || i == 4)
		{
			bMTSameSpawn[(i != 4) ? i : i - 2] = hMTSameSpawn[(i != 4) ? i : i - 2].BoolValue;
		}
		
		iMTHealthCoop[i] = hMTHealthCoop[i].IntValue;
		iMTCountCoop[i] = hMTCountCoop[i].IntValue;
		
		iMTHealthVersus[i] = hMTHealthVersus[i].IntValue;
		iMTCountVersus[i] = hMTCountVersus[i].IntValue;
	}
	
	iMaxZombies = (FindConVar("super_versus_version") != null) ? FindConVar("super_versus_infected_limit").IntValue : FindConVar("z_max_player_zombies").IntValue;
	
	iMTHealthSurvival = hMTHealthSurvival.IntValue;
	iMTCountSurvival = hMTCountSurvival.IntValue;
	iMTHealthScavenge = hMTHealthScavenge.IntValue;
	iMTCountScavenge = hMTCountScavenge.IntValue;
	
	for (int i = 0; i < 2; i++)
	{
		fMTSpawnDelay[i] = hMTSpawnDelay[i].FloatValue;
	}
	if (bMTOn)
	{
		gmsBase = GetGameModeInfo();
		LaunchMTParameters();
	}
}

public void OnPluginEnd()
{
	hMTOn.RemoveChangeHook(OnMTCVarsChanged);
	hMTHealthSurvival.RemoveChangeHook(OnMTCVarsChanged);
	hMTCountSurvival.RemoveChangeHook(OnMTCVarsChanged);
	hMTHealthScavenge.RemoveChangeHook(OnMTCVarsChanged);
	hMTCountScavenge.RemoveChangeHook(OnMTCVarsChanged);
	hMTAnnounce.RemoveChangeHook(OnMTCVarsChanged);
	hMTDisplay.RemoveChangeHook(OnMTCVarsChanged);
	for (int i = 0; i < 2; i++)
	{
		hMTSpawnDelay[i].RemoveChangeHook(OnMTCVarsChanged);
	}
	
	for (int i = 0; i < 5; i++)
	{
		hMTHealthCoop[i].RemoveChangeHook(OnMTCVarsChanged);
		hMTCountCoop[i].RemoveChangeHook(OnMTCVarsChanged);
		
		hMTHealthVersus[i].RemoveChangeHook(OnMTCVarsChanged);
		hMTCountVersus[i].RemoveChangeHook(OnMTCVarsChanged);
		
		if (i == 0 || i == 1 || i == 4)
		{
			hMTSameSpawn[(i == 4) ? i - 2 : i].RemoveChangeHook(OnMTCVarsChanged);
		}
	}
	
	UnhookEvent("round_start", OnRoundEvents);
	UnhookEvent("round_end", OnRoundEvents);
	
	UnhookEvent("finale_start", OnFinaleEvents);
	UnhookEvent("finale_escape_start", OnFinaleEvents);
	UnhookEvent("finale_vehicle_leaving", OnFinaleEvents);
	
	UnhookEvent("tank_frustrated", OnTankFrustrated);
	UnhookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	UnhookEvent("tank_spawn", OnTankSpawn);
}

public void OnRoundEvents(Event event, const char[] name, bool dontBroadcast)
{
	if (!bMTOn)
	{
		return;
	}
	
	if (StrEqual(name, "round_start"))
	{
		bRoundBegan = true;
		bRoundFinished = false;
		
		msBase = MS_REGULAR;
	}
	else if (StrEqual(name, "round_end"))
	{
		bRoundBegan = false;
		bRoundFinished = true;
		
		msBase = MS_ROUNDEND;
	}
	LaunchMTParameters();
	
	iTankCount = 0;
	iFinaleWave = 0;
	
	bFirstSpawned = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			iFrustration[i] = 0;
			
			bIsTank[i] = false;
			bFrustrated[i] = false;
		}
	}
}

public void OnFinaleEvents(Event event, const char[] name, bool dontBroadcast)
{
	if (!bMTOn)
	{
		return;
	}
	
	if (StrEqual(name, "finale_start") || StrEqual(name, "finale_vehicle_leaving"))
	{
		iFinaleWave = 0;
	}
	
	if (StrEqual(name, "finale_start"))
	{
		msBase = MS_FINALE;
	}
	else if (StrEqual(name, "finale_escape_start"))
	{
		msBase = MS_ESCAPE;
	}
	else if (StrEqual(name, "finale_vehicle_leaving"))
	{
		msBase = MS_LEAVING;
	}
	LaunchMTParameters();
}

public void OnTankFrustrated(Event event, const char[] name, bool dontBroadcast)
{
	if (!bMTOn)
	{
		return;
	}
	
	int tank = GetClientOfUserId(event.GetInt("userid"));
	if (!IsTank(tank))
	{
		return;
	}
	
	bFrustrated[tank] = true;
	
	if (bMTAnnounce)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == 3 && !IsFakeClient(i))
			{
				PrintToChat(i, "\x04[MT]\x01 %N Lost Control!", tank);
			}
		}
	}
}

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bMTOn)
	{
		return Plugin_Continue;
	}
	
	int died = GetClientOfUserId(event.GetInt("userid"));
	if (!IsTank(died))
	{
		return Plugin_Continue;
	}
	
	if (iTankCount > 0)
	{
		iTankCount -= 1;
		if (iTankCount <= 0)
		{
			bFirstSpawned = false;
		}
	}
	
	if (bFrustrated[died])
	{
		bFrustrated[died] = false;
	}
	bIsTank[died] = false;
	
	return Plugin_Continue;
}

public void OnTankSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!bMTOn)
	{
		return;
	}
	
	int tank = GetClientOfUserId(event.GetInt("userid"));
	if (!tank)
	{
		return;
	}
	
	if (!bIsTank[tank])
	{
		bIsTank[tank] = true;
		
		if (!bFirstSpawned && msBase == MS_FINALE)
		{
			bFirstSpawned = true;
			
			iFinaleWave += 1;
			LaunchMTParameters();
		}
		
		SetEntProp(tank, Prop_Send, "m_iHealth", iTankHP, 1);
		SetEntProp(tank, Prop_Send, "m_iMaxHealth", iTankHP, 1);
		
		if ((msBase == MS_ESCAPE) ? bMTSameSpawn[2] : ((msBase != MS_FINALE) ? bMTSameSpawn[1] : bMTSameSpawn[0]))
		{
			if (iTankCount <= 0)
			{
				GetEntPropVector(tank, Prop_Send, "m_vecOrigin", fTankPos);
			}
			else
			{
				TeleportEntity(tank, fTankPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
		
		iTankCount += 1;
		if (iTankCount < iMaxTankCount)
		{
			ChangeInfectedLimits(iMaxZombies + iMaxTankCount);
			CreateTimer((msBase != MS_ESCAPE) ? fMTSpawnDelay[0] : fMTSpawnDelay[1], SpawnMoreTank);
		}
		else
		{
			ChangeInfectedLimits(iMaxZombies);
		}
		
		if (bMTAnnounce && msBase != MS_ROUNDEND)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					if (GetClientTeam(i) == 3)
					{
						if (IsFakeClient(tank))
						{
							PrintToChat(i, "\x04[MT]\x01 New Tank Spawning (%i HP) [AI]", iTankHP);
						}
						else
						{
							PrintToChat(i, "\x04[MT]\x01 New Tank Spawning (%i HP) [%N]", iTankHP, tank);
						}
					}
					else
					{
						PrintToChat(i, "\x04[MT]\x01 New Tank Spawning (%i HP)", iTankHP);
					}
				}
			}
		}
	}
	else
	{
		if (bFrustrated[tank])
		{
			bFrustrated[tank] = false;
		}
		SetEntProp(tank, Prop_Send, "m_iMaxHealth", iTankHP, 1);
	}
	
	if (!IsFakeClient(tank))
	{
		CreateTimer(10.0, CheckFrustration, GetClientUserId(tank));
	}
	
	if (bMTDisplay)
	{
		pMTList = new Panel();
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == 3 && GetEntProp(i, Prop_Send, "m_zombieClass") == 8 && IsPlayerAlive(i) && !GetEntProp(i, Prop_Send, "m_isIncapacitated", 1))
			{
				char sText[128];
				if (IsPlayerBurning(i))
				{
					Format(sText, sizeof(sText), "%N: %i HP (FIRE)", i, GetEntProp(i, Prop_Send, "m_iHealth"));
				}
				else
				{
					Format(sText, sizeof(sText), "%N: %i HP, Control: %i％", i, GetEntProp(i, Prop_Send, "m_iHealth"), 100 - GetEntProp(i, Prop_Send, "m_frustration"));
				}
				pMTList.DrawText(sText);
			}
		}
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) != 2 && !IsFakeClient(i))
			{
				pMTList.Send(i, MTListHandler, 1);
			}
		}
		delete pMTList;
	}
}

public Action SpawnMoreTank(Handle timer)
{
	if (!bMTOn || !bRoundBegan || bRoundFinished)
	{
		return Plugin_Stop;
	}
	
	int iCommandExecuter = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			iCommandExecuter = i;
			break;
		}
	}
	
	if(iCommandExecuter == 0) return Plugin_Stop;
	
	float vecPos[3];
	if(L4D_GetRandomPZSpawnPosition(iCommandExecuter,8,5,vecPos) == true)
	{
		int bot = SDKCall(hCreateTank, "MultiTank"); //召喚坦克
		if (bot > 0 && bot <= MaxClients && IsClientInGame(bot))
		{
			SetEntityModel(bot, "models/infected/hulk.mdl");
			ChangeClientTeam(bot, 3);
			SetEntProp(bot, Prop_Send, "m_usSolidFlags", 16);
			SetEntProp(bot, Prop_Send, "movetype", 2);
			SetEntProp(bot, Prop_Send, "deadflag", 0);
			SetEntProp(bot, Prop_Send, "m_lifeState", 0);
			SetEntProp(bot, Prop_Send, "m_iObserverMode", 0);
			SetEntProp(bot, Prop_Send, "m_iPlayerState", 0);
			SetEntProp(bot, Prop_Send, "m_zombieState", 0);
			DispatchSpawn(bot);
			ActivateEntity(bot);
			TeleportEntity(bot, vecPos, NULL_VECTOR, NULL_VECTOR); //移動到相同位置
		}
	}
	
	return Plugin_Stop;
}

public Action CheckFrustration(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsTank(client) || !IsPlayerAlive(client) || IsFakeClient(client))
	{
		return Plugin_Stop;
	}
	
	int iFrustrationProgress = GetEntProp(client, Prop_Send, "m_frustration");
	if (iFrustrationProgress >= 95)
	{
		if (!IsPlayerBurning(client))
		{
			iFrustration[client] += 1;
			if (iFrustration[client] < 2)
			{
				SetEntProp(client, Prop_Send, "m_frustration", 0);
				CreateTimer(0.1, CheckFrustration, GetClientUserId(client));
				
				for (int i = 1; i <= MaxClients; i++)
				{	
					if (IsClientInGame(i) && GetClientTeam(i) == 3 && !IsFakeClient(i))
					{
						PrintToChat(i, "\x04[MT]\x01 %N Lost First Tank Control!", client);
					}
				}
			}
		}
		else
		{
			CreateTimer(0.1, CheckFrustration, GetClientUserId(client));
		}
	}
	else
	{
		CreateTimer(0.1 + (95 - iFrustrationProgress) * 0.1, CheckFrustration, GetClientUserId(client));
	}
	return Plugin_Stop;
}

public int MTListHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		if (bMTDisplay)
		{
			pMTList = new Panel();
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) == 3 && GetEntProp(i, Prop_Send, "m_zombieClass") == 8 && IsPlayerAlive(i) && !GetEntProp(i, Prop_Send, "m_isIncapacitated", 1))
				{
					char sText[128];
					if (IsPlayerBurning(i))
					{
						Format(sText, sizeof(sText), "%N: %i HP (FIRE)", i, GetEntProp(i, Prop_Send, "m_iHealth"));
					}
					else
					{
						Format(sText, sizeof(sText), "%N: %i HP, Control: %i％", i, GetEntProp(i, Prop_Send, "m_iHealth"), 100 - GetEntProp(i, Prop_Send, "m_frustration"));
					}
					pMTList.DrawText(sText);
				}
			}
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) != 2 && !IsFakeClient(i))
				{
					pMTList.Send(i, MTListHandler, 1);
				}
			}
			delete pMTList;
		}
	}
}

GameModeStatus GetGameModeInfo()
{
	char sGameMode[16];
	hGameMode.GetString(sGameMode, sizeof(sGameMode));
	if (StrEqual(sGameMode, "coop", false) || StrEqual(sGameMode, "realism", false))
	{
		return GMS_COOP;
	}
	else if (StrEqual(sGameMode, "versus", false) || StrEqual(sGameMode, "teamversus", false))
	{
		return GMS_VERSUS;
	}
	else if (StrEqual(sGameMode, "survival", false))
	{
		return GMS_SURVIVAL;
	}
	else if (StrEqual(sGameMode, "scavenge", false) || StrEqual(sGameMode, "teamscavenge", false))
	{
		return GMS_SCAVENGE;
	}
	else
	{
		return GMS_UNKNOWN;
	}
}

void LaunchMTParameters()
{
	switch (gmsBase)
	{
		case GMS_COOP:
		{
			switch (msBase)
			{
				case MS_REGULAR:
				{
					iTankHP = (L4D_IsMissionFinalMap()) ? iMTHealthCoop[1] : iMTHealthCoop[0];
					iMaxTankCount = (L4D_IsMissionFinalMap()) ? iMTCountCoop[1] : iMTCountCoop[0];
				}
				case MS_FINALE:
				{
					iTankHP = (iFinaleWave == 2) ? iMTHealthCoop[3] : iMTHealthCoop[2];
					iMaxTankCount = (iFinaleWave == 2) ? iMTCountCoop[3] : iMTCountCoop[2];
				}
				case MS_ESCAPE:
				{
					iTankHP = iMTHealthCoop[4];
					iMaxTankCount = iMTCountCoop[4];
				}
				case MS_LEAVING: iMaxTankCount = 0;
				case MS_ROUNDEND: iMaxTankCount = 0;
			}
		}
		case GMS_VERSUS: 
		{
			switch (msBase)
			{
				case MS_REGULAR:
				{
					iTankHP = (L4D_IsMissionFinalMap()) ? iMTHealthVersus[1] : iMTHealthVersus[0]; 	
					iMaxTankCount = (L4D_IsMissionFinalMap()) ? iMTCountVersus[1] : iMTCountVersus[0];
				}
				case MS_FINALE:
				{
					iTankHP = (iFinaleWave == 2) ? iMTHealthVersus[3] : iMTHealthVersus[2];
					iMaxTankCount = (iFinaleWave == 2) ? iMTCountVersus[3] : iMTCountVersus[2];
				}
				case MS_ESCAPE:
				{
					iTankHP = iMTHealthVersus[4];
					iMaxTankCount = iMTCountVersus[4];
				}
				case MS_LEAVING: iMaxTankCount = 0;
				case MS_ROUNDEND: iMaxTankCount = 0;
			}
		}
		case GMS_SURVIVAL: 
		{
			iTankHP = iMTHealthSurvival;
			iMaxTankCount = iMTCountSurvival;
		}
		case GMS_SCAVENGE: 
		{
			iTankHP = iMTHealthScavenge;
			iMaxTankCount = iMTCountScavenge;
		}
		case GMS_UNKNOWN: 
		{
			iTankHP = 12500;
			iMaxTankCount = 1;
		}
	}
}

void ChangeInfectedLimits(int iValue)
{
	if (FindConVar("super_versus_version") == null)
	{
		FindConVar("z_max_player_zombies").SetInt(iValue, true, false);
	}
	else
	{
		int iFlags = FindConVar("super_versus_infected_limit").Flags;
		FindConVar("super_versus_infected_limit").Flags = iFlags & ~FCVAR_NOTIFY;
		FindConVar("super_versus_infected_limit").SetInt(iValue);
		FindConVar("super_versus_infected_limit").Flags = iFlags;
	}
}

bool IsTank(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3 && GetEntProp(client, Prop_Send, "m_zombieClass") == 8);
}

bool IsPlayerBurning(int client)
{
	float fBurning = GetEntDataFloat(client, FindSendPropInfo("CTerrorPlayer", "m_burnPercent"));
	return (fBurning > 0.0) ? true : false;
}

