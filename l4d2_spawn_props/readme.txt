Let admins spawn any kind of objects and saved to cfg

-Video-
Unlimited Map C8 by Harry: https://www.youtube.com/watch?v=UTUjd6hlpt0

-L4D2-Unlimited-Map-
https://github.com/fbef0102/L4D2-Unlimited-Map

-ChangeLog-
v3.7
-Remake Code
-Translation Support
-some menu has back button
-menu won't be disappeared if I spawn an object
-Add more options
-More objects
-New Spawn Method: Items&Weapons, you can spawn Guns, Melees, Supplies, Throwables, etc.

v2.0
-Original Post: https://forums.alliedmods.net/showthread.php?t=127418

-How to use-
type !admin to call adm menu and you will see "Spawn Objects" option

---Create Object---
1. Admin types !admin in chat->Spawn Objects->Spawn Objects->Select the spawn method
2. Physics（affected by gravity），Non-solid（You can go through it），Solid（won't be affected by gravity），Items&Weapons（Guns, Melees, Supplies, Throwables, etc.）
3. I recommend "Solid" to prevent some models disappeared

---Save Object---
1. Admin types !admin in chat->Spawn Objects->Save Objects->Select The Save Method
2. I recommend "Save Stripper File", Don't know how to install stripper read this: http://www.bailopan.net/stripper/snapshots/1.2/

---Why I can't read object spawn menu?----
The data/l4d2_spawn_props_models.txt is Chinese language,
Either you translate by yourself
or just download english data here(but fewer models): https://forums.alliedmods.net/showpost.php?p=2607756&postcount=178

-Convars-
cfg\sourcemod\l4d2_spawn_props.cfg
// Enable the plugin to auto load the cache?
l4d2_spawn_props_autoload "0"

// Should the paths be different for the teams or not?
l4d2_spawn_props_autoload_different "1"

// Enable the Decorative category
l4d2_spawn_props_category_decorative "1"

// Enable the Exterior category
l4d2_spawn_props_category_exterior "1"

// Enable the Foliage category
l4d2_spawn_props_category_foliage "1"

// Enable the Interior category
l4d2_spawn_props_category_interior "1"

// Enable the Misc category
l4d2_spawn_props_category_misc "1"

// Enable the Vehicles category
l4d2_spawn_props_category_vehicles "1"

// Enable the Dynamic (Non-solid) Objects in the menu
l4d2_spawn_props_dynamic "1"

// Enable the Items & Weapons Objects in the menu
l4d2_spawn_props_items "1"

// Log if an admin spawns an object?
l4d2_spawn_props_log_actions "0"

// Enable the Physics Objects in the menu
l4d2_spawn_props_physics "1"

// Enable the Static (Solid) Objects in the menu
l4d2_spawn_props_static "1"

// Version of the Plugin
l4d2_spawn_props_version "3.3"


***中文說明***
---如何創造物件---
1. 管理員輸入!admin->生成物件->生成物件->選擇其中一項
2. 動態（會受重力影響），穿透（擺好看），固態（不受重力影響），物品（槍械、近戰、醫療物品、投擲物品、彈藥堆、雷射裝置）
3. 推薦選擇固態，避免發生模組不見的問題

---如何儲存物件---
1. 管理員輸入!admin->生成物件->儲存物件
2. 推薦選擇Stripper File，不知道stripper插件請閱讀: http://www.bailopan.net/stripper/snapshots/1.2/)



