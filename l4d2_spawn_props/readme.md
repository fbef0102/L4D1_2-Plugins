# Description | 內容
Let admins spawn any kind of objects and saved to cfg

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Video | 影片展示
	* [Demonstration](https://youtu.be/AQ_JZa2u434)
    * [Unlimited Map C8 by Harry](https://youtu.be/I_-QSn8F8Cs)
    * [L4D2-Unlimited-Map](https://github.com/fbef0102/L4D2-Unlimited-Map)

* <details><summary>Image | 圖示</summary>

	<br/>![l4d2_spawn_props_1](image/l4d2_spawn_props_1.jpg)
	<br/>![l4d2_spawn_props_2](image/l4d2_spawn_props_2.jpg)
	<br/>![l4d2_spawn_props_3](image/l4d2_spawn_props_3.jpg)
	<br/>![l4d2_spawn_props_4](image/l4d2_spawn_props_4.jpg)
	<br/>![l4d2_spawn_props_5](image/l4d2_spawn_props_5.jpg)
	<br/>![l4d2_spawn_props_6](image/l4d2_spawn_props_6.jpg)
	<br/>![l4d2_spawn_props_7](image/l4d2_spawn_props_7.jpg)
	<br/>![l4d2_spawn_props_8](image/l4d2_spawn_props_8.jpg)
	<br/>![l4d2_spawn_props_9](image/l4d2_spawn_props_9.jpg)
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)
    3. [Install Stripper:Source](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_教學區/English/Server/Install_Other_File#stripper): Save objects/items permanently
		* [安裝Stripper:Source](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_教學區/Chinese_繁體中文/Server/安裝其他檔案教學#安裝stripper): 永久保存障礙物與物品於地圖上

* <details><summary>How to use</summary>

	* Type ```!admin``` to call adm menu and you will see "Spawn Objects" option
	* **Create Object**
        1. Admin types !admin in chat->Spawn Objects->Spawn Objects->Select the spawn method
        2. Physics（affected by gravity, can be moved by Tanks），Non-solid（you can go through it），Solid（won't be affected by gravity），Items&Weapons（Guns, Melees, Supplies, Throwables, etc.）
			* Not all objects can be Physics
			* Not all objects can be Non-solid
			* Not all objects can be Solid (Go ask Valve)

	* **Save Object**
        1. Admin types ```!admin``` in chat->Spawn Objects->Save Objects->Save Stripper File
		2. All Spawned objects will be saved into ```addons\stripper\maps\xxxxx.cfg```
			* xxxx is map name
			* Auto-generate xxxxx.cfg if file not exist
		3. Restart Map

	* **Delete Object**
        1. Modify file: ```addons\stripper\maps\xxxxx.cfg```
			* xxxx is map name
		2. Find the object you want to delete by classname, origin, angles
		3. Delete code {}，for example:
			```php
			{
				"solid" "6"
				"origin" "2408 -140 0"
				"angles" "0 93 0"
				"model"	 "models/props/cs_militia/boxes_frontroom.mdl"
				"classname"	"prop_dynamic"
			}
			```

	* Auto save the objects when map change or round ends. For people who always forget to save objects :(
</details>

* <details><summary>Q&A</summary>

	* How to add more models and translate name?
		* Modify [data/l4d2_spawn_props_models_english.txt](data/l4d2_spawn_props_models_english.txt)
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d2_spawn_props.cfg
		```php
        // If 1, Enable the Decorative category
        l4d2_spawn_props_category_decorative "1"

        // If 1, Enable the Exterior category
        l4d2_spawn_props_category_exterior "1"

        // If 1, Enable the Foliage category
        l4d2_spawn_props_category_foliage "1"

        // If 1, Enable the Interior category
        l4d2_spawn_props_category_interior "1"

        // If 1, Enable the Misc category
        l4d2_spawn_props_category_misc "1"

        // If 1, Enable the Vehicles category
        l4d2_spawn_props_category_vehicles "1"

        // If 1, Enable the Dynamic (Non-solid) Objects in the menu
        l4d2_spawn_props_dynamic "1"

        // If 1, Enable the Static (Solid) Objects in the menu
        l4d2_spawn_props_static "1"

        // If 1, Enable the Physics Objects in the menu
        l4d2_spawn_props_physics "1"

        // If 1, Enable the Items & Weapons Objects in the menu
        l4d2_spawn_props_items "1"

        // If 1, Log if an admin spawns an object?
        l4d2_spawn_props_log_actions "0"

		// Model file to read, default: data/l4d2_spawn_props_models_english.txt
		// -
		// Default: "data/l4d2_spawn_props_models_english.txt"
		l4d2_spawn_props_model_file "data/l4d2_spawn_props_models_english.txt"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Spawns an object with the given information (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_spawnprop <model> [static | dynamic | physics] [cursor | origin]
		```

	* **Save all the spawned object in a stripper file, path: addons/stripper/maps/XXXX.cfg (XXXX is map name) (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_savemap
		```

	* **Rotates the looking spawned object with the desired angles, e.g.: !prop_rotate x 30 (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_rotate sm_prop_rotate <axys> <angles> [e.g.: !prop_rotate x 30]
		```

	* **Remove last spawned object (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_removelast
		```

	* **Remove the looking object (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_removelook
		```

	* **Remove all spawned objects (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_removeall
		```

	* **Move the looking spawned object with the desired movement type [EX: !prop_move x 30] (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_move <axys> <distance>
		```

	* **Forces the looking spawned object angles [e.g.: !prop_setang 30 0 34] (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_setang <X Y Z>
		```

	* **Sets the looking spawned object position [e.g.: !prop_setpos 505 -34 17] (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_setpos <X Y Z>
		```

	* **Locks the looking spawned object, Use for move and rotate (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_lock
		```

	* **Clone the last spawned object (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_clone
		```

	* **Print the looking object information (Adm required: ADMFLAG_UNBAN)**
		```php
		sm_prop_print
		```
</details>

* Translation Support | 支援翻譯
	```
	translations/l4d2_spawn_props.phrases.txt
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v4.3 (2026-3-15)
		* Update translation
		* Update cvars
		* Add Chinese and English model data file

	* v4.2 (2025-5-23)
		* Suppprt float number

	* v4.1 (2024-3-24)
		* Fixed error

	* v4.0 (2023-2-21)
		* Support stripper cvar to save map.cfg
			```c
			// Stripper Config Path
			stripper_cfg_path "addons/stripper"
			```

	* v3.9 (2023-1-5)
        * Fixed Item Position Menu Error.

	* v3.8 (2022-11-3)
        * Remake Code
        * Translation Support
        * some menu has back button
        * menu won't be disappeared if I spawn an object
        * Add more options
        * More objects
        * New Spawn Method: Items&Weapons, you can spawn Guns, Melees, Supplies, Throwables, etc.
        * Remove routing, cache, only stripper save method

	* v2.0
        * [Original Post by honorcode23](https://forums.alliedmods.net/showthread.php?t=127418)
</details>

- - - -
# 中文說明
創造屬於自己風格的地圖，製作迷宮與障礙物

* <details><summary>如何使用?</summary>

	* 如何創造物件?
		1. 管理員輸入```!admin```->生成物件->生成物件->選擇其中一項
		2. 動態（會受重力影響, Tank可以揮拳使其移動），穿透（擺好看），固定（不受重力影響），物品（槍械、近戰、醫療物品、投擲物品、彈藥堆、雷射裝置）
			* 非所有模型都能變成動態
			* 非所有模型都能變成穿透
			* 非所有模型都能變成固態 (去問Valve，認真你就輸了)

	* 如何儲存物件?
		1. 管理員輸入```!admin```->生成物件->儲存物件
		2. 生成的物件會儲存於```addons\stripper\maps\xxxxx.cfg```
			* xxxx是地圖名
			* 沒有此cfg也會自動產生
		3. 重啟地圖

	* 如何刪除已經儲存的物件?
		1. 編輯檔案 ```addons\stripper\maps\xxxxx.cfg```
			* xxxx是地圖名
		2. 透過 ```"model" "origin" "angles"```關鍵字查找你要刪除的物件
			* origin: 位置
			* angles: 角度
			* model: 模組
		3. 刪除整段上下{}，譬如
			```php
			{
				"solid" "6"
				"origin" "2408 -140 0"
				"angles" "0 93 0"
				"model"	 "models/props/cs_militia/boxes_frontroom.mdl"
				"classname"	"prop_dynamic"
			}
			```

	* 回合結束或切換地圖時, 自動保存尚未儲存的物件 (因為玩家容易忘記儲存物件)
</details>

* <details><summary>Q&A</summary>

	* 如何變成中文模組菜單?
		* 修改插件的指令
			```c
			// 取模組的文件檔案，換成中文菜單請修改成 "data/l4d2_spawn_props_models_chinese.txt"
			l4d2_spawn_props_model_file "data/l4d2_spawn_props_models_chinese.txt"
			```

	* 如何增加更多模組?
		* 編輯檔案 [data/l4d2_spawn_props_models_english.txt](data/l4d2_spawn_props_models_english.txt)
		* 編輯檔案 [data/l4d2_spawn_props_models_chinese.txt](data/l4d2_spawn_props_models_chinese.txt)
</details>


* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d2_spawn_props.cfg
		```php
        // 為1時, 啟用 "裝飾類"
        l4d2_spawn_props_category_decorative "1"

        // 為1時, 啟用 "室外類"
        l4d2_spawn_props_category_exterior "1"

        // 為1時, 啟用 "植物類"
        l4d2_spawn_props_category_foliage "1"

        // 為1時, 啟用 "室內類"
        l4d2_spawn_props_category_interior "1"

        // 為1時, 啟用 "雜項類"
        l4d2_spawn_props_category_misc "1"

        // 為1時, 啟用 "載具類"
        l4d2_spawn_props_category_vehicles "1"

        // 為1時, 啟用 "生成穿透物件"（擺好看）
        l4d2_spawn_props_dynamic "1"

        // 為1時, 啟用 "生成固定物件"（不受重力影響）
        l4d2_spawn_props_static "1"

        // 為1時, 啟用 "生成動態物件"（受重力影響）
        l4d2_spawn_props_physics "1"

        // 為1時, 啟用 "生成物品物件" (槍械、近戰、醫療物品、投擲物品、彈藥堆、雷射裝置）
        l4d2_spawn_props_items "1"

        // 為1時, 任何管理員的動作(生成或刪除)都會紀錄文件，位於addons/souremod/logs資料夾
        l4d2_spawn_props_log_actions "0"

		// 取模組的文件檔案，想要換成中文菜單請修改成 "data/l4d2_spawn_props_models_chinese.txt"
		// 預設: data/l4d2_spawn_props_models_english.txt
		l4d2_spawn_props_model_file "data/l4d2_spawn_props_models_english.txt"
		```
</details>

* <details><summary>命令中文介紹 (點我展開)</summary>

	* **生成模型 (權限: ADMFLAG_UNBAN)**
		```php
		sm_spawnprop <model> [static | dynamic | physics] [cursor | origin]
		```

	* **儲存所有物件到 stripper 文件, 路徑: addons/stripper/maps/XXXX.cfg (XXXX是地圖名稱) (權限: ADMFLAG_UNBAN)**
		```php
		sm_savemap
		```

	* **準心指向的物件指定X/Y/Z軸旋轉角度 [範例: !prop_rotate x 30] (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_rotate <x y z> <角度>
		```

	* **移除最後一個生成的物件 (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_removelast
		```

	* **移除準心指向的物件 (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_removelook
		```

	* **移除所有生成過的物件 (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_removeall
		```

	* **準心指向的生成過的物件指定X/Y/Z軸移動位置 <distance> [範例:  !prop_move x 30] (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_move <寫x y z> <距離>
		```

	* **準心指向的生成過的物件設置旋轉角度 [範例:  !prop_setang 30 0 34] (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_setang <寫三個數字>
		```

	* **準心指向的生成過的物件移動位置 [範例:  !prop_setpos 505 -34 17] (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_setpos <寫三個數字>
		```

	* **鎖定準心指向的生成過的物件, 用於移動或是旋轉角度 (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_lock
		```

	* **複製被鎖定的物件 (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_clone
		```

	* **列印準心指向的物件各種資訊 (打印於聊天框上) (權限: ADMFLAG_UNBAN)**
		```php
		sm_prop_print
		```
</details>

