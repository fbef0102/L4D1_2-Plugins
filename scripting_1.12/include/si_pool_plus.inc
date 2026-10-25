/*
 * @Author: 我是派蒙啊
 * @Last Modified by:   我是派蒙啊
 * @Create Date: 2024-02-17 18:11:22
 * @Last Modified time: 2024-11-17 10:21:30
 * @Github: https://github.com/Paimon-Kawaii
 */

#if defined _sipool_included_
    #endinput
#endif
#define _sipool_included_

public SharedPlugin __pl_sipool = {
    name = "si_pool_plus",
    file = "si_pool_plus.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

public void __pl_sipool_SetNTVOptional()
{
    MarkNativeAsOptional("SIPool.Instance");

    MarkNativeAsOptional("SIPool.RequestSIBot");
    MarkNativeAsOptional("SIPool.ReturnSIBot");
}

// Provided by "BHaType":
// For the "L4D_State_Transition" native
// X -> Y (means X state will become Y state on next frame or some seconds later)
#define STATE_ACTIVE             0
#define STATE_WELCOME            1    // -> STATE_PICKING_TEAM
#define STATE_PICKING_TEAM       2
#define STATE_PICKINGCLASS       3    // -> STATE_ACTIVE
#define STATE_DEATH_ANIM         4    // -> STATE_DEATH_WAIT_FOR_KEY
#define STATE_DEATH_WAIT_FOR_KEY 5    // -> STATE_OBSERVER_MODE
#define STATE_OBSERVER_MODE      6
#define STATE_WAITING_FOR_RESCUE 7
#define STATE_GHOST              8
#define STATE_INTRO_CAMERA       9

methodmap SIPool __nullable__
{
    public static native SIPool Instance();

    /**
     * Request a Special infected Bot from SIPool
     *
     * @param zclass    Zombie class
     * @param origin    Position to spawn
     * @param angle    Angle that zombie look at
     * @return          Client index
     */
    public native int RequestSIBot(int zclass, const float origin[3] = NULL_VECTOR, const float angle[3] = NULL_VECTOR);
    
    /**
     * Return a Special infected Bot to SIPool
     * Bot will automatically return after dead
     *
     * @param client    Zombie Bot to return
     * @return          True if success, false otherwise
     */
    public native bool ReturnSIBot(int client);
}