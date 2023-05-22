# Description | 內容
Fixes the invisible spritetrails entity

* Video | 影片展示
    * [L4D1/2 has bug when env_spritetrail is created and is visible for about 1 second and then disappears. But actually the entity is not removed.](https://www.youtube.com/watch?v=i1zY1tpFMkw)
        > spritetrails物件不會發光但其實物件還是存在的

* Image | 圖示
<br/>None

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0
		* [Original Plugin by 000](https://forums.alliedmods.net/showthread.php?t=339197)
</details>

* Require | 必要安裝
<br/>None

* Related Plugin | 相關插件
	1. [l4d_player_spritetrail](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Fun_%E5%A8%9B%E6%A8%82/l4d_player_spritetrail): l4d player tail effect (use env_spritetrail)
		> 玩家走路，會有尾巴特效 (使用物件: env_spritetrail)

* <details><summary>ConVar | 指令</summary>

	None
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

- - - -
# 中文說明
修復Source引擎的bug，看不見spritetrail物件的發光效果

* 原理
	* [env_spritetrail](https://developer.valvesoftware.com/wiki/Env_spritetrail)物件創造的時候，會發光一下子然後就消失了，但其實物件還是存在，占用伺服器的空間
    * 裝上這個插件之後，會持續讓env_spritetrail有發光效果
	* 不知道什麼是spritetrail也沒關係，等其他插件需要用到這個插件的時候再來安裝

* 功能
	* 無