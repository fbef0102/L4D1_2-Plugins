#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <l4d2_weapons>
#include <multicolors>

#define PLUGIN_VERSION		"3.5-2024/5/5"

public Plugin myinfo = 
{
	name = "[L4D2] Gifts Drop & Spawn",
	author = "Aceleracion & Harry Potter",
	description = "Drop gifts when a special infected or a tank/witch killed by survivor.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=302731"
}

int ZC_TANK;
bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	
	ZC_TANK = 8;
	bLate = late;
	return APLRes_Success; 
}

#define MAXENTITIES                   2048

#define	MAX_GIFTS			20
#define MAX_STRING_WIDTH	64
#define MAX_TYPEGIFTS		3
#define TYPE_STANDARD		1
#define TYPE_SPECIAL		2
#define STRING_STANDARD		"standard"
#define STRING_SPECIAL		"special"

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

//WeaponName/AmmoOffset/AmmoGive
static char weapon_ammo[][3][64] =
{
	{"weapon_smg",		 				"5", 	"250"},
	{"weapon_pumpshotgun",				"7", 	"40"},
	{"weapon_rifle",					"3", 	"200"},
	{"weapon_autoshotgun",				"8", 	"50"},
	{"weapon_hunting_rifle",			"9", 	"75"},
	{"weapon_smg_silenced",				"5", 	"250"},
	{"weapon_smg_mp5", 	 				"5", 	"250"},
	{"weapon_shotgun_chrome",	 		"7", 	"40"},
	{"weapon_rifle_ak47",  				"3",	"200"},
	{"weapon_rifle_desert",				"3", 	"200"},
	{"weapon_sniper_military",			"10", 	"90"},
	{"weapon_grenade_launcher", 	 	"17", 	"15"},
	{"weapon_rifle_sg552",	 			"3", 	"200"},
	{"weapon_rifle_m60",  				"6",	"200"},
	{"weapon_sniper_awp", 	 			"10", 	"80"},
	{"weapon_sniper_scout",	 			"10", 	"80"},
	{"weapon_shotgun_spas",  			"8",	"50"}
};

#define	MAX_WEAPONS		30
static char g_sWeaponModels[MAX_WEAPONS][] =
{
	"models/w_models/weapons/w_pistol_B.mdl",
	"models/w_models/weapons/w_desert_eagle.mdl",
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_rifle_ak47.mdl",
	"models/w_models/weapons/w_rifle_sg552.mdl",
	"models/w_models/weapons/w_desert_rifle.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_shotgun_spas.mdl",
	"models/w_models/weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_pumpshotgun_A.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_smg_a.mdl",
	"models/w_models/weapons/w_smg_mp5.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_sniper_awp.mdl",
	"models/w_models/weapons/w_sniper_military.mdl",
	"models/w_models/weapons/w_sniper_scout.mdl",
	"models/w_models/weapons/w_m60.mdl",
	"models/w_models/weapons/w_grenade_launcher.mdl",
	"models/weapons/melee/w_chainsaw.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_bile_flask.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl",
	"models/w_models/weapons/w_eq_adrenaline.mdl",
	"models/w_models/weapons/w_eq_Medkit.mdl",
	"models/w_models/weapons/w_eq_defibrillator.mdl",
	"models/w_models/weapons/w_eq_explosive_ammopack.mdl",
	"models/w_models/weapons/w_eq_incendiary_ammopack.mdl",
	"models/props_junk/gnome.mdl"
};

int ColorCyan[3], ColorBlue[3], ColorGreen[3], ColorPink[3], ColorRed[3],
	ColorOrange[3], ColorYellow[3], ColorPurple[3], ColorWhite[3],ColorLime[3],
	ColorMaroon[3], ColorTeal[3], ColorLightGreen[3];

#define ENTITY_SAFE_LIMIT 2000 //don't spawn boxes when it's index is above this

ConVar g_hCvar_gift_enable, g_hCvar_gift_life, g_hCvar_gift_chance,
	g_hCvar_special_gift_chance,
	g_hCvar_gift_infected_hp, g_hCvar_special_gift_infected_hp,
	g_hCvar_gift_Announce, g_hCvar_blockSwitch,
	g_hCvarStandSoundFile, g_hCvarSpecialSoundFile;

bool g_bGiftEnable, g_bCvarBlockSwitch;
float g_fGiftLife;
int g_iGiftChance, g_iSpecialGiftChance,
	g_iGiftHP, g_iSpecialGiftHP;
int g_iCvarAnnounce;
char g_sCvarStandSoundFile[256], g_sCvarSpecialSoundFile[256];

char g_sModel[MAX_GIFTS][MAX_STRING_WIDTH];
char g_sType[MAX_GIFTS][10];
char g_sGift[MAX_GIFTS][10];
float g_fScale[MAX_GIFTS];
char g_sGiftGlowCols[MAX_GIFTS][12],
	g_sGiftEntityCols[MAX_GIFTS][12];

int g_iGiftGlowRange[MAX_GIFTS], 
	g_iSpecialGiftGlowRange[MAX_GIFTS];

int g_iGifType[MAXENTITIES + 1];

char sPath_gifts[PLATFORM_MAX_PATH];
int g_iCountGifts;
int g_iOffset_Incapacitated;        // Used to check if tank is dying
int ammoOffset;	

bool 
	g_bGiftGlowEnable[MAX_GIFTS],
	g_bGiftEntityEnable[MAX_GIFTS],
	g_bFinalHasStart, 
	g_bIsDoorOpen_LockDown,
	g_bHooked[MAXPLAYERS+1],
	g_bMapStart;

StringMap 
	g_smItemsToTranslation;

ArrayList 
	g_aMapMeleeTable,
	g_aStandItemsList,
	g_aSpecialItemsList,
	g_aGiftModelStandard,
	g_aGiftModelSpecial;

int 
	g_iMeleeClassCount;

char 
	g_sMeleeClass[16][32];

public void OnPluginStart()
{
	LoadTranslations("l4d2_gifts.phrases");
	BuildPath(Path_SM, sPath_gifts, PLATFORM_MAX_PATH, "data/l4d2_gifts.cfg");

	ammoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");
	g_iOffset_Incapacitated = FindSendPropInfo("Tank", "m_isIncapacitated");

	g_hCvar_gift_enable	 				= CreateConVar( "l4d2_gifts_enabled",					 	"1", 	"Enable gifts 0: Disable, 1: Enable", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvar_gift_life 					= CreateConVar( "l4d2_gifts_gift_life",					 	"30",	"How long the gift stay on ground (seconds)", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_gift_chance 				= CreateConVar( "l4d2_gifts_chance_standard", 			 	"50",	"Chance (%) of infected drop special standard gift.", FCVAR_NOTIFY, true, 1.0, true, 100.0);
	g_hCvar_special_gift_chance 		= CreateConVar( "l4d2_gifts_chance_special", 			 	"100",	"Chance (%) of tank and witch drop second special gift.", FCVAR_NOTIFY, true, 1.0, true, 100.0);
	g_hCvar_gift_infected_hp 			= CreateConVar( "l4d2_gifts_infected_reward_hp_standard", 	"200",	"Increase Infected health if they pick up gift. (0=Off)", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_special_gift_infected_hp 	= CreateConVar( "l4d2_gifts_infected_reward_hp_special",	"400",	"Increase Infected health if they pick up special gift. (0=Off)", FCVAR_NOTIFY, true, 0.0);
	g_hCvar_gift_Announce 				= CreateConVar( "l4d2_gifts_announce_type",				 	"3",	"Notify Server who pickes up gift, and what the gift reward is. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvar_blockSwitch 				= CreateConVar( "l4d2_gifts_block_switch",				 	"0",	"If 1, prevent survivors from switching into new weapons and items when they open gifts", FCVAR_NOTIFY, true, 0.0);
	g_hCvarStandSoundFile 				= CreateConVar( "l4d2_gifts_soundfile_standard", 			"level/loud/climber.wav", 	"Standard gift - pick up sound file (relative to to sound/, empty=disable)", FCVAR_NOTIFY);
	g_hCvarSpecialSoundFile 			= CreateConVar( "l4d2_gifts_soundfile_special", 			"level/gnomeftw.wav", 		"Special gift - pick up sound file (relative to to sound/, empty=disable)", FCVAR_NOTIFY);
	AutoExecConfig(true, "l4d2_gifts");

	GetCvars();
	g_hCvar_gift_enable.AddChangeHook(Cvar_Changed);
	g_hCvar_gift_life.AddChangeHook(Cvar_Changed);
	g_hCvar_gift_chance.AddChangeHook(Cvar_Changed);
	g_hCvar_special_gift_chance.AddChangeHook(Cvar_Changed);
	g_hCvar_gift_Announce.AddChangeHook(Cvar_Changed);
	g_hCvar_gift_infected_hp.AddChangeHook(Cvar_Changed);
	g_hCvar_special_gift_infected_hp.AddChangeHook(Cvar_Changed);
	g_hCvar_blockSwitch.AddChangeHook(Cvar_Changed);
	g_hCvarStandSoundFile.AddChangeHook(Cvar_Changed);
	g_hCvarSpecialSoundFile.AddChangeHook(Cvar_Changed);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("witch_killed", OnWitchKilled);
	HookEvent("finale_vehicle_ready", Finale_Vehicle_Ready);

	RegAdminCmd("sm_gifts", Command_Gift, ADMFLAG_CHEATS, "Spawn a gift in your position");
	RegAdminCmd("sm_reloadgifts", Command_ReloadGift, ADMFLAG_CONFIG, " Reload the config file of gifts (data/l4d2_gifts.cfg)");

	SetRandomColor();

	g_smItemsToTranslation = new StringMap();
	g_smItemsToTranslation.SetString("grenade_launcher", "Grenade Launcher");
	g_smItemsToTranslation.SetString("rifle_m60", "M60 Machine Gun");
	g_smItemsToTranslation.SetString("defibrillator","Defibrillator");
	g_smItemsToTranslation.SetString("first_aid_kit","First Aid Kit");
	g_smItemsToTranslation.SetString("pain_pills", "Pain Pill");
	g_smItemsToTranslation.SetString("adrenaline", "Adrenaline");
	g_smItemsToTranslation.SetString("weapon_upgradepack_incendiary", "Incendiary Pack");
	g_smItemsToTranslation.SetString("weapon_upgradepack_explosive","Explosive Pack");
	g_smItemsToTranslation.SetString("molotov", "Molotov");
	g_smItemsToTranslation.SetString("pipe_bomb", "Pipe Bomb");
	g_smItemsToTranslation.SetString("vomitjar", "Vomitjar");
	g_smItemsToTranslation.SetString("gascan","Gascan");
	g_smItemsToTranslation.SetString("propanetank", "Propane Tank");
	g_smItemsToTranslation.SetString("oxygentank", "Oxygen Tank");
	g_smItemsToTranslation.SetString("fireworkcrate","Firework Crate");
	g_smItemsToTranslation.SetString("pistol","Pistol");
	g_smItemsToTranslation.SetString("pistol_magnum", "Magnum");
	g_smItemsToTranslation.SetString("pumpshotgun", "Pumpshotgun");
	g_smItemsToTranslation.SetString("shotgun_chrome", "Chrome Shotgun");
	g_smItemsToTranslation.SetString("smg", "Smg");
	g_smItemsToTranslation.SetString("smg_silenced", "Silenced Smg");
	g_smItemsToTranslation.SetString("smg_mp5","MP5");
	g_smItemsToTranslation.SetString("rifle", "Rifle");
	g_smItemsToTranslation.SetString("rifle_sg552", "SG552");
	g_smItemsToTranslation.SetString("rifle_ak47", "AK47");
	g_smItemsToTranslation.SetString("rifle_desert","Desert Rifle");
	g_smItemsToTranslation.SetString("shotgun_spas","Spas Shotgun");
	g_smItemsToTranslation.SetString("autoshotgun", "Autoshotgun");
	g_smItemsToTranslation.SetString("hunting_rifle", "Hunting Rifle");
	g_smItemsToTranslation.SetString("sniper_military", "Military Sniper");
	g_smItemsToTranslation.SetString("sniper_scout", "SCOUT");
	g_smItemsToTranslation.SetString("sniper_awp", "AWP");
	g_smItemsToTranslation.SetString("baseball_bat", "Baseball Bat");
	g_smItemsToTranslation.SetString("chainsaw", "Chainsaw");
	g_smItemsToTranslation.SetString("cricket_bat", "Cricket Bat");
	g_smItemsToTranslation.SetString("crowbar", "Crowbar");
	g_smItemsToTranslation.SetString("electric_guitar", "Electric Guitar");
	g_smItemsToTranslation.SetString("fireaxe", "Fire Axe");
	g_smItemsToTranslation.SetString("frying_pan", "Frying Pan");
	g_smItemsToTranslation.SetString("katana", "Katana");
	g_smItemsToTranslation.SetString("machete", "Machete");
	g_smItemsToTranslation.SetString("tonfa", "Tonfa");
	g_smItemsToTranslation.SetString("knife", "Knife");
	g_smItemsToTranslation.SetString("golfclub", "Golf Club");
	g_smItemsToTranslation.SetString("pitchfork", "Pitchfork");
	g_smItemsToTranslation.SetString("shovel", "Shovel");
	g_smItemsToTranslation.SetString("gnome", "Gnome");
	g_smItemsToTranslation.SetString("cola_bottles", "Cola Bottles");
	g_smItemsToTranslation.SetString("laser_sight",	"Laser Sight");
	g_smItemsToTranslation.SetString("incendiary_ammo",	"Incendiary Ammo");
	g_smItemsToTranslation.SetString("explosive_ammo",	"Explosive Ammo");
	g_smItemsToTranslation.SetString("ammo","Ammo");
	g_smItemsToTranslation.SetString("hp","Health");
	g_smItemsToTranslation.SetString("empty","Empty");

	if(bLate)
	{
		LateLoad();
	}
}

void LateLoad()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
            continue;

        OnClientPutInServer(client);
    }
}

void Cvar_Changed(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	//Values of cvars
	g_bGiftEnable = g_hCvar_gift_enable.BoolValue;
	g_fGiftLife = g_hCvar_gift_life.FloatValue;
	g_iGiftChance = g_hCvar_gift_chance.IntValue;
	g_iSpecialGiftChance = g_hCvar_special_gift_chance.IntValue;
	g_iCvarAnnounce = g_hCvar_gift_Announce.IntValue;
	g_iGiftHP = g_hCvar_gift_infected_hp.IntValue;
	g_iSpecialGiftHP = g_hCvar_special_gift_infected_hp.IntValue;
	g_bCvarBlockSwitch = g_hCvar_blockSwitch.BoolValue;
	g_hCvarStandSoundFile.GetString(g_sCvarStandSoundFile, sizeof(g_sCvarStandSoundFile));
	g_hCvarSpecialSoundFile.GetString(g_sCvarSpecialSoundFile, sizeof(g_sCvarSpecialSoundFile));

	if(g_bMapStart)
	{
		if(strlen(g_sCvarStandSoundFile) > 0) PrecacheSound(g_sCvarStandSoundFile, true);
		if(strlen(g_sCvarSpecialSoundFile) > 0) PrecacheSound(g_sCvarSpecialSoundFile, true);
	}
}

public void OnMapStart()
{
	g_bMapStart = true;
	for( int i = 0; i < MAX_WEAPONS; i++ )
	{
		PrecacheModel(g_sWeaponModels[i], true);
	}
}

public void OnMapEnd()
{
	g_bMapStart = false;
}

void PrecacheModelGifts()
{
	for( int i = 0; i < g_iCountGifts; i++ )
	{
		CheckPrecacheModel(g_sModel[i]);
	}
}

void CheckPrecacheModel(char[] Model)
{
	if (!IsModelPrecached(Model))
	{
		PrecacheModel(Model, true);
	}
}

public void OnConfigsExecuted()
{
	GetCvars();

	GetMeleeClasses();
	LoadConfigGifts();
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_WeaponCanUse, WeaponCanUse);
}

Action Command_Gift(int client, int args)
{
	if (!g_bGiftEnable)
		return Plugin_Handled;
	
	if(!IsValidClient(client))
		return Plugin_Handled;
	
	if(IsFakeClient(client))
		return Plugin_Handled;
	
	if(args < 1)
	{
		DropGift(client, TYPE_STANDARD);
	}
	else
	{
		char arg1[10];
		GetCmdArg(1, arg1, sizeof(arg1));
		
		if(strcmp(arg1, STRING_STANDARD, false) == 0)
		{
			DropGift(client, TYPE_STANDARD);
		}
		else if(strcmp(arg1, STRING_SPECIAL, false) == 0)
		{
			DropGift(client, TYPE_SPECIAL);
		}
		else
		{
			ReplyToCommand(client, "[SM] Usage: sm_gifts <standard or special>");
		}
	}
	return Plugin_Handled;
}

Action Command_ReloadGift(int client, int args)
{
	LoadConfigGifts();
	
	return Plugin_Handled;
}

void LoadConfigGifts()
{
	KeyValues hFile = new KeyValues("Gifts");
	
	if(!hFile.ImportFromFile(sPath_gifts) )
	{
		SetFailState("Cannot load the data file 'data/l4d2_gifts.cfg'");
		delete hFile;
		return;
	}

	delete g_aStandItemsList;
	g_aStandItemsList = new ArrayList(ByteCountToCells(64));

	delete g_aSpecialItemsList;
	g_aSpecialItemsList = new ArrayList(ByteCountToCells(64));

	delete g_aGiftModelStandard;
	g_aGiftModelStandard = new ArrayList();

	delete g_aGiftModelSpecial;
	g_aGiftModelSpecial = new ArrayList();

	char sNumber[4];
	if( hFile.JumpToKey("models") )
	{
		g_iCountGifts = hFile.GetNum("num", 0);

		// Max 
		if( g_iCountGifts > MAX_GIFTS )
			g_iCountGifts = MAX_GIFTS;

		char sTemp[MAX_STRING_WIDTH];
		for(int i = 1; i <= g_iCountGifts; i++)
		{
			IntToString(i, sNumber, sizeof(sNumber));
			if(hFile.JumpToKey(sNumber))
			{
				hFile.GetString("model", sTemp, MAX_STRING_WIDTH);
					
				if(strlen(sTemp) == 0)
					continue;
				
				if(FileExists(sTemp, true))
				{
					strcopy(g_sModel[i-1], MAX_STRING_WIDTH, sTemp);
					hFile.GetString("type", g_sType[i-1], sizeof(g_sType[]), "static");
					hFile.GetString("gift", g_sGift[i-1], sizeof(g_sGift[]));
					if(strcmp(g_sGift[i-1], STRING_SPECIAL, false) == 0)
					{
						g_aGiftModelSpecial.Push(i-1);
					}
					else
					{
						g_aGiftModelStandard.Push(i-1);
					}

					g_fScale[i-1] = hFile.GetFloat("scale", 1.0);

					g_bGiftEntityEnable[i-1] = view_as<bool>(hFile.GetNum("entity_enable", 1));
					hFile.GetString("entity_color", g_sGiftEntityCols[i-1], sizeof(g_sGiftEntityCols[]));

					g_bGiftGlowEnable[i-1] = view_as<bool>(hFile.GetNum("glow_enable", 1));
					hFile.GetString("glow_color", g_sGiftGlowCols[i-1], sizeof(g_sGiftGlowCols[]));
					g_iGiftGlowRange[i-1] = hFile.GetNum("glow_range", 0);
				}

				hFile.GoBack();
			}
		} 

		hFile.GoBack();
	}
	else
	{
		SetFailState("Cannot load gift models, please check data file 'data/l4d2_gifts.cfg'");
		delete hFile;
		return;
	}

	char sName[64], sTemp[64];
	int number, hp;
	if( hFile.JumpToKey("standard_items") )
	{
		number = hFile.GetNum("num", 0);
		for(int i = 1; i <= number; i++)
		{
			IntToString(i, sNumber, sizeof(sNumber));
			if(hFile.JumpToKey(sNumber))
			{
				hFile.GetString("name", sName, sizeof(sName), "");
				if(strlen(sName) > 0)
				{
					if(strcmp(sName, "weapon_melee", false) == 0)
					{
						FormatEx(sName, sizeof(sName), "%s", g_sMeleeClass[GetRandomInt(0, g_iMeleeClassCount-1)]);
						g_aStandItemsList.PushString(sName);
					}
					else if(strcmp(sName, "hp", false) == 0)
					{
						hp = hFile.GetNum("hp", 0);
						if(hp > 0)
						{
							FormatEx(sName, sizeof(sName), "hp_+%d", hp);
							g_aStandItemsList.PushString(sName);
						}
						else if(hp < 0)
						{
							FormatEx(sName, sizeof(sName), "hp_-%d", -hp);
							g_aStandItemsList.PushString(sName);
						}
					}
					else
					{
						if(g_smItemsToTranslation.GetString(sName, sTemp, sizeof(sTemp)) == false)
						{
							LogError("%s is not a valid weapon, please check data file 'data/l4d2_gifts.cfg' \"standard_items\" #%d", sName, i);
						}
						else
						{
							g_aStandItemsList.PushString(sName);
						}
					}
				}

				hFile.GoBack();
			}
		}

		hFile.GoBack();
	}
	else
	{
		SetFailState("Cannot load standard items, please check data file 'data/l4d2_gifts.cfg'");
		delete hFile;
		return;
	}

	if( hFile.JumpToKey("special_items") )
	{
		number = hFile.GetNum("num", 0);
		for(int i = 1; i <= number; i++)
		{
			IntToString(i, sNumber, sizeof(sNumber));
			if(hFile.JumpToKey(sNumber))
			{
				hFile.GetString("name", sName, sizeof(sName), "");
				if(strlen(sName) > 0)
				{
					if(strcmp(sName, "weapon_melee", false) == 0)
					{
						hFile.GetString("melee", sName, sizeof(sName), "");
						if(strlen(sName) > 0 && g_aMapMeleeTable.FindString(sName) > -1) 
							g_aSpecialItemsList.PushString(sName);
					}
					else if(strcmp(sName, "hp", false) == 0)
					{
						hp = hFile.GetNum("hp", 0);
						if(hp > 0)
						{
							FormatEx(sName, sizeof(sName), "hp_+%d", hp);
							g_aSpecialItemsList.PushString(sName);
						}
						else if(hp < 0)
						{
							FormatEx(sName, sizeof(sName), "hp_-%d", -hp);
							g_aSpecialItemsList.PushString(sName);
						}
					}
					else
					{
						if(g_smItemsToTranslation.GetString(sName, sTemp, sizeof(sTemp)) == false)
						{
							LogError("%s is not a valid weapon, please check data file 'data/l4d2_gifts.cfg' \"special_items\" #%d", sName, i);
						}
						else
						{
							g_aSpecialItemsList.PushString(sName);
						}
					}
				}

				hFile.GoBack();
			}
		}

		hFile.GoBack();
	}
	else
	{
		SetFailState("Cannot load special items, please check data file 'data/l4d2_gifts.cfg'");
		delete hFile;
		return;
	}

	if( hFile.JumpToKey("weapon_ammo") )
	{
		int size = sizeof(weapon_ammo);
		for( int index = 0 ; index < size ; ++index )
		{
			hFile.GetString(weapon_ammo[index][0], weapon_ammo[index][2], sizeof(weapon_ammo[][]), weapon_ammo[index][2]);
		}

		hFile.GoBack();
	}
	
	delete hFile;

	PrecacheModelGifts();
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalHasStart = false;
	g_bIsDoorOpen_LockDown = false;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalHasStart = false;
	g_bIsDoorOpen_LockDown = false;
}

void Finale_Vehicle_Ready(Event event, const char[] name, bool dontBroadcast) 
{
	g_bFinalHasStart = true;
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bGiftEnable)
		return;

	if(g_bIsDoorOpen_LockDown || g_bFinalHasStart)
		return;
	
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if (attacker != victim && IsValidClient(victim) && GetClientTeam(victim) == 3)
	{
		if(GetZombieClass(victim) == 8)
		{
			if (GetRandomInt(1, 100) <= g_iSpecialGiftChance)
			{
				DropGift(victim, TYPE_SPECIAL);
			}
		}
		else
		{
			if (GetRandomInt(1, 100) <= g_iGiftChance)
			{
				DropGift(victim, TYPE_STANDARD);
			}
		}
	}
}

void OnWitchKilled(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bGiftEnable)
		return;

	if(g_bIsDoorOpen_LockDown|| g_bFinalHasStart)
		return;	

	//int attacker = GetClientOfUserId(event.GetInt("userid"));
	int witch = event.GetInt("witchid");
	if (GetRandomInt(1, 100) <= g_iSpecialGiftChance)
	{
		DropGift(witch, TYPE_SPECIAL);
	}
}

void OpenGift(int client, int type)
{
	static char 
			sItem[64], 
			sItemName_Translate[64], 
			sNumber[2][6];

	int iSlot0 = GetPlayerWeaponSlot(client, 0), hp = 0, index;
	if(type == TYPE_STANDARD)
	{
		index = GetURandomIntRange(0, g_aStandItemsList.Length-1);
		g_aStandItemsList.GetString(index, sItem, sizeof(sItem));
		sItemName_Translate[0] = '\0';
		g_smItemsToTranslation.GetString(sItem, sItemName_Translate, sizeof(sItemName_Translate));

		if(strlen(g_sCvarStandSoundFile) > 0) PlaySoundAroundClient(client, g_sCvarStandSoundFile);
	}
	else if(type == TYPE_SPECIAL)
	{
		index = GetURandomIntRange(0, g_aSpecialItemsList.Length-1);
		g_aSpecialItemsList.GetString(index, sItem, sizeof(sItem));
		sItemName_Translate[0] = '\0';
		g_smItemsToTranslation.GetString(sItem, sItemName_Translate, sizeof(sItemName_Translate));

		if(strlen(g_sCvarSpecialSoundFile) > 0) PlaySoundAroundClient(client, g_sCvarSpecialSoundFile);
	}
	else
	{
		return;
	}

	if( strcmp(sItem, "laser_sight") == 0 || 
		strcmp(sItem, "incendiary_ammo") == 0 || 
		strcmp(sItem, "explosive_ammo") == 0)
	{
		if(iSlot0 > MaxClients) GiveUpgrade(client, sItem);
	}
	else if( strcmp(sItem, "ammo") == 0)
	{
		if(iSlot0 > MaxClients) GiveClientAmmo(client, iSlot0);
	}
	else if ( strncmp(sItem, "hp_", 3, false) == 0)
	{
		g_smItemsToTranslation.GetString("hp", sItemName_Translate, sizeof(sItemName_Translate));

		ExplodeString(sItem, "_", sNumber, sizeof(sNumber), sizeof(sNumber[]));

		hp = StringToInt(sNumber[1]);
		if(hp >= 0)
		{
			GiveClientHealth(client, hp);
		}
		else
		{
			HurtEntity(client, client, float(-hp));
		}
	}
	else
	{
		GiveWeapon(client, sItem);
	}

	//PrintToChatAll("sItem: %s %s", sItem, sItemName_Translate);
	AnnounceToChat(client, sItemName_Translate, hp);
}

void GiveWeapon(int client, const char[] weapon)
{
	int flagsgive = GetCommandFlags("give");
	SetCommandFlags("give", flagsgive & ~FCVAR_CHEAT);
	FakeClientCommand(client, "give %s", weapon);
	SetCommandFlags("give", flagsgive);
}

int GetRandomIndexGift(int iType)
{
	int index;
	if(iType == TYPE_STANDARD)
	{
		if(g_aGiftModelStandard.Length == 0) return -1;

		index = GetRandomInt(0, g_aGiftModelStandard.Length-1);
		return g_aGiftModelStandard.Get(index);
	}
	else
	{
		if(g_aGiftModelSpecial.Length == 0) return -1;

		index = GetRandomInt(0, g_aGiftModelSpecial.Length-1);
		return g_aGiftModelSpecial.Get(index);
	}
}

void DropGift(int client, int type = TYPE_STANDARD)
{	
	float gifPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", gifPos);
	gifPos[2] += 10.0;
	
	int gift = -1;
	int random = GetRandomIndexGift(type);
	if(random == -1) return;
	
	if(strcmp(g_sType[random], "physics") == 0)
	{
		gift = CreateEntityByName("prop_physics_override");
	}
	else if(strcmp(g_sType[random], "static") == 0)
	{
		gift = CreateEntityByName("prop_dynamic_override");
	}
	else
	{
		return;
	}
	
	if( CheckIfEntitySafe(gift) )
	{
		DispatchKeyValue(gift, "model", g_sModel[random]);
		
		g_iGifType[gift] = type;
		DispatchKeyValueVector(gift, "origin", gifPos);
		DispatchKeyValue(gift, "spawnflags", "8448"); // 2="Don`t take physics damage", 256="Generate output on +USE", 8196:"Force Server Side"

		DispatchSpawn(gift);
		SetEntPropFloat(gift, Prop_Send, "m_flModelScale", g_fScale[random]);

		if(g_bGiftEntityEnable[random])
		{
			int entitycolor[3];
			if(strcmp(g_sGiftEntityCols[random], "-1 -1 -1", false) == 0)
			{
				switch(GetRandomInt(1, 8))
				{
					case 1: {entitycolor[0] = ColorCyan[0]; entitycolor[1] = ColorCyan[1]; entitycolor[2] = ColorCyan[2];}
					case 2: {entitycolor[0] = ColorLightGreen[0]; entitycolor[1] = ColorLightGreen[1]; entitycolor[2] = ColorLightGreen[2];}
					case 3: {entitycolor[0] = ColorPurple[0]; entitycolor[1] = ColorPurple[1]; entitycolor[2] = ColorPurple[2];}
					case 4: {entitycolor[0] = ColorPink[0]; entitycolor[1] = ColorPink[1]; entitycolor[2] = ColorPink[2];}
					case 5: {entitycolor[0] = ColorRed[0]; entitycolor[1] = ColorRed[1]; entitycolor[2] = ColorRed[2];}
					case 6: {entitycolor[0] = ColorOrange[0]; entitycolor[1] = ColorOrange[1]; entitycolor[2] = ColorOrange[2];}
					case 7: {entitycolor[0] = ColorYellow[0]; entitycolor[1] = ColorYellow[1]; entitycolor[2] = ColorYellow[2];}
					case 8: {entitycolor[0] = 255; entitycolor[1] = 255; entitycolor[2] = 255;}
				}
			}
			else
			{
				GetColor(g_sGiftEntityCols[random], entitycolor);
			}

			SetEntityRenderColor(gift, entitycolor[0], entitycolor[1], entitycolor[2]);
		}
		if(g_bGiftGlowEnable[random])
		{
			int glowcolor[3];
			if(strcmp(g_sGiftGlowCols[random], "-1 -1 -1", false) == 0)
			{
				switch(GetRandomInt(1, 13))
				{
					case 1: {glowcolor[0] = ColorRed[0]; glowcolor[1] = ColorRed[1]; glowcolor[2] = ColorRed[2];}
					case 2: {glowcolor[0] = ColorGreen[0]; glowcolor[1] = ColorGreen[1]; glowcolor[2] = ColorGreen[2];}
					case 3: {glowcolor[0] = ColorBlue[0]; glowcolor[1] = ColorBlue[1]; glowcolor[2] = ColorBlue[2];}
					case 4: {glowcolor[0] = ColorPurple[0]; glowcolor[1] = ColorPurple[1]; glowcolor[2] = ColorPurple[2];}
					case 5: {glowcolor[0] = ColorCyan[0]; glowcolor[1] = ColorCyan[1]; glowcolor[2] = ColorCyan[2];}
					case 6: {glowcolor[0] = ColorOrange[0]; glowcolor[1] = ColorOrange[1]; glowcolor[2] = ColorOrange[2];}
					case 7: {glowcolor[0] = ColorWhite[0]; glowcolor[1] = ColorWhite[1]; glowcolor[2] = ColorWhite[2];}
					case 8: {glowcolor[0] = ColorPink[0]; glowcolor[1] = ColorPink[1]; glowcolor[2] = ColorPink[2];}
					case 9: {glowcolor[0] = ColorLime[0]; glowcolor[1] = ColorLime[1]; glowcolor[2] = ColorLime[2];}
					case 10: {glowcolor[0] = ColorMaroon[0]; glowcolor[1] = ColorMaroon[1]; glowcolor[2] = ColorMaroon[2];}
					case 11: {glowcolor[0] = ColorTeal[0]; glowcolor[1] = ColorTeal[1]; glowcolor[2] = ColorTeal[2];}
					case 12: {glowcolor[0] = ColorYellow[0]; glowcolor[1] = ColorYellow[1]; glowcolor[2] = ColorYellow[2];}
					case 13: {glowcolor[0] = 255; glowcolor[1] = 255; glowcolor[2] = 255;}
				}
			}
			else
			{
				GetColor(g_sGiftGlowCols[random], glowcolor);
			}

			int glowrange = 0;
			if(type == TYPE_STANDARD) glowrange = g_iGiftGlowRange[random];
			else glowrange = g_iSpecialGiftGlowRange[random];

			L4D2_SetEntityGlow(gift, L4D2Glow_Constant, glowrange, 0, glowcolor, true);
		}

		CreateTimer(g_fGiftLife, Timer_GiftLife, EntIndexToEntRef(gift), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, ColdDown, EntIndexToEntRef(gift),TIMER_FLAG_NO_MAPCHANGE);
	}
}

Action ColdDown( Handle timer, any ref)
{
	int gift;
	if (ref && (gift = EntRefToEntIndex(ref)) != INVALID_ENT_REFERENCE)
	{
		SDKHook(gift, SDKHook_TouchPost, OnTouchPost);
		SDKHook(gift, SDKHook_UsePost, OnUsePost);
	}

	return Plugin_Continue;
}

void OnTouchPost(int gift, int client)
{
	TryOpenGift(gift, client);
} 

void OnUsePost(int gift, int client, int caller, UseType type, float value)
{
	TryOpenGift(gift, client);
}

void TryOpenGift(int gift, int client)
{
	if (IsValidClient(client))
	{
		int iTeam = GetClientTeam(client);

		if(iTeam == 1) return;

		if(iTeam == 2 && IsPlayerAlive(client) &&
			!IsIncapacitated(client) &&
			!IsHandingFromLedge(client) &&
			L4D_GetPinnedInfected(client) == 0 )
		{

			g_bHooked[client] = true;
			if (g_iGifType[gift] == TYPE_STANDARD)
			{
				OpenGift(client, TYPE_STANDARD);
			}
			else if (g_iGifType[gift] == TYPE_SPECIAL)
			{
				OpenGift(client, TYPE_SPECIAL);
			}
			g_bHooked[client] = false;

			AcceptEntityInput(gift, "kill");
		}
		else if(iTeam == 3 && IsPlayerAlive(client) && !IsPlayerGhost(client))
		{
			if(GetEntProp(client, Prop_Send, "m_zombieClass") == ZC_TANK && IsTankDying(client)) return;

			int AddHP = 0;
			if (g_iGifType[gift] == TYPE_STANDARD) AddHP = g_iGiftHP;
			else AddHP = g_iSpecialGiftHP;

			if(AddHP == 0) return;

			SetEntityHealth(client, GetClientHealth(client) + AddHP);

			switch(g_iCvarAnnounce)
			{
				case 0: { }
				case 1:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_INFECTED || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							CPrintToChat(i, "%T", "Infected Got Gift (C)", i, client, AddHP);
						}
					}
				}
				case 2:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_INFECTED || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							PrintHintText(i, "%T", "Infected Got Gift", i, client, AddHP);
						}
					}
				}
				case 3:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_INFECTED || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							PrintCenterText(i, "%T", "Infected Got Gift", i, client, AddHP);
						}
					}
				}
			}

			if (g_iGifType[gift] == TYPE_STANDARD) 
			{
				if(strlen(g_sCvarStandSoundFile) > 0) PlaySoundAroundClient(client, g_sCvarStandSoundFile);
			}
			else
			{
				if(strlen(g_sCvarSpecialSoundFile) > 0) PlaySoundAroundClient(client, g_sCvarSpecialSoundFile);
			}

			AcceptEntityInput(gift, "kill");
		}
	}
} 

Action WeaponCanUse(int client, int weapon)
{
	if(!g_bGiftEnable || !g_bCvarBlockSwitch) return Plugin_Continue;

	if(IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		if(g_bHooked[client])
		{
			int wepid = IdentifyWeapon(weapon);
			if(wepid == WEPID_NONE) return Plugin_Continue;
			
			if(wepid == WEPID_GASCAN ||
				wepid == WEPID_PROPANE_TANK ||
				wepid == WEPID_OXYGEN_TANK ||
				wepid == WEPID_FIREWORKS_BOX ||
				wepid == WEPID_COLA_BOTTLES ||
				wepid == WEPID_GNOME_CHOMPSKI) 
			{
				Event hEvent = CreateEvent("weapon_drop");
				if( hEvent != null )
				{
					hEvent.SetInt("userid", GetClientUserId(client));
					hEvent.SetInt("propid", weapon);
					hEvent.Fire();
				}
				return Plugin_Handled;
			}

			int slot = GetSlotFromWeaponId(wepid);
			if(slot == L4D2WeaponSlot_None) return Plugin_Continue;

			if(GetPlayerWeaponSlot(client, slot) == -1) return Plugin_Continue;

			Event hEvent = CreateEvent("weapon_drop");
			if( hEvent != null )
			{
				hEvent.SetInt("userid", GetClientUserId(client));
				hEvent.SetInt("propid", weapon);
				hEvent.Fire();
			}

			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

bool IsValidClient(int client)
{
	if (client < 1 || client > MaxClients) 
		return false;
	
	if (!IsClientConnected(client)) 
		return false;
	
	if (!IsClientInGame(client)) 
		return false;
	
	return true;
}

int GetZombieClass(int client)
{
	return GetEntProp(client, Prop_Send, "m_zombieClass");
}

Action Timer_GiftLife( Handle timer, any ref)
{
	if ( ref && EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(ref, "kill");
	}

	return Plugin_Continue;
}

void GetColor(const char[] str_color, int color[3])
{
	char sColors[3][4];
	ExplodeString(str_color, " ", sColors, 3, 4);

	color[0] = StringToInt(sColors[0]);
	color[1] = StringToInt(sColors[1]);
	color[2] = StringToInt(sColors[2]);
}

stock int GetURandomIntRange(int min, int max)
{
	return (GetURandomInt() % (max-min+1)) + min;
}

void PlaySoundAroundClient(int client,char[] sSoundName)
{
	EmitSoundToAll(sSoundName, client, SNDCHAN_AUTO, SNDLEVEL_AIRCRAFT, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

bool IsPlayerGhost (int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost"))
		return true;
	return false;
}

bool IsTankDying(int tankclient)
{
	if (!tankclient) return false;
 
	return view_as<bool>(GetEntData(tankclient, g_iOffset_Incapacitated));
}

stock void GiveUpgrade(int client, char[] name)
{
	char sBuf[32];
	int flags = GetCommandFlags("upgrade_add");
	SetCommandFlags("upgrade_add", flags & ~FCVAR_CHEAT);
	FormatEx(sBuf, sizeof (sBuf), "upgrade_add %s", name);
	FakeClientCommand(client, sBuf);
	SetCommandFlags("upgrade_add", flags);
}

stock void GiveClientAmmo(int client, int iSlot0)
{
	char slot0ClassName[40];
	GetEdictClassname(iSlot0, slot0ClassName, sizeof(slot0ClassName));
	int weaponAmmoOffset, ammoMax;
	for( int i = 0 ; i < sizeof(weapon_ammo) ; ++i) {
		if (strcmp(slot0ClassName, weapon_ammo[i][0]) == 0)
		{
			weaponAmmoOffset = StringToInt(weapon_ammo[i][1]);
			ammoMax = GetEntData(client, ammoOffset+(weaponAmmoOffset*4)) + StringToInt(weapon_ammo[i][2]);
			if(ammoMax > 999) ammoMax = 999;
			SetEntData(client, ammoOffset+(weaponAmmoOffset*4), ammoMax);
		}	
	}			
}

void GiveClientHealth(int client, int iHealthAdd)
{
	
	int iHealth = GetClientHealth( client );
	float fHealth = L4D_GetTempHealth( client );

	if(iHealthAdd>=99) 
	{
		int flagsgive = GetCommandFlags("give");
		SetCommandFlags("give", flagsgive & ~FCVAR_CHEAT);
		FakeClientCommand(client, "give health");
		SetCommandFlags("give", flagsgive);

		SetEntityHealth( client, iHealth + iHealthAdd );
		SetTempHealth( client, 0.0 );
	}

	if( GetEntProp( client, Prop_Send, "m_currentReviveCount" ) >= 1 )
	{
		SetTempHealth( client, fHealth + iHealthAdd);
	}
	else
	{
		SetEntityHealth( client, iHealth + iHealthAdd );
		SetTempHealth( client, fHealth );
	}
}

void SetTempHealth(int client, float fHealth)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", fHealth < 0.0 ? 0.0 : fHealth );
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
}

bool IsIncapacitated(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated"));
}

bool IsHandingFromLedge(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isHangingFromLedge") || GetEntProp(client, Prop_Send, "m_isFallingFromLedge"));
}

bool CheckIfEntitySafe(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		AcceptEntityInput(entity, "Kill");
		return false;
	}
	return true;
}

void SetRandomColor()
{
	GetColor("255 0 0", ColorRed);
	GetColor("0 255 0", ColorGreen);
	GetColor("0 0 255", ColorBlue);
	GetColor("128 0 128", ColorPurple);
	GetColor("0 255 255", ColorCyan);
	GetColor("254 100 46", ColorOrange);
	GetColor("255 255 255", ColorWhite);
	GetColor("255 88 130", ColorPink);
	GetColor("128 255 0", ColorLime);
	GetColor("128 0 0", ColorMaroon);
	GetColor("0 128 128", ColorTeal);
	GetColor("255 255 0", ColorYellow);
	GetColor("144 238 144", ColorLightGreen);
}

void HurtEntity(int victim, int attacker, float damage)
{
	SDKHooks_TakeDamage(victim, attacker, attacker, damage, DMG_SLASH);
}

void AnnounceToChat(int client, const char[] buffer, int hp)
{
	if(strlen(buffer) == 0) return;

	if(strncmp(buffer, "Health", 6, false) == 0)
	{
		if(hp >= 0)
		{
			switch(g_iCvarAnnounce)
			{
				case 0: { }
				case 1:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							CPrintToChat(i, "%T", "Got Gift (+hp) (C)", i, client, hp);
						}
					}
				}
				case 2:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							PrintHintText(i, "%T", "Got Gift (+hp)", i, client, hp);
						}
					}
				}
				case 3:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							PrintCenterText(i, "%T", "Got Gift (+hp)", i, client, hp);
						}
					}
				}
			}
		}
		else
		{
			switch(g_iCvarAnnounce)
			{
				case 0: { }
				case 1:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							CPrintToChat(i, "%T", "Got Gift (-hp) (C)", i, client, -hp);
						}
					}
				}
				case 2:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							PrintHintText(i, "%T", "Got Gift (-hp)", i, client, -hp);
						}
					}
				}
				case 3:
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;
						if(IsFakeClient(i)) continue;
						if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
						{
							PrintCenterText(i, "%T", "Got Gift (-hp)", i, client, -hp);
						}
					}
				}
			}
		}
	}
	else
	{
		bool bTranslationPhraseExists = TranslationPhraseExists(buffer);
		switch(g_iCvarAnnounce)
		{
			case 0: { }
			case 1:
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if(!IsClientInGame(i)) continue;
					if(IsFakeClient(i)) continue;
					if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
					{
						if(bTranslationPhraseExists) CPrintToChat(i, "%T", "Got Gift (C)", i, client, buffer, i);
						else CPrintToChat(i, "%T", "Got Gift (CS)", i, client, buffer);
					}
				}
			}
			case 2:
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if(!IsClientInGame(i)) continue;
					if(IsFakeClient(i)) continue;
					if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
					{
						if(bTranslationPhraseExists) PrintHintText(i, "%T", "Got Gift", i, client, buffer, i);
						else PrintHintText(i, "%T", "Got Gift (S)", i, client, buffer);
					}
				}
			}
			case 3:
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if(!IsClientInGame(i)) continue;
					if(IsFakeClient(i)) continue;
					if(GetClientTeam(i) == TEAM_SURVIVOR || GetClientTeam(i) == TEAM_SPECTATOR)
					{
						if(bTranslationPhraseExists) PrintCenterText(i, "%T", "Got Gift", i, client, buffer, i);
						else PrintCenterText(i, "%T", "Got Gift (S)", i, client, buffer);
					}
				}
			}
		}
	}
}

//credit spirit12 for auto melee detection
void GetMeleeClasses()
{
	int MeleeStringTable = FindStringTable( "MeleeWeapons" );
	g_iMeleeClassCount = GetStringTableNumStrings( MeleeStringTable );
	
	int len = sizeof(g_sMeleeClass[]);
	
	for( int i = 0; i < g_iMeleeClassCount; i++ )
	{
		ReadStringTable( MeleeStringTable, i, g_sMeleeClass[i], len );
		//LogAcitivity( "Function::GetMeleeClasses - Getting melee classes: %s", g_sMeleeClass[i]);
	}	
}

// Other API Forward-------------------------------

// from lockdown_system-l4d2_b.smx
// when door is fully opened
public void L4DLockDownSystem_OnOpenDoorFinish(const char[] sKeyMan)
{
	g_bIsDoorOpen_LockDown = true;
}