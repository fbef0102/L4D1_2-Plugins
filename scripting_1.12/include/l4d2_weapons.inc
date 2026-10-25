#if defined __l4d2_weapons_inc__
	#endinput
#endif
#define __l4d2_weapons_inc__

#include <sdktools>

/**
 * Version: 1.1h (2025-3-21)
 * Author: HarryPotter
 */


enum /*L4D2WeaponSlot*/
{
	L4D2WeaponSlot_None = -1,
	L4D2WeaponSlot_Primary,
	L4D2WeaponSlot_Secondary,
	L4D2WeaponSlot_Throwable,
	L4D2WeaponSlot_HeavyHealthItem,
	L4D2WeaponSlot_LightHealthItem,
	
	L4D2WeaponSlot_Size //5 size
};

// Weapon ID enumerations.
// These values are *NOT* arbitrary! 
// They are used in game as the weaponid for weapon_spawn entities (member: m_weaponID)
enum /*WeaponId*/
{
	WEPID_NONE,             // 0
	WEPID_PISTOL,           // 1
	WEPID_SMG,              // 2
	WEPID_PUMPSHOTGUN,      // 3
	WEPID_AUTOSHOTGUN,      // 4
	WEPID_RIFLE,            // 5
	WEPID_HUNTING_RIFLE,    // 6
	WEPID_SMG_SILENCED,     // 7
	WEPID_SHOTGUN_CHROME,   // 8
	WEPID_RIFLE_DESERT,     // 9
	WEPID_SNIPER_MILITARY,  // 10
	WEPID_SHOTGUN_SPAS,     // 11
	WEPID_FIRST_AID_KIT,    // 12
	WEPID_MOLOTOV,          // 13
	WEPID_PIPE_BOMB,        // 14
	WEPID_PAIN_PILLS,       // 15
	WEPID_GASCAN,           // 16
	WEPID_PROPANE_TANK,     // 17
	WEPID_OXYGEN_TANK,      // 18
	WEPID_MELEE,            // 19
	WEPID_CHAINSAW,         // 20
	WEPID_GRENADE_LAUNCHER, // 21
	WEPID_AMMO_PACK,        // 22
	WEPID_ADRENALINE,       // 23
	WEPID_DEFIBRILLATOR,    // 24
	WEPID_VOMITJAR,         // 25
	WEPID_RIFLE_AK47,       // 26
	WEPID_GNOME_CHOMPSKI,   // 27, weapon_gnome
	WEPID_COLA_BOTTLES,     // 28, weapon_cola_bottles
	WEPID_FIREWORKS_BOX,    // 29, weapon_fireworkcrate
	WEPID_INCENDIARY_AMMO,  // 30, weapon_upgradepack_incendiary
	WEPID_FRAG_AMMO,        // 31, weapon_upgradepack_explosive
	WEPID_PISTOL_MAGNUM,    // 32
	WEPID_SMG_MP5,          // 33
	WEPID_RIFLE_SG552,      // 34
	WEPID_SNIPER_AWP,       // 35
	WEPID_SNIPER_SCOUT,     // 36
	WEPID_RIFLE_M60,        // 37
	WEPID_TANK_CLAW,        // 38
	WEPID_HUNTER_CLAW,      // 39
	WEPID_CHARGER_CLAW,     // 40
	WEPID_BOOMER_CLAW,      // 41
	WEPID_SMOKER_CLAW,      // 42
	WEPID_SPITTER_CLAW,     // 43
	WEPID_JOCKEY_CLAW,      // 44
	WEPID_MACHINEGUN,       // 45
	WEPID_VOMIT,            // 46
	WEPID_SPLAT,            // 47
	WEPID_POUNCE,           // 48
	WEPID_LOUNGE,           // 49
	WEPID_PULL,             // 50
	WEPID_CHOKE,            // 51
	WEPID_ROCK,             // 52
	WEPID_PHYSICS,          // 53
	WEPID_AMMO,             // 54
	WEPID_UPGRADE_ITEM,     // 55

	WEPID_SIZE //56 size
};

// These values are arbitrary
enum /*MeleeWeaponId*/
{
	WEPID_MELEE_NONE,
	WEPID_KNIFE,
	WEPID_BASEBALL_BAT,
	WEPID_CRICKET_BAT,
	WEPID_CROWBAR,
	WEPID_ELECTRIC_GUITAR,
	WEPID_FIREAXE,
	WEPID_FRYING_PAN,
	WEPID_GOLF_CLUB,
	WEPID_KATANA,
	WEPID_MACHETE,
	WEPID_TONFA,
	WEPID_SHOVEL,
	WEPID_PITCHFORK,
	
	WEPID_MELEES_SIZE = 14 //14 size
};

// Weapon class names for each of the weapons, used in identification.
stock const char WeaponNames[WEPID_SIZE][] =
{
	"weapon_none", "weapon_pistol", "weapon_smg",                                            // 0
	"weapon_pumpshotgun", "weapon_autoshotgun", "weapon_rifle",                              // 3
	"weapon_hunting_rifle", "weapon_smg_silenced", "weapon_shotgun_chrome",                  // 6
	"weapon_rifle_desert", "weapon_sniper_military", "weapon_shotgun_spas",                  // 9
	"weapon_first_aid_kit", "weapon_molotov", "weapon_pipe_bomb",                            // 12
	"weapon_pain_pills", "weapon_gascan", "weapon_propanetank",                              // 15
	"weapon_oxygentank", "weapon_melee", "weapon_chainsaw",                                  // 18
	"weapon_grenade_launcher", "weapon_ammo_pack", "weapon_adrenaline",                      // 21
	"weapon_defibrillator", "weapon_vomitjar", "weapon_rifle_ak47",                          // 24
	"weapon_gnome", "weapon_cola_bottles", "weapon_fireworkcrate",                           // 27
	"weapon_upgradepack_incendiary", "weapon_upgradepack_explosive", "weapon_pistol_magnum", // 30
	"weapon_smg_mp5", "weapon_rifle_sg552", "weapon_sniper_awp",                             // 33
	"weapon_sniper_scout", "weapon_rifle_m60", "weapon_tank_claw",                           // 36
	"weapon_hunter_claw", "weapon_charger_claw", "weapon_boomer_claw",                       // 39
	"weapon_smoker_claw", "weapon_spitter_claw", "weapon_jockey_claw",                       // 42
	"weapon_machinegun", "vomit", "splat",                                                   // 45
	"pounce", "lounge", "pull",                                                              // 48
	"choke", "rock", "physics",                                                              // 51
	"ammo", "upgrade_item"                                                                   // 54
};

// Long weapon names
stock const char LongWeaponNames[WEPID_SIZE][] = 
{
	"None", "Pistol", "Uzi", // 0
	"Pump Shotgun", "Auto Shotgun", "M-16 Rifle", // 3
	"Hunting Rifle", "MAC-10", "Chrome Shotgun", // 6
	"Desert Rifle", "Military Sniper", "SPAS Shotgun", // 9
	"First Aid Kit", "Molotov", "Pipe Bomb", // 12
	"Pills", "Gascan", "Propane Tank", // 15
	"Oxygen Tank", "Melee", "Chainsaw", // 18
	"Grenade Launcher", "Ammo Pack", "Adrenaline", // 21
	"Defibrillator", "Bile Bomb", "AK-47", // 24
	"Gnome", "Cola Bottles", "Fireworks", // 27
	"Incendiary Ammo Pack", "Explosive Ammo Pack", "Magnum", // 30
	"MP5", "SG552", "AWP", // 33
	"Scout", "M60", "Tank Claw", // 36
	"Hunter Claw", "Charger Claw", "Boomer Claw", // 39
	"Smoker Claw", "Spitter Claw", "Jockey Claw", // 42
	"Turret", "vomit", "splat", // 45
	"pounce", "lounge", "pull", // 48
	"choke", "rock", "physics", // 51
	"ammo", "upgrade_item" // 54
};

// Internal names for melee weapons
stock const char MeleeWeaponNames[WEPID_MELEES_SIZE][] =
{
	"",
	"knife",
	"baseball_bat",
	"cricket_bat",
	"crowbar",
	"electric_guitar",
	"fireaxe",
	"frying_pan",
	"golfclub",
	"katana",
	"machete",
	"tonfa",
	"shovel",
	"pitchfork"
};

stock const char LongMeleeWeaponNames[WEPID_MELEES_SIZE][] =
{
	"None",
	"Knife",
	"Baseball Bat",
	"Cricket Bat",
	"Crowbar",
	"Guitar",
	"Axe",
	"Frying Pan",
	"Golf Club",
	"Katana",
	"Machete",
	"Tonfa",
	"Shovel",
	"Pitchfork"
};

// World weapon models for each of the weapons. Useful for making new weapon spawns.
// Some models are left blank because no single model can be given, the model is known or none exist.
stock const char WeaponModels[WEPID_SIZE][] =
{
	"",
	"/w_models/weapons/w_pistol_B.mdl",
	"/w_models/weapons/w_smg_uzi.mdl",
	"/w_models/weapons/w_shotgun.mdl",
	"/w_models/weapons/w_autoshot_m4super.mdl",
	"/w_models/weapons/w_rifle_m16a2.mdl",
	"/w_models/weapons/w_sniper_mini14.mdl",
	"/w_models/weapons/w_smg_a.mdl",
	"/w_models/weapons/w_pumpshotgun_a.mdl",
	"/w_models/weapons/w_desert_rifle.mdl",           // "/w_models/weapons/w_rifle_b.mdl"
	"/w_models/weapons/w_sniper_military.mdl",
	"/w_models/weapons/w_shotgun_spas.mdl",
	"/w_models/weapons/w_eq_medkit.mdl",
	"/w_models/weapons/w_eq_molotov.mdl",
	"/w_models/weapons/w_eq_pipebomb.mdl",
	"/w_models/weapons/w_eq_painpills.mdl",
	"/props_junk/gascan001a.mdl",
	"/props_junk/propanecanister001.mdl",
	"/props_equipment/oxygentank01.mdl",
	"",                                               // "/w_models/weapons/w_knife_t.mdl",
	                                                  // "/weapons/melee/w_bat.mdl",
	                                                  // "/weapons/melee/w_cricket_bat.mdl",
	                                                  // "/weapons/melee/w_crowbar.mdl",
	                                                  // "/weapons/melee/w_electric_guitar.mdl",
	                                                  // "/weapons/melee/w_fireaxe.mdl",
	                                                  // "/weapons/melee/w_frying_pan.mdl",
	                                                  // "/weapons/melee/w_golfclub.mdl",
	                                                  // "/weapons/melee/w_katana.mdl",
	                                                  // "/weapons/melee/w_machete.mdl",
	                                                  // "/weapons/melee/w_tonfa.mdl",
	                                                  // "/weapons/melee/w_shovel.mdl",
	                                                  // "/weapons/melee/w_pitchfork.mdl",
	"/weapons/melee/w_chainsaw.mdl",
	"/w_models/weapons/w_grenade_launcher.mdl",
	"",
	"/w_models/weapons/w_eq_adrenaline.mdl",
	"/w_models/weapons/w_eq_defibrillator.mdl",
	"/w_models/weapons/w_eq_bile_flask.mdl",
	"/w_models/weapons/w_rifle_ak47.mdl",
	"/props_junk/gnome.mdl",
	"/w_models/weapons/w_cola.mdl",
	"/props_junk/explosive_box001.mdl",
	"/w_models/weapons/w_eq_incendiary_ammopack.mdl",
	"/w_models/weapons/w_eq_explosive_ammopack.mdl",
	"/w_models/weapons/w_desert_eagle.mdl",
	"/w_models/weapons/w_smg_mp5.mdl",
	"/w_models/weapons/w_rifle_sg552.mdl",
	"/w_models/weapons/w_sniper_awp.mdl",
	"/w_models/weapons/w_sniper_scout.mdl",
	"/w_models/weapons/w_m60.mdl",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	""
};

stock const char MeleeWeaponModels[WEPID_MELEES_SIZE][] =
{
	"",
	"/w_models/weapons/w_knife_t.mdl",
	"/weapons/melee/w_bat.mdl",
	"/weapons/melee/w_cricket_bat.mdl",
	"/weapons/melee/w_crowbar.mdl",
	"/weapons/melee/w_electric_guitar.mdl",
	"/weapons/melee/w_fireaxe.mdl",
	"/weapons/melee/w_frying_pan.mdl",
	"/weapons/melee/w_golfclub.mdl",
	"/weapons/melee/w_katana.mdl",
	"/weapons/melee/w_machete.mdl",
	"/weapons/melee/w_tonfa.mdl",
	"/weapons/melee/w_shovel.mdl",
	"/weapons/melee/w_pitchfork.mdl"
};

stock const char MeleeWeaponModels_Hand[WEPID_MELEES_SIZE][] =
{
	"",
	"/w_models/weapons/v_knife_t.mdl",
	"/weapons/melee/v_bat.mdl",
	"/weapons/melee/v_cricket_bat.mdl",
	"/weapons/melee/v_crowbar.mdl",
	"/weapons/melee/v_electric_guitar.mdl",
	"/weapons/melee/v_fireaxe.mdl",
	"/weapons/melee/v_frying_pan.mdl",
	"/weapons/melee/v_golfclub.mdl",
	"/weapons/melee/v_katana.mdl",
	"/weapons/melee/v_machete.mdl",
	"/weapons/melee/v_tonfa.mdl",
	"/weapons/melee/v_shovel.mdl",
	"/weapons/melee/v_pitchfork.mdl"
};

stock const int WeaponSlots[WEPID_SIZE] =
{
	L4D2WeaponSlot_None, // WEPID_NONE
	L4D2WeaponSlot_Secondary,  // WEPID_PISTOL
	L4D2WeaponSlot_Primary,  // WEPID_SMG
	L4D2WeaponSlot_Primary,  // WEPID_PUMPSHOTGUN
	L4D2WeaponSlot_Primary,  // WEPID_AUTOSHOTGUN
	L4D2WeaponSlot_Primary,  // WEPID_RIFLE
	L4D2WeaponSlot_Primary,  // WEPID_HUNTING_RIFLE
	L4D2WeaponSlot_Primary,  // WEPID_SMG_SILENCED
	L4D2WeaponSlot_Primary,  // WEPID_SHOTGUN_CHROME
	L4D2WeaponSlot_Primary,  // WEPID_RIFLE_DESERT
	L4D2WeaponSlot_Primary,  // WEPID_SNIPER_MILITARY
	L4D2WeaponSlot_Primary,  // WEPID_SHOTGUN_SPAS
	L4D2WeaponSlot_HeavyHealthItem,  // WEPID_FIRST_AID_KIT
	L4D2WeaponSlot_Throwable,  // WEPID_MOLOTOV
	L4D2WeaponSlot_Throwable,  // WEPID_PIPE_BOMB
	L4D2WeaponSlot_LightHealthItem,  // WEPID_PAIN_PILLS
	L4D2WeaponSlot_None, // WEPID_GASCAN
	L4D2WeaponSlot_None, // WEPID_PROPANE_TANK
	L4D2WeaponSlot_None, // WEPID_OXYGEN_TANK
	L4D2WeaponSlot_Secondary,  // WEPID_MELEE
	L4D2WeaponSlot_Secondary,  // WEPID_CHAINSAW
	L4D2WeaponSlot_Primary,  // WEPID_GRENADE_LAUNCHER
	L4D2WeaponSlot_HeavyHealthItem,  // WEPID_AMMO_PACK
	L4D2WeaponSlot_LightHealthItem,  // WEPID_ADRENALINE
	L4D2WeaponSlot_HeavyHealthItem,  // WEPID_DEFIBRILLATOR
	L4D2WeaponSlot_Throwable,  // WEPID_VOMITJAR
	L4D2WeaponSlot_Primary,  // WEPID_RIFLE_AK47
	L4D2WeaponSlot_None, // WEPID_GNOME_CHOMPSKI
	L4D2WeaponSlot_None, // WEPID_COLA_BOTTLES
	L4D2WeaponSlot_None, // WEPID_FIREWORKS_BOX
	L4D2WeaponSlot_HeavyHealthItem,  // WEPID_INCENDIARY_AMMO
	L4D2WeaponSlot_HeavyHealthItem,  // WEPID_FRAG_AMMO
	L4D2WeaponSlot_Secondary,  // WEPID_PISTOL_MAGNUM
	L4D2WeaponSlot_Primary,  // WEPID_SMG_MP5
	L4D2WeaponSlot_Primary,  // WEPID_RIFLE_SG552
	L4D2WeaponSlot_Primary,  // WEPID_SNIPER_AWP
	L4D2WeaponSlot_Primary,  // WEPID_SNIPER_SCOUT
	L4D2WeaponSlot_Primary,  // WEPID_RIFLE_M60
	L4D2WeaponSlot_None, // WEPID_TANK_CLAW
	L4D2WeaponSlot_None, // WEPID_HUNTER_CLAW
	L4D2WeaponSlot_None, // WEPID_CHARGER_CLAW
	L4D2WeaponSlot_None, // WEPID_BOOMER_CLAW
	L4D2WeaponSlot_None, // WEPID_SMOKER_CLAW
	L4D2WeaponSlot_None, // WEPID_SPITTER_CLAW
	L4D2WeaponSlot_None, // WEPID_JOCKEY_CLAW
	L4D2WeaponSlot_None, // WEPID_MACHINEGUN
	L4D2WeaponSlot_None, // WEPID_FATAL_VOMIT
	L4D2WeaponSlot_None, // WEPID_EXPLODING_SPLAT
	L4D2WeaponSlot_None, // WEPID_LUNGE_POUNCE
	L4D2WeaponSlot_None, // WEPID_LOUNGE
	L4D2WeaponSlot_None, // WEPID_FULLPULL
	L4D2WeaponSlot_None, // WEPID_CHOKE
	L4D2WeaponSlot_None, // WEPID_THROWING_ROCK
	L4D2WeaponSlot_None, // WEPID_TURBO_PHYSICS
	L4D2WeaponSlot_None, // WEPID_AMMO
	L4D2WeaponSlot_None  // WEPID_UPGRADE_ITEM
};

#define GETWEAPONNAME(%0) (IsValidWeaponId(%0) ? (WeaponNames[%0]) : "")
#define GETLONGWEAPONNAME(%0) (IsValidWeaponId(%0) ? (LongWeaponNames[%0]) : "")
#define GETMELEEWEAPONNAME(%0) (IsValidMeleeWeaponId(%0) ? (MeleeWeaponNames[%0]) : "")
#define GETLONGMELEEWEAPONNAME(%0) (IsValidMeleeWeaponId(%0) ? (LongMeleeWeaponNames[%0]) : "")
#define GETWEAPONMODEL(%0) (HasValidWeaponModel(%0) ? (WeaponModels[%0]) : "")
#define GETMELEEWEAPONMODEL(%0) (HasValidMeleeWeaponModel(%0) ? (MeleeWeaponModels[%0]) : "")
#define GETMELEEWEAPONMODEL_HAND(%0) (HasValidMeleeWeaponModel_HAND(%0) ? (MeleeWeaponModels_Hand[%0]) : "")

stock static StringMap hWeaponNamesTrie = null;
stock static StringMap hMeleeWeaponNamesTrie = null;
stock static StringMap hMeleeWeaponModelsTrie = null;
stock static StringMap hMeleeWeaponModelsHandTrie = null;
stock static StringMap hPropPhysicModelsTrie = null;
//stock static StringMap hPropPhysicModelsHandTrie = null;

stock void InitWeaponNamesTrie()
{
	delete hWeaponNamesTrie;
	hWeaponNamesTrie = new StringMap();

	for (int i = 0; i < WEPID_SIZE; i++) {
		hWeaponNamesTrie.SetValue(WeaponNames[i], i);
	}

	delete hMeleeWeaponNamesTrie;
	hMeleeWeaponNamesTrie = new StringMap();
	delete hMeleeWeaponModelsTrie;
	hMeleeWeaponModelsTrie = new StringMap();
	delete hMeleeWeaponModelsHandTrie;
	hMeleeWeaponModelsHandTrie = new StringMap();

	for (int i = 0; i < WEPID_MELEES_SIZE; i++) {
		hMeleeWeaponNamesTrie.SetValue(MeleeWeaponNames[i], i);
		hMeleeWeaponModelsTrie.SetString(MeleeWeaponModels[i], MeleeWeaponNames[i]);
		hMeleeWeaponModelsHandTrie.SetString(MeleeWeaponModels_Hand[i], MeleeWeaponNames[i]);
	}

	delete hPropPhysicModelsTrie;
	hPropPhysicModelsTrie = new StringMap();
	//delete hPropPhysicModelsHandTrie;
	//hPropPhysicModelsHandTrie = new StringMap();
	for (int i = 0; i < WEPID_SIZE; i++) {
		hPropPhysicModelsTrie.SetString(WeaponModels[i], WeaponNames[i]);
		//hPropPhysicModelsHandTrie.SetString(WeaponModels_Hand[i], WeaponNames[i]);
	}
}

/**
 * Initializes internal structure necessary for weapons.inc functions
 * @remark It is recommended that you run this function on plugin start, but not necessary
 *
 * @noreturn
 */
stock void L4D2Weapons_Init()
{
	if (hWeaponNamesTrie == null) {
		InitWeaponNamesTrie();
	}
}

/**
 * Performs bounds checking to determine if a WeaponId is valid
 * @remark Simple check to see if wepid has a garbage value
 *
 * @param wepid        WeaponId to check for validity
 * @return True if wepid is valid, false otherwise.
 */
stock bool IsValidWeaponId(int wepid)
{
	return (wepid >= WEPID_NONE && wepid < WEPID_SIZE);
}

/**
 * Performs bounds checking to determine if a MeleeWeaponId is valid
 * @remark Simple check to see if wepid has a garbage value
 *
 * @param wepid        MeleeWeaponId to check for validity
 * @return True if wepid is valid, false otherwise.
 */
stock bool IsValidMeleeWeaponId(int wepid)
{
	return (wepid >= WEPID_MELEE_NONE && wepid < WEPID_MELEES_SIZE);
}

/**
 * Checks to see if a given meleeweaponid has a known WeaponModel in this file's model array
 *
 * @param wepid        MeleeWeaponId to check for a known weapon model for.
 * @return True if a valid weapon model exists for wepid, false otherwise.
 */
stock bool HasValidMeleeWeaponModel(int wepid)
{
	return (IsValidMeleeWeaponId(wepid) && MeleeWeaponModels[wepid][0] != '\0');
}

/**
 * Checks to see if a given meleeweaponid has a known WeaponModel (first person hand) in this file's model array
 *
 * @param wepid        MeleeWeaponId to check for a known weapon model for.
 * @return True if a valid weapon model exists for wepid, false otherwise.
 */
stock bool HasValidMeleeWeaponModel_HAND(int wepid)
{
	return (IsValidMeleeWeaponId(wepid) && MeleeWeaponModels_Hand[wepid][0] != '\0');
}

/**
 * Get the player weapon slot used by the given WeaponId.
 * 
 * @param wepid     WeaponId to get the slot for.
 * @return Slot number (0-4) or -1 for invalid WeaponId or no slot
 */
stock int GetSlotFromWeaponId(int wepid)
{
	return (IsValidWeaponId(wepid)) ? WeaponSlots[wepid] : -1;
}

/**
 * Checks to see if a given weaponid has a known WeaponModel in this file's model array
 * @remark Some weapons (like weapon_melee) have multiple valid models, and this will report false for them.
 *
 * @param wepid        WeaponId to check for a known weapon model for.
 * @return True if a valid weapon model exists for wepid, false otherwise.
 */
stock bool HasValidWeaponModel(int wepid)
{
	return (IsValidWeaponId(wepid) && WeaponModels[wepid][0] != '\0');
}

/**
 * Tries to look up a WeaponId for a given Weapon Name.
 *
 * @param weaponName    Weapon name string to look up Id from
 * @return int          The corresponding WeaponId if found, else WEPID_NONE
 */
stock int WeaponNameToId(const char[] weaponName)
{
	if (hWeaponNamesTrie == null) {
		InitWeaponNamesTrie();
	}
	
	int id;
	if (hWeaponNamesTrie.GetValue(weaponName, id)) {
		return id;
	}
	
	return WEPID_NONE;
}

/**
 * Tries to look up L4D2's internal weapon name for a given WeaponId.
 *
 * @param wepid            WeaponId To get name of.
 * @param nameBuffer    String buffer to write the weapon name to.
 * @param length        Max length which can be written to the buffer.
 * @return                Number of bytes written to buffer, or 0 for invalid weaponId.
 */
stock void GetWeaponName(int wepid, char[] nameBuffer, const int length)
{
	strcopy(nameBuffer, length, GETWEAPONNAME(wepid));
}

/**
 * Tries to look up L4D2's internal weapon name for a given MeleeWeaponId.
 *
 * @param wepid            MeleeWeaponId To get name of.
 * @param nameBuffer    String buffer to write the weapon name to.
 * @param length        Max length which can be written to the buffer.
 * @return                Number of bytes written to buffer, or 0 for invalid weaponId.
 */
stock void GetMeleeWeaponName(int wepid, char[] nameBuffer, const int length)
{
	strcopy(nameBuffer, length, GETMELEEWEAPONNAME(wepid));
}

/**
 * Tries to look up L4D2's internal weapon name for a given WeaponId.
 *
 * @param wepid            WeaponId To get name of.
 * @param nameBuffer    String buffer to write the weapon name to.
 * @param length        Max length which can be written to the buffer.
 * @return                Number of bytes written to buffer, or 0 for invalid weaponId.
 */
stock void GetLongWeaponName(int wepid, char[] nameBuffer, const int length)
{
	strcopy(nameBuffer, length, GETLONGWEAPONNAME(wepid));
}

/**
 * Tries to look up L4D2's internal weapon name for a given MeleeWeaponId.
 *
 * @param wepid            MeleeWeaponId To get name of.
 * @param nameBuffer    String buffer to write the weapon name to.
 * @param length        Max length which can be written to the buffer.
 * @return                Number of bytes written to buffer, or 0 for invalid weaponId.
 */
stock void GetLongMeleeWeaponName(int wepid, char[] nameBuffer, const int length)
{
	strcopy(nameBuffer, length, GETLONGMELEEWEAPONNAME(wepid));
}

/**
 * Tries to look up the weapon model for a given MeleeWeaponId.
 * @remarks You should use HasValidWeaponModel to make sure the MeleeWeaponId you're looking up has a valid model associated with it.
 *
 * @param wepid            MeleeWeaponId To get name of.
 * @param nameBuffer    String buffer to write the weapon name to.
 * @param length        Max length which can be written to the buffer.
 * @return                Number of bytes written to buffer, or 0 for invalid weaponid or no weapon model available.
 */
stock void GetMeleeWeaponModel(int wepid, char[] modelBuffer, const int length)
{
	strcopy(modelBuffer, length, GETMELEEWEAPONMODEL(wepid));
}

// Helper function used for getting an entity's internal melee name
stock bool GetMeleeWeaponNameFromEntity(int entity, char[] buffer, const int length)
{
	if (entity <= MaxClients|| !IsValidEntity(entity)) {
		return false;
	}

	char classname[64], sModelName[PLATFORM_MAX_PATH];
	if (!GetEntityClassname(entity, classname, sizeof(classname))) {
		return false;
	}

	if (hMeleeWeaponModelsTrie == null || hMeleeWeaponModelsHandTrie == null) {
		InitWeaponNamesTrie();
	}

	if (StrEqual(classname, "weapon_melee_spawn")) {

		GetEntPropString(entity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));

		// Strip models directory
		if (strncmp(sModelName, "models/", 7, false) == 0) {
			strcopy(sModelName, sizeof(sModelName), sModelName[6]);
		}

		if (hMeleeWeaponModelsTrie.GetString(sModelName, buffer, length)) {
			return true;
		}
		
		return false;
	} else if (StrEqual(classname, "weapon_melee")) {
		GetEntPropString(entity, Prop_Data, "m_strMapSetScriptName", buffer, length);

		if(strlen(buffer) == 0) // the tonfa from cop is empty
		{
			GetEntPropString(entity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
			// Strip models directory
			if (strncmp(sModelName, "models/", 7, false) == 0) {
				strcopy(sModelName, sizeof(sModelName), sModelName[6]);
			}

			if (hMeleeWeaponModelsTrie.GetString(sModelName, buffer, length)) {
				return true;
			}

			if (hMeleeWeaponModelsHandTrie.GetString(sModelName, buffer, length)) {
				return true;
			}

			return false;
		}
		else
		{
			return true;
		}
	}

	return false;
}
/**
 * Tries to get weapon name from prop_physics or physics_prop
 */
stock bool GetWeaponNameFromProp(int entity, char[] buffer, const int length)
{
	if (entity <= MaxClients|| !IsValidEntity(entity)) {
		return false;
	}

	char classname[64], sModelName[PLATFORM_MAX_PATH];
	if (!GetEntityClassname(entity, classname, sizeof(classname))) {
		return false;
	}

	if (hPropPhysicModelsTrie == null) {
		InitWeaponNamesTrie();
	}

	if (strncmp(classname, "physics_prop", 12, false) == 0)
	{
		// nothing
	} 
	else if (strncmp(classname, "prop_physics", 12, false) == 0) 
	{
		if (!HasEntProp(entity, Prop_Send, "m_isCarryable")) 
			return false;
	}
	else
	{
		return false;
	}

	GetEntPropString(entity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	// Strip models directory
	if (strncmp(sModelName, "models/", 7, false) == 0) {
		strcopy(sModelName, sizeof(sModelName), sModelName[6]);
	}

	if (hPropPhysicModelsTrie.GetString(sModelName, buffer, length)) {
		return true;
	}

	return false;
}

/**
 * Tries to look up the weapon model for a given WeaponId.
 * @remarks You should use HasValidWeaponModel to make sure the WeaponId you're looking up has a valid model associated with it.
 *
 * @param wepid            WeaponId To get name of.
 * @param nameBuffer    String buffer to write the weapon name to.
 * @param length        Max length which can be written to the buffer.
 * @return                Number of bytes written to buffer, or 0 for invalid weaponid or no weapon model available.
 */
stock void GetWeaponModel(int wepid, char[] modelBuffer, const int length)
{
	strcopy(modelBuffer, length, GETWEAPONMODEL(wepid));
}

/**
 * Identifies a weapon spawn or weapon entity as a WeaponID
 * @remark Should work on most weapon ents--even spawns, singles, held, etc.
 *
 * @param entity        Index of entity to identify
 * @return int for the entity if it is a weapon, WEPID_NONE otherwise
 */
stock int IdentifyWeapon(int entity)
{
	if (entity <= MaxClients|| !IsValidEntity(entity)) {
		return WEPID_NONE;
	}

	char class[64];
	if (!GetEntityClassname(entity, class, sizeof(class))) {
		return WEPID_NONE;
	}

	if (strcmp(class, "weapon_spawn") == 0) {
		return GetEntProp(entity, Prop_Send, "m_weaponID");
	}
	else if (strncmp(class, "physics_prop", 12, false) == 0)
	{
		if(!GetWeaponNameFromProp(entity, class, sizeof(class)))
		{
			return WEPID_NONE;
		}
	}
	else if (strncmp(class, "prop_physics", 12, false) == 0)
	{
		if(!GetWeaponNameFromProp(entity, class, sizeof(class)))
		{
			return WEPID_NONE;
		}
	}

	int len = strlen(class);
	int len2 = len - 6;
	if (len2 > 0 && strcmp(class[len2], "_spawn") == 0) {
		class[len2] = '\0';
		return WeaponNameToId(class);
	}

	return WeaponNameToId(class);
}

/**
 * Identifies a weapon spawn or weapon entity as a WeaponID and get full classname
 * @remark Should work on most weapon ents--even spawns, singles, held, etc.
 *
 * @param 	entity      Index of entity to identify
 * @param	buffer		Buffer to copy classname
 * @param	maxlength	Maximum size of the buffer
 * @return int for the entity if it is a weapon, WEPID_NONE otherwise
 */
stock int IdentifyWeaponAndFullClassName(int entity, char[] buffer, int maxlength)
{
	if (entity <= MaxClients|| !IsValidEntity(entity)) {
		return WEPID_NONE;
	}

	if (!GetEntityClassname(entity, buffer, maxlength)) {
		return WEPID_NONE;
	}

	char class[64];
	FormatEx(class, sizeof(class), "%s", buffer);

	if (strcmp(class, "weapon_spawn") == 0) {
		return GetEntProp(entity, Prop_Send, "m_weaponID");
	}
	else if (strncmp(class, "physics_prop", 12, false) == 0)
	{
		if(!GetWeaponNameFromProp(entity, class, sizeof(class)))
		{
			return WEPID_NONE;
		}
	}
	else if (strncmp(class, "prop_physics", 12, false) == 0)
	{
		if(!GetWeaponNameFromProp(entity, class, sizeof(class)))
		{
			return WEPID_NONE;
		}
	}

	int len = strlen(class);
	int len2 = len - 6;
	if (len2 > 0 && strcmp(class[len2], "_spawn") == 0) {
		class[len2] = '\0';
		return WeaponNameToId(class);
	}

	return WeaponNameToId(class);
}

/**
 * Identifies a melee weapon spawn or weapon entity as a MeleeWeaponId
 * @remark Should work on most weapon ents--even spawns, singles, held, etc.
 *
 * @param entity		Index of entity to identify
 * @return int			for the entity if it is a melee weapon, WEPID_MELEE_NONE otherwise
 */
stock int IdentifyMeleeWeapon(int entity)
{
	if (IdentifyWeapon(entity) != WEPID_MELEE) {
		return WEPID_MELEE_NONE;
	}

	char sName[64];
	if (!GetMeleeWeaponNameFromEntity(entity, sName, sizeof(sName))) {
		return WEPID_MELEE_NONE;
	}

	if (hMeleeWeaponNamesTrie == null) {
		InitWeaponNamesTrie();
	}

	int id;
	if (hMeleeWeaponNamesTrie.GetValue(sName, id)) {
		return id;
	}

	return WEPID_MELEE_NONE;
}

/**
 * Tries to look up a WeaponId for a given Melee Weapon Name. (short names)
 *
 * @param weaponName    Weapon name string to look up Id from
 * @return int			The corresponding Melee WeaponId if found, else WEPID_MELEE_NONE
 */
stock int MeleeNameToMeleeId(const char[] meleeName)
{
	if (hMeleeWeaponNamesTrie == null) {
		InitWeaponNamesTrie();
	}
	
	int id;
	if (hMeleeWeaponNamesTrie.GetValue(meleeName, id)) {
		return id;
	}
	
	return WEPID_MELEE_NONE;
}

/**
 * Attempts to convert a weapon spawn entity to a given weapon spawn
 * @remark Truthfully, this will work on any entity with origin/rotation.
 *        Also, requires the weapon to either have a Valid weapon model or have one provided
 *
 * @param entity        Index of entity to convert to weapon spawn
 * @param wepid            WeaponId of the weapon to have the spawner hold
 * @param count            Weapon count for the spawner (default 5)
 * @param model            World model to use for the weapon spawn
 * @return entity of the new weapon spawn, or -1 on errors.
 */
stock int ConvertWeaponSpawn(int entity, int wepid, int count = 5, const char[] model = "")
{
	if (entity <= MaxClients|| !IsValidEntity(entity)) {
		return -1;
	}
	
	if (!IsValidWeaponId(wepid)) {
		return -1;
	}
	
	if (model[0] == '\0' && !HasValidWeaponModel(wepid)) {
		return -1;
	}

	float origins[3], angles[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origins);
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);

	AcceptEntityInput(entity, "kill");

	entity = CreateEntityByName("weapon_spawn");
	if (entity <= MaxClients || !IsValidEntity(entity)) {
		return -1;
	}
	
	SetEntProp(entity, Prop_Send, "m_weaponID", wepid);

	char buf[PLATFORM_MAX_PATH - 16], modelName[PLATFORM_MAX_PATH];
	if (model[0] != '\0') {
		SetEntityModel(entity, model);
	} else {
		GetWeaponModel(wepid, buf, sizeof(buf));
		Format(modelName, sizeof(modelName), "models%s", buf);
		SetEntityModel(entity, modelName);
	}
	
	IntToString(count, buf, sizeof(buf));
	DispatchKeyValue(entity, "count", buf);

	TeleportEntity(entity, origins, angles, NULL_VECTOR);
	DispatchSpawn(entity);
	SetEntityMoveType(entity, MOVETYPE_NONE);

	return entity;
}