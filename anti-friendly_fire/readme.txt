shoot your teammate = shoot yourself

-Changelog-
v1.4
-Disable Pipe Bomb Explosive friendly fire
-Disable Fire friendly fire.
-Friendly fire now will not incap player

-Require-
1. left4dhooks: https://forums.alliedmods.net/showthread.php?p=2684862

-Convar-
// Multiply friendly fire damage value and reflect to attacker. (1.0=original damage value)
anti_friendly_fire_damage_multi "2.0"

// Disable friendly fire damage if damage is below this value (0=Off).
anti_friendly_fire_damage_sheild "1"

// Enable anti-friendly_fire plugin [0-Disable,1-Enable]
anti_friendly_fire_enable "1"

// If 1, Disable Pipe Bomb, Propane Tank, and Oxygen Tank Explosive friendly fire.
anti_friendly_fire_immue_explode "0"

// If 1, Disable Fire friendly fire.
anti_friendly_fire_immue_fire "1"

// If 1, Disable friendly fire if damage is about to incapacitate victim.
anti_friendly_fire_incap_protect "1"
