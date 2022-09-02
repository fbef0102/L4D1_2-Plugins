Keep track of players' lerp settings

-Changelog-
v1.1
-Remake Code

v1.0
-Original Post: https://forums.alliedmods.net/showthread.php?t=149333

-ConVar-
// Announce changes to client lerp. 1=Announce initial lerp and changes 2=Announce changes only
sm_announce_lerp "1"

// Fix Lerp values clamping incorrectly when interp_ratio 0 is allowed
sm_fixlerp "1"

// Display Style, 0 = default, 1 = team based
sm_lerpstyle "1"

// Log changes to client lerp. 1=Log initial lerp and changes 2=Log changes only
sm_log_lerp "1"

// Kick players whose settings breach this Hard upper-limit for player lerps.
sm_max_interp "0.5"

// Maximum allowed lerp value, 超過踢到旁觀
sm_max_lerp "0.1"

// Minimum allowed lerp value
sm_min_lerp "0.000"
