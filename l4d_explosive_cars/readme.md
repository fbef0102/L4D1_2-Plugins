# Description | 內容
Cars explode after they take some damage

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* [Video | 影片展示](https://youtu.be/B_-pOplOML4)

* Image
	* Cars Explosions (車子會爆炸)
	<br/>![l4d_explosive_cars_1](image/l4d_explosive_cars_1.gif)

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_explosive_cars.cfg
        ```php
		// Maximum health of the cars
		l4d_explosive_cars_health "5000"

		// Maximum radius of the explosion
		l4d_explosive_cars_radius "420"

		// (L4D2 only) Power of the explosion when the car explodes
		l4d_explosive_cars_power "300"

		// Damage made by the explosion
		l4d_explosive_cars_damage "10"

		// Should the car explosion cause a panic event? (1: Yes 0: No)
		l4d_explosive_cars_panic "1"

		// Chance that the cars explosion might call a horde (1 / CVAR) [1: Always]
		l4d_explosive_cars_panic_chance "5"

		// Should infected trigger the car explosion? (1: Yes 0: No)
		l4d_explosive_cars_infected "1"

		// How much damage do the tank deal to the cars? (0: Default, which is 999 from the engine)
		l4d_explosive_cars_tank "0"

		// Time to wait before removing the exploded car in case it blockes the way. (0: Don't remove)
		l4d_explosive_cars_removetime "60"

		// On which maps should the plugin disable itself? separate by commas (no spaces). (Example: c5m3_cemetery,c5m5_bridge)
		l4d_explosive_cars_unload_map "c5m3_cemetery,c5m5_bridge"

		// If 1, cars get damaged by another car's explosion
		l4d_explosive_cars_explosion_damage "1"

		// (L4D2) If 1, Display outline glow of car's health
		l4d_explosive_cars_health_outline "1"

		// (L4D2) Which method to send survivor flying by car.
		// 0=Flings a player to the ground, like they were hit by a Charger
		// 1=Stagger player
		l4d_explosive_cars_flying_method "0"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v2.5 (2024-11-11)
		* Fixed not working in l4d1

	* v2.4 (2024-8-5)
		* Add outline glow of car's health
		* Delete invisible fire
		* Update Cvars

	* v2.3 (2023-6-7)
		* Change back ```L4D_ForcePanicEvent()```
		* Fixed non-car hittables would burn and explode
		
	* v2.2 (2023-5-28)
		* Use ```z_spawn mob auto``` instead of ```L4D_ForcePanicEvent()```
		
	* v2.1 (2023-2-14)
		* Support L4D1

	* v2.0
		* [AlliedModder post](https://forums.alliedmods.net/showpost.php?p=2751903&postcount=217)
		* Remake code
		* Replace left4downtown with left4dhooks
		* Remove car entity after it explodes
		* Fixed damage dealt to car
		* Safely create entity and safely remove entity
		* Safely explode cars between few secomds to prevent client from crash

    * v1.0.4
        * [Original Plugin by honorcode23](https://forums.alliedmods.net/showthread.php?p=1304463)
</details>

- - - -
# 中文說明
車子爆炸啦!

* 原理
	* 地圖上可以移動的車子如果受到一定程度的傷害，將會爆炸，並震飛周圍的倖存者
    * 地圖上某些車子不能移動也就不能爆炸，認真你就輸了

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_explosive_cars.cfg
        ```php
		// 車子的血量
		l4d_explosive_cars_health "5000"

		// 爆炸影響的範圍
		l4d_explosive_cars_radius "420"

		// (L4D2 only) 車子爆炸震開倖存者的力道 (倖存者飛得越遠)
		l4d_explosive_cars_power "300"

		// 爆炸所產生的傷害
		l4d_explosive_cars_damage "10"

		// 為1時，車子爆炸會導致屍潮
		l4d_explosive_cars_panic "1"

		// 車子爆炸導致屍潮的機率，機率 = 1/此數值 [1: 100%, 2: 50%, ...]
		l4d_explosive_cars_panic_chance "5"

		// 為1時，特感會抓傷車子引發爆炸
		l4d_explosive_cars_infected "1"

		// 設置Tank對車子造成的傷害值 (0: 遊戲預設, 一拳999傷害)
		l4d_explosive_cars_tank "0"

		// 車子爆炸60秒後自動移除. (0: 不移除)
		l4d_explosive_cars_removetime "60"

		// 在這些地圖上關閉此插件, 逗號區隔 (無空白). (範例: c5m3_cemetery,c5m5_bridge)
		l4d_explosive_cars_unload_map "c5m3_cemetery,c5m5_bridge"

		// 為1時，車子爆炸後也會對周圍的車子產生連鎖爆炸效應
		l4d_explosive_cars_explosion_damage "1"

		// (L4D2)  為1時，車子光圈顯示血量狀態 (黃->紅)
		l4d_explosive_cars_health_outline "1"

		// (L4D2) 選擇倖存者被車子爆炸炸飛的方式
		// 0=撞飛倖存者, 就像被Charger撞到
		// 1=震退倖存者
		l4d_explosive_cars_flying_method "0"
        ```
</details>

