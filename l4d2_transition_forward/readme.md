# Description | 內容
Provides forward to determine player inventory transitioned entities between map

* Apply to | 適用於
    ```
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * 🟥 Only install this plugin when other plugins require this
    * Provide API for other plugins to help detect which entity is from last level when game restore transitioned weapons and items
    * Provides forward to determine player inventory transitioned entities between map
        * Held items also trigger (e.g. weapon_gascan, weapon_gnome etc)
    * This plugin does not detect transitioned weapons and items on the ground
        * If needed, please check "Support | 支援插件"
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>Support | 支援插件</summary>

	1. [l4d_transition_entity](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_transition_entity): Provide events for weapons/spawners/props transition across level change.
		* 輔助插件，可以知道哪些實體是上一關遺留在安全室地上保存的
</details>

* <details><summary>API | 串接</summary>

    * [l4d2_transition_forward.inc](scripting/include/l4d2_transition_forward.inc)
        ```php
        library name: l4d2_transition_forward
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.1h (2026-1-30)
        * L4D2 only
        * Update API

    * v1.0h (2026-1-27)
        * Optimize code
        * Require left4dhooks
        * weapon_* on the ground can be detected

    * Credit
        * [BHaType](https://forums.alliedmods.net/showthread.php?t=334006) - Original Plugin
</details>

- - - -
# 中文說明
輔助插件，可以知道從上一關玩家物品欄攜帶過來的武器實體

* 原理
    * 🟥 這插件只是一個輔助插件，等其他插件需要的時候再安裝此插件
    * 提供API給其他插件查看從上一關玩家物品欄攜帶過來的武器實體
        * 手持物品也會觸發 (如: 汽油、瓦斯桶等)
    * 不會檢測到遺留在安全室地上的武器與物品
        * 如果需要，請查看"Support | 支援插件"


