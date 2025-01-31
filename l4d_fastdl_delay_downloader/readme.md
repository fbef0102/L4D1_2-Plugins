# Description | 內容
Downloading fastdl custom files only when map change/transition

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>How does it work?</summary>

	* 🟥 Use this plugin only when you have [fastdl set](https://developer.valvesoftware.com/wiki/FastDL)
	* (Before) Downloading custom files when player connecting to server
	* (After) Only downloading custom files when map change/transition
</details>

* Require | 必要安裝
	1. [[INC] stringtables_data](https://forums.alliedmods.net/showthread.php?t=319828)

* <details><summary>ConVar | 指令</summary>

    None
</details>

* <details><summary>Command | 命令</summary>

    * **Get all exclude list from data/l4d_fastdl_delay_downloader.cfg (Adm required: ADMFLAG_ROOT)**
        ```php
        sm_get_exclude_items
        ```

    * **Restore downloadables stringtable items (Adm required: ADMFLAG_ROOT)**
        ```php
        sm_restore_st
        ```
</details>

* <details><summary>Data Config</summary>
  
	* [data/l4d_fastdl_delay_downloader.cfg](data/l4d_fastdl_delay_downloader.cfg)
		> Manual in this file, click for more details...
</details>

* <details><summary>Related | 相關插件</summary>

	1. [sm_downloader](/sm_downloader): SM File/Folder Downloader and Precacher
    	* SM 文件下載器 (玩家連線伺服器的時候能下載自製的檔案)
	2. [l4d_MusicMapStart](/l4d_MusicMapStart): Download and play custom musics
		* 下載自製音樂
	3. [map-decals](https://github.com/fbef0102/Sourcemod-Plugins/tree/main/map-decals): Download custom decals
		* 下載自製的噴漆貼圖
	4. [fortnite_dances_emotes_l4d](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_%E6%8F%92%E4%BB%B6/Fun_%E5%A8%9B%E6%A8%82/fortnite_dances_emotes_l4d): Download dance models
		* 下載跳舞模組
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2024-12-31)
		* Remake code
        * Custom File downloading only when map change/transition
        * Fix warnings when compiling on SourceMod 1.11.
        * Optimize code and improve performance
		* Apply to all modes

	* Original
		* [By BHaType, Dragokas](https://forums.alliedmods.net/showthread.php?t=318739)
</details>

- - - -
# 中文說明
只有在換圖或過關時，才讓玩家下載Fastdl自製的檔案

* 原理
	* 🟥 有使用自己準備的[網空支援Fastdl](https://developer.valvesoftware.com/wiki/Zh/FastDL)，才需要安裝此插件
	* [什麼是自訂伺服器內容?](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/Chinese_%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87/Game#%E4%B8%8B%E8%BC%89%E8%87%AA%E8%A8%82%E4%BC%BA%E6%9C%8D%E5%99%A8%E5%85%A7%E5%AE%B9)
	* (安裝此插件之前) 玩家連線到伺服器必須下載所有伺服器的自製檔案
		* 下載過程漫長且玩家螢幕會黑屏
		* 玩家通常沒有耐心等待，而且看到螢幕黑屏以為遊戲卡住，導致大部分玩家直接離開，反覆循環
	* (安裝此插件之後) 換圖/過關時才會下載伺服器的自製檔案
		* 玩家感受不會那麼差

* <details><summary>命令中文介紹 (點我展開)</summary>

    * **從文件 data/l4d_fastdl_delay_downloader.cfg 內取得不受影響的檔案列表 (權限: ADMFLAG_ROOT)**
        ```php
        sm_get_exclude_items
        ```

    * **回復所有下載列表，玩家連線時要下載自製檔案 (權限: ADMFLAG_ROOT)**
        ```php
        sm_restore_st
        ```
</details>

* <details><summary>文件設定範例</summary>
  
	* [data/l4d_fastdl_delay_downloader.cfg](data/l4d_fastdl_delay_downloader.cfg)
		> 內有中文說明，可點擊查看
</details>