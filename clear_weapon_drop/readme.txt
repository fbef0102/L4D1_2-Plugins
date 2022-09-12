Remove drop weapon + remove upgradepack when used

-ChangeLog-
v2.9
-Remake Code
-Remove gnome and cola
-Create Native
-Use EntIndexToEntRef and EntRefToEntIndex to remove entity safely

v1.7
-original Post: https://forums.alliedmods.net/showthread.php?p=2638375

-ConVar-
(L4D2) // Time in seconds to remove upgradepack on the ground after used. (0=off)
sm_drop_clear_ground_upgrade_pack_time "60"

(L4D2) // If 1, remove cola bottles after drops.
sm_drop_clear_weapon_cola_bottles "0"

(L4D2) // If 1, remove gnome after drops.
sm_drop_clear_weapon_gnome "0"

// Time in seconds  to remove weapon after drops. (0=off)
sm_drop_clear_weapon_time "60"

-Delete weapon list-
* weapons
{
	"weapon_smg_mp5",
	"weapon_smg",
	"weapon_smg_silenced",
	"weapon_shotgun_chrome",
	"weapon_pumpshotgun",
	"weapon_hunting_rifle",
	"weapon_pistol",
	"weapon_rifle_m60",
	//"weapon_first_aid_kit",
	"weapon_autoshotgun",
	"weapon_shotgun_spas",
	"weapon_sniper_military",
	"weapon_rifle",
	"weapon_rifle_ak47",
	"weapon_rifle_desert",
	"weapon_sniper_awp",
	"weapon_rifle_sg552",
	"weapon_sniper_scout",
	"weapon_grenade_launcher",
	"weapon_pistol_magnum",
	"weapon_molotov",
	"weapon_pipe_bomb",
	"weapon_vomitjar",
	"weapon_defibrillator",
	"weapon_pain_pills",
	"weapon_adrenaline",
	"weapon_melee",
	"weapon_upgradepack_incendiary",
	"weapon_upgradepack_explosive",
	//"weapon_gascan",
	"weapon_fireworkcrate",
	"weapon_propanetank",
	"weapon_oxygentank"
}

* upgradepack
{
	"models/props/terror/incendiary_ammo.mdl",
	"models/props/terror/exploding_ammo.mdl"
};

* special item
"weapon_gnome"
"weapon_cola_bottles"
