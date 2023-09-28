# Description | 內容
Tanks throw special infected instead of rock

* [Video | 影片展示](https://youtu.be/v-hHB0XzyW0?si=iUmdRvYAsSS_K3KO)

* Image | 圖示
	<br/>![l4d_tankhelper_1](image/l4d_tankhelper_1.gif)
	<br/>![l4d_tankhelper_2](image/l4d_tankhelper_2.gif)
	<br/>![l4d_tankhelper_3](image/l4d_tankhelper_3.gif)
	<br/>![l4d_tankhelper_4](image/l4d_tankhelper_4.gif)

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [Actions](https://forums.alliedmods.net/showthread.php?t=336374)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_tankhelper.cfg
		```php
        // AI Tank throws helper special infected chance [0.0, 100.0]
        l4d_tank_throw_si_ai "100.0"

        // Real Tank Player throws helper special infected chance [0.0, 100.0]
        l4d_tank_throw_si_player "70.0"

        // Weight of helper Hunter[0.0, 10.0]
        l4d_tank_throw_hunter "2.0"

        // Weight of helper Smoker[0.0, 10.0]
        l4d_tank_throw_smoker "2.0"

        // Weight of helper Boomer[0.0, 10.0]
        l4d_tank_throw_boomer "2.0"

        // Weight of helper Charger [0.0, 10.0]
        l4d_tank_throw_charger "2.0"

        // Weight of helper Spitter [0.0, 10.0]
        l4d_tank_throw_spitter "2.0"

        // Weight of helper Jockey [0.0, 10.0]
        l4d_tank_throw_jockey "2.0"

        // Weight of helper Tank[0.0, 10.0]
        l4d_tank_throw_tank "2.0"

        // Weight of throwing Tank self[0.0, 10.0]
        l4d_tank_throw_self "10.0"

        // Helper Tank bot health
        l4d_tank_throw_tank_health "750"

        // Weight of helper Witch[0.0, 10.0]
        l4d_tank_throw_witch "2.0"

        // Helper Witch health
        l4d_tank_throw_witch_health "250"

        // Amount of seconds before a helper witch is kicked. (only remove witches spawned by this plugin)
        l4d_tank_throw_witch_lifespan "30"

        // Hunter Limit on the field[1 ~ 5] (if limit reached, throw Hunter teammate, if all hunters busy, throw Tank self)
        l4d_tank_throw_hunter_limit "2"

        // Smoker Limit on the field[1 ~ 5] (if limit reached, throw Smoker teammate, if all smokers busy, throw Tank self)
        l4d_tank_throw_smoker_limit "2"

        // Boomer Limit on the field[1 ~ 5] (if limit reached, throw Boomer teammate)
        l4d_tank_throw_boomer_limit "2"

        // Charger Limit on the field[1 ~ 5] (if limit reached, throw Charger teammate, if all chargers busy, throw Tank self)
        l4d_tank_throw_charger_limit "2"

        // Spitter Limit on the field[1 ~ 5] (if limit reached, throw Spitter teammate)
        l4d_tank_throw_spitter_limit "1"

        // Jockey Limit on the field[1 ~ 5] (if limit reached, throw Jockey teammate, if all jockeys busy, throw Tank self)
        l4d_tank_throw_jockey_limit "2"

        // Tank Limit on the field[1 ~ 10] (if limit reached, throw Tank teammate or yourself)
        l4d_tank_throw_tank_limit "3"

        // Witch Limit on the field[1 ~ 10] (if limit reached, throw Tank self)
        l4d_tank_throw_witch_limit "3"
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

* <details><summary>Related Plugin | 相關插件</summary>

	1. [l4d_tracerock](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Nothing_Impossible_%E7%84%A1%E7%90%86%E6%94%B9%E9%80%A0%E7%89%88/l4d_tracerock): Tank's rock will trace survivor until hit something.
		> Tank的石頭自動追蹤倖存者
</details>

* <details><summary>Changelog | 版本日誌</summary>

	```php
	//Pan Xiaohai @ 2010-2011
	//Harry @ 2022-2023
	```
	* v2.0h (2023-9-5)
        * Teleport Rock before removed

	* v1.9h (2023-5-21)
        * Fixed crash and error

	* v1.8h
		* Use left4dhooks to optimize code

	* v1.7h
        * [AlliedModders Post](https://forums.alliedmods.net/showpost.php?p=2771705&postcount=68)
		* Remake Code
		* Removed rock thrown sound (it's looping)
		* Throw Witch (Require Actions extension)
		* Separate chance for Real Tank player and AI Tank
		* ConVar to set infected limit
		* Create special infected without being limit by director

	* v1.0
		* [By Pan panxiaohai](https://forums.alliedmods.net/showthread.php?t=140254)
</details>

- - - -
# 中文說明
Tank不扔石頭而是扔出特感

* 原理
	* Tank的石頭變成特感扔出去
	    * 會扔特感隊友，沒特感隊友會自己生一個特感，特感數量達限制則扔自己
        * 會扔Witch或另一隻Tank
        * 偶而會把自己扔出去
    * AI Tank也適用

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_tankhelper.cfg
		```php
        // AI Tank的石頭變成特感扔出去的機率 [0.0 ~ 100.0]
        l4d_tank_throw_si_ai "100.0"

        // 真人 Tank的石頭變成特感扔出去的機率 [0.0 ~ 100.0]
        l4d_tank_throw_si_player "70.0"

        // 石頭變成Hunter的權重值 [0.0 ~ 10.0]
        l4d_tank_throw_hunter "2.0"

        // 石頭變成Smoker的權重值 [0.0 ~ 10.0]
        l4d_tank_throw_smoker "2.0"

        // 石頭變成Boomer的權重值[0.0 ~ 10.0]
        l4d_tank_throw_boomer "2.0"

        // 石頭變成Charger的權重值 [0.0 ~ 10.0]
        l4d_tank_throw_charger "2.0"

        // 石頭變成Spitter的權重值 [0.0 ~ 10.0]
        l4d_tank_throw_spitter "2.0"

        // 石頭變成Jockey的權重值 [0.0 ~ 10.0]
        l4d_tank_throw_jockey "2.0"

        // 石頭變成Tank的權重值 [0.0 ~ 10.0]
        l4d_tank_throw_tank "2.0"

        // Tank把自己扔出去的權重值 [0.0 ~ 10.0]
        l4d_tank_throw_self "10.0"

        // 石頭變成Tank時，設置這隻Tank的血量
        l4d_tank_throw_tank_health "750"

        // 石頭變成Witch的權重值 [0.0 ~ 10.0]
        l4d_tank_throw_witch "2.0"

        // 石頭變成Witch時，設置這隻Witch的血量
        l4d_tank_throw_witch_health "250"

        // 石頭變成Witch時，經過30秒之後自動移除Witch (只會移除由石頭變成的Witch)
        l4d_tank_throw_witch_lifespan "30"

        // 設置Hunter的數量限制 [1 ~ 5] (當場上Hunter的數量達限制時，石頭改扔自己)
        l4d_tank_throw_hunter_limit "2"

        // 設置Smoker的數量限制[1 ~ 5] (當場上Smoker的數量達限制時，石頭改扔自己)
        l4d_tank_throw_smoker_limit "2"

        // 設置Boomer的數量限制[1 ~ 5] (當場上Boomer的數量達限制時，石頭改扔自己)
        l4d_tank_throw_boomer_limit "2"

        // 設置Charger的數量限制[1 ~ 5] (當場上Charger的數量達限制時，石頭改扔自己)
        l4d_tank_throw_charger_limit "2"

        // 設置Spitter的數量限制[1 ~ 5] (當場上Spitter的數量達限制時，石頭改扔自己)
        l4d_tank_throw_spitter_limit "1"

        // 設置Jockey的數量限制[1 ~ 5] (當場上Jockey的數量達限制時，石頭改扔自己)
        l4d_tank_throw_jockey_limit "2"

        // 設置Tank的數量限制[1 ~ 10] (當場上Tank的數量達限制時，石頭改扔自己)
        l4d_tank_throw_tank_limit "3"

        // 設置Witch的數量限制[1 ~ 10] (當場上Witch的數量達限制時，石頭改扔自己)
        l4d_tank_throw_witch_limit "3"
		```
</details>
