# Description | 內容
Allow refuelling of a chainsaw

* Apply to | 適用於
    ```
    L4D2
    ```

* Image | 圖示
    <br/>![l4d2_chainsaw_refuelling_1](image/l4d2_chainsaw_refuelling_1.gif)
    <br/>![l4d2_chainsaw_refuelling_2](image/l4d2_chainsaw_refuelling_2.gif)

* <details><summary>How does it work?</summary>

    * The plugin allow refuelling of a chainsaw with gascans (not scavenge gascans).
    * You can refuel a chainsaws: Aim for it and press Right Mouse or E while carrying a gascan
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d2_chainsaw_refuelling.cfg
        ```php
        // Chainsaw Refuelling plugin status (0 - Disable, 1 - Enable)
        l4d2_chainsaw_refuelling_enable "1"

        // If 1, Remove a chainsaw if it empty
        l4d2_chainsaw_refuelling_remove "0"

        // Allow refuelling of a chainsaw (0 - On the ground, 1 - On players, 2 - Both)
        l4d2_chainsaw_refuelling_mode "2"

        // If 1, Enable dropping a chainsaw with Reload button
        l4d2_chainsaw_refuelling_drop "1"

        // If 1, Enable hint message
        l4d2_chainsaw_refuelling_hint "1"
        ```
</details>

* Translation Support | 支援翻譯
	```
	translations/chainsaw_refuelling.phrases.txt
	```

* <details><summary>Changelog | 版本日誌</summary>

    * v1.1h (2024-12-9)
        * Remake code again

    * v1.0h (2024-4-27)
        * Require lef4dhooks v1.33 or above
        * Remake code, convert code to latest syntax
        * Fix warnings when compiling on SourceMod 1.11.
        * Optimize code and improve performance
        * Require left4dhooks

    * v1.6.3
        * Fix error
        * Chinese translation

    * v1.6.1
        * Lossy (Round Start Fix), Shao (downstate support)

    * v1.6
        * [Original Post by DJ_WEST](https://forums.alliedmods.net/showthread.php?t=121983)
</details>

- - - -
# 中文說明
可以使用汽油桶重新填充電鋸油量

* 原理
    * 按下R鍵將電鋸丟在地上 -> 拿著紅色的汽油桶對準電鋸按下左鍵 -> 填充油量
    * 黃色與綠色的汽油桶不適用

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d2_chainsaw_refuelling.cfg
        ```php
        // 啟用插件 [0-關閉,1-開啟]
        l4d2_chainsaw_refuelling_enable "1"

        // 為1時，如果電鋸沒油了，會消失(0=不消失)
        l4d2_chainsaw_refuelling_remove "0"

        // 允許電鋸如何加油 (0=在地上, 1=在倖存者身上, 2=兩者皆可)
        l4d2_chainsaw_refuelling_mode "2"

        // 為1時，按下Ｒ鍵可以丟下電鋸 (0=關閉)
        l4d2_chainsaw_refuelling_drop "1"

        // 為1時，顯示電鋸的提示訊息 (0=關閉)
        l4d2_chainsaw_refuelling_hint "1"
        ```
</details>