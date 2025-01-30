// Explain / 說明書
//
//  // 1 = Announce current plugin status in chatbox when the number of alive survivors changes.
//  // 1 = 當存活的倖存者數量發生變化時，聊天框提示插件狀態
//  "announce_enable" "1"
//
//  // Sets the limit
//  // 設置特感上限
//  "smoker_limit"      "2"
//  "boomer_limit"      "2"
//  "hunter_limit"      "2"
//  "spitter_limit"     "2"
//  "jockey_limit"      "2"
//  "charger_limit"     "2"

//  // Defines how many special infected can be on the map on all gamemodes (does not count witch on all gamemodes, count tank in all gamemode)
//  // The 6 infected limit [Smoker, Boomer, Hunter, Spitter, Jockey, Charger] combined together must equal or exceed this value
//  // 設置插件生成的最大特感數量
//  // 必須讓6個特感數量[Smoker, Boomer, Hunter, Spitter, Jockey, Charger]的值加起來超過這個值
//  "max_specials"      "4"
//
//  // Sets the max and min spawn time for special infected spawned by the plugin in seconds.
//  // 設置插件生成的特感最大與最小時間 (秒)
//  "spawn_time_max"    "60.0"
//  "spawn_time_min"    "40.0"
//
//  // Amount of seconds before a special infected bot is kicked
//  // AI特感生成多少秒後，如果沒攻擊倖存者也沒被看見將踢出遊戲（防止AI卡住）
//  "life"                  "30.0"
//
//  // The spawn time in seconds used when infected bots are spawned for the first time after survivors left saferoom
//  // 倖存者離開安全室後第一波特感何時刷出來
//  "initial_spawn_time"  "10.0"
//
//  // The weight for spawning [0-100]
//  // 插件生成特感的權重值 [0-100]
//  "smoker_weight"      "100"
//  "boomer_weight"      "80"
//  "hunter_weight"      "100"
//  "spitter_weight"     "80"
//  "jockey_weight"      "100"
//  "charger_weight"     "100"
//
//  // 1 = Scale spawn weights with the limits of corresponding SI
//  // 1 = 可生成的最大數量越多，該特感的權重值越高
//  // 1 = 場上相同特感種類的數量越多，該特感的權重值越低
//  "scale_weights"     "1"
//
//  // Set SI Health (0=Don't modify SI health)
//  // 設置特感血量 (0=不修改血量)
//  "smoker_health"      "250"
//  "boomer_health"      "50"
//  "hunter_health"      "250"
//  "spitter_health"     "100"
//  "jockey_health"      "325"
//  "charger_health"     "600"
//
//  // Sets the tank limit (Does not affect director tank)
//  // 設置Tank上限	(不影響導演系統生成tank)
//  "tank_limit"        "1"
//   
//  // When each time spawn S.I., how much percent of chance to spawn tank [0-100%]
//  // 每次生成一個特感的時候多少概率會變成tank [0-100%]
//  "tank_spawn_probability"    "5"
//
//  // Sets Health for Tank (0=Don't modify tank health)
//  // 設置Tank血量 (0=不修改血量)
//  "tank_health"         "4000"
//
//  // 1 = Still spawn tank in final stage rescue (does not affect director tanks)
//  // 1 = 最後一關救援後插件持續生成Tank（不影響導演系統生成的Tank）
//  "tank_spawn_final"    "0"
//
//  // Sets the limit for witches spawned by the plugin (does not affect director witches)
//  // 插件可生成witch的最大數量 （不影響導演生成的witch）
//  "witch_max_limit"        "4"
//
//  // Sets the max and min spawn time for witch
//  // 插件生成witch的最大與最小時間 (秒)
//  "witch_spawn_time_max"    "120.0"
//  "witch_spawn_time_max"    "90.0"
//
//  // Amount of seconds before a witch is kicked. (only remove witches spawned by this plugin)
//  // witch生成多少秒才會踢出（不影響導演生成的witch）
//  "witch_life"        "200.0"
//
//  // 1 = Still spawn witch in final stage rescue
//  // 1 = 最後一關救援開始後插件持續生成witch
//  "witch_spawn_final"    "0"
//
//  // 1 = Infected bots spawn on the same game frame (careful, this could cause sever laggy)
//  // 1 = 允許AI特感在同一個時間點一起復活不要延遲誤差 (小心啟動，會影響伺服器卡頓)
//  "spawn_same_frame"  "0"
//
//  // Increase certain value to infected bots spawn timer based per human infected player in coop/survival/realism (0=off)
//  // 每有一位特感真人玩家，則AI特感的復活時間增加此數值 (戰役/寫實/生存模式, 0=關閉此功能)
//  "spawn_time_increase_on_human_infected" "3.0"
//
//  // 1 = Spawn special infected before survivors leave starting safe room area in coop/survival/realism
//  // 1 = 即使倖存者尚未離開安全區域，遊戲依然能生成特感 (戰役/寫實/生存模式)
//  "spawn_safe_zone"   "0"
//
//  // Where to spawn infected? 0=Near the first ahead survivor. 1=Near the random survivor
//  // 插件在哪個位置生成特感? (0=最前方倖存者附近, 1=隨機的倖存者附近)
//  "spawn_where_method"    "0"
//
//  // The minimum of spawn range for infected. (default: 550, coop/realism only)
//  // Override official convar "z_spawn_safety_range", it also affects common zombie spawn range
//  // 特感生成的最小距離 (默認: 550, 僅戰役/寫實)
//  // 覆蓋官方指令 "z_spawn_safety_range, 這個設置也會影響普通殭屍的生成範圍和真人特感玩家的靈魂狀態復活距離
//  "spawn_range_min"   "350"
//
//  // 1 = Disable infected bots spawning. Only allow humam infected players to spawn (does not disable witch spawn and not affect director spawn)
//  // 1 = 關閉特感bots生成，只允許真人特感玩家生成 (此插件會繼續生成Witch、不影響導演系統)
//  "spawn_disable_bots"  "0"
//
//  // 1 = Plugin will disable spawning infected bot when a tank is on the field. (does not affect human infected player in versus)
//  // 1 = 當Tank存活，插件停止生成特感 (不影響對抗模式的真人特感)
//  "tank_disable_spawn"  "0"
//
//  // 1 = Bots will only spawn when all other bot spawn timers are at zero.
//  // 1 = 感染者需要等待其他感染者復活時間到才能一起生成
//  "coordination"      "0"
//
//  // 1 = players can join the infected team in coop/survival/realism
//  // !ji in chat to join infected, !js to join survivors
//  // Enable this also allow game to continue with survivor bots
//  // 1 = 玩家可以在戰役/寫實/生存模式中加入感染者 (!ji加入感染者，!js加入倖存者)"
//  // 開啟此指令，即使倖存者陣營都是Bot，會強制遊戲繼續進行
//  "coop_versus_enable"    "0"
//
//  // Sets the max and min spawn time for human infected player in coop/survival/realism
//  // 插件生成真人特感玩家的最大與最小時間 (秒) (戰役/寫實/生存模式)
//  "coop_versus_spawn_time_max"    "35.0"
//  "coop_versus_spawn_time_min"    "25.0"
//
//  // 1 = Tank will always be controlled by human player in coop/survival/realism.
//  // 1 = 玩家可以在戰役/寫實/生存模式中接管Tank
//  "coop_versus_tank_playable" "0"
//
//  // 1 = Clients will be announced to on how to join the infected team in chatbox
//  // 1 = 在聊天框提示玩家如何加入到倖存者和感染者
//  "coop_versus_announce"      "1"
//
//  // Sets the limit for the amount of humans that can join the infected team in coop/survival/realism.
//  // 在戰役/倖存者/清道夫中設置通過插件加入到感染者的玩家數量
//  "coop_versus_human_limit"   "1"
//
//  // Players with these flags have access to join infected team in coop/survival/realism. (Empty = Everyone, -1: Nobody)
//  // 擁有這些權限的玩家在戰役/寫實/生存模式中可以加入到感染者 (留白 = 所有人可以加入, -1: 所有人無法加入)
//  "coop_versus_join_access"   "z"
//
//  // 1 = Attaches red flash light to human infected player in coop/survival/realism. (Make it clear which infected bot is controlled by player)
//  // 1 = 真人扮演的感染者，身體會發出紅色的動態光 (戰役/寫實/生存模式)
//  "coop_versus_human_light"   "1"
//
//  // 1 = Human infected player will spawn as ghost state in coop/survival/realism (0=Just spawn alive)
//  // 1 = 真人扮演的感染者，將以靈魂狀態復活 (戰役/寫實/生存模式)
//  "coop_versus_human_ghost"   "1"
//
//  // Cool Down in seconds human infected player can join infected team again on new round in coop/survival/realism (0=off)
//  // 真人扮演的感染者，下一個回合開始之後不能再度扮演感染者的冷卻時間 (戰役/寫實/生存模式)
//  "coop_versus_cool_down"   "60.0"
//