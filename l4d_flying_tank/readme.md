# Description | 內容
Provides the ability to fly to Tanks and special effects.

* [Video | 影片展示](https://youtu.be/c1bY8Zgvd4s)

* Image | 圖示
	<br/>![l4d_flying_tank_1](image/l4d_flying_tank_1.gif)
	<br/>![l4d_flying_tank_2](image/l4d_flying_tank_2.gif)

* Require | 必要安裝
<br/>None

* <details><summary>How does it work?</summary>

	* Tank player can press space key to fly 
		* (W)(S)(D)(A)
		* (Space)
		* (Shift)
		* (E)
	* Also apply to AI Tank
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_flying_tank.cfg
		```php
		// 0=Plugin off, 1=Plugin on.
		l4d_flying_tank_enable "1"

		// If 1, Enable the ability to fly for Tanks only in final.
		l4d_flying_tank_finale_only "0"

		// Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
		l4d_flying_tank_gamemodes_on ""

		// Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
		l4d_flying_tank_gamemodes_off ""

		// Turn on the plugin in these game modes.
		// 0 = All, 1 = Coop, 2 = Survival, 4 = Versus, 8 = Scavenge.
		// Add numbers together.
		l4d_flying_tank_gamemodes_toggle "0"

		// Allow the plugin being loaded on these maps, separate by commas (no spaces). Empty = all.
		// Example: "l4d_hospital01_apartment,c1m1_hotel"
		l4d_flying_tank_maps_on ""

		// Prevent the plugin being loaded on these maps, separate by commas (no spaces). Empty = none.
		// Example: "l4d_hospital01_apartment,c1m1_hotel"
		l4d_flying_tank_maps_off ""

		// Probability of flying when the AI Tank throws a rock.
		l4d_flying_tank_chance_throw_ai "40.0"

		// Probability of flying when the AI Tank hits.
		l4d_flying_tank_chance_claw_ai "50.0"

		// Probability of flying when the Tank Player jumps.
		l4d_flying_tank_chance_jump_real "100.0"

		// Probability of flying when the AI Tank jumps.
		l4d_flying_tank_chance_jump_ai "40.0"

		// Set the speed of the Tank player when him is flying.
		l4d_flying_tank_speed_real "150.0"

		// Set the speed of the AI Tank when him is flying.
		l4d_flying_tank_speed_ai "200.0"

		// Set the max flight time for Tank player.
		l4d_flying_tank_maxtime_real "10.0"

		// Set the max flight time for AI tank.
		l4d_flying_tank_maxtime_ai "20.0"

		// (L4D2) Enable the glow when Tank is flying.
		// 0 = Glow OFF
		// 1 = Glow ON.
		l4d_flying_tank_glow "1"

		// Enable the crown when Tank is fliying.
		// 0 = Crown of light OFF.
		// 1 = Crown of light ON.
		l4d_flying_tank_crown "1"

		// Enable the light effect of the jetpack when the Tank is flying.
		// 0 = JetPack Light OFF.
		// 1 = JetPack Light ON.
		l4d_flying_tank_light_system "1"

		// Enable the Message to Tank player.
		// 0 = Message OFF
		// 1 = Message ON.
		l4d_flying_tank_ads "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>


* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Translation Support | 支援翻譯</summary>

	```
	English
	繁體中文
	简体中文
	```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

    1. [l4d_tracerock](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Nothing_Impossible_%E7%84%A1%E7%90%86%E6%94%B9%E9%80%A0%E7%89%88/l4d_tracerock): Tank's rock will trace survivor until hit something.
        > Tank的石頭自動追蹤倖存者
</details>

* <details><summary>Changelog | 版本日誌</summary>

	```php
	//Ernecio @ 2020
	//HarryPotter @ 2021-2023
	```
	* v1.0h (2023-12-8)
		* Remake code, convert code to latest syntax
		* Fix warnings when compiling on SourceMod 1.11.
		* Optimize code and improve performance
		* Translation Support
		* Add more cvars
		* Control real tank player and AI Tank
		* Safely create entity and remove

	* v2.6
		* [Original Plugin by Ernecio](https://forums.alliedmods.net/showthread.php?t=325719)
</details>

- - - -
# 中文說明
Tank化身鋼鐵人，可以自由飛行

* 原理
	* Tank玩家按下空白鍵可以飛行
		* 移動: (W)(S)(D)(A)
		* 上升(Space)
		* 往前飛(Shift)
		* 下降(E)
	* AI Tank也會飛，是自動飛向玩家

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_flying_tank.cfg
		```php
		// 0=關閉插件, 1=啟動插件
		l4d_flying_tank_enable "1"

		// 為1時，此插件只會在救援階段啟動
		l4d_flying_tank_finale_only "0"

		// 什麼模式下啟動此插件, 逗號區隔 (無空白). (留白 = 所有模式)
		l4d_flying_tank_gamemodes_on ""

		// 什麼模式下關閉此插件, 逗號區隔 (無空白). (留白 = 無)
		l4d_flying_tank_gamemodes_off ""

		// 什麼模式下啟動此插件. 0=所有模式, 1=戰役, 2=生存, 4=對抗, 8=清道夫. 請將數字相加起來
		l4d_flying_tank_gamemodes_toggle "0"

		// 指定那些地圖下啟動此插件, 逗號區隔 (無空白). (留白 = 所有地圖)
		// 舉例: "l4d_hospital01_apartment,c1m1_hotel"
		l4d_flying_tank_maps_on ""

		// 指定那些地圖下關閉此插件, 逗號區隔 (無空白). (留白 = 所有地圖)
		// Example: "l4d_hospital01_apartment,c1m1_hotel"
		l4d_flying_tank_maps_off ""

		// AI Tank 丟石頭之後飛行的機率.
		l4d_flying_tank_chance_throw_ai "40.0"

		// AI Tank 揮拳之後飛行的機率.
		l4d_flying_tank_chance_claw_ai "50.0"

		// 真人Tank玩家使用空白鍵跳起來飛行的機率.
		l4d_flying_tank_chance_jump_real "100.0"

		// AI Tank 跳起來飛行的機率.
		l4d_flying_tank_chance_jump_ai "40.0"

		// 真人Tank玩家飛行速度
		l4d_flying_tank_speed_real "150.0"

		// AI Tank飛行速度
		l4d_flying_tank_speed_ai "200.0"

		// 真人Tank玩家時間
		l4d_flying_tank_maxtime_real "10.0"

		// AI Tank玩家時間
		l4d_flying_tank_maxtime_ai "20.0"

		// (L4D2) Tank飛行時身上發光 
		// 0 = 不發光
		// 1 = 發光 (不占用實體)
		l4d_flying_tank_glow "1"

		// Tank飛行時頭上有王冠特效 
		// 0 = 無王冠特效
		// 1 = 有王冠特效 (占用六個實體)
		l4d_flying_tank_crown "1"

		// Tank飛行時有噴射背包動態火
		// 0 = 無噴射背包動態火
		// 1 = 有噴射背包動態火 (占用兩個實體)
		l4d_flying_tank_light_system "1"

		// Tank飛行時提示玩家如何操作
		// 0 = 不提示
		// 1 = 要提示
		l4d_flying_tank_ads "1"
		```
</details>

