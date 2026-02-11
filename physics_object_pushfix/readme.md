# Description | 內容
Prevents firework crates, gascans, oxygen, propane tanks being pushed when players walk into them

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Image | 圖示
    <br/>![physics_object_pushfix_1](image/physics_object_pushfix_1.gif)

* <details><summary>How does it work?</summary>

	* To fix the bug where survivor push gascans, oxygen, propane tanks, firework crates by accident
	* How to reproduce the bug?
		* Find a gascan on the map, don't grab, just walk into it
</details>

* Require | 必要安裝
<br/>None

* <details><summary>Changelog | 版本日誌</summary>

	* v1.1h (2026-2-11)
		* Remove pipebomb (use l4d_collision_adjustments instead)

	* v1.0h (2025-1-4)
		* Remake code
		* Add pipebomb
		* Add prop_physics, prop_physics_override, prop_physics_multiplayer

	* Original
		* [By Lux](https://forums.alliedmods.net/showthread.php?t=325263)
</details>

- - - -
# 中文說明
修復玩家走路就能推擠地上物品

* 原理
	* 官方的Bug: 玩家走路就能推擠地上的物品 (汽油桶、瓦斯桶、煙火盒、氧氣罐)
	* 如何復現?
		* 找到地圖上的汽油桶，不要拿取，直接走過去