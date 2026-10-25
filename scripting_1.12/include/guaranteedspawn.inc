/** Double-include prevention */
#if defined _guaranteedspawn_included_
  #endinput
#endif
#define _guaranteedspawn_included_

enum GSMethod
{
	GSMethod_Checkpoint,
	GSMethod_Nearby
}

/**
 * Called when a client is about to spawn via their guaranteed spawn
 *
 * @param client      Entity index of the spawning client.
 * @param method      Method by which they're spawning
 * @param target      Entity index of our spawn target
 * @return            Plugin_Handled to prevent spawning
 */
forward Action GS_OnGuaranteedSpawn(int client, GSMethod method, int target);

/**
 * Called after a client has spawned via their guaranteed spawn
 *
 * @param client      Entity index of the spawning client.
 * @param method      Method by which they're spawning
 * @param target      Entity index of our spawn target
 */
forward void GS_OnGuaranteedSpawnPost(int client, GSMethod method, int target);

/**
 * Grants or revokes a client's guaranteed spawn.
 *
 * @param client     Player's index
 * @param canSpawn     Whether the player can spawn
 */
native void GS_SetCanSpawn(int client, bool canSpawn);
