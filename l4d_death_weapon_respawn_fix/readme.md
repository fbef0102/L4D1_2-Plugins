# Description | 內容
In coop/realism, if you died with primary weapon, you will respawn with T1 weapon. Delete datas if hold M60 or mission lost

* [Video | 影片展示](https://youtu.be/AbfjBeQmpd8)

* Apply to | 適用於
    ```
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * Newly-rescued Survivors start with 50 permanent health, a random tier 1 weapon, and a single P220 Pistol. 
    * Their primary tier 1 weapon is determined by what weapons you had when you died:
        1. If you died with an assault rifle (Combat Rifle, AK-47, or M16 Assault Rifle) or a submachine gun (normal or silenced), you will respawn with a submachine gun (with a chance for a Silenced Submachine Gun instead in Left 4 Dead 2);
        2. If you died with a shotgun (Chrome, Pump, Auto or Combat) or Grenade Launcher, you are given a Pump Shotgun (with a chance for a Chrome Shotgun instead in Left 4 Dead 2);
        3. If you died with a Hunting or Sniper Rifle, you will have a 60% chance of getting a submachine gun and a 40% chance of a shotgun.
    * This plugin tries to fix the following situations
        1. If you died with M60, you will respawn with M60 full clip (This is bug)
        2. If you died with any weapons and mission lost in coop/realism, you will have T1 weapons after new round starts (Usually happen after changelevel map 2...)
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.1 (2023-1-12)
	    * Fixed player respawns with only pistol

    * v1.0 (2022-12-12)
        * Initial Release
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] l4d2_weapons](https://github.com/fbef0102/Game-Private_Plugin/blob/main/L4D_插件/Require_檔案/scripting/include/l4d2_weapons.inc)

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\l4d_death_weapon_respawn_fix
		```php
        // 0=Plugin off, 1=Plugin on.
        l4d_death_weapon_respawn_fix_enable "1"
		```
</details>

* <details><summary>Related Official ConVar</summary>

	* write down the follong cvars in cfg/server.cfg
		```php
        // Newly-rescued Survivors start with weapons 0: Just a pistol, 1: Downgrade of last primary weapon, 2: Last primary weapon.
        sm_cvar survivor_respawn_with_guns 1
		```
</details>

- - - -
# 中文說明
修復在戰役/寫實模式中重新復活或救援房間救活的時候，武器不一樣

* 原理
    * 在救援房間被救援時，倖存者有50實血、T1武器(單發散彈槍或者機槍) 和一把手槍
    * T1武器取決於上次你死亡時持有什麼武器
    * 這個插件會解決以下問題
        1. 死亡時有M60重型機槍，被救援時會有滿發子彈夾的M60 (這是官方的bug)
        2. 死亡時擁有主武器，倖存者滅團後重新回合會發現你的武器變成了單發散彈槍或者機槍 (這也是官方的bug)
    * 安裝這個插件不會影響過關攜帶的武器

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg\sourcemod\l4d_death_weapon_respawn_fix
		```php
        // 0=關閉插件, 1=啟動插件
        l4d_death_weapon_respawn_fix_enable "1"
		```
</details>

* <details><summary>相關的官方指令中文介紹 (點我展開)</summary>

	* 以下指令寫入文件 cfg/server.cfg，可自行調整
		```php
        // 在救援房間被救援時的起始武器 0: 手槍, 1: 上次死亡時主武器降成T1武器 (單發散彈槍或者機槍), 2: 上次死亡時主武器.
        sm_cvar survivor_respawn_with_guns 1
		```
</details>
