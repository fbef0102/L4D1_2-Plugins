# Description | 內容
Provides forward to determine transitioned entities between map

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * 🟥 Only install this plugin when other plugins require this
    * Provide API for other plugins to help detect which entity is from last level when game restore transitioned weapons and items
    * Provides forward to determine transitioned entities between maps
    * The following transitioned entities not work
        * upgrade_ammo_explosive
        * upgrade_ammo_incendiary
        * upgrade_laser_sight
        * prop_physics (propane tank, oxy tank, firework crate, gnome)
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>API | 串接</summary>

    * [l4d_transition_forward.inc](scripting/include/l4d_transition_forward.inc)
        ```php
        library name: l4d_transition_forward
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.0h (2026-1-27)
        * Optimize code
        * Require left4dhooks
        * weapon_* on the ground can be detected

    * Credit
        * [BHaType](https://forums.alliedmods.net/showthread.php?t=334006) - Original Plugin
</details>

- - - -
# 中文說明
輔助插件，可以知道哪些實體是從上一關攜帶過來的

* 原理
    * 🟥 這插件只是一個輔助插件，等其他插件需要的時候再安裝此插件
    * 提供API給其他插件查看哪些武器與物品是上一關攜帶或遺留在安全室的
    * 以下物品，暫時不會檢測，需另尋他法
        * upgrade_ammo_explosive
        * upgrade_ammo_incendiary
        * upgrade_laser_sight
        * prop_physics (瓦斯桶, 氧氣灌, 煙火盒, 精靈小矮人)


