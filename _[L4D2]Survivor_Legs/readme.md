https://forums.alliedmods.net/showthread.php?t=299560

# Description | 內容
Add's Left 4 Dead 1 Style ViewModel Legs

* Apply to | 適用於
	```
	L4D2
	```

* <details><summary>How does it work?</summary>

	* You can see your own legs on first person view
	* Support custom character mods
</details>

* Require | 必要安裝
    1. [ThirdPersonShoulder_Detect](https://forums.alliedmods.net/showthread.php?t=298649)
    2. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>Support | 支援插件</summary>

	1. [Luxs-Model-Changer](/Luxs-Model-Changer): LMC Allows you to use most models with most characters
    	* 可以自由變成其他角色或NPC的模組
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/_[L4D2]Survivor_Legs.cfg
		```php
		// (If you install LMC plugins)
		// Copy LMC model to legs model, creates an extra entity for legs, will update on state change for legs
		lmc_integration "1"
		```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2025-8-18)
		* Optimize code
		* Use left4dhooks to detect if survivor is on third person mode (more accurate)

	* Original & Credit
		* [Lux](https://forums.alliedmods.net/showthread.php?t=299560)
</details>

- - - -
# 中文說明
第一人稱可以看到自己的雙腳

* 原理
	* 人類在第一人稱下可以看到自己雙腳
	* 支援玩家訂閱工作仿的角色模組

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/_[L4D2]Survivor_Legs.cfg
		```php
		// (有裝 LMC 插件才需要修改此指令)
		// 為1時，使用LMC模型的腿，並且即時更新
		lmc_integration "1"
		```
</details>