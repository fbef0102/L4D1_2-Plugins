# Description | 內容
Fixes shooting/bullet displacement by 1 tick problems so you can accurately hit by moving.

* Video | 影片展示
    1. [Huge CS:GO hitreg bug](https://www.youtube.com/watch?v=VPT0-CKODNc)
    2. [One bug from all valve games](https://www.youtube.com/watch?v=pr4EZ06mrpQ)

* Image | 圖示
<br/>None

* Require | 必要安裝
<br/>None

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

    * v1.0h (2024-3-7)
        * Fixed physics objects are broken therefore tank hittables are flying totally random in l4d1/2

	* v1.0
		* [Original Plugin by Xutax_Kamay](https://forums.alliedmods.net/showthread.php?t=315405)
</details>

- - - -
# 中文說明
修復子彈擊中與伺服器運算相差 1 tick的延遲

* 原理
    * 請看上方 "影片展示"
    * 這是所有source引擎的遊戲都會有的bug (去你馬Valve)
    * 1 tick ≈ 0.033秒 (視伺服器tickrate決定)
    * L4D2貌似從2019 the last stand 更新之後有修復這個bug，但我沒感覺，如果官方真的已修復請通知