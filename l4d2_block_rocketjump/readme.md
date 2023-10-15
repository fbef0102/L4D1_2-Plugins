# Description | 內容
Block rocket jump exploit with grenade launcher/vomitjar/pipebomb/molotov/common/spit/rock/witch

* Video | 影片展示
    * [Grenade launcher Exploit](https://www.youtube.com/watch?v=eAKt6NZXqJM)
        > 踩在榴彈發射器發射的榴彈上高空跳躍bug示範
    * [Survivor tricks](https://youtu.be/AEWIe3YRq7Y?t=369)
        > 人類能使用這技巧略過地圖機關
    * [Witch - お前はもう死んでいる](https://www.youtube.com/shorts/Chy2v7Ns9oY)
        > 踩在Witch頭上瞬間死亡bug示範

* Image | 圖示
	* Classic Source Engine Bug (經典的Source引擎Bug)
	<br/>![l4d2_block_rocketjump_1](image/l4d2_block_rocketjump_1.gif)

* Require | 必要安裝
<br/>None

* Related Plugin | 相關插件
	1. [l4d2_steady_boost by jensewe](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d2_steady_boost): Prevent forced sliding when landing at head of enemies.
		> 人類踩在特感頭上或特感踩在人類頭上不會滑落飄移

* <details><summary>ConVar | 指令</summary>

	None
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.4
		* Optimize code and improve performance
		* molotov
		* pipebomb
		* vomitjar
		* grenade launcher
		* spitter projectile
		* tank rock
		* common infected
		* witch

	* v1.1
		* [Original Plugin by DJ_WEST](https://forums.alliedmods.net/showthread.php?t=122371)
</details>

- - - -
# 中文說明
修復Source引擎的踩頭跳躍bug

* 原理
	* 嘗試修復經典的Source引擎bug，當玩家踩在其他的物件上有機率會造成各種bug，譬如
        * 當玩家踩在殭屍頭上，有一定機率飛到空中墬樓死亡
        * 當玩家踩在Witch頭上，有一定機率直接死亡
        * 踩在榴彈發射器發射的榴彈上高空跳躍
        * 踩在Spitter吐出的酸液物上高空跳躍
        * 踩在隊友扔出去的燃燒瓶、土製炸彈、膽汁瓶上高空跳躍
    * Tickrate越高的伺服器越容易發生

* 功能
	* 無