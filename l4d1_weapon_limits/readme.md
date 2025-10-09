# Description | 內容
Maximum of each L4D1 weapons the survivors can pick up

* Apply to | 適用於
    ```
    L4D1
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0 (2023-6-30)
        * Initial Release
</details>

* Require | 必要安裝
	1. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>Other Version | 其他版本</summary>

    1. [l4d_weapon_limits](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Weapons_%E6%AD%A6%E5%99%A8/l4d_weapon_limits): (L4D2) Restrict weapons and melees individually or together
        * (L4D2) 限制每個武器與近戰可以拿取的數量，超過就不能拿取
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d1_weapon_limits.cfg
		```php
        // Maximum of autoshotguns the survivors can pick up. [-1:No limit]
        l4d1_weapon_limitsautoshotgun "1"

        // Maximum of hunting rifles the survivors can pick up. [-1:No limit]
        l4d1_weapon_limitshuntingrifle "1"

        // Maximum of pumpshotguns the survivors can pick up. [-1:No limit]
        l4d1_weapon_limitspumpshotgun "4"

        // Maximum of rifles the survivors can pick up. [-1:No limit]
        l4d1_weapon_limitsrifle "1"

        // Maximum of smgs the survivors can pick up. [-1:No limit]
        l4d1_weapon_limitssmg "3"
		```
</details>

- - - -
# 中文說明
限制L4D1遊戲中每個武器可以拿取的數量，超過就不能拿取

* 原理
    * 當要撿起武器時，計算隊友之中已經拿取的數量，超過便不能撿起武器
    * 適用真人玩家與Bot

* 功能
    * L4D1遊戲的主武器只有五把，因此用指令去控制每一把武器的限制，也可以不設置