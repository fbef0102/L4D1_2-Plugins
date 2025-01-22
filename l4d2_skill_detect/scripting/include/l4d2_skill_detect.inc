#if defined  _l4d2_skill_detect_included_
 #endinput
#endif
#define _l4d2_skill_detect_included_

/**
 * @brief Called when survivor skeeted hunter or jockey
 * @remarks Without melee, sniper, magnum, shotgun, grenade launcher
 * 
 * @param survivor 			Client index of survivor (-2 if team skeet, -1 or 0 if unknown or invalid client)
 * @param victim 			Client index of hunter or jockey
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * @param shots 			How many shots
 * 
 * @noreturn
 */
forward void OnSkeet( int survivor, int victim, bool isHunter, bool headshot, int shots )

/**
 * @brief Called when survivor skeeted hunter or jockey with Melee
 * 
 * @param survivor 			Client index of survivor (-2 if team skeet, -1 or 0 if unknown or invalid client)
 * @param victim 			Client index of hunter or jockey
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * 
 * @noreturn
 */
forward void OnSkeetMelee( int survivor, int victim, bool isHunter, bool headshot )
 
 /**
 * @brief Called when survivor skeeted hunter or jockey with Sniper
 * 
 * @param survivor 			Client index of survivor (-2 if team skeet, -1 or 0 if unknown or invalid client)
 * @param victim 			Client index of hunter or jockey
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * @param shots 			How many shots
 * 
 * @noreturn
 */
forward void OnSkeetSniper( int survivor, int victim, bool isHunter, bool headshot, int shots )

/**
 * @brief Called when survivor skeeted hunter or jockey with Magnum
 * 
 * @param survivor 			Client index of survivor (-2 if team skeet, -1 or 0 if unknown or invalid client)
 * @param victim 			Client index of hunter or jockey
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * @param shots 			How many shots
 * 
 * @noreturn
 */
forward void OnSkeetMagnum( int survivor, int victim, bool isHunter, bool headshot, int shots )

/**
 * @brief Called when survivor skeeted hunter or jockey with Shotgun
 * 
 * @param survivor 			client index of survivor (-2 if team skeet, -1 or 0 if unknown or invalid client)
 * @param victim 			client index of hunter or jockey
 * @param isHunter 			true if victim is hunter, false if victim if jockey
 * @param headshot 			true if headshot, false otherwise
 * @param shots 			how many shots
 * 
 * @noreturn
 */
forward void OnSkeetShotgun( int survivor, int victim, bool isHunter, bool headshot, int shots )

/**
 * @brief Called when survivor skeeted hunter or jockey with Grenade Launcher
 * 
 * @param survivor 			Client index of survivor (-2 if team skeet, -1 or 0 if unknown or invalid client)
 * @param victim 			Client index of hunter or jockey
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * 
 * @noreturn
 */
forward void OnSkeetGL( int survivor, int victim, bool isHunter, bool headshot )

/**
 * @brief Called when survivor skeeted hunter or jockey
 * @remarks Without melee, sniper, magnum, shotgun, grenade launcher
 * @remarks Damage is lower then z_pounce_damage_interrupt value
 * 
 * @param survivor 			Client index of survivor
 * @param victim 			Client index of hunter or jockey
 * @param damage 			The amount of damage done to victim (That didn't add up to skeeting damage)
 * @param isOverkill 		Indicates whether the shot would've been a skeet if the hunter had not been chipped
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * @param shots 			How many shots
 * 
 * @noreturn
 */
forward void OnSkeetHurt( int survivor, int victim, int damage, bool isOverkill, bool isHunter, bool headshot, int shots )
 
/**
 * @brief Called when survivor skeeted hunter or jockey with Melee
 * @remarks Damage is lower then z_pounce_damage_interrupt value
 * 
 * @param survivor 			Client index of survivor
 * @param victim 			Client index of hunter or jockey
 * @param damage 			The amount of damage done to victim (That didn't add up to skeeting damage)
 * @param isOverkill 		Indicates whether the shot would've been a skeet if the hunter had not been chipped (always true for melee)
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * 
 * @noreturn
 */
forward void OnSkeetMeleeHurt( int survivor, int victim, int damage, bool isOverkill, bool isHunter, bool headshot )

/**
 * @brief Called when survivor skeeted hunter or jockey with Sniper
 * @remarks Damage is lower then z_pounce_damage_interrupt value
 * 
 * @param survivor 			Client index of survivor
 * @param victim 			Client index of hunter or jockey
 * @param damage 			The amount of damage done to victim (That didn't add up to skeeting damage)
 * @param isOverkill 		Indicates whether the shot would've been a skeet if the hunter had not been chipped
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * @param shots 			How many shots
 * 
 * @noreturn
 */
forward void OnSkeetSniperHurt( int survivor, int victim, int damage, bool isOverkill, bool isHunter, bool headshot, int shots )

/**
 * @brief Called when survivor skeeted hunter or jockey with Magnum
 * @remarks Damage is lower then z_pounce_damage_interrupt value
 * 
 * @param survivor 			Client index of survivor
 * @param victim 			Client index of hunter or jockey
 * @param damage 			The amount of damage done to victim (That didn't add up to skeeting damage)
 * @param isOverkill 		Indicates whether the shot would've been a skeet if the hunter had not been chipped
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * @param shots 			How many shots
 * 
 * @noreturn
 */
forward void OnSkeetMagnumHurt( int survivor, int victim, int damage, bool isOverkill, bool isHunter, bool headshot, int shots )

/**
 * @brief Called when survivor skeeted hunter or jockey with Shotgun
 * @remarks Damage is lower then z_pounce_damage_interrupt value
 * 
 * @param survivor 			Client index of survivor
 * @param victim 			Client index of hunter or jockey
 * @param damage 			The amount of damage done to victim (That didn't add up to skeeting damage)
 * @param isOverkill 		Indicates whether the shot would've been a skeet if the hunter had not been chipped
 * @param isHunter 			True if victim is hunter, false if victim if jockey
 * @param headshot 			True if headshot, false otherwise
 * @param shots 			How many shots
 * 
 * @noreturn
 */
forward void OnSkeetShotgunHurt( int survivor, int victim, int damage, bool isOverkill, bool isHunter, bool headshot, int shots )

/**
 * @brief Called when survivor deadstopped hunter
 * 
 * @param survivor 			Client index of survivor
 * @param hunter 			Client index of hunter
 * 
 * @noreturn
 */
forward void OnHunterDeadstop( int survivor, int hunter )

/**
 * @brief Called when survivor deadstopped jockey
 * 
 * @param survivor 			Client index of survivor
 * @param jockey 			Client index of jockey
 * 
 * @noreturn
 */
forward void OnJockeyDeadstop( int survivor, int jockey )

/**
 * @brief Called when survivor popped boomer
 * 
 * @param survivor 			Client index of survivor
 * @param boomer 			Client index of boomer
 * @param shoveCount 		Count of boomer getting shoved
 * @param timeAlive 		Boomer alive time after spawn
 * 
 * @noreturn
 */
forward void OnBoomerPop( int survivor, int boomer, int shoveCount, float timeAlive )

/**
 * @brief Called when survivor leveled charger
 * 
 * @param survivor 			Client index of survivor
 * @param charger 			Client index of charger
 * @param headshot 			True if headshot, false otherwise
 * 
 * @noreturn
 */
forward void OnChargerLevel( int survivor, int charger, bool headshot )

/**
 * @brief Called when survivor leveled charger
 * @remarks Damage is lower then half of charger's health
 * 
 * @param survivor 			Client index of survivor
 * @param charger 			Client index of charger
 * @param damage 			The amount of damage done to victim (That didn't add up to leveling damage)
 * @param headshot 			True if headshot, false otherwise
 * 
 * @noreturn
 */
forward void OnChargerLevelHurt( int survivor, int charger, int damage, bool headshot )

/**
 * @brief Called when survivor crowned the witch
 * @remarks One-Shot Kill
 * 
 * @param survivor 			Client index of survivor
 * @param damage 			The amount of damage done to witch
 * 
 * @noreturn
 */
forward void OnWitchCrown( int survivor, int damage )

/**
 * @brief Called when survivor crowned the witch
 * @remarks Many-Shots Kill
 * 
 * @param survivor 			Client index of survivor
 * @param damage 			The amount of damage done to witch
 * @param damage 			Chip damage
 * 
 * @noreturn
 */
forward void OnWitchDrawCrown( int survivor, int damage, int chipdamage )

/**
 * @brief Called when survivor cut the smoker's tongue
 * 
 * @param survivor 			Client index of survivor
 * @param smoker 			Client index of smoker
 * 
 * @noreturn
 */
forward void OnTongueCut( int survivor, int smoker )

/**
 * @brief Called when survivor self-cleared from smoker's tongue
 * 
 * @param survivor 			Client index of survivor
 * @param smoker 			Client index of smoker
 * @param headshot 			True if headshot, false otherwise
 * 
 * @noreturn
 */
forward void OnSmokerSelfClear( int survivor, int smoker, bool withShove, bool headshot )

/**
 * @brief Called when survivor skeeted the tank rick
 * 
 * @param survivor 			Client index of survivor
 * @param tank 				Client index of tank
 * 
 * @noreturn
 */
forward void OnTankRockSkeeted( int survivor, int tank )

/**
 * @brief Called when survivor ate the tank rock
 * 
 * @param tank 				Client index of tank
 * @param survivor 			Client index of survivor
 * 
 * @noreturn
 */
forward void OnTankRockEaten( int tank, int survivor )

/**
 * @brief Called when hunter high-pounced survivor
 * 
 * @param hunter 			Client index of hunter
 * @param victim 			Client index of survivor
 * @param actualDamage 		The acutal damage done to victim
 * @param calculatedDamage 	Calculated Hight Pounce damage
 * @param height 			Height distance of hunter pounce
 * @param bReportedHigh 	True if plugin counts as a DP and reports, false otherwise
 * 
 * @noreturn
 */
forward void OnHunterHighPounce( int hunter, int victim, int actualDamage, float calculatedDamage, float height, bool bReportedHigh )

/**
 * @brief Called when jockey high-pounced survivor
 * 
 * @param jockey 			Client index of hunter
 * @param victim 			Client index of survivor
 * @param height 			Height distance of jockey leap
 * @param bReportedHigh 	True if plugin counts as a DP and reports, false otherwise
 * 
 * @noreturn
 */
forward void OnJockeyHighPounce( int jockey, int victim, float height, bool bReportedHigh )

/**
 * @brief Called when charger death-charged survivor
 * 
 * @param charger 			Client index of charger
 * @param victim 			Client index of survivor
 * @param height 			Height distance of deathcharge
 * @param distance 			Full Distance of deathcharge
 * @param wasCarried 		True if victim was carried by charger, false if victim was flung by a Charger impact
 * 
 * @noreturn
 */
forward void OnDeathCharge( int charger, int victim, float height, float distance, bool wasCarried )

/**
 * @brief Called when survivor deadstopped special infected
 * @remarks Special infected is not Hunter or Jockey
 * 
 * @param survivor 			Client index of survivor
 * @param infected 			Client index of special infected
 * 
 * @noreturn
 */
forward void OnSpecialShoved( int survivor, int infected, int zombieClass )

/**
 * @brief Called when survivor insta-cleared teammate from special infected
 * 
 * @param clearer 			Client index of survivor
 * @param pinner 			Client index of special infected
 * @param pinvictim 		Client index of teammate
 * @param zombieClass 		ZombieClass of the Special Infected
 * @param timeA 			Clear time (pummel/pounce/ride/choke)
 * @param timeB 			Clear time (tongue drag, charger carry)
 * @param withShove 		True if clear by shoving, false otherwise
 * @param headshot 			True if headshot, false otherwise
 * 
 * @noreturn
 */
forward void OnSpecialClear( int clearer, int pinner, int pinvictim, int zombieClass, float timeA, float timeB, bool withShove, bool headshot )

/**
 * @brief Called when boomer vomit survivors
 * 
 * @param boomer 			Client index of boomer
 * @param amount			Number of survivors on vomit effect
 * 
 * @noreturn
 */
forward void OnBoomerVomitLanded( int boomer, int amount )

/**
 * @brief Called when the survivor bunnyhop in a row
 * 
 * @param survivor 			Client index of survivor
 * @param streak			Number of bunnyhop streaks
 * @param maxVelocity		Top speed
 * 
 * @noreturn
 */
forward void OnBunnyHopStreak( int survivor, int streak, float maxVelocity )

 /**
 * @brief Called whenever the survivor trigger the alarm car
 * 
 * @param survivor   Client index of survivor
 * @param infected   Client index of special infected (Could be 0 if was not because the special infected)
 * @param reason     The reason why alaram was triggered, 0 = CALARM_UNKNOWN, 1 = CALARM_HIT, 2 = CALARM_TOUCHED, 3 = CALARM_EXPLOSION, 4 = CALARM_BOOMER
 *
 * @noreturn
 */
forward void OnCarAlarmTriggered( int survivor, int infected, int reason )

public SharedPlugin __pl_l4d2_skill_detect =
{
	name = "skill_detect",
	file = "l4d2_skill_detect.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_skill_detect_SetNTVOptional()
{
	
}
#endif