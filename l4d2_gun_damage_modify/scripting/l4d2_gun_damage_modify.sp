#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#define DEBUG 0

public Plugin myinfo = 
{
	name = "Modify every weapon damage done to Tank,SI,Witch,Common in l4d2",
	author = "Harry Potter",
	description = "as the name says, you dumb fuck",
	version = "1.3-2024/2/23",
	url = "https://steamcommunity.com/profiles/76561198026784913"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

#define L4D_TEAM_INFECTED  	3
#define L4D_TEAM_SURVIVOR  	2
#define L4D_TEAM_SPECTATOR 	1

#define ZC_SMOKER       	1
#define ZC_BOOMER       	2
#define ZC_HUNTER       	3
#define ZC_JOCKEY       	5
#define ZC_CHARGER      	6
#define ZC_TANK         	8

#define CLASSNAME_LENGTH 	64

//enum
enum WeaponID
{
	ID_NONE,
	ID_PISTOL,
	//ID_DUAL_PISTOL,
	ID_SMG,
	ID_PUMPSHOTGUN,
	ID_RIFLE,
	ID_AUTOSHOTGUN,
	ID_HUNTING_RIFLE,
	ID_SMG_SILENCED,
	ID_SMG_MP5,
	ID_CHROMESHOTGUN,
	ID_MAGNUM,
	ID_AK47,
	ID_RIFLE_DESERT,
	ID_SNIPER_MILITARY,
	ID_GRENADE,
	ID_SG552,
	ID_M60,
	ID_AWP,
	ID_SCOUT,
	ID_SPASSHOTGUN,
	//ID_Melee,
	ID_WEAPON_MAX
}

enum VictimID
{
	Victim_NONE,
	Victim_Tank,
	Victim_Witch,
	Victim_SI,
	Victim_Common,
	Victim_MAX
}

ConVar g_hCvarAllow,
	g_hCvarWeaponDamageModfiy[view_as<int>(ID_WEAPON_MAX)][view_as<int>(Victim_MAX)];

bool g_bCvarAllow;
float g_fCvarWeaponDamageModfiy[view_as<int>(ID_WEAPON_MAX)][view_as<int>(Victim_MAX)];

int g_iOffset_Incapacitated;

StringMap g_smWeaponNameID;

public void OnPluginStart()
{
	g_hCvarAllow = CreateConVar(	"l4d_gun_damage_modify_enable", "1",
								"Enable gun damage modify plugin. [0-Disable,1-Enable]",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );			

	g_hCvarWeaponDamageModfiy[ID_PISTOL][Victim_Tank] = CreateConVar("l4d_pistol_damage_tank_multi", "1.0",
								"Modfiy pistol Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_PISTOL][Victim_Witch] = CreateConVar("l4d_pistol_damage_witch_multi", "1.0",
								"Modfiy pistol Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_PISTOL][Victim_SI] = CreateConVar("l4d_pistol_damage_SI_multi", "1.0",
								"Modfiy pistol Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_PISTOL][Victim_Common] = CreateConVar("l4d_pistol_damage_common_multi", "1.0",
								"Modfiy pistol Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_SMG][Victim_Tank] = CreateConVar("l4d_smg_damage_tank_multi", "1.0",
								"Modfiy smg Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_SMG][Victim_Witch] = CreateConVar("l4d_smg_damage_witch_multi", "1.0",
								"Modfiy smg Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SMG][Victim_SI] = CreateConVar("l4d_smg_damage_SI_multi", "1.0",
								"Modfiy smg Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SMG][Victim_Common] = CreateConVar("l4d_smg_damage_common_multi", "1.0",
								"Modfiy smg Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);																														
	g_hCvarWeaponDamageModfiy[ID_PUMPSHOTGUN][Victim_Tank] = CreateConVar("l4d_pumpshotgun_damage_tank_multi", "1.0",
								"Modfiy pumpshotgun Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_PUMPSHOTGUN][Victim_Witch] = CreateConVar("l4d_pumpshotgun_damage_witch_multi", "1.0",
								"Modfiy pumpshotgun Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_PUMPSHOTGUN][Victim_SI] = CreateConVar("l4d_pumpshotgun_damage_SI_multi", "1.0",
								"Modfiy pumpshotgun Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_PUMPSHOTGUN][Victim_Common] = CreateConVar("l4d_pumpshotgun_damage_common_multi", "1.0",
								"Modfiy pumpshotgun Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_RIFLE][Victim_Tank] = CreateConVar("l4d_rifle_damage_tank_multi", "1.0",
								"Modfiy rifle Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_RIFLE][Victim_Witch] = CreateConVar("l4d_rifle_damage_witch_multi", "1.0",
								"Modfiy rifle Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_RIFLE][Victim_SI] = CreateConVar("l4d_rifle_damage_SI_multi", "1.0",
								"Modfiy rifle Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_RIFLE][Victim_Common] = CreateConVar("l4d_rifle_damage_common_multi", "1.0",
								"Modfiy rifle Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_AUTOSHOTGUN][Victim_Tank] = CreateConVar("l4d_autoshotgun_damage_tank_multi", "1.0",
								"Modfiy auto shotgun Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_AUTOSHOTGUN][Victim_Witch] = CreateConVar("l4d_autoshotgun_damage_witch_multi", "1.0",
								"Modfiy auto shotgun Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_AUTOSHOTGUN][Victim_SI] = CreateConVar("l4d_autoshotgun_damage_SI_multi", "1.0",
								"Modfiy auto shotgun Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_AUTOSHOTGUN][Victim_Common] = CreateConVar("l4d_autoshotgun_damage_common_multi", "1.0",
								"Modfiy auto shotgun Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_HUNTING_RIFLE][Victim_Tank] = CreateConVar("l4d_huntingrifle_damage_tank_multi", "1.0",
								"Modfiy hunting rifle Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_HUNTING_RIFLE][Victim_Witch] = CreateConVar("l4d_huntingrifle_damage_witch_multi", "1.0",
								"Modfiy hunting rifle Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_HUNTING_RIFLE][Victim_SI] = CreateConVar("l4d_huntingrifle_damage_SI_multi", "1.0",
								"Modfiy hunting rifle Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_HUNTING_RIFLE][Victim_Common] = CreateConVar("l4d_huntingrifle_damage_common_multi", "1.0",
								"Modfiy hunting rifle Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_SMG_SILENCED][Victim_Tank] = CreateConVar("l4d_smgsilenced_damage_tank_multi", "1.0",
								"Modfiy silenced smg Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_SMG_SILENCED][Victim_Witch] = CreateConVar("l4d_smgsilenced_damage_witch_multi", "1.0",
								"Modfiy silenced smg Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SMG_SILENCED][Victim_SI] = CreateConVar("l4d_smgsilenced_damage_SI_multi", "1.0",
								"Modfiy silenced smg Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SMG_SILENCED][Victim_Common] = CreateConVar("l4d_smgsilenced_damage_common_multi", "1.0",
								"Modfiy silenced smg Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_SMG_MP5][Victim_Tank] = CreateConVar("l4d_mp5_damage_tank_multi", "1.0",
								"Modfiy mp5 Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_SMG_MP5][Victim_Witch] = CreateConVar("l4d_mp5_damage_witch_multi", "1.0",
								"Modfiy mp5 Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SMG_MP5][Victim_SI] = CreateConVar("l4d_mp5_damage_SI_multi", "1.0",
								"Modfiy mp5 Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SMG_MP5][Victim_Common] = CreateConVar("l4d_mp5_damage_common_multi", "1.0",
								"Modfiy mp5 Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_CHROMESHOTGUN][Victim_Tank] = CreateConVar("l4d_chromeshotgun_damage_tank_multi", "1.0",
								"Modfiy chrome shotgun Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_CHROMESHOTGUN][Victim_Witch] = CreateConVar("l4d_chromeshotgun_damage_witch_multi", "1.0",
								"Modfiy chrome shotgun Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_CHROMESHOTGUN][Victim_SI] = CreateConVar("l4d_chromeshotgun_damage_SI_multi", "1.0",
								"Modfiy chrome shotgun Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_CHROMESHOTGUN][Victim_Common] = CreateConVar("l4d_chromeshotgun_damage_common_multi", "1.0",
								"Modfiy chrome shotgun Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);								
	g_hCvarWeaponDamageModfiy[ID_MAGNUM][Victim_Tank] = CreateConVar("l4d_magnum_damage_tank_multi", "1.0",
								"Modfiy magnum Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_MAGNUM][Victim_Witch] = CreateConVar("l4d_magnum_damage_witch_multi", "1.0",
								"Modfiy magnum Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_MAGNUM][Victim_SI] = CreateConVar("l4d_magnum_damage_SI_multi", "1.0",
								"Modfiy magnum Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_MAGNUM][Victim_Common] = CreateConVar("l4d_magnum_damage_common_multi", "1.0",
								"Modfiy magnum Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_AK47][Victim_Tank] = CreateConVar("l4d_ak47_damage_tank_multi", "1.0",
								"Modfiy ak47 Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_AK47][Victim_Witch] = CreateConVar("l4d_ak47_damage_witch_multi", "1.0",
								"Modfiy ak47 Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_AK47][Victim_SI] = CreateConVar("l4d_ak47_damage_SI_multi", "1.0",
								"Modfiy ak47 Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_AK47][Victim_Common] = CreateConVar("l4d_ak47_damage_common_multi", "1.0",
								"Modfiy ak47 Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_RIFLE_DESERT][Victim_Tank] = CreateConVar("l4d_rifledesert_damage_tank_multi", "1.0",
								"Modfiy rifle desert Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_RIFLE_DESERT][Victim_Witch] = CreateConVar("l4d_rifledesert_damage_witch_multi", "1.0",
								"Modfiy rifle desert Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_RIFLE_DESERT][Victim_SI] = CreateConVar("l4d_rifledesert_damage_SI_multi", "1.0",
								"Modfiy rifle desert Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_RIFLE_DESERT][Victim_Common] = CreateConVar("l4d_rifledesert_damage_common_multi", "1.0",
								"Modfiy rifle desert Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_SNIPER_MILITARY][Victim_Tank] = CreateConVar("l4d_militarysniper_damage_tank_multi", "1.0",
								"Modfiy military sniper Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_SNIPER_MILITARY][Victim_Witch] = CreateConVar("l4d_militarysniper_damage_witch_multi", "1.0",
								"Modfiy military sniper Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SNIPER_MILITARY][Victim_SI] = CreateConVar("l4d_militarysniper_damage_SI_multi", "1.0",
								"Modfiy military sniper Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SNIPER_MILITARY][Victim_Common] = CreateConVar("l4d_militarysniper_damage_common_multi", "1.0",
								"Modfiy military sniper Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_GRENADE][Victim_Tank] = CreateConVar("l4d_grenadelauncher_damage_tank_multi", "1.0",
								"Modfiy grenade launcher Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_GRENADE][Victim_Witch] = CreateConVar("l4d_grenadelauncher_damage_witch_multi", "1.0",
								"Modfiy grenade launcher Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_GRENADE][Victim_SI] = CreateConVar("l4d_grenadelauncher_damage_SI_multi", "1.0",
								"Modfiy grenade launcher Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_GRENADE][Victim_Common] = CreateConVar("l4d_grenadelauncher_damage_common_multi", "1.0",
								"Modfiy grenade launcher Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);																					
	g_hCvarWeaponDamageModfiy[ID_SG552][Victim_Tank] = CreateConVar("l4d_sg552_damage_tank_multi", "1.0",
								"Modfiy sg552 Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_SG552][Victim_Witch] = CreateConVar("l4d_sg552_damage_witch_multi", "1.0",
								"Modfiy sg552 Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SG552][Victim_SI] = CreateConVar("l4d_sg552_damage_SI_multi", "1.0",
								"Modfiy sg552 Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SG552][Victim_Common] = CreateConVar("l4d_sg552_damage_common_multi", "1.0",
								"Modfiy sg552 Damage to Common multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_M60][Victim_Tank] = CreateConVar("l4d_m60_damage_tank_multi", "1.0",
								"Modfiy m60 Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_M60][Victim_Witch] = CreateConVar("l4d_m60_damage_witch_multi", "1.0",
								"Modfiy m60 Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_M60][Victim_SI] = CreateConVar("l4d_m60_damage_SI_multi", "1.0",
								"Modfiy m60 Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_M60][Victim_Common] = CreateConVar("l4d_m60_damage_common_multi", "1.0",
								"Modfiy m60 Damage to Common multi. (0=No Damage, -1: Don't modify)",	
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_AWP][Victim_Tank] = CreateConVar("l4d_awp_damage_tank_multi", "1.0",
								"Modfiy awp Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_AWP][Victim_Witch] = CreateConVar("l4d_awp_damage_witch_multi", "1.0",
								"Modfiy awp Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_AWP][Victim_SI] = CreateConVar("l4d_awp_damage_SI_multi", "1.0",
								"Modfiy awp Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_AWP][Victim_Common] = CreateConVar("l4d_awp_damage_common_multi", "1.0",
								"Modfiy awp Damage to Common multi. (0=No Damage, -1: Don't modify)",	
								FCVAR_NOTIFY, true, 0.0);	
	g_hCvarWeaponDamageModfiy[ID_SCOUT][Victim_Tank] = CreateConVar("l4d_scout_damage_tank_multi", "1.0",
								"Modfiy scout Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_SCOUT][Victim_Witch] = CreateConVar("l4d_scout_damage_witch_multi", "1.0",
								"Modfiy scout Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SCOUT][Victim_SI] = CreateConVar("l4d_scout_damage_SI_multi", "1.0",
								"Modfiy scout Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SCOUT][Victim_Common] = CreateConVar("l4d_scout_damage_common_multi", "1.0",
								"Modfiy scout Damage to Common multi. (0=No Damage, -1: Don't modify)",	
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SPASSHOTGUN][Victim_Tank] = CreateConVar("l4d_spasshotgun_damage_tank_multi", "1.0",
								"Modfiy spas shotgun Damage to tank multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);
	g_hCvarWeaponDamageModfiy[ID_SPASSHOTGUN][Victim_Witch] = CreateConVar("l4d_spasshotgun_damage_witch_multi", "1.0",
								"Modfiy spas shotgun Damage to witch multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SPASSHOTGUN][Victim_SI] = CreateConVar("l4d_spasshotgun_damage_SI_multi", "1.0",
								"Modfiy spas shotgun Damage to SI multi. (0=No Damage, -1: Don't modify)",
								FCVAR_NOTIFY, true, 0.0);		
	g_hCvarWeaponDamageModfiy[ID_SPASSHOTGUN][Victim_Common] = CreateConVar("l4d_spasshotgun_damage_common_multi", "1.0",
								"Modfiy spas shotgun Damage to Common multi. (0=No Damage, -1: Don't modify)",	
								FCVAR_NOTIFY, true, 0.0);	

	AutoExecConfig(true, "l4d2_gun_damage_modify");

	GetCvars();
	g_hCvarAllow.AddChangeHook(ConVarChanged_Cvars);
	for(WeaponID i = ID_PISTOL ; i < ID_WEAPON_MAX ; ++i)
	{
		for(VictimID j = Victim_Tank ; j < Victim_MAX; ++j)
		{
			g_hCvarWeaponDamageModfiy[i][j].AddChangeHook(ConVarChanged_Cvars);
		}
	}

	SetWeaponNameId();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarAllow = g_hCvarAllow.BoolValue;
	for(WeaponID i = ID_PISTOL ; i < ID_WEAPON_MAX ; ++i)
	{
		for(VictimID j = Victim_Tank ; j < Victim_MAX; ++j)
		{
			g_fCvarWeaponDamageModfiy[i][j] = g_hCvarWeaponDamageModfiy[i][j].FloatValue;
		}
	}
}

void SetWeaponNameId()
{
	g_smWeaponNameID = new StringMap ();
	g_iOffset_Incapacitated = FindSendPropInfo("Tank", "m_isIncapacitated");

	g_smWeaponNameID.SetValue("", ID_NONE);
	g_smWeaponNameID.SetValue("weapon_pistol", ID_PISTOL);
	//g_smWeaponNameID.SetValue("weapon_pistol", ID_DUAL_PISTOL);
	g_smWeaponNameID.SetValue("weapon_smg", ID_SMG);
	g_smWeaponNameID.SetValue("weapon_pumpshotgun", ID_PUMPSHOTGUN);
	g_smWeaponNameID.SetValue("weapon_rifle", ID_RIFLE);
	g_smWeaponNameID.SetValue("weapon_autoshotgun", ID_AUTOSHOTGUN);
	g_smWeaponNameID.SetValue("weapon_hunting_rifle", ID_HUNTING_RIFLE);
	g_smWeaponNameID.SetValue("weapon_smg_silenced", ID_SMG_SILENCED);
	g_smWeaponNameID.SetValue("weapon_smg_mp5", ID_SMG_MP5);
	g_smWeaponNameID.SetValue("weapon_shotgun_chrome", ID_CHROMESHOTGUN);
	g_smWeaponNameID.SetValue("weapon_pistol_magnum", ID_MAGNUM);
	g_smWeaponNameID.SetValue("weapon_rifle_ak47", ID_AK47);
	g_smWeaponNameID.SetValue("weapon_rifle_desert", ID_RIFLE_DESERT);
	g_smWeaponNameID.SetValue("weapon_sniper_military", ID_SNIPER_MILITARY);
	g_smWeaponNameID.SetValue("weapon_grenade_launcher", ID_GRENADE);
	g_smWeaponNameID.SetValue("weapon_rifle_sg552", ID_SG552);
	g_smWeaponNameID.SetValue("weapon_rifle_m60", ID_M60);
	g_smWeaponNameID.SetValue("weapon_sniper_awp", ID_AWP);
	g_smWeaponNameID.SetValue("weapon_sniper_scout", ID_SCOUT);
	g_smWeaponNameID.SetValue("weapon_shotgun_spas", ID_SPASSHOTGUN);
	//g_smWeaponNameID.SetValue("weapon_melee", ID_Melee);
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public void OnEntityCreated(int entity, const char[] classname) 
{ 
	if (!IsValidEntityIndex(entity))
		return;

	switch (classname[0])
	{
		case 'i':
		{
			if(strncmp(classname, "infected", 18) == 0)
			{
				SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage); 
			}
		}
		case 'w':
		{
			if(strncmp(classname, "witch", 18) == 0)
			{
				SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(damage <= 0.0 || g_bCvarAllow == false) return Plugin_Continue;
	if(!IsClientAndInGame(attacker) || 
		GetClientTeam(attacker) != L4D_TEAM_SURVIVOR ||
		attacker == victim
	) return Plugin_Continue;

	VictimID victimId = Victim_NONE;

	if(IsClientAndInGame(victim) && GetClientTeam(victim) == L4D_TEAM_INFECTED && IsPlayerAlive(victim))
	{
		if(GetEntProp(victim, Prop_Send, "m_zombieClass") == ZC_TANK)
		{
			if(IsTankDying(victim)) return Plugin_Continue;

			victimId = Victim_Tank;
		}
		else
			victimId = Victim_SI;
	}

	if(IsCommonInfected(victim)) victimId = Victim_Common;
	if(IsWitch(victim)) victimId = Victim_Witch;
	
	if(victimId == Victim_NONE) return Plugin_Continue;

	damage = float(RoundToNearest(damage));

	if(damagetype & DMG_BULLET)
	{
		static char sWeaponName[CLASSNAME_LENGTH];
		GetClientWeapon(attacker,sWeaponName, sizeof(sWeaponName));
		#if DEBUG
			PrintToChatAll("%N use %s to attack %d, damage: %f - > %f",attacker,sWeaponName,victim,damage,damage * g_hCvarWeaponDamageModfiy[weaponId][victimId].FloatValue);
		#endif
		WeaponID weaponId = GetWeaponID(sWeaponName);
		if(weaponId == ID_NONE) return Plugin_Continue; //找不到武器名稱
		if(g_fCvarWeaponDamageModfiy[weaponId][victimId] < 0.0) return Plugin_Continue; //不修改

		damage = damage * g_fCvarWeaponDamageModfiy[weaponId][victimId];
	}
	else if(damagetype & DMG_BLAST)
	{
		static char classname[CLASSNAME_LENGTH];
		GetEntityClassname(inflictor, classname, sizeof(classname));
		if(strncmp(classname, "grenade_launcher_projectile", 27, false) != 0 ) return Plugin_Continue; //非榴彈發射器
		if(g_fCvarWeaponDamageModfiy[ID_GRENADE][victimId] < 0.0) return Plugin_Continue; //不修改
		
		damage = damage * g_fCvarWeaponDamageModfiy[ID_GRENADE][victimId];
	}
	else
	{
		return Plugin_Continue;
	}

	return Plugin_Changed;
}

stock bool IsClientAndInGame(int client)
{
	if (0 < client && client <= MaxClients)
	{	
		return IsClientInGame(client);
	}
	return false;
}

WeaponID GetWeaponID(char[] sWeaponName)
{
	WeaponID index = ID_NONE;

	if ( g_smWeaponNameID.GetValue(sWeaponName, index) )
	{
		return index;
	}

	return index;
}

bool IsCommonInfected(int entity)
{
	if(entity && IsValidEntity(entity) && IsValidEdict(entity))
	{
		char classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		return StrEqual(classname, "infected");
	}
	return false;
} 

bool IsWitch(int entity)
{
	if(entity && IsValidEntity(entity) && IsValidEdict(entity))
	{
		char classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		return StrEqual(classname, "witch");
	}
	return false;
}  

bool IsTankDying(int tankclient)
{
	if (!tankclient) return false;
 
	return view_as<bool>(GetEntData(tankclient, g_iOffset_Incapacitated));
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}