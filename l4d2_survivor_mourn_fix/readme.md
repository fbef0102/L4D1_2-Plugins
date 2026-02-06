# Description | 內容
Fixes the bug where any survivor is unable to mourn a L4D1 survivor on the L4D2 set

* Apply to | 適用於
    ```
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * (Before) 
        1. Usually, when a survivor dies, and if the client is looking at a survivor's dead body, the client should mourn (vocalize).
            * For example, when Louis saw Bill's dead body, Louis should say "Oh no, the old man's dead."
            * But if l4d1 survivor on l4d2 maps or 5+ survivors, the character sometimes won't mourn 
        2. 2019 Last Stand update has made a number of changes, one such change is that when a survivor dies, another fellow survivor will no longer shout their name.
    * (After) 
        1. Any survivors are unable to mourn each other on any map
        2. Allows survivors to say the name of an L4D1 survivor when an L4D1 survivor dies
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [sceneprocessor](https://forums.alliedmods.net/showpost.php?p=2766130&postcount=59)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d2_survivor_mourn_fix.cfg
        ```php
        // If 1, Enable a feature that allows survivors to say the name of an L4D1 survivor when an L4D1 survivor dies. (2019 The last stand update removed this feature)
        l4d2_survivor_mourn_fix_death "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.0h (2026-2-4)
        * Optimize code
        * Remove l4d_stocks required, add left4dhooks
        * Update cvars
        * Remove Ragdoll deaths fix
        * Add cool down between mourning vocalization
        * Fixed wrong entity error, use entity references

    * Credit
        * [DeathChaos25](https://forums.alliedmods.net/showthread.php?t=258870) - Original Plugin
</details>

- - - -
# 中文說明
修復一代倖存者互相看見屍體時沒有語音反應

* 原理
    * (裝此插件之前) 
        1. 通常情況下，當倖存者看見隊友的屍體時，會說出一些語音對話
            * 舉例：Louis看見Bill的屍體會說 "Oh no, the old man's dead."
            * 但是如果在二代地圖上遊玩一代倖存者或是5+多人倖存者，有時候角色不會對屍體有反應
        2. 2019 官方更新時刪除了一項特色: 當一代倖存者死亡時，隊友不再大聲呼喊死去的角色名稱
    * (裝此插件之後) 
        1. 任何倖存者在任何地圖上看見隊友屍體會有反應 (發出語音)
        2. 當一代倖存者死亡時，隊友會大聲呼喊其名稱

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d2_survivor_mourn_fix.cfg
        ```php
        // 為1時，當一代倖存者死亡時，隊友會大聲呼喊其名稱 (2019 官方更新後已去掉這項功能)
        l4d2_survivor_mourn_fix_death "1"
        ```
</details>


