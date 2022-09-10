When rescue vehicle arrived and a timer will display how many time left for vehicle leaving. If a player is not on rescue vehicle or zone, slay him

-Video-
https://youtu.be/dLbNv9zNckE

-ChangeLog-
AlliedModders Post: https://forums.alliedmods.net/showpost.php?p=2725525&postcount=7
v1.4
-Original Request by darkbret.
-Thanks to Marttt and Crasher_3637.
-Works on l4d1/2 all value maps.
-Custom timer for each final map (edit data).
-Translation support
-The City Will Get Nuked After Countdown Time Passes
-Silvers F18 Airstrike

-Require-
1. left4dhooks: https://forums.alliedmods.net/showthread.php?p=2684862
2. [INC] Multi Colors: https://forums.alliedmods.net/showthread.php?t=247770

Example Config:
data/l4d_rescue_vehicle.cfg
"rescue_vehicle"
{
	"c2m5_concert"
    {
        "num"        "2"  //There are two escape Helicopters in Dark Carnival
		"time"       "60" //set timer to escape (seconds)
        "1"
        {
            "hammerid"        "792981" //find which entity is rescue vehicle entity(classname is "trigger_multiple") by dumping the map with stripper
        }
        "2"
        {
            "hammerid"        "793053" //DO NOT modify hammerid unless you know what it is
        }
    }
	
	"c7m3_port"
	{
		"num"		"0" //0=Turn off the plugin in this map
	} 
}

-Notice-
The plugin only supports all valve maps.
If you want to support custom map, find entity by yourself or pay me money

-支援的關卡-
支援一二代所有官方地圖
如果你想要支援三方地圖, 請自己利用stripper尋找物件或支付金錢

-Convars-
cfg/sourcemod/l4d_rescue_vehicle_leave_timer.cfg
// 0=Plugin off, 1=Plugin on.
l4d_rescue_vehicle_leave_timer_allow "1"

// Turn off the plugin in these maps, separate by commas (no spaces). (0=All maps, Empty = none).
l4d_rescue_vehicle_leave_timer_map_off "c7m3_port"

// Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
l4d_rescue_vehicle_leave_timer_modes ""

// Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
l4d_rescue_vehicle_leave_timer_modes_off ""

// Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
l4d_rescue_vehicle_leave_timer_modes_tog "0" 

// Changes how count down tumer hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
l4d_rescue_vehicle_leave_timer_announce_type "2"
