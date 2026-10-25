#if defined  _l4d2_replace_gun_item_included_
 #endinput
#endif
#define _l4d2_replace_gun_item_included_

/**
* Call this function to replace all melee/weapons/items with other melee/weapons/items now
* 
* @param Slot_Primary			Shoud Replace Primary Weapons (true = yes, false = no)
* @param Slot_Secondary			Shoud Replace Secondary Weapons (true = yes, false = no)
* @param Slot_Throwable			Shoud Replace Throwable (true = yes, false = no)
* @param Slot_HeavyHealthItem	Shoud Replace Slot 4 Items (true = yes, false = no)
* @param Slot_LightHealthItem	Shoud Replace Slot 5 Items (true = yes, false = no)
* @param Special				Shoud Replace Special Items (true = yes, false = no)
* @param Melee					Shoud Replace Melee Weaopns (true = yes, false = no)
*
* @return						None
*/
native void l4d2_RGI_ReplaceAllWeapons(bool Slot_Primary = true, bool Slot_Secondary = true, bool Slot_Throwable = true, bool Slot_HeavyHealthItem = true, bool Slot_LightHealthItem = true, bool Special = true, bool Melee = true);


public SharedPlugin __pl_l4d2_replace_gun_item =
{
	name = "l4d2_replace_gun_item",
	file = "l4d2_replace_gun_item.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_replace_gun_item_SetNTVOptional()
{
	MarkNativeAsOptional("l4d2_RGI_ReplaceAllWeapons");
}
#endif