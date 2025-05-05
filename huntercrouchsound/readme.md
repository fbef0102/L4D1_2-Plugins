# Description | 內容
Forces silent but crouched hunters to emitt sounds

* Video | 影片展示
    * [Stay silent while Crouched](https://youtu.be/L7x_x6dc1-Y?si=vA2dkxBxwxfz9vT4&t=48)
        > Hunter利用地形強制蹲下，但不會發出任何聲音

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.6 (2025-5-5)
		* Support L4D1

	* v1.5 (2023-7-27)
		* Fix warnings when compiling on SourceMod 1.11.

	* v1.4
		* Initial Release
</details>

* Require | 必要安裝
<br/>None

* <details><summary>Related Plugin | 相關插件</summary>

	1. [hunter_growl_sound_fix](/hunter_growl_sound_fix): Fix silence Hunter produces growl sound when player MIC on
		> 修復使用Mic的Hunter玩家會發出聲音
</details>

- - - -
# 中文說明
強制蹲下安靜的Hunter發出聲音

* 原理
    * (安裝此插件之前) Hunter玩家在地圖某些地形會強制蹲下，玩家不需要按住蹲下鍵
      * 譬如通風管、較低的天花板
      * 這時候的Hunter不會發出任何聲音，且可以隨時撲人
	* (安裝此插件之後) Hunter只要是蹲下狀態，強迫發生低吼聲
