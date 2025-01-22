# Description | 內容
Modify every weapon damage done to Tank, SI, Witch, Common in l4d2

* Apply to | 適用於
	```
	L4D2
	```

* <details><summary>How does it work?</summary>

	* Modify weapon damages dealt to Commons/S.I./Tank/Witch
        * Pistol
        * Magnum Pistol
        * Pump Shotgun
        * Shotgun Chrome
        * Smg
        * Silenced Smg
        * Autoshotgun
        * Spas Shotgun
        * Hunting Rifle
        * Sniper Military
        * Rifle
        * Desert Rifle
        * Ak47
        * Grenade Launcher
        * M60 Rifle
        * CSS Mp5
        * SG552 Rifle
        * CSS Scout
        * CSS AWP
    * To modify melee weapons' damage, please check "Related Plugin" below
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d2_gun_damage_modify.cfg
		```php
        // Enable gun damage modify plugin. [0-Disable,1-Enable]
        l4d_gun_damage_modify_enable "1"

        // Modfiy ak47 Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_ak47_damage_SI_multi "1.0"

        // Modfiy ak47 Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_ak47_damage_common_multi "1.0"

        // Modfiy ak47 Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_ak47_damage_tank_multi "1.0"

        // Modfiy ak47 Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_ak47_damage_witch_multi "1.0"

        // Modfiy auto shotgun Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_autoshotgun_damage_SI_multi "1.0"

        // Modfiy auto shotgun Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_autoshotgun_damage_common_multi "1.0"

        // Modfiy auto shotgun Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_autoshotgun_damage_tank_multi "1.0"

        // Modfiy auto shotgun Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_autoshotgun_damage_witch_multi "1.0"

        // Modfiy awp Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_awp_damage_SI_multi "1.0"

        // Modfiy awp Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_awp_damage_common_multi "1.0"

        // Modfiy awp Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_awp_damage_tank_multi "1.0"

        // Modfiy awp Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_awp_damage_witch_multi "1.0"

        // Modfiy chrome shotgun Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_chromeshotgun_damage_SI_multi "1.0"

        // Modfiy chrome shotgun Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_chromeshotgun_damage_common_multi "1.0"

        // Modfiy chrome shotgun Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_chromeshotgun_damage_tank_multi "1.0"

        // Modfiy chrome shotgun Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_chromeshotgun_damage_witch_multi "1.0"

        // Modfiy grenade launcher Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_grenadelauncher_damage_SI_multi "1.0"

        // Modfiy grenade launcher Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_grenadelauncher_damage_common_multi "1.0"

        // Modfiy grenade launcher Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_grenadelauncher_damage_tank_multi "1.0"

        // Modfiy grenade launcher Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_grenadelauncher_damage_witch_multi "1.0"

        // Modfiy hunting rifle Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_huntingrifle_damage_SI_multi "1.0"

        // Modfiy hunting rifle Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_huntingrifle_damage_common_multi "1.0"

        // Modfiy hunting rifle Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_huntingrifle_damage_tank_multi "1.0"

        // Modfiy hunting rifle Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_huntingrifle_damage_witch_multi "1.0"

        // Modfiy m60 Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_m60_damage_SI_multi "1.0"

        // Modfiy m60 Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_m60_damage_common_multi "1.0"

        // Modfiy m60 Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_m60_damage_tank_multi "1.0"

        // Modfiy m60 Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_m60_damage_witch_multi "1.0"

        // Modfiy magnum Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_magnum_damage_SI_multi "1.0"

        // Modfiy magnum Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_magnum_damage_common_multi "1.0"

        // Modfiy magnum Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_magnum_damage_tank_multi "1.0"

        // Modfiy magnum Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_magnum_damage_witch_multi "1.0"

        // Modfiy military sniper Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_militarysniper_damage_SI_multi "1.0"

        // Modfiy military sniper Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_militarysniper_damage_common_multi "1.0"

        // Modfiy military sniper Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_militarysniper_damage_tank_multi "1.0"

        // Modfiy military sniper Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_militarysniper_damage_witch_multi "1.0"

        // Modfiy mp5 Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_mp5_damage_SI_multi "1.0"

        // Modfiy mp5 Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_mp5_damage_common_multi "1.0"

        // Modfiy mp5 Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_mp5_damage_tank_multi "1.0"

        // Modfiy mp5 Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_mp5_damage_witch_multi "1.0"

        // Modfiy pistol Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_pistol_damage_SI_multi "1.0"

        // Modfiy pistol Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_pistol_damage_common_multi "1.0"

        // Modfiy pistol Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_pistol_damage_tank_multi "1.0"

        // Modfiy pistol Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_pistol_damage_witch_multi "1.0"

        // Modfiy pumpshotgun Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_pumpshotgun_damage_SI_multi "1.0"

        // Modfiy pumpshotgun Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_pumpshotgun_damage_common_multi "1.0"

        // Modfiy pumpshotgun Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_pumpshotgun_damage_tank_multi "1.0"

        // Modfiy pumpshotgun Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_pumpshotgun_damage_witch_multi "1.0"

        // Modfiy rifle Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_rifle_damage_SI_multi "1.0"

        // Modfiy rifle Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_rifle_damage_common_multi "1.0"

        // Modfiy rifle Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_rifle_damage_tank_multi "1.0"

        // Modfiy rifle Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_rifle_damage_witch_multi "1.0"

        // Modfiy rifle desert Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_rifledesert_damage_SI_multi "1.0"

        // Modfiy rifle desert Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_rifledesert_damage_common_multi "1.0"

        // Modfiy rifle desert Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_rifledesert_damage_tank_multi "1.0"

        // Modfiy rifle desert Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_rifledesert_damage_witch_multi "1.0"

        // Modfiy scout Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_scout_damage_SI_multi "1.0"

        // Modfiy scout Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_scout_damage_common_multi "1.0"

        // Modfiy scout Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_scout_damage_tank_multi "1.0"

        // Modfiy scout Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_scout_damage_witch_multi "1.0"

        // Modfiy sg552 Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_sg552_damage_SI_multi "1.0"

        // Modfiy sg552 Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_sg552_damage_common_multi "1.0"

        // Modfiy sg552 Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_sg552_damage_tank_multi "1.0"

        // Modfiy sg552 Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_sg552_damage_witch_multi "1.0"

        // Modfiy smg Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_smg_damage_SI_multi "1.0"

        // Modfiy smg Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_smg_damage_common_multi "1.0"

        // Modfiy smg Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_smg_damage_tank_multi "1.0"

        // Modfiy smg Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_smg_damage_witch_multi "1.0"

        // Modfiy silenced smg Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_smgsilenced_damage_SI_multi "1.0"

        // Modfiy silenced smg Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_smgsilenced_damage_common_multi "1.0"

        // Modfiy silenced smg Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_smgsilenced_damage_tank_multi "1.0"

        // Modfiy silenced smg Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_smgsilenced_damage_witch_multi "1.0"

        // Modfiy spass shotgun Damage to SI multi. (0=No Damage, -1: Don't modify)
        l4d_spassshotgun_damage_SI_multi "1.0"

        // Modfiy spass shotgun Damage to Common multi. (0=No Damage, -1: Don't modify)
        l4d_spassshotgun_damage_common_multi "1.0"

        // Modfiy spass shotgun Damage to tank multi. (0=No Damage, -1: Don't modify)
        l4d_spassshotgun_damage_tank_multi "1.0"

        // Modfiy spass shotgun Damage to witch multi. (0=No Damage, -1: Don't modify)
        l4d_spassshotgun_damage_witch_multi "1.0"
		```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

	1. [l4d2_melee_modify_damage](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Weapons_%E6%AD%A6%E5%99%A8/l4d2_melee_modify_damage): Modify Chainsaw and each melee weapon damages dealt to Commons/S.I./Tank/Witch
        > 修改電鋸與每一種近戰武器對 普通殭屍/Tank/Witch/特感 的傷害值
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.3 (2024-2-23)
        * Update cvars

    * v1.2 (2024-1-25)
        * Delete Melee

    * 1.0 (2022-7-25)
        * Initial Release
</details>

- - - -
# 中文說明
修改每一種槍械武器對普通殭屍/Tank/Witch/特感 的傷害倍率

* 原理
	* 修改每一種槍械武器的傷害倍率
    * 如要修改近戰武器的傷害值，請查看 "相關插件" 部分

* <details><summary>槍械武器列表</summary>

    * Pistol => 手槍
    * Magnum Pistol => 麥格農手槍
    * Pump Shotgun => 木製單發散彈槍
    * Shotgun Chrome => 鐵製單發散彈槍
    * Smg => Uzi烏茲衝鋒槍
    * Silenced Smg => 消音衝鋒槍
    * Autoshotgun => 自動連發散彈槍
    * Spas Shotgun => 自動連發戰鬥散彈槍
    * Hunting Rifle => 獵槍
    * Sniper Military => 軍用狙擊槍
    * Rifle => M16步槍
    * Desert Rifle => 三連發步槍
    * Ak47 => AK47
    * Grenade Launcher => 榴彈發射器
    * M60 Rifle => M60機關槍
    * CSS Mp5 => CSS-MP5衝鋒槍
    * SG552 Rifle => CSS-SG552步槍
    * CSS Scout => CSS-Scout狙擊槍
    * CSS AWP => CSS-AWP狙擊槍
</details>

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d2_gun_damage_modify.cfg
		```php
        // 0=關閉插件, 1=啟動插件
        l4d_gun_damage_modify_enable "1"

        // 修改 ak47 對特感造成的傷害倍率 (0=無傷, -1=不修改)
        l4d_ak47_damage_SI_multi "1.0"

        // 修改 ak47 對普通殭屍造成的傷害倍率 (0=無傷, -1=不修改)
        l4d_ak47_damage_common_multi "1.0"

        // 修改 ak47 對Tank造成的傷害倍率 (0=無傷, -1=不修改)
        l4d_ak47_damage_tank_multi "1.0"

        // 修改 ak47 對Witch造成的傷害倍率 (0=無傷, -1=不修改)
        l4d_ak47_damage_witch_multi "1.0"

        // 以下類推...
        l4d_autoshotgun_damage_SI_multi "1.0"
        l4d_autoshotgun_damage_common_multi "1.0"
        l4d_autoshotgun_damage_tank_multi "1.0"
        l4d_autoshotgun_damage_witch_multi "1.0"

        l4d_awp_damage_SI_multi "1.0"
        l4d_awp_damage_common_multi "1.0"
        l4d_awp_damage_tank_multi "1.0"
        l4d_awp_damage_witch_multi "1.0"

        l4d_chromeshotgun_damage_SI_multi "1.0"
        l4d_chromeshotgun_damage_common_multi "1.0"
        l4d_chromeshotgun_damage_tank_multi "1.0"
        l4d_chromeshotgun_damage_witch_multi "1.0"

        l4d_grenadelauncher_damage_SI_multi "1.0"
        l4d_grenadelauncher_damage_common_multi "1.0"
        l4d_grenadelauncher_damage_tank_multi "1.0".
        l4d_grenadelauncher_damage_witch_multi "1.0"

        l4d_huntingrifle_damage_SI_multi "1.0"
        l4d_huntingrifle_damage_common_multi "1.0"
        l4d_huntingrifle_damage_tank_multi "1.0"
        l4d_huntingrifle_damage_witch_multi "1.0"

        l4d_m60_damage_SI_multi "1.0"
        l4d_m60_damage_common_multi "1.0"
        l4d_m60_damage_tank_multi "1.0"
        l4d_m60_damage_witch_multi "1.0"

        l4d_magnum_damage_SI_multi "1.0"
        l4d_magnum_damage_common_multi "1.0"
        l4d_magnum_damage_tank_multi "1.0"
        l4d_magnum_damage_witch_multi "1.0"

        l4d_militarysniper_damage_SI_multi "1.0"
        l4d_militarysniper_damage_common_multi "1.0"
        l4d_militarysniper_damage_tank_multi "1.0"
        l4d_militarysniper_damage_witch_multi "1.0"

        l4d_mp5_damage_SI_multi "1.0"
        l4d_mp5_damage_common_multi "1.0"
        l4d_mp5_damage_tank_multi "1.0"
        l4d_mp5_damage_witch_multi "1.0"

        l4d_pistol_damage_SI_multi "1.0"
        l4d_pistol_damage_common_multi "1.0"
        l4d_pistol_damage_tank_multi "1.0"
        l4d_pistol_damage_witch_multi "1.0"

        l4d_pumpshotgun_damage_SI_multi "1.0"
        l4d_pumpshotgun_damage_common_multi "1.0"
        l4d_pumpshotgun_damage_tank_multi "1.0"
        l4d_pumpshotgun_damage_witch_multi "1.0"

        l4d_rifle_damage_SI_multi "1.0"
        l4d_rifle_damage_common_multi "1.0"
        l4d_rifle_damage_tank_multi "1.0"
        l4d_rifle_damage_witch_multi "1.0"

        l4d_rifledesert_damage_SI_multi "1.0"
        l4d_rifledesert_damage_common_multi "1.0"
        l4d_rifledesert_damage_tank_multi "1.0"
        l4d_rifledesert_damage_witch_multi "1.0"

        l4d_scout_damage_SI_multi "1.0"
        l4d_scout_damage_common_multi "1.0"
        l4d_scout_damage_tank_multi "1.0"
        l4d_scout_damage_witch_multi "1.0"

        l4d_sg552_damage_SI_multi "1.0"
        l4d_sg552_damage_common_multi "1.0"
        l4d_sg552_damage_tank_multi "1.0"
        l4d_sg552_damage_witch_multi "1.0"

        l4d_smg_damage_SI_multi "1.0"
        l4d_smg_damage_common_multi "1.0"
        l4d_smg_damage_tank_multi "1.0"
        l4d_smg_damage_witch_multi "1.0"

        l4d_smgsilenced_damage_SI_multi "1.0"
        l4d_smgsilenced_damage_common_multi "1.0"
        l4d_smgsilenced_damage_tank_multi "1.0"
        l4d_smgsilenced_damage_witch_multi "1.0"

        l4d_spassshotgun_damage_SI_multi "1.0"
        l4d_spassshotgun_damage_common_multi "1.0"
        l4d_spassshotgun_damage_tank_multi "1.0"
        l4d_spassshotgun_damage_witch_multi "1.0"
		```
</details>