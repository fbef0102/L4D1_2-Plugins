# Description | 內容
Once everyone has used the same ammo pile at least once, it is removed.

> __Note__ 
<br/>This Plugin has been discontinued, Use [Percentage Limited Ammo Pile](https://forums.alliedmods.net/showthread.php?t=340484)

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_limited_ammo_pile.cfg
		```php
        // If 1, Play sound when ammo already used.
        l4d_limited_ammo_pile_denied_sound "1"

        // If 1, Each player has only one chance to pick up ammo from each ammo pile. (0=No limit until ammo pile removed)
        l4d_limited_ammo_pile_one_time "1"

        // Changes how message displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
        l4d_limited_ammo_pile_announce_type "2"
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
	Russian
	```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

	1. [Percentage Limited Ammo Pile by NoroHime](https://forums.alliedmods.net/showthread.php?t=340484): ammo pile has shared limited ammo, dont waste any bullet
        * 子彈堆有數量限制且是共享的，拿完就沒了
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * Archived (2024-10-30)
        * This Plugin has been discontinued
		* 停止更新

	* v1.4
		* Remake Code
		* Add more convars
		* Translation Support
		* Deny Sound
		* Provide a better method to check if player does fill a weapon fully from ammo pile
		* Compatible with [M60_GrenadeLauncher_patches](https://forums.alliedmods.net/showthread.php?t=323408)

	* v2.1
		* [Original Plugin by Thraka](http://forums.alliedmods.net/showthread.php?t=115898)
</details>

- - - -
# 中文說明
子彈堆只能拿一次子彈，當每個人都拿過一遍之後移除子彈堆

> __Note__ 
<br/>此插件已停止更新，請使用[Percentage Limited Ammo Pile](https://forums.alliedmods.net/showthread.php?t=340484)

* 原理
	* 子彈堆拿一次之後就不能再拿了
	* 每個人都拿過一遍之後，子彈堆自動移除

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_limited_ammo_pile.cfg
		```php
        // 為1時，子彈堆不能拿取有提示音效
        l4d_limited_ammo_pile_denied_sound "1"

        // 為1時，子彈堆只能拿一次 (0=無限制)
        l4d_limited_ammo_pile_one_time "1"

        // 提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 螢幕正中間)
        l4d_limited_ammo_pile_announce_type "2"
		```
</details>



