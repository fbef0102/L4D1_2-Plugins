# Description | 內容
Remove weapon dropped by survivor or uncommon infected + remove upgrade pack when deployed

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>How does it work?</summary>

	* When weapons/items dropped by survivor or by uncommon infected.
		* If no one pick up weapons or items, they will be removed after the certain time passed
		* Will not remove Scavenge Gascan/cola/gnome.
	* When surivior deployed upgrade packs on the gound.
		* They will be removed after the certain time passed
	* Modify weapon/item delete list or time: [data/clear_weapon_drop.cfg](data/clear_weapon_drop.cfg)
		* Manual in this file, click for more details...
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>Related Plugin | 相關插件</summary>

	1. [l4d_drop](/l4d_drop): Allows players to drop the weapon they are holding
		> 玩家可自行丟棄手中的武器
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/clear_weapon_drop.cfg
		```php
		// 0=Plugin off, 1=Plugin on.
		clear_weapon_drop_enable "1"

		// 1=Do not remove weapons if dropped when player death
		// 0=Remove
		clear_weapon_drop_death_not "1"
		```
</details>

* <details><summary>API | 串接</summary>

	* [clear_weapon_drop.inc](scripting/include/clear_weapon_drop.inc)
		```php
		library name: clear_weapon_drop
		```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v3.3 (2026-2-1)
		* Add data to control weapon list and remoe time
		* Update cvars
		* Won't remove weapons if dropped when player death

	* v3.2 (2025-1-30)
		* Optimize code

	* v3.1 (2023-5-10)
		* Will not remove Scavenge Gascan.
		* Optimize code and improve performance

	* v3.0 (2023-1-28)
		* Remove weapon after dropped by uncommon infected.

	* v2.9
		* [AlliedModder Post](https://forums.alliedmods.net/showpost.php?p=2731634&postcount=19)
		* Remake Code
		* Remove gnome and cola
		* Create Native
		* Use EntIndexToEntRef and EntRefToEntIndex to remove entity safely
		* Remove upgrade pack after deployed on the ground

	* v1.7
		* [Original Plugin by AK978](https://forums.alliedmods.net/showthread.php?p=2638375)
</details>

- - - -
# 中文說明
如果一段時間後沒有人撿起掉落的武器與物品，則自動移除

* 原理
    * 當人類從手上掉落物器或物品時，一段時間過後如果沒有人撿起或者使用將自動移除
		* 玩家死亡、丟棄、更換武器與物品
		* 玩家從手中丟出汽油桶、瓦斯桶、氧氣罐、煙火盒、精靈小矮人、可樂瓶也算 (不會移除黃色與綠色的汽油桶)
	* 當人類放置燃燒彈包與高爆彈包於地上之後，一段時間過後將自動移除
    * 當特殊一般感染者掉落武器或物品時，一段時間過後如果沒有人撿起或者使用將自動移除
		* CEDA防疫人員的膽汁瓶
		* 防暴警察的警棍
		* 墮落生還者的醫療與投擲物品
	* 不影響地圖上原本的武器與物品，只有當武器與物品從人類或者感染者身上掉落之後才會觸發移除
	* 如要更改移除時間或是移除的武器項目，查看文件: [data/clear_weapon_drop.cfg](data/clear_weapon_drop.cfg)
		* 內有中文說明書

* 用意在哪?
	* 避免伺服器塞滿過多的武器與物品導致崩潰 (伺服器實體物件空間不足)
    * 適合用於很多RPG或頻繁生出武器與物品的伺服器

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/clear_weapon_drop.cfg
		```php
		// 0=關閉插件, 1=啟動插件
		clear_weapon_drop_enable "1"

		// 1=不會移除倖存者死亡時掉落之物器或物品
		// 0=會移除倖存者死亡時掉落之物器或物品
		clear_weapon_drop_death_not "1"
		```
</details>