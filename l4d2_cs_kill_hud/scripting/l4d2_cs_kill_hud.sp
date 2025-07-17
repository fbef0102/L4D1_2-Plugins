#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION			"2.0h-2025/7/17"
#define PLUGIN_NAME			    "l4d2_cs_kill_hud"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D2] CS Kill Hud",
	author = "Miuwiki, Harry",
	description = "HUD with cs kill info list.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

int ZC_TANK;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	ZC_TANK = 8;
	return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define CLASSNAME_INFECTED            "infected"
#define CLASSNAME_WITCH               "witch"

//	#define HUD_LEFT_TOP	0
//	#define HUD_LEFT_BOT	1
//	#define HUD_MID_TOP		2
//	#define HUD_MID_BOT		3
//	#define HUD_RIGHT_TOP	4
//	#define HUD_RIGHT_BOT	5
//	#define HUD_TICKER		6
//	#define HUD_FAR_LEFT	7
//	#define HUD_FAR_RIGHT	8
//	#define HUD_MID_BOX		9	<-- 此插件占用
//	#define HUD_SCORE_TITLE	10	<-- 此插件占用
//	#define HUD_SCORE_1		11	<-- 此插件占用
//	#define HUD_SCORE_2		12	<-- 此插件占用
//	#define HUD_SCORE_3		13	<-- 此插件占用
//	#define HUD_SCORE_4		14	<-- 此插件占用

#define MAX_SIZE_HUD	15

// custom flags for background, time, alignment, which team, pre or postfix, etc
#define HUD_FLAG_PRESTR			(1<<0)	//	do you want a string/value pair to start(pre) or end(post) with the static string (default is PRE)
#define HUD_FLAG_POSTSTR		(1<<1)	//	ditto
#define HUD_FLAG_BEEP			(1<<2)	//	Makes a countdown timer blink
#define HUD_FLAG_BLINK			(1<<3)  //	do you want this field to be blinking
#define HUD_FLAG_AS_TIME		(1<<4)	//	to do..
#define HUD_FLAG_COUNTDOWN_WARN	(1<<5)	//	auto blink when the timer gets under 10 seconds
#define HUD_FLAG_NOBG			(1<<6) 	//	dont draw the background box for this UI element
#define HUD_FLAG_ALLOWNEGTIMER	(1<<7) 	//	by default Timers stop on 0:00 to avoid briefly going negative over network, this keeps that from happening
#define HUD_FLAG_ALIGN_LEFT		(1<<8) 	//	Left justify this text
#define HUD_FLAG_ALIGN_CENTER	(1<<9)	//	Center justify this text
#define HUD_FLAG_ALIGN_RIGHT	(3<<8)	//	Right justify this text
#define HUD_FLAG_TEAM_SURVIVORS	(1<<10) //	only show to the survivor team
#define HUD_FLAG_TEAM_INFECTED	(1<<11) //	only show to the special infected team
#define HUD_FLAG_TEAM_MASK		(3<<10) //	link HUD_FLAG_TEAM_SURVIVORS and HUD_FLAG_TEAM_INFECTED
#define HUD_FLAG_UNKNOWN1		(1<<12)	//	?
#define HUD_FLAG_TEXT			(1<<13)	//	?
#define HUD_FLAG_NOTVISIBLE		(1<<14) //	if you want to keep the slot data but keep it from displaying

ConVar g_hCvarEnable, g_hCvarKillInfoNumber, g_hCvarHudDecrease, g_hCvarBlockMessage, 
	g_hCvar_HUD_X, g_hCvar_HUD_Y, g_hCvar_HUD_Width, g_hCvar_HUD_Height, g_hCvar_HUD_TextAlign, g_hCvar_HUD_Team, g_hCvarHUDBlink, g_hCvarHUDBackground;
bool g_bCvarEnable, g_bCvarBlockMessage, g_bCvarHUDBlink, g_bCvarHUDBackground;
int g_iCvarKillInfoNumber, g_iCvar_HUD_TextAlign, g_iCvar_HUD_Team;
float g_fCvarHudDecrease, g_fCvar_HUD_X, g_fCvar_HUD_Y, g_fCvar_HUD_Width, g_fCvar_HUD_Height;

static StringMap g_weapon_name;
ArrayList g_hud_killinfo;
Handle g_hKillHUDDecreaseTimer;
int g_iHUDFlags;

static const char g_kill_type[][] =
{
	"■■‖:::::::>",     //0 melee

	"/̵͇̿̿/’̿’̿ ̿ ̿̿ ̿̿ ̿̿",        //1 pistol

	"⌐╤═─",         //2 smg

	"︻╦╦═─",   //3 rifle

	"▄︻═══∶∷",      //4 shotgun

	"︻╦̵̵͇̿̿̿̿╤───",    //5 sniper

	"☆BOMB☆",          //6 pipe bomb, explosive

	"__∫∫∫∫__",      //7 inferno, entityflame

	"▄︻╤■══一",		//8 M60

	"︻■■■■ ●",	    //9 grenade_launcher_projectile

	"(●｀・ω・)=Ｏ",	     //10 killed by push, shove melee

	"↼■╦══",	     //11 killed by mini gun

	"X_X",           //12 killed by world, worldspawn, trigger_hurt

	"*皿*彡",         //13 killed by special infected,

	"→‖",           //14 kill behind wall
	
	"→⊙",           //15 headshot

	"(ﾒﾟДﾟ)ﾒ彡",           //16 killed by witch

	"☠",         //17 killed by common infected

	"<ʖ͡=::::::⊃",         //18 killed by chainsaw

	"⬇ X_X",         //19 Die due to falling from roof

	"SYSTEM X_X",         //20 ForcePlayerSuicide / SI committed suicide / Tank committed suicide

	"→☠",         //21 Unknown weapons
};

#define KILL_HUD_BASE 9
#define KILL_INFO_MAX 6

static float g_HUDpos[][] =
{
	//{x, y, 寬, 高}
    {0.00,0.00,0.00,0.00}, // 0
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
    {0.00,0.00,0.00,0.00},
	{0.00,0.00,0.00,0.00},

    // kill list
	// {x, y, 寬, 高} <= 會根據插件指令改變
    {0.50,0.10,0.49,0.04}, // 9
    {0.50,0.14,0.49,0.04}, // 10
    {0.50,0.18,0.49,0.04},
    {0.50,0.22,0.49,0.04},
    {0.50,0.26,0.49,0.04},
    {0.50,0.30,0.49,0.04}, // 14
};

enum struct HUD
{
	int slot;
	int flag;
	float pos[4];
	char info[128];
	void Place()
	{
		HUDSetLayout(this.slot, HUD_FLAG_TEXT|this.flag, this.info);
		HUDPlace(this.slot, this.pos[0], this.pos[1], this.pos[2], this.pos[3]);
	}
}

StringMap 
	g_smSpecialWeapons,
	g_smIgnoreWallWeapons;

public void OnPluginStart()
{
	g_hCvarEnable 			= CreateConVar( PLUGIN_NAME ... "_enable",        				"1",   	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarKillInfoNumber 	= CreateConVar( PLUGIN_NAME ... "_number",        				"5",   	"Numbers of kill list on hud (Default: 5, MAX: 6)", CVAR_FLAGS, true, 1.0, true, 6.0);
	g_hCvarHudDecrease 		= CreateConVar( PLUGIN_NAME ... "_notice_time",   				"7.0", 	"Time in seconds to erase kill list on hud.", CVAR_FLAGS, true, 1.0);
	g_hCvarBlockMessage 	= CreateConVar( PLUGIN_NAME ... "_disable_standard_message", 	"1",   	"If 1, disable offical player death message (the red font of kill info)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvar_HUD_X           = CreateConVar( PLUGIN_NAME ... "_x",             				"0.60",  "X (horizontal) position of the kill list.\nNote: setting it to less than 0.0 may cut/hide the text at screen.", CVAR_FLAGS, true, -1.0, true, 1.0);
	g_hCvar_HUD_Y           = CreateConVar( PLUGIN_NAME ... "_y",             				"0.10",  "Y (vertical) position of the kill list.\nNote: setting it to less than 0.0 may cut/hide the text at screen.", CVAR_FLAGS, true, -1.0, true, 1.0);
	g_hCvar_HUD_Width       = CreateConVar( PLUGIN_NAME ... "_width",         				"0.39", "Text area Width.", CVAR_FLAGS, true, 0.0, true, 2.0);
	g_hCvar_HUD_Height      = CreateConVar( PLUGIN_NAME ... "_height",        				"0.04",	"Text area Height.", CVAR_FLAGS, true, 0.0, true, 2.0);
	g_hCvar_HUD_TextAlign   = CreateConVar( PLUGIN_NAME ... "_text_align",    				"3",    "Aligns the text horizontally.\n1 = LEFT, 2 = CENTER, 3 = RIGHT.", CVAR_FLAGS, true, 1.0, true, 3.0);
	g_hCvar_HUD_Team        = CreateConVar( PLUGIN_NAME ... "_team",          				"0",    "Which team should see the text.\n0 = ALL, 1 = SURVIVOR, 2 = INFECTED.", CVAR_FLAGS, true, 0.0, true, 2.0);
	g_hCvarHUDBlink         = CreateConVar( PLUGIN_NAME ... "_blink", 						"0",   	"If 1, Makes the text blink from white to red.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarHUDBackground    = CreateConVar( PLUGIN_NAME ... "_background", 					"1",   	"If 1, Shows the text inside a black transparent background.\nNote: the background may not draw properly when initialized as \"0\", start the map with \"1\" to render properly.\n", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(                       	PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                	PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarKillInfoNumber.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHudDecrease.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarBlockMessage.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_HUD_X.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_HUD_Y.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_HUD_Width.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_HUD_Height.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_HUD_TextAlign.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_HUD_Team.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHUDBlink.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHUDBackground.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_death",Event_PlayerDeathInfo_Pre, EventHookMode_Pre);
	HookEvent("player_death",Event_PlayerDeathInfo_Post);

	HookEvent("round_start",            Event_RoundStart, 	EventHookMode_PostNoCopy);

	g_hud_killinfo = new ArrayList(ByteCountToCells(128));
	LoadEventWeaponName();
}

//Cvars-------------------------------

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_iCvarKillInfoNumber = g_hCvarKillInfoNumber.IntValue;
	g_fCvarHudDecrease = g_hCvarHudDecrease.FloatValue;
	g_bCvarBlockMessage = g_hCvarBlockMessage.BoolValue;
	g_fCvar_HUD_X = g_hCvar_HUD_X.FloatValue;
	g_fCvar_HUD_Y = g_hCvar_HUD_Y.FloatValue;
	g_fCvar_HUD_Width = g_hCvar_HUD_Width.FloatValue;
	g_fCvar_HUD_Height = g_hCvar_HUD_Height.FloatValue;
	g_iCvar_HUD_TextAlign = g_hCvar_HUD_TextAlign.IntValue;
	g_iCvar_HUD_Team = g_hCvar_HUD_Team.IntValue;
	g_bCvarHUDBlink = g_hCvarHUDBlink.BoolValue;
	g_bCvarHUDBackground = g_hCvarHUDBackground.BoolValue;

	g_iHUDFlags = HUD_FLAG_TEXT;

	switch (g_iCvar_HUD_TextAlign)
	{
		case 1: g_iHUDFlags |= HUD_FLAG_ALIGN_LEFT;
		case 2: g_iHUDFlags |= HUD_FLAG_ALIGN_CENTER;
		case 3: g_iHUDFlags |= HUD_FLAG_ALIGN_RIGHT;
	}

	switch (g_iCvar_HUD_Team)
	{
		case 1: g_iHUDFlags |= HUD_FLAG_TEAM_SURVIVORS;
		case 2: g_iHUDFlags |= HUD_FLAG_TEAM_INFECTED;
	}

	if(!g_bCvarHUDBackground)
		g_iHUDFlags |= HUD_FLAG_NOBG;

	if(g_bCvarHUDBlink)
		g_iHUDFlags |= HUD_FLAG_BLINK;

	for (int slot = KILL_HUD_BASE; slot < MAX_SIZE_HUD; slot++)
	{
		g_HUDpos[slot][0] = g_fCvar_HUD_X ;
		g_HUDpos[slot][1] = g_fCvar_HUD_Y + (slot-KILL_HUD_BASE) * 0.04;
		g_HUDpos[slot][2] = g_fCvar_HUD_Width;
		g_HUDpos[slot][3] = g_fCvar_HUD_Height;
	}
}

//Sourcemod API Forward-------------------------------

public void OnMapStart()
{
	/**
	 * 启用HUD绘制.
	 * 在OnMapStart()函数内部启用即可.	
	 */
	GameRules_SetProp("m_bChallengeModeActive", true, _, _, true);
}

public void OnMapEnd()
{
	delete g_hud_killinfo;
	g_hud_killinfo = new ArrayList(ByteCountToCells(128));

	delete g_hKillHUDDecreaseTimer;
}

//Event-------------------------------

void Event_PlayerDeathInfo_Pre(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_bCvarEnable )
		return;

	if(g_bCvarBlockMessage) event.BroadcastDisabled = true; // by prehook, set this to prevent the red font of kill info.
}

void Event_PlayerDeathInfo_Post(Event event, const char[] name, bool dontBroadcast)
{
	if( !g_bCvarEnable )
		return;

	int victim = GetClientOfUserId( event.GetInt("userid") );
	bool bIsVictimPlayer = true;
	if( victim <= 0 || victim > MaxClients || !IsClientInGame(victim) )
		bIsVictimPlayer = false;

	int attacker = GetClientOfUserId( event.GetInt("attacker") );
	bool bIsAttackerPlayer = true;
	if( attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker) ) // because attacker = 0 mean it is world.
		bIsAttackerPlayer = false;

	int entityid = event.GetInt("entityid");
	bool headshot = event.GetBool("headshot");
	int damagetype = event.GetInt("type");

	//調整受害者人名
	static char victim_name[64];
	if(bIsVictimPlayer)
	{
		if( IsFakeClient(victim) )
		{
			FormatEx(victim_name,sizeof(victim_name),"%N",victim);
			int index = StrContains(victim_name,")");
			if( index != -1 )
				FormatEx(victim_name,sizeof(victim_name),"%s",victim_name[index + 1]);
		}
		else
		{
			FormatEx(victim_name,sizeof(victim_name),"%N",victim);
		}
	}
	else
	{
		if(IsWitch(entityid))
		{
			FormatEx(victim_name,sizeof(victim_name),"Witch");
		}
		else
		{
			return;
		}
	}

	//某個東西殺死了玩家
	static char killinfo[128];
	if( bIsAttackerPlayer == false)
	{
		if(bIsVictimPlayer == true) // something killed player
		{
			int attackid = event.GetInt("attackerentid");
			if(IsWitch(attackid))
			{
				FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[16],victim_name);
			}
			else if(IsCommonInfected(attackid))
			{
				FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[17],victim_name);
			}
			else if(damagetype & DMG_BURN)
			{
				FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[7],victim_name);
			}
			else if(damagetype & DMG_FALL)
			{
				FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[19],victim_name);
			}
			else if(damagetype & DMG_BLAST)
			{
				FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[6],victim_name);
			}
			else 
			{
				FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[12],victim_name);
			}
			
			DisplayKillList(killinfo);
		}

		return;
	}

	int victimTeam, attackerTeam;
	if(bIsVictimPlayer) victimTeam = GetClientTeam(victim);
	if(bIsAttackerPlayer) attackerTeam = GetClientTeam(attacker);

	static char sWeapon[64];
	event.GetString("weapon", sWeapon,sizeof(sWeapon));
	//PrintToChatAll("weapon: %s", sWeapon);

	// 受害者玩家被系統處死判斷
	if(bIsAttackerPlayer && bIsVictimPlayer && attacker == victim)
	{
		switch(victimTeam)
		{
			case TEAM_SURVIVOR:
			{
				if(damagetype == (DMG_PREVENT_PHYSICS_FORCE + DMG_NEVERGIB) && strcmp(sWeapon, "world", false) == 0) // 傷害類型: 6144, 武器: world, 原因: ForcePlayerSuicide
				{
					FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[20],victim_name);
					DisplayKillList(killinfo);
					return;
				}
			}
			case TEAM_INFECTED:
			{
				int zombie = GetEntProp(victim, Prop_Send, "m_zombieClass");
				if(damagetype & DMG_FALL) // 特感墬樓傷害自己死掉
				{
					FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[19],victim_name);
					DisplayKillList(killinfo);
					return;
				}
				else if(damagetype == (DMG_PREVENT_PHYSICS_FORCE + DMG_NEVERGIB) && strcmp(sWeapon, "world", false) == 0) // 傷害類型: 6144, 武器: world, 原因: ForcePlayerSuicide 或 特感自動被導演處死
				{
					FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[20],victim_name);
					DisplayKillList(killinfo);
					return;
				}
				else if(zombie == ZC_TANK && damagetype == DMG_BULLET && strcmp(sWeapon, "tank_claw", false) == 0) // 傷害類型: 2, 武器: tank_claw, 原因: Tank卡住自動被處死
				{
					FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[20],victim_name);
					DisplayKillList(killinfo);
					return;
				}
				else if(zombie == ZC_TANK && victim == attacker && strcmp(sWeapon, "world", false) == 0 && damagetype == DMG_NEVERGIB) // 傷害類型: 2048, 武器: world, 受害者與攻擊者: tank自己, 原因: 真人A玩家失去tank控制權給真人B玩家時會觸發此涵式
				{
					return;
				}
			}
		}
	}

	// 特感殺死人類 或 特感殺死特感
	if( (bIsAttackerPlayer && attackerTeam == TEAM_INFECTED 
		&& bIsVictimPlayer && victimTeam == TEAM_SURVIVOR)
		|| 
		(bIsAttackerPlayer && attackerTeam == TEAM_INFECTED 
		&& bIsVictimPlayer && victimTeam == TEAM_INFECTED) )
	{
		static char attacker_name[64];
		if( IsFakeClient(attacker) )
		{
			FormatEx(attacker_name, sizeof(attacker_name), "%N", attacker);
			int index = StrContains(attacker_name,")");
			if( index != -1 )
				FormatEx(attacker_name,sizeof(attacker_name),"%s", attacker_name[index + 1]);
		}
		else
		{
			FormatEx(attacker_name, sizeof(attacker_name), "%N", attacker);
		}

		FormatEx(killinfo,sizeof(killinfo),"%s  %s  %s",attacker_name,g_kill_type[13],victim_name);
		DisplayKillList(killinfo);
		return;
	}

	// 取得武器圖案
	if( strncmp(sWeapon, "world", 5, false) == 0 || // "world", "worldspawn" (倒地流血死亡或其他自然死亡)
		strncmp(sWeapon, "trigger_hurt", 12, false) == 0 ) // "trigger_hurt", "trigger_hurt_ghost" (地圖上的即死傷害)
	{
		FormatEx(killinfo,sizeof(killinfo),"    %s  %s",g_kill_type[12],victim_name);
		DisplayKillList(killinfo);
		return;
	}

	if(!bIsAttackerPlayer) return;
		
	static char sWeaponType[64];
	if(g_weapon_name.GetString(sWeapon, sWeaponType, sizeof(sWeaponType)) == false)
	{
		// Unknown weapons
		FormatEx(sWeaponType, sizeof(sWeaponType), "%s", g_kill_type[21]);
	}

	//PrintToChatAll("sWeaponType: %s", sWeaponType);

	if(g_smSpecialWeapons.ContainsKey(sWeaponType) ) //不需要穿牆跟爆頭提示
	{
		FormatEx(killinfo,sizeof(killinfo),"%N  %s  %s",attacker, sWeaponType, victim_name);
	}
	else
	{
		if(bIsVictimPlayer)
		{
			if( headshot )
			{
				if( !g_smIgnoreWallWeapons.ContainsKey(sWeaponType) && IsPlayerKilledBehindWall(attacker, victim) )
					FormatEx(killinfo,sizeof(killinfo),"%N  %s %s %s  %s",attacker,g_kill_type[14],g_kill_type[15],sWeaponType,victim_name);
				else
					FormatEx(killinfo,sizeof(killinfo),"%N  %s %s  %s",attacker,g_kill_type[15],sWeaponType,victim_name);
			}
			else
			{
				if( !g_smIgnoreWallWeapons.ContainsKey(sWeaponType) && IsPlayerKilledBehindWall(attacker, victim) )
					FormatEx(killinfo,sizeof(killinfo),"%N  %s %s  %s",attacker,g_kill_type[14],sWeaponType,victim_name);
				else
					FormatEx(killinfo,sizeof(killinfo),"%N  %s  %s",attacker,sWeaponType,victim_name);
			}
		}
		else
		{
			if( headshot )
			{
				if( !g_smIgnoreWallWeapons.ContainsKey(sWeaponType) && IsEntityKilledBehindWall(attacker, entityid) )
					FormatEx(killinfo,sizeof(killinfo),"%N  %s %s %s  %s",attacker,g_kill_type[14],g_kill_type[15],sWeaponType,victim_name);
				else
					FormatEx(killinfo,sizeof(killinfo),"%N  %s %s  %s",attacker,g_kill_type[15],sWeaponType,victim_name);
			}
			else
			{
				if( !g_smIgnoreWallWeapons.ContainsKey(sWeaponType) && IsEntityKilledBehindWall(attacker, entityid) )
					FormatEx(killinfo,sizeof(killinfo),"%N  %s %s  %s",attacker,g_kill_type[14],sWeaponType,victim_name);
				else
					FormatEx(killinfo,sizeof(killinfo),"%N  %s  %s",attacker,sWeaponType,victim_name);
			}
		}
	}

	DisplayKillList(killinfo);
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for (int slot = KILL_HUD_BASE; slot < MAX_SIZE_HUD; slot++)
		RemoveHUD(slot);

	delete g_hud_killinfo;
	g_hud_killinfo = new ArrayList(ByteCountToCells(128));

	delete g_hKillHUDDecreaseTimer;
}

//Timer-------------------------------

Action Timer_KillHUDDecrease(Handle timer)
{
	if( g_hud_killinfo.Length == 0 )
	{
		g_hKillHUDDecreaseTimer = null;
		return Plugin_Stop;
	}

	g_hud_killinfo.Erase(0);

	HUD kill_list;
	int index;
	for(index = 0; index < KILL_INFO_MAX && index < g_hud_killinfo.Length; index++)
	{
		g_hud_killinfo.GetString(index, kill_list.info, sizeof(kill_list.info));
		kill_list.slot = index + KILL_HUD_BASE;
		kill_list.flag = g_iHUDFlags;
		kill_list.pos  = g_HUDpos[kill_list.slot];
		kill_list.Place();
	}

	while(index < KILL_INFO_MAX)
	{
		RemoveHUD(index + KILL_HUD_BASE);
		index++;
	}

	return Plugin_Continue;
}

//Function-------------------------------

void DisplayKillList(const char[] info)
{
	HUD kill_list;
	FormatEx(kill_list.info, sizeof(kill_list.info), "%s", info);
	g_hud_killinfo.PushString(info);

	if( g_hud_killinfo.Length <= g_iCvarKillInfoNumber )
	{
		kill_list.slot = g_hud_killinfo.Length-1 + KILL_HUD_BASE;
		kill_list.flag = g_iHUDFlags;
		kill_list.pos  = g_HUDpos[kill_list.slot];
		kill_list.Place();
	}
	else
	{
		g_hud_killinfo.Erase(0);
		for(int index = 0; index < KILL_INFO_MAX && index < g_hud_killinfo.Length; index++)
		{
			g_hud_killinfo.GetString(index, kill_list.info, sizeof(kill_list.info));
			kill_list.slot = index+KILL_HUD_BASE;
			kill_list.flag = g_iHUDFlags;
			kill_list.pos  = g_HUDpos[kill_list.slot];
			kill_list.Place();
		}
	}

	delete g_hKillHUDDecreaseTimer;
	g_hKillHUDDecreaseTimer = CreateTimer(g_fCvarHudDecrease, Timer_KillHUDDecrease, _, TIMER_REPEAT);
}

bool IsPlayerKilledBehindWall(int attacker,int client)
{
	float vPos_a[3],vPos_c[3];
	GetClientEyePosition(attacker, vPos_a);
	GetClientEyePosition(client,vPos_c);
	Handle hTrace = TR_TraceRayFilterEx(vPos_a, vPos_c,MASK_PLAYERSOLID, RayType_EndPoint,TraceRayNoPlayers,client);
	if( hTrace != null )
	{
		if( TR_DidHit(hTrace) )
		{
			delete hTrace;
			return true;
		}
	}
	delete hTrace;
	return false;
}

bool TraceRayNoPlayers(int entity, int mask, any data)
{
    if( entity == data || (entity >= 1 && entity <= MaxClients) )
    {
        return false;
    }
    return true;
}

bool IsEntityKilledBehindWall(int attacker, int entity)
{
	float vAngles[3],vOrigin[3];
	
	GetClientEyePosition(attacker, vOrigin);
	GetClientEyeAngles(attacker, vAngles);
	
	//get endpoint for teleport
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceRayNoEntities);
	
	if(TR_DidHit(trace))
	{
		if(TR_GetEntityIndex(trace)==entity)
		{
			delete trace;
			return false;
		}
	}

	delete trace;
	return true;
}

bool TraceRayNoEntities(int entity, int mask, any data)
{
    if( entity == data || (entity >= 1 && entity <= MaxClients) )
    {
        return false;
    }
    return true;
}

void LoadEventWeaponName()
{
	g_weapon_name = new StringMap();

	g_weapon_name.SetString("melee",g_kill_type[0]);

	g_weapon_name.SetString("pistol",g_kill_type[1]);
	g_weapon_name.SetString("pistol_magnum",g_kill_type[1]);
	g_weapon_name.SetString("dual_pistols",g_kill_type[1]);

	g_weapon_name.SetString("smg",g_kill_type[2]);
	g_weapon_name.SetString("smg_silenced",g_kill_type[2]);
	g_weapon_name.SetString("smg_mp5",g_kill_type[2]);

	g_weapon_name.SetString("rifle",g_kill_type[3]);
	g_weapon_name.SetString("rifle_ak47",g_kill_type[3]);
	g_weapon_name.SetString("rifle_sg552",g_kill_type[3]);
	g_weapon_name.SetString("rifle_desert",g_kill_type[3]);

	g_weapon_name.SetString("pumpshotgun",g_kill_type[4]);
	g_weapon_name.SetString("shotgun_chrome",g_kill_type[4]);
	g_weapon_name.SetString("autoshotgun",g_kill_type[4]);
	g_weapon_name.SetString("shotgun_spas",g_kill_type[4]);

	g_weapon_name.SetString("hunting_rifle",g_kill_type[5]);
	g_weapon_name.SetString("sniper_military",g_kill_type[5]);
	g_weapon_name.SetString("sniper_scout",g_kill_type[5]);
	g_weapon_name.SetString("sniper_awp",g_kill_type[5]);

	// explode
	g_weapon_name.SetString("pipe_bomb",g_kill_type[6]);
	g_weapon_name.SetString("env_explosion",g_kill_type[6]);

	// fire
	g_weapon_name.SetString("inferno",g_kill_type[7]);
	g_weapon_name.SetString("entityflame",g_kill_type[7]);

	g_weapon_name.SetString("rifle_m60",g_kill_type[8]);

	g_weapon_name.SetString("grenade_launcher_projectile",g_kill_type[9]);

	// boomer/player killed by push
	g_weapon_name.SetString("boomer",g_kill_type[10]);
	g_weapon_name.SetString("player",g_kill_type[10]);

	g_weapon_name.SetString("prop_minigun_l4d1",g_kill_type[11]);
	g_weapon_name.SetString("prop_minigun",g_kill_type[11]);

	// killed by map
	g_weapon_name.SetString("world",g_kill_type[12]);
	g_weapon_name.SetString("worldspawn",g_kill_type[12]);
	g_weapon_name.SetString("trigger_hurt",g_kill_type[12]);

	g_weapon_name.SetString("chainsaw",g_kill_type[18]);

	g_smSpecialWeapons = new StringMap();
	g_smSpecialWeapons.SetValue(g_kill_type[6], true);
	g_smSpecialWeapons.SetValue(g_kill_type[7], true);
	g_smSpecialWeapons.SetValue(g_kill_type[10], true);
	g_smSpecialWeapons.SetValue(g_kill_type[21], true);

	g_smIgnoreWallWeapons = new StringMap();
	g_smIgnoreWallWeapons.SetValue(g_kill_type[9], true);
	g_smIgnoreWallWeapons.SetValue(g_kill_type[0], true);
	g_smIgnoreWallWeapons.SetValue(g_kill_type[18], true);
	g_smIgnoreWallWeapons.SetValue(g_kill_type[21], true);
}

bool IsWitch(int entity)
{
    if (entity > 0 && IsValidEntity(entity))
    {
        char strClassName[64];
        GetEntityClassname(entity, strClassName, sizeof(strClassName));
        return strcmp(strClassName, CLASSNAME_WITCH, false) == 0;
    }
    return false;
}

bool IsCommonInfected(int entity)
{
	if (entity > 0 && IsValidEntity(entity))
	{
		char entType[64];
		GetEntityClassname(entity, entType, sizeof(entType));
		return StrEqual(entType, CLASSNAME_INFECTED);
	}
	return false;
}

// HUD-------------------------------

/**
 * Passes a table that defines your in-game HUD to the engine.
 * From there on, you can modify the table to cause changes.
 * Though often you wont, you will instead use a dataval entry to define a simple lambda that
 * returns the up-to-date value to the HUD system.
*/
/**
 * Passes a table that defines your in-game HUD to the engine.
 *
 * @param slot			HUD slot.
 * @param flags			flags(出于某些未知原因需要添加HUD_FLAG_TEXT falg才能正常绘制)..
 * @param dataval		used for data of destination string buffer.
 * @param ...			Variable number of format parameters.
 * @noreturn
 * @error				Invalid HUD slot.
 */
void HUDSetLayout(int slot, int flags, const char[] dataval, any ...) {
	static char str[128];
	VFormat(str, sizeof str, dataval, 4);

	GameRules_SetProp("m_iScriptedHUDFlags", flags, _, slot, true);
	GameRules_SetPropString("m_szScriptedHUDStringSet", str, true, slot);
}

/**
 * Note:HUDPlace(slot,x,y,w,h): moves the given HUD slot to the XY position specified, with new W and H.
 * This is for doing occasional highlight/make a point type things,
 * or small changes to layout w/o having to build a new .res to put in a VPK.
 * We suspect if you want to do a super fancy HUD you will want to create your own hudscriptedmode.res file,
 * just making sure to use the same element naming conventions so you can still talk to them from script.
 * x,y,w,h are all 0.0-1.0 screen relative coordinates (actually, a bit smaller than the screen, but anyway).
 * So a box near middle might be set as (0.4,0.45,0.2,0.1) or so.
 */
/**
 * Place a slot in game.
 *
 * @param slot			HUD slot.
 * @param x				screen x position.
 * @param y				screen y position.
 * @param width			screen slot width.
 * @param height		screen slot height.
 * @noreturn
 * @error				Invalid HUD slot.
 */
void HUDPlace(int slot, float x, float y, float width, float height) {
	GameRules_SetPropFloat("m_fScriptedHUDPosX", x, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDPosY", y, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDWidth", width, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDHeight", height, slot, true);
}

/**
 * Removes a slot from game.
 *
 * @param slot			HUD slot.
 * @noreturn
 * @error				Invalid HUD slot.
 */
void RemoveHUD(int slot) {
	GameRules_SetProp("m_iScriptedHUDInts", 0, _, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDFloats", 0.0, slot, true);
	GameRules_SetProp("m_iScriptedHUDFlags", HUD_FLAG_NOTVISIBLE, _, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDPosX", 0.0, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDPosY", 0.0, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDWidth", 0.0, slot, true);
	GameRules_SetPropFloat("m_fScriptedHUDHeight", 0.0, slot, true);
	GameRules_SetPropString("m_szScriptedHUDStringSet", "", true, slot);
}