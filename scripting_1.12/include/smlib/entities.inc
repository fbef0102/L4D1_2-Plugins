#if defined _smlib_entities_included
	#endinput
#endif
#define _smlib_entities_included

#include <sourcemod>
#include <sdktools_entinput>
#include <sdktools_functions>

/**
 * Macro for iterating trough all children (entities it is parent of) of an entity.
 *
 * @param 1		Entity Index of the parent.
 * @param 2		Name of the children entity index variable (will be only valid in the loop).
 */
#define LOOP_CHILDREN(%1,%2) for (int %2=Entity_GetNextChild(%1); %2 != INVALID_ENT_REFERENCE; %2=Entity_GetNextChild(%1, ++%2))

/*
 * Checks if an entity is valid and exists.
 *
 * @param entity		Entity Index.
 * @return				True if the entity is valid, false otherwise.
 */
stock bool Entity_IsValid(int entity)
{
	return IsValidEntity(entity);
}

/**
 * Finds an entity by its name.
 * You can optionally specify the classname to search for.
 * Note: If the classname is specified it uses The Sourcemod native
 * function FindEntityByClassname() which uses the engine's
 * linked entity list for finding entities. This might be
 * cheaper, use this if you call this function very often.
 *
 * @param name			Name of the entity you want so search.
 * @param className		Optional: Classname of the entity
 * @return				Entity index or INVALID_ENT_REFERENCE if not matching entity was found.
 */
stock int Entity_FindByName(const char[] name, const char[] className="")
{
	if (className[0] == '\0') {
		// Hack: Double the limit to gets none-networked entities too.
		int realMaxEntities = GetMaxEntities() * 2;
		for (int entity=0; entity < realMaxEntities; entity++) {

			if (!IsValidEntity(entity)) {
				continue;
			}

			if (Entity_NameMatches(entity, name)) {
				return entity;
			}
		}
	}
	else {
		int entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, className)) != INVALID_ENT_REFERENCE) {

			if (Entity_NameMatches(entity, name)) {
				return entity;
			}
		}
	}

	return INVALID_ENT_REFERENCE;
}

/**
 * Finds an entity by its HammerID.
 * The newer version of Valve's Hammer editor
 * sets a unique ID for each entity in a map.
 * It only finds the first occurence.
 * Note: If the classname is specified it uses The Sourcemod native
 * function FindEntityByClassname() which uses the engine's
 * linked entity list for finding entities. This might be
 * cheaper, use this if you call this function very often.
 *
 * @param hammerId		Hammer editor ID
 * @param className		Optional: Classname of the entity
 * @return				Edict Index or INVALID_ENT_REFERENCE if no entity was found.
 */
stock int Entity_FindByHammerId(int hammerId, const char[] className="")
{
	if (className[0] == '\0') {
		// Hack: Double the limit to gets none-networked entities too.
		int realMaxEntities = GetMaxEntities() * 2;
		for (int entity=0; entity < realMaxEntities; entity++) {

			if (!IsValidEntity(entity)) {
				continue;
			}

			if (Entity_GetHammerId(entity) == hammerId) {
				return entity;
			}
		}
	}
	else {
		int entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, className)) != INVALID_ENT_REFERENCE) {

			if (Entity_GetHammerId(entity) == hammerId) {
				return entity;
			}
		}
	}

	return INVALID_ENT_REFERENCE;
}

/**
 * Searches for an entity by classname.
 * This is a wrapper around FindEntityByClassname
 * and has been added for completion.
 *
 * @param startEnt		The entity index after which to begin searching from. Use -1 to start from the first entity.
 * @param classname		Classname of the entity to find.
 * @return				Entity index >= 0 if found, -1 otherwise.
 */

stock int Entity_FindByClassName(int startEntity, const char[] className)
{
	return FindEntityByClassname(startEntity, className);
}

/**
 * Checks if an entity (partially) matches a specific entity class.
 *
 * @param entity		Entity Index.
 * @param className		Classname String.
 * @partialMatch		If to do a partial classname check.
 * @return				True if the classname matches, false otherwise.
 */
stock bool Entity_ClassNameMatches(int entity, const char[] className, bool partialMatch=false)
{
	char entity_className[64];
	Entity_GetClassName(entity, entity_className, sizeof(entity_className));

	if (partialMatch) {
		return (StrContains(entity_className, className) != -1);
	}

	return StrEqual(entity_className, className);
}

/**
 * Checks if an entity matches a name
 *
 * @param entity		Entity Index.
 * @param class			Name String.
 * @return				True if the name matches, false otherwise.
 */
stock bool Entity_NameMatches(int entity, const char[] name)
{
	char entity_name[128];
	Entity_GetName(entity, entity_name, sizeof(entity_name));

	return StrEqual(name, entity_name);
}

/**
 * Gets the Name of an entity.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock int Entity_GetName(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_iName", buffer, size);
}

/**
 * Sets the Name of an entity.
 *
 * @param entity			Entity index.
 * @param name				The name you want to give.
 * @return					True on success, false otherwise.
 */
stock bool Entity_SetName(int entity, const char[] name, any ...)
{
	char format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "targetname", format);
}

/**
 * Gets the Classname of an entity.
 * This is like GetEdictClassname(), except it works for ALL
 * entities, not just edicts.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock int Entity_GetClassName(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_iClassname", buffer, size);
}

/**
 * Sets the Classname of an entity.
 *
 * @param entity			Entity index.
 * @param name				The name you want to give.
 * @return					True on success, false otherwise.
 */
stock bool Entity_SetClassName(int entity, const char[] className)
{
	return DispatchKeyValue(entity, "classname", className);
}

/**
 * Gets the Target name of an other entity
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock int Entity_GetTargetName(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_target", buffer, size);
}

/**
 * Sets the Target name of an other Entity
 *
 * @param entity			Entity index.
 * @param name				The target name you want to set
 * @return					True on success, false otherwise.
 */
stock bool Entity_SetTargetName(int entity, const char[] name, any ...)
{
	char format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "target", format);
}

/**
 * Gets the Global Name of an entity.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock int Entity_GetGlobalName(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_iGlobalname", buffer, size);
}

/**
 * Sets the Global Name of an entity.
 *
 * @param entity			Entity index.
 * @param name				The global name you want to set.
 * @return					True on success, false otherwise.
 */
stock bool Entity_SetGlobalName(int entity, const char[] name, any ...)
{
	char format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "globalname", format);
}

/**
 * Gets the Parent name of an entity.
 *
 * @param entity			Entity index.
 * @param buffer			Return/Output buffer.
 * @param size				Max size of buffer.
 * @return					Number of non-null bytes written.
 */
stock int Entity_GetParentName(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_iParent", buffer, size);
}

/**
 * Sets the Parent name of an entity.
 *
 * @param entity			Entity index.
 * @param name				The parent name you want to set.
 * @return					True on success, false otherwise.
 */
stock bool Entity_SetParentName(int entity, const char[] name, any ...)
{
	char format[128];
	VFormat(format, sizeof(format), name, 3);

	return DispatchKeyValue(entity, "parentname", format);
}

/**
 * Gets the Hammer-ID of an entity.
 * The Hammer Editor gives every entity a unique ID.
 * Note: Old maps don't have Hammer-ID's set for entities
 *
 * @param entity			Entity index.
 * @return					Hammer ID.
 */
stock int Entity_GetHammerId(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iHammerID");
}

/**
 * Gets the radius (m_flRadius) of an entity.
 *
 * @param entity			Entity index.
 * @return					Radius
 */
stock float Entity_GetRadius(int entity)
{
	return GetEntPropFloat(entity, Prop_Data, "m_flRadius");
}

/**
 * Sets the radius (m_flRadius) of an entity.
 *
 * @param entity			Entity index.
 * @param radius			Radius value
 */
stock void Entity_SetRadius(int entity, float radius)
{
	SetEntPropFloat(entity, Prop_Data, "m_flRadius", radius);
}

/**
 * Gets the Mins of an entity.
 *
 * @param entity			Entity index.
 * @param vec				Buffer to hold the vector.
 */
stock void Entity_GetMinSize(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecMins", vec);
}

/**
 * Sets the Mins of an entity.
 *
 * @param entity			Entity index.
 * @param vec				Vector.
 */
stock void Entity_SetMinSize(int entity, const float vecMins[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vecMins);
}

/**
 * Gets the Mins of an entity.
 * This functions isn't safe to use, use Entity_SetMinMaxSize() instead.
 *
 * @param entity			Entity index
 * @param vec				Buffer to hold the vector
 */
stock void Entity_GetMaxSize(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vec);
}

/**
 * Sets the Maxs of an entity.
 * This functions isn't safe to use, use Entity_SetMinMaxSize() instead.
 *
 * @param entity			Entity index.
 * @param vec				Buffer to hold the vector.
 */
stock void Entity_SetMaxSize(int entity, const float vecMaxs[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecMaxs);
}

/**
 * Sets the Min and Max Size of an entity.
 * Code is taken from HL2SDK and rewritten for Sourcemod.
 *
 * @param entity			Entity index.
 * @param vecMins			Min size Vector
 * @param vecMaxs			Max size Vector
 */
stock void Entity_SetMinMaxSize(int entity, float vecMins[3], float vecMaxs[3])
{
	// Taken from hl2sdk-ob-valve\game\server\util.cpp SetMinMaxSize()
	// Todo: Replace this by a SDK call
	for (int i=0; i<3; i++) {

		if (vecMins[i] > vecMaxs[i]) {
			ThrowError("Error: mins[%d] > maxs[%d] of entity %d", i, i, EntRefToEntIndex(entity));
		}
	}

	float m_vecMins[3], m_vecMaxs[3];
	Entity_GetMinSize(entity, m_vecMins);
	Entity_GetMaxSize(entity, m_vecMaxs);

	if (Math_VectorsEqual(m_vecMins, vecMins) && Math_VectorsEqual(m_vecMaxs, vecMaxs)) {
		return;
	}

	Entity_SetMinSize(entity, vecMins);
	Entity_SetMaxSize(entity, vecMaxs);

	float vecSize[3];
	SubtractVectors(vecMaxs, vecMins, vecSize);
	Entity_SetRadius(entity, GetVectorLength(vecSize) * 0.5);

	Entity_MarkSurrBoundsDirty(entity);
}

/*
 * Spawn Flags
 * Many entities define their specific spawnflags, check the HL2SDK.
 */

/*
 * Phys prop spawnflags
 * Taken from hl2sdk-ob-valve\game\shared\props_shared.h
 */
#define SF_PHYSPROP_START_ASLEEP				0x000001
#define SF_PHYSPROP_DONT_TAKE_PHYSICS_DAMAGE	0x000002		// this prop can't be damaged by physics collisions
#define SF_PHYSPROP_DEBRIS						0x000004
#define SF_PHYSPROP_MOTIONDISABLED				0x000008		// motion disabled at startup (flag only valid in spawn - motion can be enabled via input)
#define	SF_PHYSPROP_TOUCH						0x000010		// can be 'crashed through' by running player (plate glass)
#define SF_PHYSPROP_PRESSURE					0x000020		// can be broken by a player standing on it
#define SF_PHYSPROP_ENABLE_ON_PHYSCANNON		0x000040		// enable motion only if the player grabs it with the physcannon
#define SF_PHYSPROP_NO_ROTORWASH_PUSH			0x000080		// The rotorwash doesn't push these
#define SF_PHYSPROP_ENABLE_PICKUP_OUTPUT		0x000100		// If set, allow the player to +USE this for the purposes of generating an output
#define SF_PHYSPROP_PREVENT_PICKUP				0x000200		// If set, prevent +USE/Physcannon pickup of this prop
#define SF_PHYSPROP_PREVENT_PLAYER_TOUCH_ENABLE	0x000400		// If set, the player will not cause the object to enable its motion when bumped into
#define SF_PHYSPROP_HAS_ATTACHED_RAGDOLLS		0x000800		// Need to remove attached ragdolls on enable motion/etc
#define SF_PHYSPROP_FORCE_TOUCH_TRIGGERS		0x001000		// Override normal debris behavior and respond to triggers anyway
#define SF_PHYSPROP_FORCE_SERVER_SIDE			0x002000		// Force multiplayer physics object to be serverside
#define SF_PHYSPROP_RADIUS_PICKUP				0x004000		// For Xbox, makes small objects easier to pick up by allowing them to be found
#define SF_PHYSPROP_ALWAYS_PICK_UP				0x100000		// Physcannon can always pick this up, no matter what mass or constraints may apply.
#define SF_PHYSPROP_NO_COLLISIONS				0x200000		// Don't enable collisions on spawn
#define SF_PHYSPROP_IS_GIB						0x400000		// Limit # of active gibs

/*
 * Physbox Spawnflags. Start at 0x01000 to avoid collision with CBreakable's
 * Taken from hl2sdk-ob-valve\game\server\physobj.h
 */
#define SF_PHYSBOX_ASLEEP						0x01000
#define SF_PHYSBOX_IGNOREUSE					0x02000
#define SF_PHYSBOX_DEBRIS						0x04000
#define SF_PHYSBOX_MOTIONDISABLED				0x08000
#define SF_PHYSBOX_USEPREFERRED					0x10000
#define SF_PHYSBOX_ENABLE_ON_PHYSCANNON			0x20000
#define SF_PHYSBOX_NO_ROTORWASH_PUSH			0x40000			// The rotorwash doesn't push these
#define SF_PHYSBOX_ENABLE_PICKUP_OUTPUT			0x80000
#define SF_PHYSBOX_ALWAYS_PICK_UP		  		0x100000		// Physcannon can always pick this up, no matter what mass or constraints may apply.
#define SF_PHYSBOX_NEVER_PICK_UP				0x200000		// Physcannon will never be able to pick this up.
#define SF_PHYSBOX_NEVER_PUNT					0x400000		// Physcannon will never be able to punt this object.
#define SF_PHYSBOX_PREVENT_PLAYER_TOUCH_ENABLE	0x800000		// If set, the player will not cause the object to enable its motion when bumped into

/*
 * Spawnflags for func breakable
 * Taken from hl2sdk-ob-valve\game\server\func_break.h
 */
#define SF_BREAK_TRIGGER_ONLY				0x0001	// may only be broken by trigger
#define	SF_BREAK_TOUCH						0x0002	// can be 'crashed through' by running player (plate glass)
#define SF_BREAK_PRESSURE					0x0004	// can be broken by a player standing on it
#define SF_BREAK_PHYSICS_BREAK_IMMEDIATELY	0x0200	// the first physics collision this breakable has will immediately break it
#define SF_BREAK_DONT_TAKE_PHYSICS_DAMAGE	0x0400	// this breakable doesn't take damage from physics collisions
#define SF_BREAK_NO_BULLET_PENETRATION		0x0800  // don't allow bullets to penetrate

/*
 * Spawnflags for func_pushable (it's also func_breakable, so don't collide with those flags)
 * Taken from hl2sdk-ob-valve\game\server\func_break.h
 */
#define SF_PUSH_BREAKABLE					0x0080
#define SF_PUSH_NO_USE						0x0100	// player cannot +use pickup this ent

/**
 * Gets the Spawnflags of an entity.
 *
 * @param entity			Entity index.
 * @return					Spawnflags value
 */
stock int Entity_GetSpawnFlags(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_spawnflags");
}

/**
 * Sets the Spawnflags of an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 */
stock void Entity_SetSpawnFlags(int entity, int flags)
{
	SetEntProp(entity, Prop_Data, "m_spawnflags", flags);
}

/**
 * Adds Spawnflags to an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 */
stock void Entity_AddSpawnFlags(int entity, int flags)
{
	int spawnFlags = Entity_GetSpawnFlags(entity);
	spawnFlags |= flags;
	Entity_SetSpawnFlags(entity, spawnFlags);
}

/**
 * Removes Spawnflags from an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 */
stock void Entity_RemoveSpawnFlags(int entity, int flags)
{
	int spawnFlags = Entity_GetSpawnFlags(entity);
	spawnFlags &= ~flags;
	Entity_SetSpawnFlags(entity, spawnFlags);
}

/**
 * Clears all Spawnflags of an entity.
 *
 * @param entity			Entity index.
 * @noretur */
stock void Entity_ClearSpawnFlags(int entity)
{
	Entity_SetSpawnFlags(entity, 0);
}

/**
 * Returns whether the entity has specific Spawnflags.
 *
 * @param entity			Entity index.
 * @param flags				Flags value.
 * @return					True if the entity has the spawnflags set, false otherwise.
 */
stock bool Entity_HasSpawnFlags(int entity, int flags)
{
	return Entity_GetSpawnFlags(entity) & flags == flags;
}

/*
 * Entity flags, CBaseEntity::m_iEFlags
 * Taken from: hl2sdk-ob-valve\game\shared\shareddefs.h
 */
enum Entity_Flags
{
	EFL_KILLME =							(1<<0),	// This entity is marked for death -- This allows the game to actually delete ents at a safe time
	EFL_DORMANT	=							(1<<1),	// Entity is dormant, no updates to client
	EFL_NOCLIP_ACTIVE =						(1<<2),	// Lets us know when the noclip command is active.
	EFL_SETTING_UP_BONES =					(1<<3),	// Set while a model is setting up its bones.
	EFL_KEEP_ON_RECREATE_ENTITIES = 		(1<<4), // This is a special entity that should not be deleted when we restart entities only

	EFL_HAS_PLAYER_CHILD=					(1<<4),	// One of the child entities is a player.

	EFL_DIRTY_SHADOWUPDATE =				(1<<5),	// Client only- need shadow manager to update the shadow...
	EFL_NOTIFY =							(1<<6),	// Another entity is watching events on this entity (used by teleport)

	// The default behavior in ShouldTransmit is to not send an entity if it doesn't
	// have a model. Certain entities want to be sent anyway because all the drawing logic
	// is in the client DLL. They can set this flag and the engine will transmit them even
	// if they don't have a model.
	EFL_FORCE_CHECK_TRANSMIT =				(1<<7),

	EFL_BOT_FROZEN =						(1<<8),	 // This is set on bots that are frozen.
	EFL_SERVER_ONLY =						(1<<9),	 // Non-networked entity.
	EFL_NO_AUTO_EDICT_ATTACH =				(1<<10), // Don't attach the edict; we're doing it explicitly

	// Some dirty bits with respect to abs computations
	EFL_DIRTY_ABSTRANSFORM =				(1<<11),
	EFL_DIRTY_ABSVELOCITY =					(1<<12),
	EFL_DIRTY_ABSANGVELOCITY =				(1<<13),
	EFL_DIRTY_SURR_COLLISION_BOUNDS =		(1<<14),
	EFL_DIRTY_SPATIAL_PARTITION = 			(1<<15),
//	UNUSED						=			(1<<16),

	EFL_IN_SKYBOX =							(1<<17), // This is set if the entity detects that it's in the skybox.
													 // This forces it to pass the "in PVS" for transmission.
	EFL_USE_PARTITION_WHEN_NOT_SOL = 		(1<<18), // Entities with this flag set show up in the partition even when not solid
	EFL_TOUCHING_FLUID =					(1<<19), // Used to determine if an entity is floating

	// FIXME: Not really sure where I should add this...
	EFL_IS_BEING_LIFTED_BY_BARNACLE =		(1<<20),
	EFL_NO_ROTORWASH_PUSH =					(1<<21), // I shouldn't be pushed by the rotorwash
	EFL_NO_THINK_FUNCTION =					(1<<22),
	EFL_NO_GAME_PHYSICS_SIMULATION =		(1<<23),

	EFL_CHECK_UNTOUCH =						(1<<24),
	EFL_DONTBLOCKLOS =						(1<<25), // I shouldn't block NPC line-of-sight
	EFL_DONTWALKON =						(1<<26), // NPC;s should not walk on this entity
	EFL_NO_DISSOLVE =						(1<<27), // These guys shouldn't dissolve
	EFL_NO_MEGAPHYSCANNON_RAGDOLL =			(1<<28), // Mega physcannon can't ragdoll these guys.
	EFL_NO_WATER_VELOCITY_CHANGE =			(1<<29), // Don't adjust this entity's velocity when transitioning into water
	EFL_NO_PHYSCANNON_INTERACTION =			(1<<30), // Physcannon can't pick these up or punt them
	EFL_NO_DAMAGE_FORCES =					(1<<31), // Doesn't accept forces from physics damage
};

/**
 * Gets the Entity flags (m_iEFlags) of an entity.
 *
 * @param entity			Entity index.
 * @return					Entity flags value
 */
stock Entity_Flags Entity_GetEFlags(int entity)
{
	return view_as<Entity_Flags>(GetEntProp(entity, Prop_Data, "m_iEFlags"));
}

/**
 * Sets the entity's Entity flags (m_iEFlags).
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 */
stock void Entity_SetEFlags(int entity, Entity_Flags flags)
{
	SetEntProp(entity, Prop_Data, "m_iEFlags", flags);
}

/**
 * Adds Entity flags (m_iEFlags) to an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 */
stock void Entity_AddEFlags(int entity, Entity_Flags flags)
{
	Entity_Flags setFlags = Entity_GetEFlags(entity);
	setFlags |= flags;
	Entity_SetEFlags(entity, setFlags);
}

/**
 * Removes Entity flags (m_iEFlags) from an entity.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 */
stock void Entity_RemoveEFlags(int entity, Entity_Flags flags)
{
	Entity_Flags setFlags = Entity_GetEFlags(entity);
	setFlags &= ~flags;
	Entity_SetEFlags(entity, setFlags);
}

/**
 * Checks if the entity has specific Entity flags (m_iEFlags) set.
 *
 * @param entity			Entity index.
 * @param flags				Flags value
 * @return					True if the flags are set, false otherwise.
 */
stock bool Entity_HasEFlags(int entity, Entity_Flags flags)
{
	Entity_Flags currentEFlags = Entity_GetEFlags(entity);

	return currentEFlags & flags == flags;
}

/**
 * Marks the surrounding bounds of an entity as outdated.
 * You normally call this when a collision setting has changed.
 *
 * @param entity			Entity index.
 */
stock void Entity_MarkSurrBoundsDirty(int entity)
{
	Entity_AddEFlags(entity, EFL_DIRTY_SURR_COLLISION_BOUNDS);
}

/*
 * CBaseEntity::m_fFlags Functions
 * Use the FL_ Defines (FL_ONGROUND, ...) or
 * special entity specific flags.
 * Note: The flag FL_AIMTARGET probably doesn't work as
 * we have current no way of adding/removing it to the AimTarget List.
 */

/**
 * Gets the Flags of an entity.
 *
 * @param entity			Entity Index.
 * @return					Entity Flags.
 */
stock int Entity_GetFlags(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_fFlags");
}

/**
 * Sets the Flags of an entity.
 *
 * @param entity			Entity index.
 * @param flags				New Flags value
 */
stock void Entity_SetFlags(int entity, int flags)
{
	SetEntProp(entity, Prop_Data, "m_fFlags", flags);
}

/**
 * Adds Flags to the entity
 *
 * @param entity			Entity index.
 * @param flags				Flags to add
 * @noreturn
 */
stock void Entity_AddFlags(int entity, int flags)
{
	int setFlags = Entity_GetFlags(entity);
	setFlags |= flags;
	Entity_SetFlags(entity, setFlags);
}

/**
 * Removes flags from the entity
 *
 * @param entity			Entity index.
 * @param flags				Flags to remove
 */
stock void Entity_RemoveFlags(int entity, int flags)
{
	int setFlags = Entity_GetFlags(entity);
	setFlags &= ~flags;
	Entity_SetFlags(entity, setFlags);
}

/**
 * Toggles the specified flag on the entity.
 * Adds the flag to the entity if it doesn't exists
 * or removes it otherwise.
 *
 * @param entity			Entity index.
 * @param flags				Flag to Toggle
 */
stock void Entity_ToggleFlag(int entity, int flag)
{
	int setFlag = Entity_GetFlags(entity);
	setFlag ^= flag;
	Entity_SetFlags(entity, setFlag);
}

/**
 * Removes all flags from the entity
 *
 * @param entity			Entity index.
 */
stock void Entity_ClearFlags(int entity)
{
	Entity_SetFlags(entity, 0);
}

/* edict->solid values
 * NOTE: Some movetypes will cause collisions independent of SOLID_NOT/SOLID_TRIGGER when the entity moves
 * SOLID only effects OTHER entities colliding with this one when they move - UGH!
 *
 * Solid type basically describes how the bounding volume of the object is represented
 * NOTE: These numerical values are used in the FGD by the prop code (see prop_dynamic)
 * Taken from: hl2sdk-ob-valve\public\const.h
 */

enum SolidFlags_t
{
	FSOLID_CUSTOMRAYTEST		= 0x0001,	// Ignore solid type + always call into the entity for ray tests
	FSOLID_CUSTOMBOXTEST		= 0x0002,	// Ignore solid type + always call into the entity for swept box tests
	FSOLID_NOT_SOLID			= 0x0004,	// Are we currently not solid?
	FSOLID_TRIGGER				= 0x0008,	// This is something may be collideable but fires touch functions
											// even when it's not collideable (when the FSOLID_NOT_SOLID flag is set)
	FSOLID_NOT_STANDABLE		= 0x0010,	// You can't stand on this
	FSOLID_VOLUME_CONTENTS		= 0x0020,	// Contains volumetric contents (like water)
	FSOLID_FORCE_WORLD_ALIGNED	= 0x0040,	// Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS
	FSOLID_USE_TRIGGER_BOUNDS	= 0x0080,	// Uses a special trigger bounds separate from the normal OBB
	FSOLID_ROOT_PARENT_ALIGNED	= 0x0100,	// Collisions are defined in root parent's local coordinate space
	FSOLID_TRIGGER_TOUCH_DEBRIS	= 0x0200,	// This trigger will touch debris objects

	FSOLID_MAX_BITS	= 10
};

/**
 * Gets the solid flags of the entity
 *
 * @param entity			Entity index.
 * @return					Solid Flags.
 */
stock SolidFlags_t Entity_GetSolidFlags(int entity)
{
	return view_as<SolidFlags_t>(GetEntProp(entity, Prop_Data, "m_usSolidFlags", 2));
}

/**
 * Sets the solid flags of the entity
 *
 * @param entity			Entity index.
 * @param flags				Solid Flags.
 */
stock void Entity_SetSolidFlags(int entity, SolidFlags_t flags)
{
	SolidFlags_t oldFlags = Entity_GetSolidFlags(entity);
	flags = flags & view_as<SolidFlags_t>(0xFFFF);

	if (oldFlags == flags) {
		return;
	}

	SetEntProp(entity, Prop_Data, "m_usSolidFlags", flags, 2);

	// These two flags, if changed, can produce different surrounding bounds
	if ((oldFlags & (FSOLID_FORCE_WORLD_ALIGNED | FSOLID_USE_TRIGGER_BOUNDS)) !=
			(flags & (FSOLID_FORCE_WORLD_ALIGNED | FSOLID_USE_TRIGGER_BOUNDS)))
	{
		Entity_MarkSurrBoundsDirty(entity);
	}
}

/**
 * Adds solid flags to the entity
 *
 * @param entity			Entity index.
 * @param flags				Solid Flags.
 */
stock void Entity_AddSolidFlags(int entity, SolidFlags_t flags)
{
	SolidFlags_t newFlags = Entity_GetSolidFlags(entity);
	newFlags |= flags;
	Entity_SetSolidFlags(entity, newFlags);
}

/**
 * Removes solid flags from the entity.
 *
 * @param entity			Entity index.
 * @param flags				Solid Flags.
 */
stock void Entity_RemoveSolidFlags(int entity, SolidFlags_t flags)
{
	SolidFlags_t newFlags = Entity_GetSolidFlags(entity);
	newFlags &= ~flags;
	Entity_SetSolidFlags(entity, newFlags);
}

/**
 * Removes all solid flags from the entity.
 *
 * @param entity			Entity index.
 */
stock void Entity_ClearSolidFlags(int entity)
{
	Entity_SetSolidFlags(entity, view_as<SolidFlags_t>(0));
}

/**
 * Checks whether certain solid flags are set on the entity.
 *
 * @param entity			Entity index.
 * @param flags				Solid Flags.
 * @return					True if the specified flags are set, false otherwise.
 */
stock bool Entity_SolidFlagsSet(int entity, SolidFlags_t flagMask)
{
	return Entity_GetSolidFlags(entity) & flagMask == flagMask;
}

enum SolidType_t
{
	SOLID_NONE			= 0,	// no solid model
	SOLID_BSP			= 1,	// a BSP tree
	SOLID_BBOX			= 2,	// an AABB
	SOLID_OBB			= 3,	// an OBB (not implemented yet)
	SOLID_OBB_YAW		= 4,	// an OBB, constrained so that it can only yaw
	SOLID_CUSTOM		= 5,	// Always call into the entity for tests
	SOLID_VPHYSICS		= 6,	// solid vphysics object, get vcollide from the model and collide with that
	SOLID_LAST,
};

/**
 * Gets the solidity type of the entity
 *
 * @param entity			Entity index.
 * @return					Solid Type
 */
stock SolidType_t Entity_GetSolidType(int entity)
{
	return view_as<SolidType_t>(GetEntProp(entity, Prop_Data, "m_nSolidType", 1));
}

/**
 * Sets the solidity type of the entity
 *
 * @param entity			Entity index.
 * @param					Solid Type value.
 */
stock void Entity_SetSolidType(int entity, SolidType_t value)
{
	SetEntProp(entity, Prop_Send, "m_nSolidType", value, 1);
	Entity_MarkSurrBoundsDirty(entity);
}

/**
 * Checks whether the entity is solid or not.
 *
 * @param entity			Entity index.
 * @return					True if the entity is solid, false otherwise.
 */
stock bool Entity_IsSolid(int entity)
{
	return (Entity_GetSolidType(entity) != SOLID_NONE &&
			!Entity_SolidFlagsSet(entity, FSOLID_NOT_SOLID));
}

/**
 * Retrieves the model path of a given entity.
 * Returns "*num" for Brush entities.
 *
 * @param entity		entity reference or index
 * @param model			buffer String for the model
 * @param size			max size of buffer string
 * @return				Number of non-null bytes written.
 */
stock int Entity_GetModel(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_ModelName", buffer, size);
}

/**
 * Sets the model to a given entity.
 * Be sure it has been precached.
 * This is an alias for SetEntityModel()
 *
 * @param entity		Entity index
 * @param model			Model name
 */
stock void Entity_SetModel(int entity, const char[] model)
{
	SetEntityModel(entity, model);
}

/**
 * Gets the entity's model index, if it has one set.
 *
 * @param entity			Entity index.
 * @return					The Entity's model index
 */
stock int Entity_GetModelIndex(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_nModelIndex", 2);
}

/**
 * Sets the entity's model index (must be precached)
 *
 * @param entity			Entity index.
 * @param index				Model Index.
 */
stock void Entity_SetModelIndex(int entity, int index)
{
	SetEntProp(entity, Prop_Data, "m_nModelIndex", index, 2);
}

/**
* Sets the entity's maxspeed to the given value (in units per second)
*
* @param entity		Entity index
* @param maxspeed	the maximum speed the entity can move
* @noreturn
*/
stock void Entity_SetMaxSpeed(int entity, float value)
{
	SetEntPropFloat(entity, Prop_Data, "m_flMaxspeed", value);
}

/*
 * Collision groups
 * Taken from hl2sdk-ob-valve/public/const.h
 */
enum Collision_Group_t
{
	COLLISION_GROUP_NONE  = 0,
	COLLISION_GROUP_DEBRIS,				// Collides with nothing but world and static stuff
	COLLISION_GROUP_DEBRIS_TRIGGER,		// Same as debris, but hits triggers
	COLLISION_GROUP_INTERACTIVE_DEB,	// Collides with everything except other interactive debris or debris
	COLLISION_GROUP_INTERACTIVE,		// Collides with everything except interactive debris or debris
	COLLISION_GROUP_PLAYER,
	COLLISION_GROUP_BREAKABLE_GLASS,
	COLLISION_GROUP_VEHICLE,
	COLLISION_GROUP_PLAYER_MOVEMENT,	// For HL2, same as Collision_Group_Player, for
										// TF2, this filters out other players and CBaseObjects
	COLLISION_GROUP_NPC,				// Generic NPC group
	COLLISION_GROUP_IN_VEHICLE,			// for any entity inside a vehicle
	COLLISION_GROUP_WEAPON,				// for any weapons that need collision detection
	COLLISION_GROUP_VEHICLE_CLIP,		// vehicle clip brush to restrict vehicle movement
	COLLISION_GROUP_PROJECTILE,			// Projectiles!
	COLLISION_GROUP_DOOR_BLOCKER,		// Blocks entities not permitted to get near moving doors
	COLLISION_GROUP_PASSABLE_DOOR,		// Doors that the player shouldn't collide with
	COLLISION_GROUP_DISSOLVING,			// Things that are dissolving are in this group
	COLLISION_GROUP_PUSHAWAY,			// Nonsolid on client and server, pushaway in player code

	COLLISION_GROUP_NPC_ACTOR,			// Used so NPCs in scripts ignore the player.
	COLLISION_GROUP_NPC_SCRIPTED		// USed for NPCs in scripts that should not collide with each other
};

/**
 * Gets the collision group of an entity.
 *
 * @param entity		entity index
 * @return				Entity collision group.
 */
stock Collision_Group_t Entity_GetCollisionGroup(int entity)
{
	return view_as<Collision_Group_t>(GetEntProp(entity, Prop_Data, "m_CollisionGroup"));
}

/**
 * Sets the collision group of an entity.
 *
 * @param entity		entity index
 * @param value			the new collision group.
 */
stock void Entity_SetCollisionGroup(int entity, Collision_Group_t value)
{
	SetEntProp(entity, Prop_Data, "m_CollisionGroup", value);
}

/**
 * Functions for getting / setting the origin (position) of an entity.
 * Go to http://developer.valvesoftware.com/wiki/Origin
 * if you want to learn more about origins
 */

/**
 * Gets the Absolute Origin (position) of an entity.
 *
 * @param entity			Entity index.
 * @param vec				3 dimensional vector array.
 */
stock void Entity_GetAbsOrigin(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vec);
}

/**
 * Sets the Absolute Origin (position) of an entity.
 *
 * @param entity			Entity index.
 * @param vec				3 dimensional vector array.
 */
stock void Entity_SetAbsOrigin(int entity, const float vec[3])
{
	// We use TeleportEntity to set the origin more safely
	// Todo: Replace this with a call to UTIL_SetOrigin() or CBaseEntity::SetLocalOrigin()
	TeleportEntity(entity, vec, NULL_VECTOR, NULL_VECTOR);
}

/**
 * Functions for getting / setting the angles (rotation) of an entity.
 * http://developer.valvesoftware.com/wiki/Angles
 * if you want to learn more about angles
 */

/**
 * Gets the Angles of an entity
 *
 * @param entity			Entity index.
 * @param vec				3 dimensional vector array.
 * @noreturn
 */
stock void Entity_GetAbsAngles(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_angAbsRotation", vec);
}

/**
 * Sets the Angles of an entity
 *
 * @param entity			Entity index.
 * @param vec				3 dimensional vector array.
 */
stock void Entity_SetAbsAngles(int entity, const float vec[3])
{
	// We use TeleportEntity to set the angles more safely
	// Todo: Replace this with a call to CBaseEntity::SetLocalAngles()
	TeleportEntity(entity, NULL_VECTOR, vec, NULL_VECTOR);
}

/**
 * Functions for getting / setting the velocity of an entity.
 * Go to http://developer.valvesoftware.com/wiki/Velocity
 * if you want to learn more about the different kind of velocities.
 */

/**
 * Gets the Local velocity of an entity.
 * The local velocity is the velocity generated by the entity.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 */
stock void Entity_GetLocalVelocity(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vec);
}

/**
 * Sets the Local velocity of an entity.
 * The local velocity is the velocity generated by the entity.
 * Only use this if you know what you are doing,
 * the entity can overwrite this value on next frame.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 */
stock void Entity_SetLocalVelocity(int entity, const float vec[3])
{
	SetEntPropVector(entity, Prop_Data, "m_vecVelocity", vec);
}

/**
 * Gets the Base velocity of an entity.
 * The base velocity is the velocity applied
 * to the entity from other sources .
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 */
stock void Entity_GetBaseVelocity(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecBaseVelocity", vec);
}

/**
 * Sets the Base velocity of an entity.
 * The base velocity is the velocity applied
 * to the entity from other sources .
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 */
stock void Entity_SetBaseVelocity(int entity, const float vec[3])
{
	SetEntPropVector(entity, Prop_Data, "m_vecBaseVelocity", vec);
}

/**
 * Gets the Absolute velocity of an entity.
 * The absolute velocity is the sum of the local
 * and base velocities. It's the actual value used to move.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 */
stock void Entity_GetAbsVelocity(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vec);
}

/**
 * Sets the Absolute velocity of an entity.
 * The absolute velocity is the sum of the local
 * and base velocities. It's the actual value used to move.
 *
 * @param entity		Entity index.
 * @param vel			An 3 dim array
 */
stock void Entity_SetAbsVelocity(int entity, const float vec[3])
{
	// We use TeleportEntity to set the velocity more safely
	// Todo: Replace this with a call to CBaseEntity::SetAbsVelocity()
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vec);
}

/**
 * Returns true if the entity is locked.
 *
 * @param entity		Entity index.
 * @return				True if locked otherwise false.
 */
stock bool Entity_IsLocked(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_bLocked", 1) != 0;
}

/**
 * Locks an entity.
 *
 * @param entity		Entity index.
 */
stock void Entity_Lock(int entity)
{
	SetEntProp(entity, Prop_Data, "m_bLocked", 1, 1);
}
/**
 * Unlocks an entity.
 *
 * @param entity		Entity index.
 */
stock void Entity_UnLock(int entity)
{
	SetEntProp(entity, Prop_Data, "m_bLocked", 0, 1);
}

/**
 * Gets the health of an entity.
 *
 * @param entity			entity index.
 * @return				current health points
 */
stock int Entity_GetHealth(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iHealth");
}

/**
 * Sets the health of an entity.
 *
 * @param entity		Entity index.
 * @param value			Health to set (anything above 511 will overload)
 * @param ignoreMax		Ignore the entity's maxhealth setting.
 * @param kill			Kill the entity if health gets to 0.
 * @return				The health the entity actually got set to.
 */
stock int Entity_SetHealth(int entity, int value, bool ignoreMax=false, bool kill=true)
{
	int health = value;

	if (!ignoreMax) {
		int maxHealth = Entity_GetMaxHealth(entity);

		if (health > maxHealth) {
			health = maxHealth;
		}
	}

	if (health < 0) {
		health = 0;
	}

	SetEntProp(entity, Prop_Data, "m_iHealth", health);

	if (health <= 0 && kill) {
		Entity_Kill(entity);
	}

	return health;
}

/**
 * Add health to an entity
 *
 * @param entity		Entity index
 * @param value			Health to add
 * @param ignoreMax		Ignore the entity's maxhealth setting.
 * @param kill			Kill the entity if health gets to 0.
 * @return				Returns the new health value set
 */
stock int Entity_AddHealth(int entity, int value, bool ignoreMax=false, bool kill=true)
{
	int health = Entity_GetHealth(entity);

	health += value;

	return Entity_SetHealth(entity, health, ignoreMax, kill);
}

/**
 * Takes health from an entity
 *
 * @param entity		entity index
 * @param value			health to add
 * @return				returns the new health value set
 */
stock int Entity_TakeHealth(int entity, int value, bool ignoreMax=false, bool kill=true)
{
	int health = Entity_GetHealth(entity);

	health -= value;

	return Entity_SetHealth(entity, health, ignoreMax, kill);
}

/**
 * Get the max health of an entity
 *
 * @param entity		Entity Index
 * @return				Max health points
 */
stock int Entity_GetMaxHealth(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iMaxHealth");
}


/**
 * Set the max health of an entity.
 *
 * @param entity		Entity index
 * @param value			Max health to set (anything above 511 will overload)
 */
stock void Entity_SetMaxHealth(int entity, int value)
{
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", value);
}

/**
 * Returns the Float distance between an entity
 * and a vector origin.
 *
 * @param entity		Entity Index.
 * @param target		Vector Origin.
 * @return				Distance Float value.
 */
stock float Entity_GetDistanceOrigin(int entity, const float vec[3])
{
	float entityVec[3];
	Entity_GetAbsOrigin(entity, entityVec);

	return GetVectorDistance(entityVec, vec);
}

/**
 * Returns the Float distance between two entities.
 * Both entities must be valid.
 *
 * @param entity		Entity Index.
 * @param target		Target Entity Index.
 * @return				Distance Float value.
 */
stock float Entity_GetDistance(int entity, int target)
{
	float targetVec[3];
	Entity_GetAbsOrigin(target, targetVec);

	return Entity_GetDistanceOrigin(entity, targetVec);
}

/**
 * Checks if the given 2 entitys are within a given range.
 *
 * @param entity		Entity Index.
 * @param target		Target Entity Index.
 * @param distance		Max Float distance.
 * @return				True if the given entities are closer than the given distance value, false otherwise.
 */
stock bool Entity_InRange(int entity, int target, float distance)
{
	if (Entity_GetDistance(entity, target) > distance) {
		return false;
	}

	return true;
}

/**
 * Enables the motion of an entity.
 *
 * @param entity		Entity index.
 * @return				True on success, false otherwise
 */
stock bool Entity_EnableMotion(int entity)
{
	return AcceptEntityInput(entity, "enablemotion");
}

/**
 * Disables the motion of an entity.
 *
 * @param entity		Entity index.
 * @return 				True on success, false otherwise
 */
stock bool Entity_DisableMotion(int entity)
{
	return AcceptEntityInput(entity, "disablemotion");
}

/**
 * Freezes an entity by setting the FL_FROZEN flag.
 *
 * @param entity		Entity index.
 */
stock void Entity_Freeze(int entity)
{
	Entity_AddFlags(entity, FL_FROZEN);
}

/**
 * Unfreezes an entity by removing the FL_FROZEN flag.
 *
 * @param entity		Entity index.
 */
stock void Entity_UnFreeze(int entity)
{
	Entity_RemoveFlags(entity, FL_FROZEN);
}


/**
 * This function points an entity to another with the targetname
 * and name. Useful for allot of entities like trigger_teleport.
 * If the name is not specified it will be generated automatically.
 *
 * @param entity			Entity index.
 * @param target			Target entity index.
 * @param				Optional: target name
 */
stock void Entity_PointAtTarget(int entity, int target, const char[] name="")
{
	char targetName[128];
	Entity_GetTargetName(entity, targetName, sizeof(targetName));

	if (name[0] == '\0') {

		if (targetName[0] == '\0') {
			// Let's generate our own name
			Format(
				targetName,
				sizeof(targetName),
				"_smlib_Entity_PointAtTarget:%d",
				target
			);
		}
	}
	else {
		strcopy(targetName, sizeof(targetName), name);
	}

	Entity_SetTargetName(entity, targetName);
	Entity_SetName(target, targetName);
}

/**
 * This function points a point_hurt entity to another damage target entity..
 * and name. Useful for allot of entities like trigger_teleport.
 * If the name is not specified it will be generated automatically.
 *
 * @param entity			Entity index.
 * @param target			Target entity index.
 * @param					Optional: target name
 */
stock void Entity_PointHurtAtTarget(int entity, int target, const char[] name="")
{
	char targetName[128];
	Entity_GetTargetName(entity, targetName, sizeof(targetName));

	if (name[0] == '\0') {

		if (targetName[0] == '\0') {
			// Let's generate our own name
			Format(
				targetName,
				sizeof(targetName),
				"_smlib_Entity_PointHurtAtTarget:%d",
				target
			);
		}
	}
	else {
		strcopy(targetName, sizeof(targetName), name);
	}

	DispatchKeyValue(entity, "DamageTarget", targetName);
	Entity_SetName(target, targetName);
}

/**
 * Checks if an entity is a player or not.
 * No checks are done if the entity is actually valid,
 * the player is connected or ingame.
 *
 * @param entity			Entity index.
 * @return 				True if the entity is a player, false otherwise.
 */
stock bool Entity_IsPlayer(int entity)
{
	if (entity < 1 || entity > MaxClients) {
		return false;
	}

	return true;
}

/**
 *  Creates an entity by classname.
 *
 * @param className			Classname String.
 * @param ForceEdictIndex	Edict Index to use.
 * @return 					Entity Index or INVALID_ENT_REFERENCE if the slot is already in use.
 */
stock int Entity_Create(const char[] className, int ForceEdictIndex=-1)
{
	if (ForceEdictIndex != -1 && Entity_IsValid(ForceEdictIndex)) {
		return INVALID_ENT_REFERENCE;
	}

	return CreateEntityByName(className, ForceEdictIndex);
}

/**
 * Kills an entity on the next frame (delayed).
 * It is safe to use with entity loops.
 * If the entity is is player ForcePlayerSuicide() is called.
 *
 * @param kenny			Entity index.
 * @param killChildren	When true, kennys children are killed too.
 * @return 				True on success, false otherwise.
 */
stock bool Entity_Kill(int kenny, bool killChildren=false)
{
	if (Entity_IsPlayer(kenny)) {
		// Oh My God! They Killed Kenny!!
		ForcePlayerSuicide(kenny);
		return true;
	}

	if(killChildren){
		return AcceptEntityInput(kenny, "KillHierarchy");
	}
	else {
		return AcceptEntityInput(kenny, "Kill");
	}
}

/**
 * Kills all entities with the given networked classname.
 *  It is safe to use with entity loops.
 * If the entity is is player ForcePlayerSuicide() is called.
 *
 * @param className		Entity Network Class to search for.
 * @return 				Number of entities killed.
 */
stock int Entity_KillAllByClassName(const char[] className)
{
	int x = 0;

	int entity = INVALID_ENT_REFERENCE;
	while ((entity = FindEntityByClassname(entity, className)) != INVALID_ENT_REFERENCE) {
		AcceptEntityInput(entity, "kill");
		x++;
	}

	return x;
}

/**
 * Gets the owner of an entity.
 * For example the owner of a weapon entity.
 *
 * @param entity		Entity index.
 * @return 				Ground Entity or -1
 */
stock int Entity_GetOwner(int entity)
{
	return GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
}

/**
 * Sets the owner of an entity.
 * For example the owner of a weapon entity.
 *
 * @param entity			Entity index.
 */
stock void Entity_SetOwner(int entity, int newOwner)
{
	SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", newOwner);
}

/**
 * Get's the ground entity this entity stands on.
 *
 * @param entity		Entity index.
 * @return 				Ground Entity or -1
 */
stock int Entity_GetGroundEntity(int entity)
{
	return GetEntPropEnt(entity, Prop_Data, "m_hGroundEntity");
}

/*
 *  Damage definitions
 */

#if !defined DMG_GENERIC

#define DMG_GENERIC			0			// generic damage was done
#define DMG_CRUSH			(1 << 0)	// crushed by falling or moving object.
										// NOTE: It's assumed crush damage is occurring as a result of physics collision, so no extra physics force is generated by crush damage.
										// DON'T use DMG_CRUSH when damaging entities unless it's the result of a physics collision. You probably want DMG_CLUB instead.
#define DMG_BULLET			(1 << 1)	// shot
#define DMG_SLASH			(1 << 2)	// cut, clawed, stabbed
#define DMG_BURN			(1 << 3)	// heat burned
#define DMG_VEHICLE			(1 << 4)	// hit by a vehicle
#define DMG_FALL			(1 << 5)	// fell too far
#define DMG_BLAST			(1 << 6)	// explosive blast damage
#define DMG_CLUB			(1 << 7)	// crowbar, punch, headbutt
#define DMG_SHOCK			(1 << 8)	// electric shock
#define DMG_SONIC			(1 << 9)	// sound pulse shockwave
#define DMG_ENERGYBEAM		(1 << 10)	// laser or other high energy beam
#define DMG_PREVENT_PHYSICS_FORCE		(1 << 11)	// Prevent a physics force
#define DMG_NEVERGIB		(1 << 12)	// with this bit OR'd in, no damage type will be able to gib victims upon death
#define DMG_ALWAYSGIB		(1 << 13)	// with this bit OR'd in, any damage type can be made to gib victims upon death.
#define DMG_DROWN			(1 << 14)	// Drowning


#define DMG_PARALYZE		(1 << 15)	// slows affected creature down
#define DMG_NERVEGAS		(1 << 16)	// nerve toxins, very bad
#define DMG_POISON			(1 << 17)	// blood poisoning - heals over time like drowning damage
#define DMG_RADIATION		(1 << 18)	// radiation exposure
#define DMG_DROWNRECOVER	(1 << 19)	// drowning recovery
#define DMG_ACID			(1 << 20)	// toxic chemicals or acid burns
#define DMG_SLOWBURN		(1 << 21)	// in an oven

#define DMG_REMOVENORAGDOLL	(1<<22)		// with this bit OR'd in, no ragdoll will be created, and the target will be quietly removed.
										// use this to kill an entity that you've already got a server-side ragdoll for

#define DMG_PHYSGUN			(1<<23)		// Hit by manipulator. Usually doesn't do any damage.
#define DMG_PLASMA			(1<<24)		// Shot by Cremator
#define DMG_AIRBOAT			(1<<25)		// Hit by the airboat's gun

#define DMG_DISSOLVE		(1<<26)		// Dissolving!
#define DMG_BLAST_SURFACE	(1<<27)		// A blast on the surface of water that cannot harm things underwater
#define DMG_DIRECT			(1<<28)
#define DMG_BUCKSHOT		(1<<29)		// not quite a bullet. Little, rounder, different.

#endif

/**
 * Does damage to an entity.
 * This is a powerful function that allows you to specify
 * who the attacker is, the damage type and also what weapon
 * should be displayed in the hud kill message.
 * Note that for entities that fire another entity (RPG's, Crossbow's,
 * you have to pass the bullet's class, not the weapon's class !
 * It hasn't been tested how expensive this function is, as it
 * uses the entity point_hurt.
 * If you need a cheaper function use Entity_RemoveHealth().
 *
 * @param entity			Entity index.
 * @param damage			Amount of damage.
 * @param attacker		Entity Index of the attacker.
 * @param damageType		Use the DMG_ definations.
 * @param fakeClassName	Classname to fake, you can set this if you
 * 						want a specific weapon to be shown in the HUD kill message.
 * @param customOrigin		Teleport point_hurt to origin before triggering hurt
 * 						useful for damage force calculations e.g. explosions, gun fire direction, ect.
 * @return 				True on success, false otherwise.
 */
stock bool Entity_Hurt(int entity, int damage, int attacker=0, int damageType=DMG_GENERIC, const char[] fakeClassName="", float customOrigin[3]={0.0, 0.0, 0.0})
{
	static int point_hurt = INVALID_ENT_REFERENCE;

	if (point_hurt == INVALID_ENT_REFERENCE || !IsValidEntity(point_hurt)) {
		point_hurt = EntIndexToEntRef(Entity_Create("point_hurt"));

		if (point_hurt == INVALID_ENT_REFERENCE) {
			return false;
		}

		DispatchSpawn(point_hurt);
	}

	AcceptEntityInput(point_hurt, "TurnOn");
	SetEntProp(point_hurt, Prop_Data, "m_nDamage", damage);
	SetEntProp(point_hurt, Prop_Data, "m_bitsDamageType", damageType);
	
	char orignalTargetName[128];
	Entity_GetName(entity, orignalTargetName, sizeof(orignalTargetName));
	Entity_PointHurtAtTarget(point_hurt, entity);

	if (fakeClassName[0] != '\0') {
		Entity_SetClassName(point_hurt, fakeClassName);
	}

	TeleportEntity(point_hurt, customOrigin, NULL_VECTOR, NULL_VECTOR);

	AcceptEntityInput(point_hurt, "Hurt", attacker);
	AcceptEntityInput(point_hurt, "TurnOff");

	if (fakeClassName[0] != '\0') {
		Entity_SetClassName(point_hurt, "point_hurt");
	}
	
	DispatchKeyValue(entity, "targetname", orignalTargetName);
	return true;
}

/*
 * Gets the parent entity of an entity.
 *
 * @param entity		Entity Index.
 * @return				Entity Index of the parent.
 */
stock int Entity_GetParent(int entity)
{
	return GetEntPropEnt(entity, Prop_Data, "m_pParent");
}

/*
 * Clears the parent of an entity.
 *
 * @param entity		Entity Index.
 */
stock void Entity_ClearParent(int entity)
{
	//SetVariantString("");
	AcceptEntityInput(entity, "ClearParent");
}

/*
 * Sets the parent entity of an entity.
 *
 * @param entity		Entity Index.
 * @param parent		Entity Index of the new parent.
 */
stock void Entity_SetParent(int entity, int parent)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);
}


/*
 * Callback for Change_OverTime.
 * Note that every parameter is a reference and can be changed during this callback.
 * You can get the elapsed time since start by multiply tick with currentCall.
 *
 * @param entity		Entity Index.
 * @param interval		The current interval from the current game time to execute the next call of this function.
 * @param currentCall	The current call number (0 is the 1st call at 0.0 seconds, 1 the 2nd call at tick*1 seconds, ...).
 * @return				When true this callback will be called again at the next defined tick, otherwise it won't.
 */
typedef Entity_ChangeOverTimeCallback = function bool (int &entity, float &interval, int &currentCall);

/*
 * Creates a timer and provides a callback to change various things about an entity over time.
 *
 * @param entity			Entity Index.
 * @param interval			Interval from the current game time to execute the given function.
 * @noreturn
 */
stock void Entity_ChangeOverTime(int entity, float interval=0.1, Entity_ChangeOverTimeCallback valueCallback)
{
	DataPack dataPack = CreateDataPack();
	WritePackCell(dataPack, EntIndexToEntRef(entity));
	WritePackFloat(dataPack, interval);
	WritePackCell(dataPack, 0);
	WritePackFunction(dataPack, valueCallback);
	ResetPack(dataPack);
	__smlib_Timer_ChangeOverTime(INVALID_HANDLE,dataPack);
}

public Action __smlib_Timer_ChangeOverTime(Handle Timer, DataPack dataPack)
{
	int entity = EntRefToEntIndex(ReadPackCell(dataPack));
	if(!Entity_IsValid(entity)){
		return Plugin_Stop;
	}

	float interval = ReadPackFloat(dataPack);
	int currentCall = ReadPackCell(dataPack);
	Function callback = ReadPackFunction(dataPack);

	any result;
	Call_StartFunction(INVALID_HANDLE, callback);
	Call_PushCellRef(entity);
	Call_PushFloatRef(interval);
	Call_PushCellRef(currentCall);
	Call_Finish(result);

	if(result == false){
		return Plugin_Stop;
	}

	ResetPack(dataPack,true);
	WritePackCell(dataPack, EntIndexToEntRef(entity));
	WritePackFloat(dataPack, interval);
	WritePackCell(dataPack, currentCall+1);
	WritePackFunction(dataPack, callback);
	ResetPack(dataPack);
	CreateTimer(interval, __smlib_Timer_ChangeOverTime, dataPack);
	return Plugin_Stop;
}


/**
 * Gets the next child, entity is parent of.
 *
 * @param parent		Entity Index (of Parent)
 * @param start			Start Index.
 * @return				Entity Index or -1 if no entity was found.
 */
stock int Entity_GetNextChild(int parent, int start=0)
{
	int maxEntities = GetMaxEntities();
	for (int entity=start; entity < maxEntities; entity++) {

		if (!Entity_IsValid(entity)) {
			continue;
		}

		if (entity > 0 && entity <= MaxClients && !IsClientConnected(entity)) {
			continue;
		}

		if (Entity_GetParent(entity) == parent) {
			return entity;
		}
	}

	return INVALID_ENT_REFERENCE;
}
/**
 * Gets the move/open direction of an entity (only available for func_door*, prop_door* and func_movelinear).
 * Ex: if vec[2] is 1.0 a func_door moves straight up.
 *
 * @param entity			Entity index.
 * @param vec				Vector.
 */
stock void Entity_GetMoveDirection(int entity, float vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecMoveDir", vec);
}
/**
 * Sets the move/open direction of an entity (only available for func_door*, prop_door* and func_movelinear).
 * Ex: if vec[2] is 1.0 a func_door moves straight up.
 *
 * @param entity			Entity index.
 * @param vec				Vector.
 */
stock void Entity_SetMoveDirection(int entity, const float vec[3])
{
	SetEntPropVector(entity, Prop_Data, "m_vecMoveDir", vec);
}

/**
 * Returns if the entity will force close (won't be blockable by players and/or objects) or not when triggered to move.
 *
 * @param entity			Entity index.
 * @return					True if the door will force close, otherwise false.
 */
stock bool Entity_GetForceClose(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_bForceClosed") != 0;
}

/**
 * Sets if the door should force close (souldn't be blockable by players and/or objects) or not when triggered to move.
 *
 * @param entity			Entity index.
 * @param forceClose		If true the door will force close, otherwise it won't.
 */
stock void Entity_SetForceClose(int entity, bool forceClose)
{
	SetEntProp(entity, Prop_Data, "m_bForceClosed", forceClose);
}

/**
 * Gets the speed of a moving entity (like doors: open close speed).
 *
 * @param entity			Entity index.
 * @return					Speed of the entity.
 */
stock float Entity_GetSpeed(int entity)
{
	return GetEntPropFloat(entity, Prop_Data, "m_flSpeed");
}

/**
 * Sets how fast an entity moves (like doors: open close speed).
 *
 * @param entity			Entity index.
 * @param speed				The new speed of the entity.
 */
stock void Entity_SetSpeed(int entity, float speed)
{
	SetEntPropFloat(entity, Prop_Data, "m_flSpeed", speed);
}

/**
 * Gets the damage of a moving entity when blocked (like doors when open or close and players and/or objects are between the entity and something else).
 * Note: Negative values add health to the blocking entity.
 *
 * @param entity			Entity index.
 * @return					Damage.
 */
stock float Entity_GetBlockDamage(int entity)
{
	return GetEntPropFloat(entity, Prop_Data, "m_flBlockDamage");
}

/**
 * Sets the damage of a moving entity when blocked (like doors when open or close and players and/or objects are between the entity and something else).
 * Note: Negative values add health to the blocking entity.
 *
 * @param entity			Entity index.
 * @param damage			Damage.
 */
stock void Entity_SetBlockDamage(int entity, float damage)
{
	SetEntPropFloat(entity, Prop_Data, "m_flBlockDamage", damage);
}

/**
 * Returns if the given entity is disabled or not.
 *
 * @param entity			Entity index.
 * @return					True if entity is disabled, otherwise false.
 */
stock bool Entity_IsDisabled(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_bDisabled", 1) != 0;
}

/**
 * Disables the given entity.
 *
 * @param entity			Entity index.
 * @return					True if successful otherwise false.
 */
stock bool Entity_Disable(int entity)
{
	return AcceptEntityInput(entity, "Disable");
}

/**
 * Enables the given entity.
 *
 * @param entity			Entity index.
 * @return					True if successful otherwise false.
 */
stock bool Entity_Enable(int entity)
{
	return AcceptEntityInput(entity, "Enable");
}


// settings for m_takedamage taken from hl2sdk-ob-valve\game\shared\shareddefs.h
#define		DAMAGE_NO			0
#define 	DAMAGE_EVENTS_ONLY	1		// Call damage functions, but don't modify health
#define		DAMAGE_YES			2
#define		DAMAGE_AIM			3

/**
 * Sets the mode for an entity to take damage.
 * Note: This is used to give a client god mode (DAMAGE_NO).
 *
 * @param entity			Entity index.
 * @param value				Mode, use DAMAGE_* defines.
 */
stock void Entity_SetTakeDamage(int entity, int value)
{
	SetEntProp(entity, Prop_Data, "m_takedamage", value, 1);
}

/**
 * Gets the mode for an entity to take damage.
 * Note: When the return value is DAMAGE_NO then the client is using godmode.
 *
 * @param entity			Entity index.
 * @return					Take damage mode (DAMAGE_*).
 */
stock int Entity_GetTakeDamage(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_takedamage", 1);
}

/**
 * Sets the minimum of damage required to hurt this entity.
 * Example: This is used to block any damage done by projectile weapons against a gun ship in Half-Life 2.
 *
 * @param entity			Entity index.
 * @param minDamage			Minimum required damage.
 */
stock void Entity_SetMinHealthDamage(int entity, int minDamage)
{
	SetEntProp(entity, Prop_Data, "m_iMinHealthDmg", minDamage);
}

/**
 * Gets the minimum of damage required to hurt this entity.
 * Example: This is used to block any damage done by projectile weapons against a gun ship in Half-Life 2.
 *
 * @param entity			Entity index.
 * @return					Minimum required damage.
 */
stock int Entity_GetMinHealthDamage(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iMinHealthDmg");
}

/**
 * Gets an entity's color.
 *
 * @param entity	Entity index
 * @param color 	4 dimensional array where [r,g,b,a] values are stored
 * @error			Invalid entity index, or lack of mod compliance.
 */
stock void Entity_GetRenderColor(int entity, int color[4])
{
	static bool gotconfig = false;
	static char prop[32];

	if (!gotconfig) {
		Handle gc = LoadGameConfigFile("core.games");
		bool exists = GameConfGetKeyValue(gc, "m_clrRender", prop, sizeof(prop));
		delete gc;

		if (!exists) {
			strcopy(prop, sizeof(prop), "m_clrRender");
		}

		gotconfig = true;
	}

	int offset = GetEntSendPropOffs(entity, prop);

	if (offset <= 0) {
		ThrowError("SetEntityRenderColor not supported by this mod");
	}

	for (int i=0; i < 4; i++) {
		color[i] = GetEntData(entity, offset + i, 1);
	}
}

/**
 * Sets an entity's color.
 * Doesn't change the value, if set to -1.
 *
 * @param entity	Entity index
 * @param r 		Amount of red (0-255)
 * @param g 		Amount of green (0-255)
 * @param b 		Amount of blue (0-255)
 * @param a 		Amount of alpha (0-255)
 * @error			Invalid entity index, or lack of mod compliance.
 */
stock void Entity_SetRenderColor(int entity, int r=-1, int g=-1, int b=-1, int a=-1)
{
	static bool gotconfig = false;
	static char prop[32];

	if (!gotconfig) {
		Handle gc = LoadGameConfigFile("core.games");
		bool exists = GameConfGetKeyValue(gc, "m_clrRender", prop, sizeof(prop));
		delete gc;

		if (!exists) {
			strcopy(prop, sizeof(prop), "m_clrRender");
		}

		gotconfig = true;
	}

	int offset = GetEntSendPropOffs(entity, prop);

	if (offset <= 0) {
		ThrowError("SetEntityRenderColor not supported by this mod");
	}

	if(r != -1) {
		SetEntData(entity, offset, r, 1, true);
	}

	if(g != -1) {
		SetEntData(entity, offset + 1, g, 1, true);
	}

	if(b != -1) {
		SetEntData(entity, offset + 2, b, 1, true);
	}

	if(a != -1) {
		SetEntData(entity, offset + 3, a, 1, true);
	}
}

/**
 * Sends the 'addouput' command to an entity.
 *
 * @param entity		Entity Index.
 * @param input			Input command.
 * @param activator		Entity index which initiated the sequence of actions (-1 for a NULL entity).
 * @param caller		Entity index from which this event is sent (-1 for a NULL entity).
 * @param outputid		Unknown.
 * @return				True if successful, otherwise false.
 */
stock bool Entity_AddOutput(int entity, const char[] input, int activator=-1, int caller=-1, int outputid=0)
{
	SetVariantString(input);
	return AcceptEntityInput(entity, "addoutput", activator, caller, outputid);
}
