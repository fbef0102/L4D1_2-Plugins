#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[L4D2] Spritetrail fix",
	author = "000",
	description = "Fixes spritetrail disappearing after a second when it was created.",
	version = "1.0",
	url = "https://forums.alliedmods.net/showthread.php?t=339197"
};

public void OnPluginStart()
{
	HookEvent("round_start", OnRoundStart_PostNoCopy, EventHookMode_PostNoCopy);
}

public void OnMapStart()
{
	int index = -1;
	while((index = FindEntityByClassname(index, "env_spritetrail")) != -1)
	{
		if (IsValidEdict(index))
		{
			FixSpriteTrail(index);
		}
	}
}

void OnRoundStart_PostNoCopy(Event e, const char[] n, bool db)
{
	OnMapStart();
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity))
		return;

	switch (classname[0])
	{
		case 'e':
		{
			if(strcmp(classname, "env_spritetrail", false) == 0)
			{
				SDKHook(entity, SDKHook_SpawnPost, SpawnPost);
			}
		}
	}
}

public void SpawnPost(int entity)
{
    RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
}

public void OnNextFrame(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);

	if (entity == INVALID_ENT_REFERENCE)
		return;

	FixSpriteTrail(entity);
}

void FixSpriteTrail(int entity)
{
	SetVariantString("OnUser1 !self:SetScale:2:0.5:1");
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}