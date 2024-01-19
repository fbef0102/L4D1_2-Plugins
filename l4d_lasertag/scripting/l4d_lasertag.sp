#pragma newdecls required
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0h-2024/1/20"

public Plugin myinfo = 
{
	name = "[L4D(2)] Laser Tag",
	author = "KrX/Whosat, HarryPotter",
	description = "Shows a laser for straight-flying fired projectiles",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1203196"
}

bool isL4D2;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		isL4D2 = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		isL4D2 = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

#define DEFAULT_FLAGS FCVAR_NONE|FCVAR_NOTIFY

#define WEAPONTYPE_PISTOL   6
#define WEAPONTYPE_RIFLE    5
#define WEAPONTYPE_SNIPER   4
#define WEAPONTYPE_SMG      3
#define WEAPONTYPE_SHOTGUN  2
#define WEAPONTYPE_MELEE    1
#define WEAPONTYPE_UNKNOWN  0

ConVar cvar_vsenable;
ConVar cvar_realismenable;
ConVar cvar_bots;
ConVar cvar_enable;

ConVar cvar_pistols;
ConVar cvar_rifles;
ConVar cvar_snipers;
ConVar cvar_smgs;
ConVar cvar_shotguns;

ConVar cvar_laser_random, cvar_laser_rgb, cvar_laser_alpha;

ConVar cvar_bots_random, cvar_bots_rgb, cvar_bots_alpha;

ConVar cvar_laser_life;
ConVar cvar_laser_width;
ConVar cvar_laser_offset;
ConVar g_hCvarMPGameMode;
ConVar g_hAccesslvl;

char g_sAccesslvl[16]

bool g_LaserTagEnable = true;
bool g_Bots;
bool g_blaser_random, g_bbots_random;

bool b_TagWeapon[7];
float g_LaserOffset;
float g_LaserWidth;
float g_LaserLife;
int 
	g_LaserColor[4],
	g_BotsLaserColor[4],
	g_Sprite,
	g_iCurrentMode,
	g_iAccessFlag[MAXPLAYERS+1];

StringMap 
	g_smWeaponType;

public void OnPluginStart()
{	
	cvar_enable = CreateConVar("l4d_lasertag_enable", "1", "Turnon Lasertagging. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
 	cvar_vsenable = CreateConVar("l4d_lasertag_vs", "1", "Enable or Disable Lasertagging in Versus / Scavenge. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_realismenable = CreateConVar("l4d_lasertag_coop", "1", "Enable or Disable Lasertagging in Coop / Realism. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_bots = CreateConVar("l4d_lasertag_bots", "1", "Enable or Disable lasertagging for bots. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	cvar_pistols = CreateConVar("l4d_lasertag_pistols", "1", "LaserTagging for Pistols. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_rifles = CreateConVar("l4d_lasertag_rifles", "1", "LaserTagging for Rifles. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_snipers = CreateConVar("l4d_lasertag_snipers", "1", "LaserTagging for Sniper Rifles. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_smgs = CreateConVar("l4d_lasertag_smgs", "1", "LaserTagging for SMGs. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_shotguns = CreateConVar("l4d_lasertag_shotguns", "1", "LaserTagging for Shotguns. 0=disable, 1=enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
		
	cvar_laser_random = CreateConVar("l4d_lasertag_random", "1", "If 1, Enable Lasertagging Random Color.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_laser_rgb = CreateConVar("l4d_lasertag_rgb", "0 125 255", "Lasertagging Color. Three values between 0-255 separated by spaces. RGB: Red Green Blue.", FCVAR_NOTIFY);
	cvar_laser_alpha = CreateConVar("l4d_lasertag_alpha", "100", "Transparency (Alpha) of Laser", FCVAR_NONE, true, 0.0, true, 255.0);

	cvar_bots_random = CreateConVar("l4d_lasertag_bots_random", "1", "If 1, Enable Random Color for Bot.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvar_bots_rgb = CreateConVar("l4d_lasertag_bots_rgb", "0 255 75", "Bots Laser - Color. Three values between 0-255 separated by spaces. RGB: Red Green Blue.", FCVAR_NOTIFY);
	cvar_bots_alpha = CreateConVar("l4d_lasertag_bots_alpha", "70", "Bots Laser - Transparency (Alpha) of Laser", FCVAR_NONE, true, 0.0, true, 255.0);

	cvar_laser_life = CreateConVar("l4d_lasertag_life", "0.80", "Seconds Laser will remain", FCVAR_NOTIFY, true, 0.1);
	cvar_laser_width = CreateConVar("l4d_lasertag_width", "1.0", "Width of Laser", FCVAR_NOTIFY, true, 1.0);
	cvar_laser_offset = CreateConVar("l4d_lasertag_offset", "36", "Lasertag Offset", FCVAR_NOTIFY);
	g_hAccesslvl = 		CreateConVar("l4d_lasertag_access_flag", 	"", 	"Players with these flags have Lasertagging. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);

	CreateConVar("l4d_lasertag_version", PLUGIN_VERSION, "Lasertag Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	AutoExecConfig(true, "l4d_lasertag");

	HookEvent("bullet_impact", 		Event_BulletImpact);
	HookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	HookEvent("round_start",		Event_RoundStart,	EventHookMode_PostNoCopy);
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarGameMode);
	cvar_enable.AddChangeHook(ConVarChanged_CheckEnabled);
	cvar_vsenable.AddChangeHook(ConVarChanged_CheckEnabled);
	cvar_realismenable.AddChangeHook(ConVarChanged_CheckEnabled);
	cvar_bots.AddChangeHook(ConVarChanged_CheckEnabled);
	
	cvar_pistols.AddChangeHook(UselessHooker);
	cvar_rifles.AddChangeHook(UselessHooker);
	cvar_snipers.AddChangeHook(UselessHooker);
	cvar_smgs.AddChangeHook(UselessHooker);
	cvar_shotguns.AddChangeHook(UselessHooker);
	
	cvar_laser_rgb.AddChangeHook(UselessHooker);
	cvar_laser_alpha.AddChangeHook(UselessHooker);
	cvar_bots_rgb.AddChangeHook(UselessHooker);
	cvar_bots_alpha.AddChangeHook(UselessHooker);
	
	cvar_laser_life.AddChangeHook(UselessHooker);
	cvar_laser_width.AddChangeHook(UselessHooker);
	cvar_laser_offset.AddChangeHook(UselessHooker);
	cvar_laser_random.AddChangeHook(UselessHooker);
	cvar_bots_random.AddChangeHook(UselessHooker);
	g_hAccesslvl.AddChangeHook(UselessHooker);

	g_smWeaponType = new StringMap();
	g_smWeaponType.SetValue("weapon_pistol", WEAPONTYPE_PISTOL);
	g_smWeaponType.SetValue("weapon_smg", WEAPONTYPE_SMG);
	g_smWeaponType.SetValue("weapon_pumpshotgun", WEAPONTYPE_SHOTGUN);
	g_smWeaponType.SetValue("weapon_rifle", WEAPONTYPE_RIFLE);
	g_smWeaponType.SetValue("weapon_autoshotgun", WEAPONTYPE_SHOTGUN);
	g_smWeaponType.SetValue("weapon_hunting_rifle", WEAPONTYPE_SNIPER);
	g_smWeaponType.SetValue("weapon_smg_silenced", WEAPONTYPE_SMG);
	g_smWeaponType.SetValue("weapon_smg_mp5", WEAPONTYPE_SMG);
	g_smWeaponType.SetValue("weapon_shotgun_chrome", WEAPONTYPE_SHOTGUN);
	g_smWeaponType.SetValue("weapon_pistol_magnum", WEAPONTYPE_PISTOL);
	g_smWeaponType.SetValue("weapon_rifle_ak47", WEAPONTYPE_RIFLE);
	g_smWeaponType.SetValue("weapon_rifle_desert", WEAPONTYPE_RIFLE);
	g_smWeaponType.SetValue("weapon_sniper_military", WEAPONTYPE_SNIPER);
	//g_smWeaponType.SetValue("weapon_grenade_launcher", 0);
	g_smWeaponType.SetValue("weapon_rifle_sg552", WEAPONTYPE_RIFLE);
	g_smWeaponType.SetValue("weapon_rifle_m60", WEAPONTYPE_RIFLE);
	g_smWeaponType.SetValue("weapon_sniper_awp", WEAPONTYPE_SNIPER);
	g_smWeaponType.SetValue("weapon_sniper_scout", WEAPONTYPE_SNIPER);
	g_smWeaponType.SetValue("weapon_shotgun_spas", WEAPONTYPE_SHOTGUN);
}

public void OnPluginEnd()
{
	ResetPlugin();
}

bool g_ReadyUpAvailable;
public void OnAllPluginsLoaded()
{
	g_ReadyUpAvailable = LibraryExists("readyup");
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "readyup") == 0) g_ReadyUpAvailable = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "readyup")) g_ReadyUpAvailable = true;
}

bool g_bMapStarted;
public void OnMapStart()
{
	g_bMapStarted = true;
	if(isL4D2)
	{
		g_Sprite = PrecacheModel("materials/sprites/laserbeam.vmt");			
	}
	else
	{
		g_Sprite = PrecacheModel("materials/sprites/laser.vmt");		
	}
}

public void OnMapEnd()
{
	ResetPlugin();
	g_bMapStarted = false;
}

void ConVarGameMode(ConVar convar, const char[] oldValue, const char[] newValue)
{
	CheckGameMode();
}

void ConVarChanged_CheckEnabled(ConVar convar, const char[] oldValue, const char[] newValue)
{
	CheckEnabled();
}

void UselessHooker(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	char sRGB[12];
	cvar_laser_rgb.GetString(sRGB, sizeof(sRGB));
	GetColor(sRGB, g_LaserColor);
	g_LaserColor[3] = cvar_laser_alpha.IntValue;

	cvar_bots_rgb.GetString(sRGB, sizeof(sRGB));
	GetColor(sRGB, g_BotsLaserColor);
	g_BotsLaserColor[3] = cvar_bots_alpha.IntValue;
	
	g_LaserLife = cvar_laser_life.FloatValue;
	g_LaserWidth = cvar_laser_width.FloatValue;
	g_LaserOffset = cvar_laser_offset.FloatValue;

	g_blaser_random = cvar_laser_random.BoolValue;
	g_bbots_random = cvar_bots_random.BoolValue;
	g_hAccesslvl.GetString(g_sAccesslvl,sizeof(g_sAccesslvl));

	b_TagWeapon[WEAPONTYPE_PISTOL] = cvar_pistols.BoolValue;
	b_TagWeapon[WEAPONTYPE_RIFLE] = cvar_rifles.BoolValue;
	b_TagWeapon[WEAPONTYPE_SNIPER] = cvar_snipers.BoolValue;
	b_TagWeapon[WEAPONTYPE_SMG] = cvar_smgs.BoolValue;
	b_TagWeapon[WEAPONTYPE_SHOTGUN] = cvar_shotguns.BoolValue;
}

void CheckGameMode()
{
	if( g_bMapStarted == false )
	{
		g_iCurrentMode = -1;
		return;
	}

	if( g_hCvarMPGameMode == null )
	{
		g_iCurrentMode = -1;
		return;
	}

	int entity = CreateEntityByName("info_gamemode");
	if( IsValidEntity(entity) )
	{
		DispatchSpawn(entity);
		HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "PostSpawnActivate");
		if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
			RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
	}
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 3;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 4;
	else
		g_iCurrentMode = -1;
}

public void OnConfigsExecuted()
{
	CheckGameMode();
	GetCvars();
	CheckEnabled();
}

void CheckEnabled()
{
	// Bot Laser Tagging?
	g_Bots = cvar_bots.BoolValue;
	
	if(cvar_enable.IntValue == 0)
	{
		// IS GLOBALLY ENABLED?
		g_LaserTagEnable = false;
	}
	else if((g_iCurrentMode == 2 || g_iCurrentMode == 4) && cvar_vsenable.IntValue == 0)
	{
		// IS VS Enabled?
		g_LaserTagEnable = false;
	}
	else if(g_iCurrentMode == 1 && cvar_realismenable.IntValue == 0)
	{
		// IS Coop/REALISM ENABLED?
		g_LaserTagEnable = false;
	}
	else
	{
		// None of the above fulfilled, enable plugin.
		g_LaserTagEnable = true;
	}
}

int GetWeaponType(int userid)
{
	// Get current weapon
	char weapon[32];
	GetClientWeapon(userid, weapon, 32);
	//PrintToChatAll("%s", weapon);
	
	int type = WEAPONTYPE_UNKNOWN;
	if(g_smWeaponType.GetValue(weapon, type) == false) return WEAPONTYPE_UNKNOWN;

	return type;
}

int g_iPlayerSpawn, g_iRoundStart;
void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, TimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, TimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;

	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!client || !IsClientInGame(client) || IsFakeClient(client)) return;

	g_iAccessFlag[client] = GetUserFlagBits(client);
}

Action TimerStart(Handle timer)
{
	ResetPlugin();
	if(g_ReadyUpAvailable) cvar_enable.SetBool(true);

	return Plugin_Continue;
}

public void OnRoundIsLive() {
	cvar_enable.SetBool(false);
}

void Event_BulletImpact(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_LaserTagEnable) return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
 	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2) return;

	bool isbot = false;
	if(IsFakeClient(client)) 
	{
		if(!g_Bots) return;
		isbot = true; 
	}

	if(HasAccess(client, g_sAccesslvl) == false) return;
	
	// Check if the weapon is an enabled weapon type to tag
	if(b_TagWeapon[GetWeaponType(client)])
	{
		// Bullet impact location
		float x = GetEventFloat(event, "x");
		float y = GetEventFloat(event, "y");
		float z = GetEventFloat(event, "z");
		
		float startPos[3];
		startPos[0] = x;
		startPos[1] = y;
		startPos[2] = z;
		
		/*float bulletPos[3];
		bulletPos[0] = x;
		bulletPos[1] = y;
		bulletPos[2] = z;*/
		
		float bulletPos[3];
		bulletPos = startPos;
		
		// Current player's EYE position
		float playerPos[3];
		GetClientEyePosition(client, playerPos);
		
		float lineVector[3];
		SubtractVectors(playerPos, startPos, lineVector);
		NormalizeVector(lineVector, lineVector);
		
		// Offset
		ScaleVector(lineVector, g_LaserOffset);
		// Find starting point to draw line from
		SubtractVectors(playerPos, lineVector, startPos);
		

		// Draw the line
		int LaserColor[4];
		int BotsLaserColor[4];
		if(!isbot){
			if(g_blaser_random)
			{
				LaserColor[0] = GetRandomInt(0, 255);
				LaserColor[1] = GetRandomInt(0, 255);
				LaserColor[2] = GetRandomInt(0, 255);
				LaserColor[3] = cvar_laser_alpha.IntValue;
				TE_SetupBeamPoints(startPos, bulletPos, g_Sprite, 0, 0, 0, g_LaserLife, g_LaserWidth, g_LaserWidth, 1, 0.0, LaserColor, 0);
			}
			else
				TE_SetupBeamPoints(startPos, bulletPos, g_Sprite, 0, 0, 0, g_LaserLife, g_LaserWidth, g_LaserWidth, 1, 0.0, g_LaserColor, 0);
		}
		else {
			if(g_bbots_random)
			{
				BotsLaserColor[0] = GetRandomInt(0, 255);
				BotsLaserColor[1] = GetRandomInt(0, 255);
				BotsLaserColor[2] = GetRandomInt(0, 255);
				BotsLaserColor[3] = cvar_bots_alpha.IntValue;
				TE_SetupBeamPoints(startPos, bulletPos, g_Sprite, 0, 0, 0, g_LaserLife, g_LaserWidth, g_LaserWidth, 1, 0.0, BotsLaserColor, 0);
			}
			else
				TE_SetupBeamPoints(startPos, bulletPos, g_Sprite, 0, 0, 0, g_LaserLife, g_LaserWidth, g_LaserWidth, 1, 0.0, g_BotsLaserColor, 0);
		}
		TE_SendToAll();
	}
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

bool HasAccess(int client, char[] g_sAcclvl)
{
	// no permissions set
	if (strlen(g_sAcclvl) == 0)
		return true;

	else if (StrEqual(g_sAcclvl, "-1"))
		return false;

	// check permissions
	if ( g_iAccessFlag[client] & ReadFlagString(g_sAcclvl) 
		|| g_iAccessFlag[client] & ADMFLAG_ROOT )
	{
		return true;
	}

	return false;
}

void GetColor(char[] sTemp, int[] iColor)
{
	iColor[0] = 0;
	iColor[1] = 0;
	iColor[2] = 0;

	if( sTemp[0] == 0 )
		return;

	char sColors[3][4];
	int colornumber = ExplodeString(sTemp, " ", sColors, sizeof(sColors), sizeof(sColors[]));

	if( colornumber != 3 )
		return;

	iColor[0] = StringToInt(sColors[0]);
	iColor[1] = StringToInt(sColors[1]);
	iColor[2] = StringToInt(sColors[2]);
}