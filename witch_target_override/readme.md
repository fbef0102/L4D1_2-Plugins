# Description | 內容
Change target when the witch incapacitates or kills victim + witchs auto follow survivors

> __Note__ <br/>
This plugin is private, Please contact [me](https://github.com/fbef0102/Game-Private_Plugin#私人插件列表-private-plugins-list)<br/>
此為私人插件, 請聯繫[本人](https://github.com/fbef0102/Game-Private_Plugin#私人插件列表-private-plugins-list)

* [Video | 影片展示](https://youtu.be/SapXAIOsNJI)

* Image | 圖示
	* Fear of Witch 
	> 再度恐懼Witch
	<br/>![witch_target_override_1](image/witch_target_override_1.jpg)
	* Auto follows survivor
	> 自動跟蹤倖存者
	<br/>![witch_target_override_2](image/witch_target_override_2.jpg)

* Apply to | 適用於
```
L4D1
L4D2
```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.8 (2022-11-14)
		* [AlliedModders Post](https://forums.alliedmods.net/showpost.php?p=2732048&postcount=9)
        * Witch is allowed to chase another target after she incapacitates a survivor. 
        * Witch is allowed to chase another target after she kills a survivor. 
        * Witch will not follow survivor if there is a wall between witch and survivor.
        * Witch will not follow survivor if survivor standing on the higher place.
        * Witch burns for a set amount of time and die. (z_witch_burn_time 15 seconds = default)
        * Support L4D1

	* v1.0
        * Initial Release
        * Thanks to BHaType, xZk, cravenge and silvers
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/witch_target_override.cfg
	```php
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
	```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

- - - -
# 中文說明
Witch會自動跟蹤你，一旦驚嚇到她，不殺死任何人絕不罷休

* 原理
	* 出現在Witch看得到的視野之內，她將會自動走向你
	* 嚇到Witch之後，將目標玩家倒地或殺死之後，自動把目標轉向剩餘的倖存者繼續發難

* 功能
	1. 詳見下方"指令中文介紹"

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/witch_target_override.cfg
    ```php
    // Witch會跟蹤倖存者的機率
    witch_target_override_chance_followsurvivor "100"

    // 倖存者距離Witch的一定可見範圍內，Witch會跟蹤倖存者 [100.0, 9999.0] 
    witch_target_override_followsurvivor_range "500.0"

    // Witch的跟蹤速度
    witch_target_override_followsurvivor_speed "45.0"

    // 如設置數值為1，目標玩家倒地之後繼續追殺其他倖存者
    witch_target_override_incap "1"

    // 如果Witch在目標玩家倒地之後繼續追殺其他倖存者，增加數值血量. (0=關閉)
    witch_target_override_incap_health_add "100"

    // 如設置數值為1，目標玩家死亡之後繼續追殺其他倖存者
    witch_target_override_kill "1"

    // 如果Witch在目標玩家死亡之後繼續追殺其他倖存者，增加數值血量. (0=關閉)
    witch_target_override_kill_health_add "400"

    // 1=開啟插件. 0=關閉插件
    witch_target_override_on "1"

    // Witch準備追殺的另外一名倖存者並須在這個範圍之內 [1.0, 9999.0] (如果範圍內沒有倖存者, 那Witch繼續遊戲預設行為)
    witch_target_override_range "9999"

    // 如設置數值為1，當Witch身上著火並且準備轉移目標之時，重新計算Witch燒傷的時間 (0=官方預設模式下Witch會在著火固定時間後死亡)
    witch_target_override_recalculate_burn_time "0"
    ```
</details>