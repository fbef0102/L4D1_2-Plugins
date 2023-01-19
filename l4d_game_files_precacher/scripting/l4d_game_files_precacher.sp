#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define PLUGIN_VERSION		"1.0h"

public Plugin myinfo = 
{
	name = "[L4D1/2] Model Precacher",
	author = "Alex Dragokas & cravenge & HarryPotter",
	description = "Precaches Game Files To Prevent Crashes. + Prevents late precache of specific models",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showpost.php?p=2720454&postcount=13"
};

bool g_bLeft4dead2;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		g_bLeft4dead2 = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		g_bLeft4dead2 = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{

}

public void OnMapStart()
{
	if( g_bLeft4dead2 )
	{
		PrecacheL4D2();
	}
	else {
		PrecacheL4D1();
	}
}

void PrecacheL4D1()
{
	PrecacheModel("models/props_junk/wood_crate001a_chunk01.mdl" , true);
	PrecacheModel("models/props_junk/wood_crate001a_chunk02.mdl" , true);
	PrecacheModel("models/props_junk/wood_crate001a_chunk03.mdl" , true);
	PrecacheModel("models/props_junk/wood_crate001a_chunk04.mdl" , true);
	PrecacheModel("models/props_junk/wood_crate001a_chunk05.mdl" , true);
	PrecacheModel("models/props_junk/wood_crate001a_chunk06.mdl" , true);
	PrecacheModel("models/props_junk/wood_crate001a_chunk07.mdl" , true);
	PrecacheModel("models/props_junk/wood_crate001a_chunk08.mdl" , true);
	PrecacheModel("models/props_junk/wood_crate001a_chunk09.mdl" , true);
	
	PrecacheSound("music/terror/PuddleOfYou.wav", true);
	PrecacheSound("music/terror/ClingingToHellHit1.wav", true);
	PrecacheSound("music/terror/ClingingToHellHit2.wav", true);
	PrecacheSound("music/terror/ClingingToHellHit3.wav", true);
	PrecacheSound("music/terror/ClingingToHellHit4.wav", true);
	
	PrecacheModel("sprites/glow_test02.vmt", true);
}
	
void PrecacheL4D2()
{
	// survivor model
	PrecacheModel("models/survivors/survivor_biker.mdl", true); 
	PrecacheModel("models/survivors/survivor_manager.mdl", true);
	PrecacheModel("models/survivors/survivor_teenangst.mdl", true);
	PrecacheModel("models/survivors/survivor_coach.mdl", true);
	PrecacheModel("models/survivors/survivor_gambler.mdl", true);
	PrecacheModel("models/survivors/survivor_namvet.mdl", true);
	PrecacheModel("models/survivors/survivor_mechanic.mdl", true);
	PrecacheModel("models/survivors/survivor_producer.mdl", true);
	
	// survivor arm model
	PrecacheModel("models/weapons/arms/v_arms_gambler_new.mdl", true);
	PrecacheModel("models/weapons/arms/v_arms_producer_new.mdl", true);
	PrecacheModel("models/weapons/arms/v_arms_coach_new.mdl", true);
	PrecacheModel("models/weapons/arms/v_arms_mechanic_new.mdl", true);
	PrecacheModel("models/weapons/arms/v_arms_bill.mdl", true);
	PrecacheModel("models/weapons/arms/v_arms_zoey.mdl", true);
	PrecacheModel("models/weapons/arms/v_arms_francis.mdl", true);
	PrecacheModel("models/weapons/arms/v_arms_louis.mdl", true);
	
	// weapon
	PrecacheModel("models/v_models/v_rif_sg552.mdl", true);
	PrecacheModel("models/v_models/v_smg_mp5.mdl", true);
	PrecacheModel("models/v_models/v_snip_awp.mdl", true);
	PrecacheModel("models/v_models/v_snip_scout.mdl", true);
	PrecacheModel("models/v_models/v_grenade_launcher.mdl", true);
	PrecacheModel("models/v_models/v_m60.mdl", true);
	PrecacheModel("models/w_models/weapons/50cal.mdl", true);
	PrecacheModel("models/w_models/weapons/w_rifle_sg552.mdl", true);
	PrecacheModel("models/w_models/weapons/w_smg_mp5.mdl", true);
	PrecacheModel("models/w_models/weapons/w_sniper_awp.mdl", true);
	PrecacheModel("models/w_models/weapons/w_sniper_scout.mdl", true);
	PrecacheModel("models/w_models/weapons/w_grenade_launcher.mdl", true);
	PrecacheModel("models/w_models/weapons/w_m60.mdl", true);
	PrecacheModel("models/w_models/weapons/w_minigun.mdl", true);
	
	// melee
	PrecacheModel("models/weapons/melee/v_machete.mdl", true);
	PrecacheModel("models/weapons/melee/w_machete.mdl", true);
	PrecacheModel("models/weapons/melee/v_bat.mdl", true);
	PrecacheModel("models/weapons/melee/w_bat.mdl", true);
	PrecacheModel("models/weapons/melee/v_cricket_bat.mdl", true);
	PrecacheModel("models/weapons/melee/w_cricket_bat.mdl", true);
	PrecacheModel("models/weapons/melee/v_crowbar.mdl", true);
	PrecacheModel("models/weapons/melee/w_crowbar.mdl", true);
	PrecacheModel("models/weapons/melee/v_electric_guitar.mdl", true);
	PrecacheModel("models/weapons/melee/w_electric_guitar.mdl", true);
	PrecacheModel("models/weapons/melee/v_frying_pan.mdl", true);	
	PrecacheModel("models/weapons/melee/w_frying_pan.mdl", true);
	PrecacheModel("models/weapons/melee/v_katana.mdl", true);
	PrecacheModel("models/weapons/melee/w_katana.mdl", true);
	PrecacheModel("models/weapons/melee/v_fireaxe.mdl", true);
	PrecacheModel("models/weapons/melee/w_fireaxe.mdl", true);
	PrecacheModel("models/weapons/melee/v_golfclub.mdl", true);	
	PrecacheModel("models/weapons/melee/w_golfclub.mdl", true);
	PrecacheModel("models/weapons/melee/v_tonfa.mdl", true);	
	PrecacheModel("models/weapons/melee/w_tonfa.mdl", true);
	PrecacheModel("models/weapons/melee/v_tonfa_riot.mdl", true);
	PrecacheModel("models/weapons/melee/w_tonfa_riot.mdl", true);
	PrecacheModel("models/weapons/melee/v_shovel.mdl", true);
	PrecacheModel("models/weapons/melee/w_shovel.mdl", true);
	PrecacheModel("models/weapons/melee/v_pitchfork.mdl", true);
	PrecacheModel("models/weapons/melee/w_pitchfork.mdl", true);
	PrecacheModel("models/v_models/v_knife_t.mdl", true);
	PrecacheModel("models/w_models/weapons/w_knife_t.mdl", true);

	// melee script
	PrecacheGeneric("scripts/melee/baseball_bat.txt", true);
	PrecacheGeneric("scripts/melee/cricket_bat.txt", true);
	PrecacheGeneric("scripts/melee/crowbar.txt", true);
	PrecacheGeneric("scripts/melee/electric_guitar.txt", true);
	PrecacheGeneric("scripts/melee/fireaxe.txt", true);
	PrecacheGeneric("scripts/melee/frying_pan.txt", true);
	PrecacheGeneric("scripts/melee/golfclub.txt", true);
	PrecacheGeneric("scripts/melee/katana.txt", true);
	PrecacheGeneric("scripts/melee/machete.txt", true);
	PrecacheGeneric("scripts/melee/tonfa.txt", true);
	PrecacheGeneric("scripts/melee/pitchfork.txt", true);
	PrecacheGeneric("scripts/melee/shovel.txt", true);
	
	// bile juice + cola + gnome
	PrecacheModel("models/v_models/v_bile_flask.mdl", true);	
	PrecacheModel("models/w_models/weapons/w_eq_bile_flask.mdl", true);
	PrecacheModel("models/w_models/weapons/v_cola.mdl", true);
	PrecacheModel("models/w_models/weapons/w_cola.mdl", true);
	PrecacheModel("models/weapons/melee/v_gnome.mdl", true);
	PrecacheModel("models/weapons/melee/w_gnome.mdl", true);
	
	// upgrade pack
	PrecacheModel("models/v_models/v_incendiary_ammopack.mdl", true);
	PrecacheModel("models/w_models/weapons/w_eq_incendiary_ammopack.mdl", true);
	PrecacheModel("models/v_models/v_explosive_ammopack.mdl", true);
	PrecacheModel("models/w_models/weapons/w_eq_explosive_ammopack.mdl", true);
	
	// special infected
	PrecacheModel("models/infected/smoker.mdl", true);
	PrecacheModel("models/infected/smoker_l4d1.mdl", true);
	PrecacheModel("models/infected/boomer.mdl", true);
	PrecacheModel("models/infected/boomette.mdl", true);
	PrecacheModel("models/infected/limbs/exploded_boomette.mdl", true);
	PrecacheModel("models/infected/boomer_l4d1.mdl", true);
	PrecacheModel("models/infected/hunter.mdl", true);
	PrecacheModel("models/infected/hunter_l4d1.mdl", true);
	PrecacheModel("models/infected/spitter.mdl", true);
	PrecacheModel("models/infected/jockey.mdl", true);
	PrecacheModel("models/infected/charger.mdl", true);
	
	// infected hulk
	PrecacheModel("models/infected/hulk.mdl", true);
	PrecacheModel("models/infected/hulk_dlc3.mdl", true);
	PrecacheModel("models/infected/hulk_l4d1.mdl", true);
	
	// witch
	PrecacheModel("models/infected/witch.mdl", true);
	PrecacheModel("models/infected/witch_bride.mdl", true);
	
	// special common infected
	PrecacheModel("models/infected/common_male_ceda.mdl", true);
	PrecacheModel("models/infected/common_male_clown.mdl", true);
	PrecacheModel("models/infected/common_male_fallen_survivor.mdl", true);
	PrecacheModel("models/infected/common_male_jimmy.mdl", true);
	PrecacheModel("models/infected/common_male_mud.mdl", true);
	PrecacheModel("models/infected/common_male_riot.mdl", true);
	PrecacheModel("models/infected/common_male_roadcrew.mdl", true);
	
	// gascan + explosive box + propanecanister
	PrecacheModel("models/props_junk/gascan001a.mdl", true);
	PrecacheModel("models/props_junk/explosive_box001.mdl", true);
	PrecacheModel("models/props_junk/propanecanister001a.mdl", true);
	
	// car tire + airport hittable ball
	PrecacheModel("models/props_vehicles/tire001c_car.mdl", true);
	PrecacheModel("models/props_unique/airport/atlas_break_ball.mdl", true);
	
	// ammo
	PrecacheModel("models/props_unique/spawn_apartment/coffeeammo.mdl");
	
	// sound
	PrecacheSound("player/survivor/voice/teengirl/hordeattack10.wav", true);
	PrecacheSound("ambient/fire/gascan_ignite1.wav", true);
	PrecacheSound("player/charger/hit/charger_smash_02.wav", true);
	PrecacheSound("npc/infected/action/die/male/death_42.wav", true);
	PrecacheSound("npc/infected/action/die/male/death_43.wav", true);
	PrecacheSound("ambient/energy/zap1.wav", true);
	PrecacheSound("ambient/energy/zap5.wav", true);
	PrecacheSound("ambient/energy/zap7.wav", true);
	PrecacheSound("player/spitter/voice/warn/spitter_spit_02.wav", true);
	PrecacheSound("player/tank/voice/growl/tank_climb_01.wav", true);
	PrecacheSound("player/tank/voice/growl/tank_climb_02.wav", true);
	PrecacheSound("player/tank/voice/growl/tank_climb_03.wav", true);
	PrecacheSound("player/tank/voice/growl/tank_climb_04.wav", true);
	
	//late precache
	PrecacheModel("models/deadbodies/dead_male_civilian_body.mdl");
	PrecacheModel("models/deadbodies/dead_male_sittingchair.mdl");
	PrecacheModel("models/props/cs_militia/fireplacechimney01.mdl");
	PrecacheModel("models/props/cs_militia/militiarock01.mdl");
	PrecacheModel("models/props/cs_militia/militiarock02.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb.mdl");
	PrecacheModel("models/props/cs_office/computer_mouse.mdl");
	PrecacheModel("models/props/de_prodigy/ammo_can_02.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_gib1.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_gib2.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p1.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p1a.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p2.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p2a.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p3.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p3a.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p4.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p4a.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p4b.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p5.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p5a.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p5b.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p6.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p6a.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p6b.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p7.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p7a.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p8.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p8a.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p9.mdl");
	PrecacheModel("models/props/cs_office/computer_caseb_p9a.mdl");
	PrecacheModel("models/props_c17/computer01_keyboard.mdl");
	PrecacheModel("models/props_crates/static_crate_40.mdl");
	PrecacheModel("models/props_downtown/booth_table.mdl");
	PrecacheModel("models/props_fairgrounds/alligator.mdl");
	PrecacheModel("models/props_fairgrounds/anvil_case_casters_64.mdl");
	PrecacheModel("models/props_fairgrounds/bass_case.mdl");
	PrecacheModel("models/props_foliage/trees_cluster01.mdl");
	PrecacheModel("models/props_interiors/computer_monitor.mdl");
	PrecacheModel("models/props_interiors/desk_metal.mdl");
	PrecacheModel("models/props_interiors/computer_monitor_p1.mdl");
	PrecacheModel("models/props_interiors/computer_monitor_p1a.mdl");
	PrecacheModel("models/props_interiors/computer_monitor_p2.mdl");
	PrecacheModel("models/props_interiors/computer_monitor_p2a.mdl");
	PrecacheModel("models/props_lighting/lightbulb01a.mdl");
	PrecacheModel("models/props_pipes/pipeset08d_128_001a.mdl");
	PrecacheModel("models/props_unique/spawn_apartment/lantern.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallhospitalexterior01_main.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalframe01_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart01_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart02_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart03_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart04_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart05_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart06_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart07_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart08_dm.mdl");
	PrecacheModel("models/props_unique/zombiebreakwallexteriorhospitalpart09_dm.mdl");
	PrecacheModel("models/props_update/plywood_128.mdl");
	PrecacheModel("models/props_urban/gas_meter.mdl");
	PrecacheModel("models/props_vehicles/deliveryvan_armored.mdl");
	PrecacheModel("models/props_vehicles/deliveryvan_armored_glass.mdl");
	PrecacheModel("models/props_vehicles/pickup_truck_2004.mdl");
	PrecacheModel("models/props_vehicles/pickup_truck_2004_glass.mdl");
	PrecacheModel("models/props_vehicles/racecar_damaged_glass.mdl");
	PrecacheModel("models/props_vehicles/van.mdl");
	PrecacheModel("models/props_vehicles/van_glass.mdl");

	// late precache
	PrecacheSound("physics/destruction/ExplosiveGasLeak.wav");
}