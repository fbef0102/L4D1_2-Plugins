# L4D1&2-Plugins  by Harry Potter
Help server to record, make server more fun, and more useful plugins for adm.
> All plugins in here apply to L4D1 or L4D2 <br/>
> If you have any modify or request, feel free to use or pay me money to do it.
# Appreciate my work, you can [PayPal Donate](https://paypal.me/Harry0215?locale.x=zh_TW) me.

# Require
* [L4D1 Server Install](https://github.com/fbef0102/Sourcemod-Server/tree/main/L4D1#server-install)
* [L4D2 Server Install](https://github.com/fbef0102/Sourcemod-Server/tree/main/L4D2#server-install)

# Plugins
> __Note__  
> **[>>Click here to see my private plugin list<<](https://github.com/fbef0102/Game-Private_Plugin?tab=readme-ov-file#%E7%A7%81%E4%BA%BA%E6%8F%92%E4%BB%B6%E5%88%97%E8%A1%A8-private-plugins-list)**<br/>
> **[>>點擊我查看更多私人插件<<](https://github.com/fbef0102/Game-Private_Plugin?tab=readme-ov-file#%E7%A7%81%E4%BA%BA%E6%8F%92%E4%BB%B6%E5%88%97%E8%A1%A8-private-plugins-list)**
* <b>[l4d_achievement_trophy](/l4d_achievement_trophy)</b>: Displays the TF2 trophy when a player unlocks an achievement.
* <b>[cge_l4d2_deathcheck](/cge_l4d2_deathcheck)</b>: Prevents mission loss(Round_End) until all human players have died.
* <b>[l4d_tanklimit](/l4d_tanklimit)</b>: limit tank in server
* <b>[l4d_rock_lagcomp](/l4d_rock_lagcomp)</b>: Provides lag compensation for tank rock entities
* <b>[l4d2_Death_Survivor](/l4d2_Death_Survivor)</b>: If a player die as a survivor, this model survior bot keep death until map change or server shutdown
* <b>[l4d2_vocalizebasedmodel](/l4d2_vocalizebasedmodel)</b>: Survivors will vocalize based on their model
* <b>[clear_dead_body](/clear_dead_body)</b>: Remove Dead Body Entity
    * 倖存者死亡之後過一段時間，移除屍體
* <b>[kills](/kills)</b>: show statistics of surviviors (kill S.I, C.I. and FF)on round end
    * 擊殺殭屍與特殊感染者統計
* <b>[clear_weapon_drop](/clear_weapon_drop)</b>: Remove drop weapon + remove upgradepack when used
    * 如果一段時間後沒有人撿起掉落的武器與物品，則自動移除
* <b>[no-rushing](/no-rushing)</b>: Prevents Rushers From Rushing Then Teleports Them Back To Their Teammates.
    * 離隊伍太遠的玩家會傳送回隊伍之中
* <b>[l4dmultislots](/l4dmultislots)</b>: Allows additional survivor players in server when 5+ player joins the server
    * 創造5位以上倖存者遊玩伺服器
* <b>[savechat](/savechat)</b>: Records player chat messages to a file.
    * 紀錄玩家的聊天紀錄到文件裡
* <b>[l4dinfectedbots](/l4dinfectedbots)</b>: Spawns multi infected bots in any mode + allows playable special infected in coop/survival + unlock infected slots (10 VS 10 available)
    * 多特感生成插件，倖存者人數越多，生成的特感越多，且不受遊戲特感數量限制 + 解除特感隊伍的人數限制 (可達成對抗 10 VS 10 玩法)
* <b>[l4d2_spawn_props](/l4d2_spawn_props)</b>: Let admins spawn any kind of objects and saved to cfg
    * 創造屬於自己風格的地圖，製作迷宮與障礙物
* <b>[l4d_explosive_cars](/l4d_explosive_cars)</b>: Cars explode after they take some damage
    * 車子爆炸啦!
* <b>[l4d_lasertag](/l4d_lasertag)</b>: Shows a laser for straight-flying fired projectiles
    * 開槍會有子彈光線
* <b>[anti-friendly_fire](/anti-friendly_fire)</b>: shoot your teammate = shoot yourself.
    * 隊友黑槍會反彈友傷
* <b>[l4d_afk_commands](/l4d_afk_commands)</b>: Adds commands to let the player spectate and join team. (!afk, !survivors, !infected, etc.),but no abuse.
    * 提供多種命令轉換隊伍陣營 (譬如: !afk, !survivors, !infected), 但不可濫用.
* <b>[l4d_blackandwhite](/l4d_blackandwhite)</b>: Notify people when player is black and white.
    * 誰是黑白狀態(最後一條生命)
* <b>[l4d_cso_zombie_Regeneration](/l4d_cso_zombie_Regeneration)</b>: The zombies have grown stronger, now they are able to heal their injuries by standing still without receiving any damage.
    * 殭屍變得更強大，他們只要站著不動便可以自癒傷勢　(仿CSO惡靈降世 殭屍技能)
* <b>[l4d_drop](/l4d_drop)</b>: Allows players to drop the weapon they are holding
    * 玩家可自行丟棄手中的武器
* <b>[l4d_game_files_precacher](/l4d_game_files_precacher)</b>: Precaches Game Files To Prevent Crashes. + Prevents late precache of specific models
    * 預先載入所有可能會缺失的模組避免伺服器崩潰
* <b>[l4d_MusicMapStart](/l4d_MusicMapStart)</b>: Download and play one random music on map start/round start.
    * 回合開始播放音樂，使用!music點歌系統，可播放自製的音樂
* <b>[l4d_shotgun_sound_fix](/l4d_shotgun_sound_fix)</b>: Thirdpersonshoulder Shotgun Sound Fix
    * 修復第三人稱下，散彈槍射擊沒有槍聲
* <b>[l4d_votes_5](/l4d_votes_5)</b>: L4D1/2 Vote Menu (Change map、Kick、Restart、Give HP、Alltalk)
    * L4D1/2 投票選單 (換圖、踢人、重新回合、回血、全頻語音)
* <b>[l4d_wind](/l4d_wind)</b>: Create a survivor bot in game. + Teleport Player
    * 新增Bot + 傳送玩家到其他位置上
* <b>[l4d_witch_behind_fix](/l4d_witch_behind_fix)</b>: The witch turns back if nearby survivor scares her behind
    * 當有人在背後驚嚇Witch，Witch會秒轉身攻擊
* <b>[l4d2_assist](/l4d2_assist)</b>: Show damage done to S.I. by survivors
    * 特感死亡時顯示人類造成的傷害統計
* <b>[l4dffannounce](/l4dffannounce)</b>: Adds Friendly Fire Announcements (who kills teammates).
    * 顯示誰他馬TK我
* <b>[sm_downloader](/sm_downloader)</b>: SM File/Folder Downloader and Precacher
    * SM 文件下載器 (玩家連線伺服器的時候能下載自製的檔案)
* <b>[tank_witch_spawn_notify](/tank_witch_spawn_notify)</b>: When the tank and witch spawns, it announces itself in chat by making a sound
    * Tank/Witch出現有提示與音效
* <b>[trigger_horde_notify](/trigger_horde_notify)</b>: Who called the horde ?
    * 顯示誰觸發了屍潮事件
* <b>[witch_target_override](/witch_target_override)</b>: (Archived) Change target when the witch incapacitates or kills victim + witch auto follows survivors
    * (棄案) Witch會自動跟蹤你，一旦驚嚇到她，不殺死任何人絕不罷休
* <b>[l4d_expertrealism](/l4d_expertrealism)</b>: L4D1/2 Real Realism Mode (No Glow + No Hud)
    * L4D1/2 真寫實模式 (沒有光圈與介面)
* <b>[L4DVSAutoSpectateOnAFK](/L4DVSAutoSpectateOnAFK)</b>: Forces survivors and infected to spectate if they're AFK after certain time.
    * 當有玩家AFK一段時間，強制將玩家旁觀並踢出伺服器
* <b>[spawn_infected_nolimit](/spawn_infected_nolimit)</b>: Provide natives, spawn special infected without the director limits!
    * 輔助插件，不受數量與遊戲限制生成特感
* <b>[l4d2pause](/l4d2pause)</b>: Allows admins to force the game to pause, only adm can unpause the game.
    * 管理員可以強制暫停遊戲，也只有管理員能解除暫停
* <b>[l4d_current_survivor_progress](/l4d_current_survivor_progress)</b>: Print survivor progress in flow percents
    * 使用指令顯示人類目前的路程
* <b>[fix_botkick](/fix_botkick)</b>: Fixed no Survivor bots issue after map loading.
    * 解決換圖之後沒有任何倖存者Bot的問題
* <b>[lockdown_system_l4d](/lockdown_system_l4d)</b>: Locks Saferoom Door Until Someone Opens It.
    * 倖存者必須等待時間到並合力對抗屍潮與Tank才能打開終點安全門
* <b>[pounceannounce](/pounceannounce)</b>: Announces hunter pounces to the entire server
    * 顯示Hunter造成的高撲傷害與高撲距離
* <b>[l4d_meteor_hunter](/l4d_meteor_hunter)</b>: Hunter high pounces cause meteor strike
    * Hunter的高撲造成核彈衝擊波
* <b>[l4d_sm_respawn](/l4d_sm_respawn)</b>: Allows players to be respawned by admin.
    * 管理員能夠復活死去的玩家
* <b>[l4d_tankhelper](/l4d_tankhelper)</b>: Tanks throw Tank/S.I./Witch/Hittable instead of rock
    * Tank不扔石頭而是扔出特感/Tank/Witch/車子
* <b>[l4d_pig_infected_notify](/l4d_pig_infected_notify)</b>: Show who is pig teammate in infected team
    * 顯示誰是豬隊友 (譬如推Tank拍死隊友、Boomer炸到Tank、Hunter跳樓自殺、Charger著火死亡等等)
* <b>[Survivor_Respawn](/Survivor_Respawn)</b>: When a Survivor dies, will respawn after a period of time.
    * 當人類玩家死亡時，過一段時間自動復活
* <b>[l4d_DynamicHostname](/l4d_DynamicHostname)</b>: Server name with txt file (Support any language)
    * 伺服器房名可以寫中文的插件
* <b>[l4d_revive_reload_interrupt](/l4d_revive_reload_interrupt)</b>: Reviving cancels reloading to fix that weapon has jammed and misfired (stupid bug exists for more than 10 years)
    * 解決裝子彈的時候拯救隊友會卡彈的問題 (存在超過十年的Bug)
* <b>[hp_tank_show](/hp_tank_show)</b>: Shows a sprite at the tank head that goes from green to red based on its HP
    * Tank頭上顯示血量狀態
* <b>[l4d2_block_rocketjump](/l4d2_block_rocketjump)</b>: Block rocket jump exploit with grenade launcher/vomitjar/pipebomb/molotov/common/spit/rock/witch
    * 修復Source引擎的踩頭跳躍bug
* <b>[l4d2_spritetrail_fix](/l4d2_spritetrail_fix)</b>: Fixed the final stage get stucked
    * 修復Source引擎的bug，看不見spritetrail物件的發光效果
* <b>[l4d_kickloadstuckers](/l4d_kickloadstuckers)</b>: Kicks Clients that get stuck in server connecting state
    * 踢出卡Loading連線中的玩家
* <b>[pounce_database](/pounce_database)</b>: (Archived) Top Hunter Pounce Announce (Data Support)
    * (棄案) 統計高撲的數量與顯示前五名高撲的大佬 (支援文件儲存)
* <b>[skeet_database](/skeet_database)</b>: (Archived) Top Skeet Hunter Announce (Data Support)
    * (棄案) 統計一槍秒殺Hunter的數量與顯示前五名擊殺的大佬 (支援文件儲存)
* <b>[l4d2_powerups_rush](/l4d2_powerups_rush)</b>: When a client pops an adrenaline (or pills), various actions are perform faster (reload, melee swings, firing rates)
    * 服用腎上腺素或藥丸，提升裝彈速度、開槍速度、近戰砍速、動畫起身速度
* <b>[l4d1_block_player_swim](/l4d1_block_player_swim)</b>: Disable the 'water hopping' spam in l4d1.
    * 修復L4D1遊戲的Bug: 水上游泳
* <b>[l4d1_weapon_limits](/l4d1_weapon_limits)</b>: Maximum of each L4D1 weapons the survivors can pick up
    * 限制L4D1遊戲中每個武器可以拿取的數量，超過就不能拿取
* <b>[l4d1_ban_twotank_glitch_player](/l4d1_ban_twotank_glitch_player)</b>: Ban player who uses L4D1 / Split tank glitchpick up
    * 修復L4D1遊戲的Bug: 雙重Tank生成的問題
* <b>[l4d_reservedslots](/l4d_reservedslots)</b>: Admin Reserved Slots in L4D1/2 (Sorry, Reserverd Slots for Admin..)
    * 當滿人的時候，管理員可以使用預留通道加入 (訊息提示: 剩餘通道只能管理員加入.. )
* <b>[l4d_death_soul](/l4d_death_soul)</b>: Soul of the dead survivor flies away to the afterlife
    * 人類死亡後，靈魂升天
* <b>[l4d_graves](/l4d_graves)</b>: When a survivor die, on his body appear a grave.
    * 為人類屍體造一個墓碑以做紀念
* <b>[l4d_tankAttackOnSpawn](/l4d_tankAttackOnSpawn)</b>: (Archived) Forces AI tank to leave stasis and attack while spawn in coop/realism.
    * (棄案) 戰役/寫實模式下，AI Tank一生成會直接往前進並攻擊倖存者，而非待在原地等待
* <b>[l4d_final_rescue_gravity](/l4d_final_rescue_gravity)</b>: Set client gravity after final rescue starts just for fun.
    * 救援開始之後，所有人重力變低，可以跳很高
* <b>[gamemode-based_configs](/gamemode-based_configs)</b>: Allows for custom settings for each gamemode and mutatuion.
    * 根據遊戲模式或突變模式執行不同的cfg文件
* <b>[l4d_mix](/l4d_mix)</b>: L4D1/2 Mix
    * 對抗模式中，投票選雙方隊長，雙方隊長再選隊員
* <b>[l4d_flying_tank](/l4d_flying_tank)</b>: Provides the ability to fly to Tanks and special effects.
    * Tank化身鋼鐵人，可以自由飛行
* <b>[admin_hp](/admin_hp)</b>: Adm type !hp to set survivor team full health.
    * 管理員輸入!hp 可以回滿所有倖存者的血量
* <b>[l4d2_vote_manager3](/l4d2_vote_manager3)</b>: Unable to call valve vote if player does not have access
    * 沒有權限的玩家不能隨意發起官方投票
* <b>[l4d_spectator_prefix](/l4d_spectator_prefix)</b>: when player in spec team, add prefix.
    * 旁觀者的名字前，加上前缀符號
* <b>[l4d_limited_ammo_pile](/l4d_limited_ammo_pile)</b>: Once everyone has used the same ammo pile at least once, it is removed.
    * 子彈堆只能拿一次子彈，當每個人都拿過一遍之後移除子彈堆
* <b>[l4d_weapon_editor_fix](/l4d_weapon_editor_fix)</b>: Fix some Weapon attribute not exactly obey keyvalue in weapon_*.txt
    * 修復一些武器的 weapon_*.txt 參數沒有作用
* <b>[l4d2_spec_stays_spec](/l4d2_spec_stays_spec)</b>: Spectator will stay as spectators on mapchange/new round.
    * 上一回合是旁觀者的玩家, 下一回合開始時繼續待在旁觀者 (避免被自動切換到人類/特感隊伍)
* <b>[firebulletsfix](/firebulletsfix)</b>: Fixes shooting/bullet displacement by 1 tick problems so you can accurately hit by moving.
    * 修復子彈擊中與伺服器運算相差 1 tick的延遲
* <b>[gametype_description](/gametype_description)</b>: Allows changing of displayed game type in server browser
    * 更改伺服器的遊戲欄資訊
* <b>[_AutoTakeOver](/_AutoTakeOver)</b>: Auto Takes Over an alive free bot UponDeath or OnBotSpawn in 5+ survivor
    * 當真人玩家死亡時，自動取代另一個有空閒的Bot繼續遊玩倖存者
* <b>[l4dafkfix_deadbot](/l4dafkfix_deadbot)</b>: Fixes issue when a bot die, his IDLE player become fully spectator rather than take over dead bot in 4+ survivors games
    * 修正5+多人遊戲裡，當真人玩家閒置的時候如果他的Bot死亡，真人玩家不會取代死亡Bot而是變成完全旁觀者
* <b>[l4d_ai_hunter_skeet_dmg_fix](/l4d_ai_hunter_skeet_dmg_fix)</b>: Makes AI Hunter take damage like human SI while pouncing.
    * 對AI Hunter(正在飛撲的途中) 造成的傷害數據跟真人玩家一樣
* <b>[vocal_block](/vocal_block)</b>: Blocks the stupid griefers who spam vocalize commands throughout campaigns.
    pouncing.
    * 禁止玩家頻繁使用角色雷達語音
* <b>[l4d_switch_team_survivor_dead_fix](/l4d_switch_team_survivor_dead_fix)</b>: Fixed a bug that exists over 12 years in l4d1/2, sometimes infected player switchs team to survivor, the survivor gets incapped/killed instantly
    * 修復切換陣營之後會導致倖存者死亡或倒地的Bug (官方的bug)
* <b>[l4d_unreservelobby](/l4d_unreservelobby)</b>: Removes lobby reservation when server is full, allow 9+ players to join server
    * 移除伺服器的大廳人數限制，簡單講就是解鎖伺服器，讓第九位以上的玩家可以加入伺服器
* <b>[l4d_heartbeat](/l4d_heartbeat)</b>: Fixes survivor_max_incapacitated_count cvar increased values reverting black and white screen.
    * 可用指令調整倖存者有多條生命與黑白狀態
* <b>[l4d_rescue_vehicle_leave_timer](/l4d_rescue_vehicle_leave_timer)</b>: When rescue vehicle arrived and a timer will display how many time left before vehicle leaving. If a player is not on rescue vehicle or zone, slay him
    * 救援來臨之後，未在時間內上救援載具逃亡的玩家將處死
* <b>[l4d_CreateSurvivorBot](/l4d_CreateSurvivorBot)</b>: Provides CreateSurvivorBot Native, spawn survivor bots without limit.
    * 輔助插件，不受遊戲限制生成倖存者Bots
* <b>[Enhanced_Throwables](/Enhanced_Throwables)</b>: Adds dynamic Light to held and thrown pipe bombs and molotovs
    * 土製炸彈與火瓶有動態光源特效
* <b>[l4d2_mixmap](/l4d2_mixmap)</b>: Randomly select five maps for versus/coop/realism. Adding for fun
    * 隨機抽取五個關卡組成一張地圖，適用於戰役/對抗/寫實，依一定順序切換地圖來進行遊戲，增加遊戲的趣味性
* <b>[l4d2_transition_info_fix](/l4d2_transition_info_fix)</b>: Fix issues after map transitioned, transition info is still retaining when changed new map by other ways.
    * 修復中途換地圖的時候(譬如使用Changelevel指令)，會遺留上次的過關保存設定，導致滅團後倖存者被傳送到安全室之外或死亡
* <b>[l4d2_maptankfix](/l4d2_maptankfix)</b>: Fix issues where customized map tank does not spawn, cause the map process break 
    * 防止地圖自帶的機關Tank因為人數不夠問題​​無法刷新而造成卡關
* <b>[l4d_start_safe_area](/l4d_start_safe_area)</b>: Add Custom safe area for any map on start
    * 遊戲開局時，強制將出生點周圍區域判定為安全區，以確保玩家安全
* <b>[l4d_fastdl_delay_downloader](/l4d_fastdl_delay_downloader)</b>: Downloading fastdl custom files only when map change/transition
    * 只有在換圖或過關時，才讓玩家下載Fastdl自製的檔案
* <b>[physics_object_pushfix](/physics_object_pushfix)</b>: Prevents firework crates, gascans, oxygen, propane tanks and pipe bombs being pushed when players walk into them
    * 修復玩家走路就能推擠地上物品或土製炸彈
* <b>[l4d2_release_victim](/l4d2_release_victim)</b>: Allow to release victim
    * 特感可以釋放被抓住的倖存者
* <b>[l4d2_rescue_vehicle_multi](/l4d2_rescue_vehicle_multi)</b>: Try to fix extra 5+ survivors bug after finale rescue leaving, such as: die, fall down, not count as alive, versus score bug
    * 修正第五位以上的玩家無法上救援載具，統計顯示其死亡，無法列入對抗分數
* <b>[l4d_witch_realism_door_fix](/l4d_witch_realism_door_fix)</b>: Fixing witch can't break the door on Realism Normal、Advanced、Expert
    * 修正Witch在寫實模式下的一般難度、進階難度、專家難度，無法抓破門
* <b>[jockey_ride_team_switch_teleport_fix](/jockey_ride_team_switch_teleport_fix)</b>: Fixed Teleport bug if jcokey player switches team while ridding the survivor
    * 修正Jockey玩家跳隊時，會發生傳送bug
* <b>[l4d_flying_car](/l4d_flying_car)</b>: Replaces getaway chopper by flying car in L4D2 C8 No Mercy
    * 前往霍格華茲學院的魔法汽車
* <b>[all4dead2](/all4dead2)</b>: Enables admins to have control over the AI Director and spawn all weapons, melee, items, special infected, and Uncommon Infected without using sv_cheats 1
    * 管理員可以直接操控遊戲導演系統並生成武器、近戰武器、物品、醫療物品、特殊感染者以及特殊一般感染者等等，無須開啟作弊模式
* <b>[drop_secondary](/drop_secondary)</b>: Survivor players will drop their secondary weapon (including melee) when they die
    * 死亡時掉落第二把武器
* <b>[l4d_death_weapon_respawn_fix](/l4d_death_weapon_respawn_fix)</b>: In coop/realism, if you died with primary weapon, you will respawn with T1 weapon. Delete datas if hold M60 or mission lost
    * 修復在戰役/寫實模式中重新復活或救援房間救活的時候，武器不一樣
* <b>[l4d2_biletheworld](/l4d2_biletheworld)</b>: Vomit Jars hit Survivors, Boomer Explosions slime Infected.
    * 膽汁瓶會噴到倖存者身上，Boomer爆炸的膽汁噴到特感、Tank、Witch、普通感染者
* <b>[l4d2_gifts](/l4d2_gifts)</b>: Drop gifts when a special infected or a tank/witch killed by survivor.
    * 殺死特感會掉落禮物盒，會獲得驚喜物品，聖誕嘉年華
* <b>[l4d2_item_hint](/l4d2_item_hint)</b>: When using 'Look' in vocalize menu, print corresponding item to chat area.
    * 使用語音雷達"看"可以標記任何物品、武器、地點、特感
* <b>[l4d2_karma_kill](/l4d2_karma_kill)</b>: Very Very loudly announces the predicted event of a player leaving the map and or life through height or drown.    
    * 被Charger撞飛、Tank打飛、Jockey騎走墬樓、自殺跳樓等等會有慢動作特效
* <b>[l4d2_skill_detect](/l4d2_skill_detect)</b>: Detects and reports skeets, crowns, levels, highpounces, etc.
    * 顯示人類與特感各種花式技巧 (譬如推開特感、速救隊友、一槍爆頭、近戰砍死、高撲傷害等等)
* <b>[l4d2_spectating_cheat](/l4d2_spectating_cheat)</b>: A spectator who watching the survivor at first person view can now see the infected model glows though the wall
    * 旁觀者可以看到特感的光圈，方便旁觀者觀賞
* <b>[l4d2_supply_woodbox](/l4d2_supply_woodbox)</b>: CSO Random Supply Boxes in l4d2
    * 地圖上隨機出現補給箱，提供人類強力支援 (仿CSO惡靈降世 補給箱)
* <b>[l4d2_tank_props_glow](/l4d2_tank_props_glow)</b>: When a Tank punches a Hittable it adds a Glow to the hittable which all infected players can see.
    * Tank打到的物件都會產生光圈，只有特感能看見 + Tank死亡之後車子自動消失
* <b>[l4d2_weapon_csgo_reload](/l4d2_weapon_csgo_reload)</b>: Quickswitch Reloading like CS:GO in L4D2
    * 將武器改成現代遊戲的裝子彈機制 (仿CS:GO切槍裝彈設定)
* <b>[LMC_Black_and_White_Notifier](/LMC_Black_and_White_Notifier)</b>: Notifies selected team(s) when someone is on final strike and add glow 
    * 顯示誰是黑白狀態，有更多的提示與支援LMC模組
* <b>[show_mic](/show_mic)</b>: Voice Announce in centr text + create hat to Show Who is speaking.
    * 顯示誰在語音並且在說話的玩家頭上帶帽子
* <b>[l4d2_ty_saveweapons](/l4d2_ty_saveweapons)</b>: L4D2 coop save weapon when map transition if more than 4 players
    * 當伺服器有5+以上玩家遊玩戰役、寫實時，保存他們過關時的血量以及攜帶的武器、物資
* <b>[l4d2_mission_manager](/l4d2_mission_manager)</b>: Mission manager for L4D2, provide information about map orders for other plugins
    * 地圖管理器，提供給其他插件做依賴與API串接
* <b>[AI_HardSI](/AI_HardSI)</b>: Improves the AI behaviour of special infected
    * 強化每個AI 特感的行為與提高智商，積極攻擊倖存者
* <b>[pill_passer](/pill_passer)</b>: Lets players pass pills and adrenaline with +Reload key
    * 用R鍵直接傳送藥丸與腎上腺素給隊友
* <b>[l4d2_cs_kill_hud](/l4d2_cs_kill_hud)</b>: HUD with cs kill info list.
    * L4D2擊殺提示改成CS遊戲的擊殺列表
* <b>[hunter_growl_sound_fix](/hunter_growl_sound_fix)</b>: Fix silence Hunter produces growl sound when player MIC on
    * 修復使用Mic的Hunter玩家會發出聲音
* <b>[huntercrouchsound](/huntercrouchsound)</b>: Forces silent but crouched hunters to emitt sounds
    * 強制蹲下安靜的Hunter發出聲音
* <b>[l4d2_melee_swing](/l4d2_melee_swing)</b>: Adjustable melee swing rate for each melee weapon.
    * 調整每個近戰武器的揮砍速度
* <b>[l4d_finale_stage_fix](/l4d_finale_stage_fix)</b>: Fixed the final stage get stucked
    * 解決最後救援卡關，永遠不能來救援載具的問題
* <b>[l4d2_gun_damage_modify](/l4d2_gun_damage_modify)</b>: Modify every weapon damage done to Tank, SI, Witch, Common in l4d2
    * 修改每一種槍械武器對普通殭屍/Tank/Witch/特感 的傷害倍率
* <b>[l4d2_ai_damagefix](/l4d2_ai_damagefix)</b>: (Archived) Makes AI SI take (and do) damage like human SI.
    * (棄案) 對AI Hunter與 AI Charger造成的傷害數據跟真人玩家一樣
* <b>[lfd_both_fixUpgradePack](/lfd_both_fixUpgradePack)</b>: Fixes upgrade packs pickup bug when there are 5+ survivors
    * 修正高爆彈與燃燒彈無法被重複角色模組的倖存者撿起來
* <b>[l4d2_chainsaw_refuelling](/l4d2_chainsaw_refuelling)</b>: Allow refuelling of a chainsaw
    * 可以使用汽油桶重新填充電鋸油量
* <b>[l4d2_bash_kills](/l4d2_bash_kills)</b>: Stop special infected getting bashed to death
    * 特感不會被人類右鍵推到死去
* <b>[charging_takedamage_patch](/charging_takedamage_patch)</b>: Makes AI Charger take damage like human SI while charging.
    * 移除AI Charger的衝鋒減傷
* <b>[rescue_glow](/rescue_glow)</b>: Fixed sometimes glow is invisible when dead survivors appears in rescue closet
    * 修復有時候救援房間沒有看到倖存者的光圈
# Scripting Compiler
* [sourcemod v1.11 compiler](https://www.sourcemod.net/downloads.php?branch=1.11-dev): scripting folder
    * 使用 sourcemod v1.11 的編譯環境
* SourceMod is licensed under the [GNU General Public License, version 3](https://www.sourcemod.net/license.php).
    * 此專案內所有開源碼皆在授權條款下: [GNU General Public License, version 3](https://www.sourcemod.net/license.php)

# Others
* <b>[Sourcemod-Plugins](https://github.com/fbef0102/Sourcemod-Plugins)</b>: Plugins for most source engine games.
* <b>[L4D1-Server](https://github.com/fbef0102/Sourcemod-Server/tree/main/L4D1)</b>: Setup your own L4D1 Servers.
* <b>[L4D2-Server](https://github.com/fbef0102/Sourcemod-Server/tree/main/L4D2)</b>: Setup your own L4D2 Servers.
* <b>[Game-Private_Plugin](https://github.com/fbef0102/Game-Private_Plugin)</b>: Private Plugin List.
