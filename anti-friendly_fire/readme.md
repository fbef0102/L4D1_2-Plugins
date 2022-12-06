# Description | 內容
shoot your teammate = shoot yourself

* Video | 影片展示
<br/>None

* Image | 圖示
	* Reflect friendly fire damage
        > 反彈友傷
        <br/>![anti-friendly_fire_1](image/anti-friendly_fire_1.gif)

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.5 (2022-12-6)
	    * Disable Pipe Bomb Explosive friendly fire
	    * Disable Fire friendly fire.
	    * Friendly fire now will not incap player
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* Similar Plugin | 相似插件
	1. [l4dffannounce](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dffannounce): Adds Friendly Fire Announcements (who kills teammates)
		> 顯示誰他馬TK我

	2. [l4d_friendly_fire_stats](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Survivor_%E4%BA%BA%E9%A1%9E/l4d_friendly_fire_stats): Display all friendly fire dealt and received
		> 顯示造成與受到的友傷以及兇手，有友傷統計

	3. [anti-friendly_fire_V2](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Anti_Griefer_%E9%98%B2%E6%83%A1%E6%84%8F%E8%B7%AF%E4%BA%BA/anti-friendly_fire_V2): shoot teammate = shoot yourself V2
		> 隊友開槍射你會反彈傷害，第二版本
		
	4. [anti-friendly_fire_RPG](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Anti_Griefer_%E9%98%B2%E6%83%A1%E6%84%8F%E8%B7%AF%E4%BA%BA/anti-friendly_fire_RPG): shoot teammate = shoot yourself RPG
		> 隊友開槍射你會反彈傷害，RPG版本

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/anti-friendly_fire.cfg
        ```php
        // Multiply friendly fire damage value and reflect to attacker. (1.0=original damage value)
        anti_friendly_fire_damage_multi "1.5"

        // Disable friendly fire damage if damage is below this value (0=Off).
        anti_friendly_fire_damage_sheild "0"

        // Enable anti-friendly_fire plugin [0-Disable,1-Enable]
        anti_friendly_fire_enable "1"

        // If 1, Disable Pipe Bomb, Propane Tank, and Oxygen Tank Explosive friendly fire.
        anti_friendly_fire_immue_explode "0"

        // If 1, Disable Fire friendly fire.
        anti_friendly_fire_immue_fire "1"

        // If 1, Disable friendly fire if damage is about to incapacitate victim.
        anti_friendly_fire_incap_protect "1"
        ```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

- - - -
# 中文說明
隊友黑槍會反彈友傷

* 原理
	* 隊友開槍打你，你不會受傷，是開槍者會受到傷害

* 功能
	* 可設置火焰不造成友傷
	* 可設置土製炸彈、瓦斯罐、氧氣罐不造成友傷
	* 可設置友傷數值加倍反彈

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/anti-friendly_fire.cfg
        ```php
        // 友傷 x 數值，然後再反彈 (1.0 = 反彈一樣的傷害)
        anti_friendly_fire_damage_multi "1.5"

        // 友傷低於此數值時，不造成友傷 (0=關閉).
        anti_friendly_fire_damage_sheild "0"

        // 啟用 anti-friendly_fire 插件 [0-關閉,1-開啟]
        anti_friendly_fire_enable "1"

        // 為 1, 土製炸彈、瓦斯罐、氧氣罐不造成友傷
        anti_friendly_fire_immue_explode "0"

        // 為 1, 火焰不造成友傷
        anti_friendly_fire_immue_fire "1"

        // 為 1, 如果友傷會造成對方倒地，不造成友傷
        anti_friendly_fire_incap_protect "1"
        ```
</details>


