#if defined _versusbosses_ifier
	#endinput
#endif
#define _versusbosses_ifier


/**
 * @brief Called when the boss percents are updated.
 * @remarks Triggered via boss votes, force tanks, force witches.
 * @remarks Special value: -1 indicates ignored in change, 0 disabled (no spawn).
 */
forward void OnUpdateBosses(int iTankFlow, int iWitchFlow);

/**
 * @brief Update the boss percentages.
 *
 * @noreturn
 */
native void L4D2VS_UpdateBossPercents();


/**
 * @brief Get the stored tank percent.
 *
 * @return					Integer of the percentage, 0 if spawn disabled or spawn static, -1 if unsupported game.
 */
native int L4D2VS_GetStoredTankPercent();

/**
 * @brief Get the stored witch percent.
 *
 * @return					Integer of the percentage, 0 if spawn disabled or spawn static, -1 if unsupported game.
 */
native int L4D2VS_GetStoredWitchPercent();

/**
 * @brief Get the ready footer index of the boss percents.
 * @remarks Safe to use no matter readyup is available or not.
 *
 * @return					Index of the ready up footer, -1 if readyup is not available.
 */
native int L4D2VS_GetReadyUpFooterIndex();

/**
 * @brief Refresh the boss percents on the ready up.
 * @remarks All hooks are removed on map change.
 *
 * @return					True on success, false if readyup is not available.
 */
native bool L4D2VS_RefreshBossPercentReadyUp();

/**
 * @brief Check if the current map is Dark Carnival: Remix.
 * @remarks Dark Carnival: Remix uses built-in custom boss system, which is not the usual way that the game performs.
 *
 * @return					True if current map is Dark Carnival: Remix, false otherwise.
 */
native bool L4D2VS_IsDarkCarniRemix();

/**
 * @brief Check if the current map contains a static witch spawn.
 *
 * @return					True on contains a static spawn, false otherwise.
 */
native bool L4D2VS_IsStaticWitchMap();

/**
 * @brief Check if the current map contains a static tank spawn.
 *
 * @return					True on contains a static spawn, false otherwise.
 */
native bool L4D2VS_IsStaticTankMap();

/**
 * @brief Validate the flow percentage of tank on current map.
 * @remarks Passing 0 is allowed and considered disabling.
 *
 * @param	percent			Flow percentage to check.
 *
 * @return					True on valid, false otherwise.
 */
native bool L4D2VS_IsTankPercentValid(int percent);

/**
 * @brief Validate the flow percentage of witch on current map.
 * @remarks Passing 0 is allowed and considered disabling.
 *
 * @param	percent			Flow percentage to check.
 * @param	ignoreBlock		Ignore percent block due to tank percent.
 *
 * @return					True on valid, false otherwise.
 */
native bool L4D2VS_IsWitchPercentValid(int percent, bool ignoreBlock = false);

/**
 * @brief Check if the flow percentage of witch is blocked due to current tank percent.
 * @remarks The blocked range covers as much as the value of convar "sm_witch_avoid_tank_spawn",
 *			taking current tank percent as middle point.
 *
 * @param	percent			Flow percentage to check.
 *
 * @return					True on blocked, false otherwise.
 */
native bool L4D2VS_IsWitchPercentBlockedForTank(int percent);

/**
 * @brief Set the flow percentage of tank on current map.
 * @remarks Passing 0 is allowed and will disable flow tank.
 *
 * @param	percent			Flow percentage to check.
 *
 * @return					True on success, false otherwise.
 */
native bool L4D2VS_SetTankPercent(int percent);

/**
 * @brief Set the flow percentage of witch on current map.
 * @remarks Passing 0 is allowed and will disable flow witch.
 *
 * @param	percent			Flow percentage to check.
 *
 * @return					True on success, false otherwise.
 */
native bool L4D2VS_SetWitchPercent(int percent);


public SharedPlugin __pl_versusbosses_ifier =
{
	name = "versusbosses_ifier",
	file = "versusbosses_ifier.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_versusbosses_ifier_SetNTVOptional()
{
	MarkNativeAsOptional("L4D2VS_UpdateBossPercents");
	MarkNativeAsOptional("L4D2VS_GetStoredTankPercent");
	MarkNativeAsOptional("L4D2VS_GetStoredWitchPercent");
	MarkNativeAsOptional("L4D2VS_GetReadyUpFooterIndex");
	MarkNativeAsOptional("L4D2VS_RefreshBossPercentReadyUp");
	MarkNativeAsOptional("L4D2VS_IsDarkCarniRemix");

	MarkNativeAsOptional("L4D2VS_IsStaticTankMap");
	MarkNativeAsOptional("L4D2VS_IsStaticWitchMap");
	MarkNativeAsOptional("L4D2VS_IsTankPercentValid");
	MarkNativeAsOptional("L4D2VS_IsWitchPercentValid");
	MarkNativeAsOptional("L4D2VS_IsWitchPercentBlockedForTank");
	MarkNativeAsOptional("L4D2VS_SetTankPercent");
	MarkNativeAsOptional("L4D2VS_SetWitchPercent");
}
#endif
