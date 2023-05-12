# Description | 內容
Fixed the final stage get stucked

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2023-5-12)
        * Add more check after final starts.
        * The plugin will force ForceNextStage if final stage stucks after 60 seconds.
        * Adm can type !nextstage if nothing happened.

	* v1.5
        * [Original Plugin by Dragokas](https://forums.alliedmods.net/showthread.php?t=334759)
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_finale_stage_fix.cfg
        ```php
        // Timeout (in sec.) for finale panic stage waiting for tank/painc horde to appear, otherwise stage forcibly changed
        l4d_finale_stage_fix_panicstage_timeout "60"
        ```
</details>

* <details><summary>Command | 命令</summary>

	* **Forcibly call the next stage.**
		```php
		sm_nextstage
		```

	* **Prints current stage index and time passed. (ADMFLAG_ROOT)**
		```php
		sm_stage
		```
</details>

* Q&A
  * <details><summary><b>When do I need this plugin?</b></summary>

    * Sometimes tanks are not appearing on finale map, because "Panic" stage get stucked. 
        * Usuall happen in custom maps. 
        * The rescue vehicle nerver coming.
    * This plugin allows to set timeout (see ConVar) for Panic stage waiting the tank to appear. If that doesn't happen, plugin forcibly call the next stage and director automatically spawns the tank as it normally should.
  </details>

  * <details><summary><b>What could the reason that final stage stuck?</b></summary>
    
    * [Dragokas's explanation](https://forums.alliedmods.net/showpost.php?p=2795565&postcount=23)
  </details>

  * <details><summary><b>What else can Adm do?</b></summary>
    
    * Adm can type ```!nextstage``` if nothing happened in final stage.
  </details>

- - - -
# 中文說明
解決最後救援卡關，永遠不能來救援載具的問題

* 原理
	* 最後救援階段過程中如果超過60秒時沒有特感、小殭屍、Tank生成時，就會視為卡關
    * 卡關之後，插件會強制下一個救援階段，救援載具直接來臨讓倖存者上去

* 功能
    * 可設置卡關等待時間

* Q&A
  * <details><summary><b>何時安裝這個插件?</b></summary>

    * 如果你經常遇到救援關卡
        * 很久的時候沒有特感、小殭屍、Tank生成卡關
        * 救援載具很久不出現卡關
  </details>

  * <details><summary><b>為什麼會卡關?</b></summary>
    
    * [請看Dragokas的解釋](https://forums.alliedmods.net/showpost.php?p=2795565&postcount=23)
    * 經常發生於三方圖，伺服器的控制台頻繁出現"5 attempts to found spawn position faile"字樣，特感、小殭屍、Tank找不到位置生成，導致救援無法進行下一個階段
        * 有可能是安裝太多插件造成
        * 有可能是地圖爛，去怪地圖作者
  </details>

  * <details><summary><b>管理員能做什麼?</b></summary>
    
    * 管理員可以於聊天框輸入 ```!nextstage``` 強制跳到下一個救援階段 (救援開始之後才能使用)
  </details>
