# Description | 內容
Maximum of each L4D1 weapons the survivors can pick up

* Apply to | 適用於
    ```
    L4D1
    ```

* <details><summary>How does it work?</summary>

	* Maximum of each L4D1 weapons the survivors can pick up
        * If "Auto Shotgun" limit reached, give pump shotgun. If pump shotgun limit reached, give ammo only
        * If "Rifle" limit reached, give smg. If pump smg limit reached, give ammo only
        * If "Hunting Rifle" limit reached, give ammo only
</Chargedetails>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>Other Version | 其他版本</summary>

    1. [l4d_weapon_limits](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Weapons_武器/l4d_weapon_limits_remake): (L4D2) Restrict weapons and melees individually or together
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

* <details><summary>Changelog | 版本日誌</summary>

    * v1.1 (2026-10-24)
        * Bots won't try to pickup if limit reached
        * Require left4dhooks

    * v1.0 (2023-6-30)
        * Initial Release
</details>

- - - -
# 中文說明
限制L4D1遊戲中每個武器可以拿取的數量，超過就不能拿取

* 原理
    * 當要撿起武器時，計算隊友之中已經拿取的數量，超過便不能撿起武器
    * 適用真人玩家與Bot

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d1_weapon_limits.cfg
        ```php
        // 連發散彈槍數量限制 [-1: 無限制]
        l4d1_weapon_limitsautoshotgun "1"

        // 獵槍散彈槍數量限制 [-1: 無限制]
        l4d1_weapon_limitshuntingrifle "1"

        // 木製散彈槍數量限制 [-1: 無限制]
        l4d1_weapon_limitspumpshotgun "4"

        // 步槍數量限制 [-1: 無限制]
        l4d1_weapon_limitsrifle "1"

        // SMG數量限制 [-1: 無限制]
        l4d1_weapon_limitssmg "3"
        ```
</details>