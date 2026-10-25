#if defined _hxstocks_included_
	#endinput
#endif
#define _hxstocks_included_

#pragma newdecls required
#pragma semicolon 1

#include <sdktools>

#define CONVAR_MAX_NAME_LENGTH	256
#define SOUND_NORMAL_CLIP_DIST	1000.0

enum
{
	WeaponSlot_Primary,
	WeaponSlot_Secondary,
	WeaponSlot_Throwable,
	WeaponSlot_FirstAid,
	WeaponSlot_Pills,
	WeaponSlot_Carry,

	WeaponSlot_MAX
};

enum
{
	Team_Unassigned	= 0,
	Team_Spectator	= 1,
	Team_Survivor	= 2,
	Team_Infected	= 3,
	Team_Actors		= 4		// used by non-playable survivors, like the l4d1 survivors in the passing
};

enum AmmoType
{
	Ammo_Null = -1,
	Ammo_None = 0,

	Ammo_Pistol,
	Ammo_PistolMagnum,
	Ammo_AssaultRifle,
	Ammo_Minigun,
	Ammo_Smg,
	Ammo_M60,
	Ammo_Shotgun,
	Ammo_Autoshotgun,
	Ammo_HuntingRifle,
	Ammo_SniperRifle,
	Ammo_Turret,
	Ammo_PipeBomb,
	Ammo_Molotov,
	Ammo_VomitJar,
	Ammo_PainPills,
	Ammo_FirstAid,
	Ammo_GrenadeLauncher,
	Ammo_Adrenaline,
	Ammo_Chainsaw,
	Ammo_CarriedItem,

	Ammo_MAX = 32
};

/** there are likely l4d2 specific flags missing from this */
enum PlayerPhysFlag
{
	PFlag_DirOverride				= (1 << 0),		// override the player's directional control (trains, physics gun, etc.)
	PFlag_Ducking					= (1 << 1),		// In the process of ducking, but totally squatted yet
	PFlag_Using						= (1 << 2),		// Using a continuous entity
	PFlag_Observer					= (1 << 3),		// player is locked in stationary cam mode. Spectators can move, observers can't.
	PFlag_VPhysicsMotionController	= (1 << 4),		// player is physically attached to a motion controller
	PFlag_GamePhysicsRotPush 		= (1 << 5)		// game physics did a rotating push that we may want to override with vphysics
};

enum ZombieClass
{
	ZClass_Null		= -1,

	ZClass_Common	= 0,

	ZClass_Smoker	= 1,
	ZClass_Boomer	= 2,
	ZClass_Hunter	= 3,
	ZClass_Spitter	= 4,
	ZClass_Jockey	= 5,
	ZClass_Charger	= 6,

	ZClass_Witch	= 7,
	ZClass_Tank		= 8,

	ZClass_Survivor	= 9
};

#define ZCLASS_SI_MIN	ZClass_Smoker
#define ZCLASS_SI_MAX	ZClass_Witch
#define ZCLASS_MAX		ZClass_Survivor

stock const char g_sZClass[][] =
{
	"Common",

	"Smoker",
	"Boomer",
	"Hunter",
	"Spitter",
	"Jockey",
	"Charger",

	"Witch",
	"Tank",

	"Survivor"
};

#define MAXPLAYERS_L4D2			32
#define MAXEDICTS				2048
#define MAXENTITIES				4095

/**
 * get ZombieClass enum of this entity
 *
 * @param entity		get ZombieClass of this entity
 *
 * @return				ZombieClass of this client
 *
 * @error				entity isn't valid
 */
stock ZombieClass GetZombieClass(int entity)
{
	if (0 < entity <= MaxClients)
		return view_as<ZombieClass>(GetEntProp(entity, Prop_Send, "m_zombieClass"));
	else
	{
		static StringMap classMap = null;
		if (classMap == null)
		{
			classMap = new StringMap();
			classMap.SetValue("infected", ZClass_Common);
			classMap.SetValue("witch", ZClass_Witch);
		}

		ZombieClass class;
		static char className[10];
		GetEntityClassname(entity, className, sizeof(className));
		if (classMap.GetValue(className, class))
			return class;
	}

	return ZClass_Null;
}

/**
 * shortcut to check if an entity is a client, and is in game
 *
 * @param entity		entity index to check
 *
 * @return				true if it's a valid connected client, false otherwise
 */
stock bool IsValidClient(int entity)
{
	if (entity < 1 || entity > MaxClients)
		return false;

	return IsClientInGame(entity);
}

/**
 * check if a client is currently being dominated by a special infected
 *
 * @param client		client index of survivor to check
 *
 * @return				true if this survivor is being dominated, false otherwise
 */
stock bool IsDominated(int client)
{
	int si = -1;
	if ((	(si = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker")) != -1
		||	(si = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker")) != -1
		||	(si = GetEntPropEnt(client, Prop_Send, "m_tongueOwner")) != -1
		||	(si = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker")) != -1
		||	(si = GetEntPropEnt(client, Prop_Send, "m_carryAttacker")) != -1
		)
		&& IsValidClient(si))
			return true;

	return false;
}

stock bool IsSmoked(int client)
{
	return IsValidClient(GetEntPropEnt(client, Prop_Send, "m_tongueOwner"));
}

stock bool IsPounced(int client)
{
	return IsValidClient(GetEntPropEnt(client, Prop_Send, "m_pounceAttacker"));
}

stock bool IsJockeyed(int client)
{
	return IsValidClient(GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker"));
}

stock bool IsChargerCarried(int client)
{
	return IsValidClient(GetEntPropEnt(client, Prop_Send, "m_carryAttacker"));
}

stock bool IsChargerPummeled(int client)
{
	return IsValidClient(GetEntPropEnt(client, Prop_Send, "m_pummelAttacker"));
}

stock bool HasVictim(int client)
{
	int victim = -1;
	switch (GetZombieClass(client))
	{
		case ZClass_Smoker:
			victim = GetEntPropEnt(client, Prop_Send, "m_tongueVictim");
		case ZClass_Hunter:
			victim = GetEntPropEnt(client, Prop_Send, "m_pounceVictim");
		case ZClass_Jockey:
			victim = GetEntPropEnt(client, Prop_Send, "m_jockeyVictim");
		case ZClass_Charger:
		{
			if ((victim = GetEntPropEnt(client, Prop_Send, "m_carryVictim")) == -1)
				victim = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
		}
	}

	return IsValidClient(victim);
}

/**
 * check if entity inherits CBaseCombatCharacter
 */
stock bool IsCombatCharacter(int entity)
{
	return HasEntProp(entity, Prop_Send, "m_hMyWeapons");
}

/**
 * is this entity a common infected?
 *
 * @param entity		entity index to check
 *
 * @return				true if it's an infected
 */
stock bool IsCommonInfected(int entity)
{
	return IsEntityOfClass(entity, "infected");
}

/**
 * check if entity inherits Infected class
 */
stock bool IsInfected(int entity)
{
	return HasEntProp(entity, Prop_Send, "m_mobRush");
}

/**
 * is this entity a witch?
 *
 * @param entity		entity index to check
 *
 * @return				true if it's a witch
 */
stock bool IsWitch(int entity)
{
	return IsEntityOfClass(entity, "witch");
}

/**
 * shortcut for checking if an entity's class string equals a specified class
 *
 * @param entity		entity index to check
 * @param classname		compare entity's classname against this classname
 *
 * @return				true if the entity's classname equals the specified class
 */
stock bool IsEntityOfClass(int entity, const char[] classname)
{
	static char buffer[64];
	GetEntityClassname(entity, buffer, sizeof(buffer));

	return strcmp(buffer, classname) == 0;
}

stock bool IsOfSurvivorTeam(int iClient)
{
	int iTeam = GetClientTeam(iClient);
	return (iTeam == Team_Survivor || iTeam == Team_Actors);
}

/**
 * get the absolute value of an integer
 *
 * @param n				number to perform operation on
 *
 * @return				absolute of n
 */
stock int IntAbs(int n)
{
   return (n ^ (n >> 31)) - (n >> 31);
}

/**
 * PrintToServer message with current game tick and plugin name as contextual prefixes
 *
 * @param	message		message to print with formatting rules
 * @param	...			variable number of format parameters
 */
stock void DebugPrint(const char[] message, any ...)
{
	int len = strlen(message) + 256;
	char[] messageFormatted = new char[len];
	static char pluginName[64];

	VFormat(messageFormatted, len, message, 2);
	GetPluginFilename(INVALID_HANDLE, pluginName, sizeof(pluginName));

	for (int i = 0; i < sizeof(pluginName); i++)
	{
		if (pluginName[i] == '.')
		{
			pluginName[i] = '\0';
			break;
		}
	}

	PrintToServer("# <%i> [%s] %s", GetGameTickCount(), pluginName, messageFormatted);
}

/**
 * get the name of the function calling this stock, or a previous one
 *
 * @param buffer		string buffer to copy to
 * @param maxlen		size of the buffer
 * @param prevAmount	target a function this far back
 */
stock void GetFunctionName(char[] buffer, int maxlen, int prevAmount = 0)
{
	FrameIterator stackTrace = new FrameIterator();

	for (int i = 0; i < prevAmount+2; i++)
		stackTrace.Next();

	stackTrace.GetFunctionName(buffer, maxlen);

	delete stackTrace;
}

/**
 * length from GetNativeStringLength but with +1 for null terminator
 *
 * @param param			native parameter number, starting from 1
 *
 * @return 				string length as an integer
 */
stock int GetNativeStringLengthFull(int param)
{
	int len;
	GetNativeStringLength(param, len);
	return ++len;
}

/**
 * follow a string pointer and load the string into a buffer
 *
 * @param ptr			address of the string pointer
 * @param buffer		buffer to store the returned string
 * @param maxlen		size of the buffer
 *
 * @return				amount of bytes written to the buffer
 */
stock int LoadStringFromPointer(Address ptr, char[] buffer, int maxlen)
{
	Address addr = LoadFromAddress(ptr, NumberType_Int32);
	return LoadStringFromAddress(addr, buffer, maxlen);
}

/**
 * load a string from the address of a char array in memory
 *
 * @param addr			address of the char array
 * @param buffer		buffer to store the returned string
 * @param maxlen		size of the buffer
 *
 * @return				amount of bytes written to the buffer
 */
stock int LoadStringFromAddress(Address addr, char[] buffer, int maxlen)
{
	int wrote;

	for (wrote = 0; wrote < maxlen; wrote++)
	{
		buffer[wrote] = LoadFromAddress(addr + view_as<Address>(wrote), NumberType_Int8);
		if (buffer[wrote] == '\0') break;
	}

	return wrote;
}

/**
 * get the client index of the first human player found
 *
 * @return				client index, -1 if no human players exist
 */
stock int GetFirstHuman()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (IsFakeClient(i)) continue;

		return i;
	}
	return -1;
}

/**
 * make an entity index array-index-friendly. often non-edict entities will be represented
 * with a big negative integer. this will convert those to indices that continue past 2048
 *
 * @param entity		original entity index
 *
 * @return				safe entity index
 *
 * @note				does nothing if the entity index is already "safe"
 */
stock int GetSafeEntityIndex(int entity)
{
	return entity & 0xFFF;
}

/**
 * get the absolute origin vector of any entity
 *
 * @param entity		index of the entity to get the origin of
 * @param buffer		store the origin vector to this buffer
 */
stock void GetEntityAbsOrigin(int entity, float buffer[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", buffer);
}

stock void SetEntityAbsOrigin(int entity, float value[3])
{
	SetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", value);
}

stock void GetEntityAbsAngles(int entity, float buffer[3])
{
	GetEntPropVector(entity, Prop_Send, "m_angRotation", buffer);
}

stock void SetEntityAbsAngles(int entity, float value[3])
{
	SetEntPropVector(entity, Prop_Send, "m_angRotation", value);
}

stock void GetEntityAbsVelocity(int entity, float buffer[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", buffer);
}

stock int GetEntityHealth(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iHealth");
}

stock int GetMagazineAmmo(int weapon)
{
	return GetEntProp(weapon, Prop_Data, "m_iClip1");
}

/**
 * load a vector from a memory address
 *
 * @param addr			the address of the vector
 * @param buffer		load it into this vector array
 */
stock void LoadVectorFromAddress(Address addr, float buffer[3])
{
	for (int i = 0; i < 3; i++)
		buffer[i] = LoadFromAddress(addr + view_as<Address>(i * 4), NumberType_Int32);
}

/**
 * store a vector to a memory address
 *
 * @param addr			the address to store a vector to
 * @param value			the vector to store at this address
 */
stock void StoreVectorToAddress(Address addr, const float value[3])
{
	for (int i = 0; i < sizeof(value); i++)
		StoreToAddress(addr + view_as<Address>(i * 4), value[i], NumberType_Int32);
}

/**
 * get the player closest to this position
 *
 * @param pos			the position
 * @param distance		store the distance between the position and closest player to this variable
 * @param team			Team_* enum. only check players on this team.
 * 						use Team_Unassigned to check all players.
 *
 * @return 				the client index of the closest player
 */
stock int GetClosestPlayer(const float pos[3], float &distance, int team = Team_Unassigned)
{
	float closestDistance;
	int closestClient = 0;

	float thisOrigin[3];
	float thisDistance;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (team != Team_Unassigned && GetClientTeam(i) != team) continue;
		if (team > 1 && !IsPlayerAlive(i)) continue;

		GetClientAbsOrigin(i, thisOrigin);
		thisDistance = GetVectorDistance(pos, thisOrigin, true);

		if (!closestClient || thisDistance < closestDistance)
		{
			closestDistance = thisDistance;
			closestClient = i;
		}
	}

	if (closestClient) distance = SquareRoot(closestDistance);
	else distance = 0.0;

	return closestClient;
}

/**
 * convert an unsigned 64-bit integer to a string representing it as hexadecimal
 *
 * @param num			64bit int
 * @param str			buffer for the string
 * @param maxlength		max characters to write to the buffer
 *
 * @return 				Number of characters written to the buffer, not including the null terminator.
 */
stock int UInt64ToStringHex(const int num[2], char[] str, int maxlength)
{
	char digit[2];
	int maskedNum;
	int wrote;

	for (int i = 1; i >= 0; i--)
	{
		for (int b = 7; b >= 0; b--)
		{
			maskedNum = (num[i] >> (b * 4)) & 0xf;
			if (!wrote && !maskedNum) continue;

			FormatEx(digit, sizeof(digit), "%x", maskedNum);
			wrote += StrCat(str, maxlength, digit);

			if (wrote >= maxlength - 1)
			{
				str[wrote] = '\0';
				return wrote;
			}
		}
	}

	if (wrote) str[wrote] = '\0';
	else
	{
		str[wrote++] = '0';
		str[wrote] = '\0';
	}

	return wrote;
}

/**
 * is the client reloading their weapon?
 *
 * @param client		client index of player to check
 *
 * @return				true if reloading, false otherwise
 */
stock bool IsReloading(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	return IsValidEdict(weapon) && GetEntProp(weapon, Prop_Send, "m_bInReload");
}

/**
 * is this weapon in reload?
 *
 * @param weapon		entity index of weapon to check
 *
 * @return				true if in reload, false otherwise
 */
stock bool IsWeaponReloading(int weapon)
{
	return GetEntProp(weapon, Prop_Send, "m_bInReload");
}

/**
 * get the integer a character represents in text
 *
 * @param character		character to derive integer from
 * @param result		save result to this
 *
 * @return				true on success, false if not a numeric character
 */
stock bool CharToInt(char character, int &result)
{
	if (IsCharNumeric(character))
	{
		result = view_as<int>(character) - '0';
		return true;
	}
	return false;
}

stock int GetOwnerEntity(int entity)
{
	return GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
}

stock void SetMagazineAmmo(int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Data, "m_iClip1", ammo);
}

stock int GetReserveAmmo(int weapon)
{
	int client = GetOwnerEntity(weapon);
	if (IsValidClient(client))
	{
		AmmoType type = GetAmmoType(weapon);
		return GetEntProp(client, Prop_Send, "m_iAmmo", _, type);
	}

	return GetEntProp(weapon, Prop_Send, "m_iExtraPrimaryAmmo");
}

stock void SetReserveAmmo(int weapon, int ammo)
{
	int client = GetOwnerEntity(weapon);
	if (IsValidClient(client))
	{
		AmmoType type = GetAmmoType(weapon);
		SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, type);
	}

	SetEntProp(weapon, Prop_Send, "m_iExtraPrimaryAmmo", ammo);
}

stock int GetMeleeWeaponName(int weapon, char[] buffer, int bufferLen)
{
	return GetEntPropString(weapon, Prop_Data, "m_strMapSetScriptName", buffer, bufferLen);
}

stock bool IsTerrorGun(int weapon)
{
	return HasEntProp(weapon, Prop_Send, "m_isDualWielding");
}

stock bool IsTerrorWeapon(int weapon)
{
	return HasEntProp(weapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
}

/** must be CTerrorWeapon */
stock int GetUpgradedAmmo(int weapon)
{
	return GetEntProp(weapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
}

/** must be CTerrorWeapon */
stock void SetUpgradedAmmo(int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", ammo);
}

/** must be CTerrorGun */
stock int GetWeaponUpgrades(int weapon)
{
	return GetEntProp(weapon, Prop_Send, "m_upgradeBitVec");
}

/** must be CTerrorGun */
stock void SetWeaponUpgrades(int weapon, int upgrades)
{
	SetEntProp(weapon, Prop_Send, "m_upgradeBitVec", upgrades);
}

/**
 * check if a weapon is being dual wielded
 *
 * @param weapon			entity index of the weapon
 *
 * @return					true if dual wielded, false otherwise
 */
stock bool IsDualWielding(int weapon)
{
	if (!IsTerrorGun(weapon))
		return false;

	return GetEntProp(weapon, Prop_Send, "m_isDualWielding", 1);
}

stock AmmoType GetAmmoType(int weapon)
{
	return view_as<AmmoType>(GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"));
}

/** is CBaseCombatWeapon entity */
stock bool IsWeapon(int entity)
{
	return HasEntProp(entity, Prop_Send, "m_iPrimaryAmmoType");
}

stock int GetCurrentWeapon(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

stock int GetEntityMaxHealth(int entity)
{
	static int offset;
	if (!offset)
	{
		/** netprop doesn't exist in many entity classes */
		offset = FindSendPropInfo("CTerrorPlayer", "m_iMaxHealth");
		if (offset <= 0)
		{
			offset = 0;
			return 0;
		}
	}

	return GetEntData(entity, offset);
}

stock int GetObserverTarget(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

stock bool IsPlayerIncapacitated(int client)
{
	return GetEntProp(client, Prop_Send, "m_isIncapacitated");
}

stock bool IsHunterLunging(int client)
{
	return GetEntProp(client, Prop_Send, "m_isAttemptingToPounce", 1);
}

stock void GetCollisionMins(int entity, float buffer[3])
{
	GetEntPropVector(entity, Prop_Send, "m_Collision", buffer, 0);
}

stock void GetCollisionMaxs(int entity, float buffer[3])
{
	GetEntPropVector(entity, Prop_Send, "m_Collision", buffer, 1);
}

stock void GetCollisionCenter(int entity, float buffer[3])
{
	float mins[3];
	float maxs[3];
	float origin[3];

	GetCollisionMins(entity, mins);
	GetCollisionMaxs(entity, maxs);
	GetEntityAbsOrigin(entity, origin);

	for (int i = 0; i < 3; i++)
		buffer[i] = origin[i] + ((maxs[i] + mins[i]) * 0.5);
}

stock bool IsPlayerGhost(int client)
{
	return GetEntProp(client, Prop_Send, "m_isGhost", 1);
}

stock PlayerPhysFlag GetPhysicsFlags(int client)
{
	return view_as<PlayerPhysFlag>(GetEntProp(client, Prop_Data, "m_afPhysicsFlags"));
}

stock bool IsPlayerInWater(int client)
{
	return GetEntProp(client, Prop_Send, "m_nWaterLevel", 1);
}

stock bool AdrenalineActive(int client)
{
	return GetEntProp(client, Prop_Send, "m_bAdrenalineActive", 1);
}

stock int GetDefaultFOV(int client)
{
	int fov = GetEntProp(client, Prop_Send, "m_iDefaultFOV");
	return fov ? fov : 90;
}

stock bool IsSurvivorBot(int client)
{
	return HasEntProp(client, Prop_Send, "m_humanSpectatorUserID");
}

/**
 * get the client index of the idle human this bot belongs to
 *
 * @param bot		client index of bot
 *
 * @return			client index of human. 0 if there is none.
 */
stock int GetIdlePlayer(int bot)
{
	return GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));
}

/** CBasePlayer */
stock bool IsOnGround(int client)
{
	return IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hGroundEntity"));
}

stock int FilterClientsByAttenuation(int[] clients, int &numClients, const float source[3], int level)
{
	float attn = 20.0 / (float(level) - 50.0);
	float maxAudible = (2 * SOUND_NORMAL_CLIP_DIST) / attn;

	float listenerPos[3];
	float distance;
	int i = 0;
	int ret = 0;

	while (i < numClients)
	{
		if (IsClientObserver(clients[i]))
		{
			i++;
			continue;
		}

		GetClientEyePosition(clients[i], listenerPos);
		distance = GetVectorDistance(source, listenerPos);

		if (distance <= maxAudible)
		{
			i++;
			continue;
		}

		for (int j = i; j < numClients; j++)
			clients[j] = clients[j + 1];

		numClients--;
		ret++;
	}

	return ret;
}

stock bool IsAudible(int client, const float source[3], int level)
{
	float attn = 20.0 / (float(level) - 50.0);
	float maxAudible = (2 * SOUND_NORMAL_CLIP_DIST) / attn;

	float listenerPos[3];
	GetClientEyePosition(client, listenerPos);

	float distance = GetVectorDistance(source, listenerPos);
	return distance <= maxAudible;
}

/** Address */
methodmap CountdownTimer
{
	/** time between timer's start and target time */
	property float duration
	{
		public get()
		{
			return LoadFromAddress(view_as<Address>(this) + view_as<Address>(4), NumberType_Int32);
		}
		public set(float value)
		{
			StoreToAddress(view_as<Address>(this) + view_as<Address>(4), value, NumberType_Int32);
		}
	}

	/** target time when timer will have elapsed */
	property float timestamp
	{
		public get()
		{
			return LoadFromAddress(view_as<Address>(this) + view_as<Address>(8), NumberType_Int32);
		}
		public set(float value)
		{
			StoreToAddress(view_as<Address>(this) + view_as<Address>(8), value, NumberType_Int32);
		}
	}

	/**
	 * start the timer over using the last started duration
	 */
	public void Reset()
	{
		this.timestamp = GetGameTime() + this.duration;
	}

	/**
	 * start a new timer from current time
	 *
	 * @param duration		timer will end this many seconds from now
	 */
	public void Start(float duration)
	{
		this.timestamp = GetGameTime() + duration;
		this.duration = duration;
	}

	/**
	 * start a new timer from a custom start time
	 *
	 * @param startTime		timestamp to start timer from
	 * @param duration		duration of the timer
	 */
	public void StartFromTime(float startTime, float duration)
	{
		this.timestamp = startTime + duration;
		this.duration = duration;
	}

	public void Invalidate()
	{
		this.timestamp = -1.0;
	}

	/**
	 * check if timer is valid/started. some code depend on it being started to use it.
	 */
	public bool HasStarted()
	{
		return this.timestamp > 0.0;
	}

	/**
	 * check if timer elapsed
	 *
	 * @return		true if elapsed, false if not
	 */
	public bool IsElapsed()
	{
		return GetGameTime() > this.timestamp;
	}

	/**
	 * get how many seconds has passed since the timer started
	 */
	public float GetElapsedTime()
	{
		return GetGameTime() - this.timestamp + this.duration;
	}

	/**
	 * get how many seconds remain until the target time
	 */
	public float GetRemainingTime()
	{
		return this.timestamp - GetGameTime();
	}

	/**
	 * ratio (0.0 through 1.0) of how much time of the duration is remaining
	 *
	 * @return		0.0 if at timer end, 1.0 if at timer start
	 */
	public float GetRemainingRatio()
	{
		if (this.timestamp <= 0.0)
			return 0.0;

		float remaining = this.GetRemainingTime() / this.duration;
		if (remaining < 0.0)
			return 0.0;
		if (remaining > 1.0)
			return 1.0;
		return remaining;
	}

	/**
	 * ratio (0.0 through 1.0) of how much of the duration was elapsed
	 *
	 * @return		0.0 if at timer start, 1.0 if at timer end
	 */
	public float GetElapsedRatio()
	{
		if (this.timestamp <= 0.0)
			return 0.0;

		float elapsed = this.GetElapsedTime() / this.duration;
		if (elapsed < 0.0)
			return 0.0;
		if (elapsed > 1.0)
			return 1.0;
		return elapsed;
	}
}
