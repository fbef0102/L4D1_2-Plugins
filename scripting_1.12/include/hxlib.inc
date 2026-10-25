#if defined _hxlib_included_
	#endinput
#endif
#define _hxlib_included_

#pragma newdecls required
#pragma semicolon 1

#define HXLIB_LIBRARY	"hxlib"

#include <hxstocks>
#include <sourcescramble>

/** if something clips into the ground, try again this much higher. 18.0 is what the game itself often likes to use */
#define GROUND_CLIP_UPLIFT	18.0

#define NULL_FLOW			-9999.0

/*****************
 * enums/structs
 *****************/

/** CIntensity::Increase param. scale of 1 through 5 of how big the increase should be */
enum IntensityType
{
	IntensityType_1 = 1,
	IntensityType_2,
	IntensityType_3,
	IntensityType_4,
	IntensityType_5
};

/** panic_event_reason_t enum */
enum PanicEventReason
{
	PanicEventReason_Generic,	// PanicEvent info_director input, director_force_panic_event command
	PanicEventReason_CarAlarm,	// car alarm triggered horde
	PanicEventReason_Force,		// ForcePanicEvent info_director input, bride witch triggered horde
	PanicEventReason_Scripted,	// ScriptedPanicEvent info_director input, director_force_scripted_panic_event command

	PanicEventReason_MAX
}

/** type of event/finale managed by the scripted event manager */
enum FinaleType
{
	FinaleType_Standard,
	FinaleType_Gauntlet,
	FinaleType_Holdout,
	FinaleType_ScriptedPanicEvent,
	FinaleType_Scavenge,

	FinaleType_None
};

enum FinaleStage
{
	FinaleStage_Gauntlet1,
	FinaleStage_HordeAttack1,
	FinaleStage_HalftimeBoss,
	FinaleStage_Gauntlet2,
	FinaleStage_HordeAttack2,
	FinaleStage_FinalBoss,
	FinaleStage_HordeEscape,
	FinaleStage_CustomPanic,
	FinaleStage_CustomTank,
	FinaleStage_CustomScripted,
	FinaleStage_CustomDelay,
	FinaleStage_CustomClearout,
	FinaleStage_GauntletStart,
	FinaleStage_GauntletHorde,
	FinaleStage_GauntletHordeBonustime,
	FinaleStage_GauntletBossIncoming,
	FinaleStage_Boss,
	FinaleStage_Escape,

	FinaleStage_None
};

enum PanicStage
{
	PanicStage_InitialDelay,
	PanicStage_MegaMob,
	PanicStage_WaitForCombatToEnd,
	PanicStage_Pause,

	PanicStage_Done		// no ongoing panic event
};

enum DirectorTempo
{
	Tempo_BuildUp,
	Tempo_SustainPeak,
	Tempo_PeakFade,
	Tempo_Relax
};

/** data type for a variant_t buffer */
enum FieldType
{
	FieldType_Void,

	FieldType_Float,
	FieldType_String,
	FieldType_Vector,
	FieldType_Quaternion,
	FieldType_Int,
	FieldType_Bool,
	FieldType_Short,
	FieldType_Char,
	FieldType_Color32,
	FieldType_Embedded,
	FieldType_Custom,
	FieldType_ClassPtr,
	FieldType_EHandle,
	FieldType_Edict,
	FieldType_PosVector,
	FieldType_Time,
	FieldType_Tick,
	FieldType_ModelName,
	FieldType_SoundName,
	FieldType_Input,
	FieldType_Function,
	FieldType_VMatrix,
	FieldType_VMatrixWorldspace,
	FieldType_Matrix3X4Worldspace,
	FieldType_Interval,
	FieldType_ModelIndex,
	FieldType_MaterialIndex,
	FieldType_Vector2D,
	FieldType_Int64,
	FieldType_Vector4D,

	FieldType_MAX
};

/** for flags param in GetNearestNavArea* and GetNavArea* natives */
enum
{
	GetNavFlag_CheckLOS 		= 1 << 0,	// check line of sight, filter out areas with obstructions between reference point and area
	GetNavFlag_IgnoreBlockers	= 1 << 1,	// prevent areas marked as nav blockers from being filtered out
	GetNavFlag_RequireGround	= 1 << 2	// filter out areas that aren't on ground below the reference point
};

/** flags param for IsVisibleToPlayer */
enum
{
	Visibility_AnyFOV			= 1 << 0,	// if set, then check visibility even if the position is outside this client's field of view
	Visibility_IgnoreObscured	= 1 << 2	// if set, the nav area having an OBSCURED spawn attribute isn't considered
}

/** for NavArea.spawnAttributes */
enum
{
	NavSpawn_Empty				= (1 << 1),
	NavSpawn_StopScan			= (1 << 2),
	NavSpawn_Battlestation		= (1 << 5),
	NavSpawn_Finale				= (1 << 6),
	NavSpawn_PlayerStart		= (1 << 7),
	NavSpawn_Battlefield		= (1 << 8),
	NavSpawn_IgnoreVisibility	= (1 << 9),
	NavSpawn_NotClearable		= (1 << 10),
	NavSpawn_Checkpoint			= (1 << 11),
	NavSpawn_Obscured			= (1 << 12),
	NavSpawn_NoMobs				= (1 << 13),
	NavSpawn_Threat				= (1 << 14),
	NavSpawn_RescueVehicle		= (1 << 15),
	NavSpawn_RescueCloset		= (1 << 16),
	NavSpawn_EscapeRoute		= (1 << 17),
	NavSpawn_Door				= (1 << 18),
	NavSpawn_NoThreat			= (1 << 19),
	NavSpawn_LyingDown			= (1 << 20),
	NavSpawn_CompassNorth		= (1 << 24),
	NavSpawn_CompassNortheast	= (1 << 25),
	NavSpawn_CompassEast		= (1 << 26),
	NavSpawn_CompassEastSouth	= (1 << 27),
	NavSpawn_CompassSouth		= (1 << 28),
	NavSpawn_CompassSouthwest	= (1 << 29),
	NavSpawn_CompassWest		= (1 << 30),
	NavSpawn_CompassWestnorth	= (1 << 31)
};

/** for NavArea.baseAttributes */
enum
{
	NavBase_Crouch				= (1 << 0),
	NavBase_Jump				= (1 << 1),
	NavBase_Precise				= (1 << 2),
	NavBase_NoJump				= (1 << 3),
	NavBase_Stop				= (1 << 4),
	NavBase_Run					= (1 << 5),
	NavBase_Walk				= (1 << 6),
	NavBase_Avoid				= (1 << 7),
	NavBase_Transient			= (1 << 8),
	NavBase_DontHide			= (1 << 9),
	NavBase_Stand				= (1 << 10),
	NavBase_NoHostages			= (1 << 11),
	NavBase_Stairs				= (1 << 12),
	NavBase_NoMerge				= (1 << 13),
	NavBase_ObstacleTop			= (1 << 14),
	NavBase_Cliff				= (1 << 15),
	NavBase_TankOnly			= (1 << 16),
	NavBase_MobOnly				= (1 << 17),
	NavBase_Playerclip			= (1 << 18),
	NavBase_Breakablewall		= (1 << 19),
	NavBase_NavMeshFlowBlocked	= (1 << 27),
	NavBase_NavMeshOutsideWorld	= (1 << 28),
	NavBase_NavMeshMostlyFlat	= (1 << 29),
	NavBase_NavMeshHasElevator	= (1 << 30),
	NavBase_NavMeshNavBlocker	= (1 << 31)
};

enum LocationType
{
	LocationType_Null = -1,	// in vscript, it's known as SPAWN_NO_PREFERENCE

	LocationType_Anywhere,
	LocationType_BehindSurvivors,
	LocationType_NearITVictim,
	LocationType_SpecialsInFrontOfSurvivors,
	LocationType_SpecialsAnywhere,
	LocationType_FarAwayFromSurvivors,
	LocationType_AboveSurvivors,
	LocationType_InFrontOfSurvivors,
	LocationType_VersusFinaleDistance,
	LocationType_LargeVolume,
	LocationType_NearPosition,

	LocationType_MAX
};

enum ServerOS
{
	OS_Invalid,
	OS_Linux,
	OS_Windows
};

enum NavDir
{
	NavDir_North,	// -y [1]
	NavDir_East,	// +x [0]
	NavDir_South,	// +y [1]
	NavDir_West,	// -x [0]

	NavDir_All
};

enum NavCorner
{
	NavCorner_NegativeNegative,	// +x, -y
	NavCorner_PositiveNegative,	// +x, -y
	NavCorner_PositivePositive,	// +x, +y
	NavCorner_NegativePositive	// -x, +y
};

/**
 * NavLadder connections to nav areas. used in AI pathfinding
 *
 * LadderConnection_Top* values all refer to nav areas connected to a ladder's top.
 * LadderConnection_Bottom refers to the nav area connected to a ladder's bottom.
 * top requires at least 1 connected nav area, but more than 1 top connection may
 * be used (although this is rare).
 */
enum LadderConnection
{
	LadderConnection_TopForward,	// upon reaching top, move forwards towards the ladder to reach connected area
	LadderConnection_TopDrop,		// upon reaching top, move forwards and drop down to an area below the ladder top's origin
	LadderConnection_TopSide,		// upon reaching top, step to the side
	LadderConnection_TopBackward,	// upon reaching top, jump back to land on the connected area

	LadderConnection_Bottom			// the area is connected to the ladder's bottom
};

#define LADDER_CONNECTION_TOP_MIN		0
#define LADDER_CONNECTION_TOP_MAX		3

/** used in NavArea.GetNextEscapeStepEx native. */
enum TraverseType
{
	Traverse_None = -1,			// no traversal took place

	Traverse_AdjacentNorth,		// equal to NavDir_North
	Traverse_AdjacentEast,		// equal to NavDir_East
	Traverse_AdjacentSouth,		// equal to NavDir_South
	Traverse_AdjacentWest,		// equal to NavDir_West

	Traverse_LadderUp,			// the step goes from the ladder's bottom connection to one of its top connections
	Traverse_LadderDown,		// the step goes from one of the ladder's top connections to its bottom connection

	Traverse_ElevatorDown,		// step to an elevator connected area that's below the current
	Traverse_ElevatorUp			// step to an elevator connected area that's above the current
};

/** vectors from the DefaultViewVectors global object, used in GetDefaultViewVector native. */
enum DefaultViewVector
{
	ViewVector_StandingEyes,	// view offset
	ViewVector_StandingMin,		// min bounds
	ViewVector_StandingMax,		// max bounds

	ViewVector_CrouchingMin,	// min bounds
	ViewVector_CrouchingMax,	// max bounds
	ViewVector_CrouchingEyes,	// view offset

	ViewVector_ObserverCamMin,	// min bounds
	ViewVector_ObserverCamMax,	// max bounds
	ViewVector_ObserverCamEyes	// view offset
};

enum LadderDir
{
	LadderDir_Up,
	LadderDir_Down
};

/**
 * there is fantastic documentation here: https://developer.valvesoftware.com/wiki/L4D_Level_Design/Nav_Flow.
 * the debug draw from "z_show_flow_distance 1" is described in this wiki page, which displays FlowType_Progress / FlowType_Distance
 */
enum FlowType
{
	FlowType_Progress,	// distance from spawn measured as progress towards the goal area
	FlowType_Distance,	// undirected distance from spawn

	FlowType_MAX
};

enum CollisionGroup
{
	CollisionGroup_None  = 0,
	CollisionGroup_Debris,				// Collides with nothing but world and static stuff
	CollisionGroup_DebrisTrigger,		// Same as debris, but hits triggers
	CollisionGroup_InteractiveDebris,	// Collides with everything except other interactive debris or debris
	CollisionGroup_Interactive,			// Collides with everything except interactive debris or debris
	CollisionGroup_Player,
	CollisionGroup_BreakableGlass,
	CollisionGroup_Vehicle,
	CollisionGroup_PlayerMovement,
	CollisionGroup_NPC,					// Generic NPC group
	CollisionGroup_InVehicle,			// for any entity inside a vehicle
	CollisionGroup_Weapon,				// for any weapons that need collision detection
	CollisionGroup_VehicleClip,			// vehicle clip brush to restrict vehicle movement
	CollisionGroup_Projectile,			// Projectiles!
	CollisionGroup_DoorBlocker,			// Blocks entities not permitted to get near moving doors
	CollisionGroup_PassableDoor,		// Doors that the player shouldn't collide with
	CollisionGroup_Dissolving,			// Things that are dissolving are in this group
	CollisionGroup_Pushaway,			// Nonsolid on client and server, pushaway in player code

	CollisionGroup_NPCActor,			// Used so NPCs in scripts ignore the player.
	CollisionGroup_NPCScripted,			// Used for NPCs in scripts that should not collide with each other

	CollisionGroup_LastShared
};

enum InfernoType
{
	Inferno_Fire,
	Inferno_Spit,
	Inferno_Firework
};

/** used in OnConnectionlessPacket* forwards. */
enum NetAdrType
{
	NetAdr_Null,
	NetAdr_Loopback,
	NetAdr_Broadcast,
	NetAdr_IP
};

/** packetType param from OnConnectionlessPacket. only a few are labeled here */
enum
{
	Packet_QueryGameInfo = 0x54,		// query the server in the steam server browser
	Packet_QueryPlayerInfo = 0x55,		// query player list in game info window
	Packet_ConnectionRequest = 0x6b,	// client trying to connect in game
	Packet_ReservationRequest = 0x6e,	// client trying to reserve a lobby
	Packet_Challenge = 0x71				// client requests token needed for other packets (like ConnectionRequest)
};

enum SurvivorCharacter
{
	Survivor_NickBill,
	Survivor_RochelleZoey,
	Survivor_CoachLouis,
	Survivor_EllisFrancis,

	Survivor_Random = 8
};

enum
{
	SurvivorSet_L4D1 = 1,
	SurvivorSet_L4D2 = 2
};

enum HitGroup
{
	HitGroup_Head = 1,
	HitGroup_Chest = 2,
	HitGroup_Stomach = 3,

	HitGroup_LArm = 4,
	HitGroup_RArm = 5,

	HitGroup_LLeg = 6,
	HitGroup_RLeg = 7
};

enum CommonSpawnType
{
	CommonSpawn_Wanderer,
	CommonSpawn_MobRush,

	/** unused. included for the sake of being complete.
	 * see this article on ambient mob infected: https://developer.valvesoftware.com/wiki/Info_ambient_mob_start */
	CommonSpawn_MobAmbient
};

enum RestoreState
{
	Restore_Transitioning	= 0,
	Restore_Restoring		= 1, // probably
	Restore_Done			= 2
};

enum WeaponID
{
	Weapon_None,
	Weapon_Pistol,
	Weapon_Smg,
	Weapon_Pumpshotgun,
	Weapon_Autoshotgun,
	Weapon_Rifle,
	Weapon_HuntingRifle,
	Weapon_SmgSilenced,
	Weapon_ShotgunChrome,
	Weapon_RifleDesert,
	Weapon_SniperMilitary,
	Weapon_ShotgunSpas,
	Weapon_FirstAidKit,
	Weapon_Molotov,
	Weapon_PipeBomb,
	Weapon_PainPills,
	Weapon_Gascan,
	Weapon_PropaneTank,
	Weapon_OxygenTank,
	Weapon_Melee,
	Weapon_Chainsaw,
	Weapon_GrenadeLauncher,
	Weapon_AmmoPack,
	Weapon_Adrenaline,
	Weapon_Defibrillator,
	Weapon_Vomitjar,
	Weapon_RifleAK47,
	Weapon_GnomeChompski,
	Weapon_ColaBottles,
	Weapon_FireworksBox,
	Weapon_IncendiaryAmmo,
	Weapon_FragAmmo,
	Weapon_PistolMagnum,
	Weapon_SmgMP5,
	Weapon_RifleSG552,
	Weapon_SniperAWP,
	Weapon_SniperScout,
	Weapon_RifleM60,
	Weapon_TankClaw,
	Weapon_HunterClaw,
	Weapon_ChargerClaw,
	Weapon_BoomerClaw,
	Weapon_SmokerClaw,
	Weapon_SpitterClaw,
	Weapon_JockeyClaw,
	Weapon_Machinegun,
	Weapon_FatalVomit,
	Weapon_ExplodingSplat,
	Weapon_LungePounce,
	Weapon_Lounge,
	Weapon_FullPull,
	Weapon_Choke,
	Weapon_ThrowingRock,
	Weapon_TurboPhysics,
	Weapon_Ammo,
	Weapon_UpgradeItem,

	Weapon_MAX
};

stock const char g_sWeapon[WeaponID][] =
{
	"weapon_none",					// 0
	"weapon_pistol",				// 1
	"weapon_smg",					// 2
	"weapon_pumpshotgun",			// 3
	"weapon_autoshotgun",			// 4
	"weapon_rifle",					// 5
	"weapon_hunting_rifle",			// 6
	"weapon_smg_silenced",			// 7
	"weapon_shotgun_chrome",		// 8
	"weapon_rifle_desert",			// 9
	"weapon_sniper_military",		// 10
	"weapon_shotgun_spas",			// 11
	"weapon_first_aid_kit",			// 12
	"weapon_molotov",				// 13
	"weapon_pipe_bomb",				// 14
	"weapon_pain_pills",			// 15
	"weapon_gascan",				// 16
	"weapon_propanetank",			// 17
	"weapon_oxygentank",			// 18
	"weapon_melee",					// 19
	"weapon_chainsaw",				// 20
	"weapon_grenade_launcher",		// 21
	"weapon_ammo_pack",				// 22
	"weapon_adrenaline",			// 23
	"weapon_defibrillator",			// 24
	"weapon_vomitjar",				// 25
	"weapon_rifle_ak47",			// 26
	"weapon_gnome",					// 27
	"weapon_cola_bottles",			// 28
	"weapon_fireworkcrate",			// 29
	"weapon_upgradepack_incendiary",// 30
	"weapon_upgradepack_explosive",	// 31
	"weapon_pistol_magnum",			// 32
	"weapon_smg_mp5",				// 33
	"weapon_rifle_sg552",			// 34
	"weapon_sniper_awp",			// 35
	"weapon_sniper_scout",			// 36
	"weapon_rifle_m60",				// 37
	"weapon_tank_claw",				// 38
	"weapon_hunter_claw",			// 39
	"weapon_charger_claw",			// 40
	"weapon_boomer_claw",			// 41
	"weapon_smoker_claw",			// 42
	"weapon_spitter_claw",			// 43
	"weapon_jockey_claw",			// 44
	"weapon_machinegun",			// 45
	"vomit",						// 46
	"splat",						// 47
	"pounce",						// 48
	"lounge",						// 49
	"pull",							// 50
	"choke",						// 51
	"rock",							// 52
	"physics",						// 53
	"weapon_ammo",					// 54
	"upgrade_item",					// 55
	""
};

/** interface for variant_t buffers. */
enum struct Variant
{
	any value[3];
	char string[128];

	FieldType type;

	/**
	 * get a cell of data
	 *
	 * @return			any single cell data
	 */
	any GetCell()
	{
		return this.value[0];
	}

	/**
	 * set a cell of data
	 *
	 * @param value		any single cell data
	 */
	void SetCell(any value)
	{
		this.value[0] = value;
	}

	/**
	 * get a string value
	 *
	 * @param buffer	buffer to store returned string to
	 * @param length	size of the buffer
	 *
	 * @return 			how many bytes were written to the buffer
	 */
	int GetString(char[] buffer, int length)
	{
		return strcopy(buffer, length, this.string);
	}

	/**
	 * sets a string value
	 *
	 * @param value		string value
	 */
	void SetString(const char[] value)
	{
		strcopy(this.string, sizeof(this.string), value);
	}

	/**
	 * get a vector value
	 *
	 * @param buffer	buffer to store returned vector
	 *
	 * @warning			assumes the data stored in the buffer is a vector
	 */
	void GetVector(float buffer[3])
	{
		for (int i = 0; i < 3; i++)
			buffer[i] = this.value[i];
	}

	/**
	 * set a vector value
	 *
	 * @param value		vector value
	 */
	void SetVector(const float value[3])
	{
		for (int i = 0; i < 3; i++)
			this.value[i] = value[i];
	}
}

/************
 * EntityHooks
 ************/

/**
 * using the AddEntityHook and RemoveEntityHook, you can hook virtual functions of that entity
 */

/** type of entity hook. enum values represent virtual functions. */
enum EntityHook
{
	EntityHook_AcceptInput,			// CBaseEntity
	EntityHook_OnNavAreaChanged,	// Player. only supports post-hook
	EntityHook_CreateRagdollEntity,	// Player
	EntityHook_EventKilled,			// CBaseEntity
	EntityHook_SetObserverTarget,	// Player
	EntityHook_FinishReload,		// CBaseCombatWeapon
	EntityHook_RemoveAmmo,			// CBaseCombatCharacter

	EntityHook_MAX
};

enum EHookMode
{
	EHook_Pre,
	EHook_Post
};

typeset EntityHookCB
{
	/** EntityHook_AcceptInput, EHook_Pre
	 *
	 * @param receiver		hooked entity receiving an input
	 * @param input			the input name
	 * @param activator		entity who triggered source entity to send the input
	 * @param source		entity sending the input once triggered
	 * @param params		parameters for the input. check Variant methodmap
	 *
	 * @return				Plugin_Continue to allow, Plugin_Changed to use changed paramaters, Plugin_Handled to skip
	 *
	 * @note				returning Plugin_Changed if only the Variant params was changed is
	 * 						still recommended since that triggers it to cleanup any allocated
	 * 						memory blocks from Variant.SetString
	 */
	function Action (int receiver, char[] input, int &activator, int &source, Variant params);
	function Action (int receiver, char[] input, int &activator, int &source, Variant params);

	/** EntityHook_AcceptInput, EHook_Post
	 *
	 * @param receiver		hooked entity receiving an input
	 * @param input			the input name
	 * @param activator		entity who triggered source entity to send the input
	 * @param source		entity sending the input once triggered
	 * @param params		parameters for the input. check Variant methodmap
	 * @param handled		true if the pre-hook for this receiver returned Plugin_Handled
	 */
	function void (int receiver, const char[] input, int activator, int source, Variant params, bool handled);

	/** EntityHook_OnNavAreaChanged, EHook_Post
	 *
	 * @param entity		hooked entity who's last known area changed
	 * @param newArea		the NavArea this entity's last known area will update to
	 * @param oldArea		the NavArea of this entity's last known area before this change
	 */
	function void (int entity, NavArea newArea, NavArea oldArea);

	/** EntityHook_CreateRagdollEntity, EHook_Pre
	 *
	 * @param victim		client who died, and who this ragdoll will substitute
	 * @param attacker		entity responsible for the victim's death
	 * @param inflictor
	 * @param damage		damage dealt for the victim's death
	 * @param damageType	type of damage
	 * @param weapon		entity index of the weapon used
	 * @param damageForce
	 * @param damagePos
	 *
	 * @return				Plugin_Continue to allow, Plugin_Changed to use changed parameters, Plugin_Handled to skip
	 *
	 * @note				many params aren't passed as reference because they aren't used in CreateRagdollEntity.
	 * 						this choice is for convenience.
	 */
	function Action (int victim, int attacker, int inflictor, float damage, int &damageType, int weapon, const float damageForce[3], const float damagePos[3]);

	/** EntityHook_CreateRagdollEntity, EHook_Post
	 *
	 * @param victim		client who died, and who this ragdoll will substitute
	 * @param attacker		entity responsible for the victim's death
	 * @param inflictor
	 * @param damage		damage dealt for the victim's death
	 * @param damageType	type of damage
	 * @param weapon		entity index of the weapon used
	 * @param damageForce
	 * @param damagePos
	 * @param handled		true if the pre-hook for this victim returned Plugin_Handled
	 */
	function void (int victim, int attacker, int inflictor, float damage, int damageType, int weapon, const float damageForce[3], const float damagePos[3], bool handled);

	/** EntityHook_EventKilled, EHook_Pre
	 *
	 * @param victim		index of the entity who is dying
	 * @param attacker		index of the entity who is killing this victim
	 * @param inflictor
	 * @param damage		damage dealt for the damage event that caused this death
	 * @param damageType	type of damage
	 * @param weapon		entity index of the weapon used
	 * @param damageForce
	 * @param damagePos
	 *
	 * @return				Plugin_Continue to allow, Plugin_Changed to use changed parameters, Plugin_Handled to skip
	 */
	function Action (int victim, int &attacker, int &inflictor, float &damage, int &damageType, int &weapon, float damageForce[3], float damagePos[3]);

	/** EntityHook_EventKilled, EHook_Post
	 *
	 * @param victim		index of the entity who died
	 * @param attacker		index of the entity who killed this victim
	 * @param inflictor
	 * @param damage		damage dealt for the damage event that caused this death
	 * @param damageType	type of damage
	 * @param weapon		entity index of the weapon used
	 * @param damageForce
	 * @param damagePos
	 * @param handled		true if the pre-hook for this victim returned Plugin_Handled
	 */
	function void (int victim, int attacker, int inflictor, float damage, int damageType, int weapon, const float damageForce[3], const float damagePos[3], bool handled);

	/** EntityHook_SetObserverTarget, EHook_Pre
	 *
	 * @param observer		client index of the observer
	 * @param target		client index of the new observer target
	 *
	 * @return				Plugin_Continue to allow, Plugin_Changed to change observer target, Plugin_Handled to block
	 */
	function Action (int observer, int &target);

	/** EntityHook_SetObserverTarget, EHook_Post
	 *
	 * @param observer		client index of the observer
	 * @param target		client index of the new observer target
	 * @param success		true if function was successful
	 * @param handled		true if pre-hook for this observer returned Plugin_Handled
	 */
	function void (int observer, int target, bool success, bool handled);

	/** EntityHook_FinishReload, EHook_Pre
	 *
	 * @param weapon		entity index of weapon
	 *
	 * @return				Plugin_Continue to allow, Plugin_Handled to block
	 */
	function Action (int weapon);

	/** EntityHook_FinishReload, EHook_Post
	 *
	 * @param weapon		entity index of weapon
	 * @param handled		true if pre-hook returned Plugin_Handled
	 */
	function void (int weapon, bool handled);

	/** EntityHook_RemoveAmmo, EHook_Pre
	 *
	 * @param client		client index to remove ammo from
	 * @param amount		amount of ammo to remove
	 * @param weaponID		type of ammo to remove from
	 *
	 * @return				Plugin_Continue to take no action, Plugin_Changed to change amount/weaponID, Plugin_Handled to block
	 */
	function Action (int client, int &amount, AmmoType &ammoType);

	/** EntityHook_RemoveAmmo, EHook_Post
	 *
	 * @param client		client index to remove ammo from
	 * @param amount		amount of ammo to remove
	 * @param weaponID		type of ammo to remove from
	 * @param handled		true if pre-hook returned Plugin_Handled
	 */
	function void (int client, int amount, AmmoType ammoType, bool handled);
};

/**
 * choose a hook type from the EntityHook enum and hook an entity to a callback from your plugin
 *
 * @param entity	entity to hook
 * @param type		EntityHook_* enum. what type of hook.
 * @param mode		hook mode (EHook_Pre or EHook_Post)
 * @param callback	function in your plugin to use as the callback.
 *
 * @note			make sure the EntityHookCB you use matches the type and mode
 *
 * @return			true on success, false on failure
 */
native bool AddEntityHook(int entity, EntityHook type, EHookMode mode, EntityHookCB callback);

/**
 * manually remove a hook added with AddEntityHook
 *
 * @param entity	entity to remove hook from
 * @param type		EntityHook_* enum. what type of hook.
 * @param mode		hook mode (EHook_Pre or EHook_Post)
 * @param callback	a local callback registered for this hook
 *
 * @note			make sure the EntityHookCB you use matches the type and mode
 * @note			hooks are automatically removed when the entity is destroyed.
 * @note			calling this on an entity who isn't hooked won't cause any errors.
 */
native void RemoveEntityHook(int entity, EntityHook type, EHookMode mode, EntityHookCB callback);

/***********
 * Forwards
 ***********/

/**
 * Called just before a survivor's intensity is increased
 *
 * @param client		client index of survivor this intensity belongs to
 * @param type			IntensityType_* enum
 *
 * @return				Plugin_Handled to skip, Plugin_Changed to continue with
 * 						changed IntensityType, Plugin_Continue for no action
 */
forward Action OnIncreaseSurvivorIntensity(int client, IntensityType &type);

/**
 * Called after a survivor's intensity is increased
 *
 * @param client		client index of survivor this intensity belongs to
 * @param type			IntensityType_* enum
 * @param handled		true if OnIncreaseSurvivorIntensity returned Plugin_Handled
 */
forward void OnIncreaseSurvivorIntensity_Post(int client, IntensityType type, bool handled);

/**
 * Called just before a map triggers a panic event
 *
 * @param activator		player responsible for triggering the event (-1 if none)
 * @param reason		how is this event being triggered
 *
 * @return				Plugin_Continue to allow it, Plugin_Handled to block
 */
forward Action OnMapInvokedPanicEvent(int activator, PanicEventReason reason);

/**
 * Called after a map triggered a panic event
 *
 * @param activator		player responsible for triggering the event (-1 if none)
 * @param reason		how was this event triggered
 * @param handled		OnMapInvokedPanicEvent returned Plugin_Handled
 */
forward void OnMapInvokedPanicEvent_Post(int activator, PanicEventReason reason, bool handled);

/**
 * Called just before a panic event starts
 *
 * @param activator		player responsible for triggering the event (-1 if none)
 * @param crescendo		if crescendo, the director can only spawn infected in nav areas marked as BATTLEFIELD
 * @param waves			total mega horde waves for this panic event
 * @param defaultWaves	true if the wave amount is the automatic default, false if it was manually specified
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block, Plugin_Changed to apply changes to params
 */
forward Action OnStartPanicEvent(int activator, bool &crescendo, int &waves, bool defaultWaves);

/**
 * Called after a panic event starts
 *
 * @param activator		player responsible for triggering the event (-1 if none)
 * @param crescendo		if crescendo, the director can only spawn infected in nav areas marked as BATTLEFIELD
 * @param waves			total mega horde waves for this panic event
 * @param defaultWaves	true if the wave amount is the automatic default, false if it was manually specified
 * @param handled		true if OnStartPanicEvent returned Plugin_Handled
 */
forward void OnStartPanicEvent_Post(int activator, bool crescendo, int waves, bool defaultWaves, bool handled);

/**
 * Called just before a finale is started
 *
 * @param activator		player who triggered this finale (-1 if none)
 * @param type			FinaleType_* enum for what type of finale this is
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 */
forward Action OnStartFinale(int activator, FinaleType type);

/**
 * Called after a finale was started
 *
 * @param activator		player who triggered this finale (-1 if none)
 * @param type			enum for what type of finale this is
 * @param handled		true if OnStartFinale returned Plugin_Handled
 */
forward void OnStartFinale_Post(int activator, FinaleType type, bool handled);

/**
 * calls when the director updates which script variables are set
 */
forward void OnGetDirectorOptions();

/**
 * calls just before a LocalScript gets loaded by the director
 *
 * @param script		name of the script
 *
 * @return 				Plugin_Continue to allow, Plugin_Changed to change script name, Plugin_Handled to block
 *
 * @note				OnEndLocalScript and OnGetDirectorOptions get called from this.
 */
forward Action OnBeginLocalScript(char script[1024]);

/**
 * calls after a LocalScript gets loaded by the director
 *
 * @param script		name of the script
 * @param handled		true if OnBeginLocalScript returned Plugin_Handled
 *
 * @note				OnEndLocalScript and OnGetDirectorOptions get called from this.
 */
forward void OnBeginLocalScript_Post(const char[] script, bool handled);


/**
 * calls just before the LocalScript scope gets cleared of any running director script
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 *
 * @note				OnGetDirectorOptions gets called from this.
 */
forward Action OnEndLocalScript();

/**
 * calls after the LocalScript scope gets cleared of any running director script
 *
 * @param handled		true if OnEndLocalScript returned Plugin_Handled
 *
 * @note				OnGetDirectorOptions gets called from this.
 */
forward void OnEndLocalScript_Post(bool handled);

/**
 * calls before the game generates a random spawn position for a special infected
 *
 * @param class			special infected ZombieClass that this position should generate for
 * @param tries			try to get a spawn position up until this many times
 * @param ghost			the client index of the player ghost this is called on (-1 if none)
 *
 * @return				Plugin_Continue to allow, Plugin_Changed to change class and tries, Plugin_Handled to block
 *
 * @note				use the OnGetRandomPZSpawnPosition_Override to override the spawn position and return value
 */
forward Action OnGetRandomPZSpawnPosition(ZombieClass &class, int &tries, int ghost);

/**
 * calls at the end of GetRandomPZSpawnPosition, just before OnGetRandomPZSpawnPosition_Post forward.
 * this forward is used to override the spawn position and return value (success param)
 *
 * @param class			special infected ZombieClass that this position should generate for
 * @param tries			try to get a spawn position up until this many times
 * @param ghost			the client index of the player ghost this is called on (-1 if none)
 * @param pos			the generated spawn position. will be 0.0, 0.0, 0.0 if success is false
 * @param success		was a spawn position successfully generated?
 *
 * @return				Plugin_Handled to force the position to be rejected, Plugin_Changed to override pos and success, Plugin_Continue to continue without changes
 *
 * @note				if OnGetRandomPZSpawnPosition returned Plugin_Handled, this forward won't call
 */
forward Action OnGetRandomPZSpawnPosition_Override(ZombieClass class, int tries, int ghost, float pos[3], bool &success);

/**
 * calls after a random spawn position for a special infected was attempted to generate
 *
 * @param class			special infected ZombieClass that this position should generate for
 * @param tries			try to get a spawn position up until this many times
 * @param ghost			the client index of the player ghost this is called on (-1 if none)
 * @param pos			the generated spawn position. will be 0.0, 0.0, 0.0 if success is false
 * @param success		was a spawn position successfully generated?
 * @param handled		true if OnGetRandomPZSpawnPosition returned Plugin_Handled
 */
forward void OnGetRandomPZSpawnPosition_Post(ZombieClass class, int tries, int ghost, const float pos[3], bool success, bool handled);

/**
 * calls just before a nav area set for picking a spawn location is collected
 *
 * @param location		see LocationType enum. each location type has a separate nav area set, each generated differently
 * @param class			the ZombieClass to use for generating the set
 *
 * @return				Plugin_Continue to allow, Plugin_Changed to apply changes to params, Plugin_Handled to block
 *
 * @warning				LocationType_Null isn't a valid location type. server will crash if you change location to that
 */
forward Action OnCollectSpawnAreas(LocationType &location, ZombieClass &class);

/**
 * calls after a nav area set for picking a spawn location is collected
 *
 * @param location		see LocationType enum. each location type has a separate nav area set, each generated differently
 * @param class			the ZombieClass to use for generating the set
 * @param spawnAreas	the collected nav area set. you may use the NavAreaSet methodmap to modify it however you like.
 * @param handled		true if OnCollectSpawnAreas returned Plugin_Handled
 *
 * @note				each location type's nav area set is persistent, and only regenerate after an
 * 						internal timer since the last generation elapses. if this is called on a
 * 						location too soon since the last time, it will skip regenerating it and
 * 						the spawnAreas set will be the same as the last time.
 */
forward void OnCollectSpawnAreas_Post(LocationType location, ZombieClass class, NavAreaSet spawnAreas, bool handled);

/**
 * calls just before mob timer gets reset to 0.0
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 */
forward Action OnResetMobTimer();

/**
 * calls after the mob timer gets reset to 0.0
 *
 * @param handled		true if OnResetMobTimer returned Plugin_Handled
 */
forward void OnResetMobTimer_Post(bool handled);

/**
 * calls just before a new mob timer is set.
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 */
forward Action OnStartMobTimer();

/**
 * calls after a new mob timer gets set, allowing the set time to be overwritten
 *
 * @param time			the time until next mob
 *
 * @return				Plugin_Continue to take no action, Plugin_Changed to apply changes to the param, Plugin_Handled is a shortcut to set time to 0.0
 *
 * @note				if OnStartMobTimer returns Plugin_Handled, this forward will not call
 */
forward Action OnStartMobTimer_Override(float &time);

/**
 * calls after a new mob timer gets set
 *
 * @param time			the time until next mob
 * @param handled		true if OnStartMobTimer returned Plugin_Handled
 */
forward void OnStartMobTimer_Post(float time, bool handled);

/**
 * calls just before all special timers (by type and by slot) are reset to 0.0
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 */
forward Action OnResetSpecialTimers();

/**
 * calls after all special timers (by type and by slot) are reset to 0.0
 *
 * @param handled		true if OnResetSpecialTimers returned Plugin_Handled
 */
forward void OnResetSpecialTimers_Post(bool handled);

/**
 * calls just before a location is checked for being suitable for a zombie spawn
 *
 * @param pos			position in world
 * @param nav			the nav area containing the position
 * @param class			class of the zombie we're checking for
 * @param ghost			meant to be the client index of a ghost player this is calling for.
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 */
forward Action OnCanZombieSpawnHere(const float pos[3], NavArea nav, ZombieClass class, int ghost);

/**
 * calls after a location is checked for being suitable for a zombie spawn.
 * you can override the returned result here
 *
 * @param pos			position in world
 * @param nav			the nav area containing the position
 * @param class			class of the zombie we're checking for
 * @param ghost			meant to be the client index of a ghost player this is calling for.
 * @param result		true if the zombie is allowed to spawn here, false if not
 *
 * @return				Plugin_Continue to take no action, Plugin_Changed to override result
 *
 * @note				if OnCanZombieSpawnHere returned Plugin_Handled, this forward won't call
 */
forward Action OnCanZombieSpawnHere_Override(const float pos[3], NavArea nav, ZombieClass class, int ghost, bool &result);

/**
 * calls after a location is checked for being suitable for a zombie spawn.
 *
 * @param pos			position in world
 * @param nav			the nav area containing the position
 * @param class			class of the zombie we're checking for
 * @param ghost			meant to be the client index of a ghost player this is calling for.
 * @param result		true if the zombie is allowed to spawn here, false if not
 * @param handled		true if OnCanZombieSpawnHere returned Plugin_Handled
 */
forward void OnCanZombieSpawnHere_Post(const float pos[3], NavArea nav, ZombieClass class, int ghost, bool result, bool handled);

/**
 * called just before the director attempts to update the tempo state.
 *
 * @param current		current tempo state. see Tempo_* enums
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 *
 * @note				outside of round restarts, this is the only way tempo can update.
 * 						returning Plugin_Handled effectively freezes tempo at any state.
 */
forward Action OnUpdateTempo(DirectorTempo current);

/**
 * called after the director attempted to update the tempo state.
 *
 * @param oldValue		tempo state before UpdateTempo was called (see Tempo_* enums)
 * @param newValue		tempo state after UpdateTempo was called (see Tempo_* enums)
 * @param handled		true if OnUpdateTempo returned Plugin_Handled
 *
 * @note				this calls everytime an update is attempted. most times an actual
 * 						change never occurs, and oldValue will equal newValue
 */
forward void OnUpdateTempo_Post(DirectorTempo oldValue, DirectorTempo newValue, bool handled);

/**
 * when director tempo transitions to SUSTAIN_PEAK (Tempo_SustainPeak enum), it will call this function.
 * it clears the population density from every nav area within any survivor's active set.
 *
 * @return				Plugin_Handled to block this from calling, Plugin_Continue to take no action
 */
forward Action OnSustainPeakPopulationClear();

/**
 * when director tempo transitions to SUSTAIN_PEAK (Tempo_SustainPeak enum), it will call this function.
 * it clears the population density from every nav area within any survivor's active set.
 *
 * @param handled		true if OnSustainPeakPopulationClear returned Plugin_Handled
 */
forward void OnSustainPeakPopulationClear_Post(bool handled);

/**
 * called just before a client goes idle.
 *
 * @param client		client index of the player about to go idle
 *
 * @return				Plugin_Handled to block the idle, Plugin_Continue to allow
 *
 * @note				the "Player is now idle." user message is sent outside of this. you likely
 * 						will want to handle that too (TextMsg um type, #L4D_idle_spectator message)
 */
forward Action OnGoAwayFromKeyboard(int client);

/**
 * called after a client goes idle.
 *
 * @param client		client index of the player who went idle
 * @param handled		true if OnGoAwayFromKeyboard returned Plugin_Handled
 */
forward void OnGoAwayFromKeyboard_Post(int client, bool handled);

/**
 * called just before a spit projectile is created
 *
 * @param spitter		entity owning the spit. 0 if there's no owner
 * @param origin		position the spit projectile will spawn
 * @param angles		angles vector, relative to origin
 * @param velocity		velocity vector
 * @param rotation		rotation vector
 *
 * @return				Plugin_Handled to block, Plugin_Changed to apply param changes, Plugin_Continue to allow with no action taken
 */
forward Action OnCreateSpitterProjectile(int spitter, float origin[3], float angles[3], float velocity[3], float rotation[3]);

/**
 * called after a spit projectile is created
 *
 * @param spitter		entity owning the spit projectile. 0 if there's no owner
 * @param projectile	entity index of the created projectile
 * @param origin		position the spit projectile will spawn
 * @param angles		angles vector, relative to origin
 * @param velocity		velocity vector
 * @param rotation		rotation vector
 * @param handled		true if OnSpitterProjectileCreated returned Plugin_Handled
 */
forward void OnCreateSpitterProjectile_Post(int spitter, int projectile, const float origin[3], const float angles[3], const float velocity[3], const float rotation[3], bool handled);

/**
 * called just before an inferno attempts to create a flame
 *
 * @param inferno		Inferno methodmap. CInferno address
 * @param origin		origin to spawn the flame at
 * @param direction		normalized vector of flame direction
 * @param parent		Flame methodmap. the flame to set as the parent of the newly created flame.
 * 						0 for no parent.
 * @param depth			generational depth. 0 for root, 1 for child of root, etc.
 *
 * @return				Plugin_Continue to take no action. Plugin_Handled to block function. Plugin_Changed to apply changed params
 */
forward Action OnCreateFlame(Inferno inferno, float origin[3], float direction[3], Flame parent, int &depth);

/**
 * called after an inferno created a flame
 *
 * @param inferno		Inferno methodmap. CInferno address
 * @param flame			Flame methodmap. the newly created flame (0 if creation failed)
 * @param origin		origin this flame was told to spawn at. actual origin written to the Flame's struct
 * 						may have a Z elevated from this param's in some scenarios.
 * @param direction		normalized direction vector written to the flame on success
 * @param parent		Flame methodmap. the flame set as the parent for the created flame.
 * @param depth			generational depth. 0 for root, 1 for child of root, etc.
 * @param success		true if flame was created, false if not.
 * @param handled		true if OnCreateFlame returned Plugin_Handled
 */
forward void OnCreateFlame_Post(Inferno inferno, Flame flame, const float origin[3], const float direction[3], Flame parent, int depth, bool success, bool handled);

/**
 * called when a spit's CInferno is setting its lifetime. can override returned lifetime
 *
 * @param inferno		Inferno methodmap. CInferno address
 * @param lifetime		the lifetime that will be set
 *
 * @return				Plugin_Change to override, Plugin_Continue to take no action. Plugin_Handled is a shortcut to set lifetime to 0.0
 */
forward Action OnGetSpitLifetime_Override(Inferno inferno, float &lifetime);

/**
 * called when a spit's CInferno has set its lifetime.
 *
 * @param inferno		Inferno methodmap. CInferno address
 * @param lifetime		the lifetime that was set
 */
forward void OnGetSpitLifetime_Post(Inferno inferno, float lifetime);

/**
 * called just before a new punch angle is set for this player
 *
 * @param client		client index of player whose punch angle will be modified
 * @param angle			QAngle vector of the new punch angle
 *
 * @return				Plugin_Continue to allow with no action taken, Plugin_Handled to block function, Plugin_Changed to use changed params
 */
forward Action OnSetPunchAngle(int client, float angle[3]);

/**
 * called after a new punch angle was set for a player
 *
 * @param client		client index of player whose punch angle was modified
 * @param angle			QAngle vector of punch angle set
 * @param handled		true if OnSetPunchAngle returned Plugin_Handled
 */
forward void OnSetPunchAngle_Post(int client, const float angle[3], bool handled);

/**
 * called just before a gun's recoil sets a player's punch angle
 *
 * @param weapon		entity index of the gun giving recoil
 * @param client		client index of the player receiving recoil
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 *
 * @note				this is a wrapper function for SetPunchAngle
 */
forward Action OnGunViewPunch(int weapon, int client);

/**
 * called after a gun's recoil sets a player's punch angle
 *
 * @param weapon		entity index of the gun giving recoil
 * @param client		client index of the player receiving recoil
 * @param handled		true if OnGunViewPunch returned Plugin_Handled
 *
 * @note				this is a wrapper function for SetPunchAngle
 */
forward void OnGunViewPunch_Post(int weapon, int client, bool handled);

/**
 * the term "connectionless" means the sender of the packet does not have an established connection
 * with the server. for example, querying server info in steam's server browser will be a connectionless packet.
 * this calls just before one of these received packets are processed.
 *
 * @param adrType		NetAdr_* enum.
 * @param ipv4			an ipv4 net address
 * @param port			network port the packet was received on
 * @param packetType	a code for what type of packet this is. some codes have an enum, check Packet_*
 * @param packet		the packet's data. some cells can be characters of a string, some not
 * @param packetSize	how many cells are in the packet array
 *
 * @return				Plugin_Continue to take no action, Plugin_Handled to prevent packet from being processed
 *
 * @note				for connecting clients, this is the earliest forward in the connection process.
 * 						it calls before a client index is even assigned.
 */
forward Action OnConnectionlessPacket(NetAdrType adrType, int ipv4, int port, int packetType, const any[] packet, int packetSize);

/**
 * the term "connectionless" means the sender of the packet does not have an established connection
 * with the server. for example, querying server info in steam's server browser will be a connectionless packet.
 * this calls after one of these received packets are processed.
 *
 * @param adrType		NetAdr_* enum.
 * @param ipv4			an ipv4 net address
 * @param port			network port the packet was received on
 * @param packetType	a code for what type of packet this is. some codes have an enum, check Packet_*
 * @param packet		the packet's data. some cells can be characters of a string, some not
 * @param packetSize	how many cells are in the packet array
 * @param handled		true of OnConnectionlessPacket returned Plugin_Handled
 *
 * @note				for connecting clients, this is the earliest forward in the connection process.
 * 						it calls before a client index is even assigned.
 */
forward void OnConnectionlessPacket_Post(NetAdrType adrType, int ipv4, int port, int packetType, const any[] packet, int packetSize, bool handled);

/**
 * called after a reservation cookie was set
 *
 * @param cookie		64 bit unsigned integer of the cookie
 */
forward void OnSetReservationCookie_Post(const int cookie[2]);

/**
 * called just before the server forcefully shows a client the MOTD
 *
 * @param client		the client who will be shown the MOTD
 *
 * @return				Plugin_Handled to block, Plugin_Continue to allow
 */
forward Action OnShowMOTD(int client);

/**
 * called after the server forcefully showed a client the MOTD
 *
 * @param client		the client who was shown the MOTD
 * @param handled		true if OnShowMOTD returned Plugin_Handled
 */
forward void OnShowMOTD_Post(int client, bool handled);

/**
 * called just before the server shows a client the hostfile banner
 *
 * @param client		the client who will be shown the host banner
 *
 * @return				Plugin_Handled to block, Plugin_Continue to allow
 */
forward Action OnShowHostBanner(int client);

/**
 * called after the server showed a client the hostfile banner
 *
 * @param client		the client who was shown the host banner
 * @param handled		true if OnShowHostBanner returned Plugin_Handled
 */
forward void OnShowHostBanner_Post(int client, bool handled);

/**
 * calls before the game checks for a free client slot, and creating a client
 * for the net address provided if there is a free slot.
 *
 * @param adrType		NetAdr_* enum.
 * @param ipv4			an ipv4 net address
 * @param port			network port the packet was received on
 *
 * return				Plugin_Handled to block (tells calling code there's no free slot, and no client is created), Plugin_Continue to take no action
 */
forward Action OnGetFreeClient(NetAdrType adrType, int ipv4, int port);

/**
 * calls before the game checks for a free client slot, and creating a client
 * for the net address provided if there is a free slot.
 *
 * @param adrType		NetAdr_* enum.
 * @param ipv4			an ipv4 net address, with its octets split into an array ([0].[1].[2].[3])
 * @param port			network port the packet was received on
 * @param client		if a slot is free, then this is the index of the client just created
 * @param handled		true if OnGetFreeClient returned Plugin_Handled
 *
 * @note				the client param will refer to a client who isn't connected yet
 */
forward void OnGetFreeClient_Post(NetAdrType adrType, int ipv4, int port, int client, bool handled);

/**
 * calls before a player entity will vocalize a game sound
 *
 * @param client		client index of player who will vocalize
 * @param gameSound		name of the game sound, as seen in scripts/game_sounds_* script files
 * @param cooldown		cooldown for when the client can vocalize again
 * @param durationAI	duration of time AI will recognize the sound
 *
 * @return				Plugin_Continue to allow, Plugin_Changed to change params, Plugin_Handled to block
 *
 * @note				cooldown isn't strictly enforced. checking the cooldown timer set is handled
 * 						in parent functions. it could be ignored in some scenarios.
 */
forward Action OnVocalize(int client, char gameSound[64], float &cooldown, float &durationAI);

/**
 * calls after a player entity vocalized a game sound
 *
 * @param client		client index of player who vocalized
 * @param gameSound		name of the game sound, as seen in scripts/game_sounds_* script files
 * @param cooldown		cooldown for when the client can vocalize again
 * @param durationAI	duration of time AI will recognize the sound
 * @param handled		true if OnVocalize returned Plugin_Handled
 *
 * @note				cooldown isn't strictly enforced. checking the cooldown timer set is handled
 * 						in parent functions. it could be ignored in some scenarios.
 */
forward void OnVocalize_Post(int client, const char gameSound[64], float cooldown, float durationAI, bool handled);

/**
 * CDirector::CheckForDeadPlayers pre-hook. this is called as part of the director updating
 * the state of the "scenario". the most notable thing that can happen in this is a scenario
 * being ended when the survivor team is dead or no longer capable of continuing.
 *
 * @param skipClamp		if true, apply memory patch to skip clamping total capable survivors to
 * 						total alive human survivors (as if allow_all_bot_survivor_team were 1)
 *
 * @return				Plugin_Continue to take no action, Plugin_Changed to apply skipClamp patch, Plugin_Handled to skip
 */
forward Action OnScenarioCheckForDeadPlayers(bool &skipClamp);

/**
 * CDirector::CheckForDeadPlayers post-hook. this is called as part of the director updating
 * the state of the "scenario". the most notable thing that can happen in this is a scenario
 * being ended when the survivor team is dead or no longer capable of continuing.
 *
 * @param handled		true if OnScenarioCheckForDeadPlayers returned Plugin_Handled
 */
forward Action OnScenarioCheckForDeadPlayers_Post(bool handled);

/**
 * called just before a survivor_death_model entity is created for a client
 *
 * @param client		client index of the survivor this death model substitutes
 *
 * @return				Plugin_Continue to allow, Plugin_Handled to block
 */
forward Action OnCreateSurvivorDeathModel(int client);

/**
 * called after a survivor_death_model entity is created for a client
 *
 * @param client		client index of the survivor this death model substitutes
 * @param model			entity index of the newly created model
 * @param handled		true if OnCreateSurvivorDeathModel returned Plugin_Handled
 */
forward void OnCreateSurvivorDeathModel_Post(int client, int model, bool handled);

/**
 * called just before a survivor becomes incapacitated
 *
 * @param client		client index of survivor
 * @param attacker		index of the entity who incapacitated this survivor
 * @param inflictor
 * @param damage		damage dealt for the damage event that caused this incapacitation
 * @param damageType	type of damage
 * @param weapon		entity index of the weapon used
 * @param damageForce
 * @param damagePos
 *
 * @return				Plugin_Continue to take no action. Plugin_Changed to apply param changes. Plugin_Handled to block
 */
forward Action OnIncapacitatedAsSurvivor(int client, int &attacker, int &inflictor, float &damage, int &damageType, int weapon, const float damageForce[3], const float damagePos[3]);

/**
 * called after a survivor becomes incapacitated
 *
 * @param client		client index of survivor
 * @param attacker		index of the entity who incapacitated this survivor
 * @param inflictor
 * @param damage		damage dealt for the damage event that caused this incapacitation
 * @param damageType	type of damage
 * @param weapon		entity index of the weapon used
 * @param damageForce
 * @param damagePos
 * @param handled		true if OnIncapacitatedAsSurvivor returned Plugin_Handled
 */
forward void OnIncapacitatedAsSurvivor_Post(int client, int attacker, int inflictor, float damage, int damageType, int weapon, const float damageForce[3], const float damagePos[3], bool handled);

/**
 * called just before a tank becomes incapacitated. incapacitation for tanks means their death animation
 *
 * @param client		client index of tank
 * @param attacker		index of the entity who incapacitated this tank
 * @param inflictor
 * @param damage		damage dealt for the damage event that caused this incapacitation
 * @param damageType	type of damage
 * @param weapon		entity index of the weapon used
 * @param damageForce
 * @param damagePos
 *
 * @return				Plugin_Continue to take no action. Plugin_Changed to apply param changes. Plugin_Handled to block
 */
forward Action OnIncapacitatedAsTank(int client, int &attacker, int &inflictor, float &damage, int &damageType, int weapon, const float damageForce[3], const float damagePos[3]);

/**
 * called after a tank becomes incapacitated. incapacitation for tanks means their death animation
 *
 * @param client		client index of tank
 * @param attacker		index of the entity who incapacitated this tank
 * @param inflictor
 * @param damage		damage dealt for the damage event that caused this incapacitation
 * @param damageType	type of damage
 * @param weapon		entity index of the weapon used
 * @param damageForce
 * @param damagePos
 * @param handled		true if OnIncapacitatedAsTank returned Plugin_Handled
 */
forward void OnIncapacitatedAsTank_Post(int client, int attacker, int inflictor, float damage, int damageType, int weapon, const float damageForce[3], const float damagePos[3], bool handled);

/**
 * called just before a CTerrorGun is told to toggle its zoom state
 *
 * @param weapon		entity index of weapon
 *
 * @return				Plugin_Continue to take no action, Plugin_Handled to skip
 */
forward Action OnCycleZoom(int weapon);

/**
 * called after a CTerrorGun is told to toggle its zoom state
 *
 * @param weapon		entity index of weapon
 * @param handled		true of OnCycleZoom returned Plugin_Handled
 */
forward void OnCycleZoom_Post(int weapon, bool handled);

/**
 * the reserve ammo of a client is about to be set to an amount
 *
 * @param client		client index of the player owning this reserve ammo
 * @param amount		amount to set it to
 * @param ammoType		reserve ammo is of this Ammo_* type
 *
 * @return				Plugin_Continue to take no action, Plugin_Changed to change amount/ammoType, Plugin_Handled to block
 */
forward Action OnSetReserveAmmo(int client, int &amount, AmmoType &ammoType);

/**
 * the reserve ammo of a client was set to an amount
 *
 * @param client		client index of the player owning this reserve ammo
 * @param amount		amount to set it to
 * @param ammoType		reserve ammo is of this Ammo_* type
 * @param handled		true if OnSetReserveAmmo returned Plugin_Handled
 */
forward void OnSetReserveAmmo_Post(int client, int amount, AmmoType ammoType, bool handled);

/***********
 * Natives
 ***********/

/**
 * force hxlib to rescan which forwards are in use, to enable/disable hooks based on what's needed
 *
 * @note			this native is only useful if your plugin loaded late. hxlib automatically
 * 					does this scan in OnAllPluginsLoaded and every OnMapStart
 */
native void HXLibRescanForwards();

/**
 * get an enum for what type of server this is (OS_Linux, OS_Windows, or OS_Invalid)
 *
 * @return			ServerOS enum
 *
 * @note			hxlib only supports linux and windows, hence why anything else will be OS_Invalid
 */
native ServerOS GetServerOS();

/**
 * Set the intensity of this survivor
 *
 * @param survivor		client index of the survivor
 * @param intensity		desired intensity (must be between 0.0 to 1.0 inclusive)
 *
 * @note 				setting it to 0.0 will call Intensity::Reset
 */
native void SetSurvivorIntensity(int survivor, float intensity);

/**
 * Get the intensity of this survivor
 *
 * @param survivor		client index of the survivor
 *
 * @return				their current intensity
 */
native float GetSurvivorIntensity(int survivor);

/**
 * increases a survivor's intensity, and resets the time until decay
 *
 * @param client		client index of the survivor owning the intensity to be increased
 * @param type			IntensityType_* enum, a scale of 1 through 5
 */
native void IncreaseSurvivorIntensity(int client, IntensityType type);

/**
 * Get an entity index from an address
 *
 * @param addr			CBaseEntity address
 *
 * @return				entity index
 */
native int GetEntityFromAddress(Address addr);

/**
 * returns true if a finale is ongoing
 *
 * @return				true if a finale is ongoing
 *
 * @note				a "finale" can also be a scripted panic event.
 * 						it's any event managed by the director's scripted event manager that's
 * 						made up of finale stages.
 */
native bool IsFinale();

/**
 * Get what type of event/finale the scripted event manager is managing
 *
 * @return				FinaleType enum
 */
native FinaleType GetFinaleType();

/**
 * Get current finale stage of the scripted event manager managed event/finale
 *
 * @return				FinaleStage enum
 */
native FinaleStage GetFinaleStage();

/**
 * Get current PanicStage
 *
 * @return 				PanicStage enum
 */
native PanicStage GetPanicStage();

/**
 * Determines if the game is in panic mode
 *
 * @return				true if in panic
 */
native bool IsPanic();

/**
 * returns true if a crescendo panic is ongoing
 *
 * @return				true if in crescendo
 *
 * @note				crescendo refers to panic events with spawn locations
 * 						in nav areas with the BATTLEFIELD spawn attribute
 */
native bool IsCrescendo();

/**
 * set ongoing crescendo status
 *
 * @param set			true for crescendo, false for non-crescendo
 *
 * @note				in cresceno panic events, spawns only happen
 * 						in nav areas with BATTLEFIELD spawn attribute.
 */
native void SetCrescendo(bool set);

/**
 * returns true if a crescendo panic event has already occurred this round
 *
 * @return				true if crescendo has occurred
 *
 * @note				crescendo refers to panic events with spawn locations
 * 						in nav areas with the BATTLEFIELD spawn attribute
 * @note				only one crescendo event can occur per map. this being true
 * 						means BATTLEFIELD areas can no longer prevent spawns (event preparation),
 * 						and any panic event started in these areas will be normal panic events.
 */
native bool HasCrescendoOccurred();

/**
 * set if a crescendo has occurred already this round
 *
 * @param set			the new value. true for has occurred, false for has not
 *
 * @note				only one crescendo event can occur per map. when one occurs, this will
 * 						be auto-set to true. on round (re)start it gets auto-set to false. use
 * 						this native to manually set it
 */
native void SetCrescendoOccurred(bool set);

/**
 * get amount of mega mob waves the current panic spawned
 *
 * @return				amount of completed panic waves
 *
 * @note				this counts when the wave's mob is set to spawn, not
 * 						when the last common of the mob spawns
 */
native int GetCompletedPanicWaves();

/**
 * set amount of mega mob waves the current panic spawned
 *
 * @param waves			wave amount to set as completed
 *
 * @note				this counts when the wave's mob is set to spawn, not
 * 						when the last common of the mob spawns
 */
native void SetCompletedPanicWaves(int waves);

/**
 * get total amount of mega mob waves required to spawn for panic to end
 *
 * @return				total waves
 */
native int GetTotalPanicWaves();

/**
 * set total amount of mega mob waves required to spawn for panic to end
 *
 * @param waves			wave amount to set as total required
 */
native void SetTotalPanicWaves(int waves);

/**
 * ends an ongoing panic. panic events will completely end, panic finale stages will end
 * and the finale will move on to the next stage
 */
native void EndPanicEvent();

/**
 * should director tempo be locked to Tempo_BuildUp?
 *
 * @return				true if locked, false if not
 *
 * @note				if the LockTempo script variable exists, its value will always be returned
 */
native bool ShouldLockTempo();

/**
 * get the director's current tempo state
 *
 * @return				Tempo_* enums
 */
native DirectorTempo GetTempo();

/**
 * set a new director tempo state
 *
 * @param tempo			Tempo_* enums
 * @param doAll			true to update additional data that a natural transition
 * 						would've updated. setting to false will likely lead to
 * 						your change not persisting as expected
 */
native void SetTempo(DirectorTempo tempo, bool doAll = true);

/**
 * when director tempo transitions to PEAK_FADE or RELAX, the flow of the furthest survivor
 * at this moment is recorded to this flow stamp. it's only relevant for transitioning out
 * of these 2 states, so for any other state consider it a garbage value.
 *
 * @return				FlowType_Progress flow value
 */
native float GetTempoFlowStamp();

/**
 * when director tempo transitions to PEAK_FADE or RELAX, the flow of the furthest survivor
 * at this moment is recorded to this flow stamp. this value can be overwritten with this
 * native. the value is only relevant for transitioning out of these 2 states, so for any
 * other state this native effectively does nothing
 *
 * @param value			FlowType_Progress flow value
 */
native void SetTempoFlowStamp(float value);

#pragma deprecated Use GetTempoTimer() instead
native float GetTempoRemainingTime();

#pragma deprecated Use GetTempoTimer() instead
native void SetTempoRemainingTime(float value);

/**
 * delays related to tempo state transitions. to transition out of any state
 * except PEAK_FADE, this timer needing to elapse is among the conditions.
 *
 * @return					CountdownTimer methodmap
 */
native CountdownTimer GetTempoTimer();

/**
 * get the client index of the survivor furthest along the flow
 *
 * @param type				FlowType_* enum. which type of flow must they be furthest along
 *
 * @return					client index
 */
native int GetHighestFlowSurvivor(FlowType type = FlowType_Progress);

/**
 * get a player's current flow
 *
 * @param client			client index of the player you want to get the flow of
 * @param type				FlowType_* enum. returned value is of this type
 *
 * @return					flow value
 */
native float GetPlayerFlow(int client, FlowType type = FlowType_Progress);

/**
 * get the address of the last valid nav area this character was known to be in.
 *
 * @param client		entity index of the character to check
 *
 * @return 				NavArea address, 0 on fail
 *
 * @note				the nav area this native gets only gets updated when the character
 * 						moves through "traversable" areas. if an area is a nav blocker for
 * 						example, then the last known area won't update to this area.
 */
native NavArea GetLastKnownArea(int character);

/**
 * get the address of the nav area this character is currently in
 *
 * @param character		entity index of the character to check
 *
 * @return				NavArea address, 0 if character is not in any nav area
 *
 * @note				the area is retrieved in the same way as a character's last known
 * 						area is updated, with the exception of ignoring nav blockers.
 */
native NavArea GetCurrentArea(int character);

/**
 * notes on the below 4 natives!!
 * We have GetNavArea, and GetNearestNavArea. the 2 both have a pair of different versions:
 * one that accepts a vector position, and another that accepts an entity.
 *
 * the entity variants are slightly more than a shortcut of getting the origin of the entity.
 * for example, GetNavAreaEntity is the only one of its pair that allows restriction flags. it
 * also confirms if the entity is allowed in that area.
 * GetNearestNavAreaEntity is much more of a wrapper however. it will call GetNavAreaEntity
 * with a distance param of 120.0, and if that fails it calls GetNearestNavArea (vector variant)
 * with the distance param from the native.
 *
 * so using GetNavAreaEntity over GetNavArea should always be preferred for entities (unless
 * you don't care for entity specific checks), and GetNearestNavAreaEntity is just an all
 * inclusive shortcut.
 */

/**
 * get the nav area this entity is in by searching directly below the entity
 *
 * @param entity		index of the entity to check
 * @param distance		max distance below to search for an area
 * @param flags			see GetNavFlag_* enums. configure restrictions used in the search
 *
 * @return				address of the area. see NavArea methodmap
 *
 * @note				any flag set will cause obstructions to disqualify areas
 * 						below them. this is logical for RequireGround and CheckLOS,
 * 						but it's even true for IgnoreBlockers which is likely a bug.
 */
native NavArea GetNavAreaEntity(int entity, float distance = 120.0, int flags = GetNavFlag_CheckLOS|GetNavFlag_RequireGround);

/**
 * get the nav area this position is in by searching directly below the position
 *
 * @param pos			vector position to check
 * @param distance		max distance below to search for an area
 *
 * @return				address of the area. see NavArea methodmap
 */
native NavArea GetNavArea(const float pos[3], float distance = 120.0);

/**
 * get the nav area nearest to this entity, within a given range
 *
 * @param entity		entity to search around for an area
 * @param distance		max range from the entity to search for an area
 * @param flags			see GetNavFlag_* enums. configure restrictions used in the search
 *
 * @return				address of the area. see NavArea methodmap
 */
native NavArea GetNearestNavAreaEntity(int entity, float distance, int flags = GetNavFlag_CheckLOS|GetNavFlag_RequireGround);

/**
 * get the nav area nearest to this position, within a given range
 *
 * @param pos			vector position to search around for an area
 * @param distance		max range from the position to search for an area
 * @param flags			see GetNavFlag_* enums. configure restrictions used in the search
 *
 * @return				address of the area. see NavArea methodmap
 *
 * @note				if CheckLOS and RequireGround flags are both ommitted, then it will
 * 						fallback to GetNavArea (vector variant) very early, before it
 * 						checks for blockers. because the vector variant of GetNavArea
 * 						doesn't accept flags, this means blocked areas are never filtered
 * 						in this scenario, even when the IgnoreBlockers flag is ommitted.
 * 						so if you want blocked nav areas to be filtered from the search,
 * 						one of the CheckLOS or RequireGround flags must be set. Likely
 * 						a bug
 */
native NavArea GetNearestNavArea(const float pos[3], float distance = 100.0, int flags = GetNavFlag_RequireGround);

/**
 * return a NavAreaSet for a given spawn location type
 *
 * @param location		see LocationType enum. each location type has a separate nav area set, each generated differently
 * @param class			what ZombieClass to use for generating the set
 *
 * @return 				the collected nav area set. see NavAreaSet methodmap
 *
 * @warning				LocationType_Null isn't a valid location type. server will crash if you change location to that
 *
 * @note				each location type's nav area set is persistent, and only regenerate after an
 * 						internal timer since the last generation elapses. if this is called on a
 * 						location too soon since the last time, it will skip regenerating it and
 * 						the spawnAreas set will be the same as the last time.
 */
native NavAreaSet CollectSpawnAreas(LocationType location, ZombieClass class);

/**
 * return TheNavAreas, the set containing all nav areas
 *
 * @return				the set of all areas. see NavAreaSet methodmap
 */
native NavAreaSet GetAllNavAreas();

/**
 * a set containing the nav areas surrounding this player.
 *
 * @param player		client index
 *
 * @return				the set of nav areas surrounding this player
 */
native NavAreaSet GetActiveSet(int player);

/**
 * same thing as the vscript function. it forces the mob timer to 0.0, making a mob spawn
 * as soon as possible
 */
native void ResetMobTimer();

/**
 * start a new mob timer, replacing the old one. see OnStartMobTimer_* forwards to read
 * and modify the resulting timer.
 */
native void StartMobTimer();

#pragma deprecated Use GetMobTimer() instead
native float GetTimeUntilNextMob();

/**
 * get the CountdownTimer for the director's mob spawning timer
 *
 * @return 				CountdownTimer methodmap
 */
native CountdownTimer GetMobTimer();

/**
 * mob recharging is a mechanic where the size of the next mob gradually increases the more
 * time passes since the last mob. the charge resets each time a mob spawns.
 *
 * resetting means to set the next mob size to MobMinSize. as time passes, the next mob size
 * gradually increases (charges/recharges). the rate at this recharge is controlled by the
 * MobRechargeRate director variable. the MobMaxSize director variable is the max value the
 * next mob size can charge to.
 *
 * if the MobSpawnSize director variable is set, then this will always be the size of mobs,
 * overriding the size from the recharge mechanic.
 */

/**
 * manually reset the mob recharge mechanic's current charge
 */
native void ResetMobRecharge();

/**
 * get the size of the next mob size from the mob recharge mechanic
 *
 * @return				current charge. if a mob spawns now, it will be this size rounded to an integer
 */
native float GetMobRechargeSize();

/**
 * set the size of the next mob size from the mob recharge mechanic
 *
 * @param value			desired charge. if a mob spawns now, it will be this size rounded to an integer
 */
native void SetMobRechargeSize(float value);

/**
 * same thing as the vscript function ResetSpecialTimers().
 * all timers are reset to 0.0, making them spawn as soon as possible
 */
native void ResetSpecialTimers();

/**
 * start a new director script in the LocalScript scope, replacing any that may already be running.
 *
 * @param script		the name of the vscript to begin, excluding the filename extension
 */
native void BeginLocalScript(const char[] script);

/**
 * clear the LocalScript scope of any running director script
 */
native void EndLocalScript();

/**
 * calls the same function the director uses to generate spawn positions, returning the position to the pos param
 *
 * @param class			zombie class type. refer to ZClass_* enum
 * @param tries			the maximum amount of attempts to find a spawn position
 * @param pos			vector the returned position will be stored in
 * @param filterEnt		entity index to filter out during a hull trace it does to check
 * 						clearance of potential locations.
 *
 * @return 				true if a position was successfully found, false on failure
 *
 * @note				in the examples of how the game calls this, filterEnt is only ever not 0
 * 						when the spawn position is meant for a player zombie in ghost form. the
 * 						filterEnt in this case is the ghost entity.
 */
native bool GetRandomPZSpawnPosition(ZombieClass class, int tries, float pos[3], int filterEnt = 0);

/**
 * get the team number of any entity
 *
 * @param entity		entity index to get a team number of
 *
 * @return				team number. see Team_* enum from hxstocks.inc
 */
native int GetEntityTeam(int entity);

/**
 * get a vector from the g_DefaultViewVectors object
 *
 * @param vector		enum of the vector to get. ViewVector_* enums
 * @param buffer		buffer to store vector in
 */
native void GetDefaultViewVector(DefaultViewVector vector, float buffer[3]);

/**
 * check if a position is within a client's field of view (FOV)
 *
 * @param client		client whose FOV we use
 * @param pos			in-world position to check
 *
 * @return				true if it's in their field of view, false otherwise
 *
 * @note				it only does what it says. distance and obstructions won't
 * 						make it false
 */
native bool IsInFieldOfView(int client, const float pos[3]);

/**
 * check if a position is hidden in a client's fog
 *
 * @param client		check using the fog for this client
 * @param pos			in-world position to check
 *
 * @return				true if the position is in this player's fog
 */
native bool IsHiddenByFog(int client, const float pos[3]);

/**
 * check if a position is visible to a client
 *
 * @param client		the client who can or can not see the position
 * @param pos			in-world position to check
 * @param range			if it's > 0.0, always return false for clients beyond this range from the position.
 * @param nav			if Visibility_IgnoreObsucred flag is absent, then this nav area's spawn attributes are used
 * 						for the obscured check.
 * @param flags			see Visibility_* enums.
 * @param allowNoNav	if nav param is Address_Null, then this param determines if we should get a nav from the pos
 * 						using GetNearestNavArea (100.0 range, GetNavFlag_RequireGround). set to true to disable this
 * 						behaviour.
 *
 * @return				true if pos is visible to the client, false otherwise
 *
 * @note				Visibility_IgnoreObscured flag, nav param, and allowNoNav param are all relevant for a single
 * 						check in the function only: returning false on areas marked as OBSCURED. if you don't care for
 * 						that check, ignore those options
 * @note				if the client's distance from the position is <= nav_obscure_range convar,
 * 						then the OBSCURED flag is ignored always.
 * @note				positions hidden by the client's fog will never be considered visible
 */
native bool IsVisibleToClient(int client, const float pos[3], float range = 0.0, NavArea nav = NavArea_Null, int flags = Visibility_AnyFOV, bool allowNoNav = true);

/**
 * check if a position is visible to any client of a team.
 * wrapper function of IsVisibleToClient
 *
 * @param team			the team of clients who can or can not see the position
 * @param pos			in-world position to check
 * @param range			if it's > 0.0, always return false for clients beyond this range from the position.
 * @param nav			if Visibility_IgnoreObsucred flag is absent, then this nav area's spawn attributes are used
 * 						for the obscured check.
 * @param flags			see Visibility_* enums.
 * @param allowNoNav	if nav param is Address_Null, then this param determines if we should get a nav from the pos
 * 						using GetNearestNavArea (100.0 range, GetNavFlag_RequireGround). set to true to disable this
 * 						behaviour.
 * @param humansOnly	only check visibility for the humans of this team
 *
 * @return				true if pos is visible to any client on the team, false otherwise
 *
 * @note				Visibility_IgnoreObscured flag, nav param, and allowNoNav param are all relevant for a single
 * 						check in the function only: returning false on areas marked as OBSCURED. if you don't care for
 * 						that check, ignore those options
 * @note				if the client's distance from the position is <= nav_obscure_range convar,
 * 						then the OBSCURED flag is ignored always.
 * @note				positions hidden by the client's fog will never be considered visible to that client
 */
native bool IsVisibleToTeam(int team, const float pos[3], float range = 0.0, NavArea nav = NavArea_Null, int flags = Visibility_AnyFOV, bool allowNoNav = true, bool humansOnly = false);

/**
 * is the server transitioning maps? this returns true both when the server itself is still
 * transitioning, and when it's waiting for connected players to finish transitioning
 *
 * @return				true if in transition, false otherwise
 */
native bool IsInTransition();

/**
 * are challenge mode exclusive director script variables allowed?
 * variables such as those that have the cm_ prefix.
 *
 * @return				true if these variables are taking effect
 */
native bool AreChallengeModeScriptVariablesAllowed();

/**
 * is this position behind an active info_zombie_border entity?
 *
 * @param pos			position in world to check
 *
 * @return				true if it's behind an active zombie border
 */
native bool IsBehindZombieBorder(const float pos[3]);

/**
 * given a position and nav area, check if a zombie is allowed to spawn here.
 *
 * @param pos			position to check
 * @param nav			nav area containing the position
 * @param class			zombie class. minimal impact on result
 * @param filterEnt		an entity to pass-through for a hull trace done to check clearance.
 * 						vanilla uses this for random relocation of ghosts, setting it to the
 * 						ghost's entity.
 *
 * @return				true if the location is suitable for a spawn, false otherwise
 *
 * @note				don't stress over passing a "correct" ZombieClass. if it's not ZClass_Common,
 * 						then nav areas with the crouch base flag always return false. ZClass_Survivor
 * 						always returns false. that's literally it. the hull mins/maxs are the same for
 * 						all classes.
 */
native bool CanZombieSpawnHere(const float pos[3], NavArea nav, ZombieClass class, int filterEnt = 0);

/**
 * given a position and nav area, check if a zombie is allowed to spawn here.
 * uses custom mins/maxs for the hull trace used for clearance check
 *
 * @param pos			position to check
 * @param mins			Hull minimum size.
 * @param maxs			Hull maximum size.
 * @param nav			nav area containing the position
 * @param class			zombie class. minimal impact on result
 * @param filterEnt		an entity to pass-through for the hull trace. vanilla uses this
 * 						for random relocation of ghosts, setting it to the ghost's entity.
 *
 * @return				true if the location is suitable for a spawn, false otherwise
 *
 * @note				this is slower than the regular CanZombieSpawnHere native. only use if
 * 						you want to specify a custom hull. default hull is the ViewVector_Standing*
 * 						vectors from GetDefaultViewVector native. using a bigger hull can reduce
 * 						stuck spawns
 * @note				this doesn't call the internal CanZombieSpawnHere. the forwards for
 * 						OnCanZombieSpawnHere will not trigger from this native
 */
native bool CanZombieSpawnHereEx(const float pos[3], const float mins[3], const float maxs[3], NavArea nav, ZombieClass class, int filterEnt = 0);

/**
 * added the below trace ray wrapper stuff to make recreating internal trace operations easier and
 * accurate to how it's done by the game.
 * for practical usecases where staying consistent with exactly how the game does it isn't important,
 * it may still be preferable to use only your own custom filter.
 * CTraceFilterSimple primarily filters out (allow pass-through) entities that are determined to have
 * no collision with the provided collision group and contents mask.
 *
 * it isn't fully reliable for traces that filter out entities based on what a player is expected to
 * collide with. for example, env_player_blocker entities often collide with players, yet this filter
 * will always let the trace pass-through. interestingly, the game relies on this filter for
 * checking clearance for zombie spawns. in theory, a zombie can spawn stuck in one of these "blocker"
 * entities. i haven't dug too deep into how the collision group and content mask are used to determine
 * collision, but i suspect the pass through for these blocker entities is a bug. (can't say with
 * complete certainty with current knowledge).
 */

/**
 * TR_TraceRayFilterEx from sdktools_trace, but with a filter callback that wraps an SDKCall to the game's
 * CTraceFilterSimple::ShouldHitEntity, and an optional custom callback from your plugin (only calls if the
 * SDKCall returned true).
 *
 * @param pos				Starting position of the ray.
 * @param vec				Depending on RayType, it will be used as the ending
 * 							point, or the direction angle.
 * @param mask				Trace flags.
 * @param rayType			RayType_* enum from sdktools_trace.inc. Method to calculate the ray direction.
 * @param entity			pass-through entity CTraceFilterSimple will use
 * @param collisionGroup	CollisionGroup_* enum. CTraceFilterSimple will use this to filter some
 * 							entities based on how they interact with this collision group
 * @param extraFilter		TraceEntityFilter typeset from sdktools_trace.inc. Function to use as a filter
 * 							for entities that returned true in CTraceFilterSimple::ShouldHitEntity. Set to
 * 							INVALID_FUNCTION to only use CTraceFilterSimple's filtering
 * @param data				Arbitrary data value to pass through to the extraFilter function.
 *
 * @return					Ray trace handle from sdktools_trace.inc, which must be closed via CloseHandle().
 *
 * @note					TraceType isn't available to set because CTraceFilterSimple is meant to have it
 * 							hardcoded to TRACE_EVERYTHING
 */
native Handle TR_TraceRayFilterSimple(const float pos[3], const float vec[3], int mask, any rayType, int entity, CollisionGroup collisionGroup, Function extraFilter = INVALID_FUNCTION, any data = 0);

/**
 * TR_TraceHullFilterEx from sdktools_trace, but with a filter callback that wraps an SDKCall to the game's
 * CTraceFilterSimple::ShouldHitEntity, and an optional custom callback from your plugin (only calls if the
 * SDKCall returned true).
 *
 * @param pos				Starting position of the ray.
 * @param vec				Ending position of the ray.
 * @param mins				Hull minimum size.
 * @param maxs				Hull maximum size.
 * @param mask				Trace flags.
 * @param entity			pass-through entity CTraceFilterSimple will use
 * @param collisionGroup	CollisionGroup_* enum. CTraceFilterSimple will use this to filter some
 * 							entities based on how they interact with this collision group
 * @param extraFilter		TraceEntityFilter typeset from sdktools_trace.inc. Function to use as a filter
 * 							for entities that returned true in CTraceFilterSimple::ShouldHitEntity. Set to
 * 							INVALID_FUNCTION to only use CTraceFilterSimple's filtering
 * @param data				Arbitrary data value to pass through to the extraFilter function.
 *
 * @return					Ray trace handle from sdktools_trace.inc, which must be closed via CloseHandle().
 *
 * @note					TraceType isn't available to set because CTraceFilterSimple is meant to have it
 * 							hardcoded to TRACE_EVERYTHING
 */
native Handle TR_TraceHullFilterSimple(const float pos[3], const float vec[3], const float mins[3], const float maxs[3], int mask, int entity, int collisionGroup, Function extraFilter = INVALID_FUNCTION, any data = 0);

/**
 * force a client to go afk/idle
 *
 * @param client			client to make idle
 * @param notify			should we send the "Player is now idle." user message?
 *
 * @note					more direct than go_away_from_keyboard command. can make players idle
 * 							under any restriction
 */
native void GoAwayFromKeyboard(int client, bool notify = true);

/**
 * get the CInferno address of this entity
 *
 * @param entity			index of an entity of one of one of the following classes:
 * 							inferno, insect_swarm, fire_cracker_blast
 */
native Inferno GetInferno(int entity);

/**
 * get a player's current punch angle
 *
 * @param client			client index of player to get punch angle of
 * @param buffer			store punch angle QAngle vector to this buffer
 */
native void GetPunchAngle(int client, float buffer[3]);

/**
 * set a new punch angle for this player
 *
 * @param client			client index of player to set punch angle for
 * @param value				QAngle vector for the new punch angle
 */
native void SetPunchAngle(int client, const float value[3]);

/**
 * set a new timescale. abruptly sets with no smoothing. sets it directly without using
 * func_timescale entity
 *
 * @param value				new timescale. 1.0 is normal speed
 * @param client			if true, inform connected clients of the change. false means we
 * 							avoid the client side effects of timescale changes
 */
native void SetTimescale(float value, bool client = true);

/**
 * forcefully display the server's "Message of the Day" to a client
 *
 * @param client			client to show MOTD to
 */
native void ShowMOTD(int client);

/**
 * forcefully display the server's hostfile banner to a client
 *
 * @param client			client to show host banner to
 */
native void ShowHostBanner(int client);

/**
 * get enum for which survivor character this client is
 *
 * @param client			survivor client to check
 *
 * @return					Survivor_* enums. characters from l4d1 share enums with l4d2 characters
 */
native SurvivorCharacter GetSurvivorCharacter(int client);

/**
 * get which cast of survivors the game is currently using
 *
 * @return					1 for L4D1 survivors, 2 for L4D2 survivors
 */
native int GetSurvivorSet();

/**
 * get the survivor name (appropriate to current survivor set) of a SurvivorCharacter enum
 *
 * @param character			Survivor_* enum
 * @param buffer			buffer to store survivor name in
 * @param bufferLen			length of the buffer
 */
native void GetSurvivorCharacterName(SurvivorCharacter character, char[] buffer, int bufferLen);

/**
 * get the SurvivorCharacter enum from a survivor name
 *
 * @param name				survivor name
 *
 * @return					Survivor_* enum
 */
native SurvivorCharacter GetSurvivorCharacterFromName(const char[] name);

/**
 * add a survivor bot in the same way the director adds one
 *
 * @param character			Survivor_* enum for survivor to add. Survivor_Random is accepted here
 *
 * @return					client index of survivor bot on success, -1 on failure
 *
 * @note					the code this calls ensures no duplicate survivors. if you
 * 							try adding a survivor who is already in the game, then
 * 							it will fallback to adding a random survivor (picking from
 * 							those not in the game yet)
 */
native int AddSurvivorBot(SurvivorCharacter character);

/**
 * check if a player's flashlight is on
 *
 * @param client			client index of player to check
 *
 * @return					true if their flashlight is on, false if it's off
 */
native bool FlashlightIsOn(int client);

/**
 * turn on a player's flashlight
 *
 * @param client			client index whose flashlight to turn on
 * @param playSound			should we emit the Player.FlashlightOn sound?
 */
native void FlashlightTurnOn(int client, bool playSound = true);

/**
 * turn off a player's flashlight
 *
 * @param client			client index whose flashlight to turn off
 * @param playSound			should we emit the Player.FlashlightOff sound?
 */
native void FlashlightTurnOff(int client, bool playSound = true);

/**
 * get the weapon ID enum of a weapon
 *
 * @param weapon			entity index of the weapon
 *
 * @return					WeaponID enum
 */
native any GetWeaponID(int weapon);

/**
 * a timestamp of when the player was last alive
 *
 * @param client			client index of player to check
 *
 * @return					time as a float
 */
native float GetTimeLastAlive(int client);

/**
 * set the timestamp of when this player was last alive. some
 * systems such as determining when a dead survivor can become
 * rescuable use this to measure how long they've been dead.
 *
 * @param client			client index of player to set it for
 * @param time				float of time to set
 */
native void SetTimeLastAlive(int client, float time);

/**
 * force a client to switch to a weapon slot. does nothing if
 * the specified slot has no weapon.
 *
 * @param client			client index to make switch weapon
 * @param slot				WeaponSlot_* enum
 *
 * @return					true on success, false on failure
 */
native bool SwitchWeapon(int client, int slot);

/**
 * a survivor's secondary weapon is detached and set as their
 * "restore secondary weapon" upon dying or incapping. the weapon
 * is later restored (on revive, etc). this native will get the
 * entity index of this weapon.
 *
 * @param client			client index of survivor
 *
 * @return					entity index of the weapon. will be an invalid entity if none exist
 */
native int GetRestoreSecondaryWeapon(int client);

/**
 * a survivor's secondary weapon is detached and set as their
 * "restore secondary weapon" upon dying or incapping. the weapon
 * is later restored (on revive, etc). this native will set this
 * weapon.
 *
 * @param client			client index of survivor
 * @param weapon			entity index of weapon
 *
 * @note					you can set it to INVALID_ENT_REFERENCE to remove it.
 * 							the entity won't be deleted, you must do that separately
 * @note					on death or incap, what you set can be overwritten from
 * 							the game setting it.
 */
native void SetRestoreSecondaryWeapon(int client, int weapon);

/**
 * get the max possible reserve ammo for this ammo type
 *
 * @param type				Ammo_* enum
 *
 * @return					max possible reserve ammo as int
 */
native int GetMaxReserveAmmo(AmmoType type);

/**
 * get the max possible clip ammo for this weapon
 *
 * @param weapon			entity index of the weapon
 *
 * @return					max possible clip ammo as int
 */
native int GetMaxMagazineAmmo(int weapon);

/**
 * check if an entity is alive. works on non-client entities
 *
 * @param entity			entity index to check
 *
 * @return					true if entity is alive, false if dead
 */
native bool IsEntityAlive(int entity);

/**
 * get last HitGroup this character was shot in
 *
 * @param character			entity index of character (player, infected, witch)
 *
 * @return					HitGroup_* enum
 */
native HitGroup GetLastHitGroup(int character);

/**
 * vocalize a gamesound from a player
 *
 * @param client		client index of player who will vocalize
 * @param gameSound		name of the game sound, as seen in scripts/game_sounds_* script files
 * @param cooldown		cooldown for when the client can vocalize again
 * @param durationAI	duration of time AI will recognize the sound
 *
 * @note				cooldown isn't strictly enforced. checking the cooldown timer set is handled
 * 						in parent functions. it could be ignored in some scenarios.
 */
native void Vocalize(int client, const char[] gameSound, float cooldown = 0.0, float durationAI = 0.0);

#pragma deprecated Use GetVocalizeTimer() instead
native float GetVocalizeCooldown(int client);

#pragma deprecated Use GetVocalizeTimer() instead
native void SetVocalizeCooldown(int client, float cooldown);

/**
 * timer used for delaying some voice sounds on clients
 *
 * @param client		client to get timer of
 *
 * @return				CountdownTimer methodmap
 */
native CountdownTimer GetVocalizeTimer(int client);

/**
 * spawn a special infected of any class at the pos/angles
 *
 * @param class			ZombieClass of infected to spawn
 * @param pos			position vector
 * @param angles		QAngles vector
 *
 * @return				entity index of the spawned special infected
 */
native int SpawnSpecial(ZombieClass class, const float pos[3], const float angles[3] = NULL_VECTOR);

/**
 * spawn a common infected
 *
 * @param pos			origin vector in world
 * @param angles		QAngles vector
 * @param type			type of common spawn, see CommonSpawn_* enums
 *
 * @return				entity index of the spawn common infected
 *
 * @note				it won't correct position if it's somewhere a common can't move
 */
native int SpawnCommon(const float pos[3], const float angles[3] = NULL_VECTOR, CommonSpawnType type = CommonSpawn_Wanderer);

/**
 * get int value of director script variable
 *
 * @param scriptVar		name of variable
 * @param defaultVal	default value if nothing was found for that variable
 *
 * @return				int value
 */
native int GetScriptValueInt(const char[] scriptVar, int defaultVal);

/**
 * get float value of director script variable
 *
 * @param scriptVar		name of variable
 * @param defaultVal	default value if nothing was found for that variable
 *
 * @return				float value
 */
native float GetScriptValueFloat(const char[] scriptVar, float defaultVal);

/**
 * get WaterSlowsMovement game rule
 *
 * @return				true if water slows movement, false otherwise
 */
native bool DoesWaterSlowMovement();

/**
 * get client's current FOV
 *
 * @param				client index
 *
 * @return				fov
 */
native int GetFOV(int client);

/**
 * get a record from the list of saved human player data.
 * use GetSavedPlayerCount() to get amount of records in this list.
 *
 * @param index			index in the list
 *
 * @return				see SavedPlayer methodmap
 */
native SavedPlayer GetSavedPlayer(int index);

/**
 * get total amount of records in the list of saved human player data
 *
 * @return				total indices in the list
 */
native int GetSavedPlayerCount();

/**
 * get a record from the list of saved survivor bot player data.
 * use GetSavedSurvivorBotCount() to get amount of records in this list.
 *
 * @param index			index in the list
 *
 * @return				see SavedPlayer methodmap
 */
native SavedPlayer GetSavedSurvivorBot(int index);

/**
 * get total amount of records in the list of saved survivor bot player data
 *
 * @return				total indices in the list
 */
native int GetSavedSurvivorBotCount();

/**
 * get current reservation cookie
 *
 * @param buffer		store int64 cookie to this
 */
native void GetReservationCookie(int buffer[2]);

/**
 * get KeyValues info of a gamemode
 *
 * @param gamemode		name of gamemode, as it's written for mp_gamemode convar.
 * 						NULL_STRING means use current mp_gamemode value
 *
 * @return				GameModeInfo methodmap. also see KeyValues methodmap
 */
native GameModeInfo GetGameModeInfo(const char[] gamemode = NULL_STRING);

/**
 * get current hibernation state of the server
 *
 * @return				true if hibernating, false if not.
 */
native bool GetHibernationState();

/**
 * get the FOV this gun should zoom to
 *
 * @param weapon		entity index of weapon
 *
 * @return				FOV as int
 */
native int GetZoomLevel(int weapon);

/**
 * set FOV with a smoothing transtion for a client
 *
 * @param client		client index of player to affect
 * @param targetFOV		smooth to this value. set to 0 for default
 * @param duration		duration for smoothing transition
 * @param startFOV		smooth from this value. 0 for current
 * @param owner			zoom owner entity. 0 to use this client (most common)
 *
 * @return				true if success, false if failure
 */
native bool SetFOV(int client, int targetFOV = 0, float duration = 0.0, int startFOV = 0, int owner = 0);

/**
 * check if this ammo type can carry an infinite amount of ammo
 *
 * @param ammoType		Ammo_* enum
 *
 * @return				true if inifnite ammo, false otherwise
 */
native bool IsAmmoTypeInfinite(AmmoType ammoType);

/**
 * remove an amount of ammo from a client's reserve pool.
 *
 * @param client		client index to remove ammo from
 * @param amount		amount to remove
 * @param ammoType		ammo pool to remove from
 *
 * @note				same as directly setting m_iAmmo netprop, except it will also trigger EntityHook_RemoveAmmo
 */
native void RemoveAmmo(int client, int amount, AmmoType ammoType);

/**
 * get activity of this weapon's deploy animation
 *
 * @param weapon		entity index of weapon
 *
 * @return				activity
 */
native int GetDeployActivity(int weapon);

/**
 * select a sequence mapped to this activity. if there are more than 1, pick through weighted RNG
 *
 * @param entity		index of entity with animation
 * @param activity		activity enum the sequence must be mapped to
 *
 * @return				sequence as an int. -1 if none found
 */
native int SelectWeightedSequence(int entity, int activity);

/**
 * get all sequences mapped to this activity.
 *
 * @param entity		index of entity with animation
 * @param activity		activity enum the sequences must be mapped to
 * @param seqTotal		size of the SequenceTupleList returned
 * @param weightTotal	sum of weights of all sequences in the returned SequenceTupleList
 *
 * @return				SequenceTupleList methodmap, SequenceTupleList_Null if none found
 */
native SequenceTupleList GetSequencesForActivity(int entity, int activity, int &seqTotal = 0, int &weightTotal = 0);

/**
 * get all sequences for this entity's model
 *
 * @param entity		index of entity with animation
 * @param seqTotal		size of the SequenceTupleList returned
 *
 * @return				SequenceTupleList methodmap, SequenceTupleList_Null if none found
 */
native SequenceTupleList GetSequences(int entity, int &seqTotal = 0);

/**
 * get duration in seconds of an entity's animation
 *
 * @param entity		index of entity with animation
 * @param sequence		sequence int of the animation to check
 *
 * @return				duration in seconds
 *
 * @note				use GetWeightedSequence or GetSequences to convert activity enum to sequence int
 */
native float GetSequenceDuration(int entity, int sequence);

#pragma deprecated Use GetScenarioRestartTimer() instead
native float GetScenarioRestartTime();

#pragma deprecated Use GetScenarioRestartTimer() instead
native void SetScenarioRestartTime(float value = 0.0);

/**
 * if this timer is started, the director will restart the scenario when it's elapsed
 *
 * @return				CountdownTimer methodmap
 */
native CountdownTimer GetScenarioRestartTimer();

/**************
 * Methodmaps
 *************/

enum SequenceTupleList
{
	SequenceTupleList_Null = 0
};

/** GetSequencesForActivity, and GetSequences native return value. they also return list size */
methodmap SequenceTupleList
{
	/**
	 * @param index		element in array
	 *
	 * @return			SequenceTuple methodmap. will be garbage value if index is out of bounds
	 */
	public SequenceTuple Get(int index)
	{
		return view_as<SequenceTuple>(this) + view_as<SequenceTuple>(index * 4);
	}
}

methodmap SequenceTuple
{
	/** identifier for a sequence/animation of a model. used as input for things like GetSequenceDuration() */
	property int sequence
	{
		public get()
		{
			return LoadFromAddress(view_as<Address>(this), NumberType_Int16);
		}
	}

	/** for multiple sequences mapped to the same activity, the weight is used to randomly choose one.
	 * weight total for a given activity is acquired from GetSequencesForActivity native */
	property int weight
	{
		public get()
		{
			return LoadFromAddress(view_as<Address>(this) + view_as<Address>(2), NumberType_Int16);
		}
	}
}

methodmap NavLadder
{
	/**
	 * the func_simpleladder entity index associated with this NavLadder.
	 * not all NavLadders have one, in that case the entity will be -1
	 */
	property int entity
	{
		public native get();
	}

	/**
	 * team number. the ladder's team determines the team players must
	 * be on to climb the ladder. Team_Unassigned means any team can climb it.
	 *
	 * @error			this.entity is an invalid entity
	 */
	property int team
	{
		public native get();
	}

	/**
	 * the vertical length of the ladder
	 */
	property float length
	{
		public native get();
	}

	/**
	 * the address of this NavLadder
	 */
	property Address address
	{
		public native get();
	}

	/**
	 * check if a given team can climb this ladder
	 *
	 * @param team		Team_* enum
	 *
	 * @return			true if they can use the ladder, false if not
	 */
	public native bool IsUsableByTeam(int team);

	/**
	 * the in-world position of the bottom of the ladder
	 *
	 * @param buffer	store its origin in this buffer
	 */
	public native void GetBottomOrigin(float buffer[3]);

	/**
	 * the in-world position of the top of the ladder
	 *
	 * @param buffer	store its origin in this buffer
	 */
	public native void GetTopOrigin(float buffer[3]);

	/**
	 * get the NavArea address connected to this ladder's bottom
	 *
	 * @return 			address as a NavArea methodmap
	 */
	public native NavArea GetBottomArea();

	/**
	 * get the first found NavArea address connected to this ladder's top
	 *
	 * @return 			address as a NavArea methodmap
	 *
	 * @note			unlike a ladder's bottom, its top has more than 1 connection type.
	 * 					more than one can be connected to an area. this native will only
	 * 					return the first valid area found when iterating these connections.
	 * 					see NavLadder.GetTopAreaEx and NavLadder.GetConnection if you need
	 * 					to be precise
	 */
	public native NavArea GetTopArea();

	/**
	 * get the first found NavArea adddress connected to this ladder's top
	 * starting from a given index
	 *
	 * @param area			if found, store the nav area to this
	 * @param startIndex	start searching from this index + 1. see the
	 * 						LadderConnection enum. connections to top are only
	 * 						0 through 4. set to -1 to search from start
	 *
	 * @return				the index where a connected area was found. will
	 * 						be -1 if no area was found
	 */
	public native int GetTopAreaEx(NavArea &area, any startIndex = -1);

	/**
	 * get the nav area connected by the giveen connection type
	 *
	 * @param connection	see LadderConnection enum. return an area connected to this connection
	 *
	 * @return				NavArea address or 0 if no area is connected via this connection
	 */
	public native NavArea GetConnection(LadderConnection connection);
}

enum NavArea
{
	NavArea_Null = 0	// so that we can use 0 without the annoying compiler warning
};

methodmap NavArea
{
	/**
	 * bitfield. refer to the NavBase_* enums
	 */
	property int baseAttributes
	{
		public native get();
		public native set(int value);
	}

	/**
	 * bitfield. refer to the NavSpawn_* enums
	 */
	property int spawnAttributes
	{
		public native get();
		public native set(int value);
	}

	/**
	 * unique integer ID of this area
	 */
	property int id
	{
		public native get();
	}

	/**
	 * entity index of an elevator connected to this NavArea. -1 if invalid or doesn't exist
	 */
	property int elevator
	{
		public native get();
	}

	/**
	 * this NavArea's address
	 */
	property Address address
	{
		public native get();
	}

	/**
	 * the size along the X axis
	 */
	property float sizeX
	{
		public native get();
	}

	/**
	 * the size along the Y axis
	 */
	property float sizeY
	{
		public native get();
	}

	/**
	 * the size along the Z axis
	 */
	property float sizeZ
	{
		public native get();
	}

	/**
	 * when wandering commons are looking to spawn, the game iterates through
	 * active nav areas and for each area it finds with a population density > 0,
	 * it will attempt to spawn as many commons as this property value. 0 means
	 * no wandering commons can spawn in this area.
	 */
	property int populationDensity
	{
		public native get();
		public native set(int value);
	}

	/**
	 * Get the vector position of the center of this nav area
	 *
	 * @param buffer		vector buffer to store center position in
	 */
	public native void GetCenter(float buffer[3]);

	/**
	 * Get the vector position of a corner of this nav area
	 *
	 * @param buffer		vector buffer to store corner position in
	 * @param corner		NavCorner_* enum for specifying which corner
	 */
	public native void GetCorner(float buffer[3], NavCorner corner = NavCorner_NegativeNegative);

	/**
	 * given an X and Y coordinate within the nav area, return the corresponding Z coordinate
	 *
	 * @param x				X coordinate [0]
	 * @param y				Y coordinate [1]
	 *
	 * @return				Z coordinate [2]
	 */
	public native float GetZ(float x, float y);

	/**
	 * Get the 'flow' value of this nav area.
	 *
	 * @param type			FlowType_* enum.
	 *
	 * @return				the flow.
	 *
	 * @note				a flow value of -9999.0 means it never got calculated
	 */
	public native float GetFlow(FlowType type = FlowType_Progress);

	/**
	 * out of the connected areas traversable to survivors, return the next step in the shortest
	 * path towards the ending saferoom. same logic as how the ESCAPE_ROUTE attribute is given
	 * to nav areas, except it's freshly computed from any area
	 *
	 * @return				the nav area that's the biggest step towards the end saferoom.
	 * 						NavArea_Null if there is no "next step"
	 *
	 * @note				at the end of some maps, there can be nav areas which both return
	 * 						each other. be wary of this if using it in an infinite loop.
	 */
	public native NavArea GetNextEscapeStep();

	/**
	 * out of the connected areas traversable to survivors, return the next step in the shortest
	 * path towards the ending saferoom. same logic as how the ESCAPE_ROUTE attribute is given
	 * to nav areas, except it's freshly computed from any area.
	 * the Ex version let's you get the TraverseType
	 *
	 * @param type			TraverseType_* enum. represents what kind of traversal is required to take this step
	 *
	 * @return				the nav area that's the biggest step towards the end saferoom
	 * 						NavArea_Null if there is no "next step"
	 *
	 * @note				at the end of some maps, there can be nav areas which both return
	 * 						each other. be wary of this if using it in an infinite loop.
	 *
	 * @note				slightly slower than NavArea.GetNextEscapeStep. only use this if
	 * 						you need the traverse type.
	 */
	public native NavArea GetNextEscapeStepEx(TraverseType &type);

	/**
	 * returns the difference of an adjacent nav area's Z coordinate and
	 * the Z of this nav area.
	 *
	 * @param externalNav	a NavArea address that isn't this
	 *
	 * @return				the z delta.
	 *
	 * @note				the exact value used as each area's Z coordinate depends on how flat they are
	 * 						and their orientation to eachother. Using this is preferred over comparing the
	 * 						Z of the same fixed points (like their centers).
	 */
	public native float GetZDeltaToArea(NavArea externalNav);

	/**
	 * is this nav area connected to another nav area in a given direction
	 *
	 * @param nav			target nav to check connected status
	 * @param direction		NavDir_* enum. check only this direction for connected check
	 *
	 * @return				true if connected, false if not
	 *
	 * @note				NavDir_All is a shortcut to check in all directions
	 */
	public native bool IsConnected(NavArea nav, NavDir direction = NavDir_All);

	/**
	 * does this nav area have a blocker for the given team?
	 *
	 * @param team			team to check blockers for
	 * @param flow			check if flow is blocked
	 *
	 * @return				true if blocked, false otherwise
	 */
	public native bool IsBlocked(int team, bool flow = false);

	/**
	 * is this nav area behind an active info_zombie_border entity?
	 *
	 * @return				true if it's behind an active zombie border
	 */
	public native bool IsBehindZombieBorder();

	/******************************
	 * Areas connected by elevator
	 *****************************/

	/**
	 * get the total amount of other nav areas connected to this one by an elevator
	 *
	 * @return				total elevator connected areas
	 */
	public native int GetElevatorAreaCount();

	/**
	 * get a NavArea connected to this one by an elevator
	 *
	 * @param index			the n'th NavArea in the list of elevator connected areas
	 *
	 * @return				a NavArea address
	 */
	public native NavArea GetElevatorArea(int index);

	/**
	 * get a list of NavAreas connected by an elevator
	 *
	 * @return				the list as a newly created ArrayList
	 *
	 * @note				see NavArea.GetElevatorAreasEx if you want to append the
	 * 						areas to an existing list
	 */
	public native ArrayList GetElevatorAreas();

	/**
	 * get a list of NavAreas connected by an elevator
	 *
	 * @param list			an ArrayList to append connected areas to
	 *
	 * @return				number of elements written to the list
	 *
	 * @note				see NavArea.GetElevatorAreas if you don't want to create
	 * 						your own ArrayList beforehand
	 */
	public native int GetElevatorAreasEx(ArrayList list);

	/********************
	 * Connected ladders
	 ********************/

	/**
	 * return how many ladders are connected to this nav area that climb
	 * in the specified direction
	 *
	 * @param direction		LadderDir_Up or LadderDir_Down. up counts ladders whose bottoms are connected to this nav area, vice versa for down
	 *
	 * @return				total connected ladders in this climbing direction
	 */
	public native int GetLadderCount(LadderDir direction);

	/**
	 * get a NavLadder address from a ladder list.
	 * there is one ladder list per climbing direction, so specify the list
	 * by direction and an index for the element in that list
	 *
	 * @param direction		LadderDir_Up or LadderDir_Down. the ladder list to pull from
	 * @param index			element in the ladder list to return
	 *
	 * @return				NavLadder address. see NavLadder methodmap
	 */
	public native NavLadder GetLadder(LadderDir direction, int index);

	/**
	 * get a list of connected ladders returned as an ArrayList.
	 * there is one ladder list per climbing direction, so specify the list
	 * by direction.
	 *
	 * @param direction		LadderDir_Up or LadderDir_Down. the ladder list to return
	 *
	 * @return				an ArrayList created by the native that contains the full ladder list
	 *
	 * @note				if you want to append the ladder list's contents to an existing
	 * 						ArrayList, see NavArea.GetLaddersEx
	 */
	public native ArrayList GetLadders(LadderDir direction);

	/**
	 * append a list of connected ladders to the provided ArrayList.
	 * there is one ladder list per climbing direction, so specify the list
	 * by direction.
	 *
	 * @param direction		LadderDir_Up or LadderDir_Down. the ladder list to append
	 *
	 * @return				how many cells were written to the ArrayList
	 *
	 * @note				you can use NavArea.GetLadders as a shortcut to create an
	 * 						ArrayList through the native if it's a new one you need
	 */
	public native int GetLaddersEx(LadderDir direction, ArrayList list);

	/***********************
	 * Adjacent areas
	 **********************/

	/**
	 * Get the total amount of areas adjacent to this nav area in the given direction
	 *
	 * @param direction		total areas in this direction. NavDir_* enum
	 *
	 * @return				total areas as an integer
	 *
	 * @note				NavDir_All is a shortcut to get the sum of every direction's total
	 */
	public native int GetAdjacentCount(NavDir direction = NavDir_All);

	/**
	 * Get the NavArea at a given index in the specified direction's adjacent area list
	 *
	 * @param direction		check NavDir_* enums. refers to areas adjacent to the nav area's edge facing this direction
	 * @param index			the n'th adjacent nav area in this direction
	 *
	 * @return				the area as a NavArea address
	 *
	 * @error				NavDir_All is not a direction, and will cause errors
	 */
	public native NavArea GetAdjacentArea(NavDir direction, int index);

	/**
	 * Get a list of nav areas adjacent to this nav area in the given direction.
	 * This native will create a new ArrayList and return it. to append the adjacent
	 * areas to an existing ArrayList, use NavArea.GetAdjacentAreasEx
	 *
	 * @param direction		NavDir_* enum. get a list of all NavAreas adjacent to this NavArea in this direction
	 *
	 * @return				an ArrayList containing the collected list
	 *
	 * @note				NavDir_All is a shortcut to get a list of adjacent areas in all directions
	 */
	public native ArrayList GetAdjacentAreas(NavDir direction = NavDir_All);

	/**
	 * Get a list of nav areas adjacent to this nav area in the given direction.
	 * This native requires you to pass an existing ArrayList for it to append to.
	 * Use NavArea.GetAdjacentAreas to have the ArrayList created and returned by
	 * the native.
	 *
	 * @param direction		NavDir_* enum. get a list of all NavAreas adjacent to this NavArea in this direction
	 *
	 * @return				the amount of areas written to the list
	 *
	 * @note				NavDir_All is a shortcut to get a list of adjacent areas in all directions
	 */
	public native int GetAdjacentAreasEx(ArrayList list, NavDir direction = NavDir_All);

	/**
	 * Get a random adjacent area in a given direction
	 *
	 * @param direction		NavDir_* enum. the compass direction to pick a random adjacent area from
	 *
	 * @return				Address_Null if there are no adjacent areas in this direction, or a NavArea address if successful
	 *
	 * @note				NavDir_All is a shortcut to pull a random area from any direction
	 */
	public native NavArea GetRandomAdjacentArea(NavDir direction = NavDir_All);

	/***************************
	 * Incoming connected areas
	 **************************/

	/**
	 * Get the total amount of areas connected to this area via an incoming connection
	 *
	 * @param direction		total areas in this direction. NavDir_* enum
	 *
	 * @return				total areas as an integer
	 *
	 * @note				NavDir_All is a shortcut to get the sum of every direction's total
	 */
	public native int GetIncomingCount(NavDir direction = NavDir_All);

	/**
	 * Get the NavArea at a given index in the specified direction's incoming connection list
	 *
	 * @param direction		check NavDir_* enums
	 * @param index			the n'th incoming connection in this direction
	 *
	 * @return				the area as a NavArea address
	 *
	 * @error				NavDir_All is not a direction, and will cause errors
	 */
	public native NavArea GetIncomingConnection(NavDir direction, int index);

	/**
	 * Get a list of incoming connections to this nav area in the given direction.
	 * This native will create a new ArrayList and return it. to append the incoming
	 * connections to an existing ArrayList, use NavArea.GetIncomingConnectionsEx
	 *
	 * @param direction		NavDir_* enum. get a list of all incoming connections to this NavArea in this direction
	 *
	 * @return				an ArrayList containing the collected list
	 *
	 * @note				NavDir_All is a shortcut to get a list of incoming connections in all directions
	 */
	public native ArrayList GetIncomingConnections(NavDir direction = NavDir_All);

	/**
	 * Get a list of incoming connections to this nav area in the given direction.
	 * This native requires you to pass an existing ArrayList for it to append to.
	 * Use NavArea.GetIncomingConnections to have the ArrayList created and returned by
	 * the native.
	 *
	 * @param direction		NavDir_* enum. get a list of all incoming connections to this NavArea in this direction
	 *
	 * @return				the amount of areas written to the list
	 *
	 * @note				NavDir_All is a shortcut to get a list of incoming connections in all directions
	 */
	public native int GetIncomingConnectionsEx(ArrayList list, NavDir direction = NavDir_All);
}

/**
 * a collected set of nav areas.
 */
methodmap NavAreaSet
{
	/**
	 * Get a NavArea at the given index
	 *
	 * @param index		get the nav area at this index in the set
	 *
	 * @return			Address to the nav area. Check NavArea methodmap
	 */
	public native NavArea Get(int index);

	/**
	 * Set an index in the set to a given nav area
	 *
	 * @param index		index in the set to set
	 * @param nav		the NavArea
	 */
	public native void Set(int index, any nav);

	/**
	 * Convert the set into a new ArrayList
	 *
	 * @return			Handle to the created ArrayList
	 */
	public native ArrayList GetArrayList();

	/**
	 * append the set to an existing ArrayList
	 *
	 * @param			the ArrayList to append to
	 *
	 * @return			how many cells were written to the ArrayList
	 */
	public native int GetArrayListEx(ArrayList list);

	/**
	 * Override the set with the contents of a provided ArrayList
	 *
	 * @param array		Handle to the ArrayList
	 */
	public native void SetArrayList(ArrayList array);

	/**
	 * Append a new nav area to the end of the list, and increment the count by 1
	 *
	 * @param nav		the NavArea to append
	 *
	 * @return			index of the new entry
	 */
	public native int Push(NavArea nav);

	/**
	 * Remove an index, and shift every index above it down 1, and decrement count by 1
	 *
	 * @param index		index to erase
	 */
	public native void Erase(int index);

	/**
	 * Same as setting this.count to 0. clear the list of all indices
	 */
	public native void Clear();

	/**
	 * Get the index of a nav in the set matching the given nav
	 *
	 * @param nav		nav you are finding an index for
	 * @param index		index to start the search from
	 *
	 * @return			index of the first matching nav found, or -1 if no matches were found
	 */
	public native int Find(NavArea nav, int index = -1);

	/**
	 * Total amount of nav areas in the set
	 *
	 * @note			increasing the count will add the new indices initialized as 0
	 */
	property int count
	{
		public native get();
		public native set(int value);
	}
}

/**
 * CInferno address
 */
methodmap Inferno
{
	/**
	 * its entity index
	 */
	property int entity
	{
		public native get();
	}

	/**
	 * Inferno_* enum for what type of inferno it is (fire, spit, firework)
	 */
	property InfernoType type
	{
		public native get();
	}

	/**
	 * max number of flames that this inferno can spawn.
	 * has a hard cap of 64
	 */
	property int maxFlames
	{
		public native get();
		public native set(int value);
	}

	/**
	 * timestamp of when the inferno started burning
	 */
	property float startTime
	{
		public native get();
	}

	/** damage tick interval */
	property CountdownTimer damageTimer
	{
		public native get();
	}

	/** multiply damage by damageRampTimer.GetElapsedRatio */
	property CountdownTimer damageRampTimer
	{
		public native get();
	}

	/**
	 * get the lifetime flames will be created with
	 *
	 * @return				duration in seconds
	 */
	public native float GetFlameLifetime();

	/**
	 * origin of where the inferno started burning
	 *
	 * @param buffer		store origin into this buffer
	 */
	public native void GetOrigin(float buffer[3]);

	/**
	 * origin of the corner with the lowest x/y/z
	 *
	 * @param buffer		store origin into this buffer
	 */
	public native void GetMins(float buffer[3]);

	/**
	 * origin of the corner with the highest x/y/z
	 *
	 * @param buffer		store origin into this buffer
	 */
	public native void GetMaxs(float buffer[3]);

	/*************
	 * Flame List
	 ************/

	/**
	 * number of flames this inferno created as of now
	 */
	property int flameCount
	{
		public native get();
	}

	/**
	 * get a flame object from this inferno's list of flames
	 *
	 * @param index			index of the list to pull a flame from
	 *
	 * @note				index 0 is always the root flame. flames are pushed
	 * 						in the order they're created
	 */
	public native Flame GetFlame(int index);
}

/**
 * FireInfo struct
 */
methodmap Flame
{
	/**
	 * generational depth. root flame is 0, root's child flames are 1, etc
	 */
	property int depth
	{
		public native get();
		public native set(int value);
	}

	/**
	 * Flame object of this flame's parent. will be 0 if there is no parent
	 */
	property Flame parent
	{
		public native get();
	}

	/**
	 * how long we attempt to spawn new fires
	 */
	property CountdownTimer spawnLifetime
	{
		public native get();
	}

	/**
	 * lifetime of this fire
	 *
	 * @note			changing it can cause visual bugs due to clients
	 * 					expecting the original lifetime, but server side
	 * 					it will change.
	 */
	property CountdownTimer lifetime
	{
		public native get();
	}

	/**
	 * origin position of this flame
	 */
	public native void GetOrigin(float buffer[3]);

	/**
	 * normalized vector
	 */
	public native void GetDirection(float buffer[3]);
}

/**
 * a KeyValues pointer from the game's memory. same as the sourcemod one, but it's not
 * provided as a handle. the sourcemod KeyValues should be preferred over this.
 */
methodmap InternalKeyValues __nullable__
{
	/**
	 * create a new internal KeyValues object of the given name
	 *
	 * @param name			name of the keyvalue
	 *
	 * @note				delete with this.DeleteThis
	 */
	public native InternalKeyValues(const char[] name);

	/**
	 * delete this internal KeyValues object. this will recursively delete
	 * any subkeys too.
	 */
	public native void DeleteThis();

	/**
	 * raw pointer address
	 */
	property Address address
	{
		public native get();
	}

	/**
	 * get an int value from a key within
	 *
	 * @param key			subkey name, or NULL_STRING to refer to this key
	 * @param defaultVal	default value if key doesn't exist
	 *
	 * @return				value of this key
	 */
	public native int GetInt(const char[] key, int defaultVal = 0);
	/**
	 * set an int value for a key within. the key will be created
	 * if it doesn't exist.
	 *
	 * @param key			subkey name, or NULL_STRING to refer to this key
	 * @param value			value to set the key to
	 */
	public native void SetInt(const char[] key, int value);

	/**
	 * get a float value from a key within
	 *
	 * @param key			subkey name, or NULL_STRING to refer to this key
	 * @param defaultVal	default value if key doesn't exist
	 *
	 * @return				value of this key
	 */
	public native float GetFloat(const char[] key, float defaultVal = 0.0);
	/**
	 * set a float value for a key within. the key will be created
	 * if it doesn't exist.
	 *
	 * @param key			subkey name, or NULL_STRING to refer to this key
	 * @param value			value to set the key to
	 */
	public native void SetFloat(const char[] key, float value);

	/**
	 * get a vector value from a key within
	 *
	 * @param key			subkey name, or NULL_STRING to refer to this key
	 * @param buffer		buffer to store the value in
	 * @param defaultVal	default value if key doesn't exist
	 */
	public native void GetVector(const char[] key, float buffer[3], const float defaultVal[3] = {0.0, 0.0, 0.0});
	/**
	 * set a vector value for a key within. the key will be created
	 * if it doesn't exist.
	 *
	 * @param key			subkey name, or NULL_STRING to refer to this key
	 * @param value			value to set the key to
	 */
	public native void SetVector(const char[] key, const float value[3]);

	/**
	 * get a string value from a key within
	 *
	 * @param key			subkey name, or NULL_STRING to refer to this key
	 * @param buffer		buffer to store the value in
	 * @param bufferLen		length of the buffer
	 * @param defaultVal	default value if key doesn't exist
	 */
	public native void GetString(const char[] key, char[] buffer, int bufferLen, const char[] defaultVal = "");
	/**
	 * set a string value for a key within. the key will be created
	 * if it doesn't exist.
	 *
	 * @param key			subkey name, or NULL_STRING to refer to this key
	 * @param value			value to set the key to
	 */
	public native void SetString(const char[] key, const char[] value);

	/**
	 * get the name of this key. either the key in a keyvalue pair, or a section name.
	 *
	 * @param buffer		buffer to store name in
	 * @param bufferLen		length of the buffer
	 */
	public native void GetName(char[] buffer, int bufferLen);
	/**
	 * set the name of this key. either the key in a keyvalue pair, or a section name.
	 *
	 * @param value			new name
	 */
	public native void SetName(const char[] value);

	/**
	 * get the first subkey within this KeyValues node.
	 *
	 * @return				an internal KeyValues object
	 */
	public native InternalKeyValues GetFirstSubKey();

	/**
	 * get the next adjacent key from a key in the same node
	 *
	 * @return				an internal KeyValues object
	 */
	public native InternalKeyValues GetNextKey();

	/**
	 * get the KeyValues object with a key within of this name
	 *
	 * @param name			key name to look for
	 * @param create		if true, then the key will be created if it doesn't exist
	 *
	 * @return				an internal KeyValues object
	 */
	public native InternalKeyValues FindKey(const char[] key, bool create = false);

	/**
	 * create a new key within this node of the given name
	 *
	 * @param name			name for the new key
	 *
	 * @return				an internal KeyValues object
	 */
	public native InternalKeyValues CreateKey(const char[] name);

	/**
	 * remove a key within this node
	 *
	 * @param keyvalue		internal KeyValues object address of the subkey to remove
	 */
	public native void RemoveSubKey(InternalKeyValues keyvalue);

	/**
	 * dump this KeyValues node recursively to a file
	 *
	 * @param path			file path
	 *
	 * @return				true if success
	 */
	public native bool SaveToFile(const char[] path);
}

/**
 * saved players are just KeyValues. this methodmap is composed of shortcuts for a handful
 * of the keys, but not all of them. you may need to use the InternalKeyValues methods for
 * some keys.
 */
methodmap SavedPlayer < InternalKeyValues
{
	/** see Restore_* enums. state of transition process */
	property RestoreState state
	{
		public get()
		{
			return view_as<RestoreState>(this.GetInt("restoreState"));
		}
	}

	property int userid
	{
		public get()
		{
			return this.GetInt("userid");
		}
	}

	property int team
	{
		public get()
		{
			return this.GetInt("teamNumber");
		}
	}

	property int health
	{
		public get()
		{
			return this.GetInt("health");
		}
		public set(int value)
		{
			this.SetInt("health", value);
		}
	}

	/** aka temp health */
	property float healthBuffer
	{
		public get()
		{
			return this.GetFloat("healthBuffer");
		}
		public set(float value)
		{
			this.SetFloat("healthBuffer", value);
		}
	}

	property bool incapacitated
	{
		public get()
		{
			return !!this.GetInt("incapacitated");
		}
		public set(bool value)
		{
			this.SetInt("incapacitated", value ? 1 : 0);
		}
	}

	/** see Survivor_* enums */
	property SurvivorCharacter survivorCharacter
	{
		public get()
		{
			return view_as<SurvivorCharacter>(this.GetInt("character"));
		}
		public set(SurvivorCharacter value)
		{
			this.SetInt("character", view_as<int>(value));
		}
	}

	/** how many times was this player revived without getting a heal */
	property int currentReviveCount
	{
		public get()
		{
			return this.GetInt("currentReviveCount");
		}
		public set(int value)
		{
			this.SetInt("currentReviveCount", value);
		}
	}

	/** black and white? */
	property bool thirdStrike
	{
		public get()
		{
			return !!this.GetInt("thirdStrike");
		}
		public set(bool value)
		{
			this.SetInt("thirdStrike", value ? 1 : 0);
		}
	}

	property bool idle
	{
		public get()
		{
			return !!this.GetInt("idle");
		}
		public set(bool value)
		{
			this.SetInt("idle", value ? 1 : 0);
		}
	}

	/**
	 * get the player's display name
	 *
	 * @param buffer		buffer to store name in
	 * @param bufferLen		length of buffer
	 */
	public void GetName(char[] buffer, int bufferLen)
	{
		this.GetString("Name", buffer, bufferLen);
	}

	/**
	 * get file path of the player's model
	 *
	 * @param buffer		buffer to store model in
	 * @param bufferLen		length of buffer
	 */
	public void GetModel(char[] buffer, int bufferLen)
	{
		this.GetString("modelName", buffer, bufferLen);
	}

	/**
	 * get player's saved world position
	 *
	 * @param buffer		store vector to this buffer
	 */
	public void GetPosition(float buffer[3])
	{
		this.GetVector("pos", buffer);
	}
	/**
	 * set player's saved world position
	 *
	 * @param value			new position vector
	 */
	public void SetPosition(const float value[3])
	{
		this.SetVector("pos", value);
	}

	/**
	 * get player's saved facing angles
	 *
	 * @param buffer		store vector to this buffer
	 */
	public void GetAngles(float buffer[3])
	{
		this.GetVector("angles", buffer);
	}
	/**
	 * set player's saved facing angles
	 *
	 * @param value			new angles vector
	 */
	public void SetAngles(const float value[3])
	{
		this.SetVector("angles", value);
	}

	/**
	 * get player's saved velocity
	 *
	 * @param buffer		store vector to this buffer
	 */
	public void GetVelocity(float buffer[3])
	{
		this.GetVector("vel", buffer);
	}
	/**
	 * set player's saved velocity
	 *
	 * @param value			new velocity vector
	 */
	public void SetVelocity(const float value[3])
	{
		this.SetVector("vel", value);
	}

	/**
	 * get map name this player was set to transition into
	 *
	 * @param buffer		buffer to store map name in
	 * @param bufferLen		length of buffer
	 */
	public void GetTargetMap(char[] buffer, int bufferLen)
	{
		this.GetString("targetMap", buffer, bufferLen);
	}
}

methodmap GameModeInfo < InternalKeyValues
{
	/** is gamemode a mutation? */
	property bool mutation
	{
		public get()
		{
			return !!this.GetInt("mutation", 0);
		}
	}

	property int maxplayers
	{
		public get()
		{
			return this.GetInt("maxplayers");
		}
	}

	property bool hasPlayerControlledZombies
	{
		public get()
		{
			return !!this.GetInt("playercontrolledzombies", 0);
		}
	}

	property bool singleChapterMode
	{
		public get()
		{
			return !!this.GetInt("singlechapter", 0);
		}
	}

	/** is gamemode from an addon? */
	property bool addon
	{
		public get()
		{
			return !!this.GetInt("addon", 0);
		}
	}

	/**
	 * get the name of this gamemode's base mode
	 *
	 * @param buffer		store name to this buffer
	 * @param bufferLen		length of buffer
	 */
	public void GetBase(char[] buffer, int bufferLen)
	{
		this.GetString("base", buffer, bufferLen);
	}
}

public SharedPlugin __pl_hxlib =
{
    name = HXLIB_LIBRARY,
    file = "hxlib.smx",
	#if defined REQUIRE_PLUGIN
		required = 1,
	#else
		required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
	public void __pl_hxlib_SetNTVOptional()
	{
		MarkNativeAsOptional("AddEntityHook");
		MarkNativeAsOptional("RemoveEntityHook");

		MarkNativeAsOptional("NavLadder.entity.get");
		MarkNativeAsOptional("NavLadder.team.get");
		MarkNativeAsOptional("NavLadder.length.get");
		MarkNativeAsOptional("NavLadder.address.get");
		MarkNativeAsOptional("NavLadder.IsUsableByTeam");
		MarkNativeAsOptional("NavLadder.GetBottomOrigin");
		MarkNativeAsOptional("NavLadder.GetTopOrigin");
		MarkNativeAsOptional("NavLadder.GetBottomArea");
		MarkNativeAsOptional("NavLadder.GetTopArea");
		MarkNativeAsOptional("NavLadder.GetTopAreaEx");
		MarkNativeAsOptional("NavLadder.GetConnection");

		MarkNativeAsOptional("NavArea.baseAttributes.get");
		MarkNativeAsOptional("NavArea.baseAttributes.set");
		MarkNativeAsOptional("NavArea.spawnAttributes.get");
		MarkNativeAsOptional("NavArea.spawnAttributes.set");
		MarkNativeAsOptional("NavArea.id.get");
		MarkNativeAsOptional("NavArea.elevator.get");
		MarkNativeAsOptional("NavArea.address.get");
		MarkNativeAsOptional("NavArea.GetCenter");
		MarkNativeAsOptional("NavArea.GetFlow");
		MarkNativeAsOptional("NavArea.GetNextEscapeStep");
		MarkNativeAsOptional("NavArea.GetNextEscapeStepEx");
		MarkNativeAsOptional("NavArea.GetElevatorAreaCount");
		MarkNativeAsOptional("NavArea.GetElevatorArea");
		MarkNativeAsOptional("NavArea.GetElevatorAreas");
		MarkNativeAsOptional("NavArea.GetElevatorAreasEx");
		MarkNativeAsOptional("NavArea.GetLadderCount");
		MarkNativeAsOptional("NavArea.GetLadder");
		MarkNativeAsOptional("NavArea.GetLadders");
		MarkNativeAsOptional("NavArea.GetLaddersEx");
		MarkNativeAsOptional("NavArea.GetAdjacentCount");
		MarkNativeAsOptional("NavArea.GetAdjacentArea");
		MarkNativeAsOptional("NavArea.GetAdjacentAreas");
		MarkNativeAsOptional("NavArea.GetAdjacentAreasEx");
		MarkNativeAsOptional("NavArea.GetRandomAdjacentArea");
		MarkNativeAsOptional("NavArea.GetZDeltaToArea");
		MarkNativeAsOptional("NavArea.IsConnected");
		MarkNativeAsOptional("NavArea.GetIncomingCount");
		MarkNativeAsOptional("NavArea.GetIncomingConnection");
		MarkNativeAsOptional("NavArea.GetIncomingConnections");
		MarkNativeAsOptional("NavArea.GetIncomingConnectionsEx");
		MarkNativeAsOptional("NavArea.sizeX.get");
		MarkNativeAsOptional("NavArea.sizeY.get");
		MarkNativeAsOptional("NavArea.sizeZ.get");
		MarkNativeAsOptional("NavArea.GetCorner");
		MarkNativeAsOptional("NavArea.GetZ");
		MarkNativeAsOptional("NavArea.IsBlocked");
		MarkNativeAsOptional("NavArea.IsBehindZombieBorder");
		MarkNativeAsOptional("NavArea.populationDensity.get");
		MarkNativeAsOptional("NavArea.populationDensity.set");

		MarkNativeAsOptional("NavAreaSet.Get");
		MarkNativeAsOptional("NavAreaSet.GetArrayList");
		MarkNativeAsOptional("NavAreaSet.GetArrayListEx");
		MarkNativeAsOptional("NavAreaSet.count.get");
		MarkNativeAsOptional("NavAreaSet.count.set");
		MarkNativeAsOptional("NavAreaSet.Push");
		MarkNativeAsOptional("NavAreaSet.Set");
		MarkNativeAsOptional("NavAreaSet.SetArrayList");
		MarkNativeAsOptional("NavAreaSet.Erase");
		MarkNativeAsOptional("NavAreaSet.Clear");
		MarkNativeAsOptional("NavAreaSet.Find");

		MarkNativeAsOptional("Inferno.entity.get");
		MarkNativeAsOptional("Inferno.type.get");
		MarkNativeAsOptional("Inferno.maxFlames.get");
		MarkNativeAsOptional("Inferno.maxFlames.set");
		MarkNativeAsOptional("Inferno.startTime.get");
		MarkNativeAsOptional("Inferno.GetMins");
		MarkNativeAsOptional("Inferno.GetMaxs");
		MarkNativeAsOptional("Inferno.flameCount.get");
		MarkNativeAsOptional("Inferno.GetFlame");
		MarkNativeAsOptional("Inferno.GetOrigin");
		MarkNativeAsOptional("Inferno.damageTimer.get");
		MarkNativeAsOptional("Inferno.damageRampTimer.get");
		MarkNativeAsOptional("Inferno.GetFlameLifetime");

		MarkNativeAsOptional("Flame.depth.get");
		MarkNativeAsOptional("Flame.depth.set");
		MarkNativeAsOptional("Flame.parent.get");
		MarkNativeAsOptional("Flame.spawnLifetime.get");
		MarkNativeAsOptional("Flame.lifetime.get");
		MarkNativeAsOptional("Flame.GetOrigin");
		MarkNativeAsOptional("Flame.GetDirection");

		MarkNativeAsOptional("HXLibRescanForwards");
		MarkNativeAsOptional("GetServerOS");
		MarkNativeAsOptional("SetSurvivorIntensity");
		MarkNativeAsOptional("GetSurvivorIntensity");
		MarkNativeAsOptional("IncreaseSurvivorIntensity");
		MarkNativeAsOptional("GetEntityFromAddress");
		MarkNativeAsOptional("IsPanic");
		MarkNativeAsOptional("GetPanicStage");
		MarkNativeAsOptional("GetFinaleStage");
		MarkNativeAsOptional("IsFinale");
		MarkNativeAsOptional("IsCrescendo");
		MarkNativeAsOptional("SetCrescendo");
		MarkNativeAsOptional("GetFinaleType");
		MarkNativeAsOptional("GetCompletedPanicWaves");
		MarkNativeAsOptional("SetCompletedPanicWaves");
		MarkNativeAsOptional("GetTotalPanicWaves");
		MarkNativeAsOptional("SetTotalPanicWaves");
		MarkNativeAsOptional("EndPanicEvent");
		MarkNativeAsOptional("GetLastKnownArea");
		MarkNativeAsOptional("GetCurrentArea");
		MarkNativeAsOptional("CollectSpawnAreas");
		MarkNativeAsOptional("ResetMobTimer");
		MarkNativeAsOptional("StartMobTimer");
		MarkNativeAsOptional("ResetMobRecharge");
		MarkNativeAsOptional("GetMobRechargeSize");
		MarkNativeAsOptional("SetMobRechargeSize");
		MarkNativeAsOptional("ResetSpecialTimers");
		MarkNativeAsOptional("BeginLocalScript");
		MarkNativeAsOptional("EndLocalScript");
		MarkNativeAsOptional("GetRandomPZSpawnPosition");
		MarkNativeAsOptional("GetEntityTeam");
		MarkNativeAsOptional("GetAllNavAreas");
		MarkNativeAsOptional("GetNavAreaEntity");
		MarkNativeAsOptional("GetNavArea");
		MarkNativeAsOptional("GetNearestNavAreaEntity");
		MarkNativeAsOptional("GetNearestNavArea");
		MarkNativeAsOptional("GetDefaultViewVector");
		MarkNativeAsOptional("IsInFieldOfView");
		MarkNativeAsOptional("IsHiddenByFog");
		MarkNativeAsOptional("IsVisibleToClient");
		MarkNativeAsOptional("IsVisibleToTeam");
		MarkNativeAsOptional("TR_TraceRayFilterSimple");
		MarkNativeAsOptional("TR_TraceHullFilterSimple");
		MarkNativeAsOptional("IsInTransition");
		MarkNativeAsOptional("HasAnySurvivorLeftSafeArea");
		MarkNativeAsOptional("AreChallengeModeScriptVariablesAllowed");
		MarkNativeAsOptional("IsBehindZombieBorder");
		MarkNativeAsOptional("CanZombieSpawnHere");
		MarkNativeAsOptional("CanZombieSpawnHereEx");
		MarkNativeAsOptional("HasCrescendoOccurred");
		MarkNativeAsOptional("SetCrescendoOccurred");
		MarkNativeAsOptional("ShouldLockTempo");
		MarkNativeAsOptional("GetTempo");
		MarkNativeAsOptional("SetTempo");
		MarkNativeAsOptional("GetTempoFlowStamp");
		MarkNativeAsOptional("SetTempoFlowStamp");
		MarkNativeAsOptional("GetHighestFlowSurvivor");
		MarkNativeAsOptional("GetPlayerFlow");
		MarkNativeAsOptional("GetActiveSet");
		MarkNativeAsOptional("GoAwayFromKeyboard");
		MarkNativeAsOptional("GetInferno");
		MarkNativeAsOptional("SetPunchAngle");
		MarkNativeAsOptional("GetPunchAngle");
		MarkNativeAsOptional("SetTimescale");
		MarkNativeAsOptional("ShowMOTD");
		MarkNativeAsOptional("ShowHostBanner");
		MarkNativeAsOptional("GetSurvivorCharacter");
		MarkNativeAsOptional("GetSurvivorSet");
		MarkNativeAsOptional("GetSurvivorCharacterName");
		MarkNativeAsOptional("GetSurvivorCharacterFromName");
		MarkNativeAsOptional("AddSurvivorBot");
		MarkNativeAsOptional("FlashlightIsOn");
		MarkNativeAsOptional("FlashlightTurnOn");
		MarkNativeAsOptional("FlashlightTurnOff");
		MarkNativeAsOptional("GetWeaponID");
		MarkNativeAsOptional("GetTimeLastAlive");
		MarkNativeAsOptional("SetTimeLastAlive");
		MarkNativeAsOptional("SwitchWeapon");
		MarkNativeAsOptional("GetRestoreSecondaryWeapon");
		MarkNativeAsOptional("SetRestoreSecondaryWeapon");
		MarkNativeAsOptional("GetMaxReserveAmmo");
		MarkNativeAsOptional("GetMaxMagazineAmmo");
		MarkNativeAsOptional("IsEntityAlive");
		MarkNativeAsOptional("GetLastHitGroup");
		MarkNativeAsOptional("Vocalize");
		MarkNativeAsOptional("SpawnSpecial");
		MarkNativeAsOptional("SpawnCommon");
		MarkNativeAsOptional("GetScriptValueInt");
		MarkNativeAsOptional("GetScriptValueFloat");
		MarkNativeAsOptional("DoesWaterSlowMovement");
		MarkNativeAsOptional("GetFOV");
		MarkNativeAsOptional("InternalKeyValues.InternalKeyValues");
		MarkNativeAsOptional("InternalKeyValues.DeleteThis");
		MarkNativeAsOptional("InternalKeyValues.address.get");
		MarkNativeAsOptional("InternalKeyValues.GetInt");
		MarkNativeAsOptional("InternalKeyValues.SetInt");
		MarkNativeAsOptional("InternalKeyValues.GetFloat");
		MarkNativeAsOptional("InternalKeyValues.SetFloat");
		MarkNativeAsOptional("InternalKeyValues.GetVector");
		MarkNativeAsOptional("InternalKeyValues.SetVector");
		MarkNativeAsOptional("InternalKeyValues.GetString");
		MarkNativeAsOptional("InternalKeyValues.SetString");
		MarkNativeAsOptional("InternalKeyValues.GetName");
		MarkNativeAsOptional("InternalKeyValues.SetName");
		MarkNativeAsOptional("InternalKeyValues.GetFirstSubKey");
		MarkNativeAsOptional("InternalKeyValues.GetNextKey");
		MarkNativeAsOptional("InternalKeyValues.FindKey");
		MarkNativeAsOptional("InternalKeyValues.CreateKey");
		MarkNativeAsOptional("InternalKeyValues.RemoveSubKey");
		MarkNativeAsOptional("InternalKeyValues.SaveToFile");
		MarkNativeAsOptional("GetSavedPlayer");
		MarkNativeAsOptional("GetSavedPlayerCount");
		MarkNativeAsOptional("GetSavedSurvivorBot");
		MarkNativeAsOptional("GetSavedSurvivorBotCount");
		MarkNativeAsOptional("GetReservationCookie");
		MarkNativeAsOptional("GetGameModeInfo");
		MarkNativeAsOptional("GetHibernationState");
		MarkNativeAsOptional("GetZoomLevel");
		MarkNativeAsOptional("SetFOV");
		MarkNativeAsOptional("IsAmmoTypeInfinite");
		MarkNativeAsOptional("RemoveAmmo");
		MarkNativeAsOptional("GetDeployActivity");
		MarkNativeAsOptional("SelectWeightedSequence");
		MarkNativeAsOptional("GetSequencesForActivity");
		MarkNativeAsOptional("GetSequences");
		MarkNativeAsOptional("GetSequenceDuration");
		MarkNativeAsOptional("GetMobTimer");
		MarkNativeAsOptional("GetTempoTimer");
		MarkNativeAsOptional("GetScenarioRestartTimer");

		/** deprecated */
		MarkNativeAsOptional("GetTimeUntilNextMob");
		MarkNativeAsOptional("GetTempoRemainingTime");
		MarkNativeAsOptional("SetTempoRemainingTime");
		MarkNativeAsOptional("GetScenarioRestartTime");
		MarkNativeAsOptional("SetScenarioRestartTime");
		MarkNativeAsOptional("GetVocalizeCooldown");
		MarkNativeAsOptional("SetVocalizeCooldown");
	}
#endif
