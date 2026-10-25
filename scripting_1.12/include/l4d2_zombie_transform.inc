#if defined  _l4d2_zombie_transform_included_
 #endinput
#endif
#define _l4d2_zombie_transform_included_

/**
 * Called when client has turned into zombie
 * 
 * @param client 			The client index.
 * @param classType 		The zombie classType. (1~8)
 * @param bAbility          True if can use infected ability, false otherwise
 */
forward void OnTurnClientIntoZombie(int client, int classType, bool bAbility);

/**
 * Called when infected has turned into survivor
 * 
 * @param client                The client index.
 * @param classType 			The zombie classType. (1~8)
 * @param bSaveAbility          True if keep infected custom ability, false otherwise
 */
forward void OnTurnZombieIntoSurvivor(int client, int classType, bool bSaveAbility);

/**
 * Called when client has turned into character
 * 
 * @param client                The client index.
 * @param sCharacterName        The Character name that client changed to: "bill", "zoey", "louis", "francis", "nick", "rochelle", "coach", "ellis"
 */
forward void OnTurnClientIntoCharacter(int client, const char[] sCharacterName);

/**
 * Called when client has turned into ghost infected
 * 
 * @param client 			The client index.
 * @param classType 		The zombie classType. (1~8)
 */
forward void OnTurnClientIntoGhost(int client, int classType);


/** Turn client into zombie
 *
 * @param client                The client index. Only accept infected or survivor
 * @param classType             The zombie classType. (1~8)
 * @param variantModel          The zombie variant model, (0=Game Default)
 *                                  Smoker: 	1=L4D2 Model, 2=L4D1 Model, 0=Game Default.
 *                                  Boomer: 	1=L4D2 Model, 2=L4D1 Model, 3=Female Boomer, 0=Game Default.
 *                                  Hunter: 	1=L4D2 Model, 2=L4D1 Model, 0=Game Default.
 *                                  Tank: 		1=L4D2 Model, 2=DLC Model, 3=L4D1 Model, 0=Game Default.
 * @param bAbility              If true, give infected custom ability
 * 
 * @return                      true if successful, false otherwise
 * @error	client is spectator or classtype is invalid
 */
native bool Z_TurnClientIntoZombie(int client, int classType, int variantModel = 0, bool bAbility = true);

/** Turn client from infected into survivor
 * @Note Does not work if client is bot
 *
 * @param client                The client index. Only accept not-bot infected player
 * @param bSaveAbility          If true, keep infected custom ability
 * 
 * @return                      true if successful, false otherwise
 * @error	client is not real infected player
 */
native bool Z_TurnZombieIntoSurvivor(int client, bool bSaveAbility = false);

/** Turn client into character
 *
 * @param client                The client index. Only accept infected or survivor
 * @param sCharacterName        The Character name that client changed to: "bill", "zoey", "louis", "francis", "nick", "rochelle", "coach", "ellis"
 * 
 * @return                      true if successful, false otherwise
 * @error	client is spectator or Character name is invalid
 */
native bool Z_TurnClientIntoCharacter(int client, const char[] sCharacterName);

/** Turn client into ghost infected
 * @Note Does not work if client is bot
 *
 * @param client                The client index. Only accept not-bot infected or survivor
 * @param classType             The zombie classType. (1~8)
 * 
 * @return                      true if successful, false otherwise
 * @error	client is bot or classtype is invalid
 */
native bool Z_TurnClientIntoGhost(int client, int classType);

public SharedPlugin __pl_l4d2_zombie_transform =
{
	name = "l4d2_zombie_transform",
	file = "l4d2_zombie_transform.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_zombie_transform_SetNTVOptional()
{
	MarkNativeAsOptional("Z_TurnClientIntoZombie");
	MarkNativeAsOptional("Z_TurnZombieIntoSurvivor");
	MarkNativeAsOptional("Z_TurnClientIntoCharacter");
}
#endif