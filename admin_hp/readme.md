# Description | 內容
Adm type !hp to set survivor team full health

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* Image | 圖示
    <br/>![admin_hp_1](image/admin_hp_1.jpg)

* Require | 必要安裝
    1. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

	None
</details>

* <details><summary>Command | 命令</summary>

	* **Restore all survivors full hp (Adm required: ADMFLAG_ROOT)**
		```php
		sm_hp
		sm_givehp
		```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v2.6 (2023-12-21)
		* Initial Release
</details>

- - - -
# 中文說明
管理員輸入!hp 可以回滿所有倖存者的血量

* 原理
    * 管理員輸入!hp
        * 所有倖存者的血量回復到100hp
        * 倒地的或掛邊的倖存者瞬間站起來並回復到100hp
        * 被抓的倖存者依然被抓

* <details><summary>命令中文介紹 (點我展開)</summary>

	* **回滿所有倖存者的血量 (權限: ADMFLAG_ROOT)**
		```php
		sm_hp
		sm_givehp
		```
</details>

