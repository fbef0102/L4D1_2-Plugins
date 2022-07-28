Change target when the witch incapacitates or kills victim + witchs auto follow survivors

-ChangeLog-
v1.7
-AlliedModders Post: https://forums.alliedmods.net/showpost.php?p=2732048&postcount=9
* Witch is allowed to chase another target after she incapacitates a survivor. 
* Witch is allowed to chase another target after she kills a survivor. 
* Witch will not follow survivor if there is a wall between witch and survivor.
* Witch will not follow survivor if survivor standing on the higher place.
* Witch burns for a set amount of time and die. (z_witch_burn_time 15 seconds = default)

-Convars-
cfg/sourcemod/witch_target_override.cfg
// Chance of following survivors [0, 100]
witch_target_override_chance_followsurvivor "100"

// Witch's vision range , witch will follow you if in range. [100.0, 9999.0] 
witch_target_override_followsurvivor_range "500.0"

// Witch's following speed.
witch_target_override_followsurvivor_speed "45.0"

// If 1, allow witch to chase another target after she incapacitates a survivor.
witch_target_override_incap "1"

// Add witch health if she is allowed to chase another target after she incapacitates a survivor. (0=Off)
witch_target_override_incap_health_add "100"

// If 1, allow witch to chase another target after she kills a survivor.
witch_target_override_kill "1"

// Add witch health if she is allowed to chase another target after she kills a survivor. (0=Off)
witch_target_override_kill_health_add "400"

// 1=Plugin On. 0=Plugin Off
witch_target_override_on "1"

// This controls the range for witch to reacquire another target. [1.0, 9999.0] (If no targets within range, witch default behavior)
witch_target_override_range "9999"

// If 1, the burning witch restarts and recalculates burning time if she is allowed to chase another target. (0=after witch burns for a set amount of time z_witch_burn_time, she dies from the fire)
witch_target_override_recalculate_burn_time "0"

-Command-
None