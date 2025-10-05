# Description | 內容
When using 'Look' in vocalize menu, print corresponding item to chat area and make item glow or create spot marker/infeced maker like back 4 blood.

* Apply to | 適用於
    ```
    L4D2
    ```

* [Video | 影片展示](https://youtu.be/FxFyhFxaZug)

* Image | 圖示
    * Mark weapons and items (標記武器與物品)
    <br/>![l4d2_item_hint_1](image/l4d2_item_hint_1.jpg)
    <br/>![l4d2_item_hint_2](image/l4d2_item_hint_2.jpg)
    * Mark place and infected (標記地點與特殊感染者)
    <br/>![l4d2_item_hint_3](image/l4d2_item_hint_3.jpg)
    * Support director hint (支援指導系統圖案提示)
    <br/>![l4d2_item_hint_4](image/l4d2_item_hint_4.jpg)
    * Mark your teammates (標記隊友)
    <br/>![l4d2_item_hint_5](image/l4d2_item_hint_5.jpg)

* <details><summary>How does it work?</summary>

    * Mark any weapons, items, infected and spots
        * 'Look' in vocalize menu
        <br/>![l4d2_item_hint_0.jpg](image/l4d2_item_hint_0.jpg)
        * Type```!mark```
        * Press shift+E
    * Marker priority: Infected > Witch > Survivor > Item or Weapon > Spot marker
    * If not aiming target or item, the plugin detects what player is looking at using field of view angle
        * If has more than two targets, it finds the target nearest to your crosshair
    <br/>![l4d2_item_hint_7](image/l4d2_item_hint_7.gif)
    * The infected is unable to mark, unable see the mark and unable to hear the mark sound
</details>

* <details><summary>Important</summary>

    * Hats and others attaching stuff to players could block the players "use" function, which makes you unable to use 'look' item hint. Install [Use Priority Patch](https://forums.alliedmods.net/showthread.php?t=327511) plugin to fix.
    * Player must Enabled GAME INSTRUCTOR, in ESC -> Options -> Multiplayer, or they can't see the hint
    <br/>![l4d2_item_hint_6.jpg](image/l4d2_item_hint_6.jpg)
    * DO NOT modify convar ```sv_gameinstructor_disable``` this force all clients to disable their game instructors.
</details>

* Require | 必要安裝
    1. [Use Priority Patch](https://forums.alliedmods.net/showthread.php?t=327511)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>Support | 支援插件</summary>

	1. [Lux's Model Changer](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/Luxs-Model-Changer): LMC Allows you to use most models with most characters
		* 可以自由變成其他角色或NPC的模組
</details>

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d2_item_hint.cfg
        * Mark Cvars
            ```php
            // If 1, Player can type !mark cmd to mark
            l4d2_item_hint_cmd "1"

            // If 1, Player can press Shift+E to mark
            l4d2_item_hint_shiftE "1"

            // If 1, Player can use Vocalize "look" to mark
            l4d2_item_hint_vocalize "1"

            // If 1, Player can use mark if get pinned by S.I.
            l4d2_item_hint_mark_capped "0"

            // If 1, Player can use mark if is haning from ledge
            l4d2_item_hint_mark_hanging "0"

            // If 1, Dead player can use mark
            l4d2_item_hint_mark_dead "0"

            // Display Instruction Hint Text in which language for all players? 0=Server Language (English), 1=Caller Language
            l4d2_item_hint_instructorhint_translate "0"
            ```

        * Item Hint
            ```php
            // Item Glow Color, Three values between 0-255 separated by spaces. (Empty = Disable Item Glow)
            l4d2_item_marker_glow_color "0 255 255"

            // Cold Down Time in seconds a player can use 'Look' Item Hint again.
            l4d2_item_marker_cooldown_time "1.0"

            // How close can a player use 'Look' item hint.
            l4d2_item_marker_use_range "150"

            // Item Hint Sound. (relative to to sound/, Empty = OFF)
            l4d2_item_marker_use_sound "buttons/blip1.wav"

            // Changes how Item Hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
            l4d2_item_marker_announce_type "1"

            // Item Glow Time.
            l4d2_item_marker_glow_timer "10.0"

            // Item Glow Range.
            l4d2_item_marker_glow_range "800"

            // If 1, Create instructor hint on marked item.
            l4d2_item_marker_instructorhint_enable "1"

            // Instructor hint color on marked item. (If empty, off the item name display)
            l4d2_item_marker_instructorhint_color "0 255 255"

            //Instructor icon name on marked item. (For more icons: https://developer.valvesoftware.com/wiki/Env_instructor_hint)
            l4d2_item_marker_instructorhint_icon "icon_interact"
            ```
            
        * Spot Marker
            ```php
            // Spot Marker Glow Color, Three values between 0-255 separated by spaces. (Empty = Disable Spot Marker)
            l4d2_spot_marker_color "200 200 200"

            // Cold Down Time in seconds a player can use 'Look' Spot Marker again.
            l4d2_spot_marker_cooldown_time "2.5"

            // How far away can a player use 'Look' Spot Marker.
            l4d2_spot_marker_use_range "1800"

            // Spot Marker Sound. (relative to to sound/, Empty = OFF)
            l4d2_spot_marker_use_sound "buttons/blip1.wav"

            // Changes how Spot Marker Hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
            l4d2_spot_marker_announce_type "0"

            // Spot Marker Duration.
            l4d2_spot_marker_duration "10.0"

            // Spot Marker Sprite model. (Empty=Disable)
            l4d2_spot_marker_sprite_model "materials/vgui/icon_arrow_down.vmt"

            // If 1, Create instructor hint on Spot Marker.
            l4d2_spot_marker_instructorhint_enable "1"

            // Instructor hint color on Spot Marker. (If empty, off the hint text display)
            l4d2_spot_marker_instructorhint_color "200 200 200"

            // Instructor icon name on Spot Marker.
            l4d2_spot_marker_instructorhint_icon "icon_info"
            ```

        * Infected Marker
            ```php
            // Infected Marker Glow Color, Three values between 0-255 separated by spaces. (Empty = Disable Infected Marker)
            l4d2_infected_marker_glow_color "255 120 203"

            // Cold Down Time in seconds a player can use 'Look' Infected Marker again.
            l4d2_infected_marker_cooldown_time "0.25"

            // How far away can a player use 'Look' Infected Marker.
            l4d2_infected_marker_use_range "1000"

            // Infected Marker Sound. (relative to to sound/, Empty = OFF)
            l4d2_infected_marker_use_sound "items/suitchargeok1.wav"

            // Changes how infected marker hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
            l4d2_infected_marker_announce_type "1"

            // Infected Marker Glow Time.
            l4d2_infected_marker_glow_timer "10.0"

            // Infected Marker Glow Rang
            l4d2_infected_marker_glow_range "2500"

            // If 1, Enable 'Look' Infected Marker on witch.
            l4d2_infected_marker_witch_enable "1"

            // Enable 'Look' Infected Marker on Which SI? 1=Smoker, 2=Boomer, 4=Hunter, 8=Spitter, 16=Jockey, 32=Charger, 64=Tank. Add numbers together (127=All)
            l4d2_infected_marker_si_flag "127"

            // If 1, Create instructor hint on Infected's head if marked.
            l4d2_infected_marker_instructorhint_enable "1"

            // Instructor hint color on Infecfed Marker. (If empty, off the zombie class display)
            l4d2_infected_marker_instructorhint_color "255 0 0"

            // Instructor icon name on Infecfed Marker.
            l4d2_infected_marker_instructorhint_icon "icon_skull"

            // Fov angle to detect if player is looking speical infected
            // Game vanilla: 45.0, 0=Off, crosshair aim only
            l4d2_infected_marker_si_fov "15.0"

            // Fov angle to detect if player is looking witch
            // Game vanilla: 45.0, 0=Off, crosshair aim only
            l4d2_infected_marker_witch_fov "15.0"
            ```

        * Survivor Marker
            ```php
            // Survivor Marker Glow Color, Three values between 0-255 separated by spaces. (Empty = Disable Infected Marker)
            l4d2_survivor_marker_glow_color "0 200 0"

            // Cold Down Time in seconds a player can use 'Look' Survivor Marker again.
            l4d2_survivor_marker_cooldown_time "1.0"

            // How far away can a player use 'Look' Survivor Marker.
            l4d2_survivor_marker_use_range "1000"

            // Survivor Marker Sound. (relative to to sound/, Empty = OFF)
            l4d2_survivor_marker_use_sound "player/suit_denydevice.wav"

            // Changes how Survivor marker hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
            l4d2_survivor_marker_announce_type "1"

            // Survivor Marker Glow Time.
            l4d2_survivor_marker_glow_timer "10.0"

            // Survivor Marker Glow Range
            l4d2_survivor_marker_glow_range "2000"

            // If 1, Create instructor hint on Survivor's head if marked.
            l4d2_survivor_marker_instructorhint_enable "1"

            // Instructor hint color on Survivor Marker. (If empty, off the name display)
            l4d2_survivor_marker_instructorhint_color "0 200 0"

            // Instructor icon name on Survivor Marker.
            l4d2_survivor_marker_instructorhint_icon "icon_alert"

            // Fov angle to detect if player is looking teammate
            // Game vanilla: 45.0, 0=Off, crosshair aim only
            l4d2_survivor_marker_fov "15.0"
            ```
</details>

* <details><summary>Command | 命令</summary>

    * **Mark item/infected/spot**
        ```php
        sm_mark
        ```
</details>

* Translation Support | 支援翻譯
	```
	translations/l4d2_item_hint.phrases.txt
	```

* <details><summary>Related Plugin | 相關插件</summary>

	1. [l4d2_infected_hp_hint](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Special_Infected_%E7%89%B9%E6%84%9F/l4d2_infected_hp_hint): Display corresponding health value hint of all Special Infected
        * 在特感身上顯示剩餘血量
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v3.9 (2025-10-5)
    * v3.8 (2025-9-23)
        * Update cvars
        * Plugin now helps detect what player is looking at using field of view angle, which means player no longer aims hard at the target

    * v3.7 (2025-3-7)
        * Update cvars

    * v3.6 (2025-2-23)
        * Support LMC (Lux's Model Changer)

    * v3.5 (2024-6-22)
        * Update cvars

    * v3.4 (2024-6-18)
        * Player can makr if dead or incapped or get pinned by special infected
        * Update cvars

    * v3.3 (2024-6-17)
        * Compatible with [Attachments API](https://forums.alliedmods.net/showthread.php?t=325651)

    * v3.2 (2024-6-16)
        * Press Shift+E to mark
        * Update cvars

    * v3.1 (2024-6-11)
        * Add Survivor marker, support custom survivor model
        * Update translation

    * v3.0 (2024-3-6)
        * Custom infected model
        * Custom witch model
        * Update translation

    * v2.9 (2024-3-3)
        * Custom melee model
        * Custom ammo model
        * Update translation

    * v2.8 (2024-2-23)
        * Fixed spot maker error

    * v2.7 (2023-3-18)
        * Add spot maker announce

    * v2.6 (2023-3-8)
        * Translation Support

    * v2.5 (2022-12-27)
        * Add MultiColors

    * v2.4 (2022-12-24)
        * Add Command ```sm_mark```, Mark item/infected/spot for people who don't have 'Look' in vocalize menu

    * v2.3 (2022-10-02)
        * [AlliedModders Post](https://forums.alliedmods.net/showpost.php?p=2765332&postcount=30)
        * Add all gun weapons, melee weapons, minigun, ammo and items.
        * Add cooldown.
        * Add Item Glow, everyone can see the item through wall.
        * Add sound.
        * Fixes custom vocalizers that uses SmartLook with capitals.
        * Add Spot Marker, using 'Look' in vocalize menu to mark the area.
        * Add Infected Marker, using 'Look' in vocalize menu to mark the infected.
        * Add Instructor hint, display instructor hint on Spot Marker/Item Hint
        * Marker priority: Infected maker > Item hint > Spot marker

    * v0.2
        * [Original Post by fdxx](https://forums.alliedmods.net/showthread.php?t=333669)
</details>

- - - -
# 中文說明
使用語音雷達"看"可以標記任何物品、武器、地點、特感

* 原理
    * 可以標記準心指向的任何東西
        1. 使用角色語音雷達"看"
        <br/>![zho/l4d2_item_hint_0.jpg](image/zho/l4d2_item_hint_0.jpg)
        2. 輸入```!mark```
        3. 按下Shift+E
    * 如果準心沒有指向任何東西，會依照玩家視野看到的目標進行標記
        * 如果有兩個目標以上，看哪一個目標離你的準心最近
        <br/>![l4d2_item_hint_7](image/zho/l4d2_item_hint_7.gif)
    * 標記優先順序: 特感 > Witch > 隊友 > 物品或武器 > 地點
    * 特感看不見人類標記的光圈、標記提示，也聽不見標記音效

* 注意事項
    * 如果有其他插件會擋住視野的裝飾品譬如帽子插件，你可能無法使用標記功能，請安裝[Use Priority Patch](https://forums.alliedmods.net/showthread.php?t=327511)以修正
    * 玩家必須啟動[遊戲指導系統](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_教學區/Chinese_繁體中文/Game#啟動遊戲指導系統)，否則玩家看不見標記提示
    * 伺服器端不要修改指令 ```sv_gameinstructor_disable```，這會關閉所有玩家的遊戲指導系統

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d2_item_hint.cfg
        * 標記指令
            ```php
            // 為1時，玩家可以輸入```!mark```標記
            l4d2_item_hint_cmd "1"

            // 為1時，玩家可以按下Shift+E標記
            l4d2_item_hint_shiftE "1"

            // 為1時，玩家可以用"看"語音標記
            l4d2_item_hint_vocalize "1"

            // 為1時，被特感控制的玩家可以使用標記
            l4d2_item_hint_mark_capped "0"

            // 為1時，掛邊的玩家可以使用標記
            l4d2_item_hint_mark_hanging "0"

            // 為1時，死亡的玩家可以使用標記
            l4d2_item_hint_mark_dead "0"

            // 標記的導演提示該使用何種語言翻譯給大家看? 0=伺服器的語言 (英文), 1=呼叫標記的玩家的語言
            l4d2_item_hint_instructorhint_translate "0"
            ```

        * 物品、武器標記
            ```php
            // 標記的光圈顏色，填入RGB三色 (三個數值介於0~255，需要空格)
            // 空=關閉此標記
            l4d2_item_marker_glow_color "0 255 255"

            // 玩家可以再次標記的時間間隔
            l4d2_item_marker_cooldown_time "1.0"

            // 能標記的距離
            l4d2_item_marker_use_range "150"

            // 標記音效. (路徑相對於sound資料夾, 空 = 無音效)
            l4d2_item_marker_use_sound "buttons/blip1.wav"

            // 標記提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 螢幕正中間)
            l4d2_item_marker_announce_type "1"

            // 標記的光圈顯示時間
            l4d2_item_marker_glow_timer "10.0"

            // 標記的光圈可見範圍
            l4d2_item_marker_glow_range "800"

            // 為1時，啟用導演提示
            l4d2_item_marker_instructorhint_enable "1"

            // 導演提示的文字顏色 (空=無文字)
            l4d2_item_marker_instructorhint_color "0 255 255"

            // 導演提示的圖案 (查找更多圖案: https://developer.valvesoftware.com/wiki/Env_instructor_hint)
            l4d2_item_marker_instructorhint_icon "icon_interact"
            ```
            
        * 地點標記
            ```php
            // 標記的光圈顏色，填入RGB三色 (三個數值介於0~255，需要空格)
            // 空=關閉此標記
            l4d2_spot_marker_color "200 200 200"

            // 玩家可以再次標記的時間間隔
            l4d2_spot_marker_cooldown_time "2.5"

            // 能標記的距離
            l4d2_spot_marker_use_range "1800"

            // 標記音效. (路徑相對於sound資料夾, 空 = 無音效)
            l4d2_spot_marker_use_sound "buttons/blip1.wav"

            // 標記提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 螢幕正中間)
            l4d2_spot_marker_announce_type "0"

            // 標記的光圈顯示時間
            l4d2_spot_marker_duration "10.0"

            // 標記的中心模型圖案 (空=無中心模型圖案)
            l4d2_spot_marker_sprite_model "materials/vgui/icon_arrow_down.vmt"

            // 為1時，啟用導演提示
            l4d2_spot_marker_instructorhint_enable "1"

            // 導演提示的文字顏色 (空=無文字)
            l4d2_spot_marker_instructorhint_color "200 200 200"

            // 導演提示的圖案 
            l4d2_spot_marker_instructorhint_icon "icon_info"
            ```

        * 特感標記
            ```php
            // 特感標記的光圈顏色，填入RGB三色 (三個數值介於0~255，需要空格)
            // 空=關閉此標記
            l4d2_infected_marker_glow_color "255 120 203"

            // 玩家可以再次標記特感的時間間隔
            l4d2_infected_marker_cooldown_time "0.25"

            // 能標記特感的距離
            l4d2_infected_marker_use_range "1000"

            // 標記音效. (路徑相對於sound資料夾, 空 = 無音效)
            l4d2_infected_marker_use_sound "items/suitchargeok1.wav"

            // 標記提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 螢幕正中間)
            l4d2_infected_marker_announce_type "1"

            // 標記的光圈顯示時間
            l4d2_infected_marker_glow_timer "10.0"

            // 標記的光圈可見範圍
            l4d2_infected_marker_glow_range "2500"

            // 為1時，也可以標記Witch
            l4d2_infected_marker_witch_enable "1"

            // 可以標記哪些特感? 1=Smoker, 2=Boomer, 4=Hunter, 8=Spitter, 16=Jockey, 32=Charger, 64=Tank. 請將數字相加 (127=全部)
            l4d2_infected_marker_si_flag "127"

            // 為1時，啟用導演提示
            l4d2_infected_marker_instructorhint_enable "1"

            // 導演提示的特感名稱顏色 (空=無特感名稱)
            l4d2_infected_marker_instructorhint_color "255 0 0"

            // 導演提示的圖案 (查找更多圖案: https://developer.valvesoftware.com/wiki/Env_instructor_hint)
            l4d2_infected_marker_instructorhint_icon "icon_skull"

            // 檢測玩家的視野是否正在看特感, 此數值代表特感與玩家準心的距離夾角
            // 遊戲預設: 45.0, 0=不使用, 只算準心有指到
            l4d2_infected_marker_si_fov "15.0"

            // 檢測玩家的視野是否正在看Witch, 此數值代表Witch與玩家準心的距離夾角
            // 遊戲預設: 45.0, 0=不使用, 只算準心有指到
            l4d2_infected_marker_witch_fov "15.0"
            ```

        * 標記隊友
            ```php
            // 標記隊友的光圈顏色，填入RGB三色 (三個數值介於0~255，需要空格)
            // 空=關閉此標記
            l4d2_survivor_marker_glow_color "0 200 0"

            // 玩家可以再次標記隊友的時間間隔
            l4d2_survivor_marker_cooldown_time "1.0"

            // 能標記隊友的距離
            l4d2_survivor_marker_use_range "1000"

            // 標記音效. (路徑相對於sound資料夾, 空 = 無音效)
            l4d2_survivor_marker_use_sound "player/suit_denydevice.wav"

            // 標記提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 螢幕正中間)
            l4d2_survivor_marker_announce_type "1"

            // 標記的光圈顯示時間
            l4d2_survivor_marker_glow_timer "10.0"

            // 標記的光圈可見範圍
            l4d2_survivor_marker_glow_range "2000"

            // 為1時，啟用導演提示
            l4d2_survivor_marker_instructorhint_enable "1"

            // 導演提示的隊友名稱顏色 (空=無隊友名稱)
            l4d2_survivor_marker_instructorhint_color "0 200 0"

            // 導演提示的圖案 
            l4d2_survivor_marker_instructorhint_icon "icon_alert"

            // 檢測玩家的視野是否正在看隊友, 此數值代表隊友與玩家準心的距離夾角
            // 遊戲預設: 45.0, 0=不使用, 只算準心有指到
            l4d2_survivor_marker_fov "15.0"
            ```
</details>
