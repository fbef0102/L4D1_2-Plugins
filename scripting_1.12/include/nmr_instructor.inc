#if defined _nmr_instructor_included_
  #endinput
#endif
#define _nmr_instructor_included_

#include <sourcemod>

#define ICON_BULB "icon_bulb"
#define ICON_CAUTION "icon_caution"
#define ICON_ALERT "icon_alert"
#define ICON_ALERT_RED "icon_alert_red"
#define ICON_TIP "icon_tip"
#define ICON_SKULL "icon_skull"
#define ICON_NO "icon_no"
#define ICON_RUN "icon_run"
#define ICON_INTERACT "icon_interact"
#define ICON_BUTTON "icon_button"
#define ICON_DOOR "icon_door"
#define ICON_ARROW_PLAIN "icon_arrow_plain"
#define ICON_ARROW_PLAIN_WHITE_DN "icon_arrow_plain_white_dn"
#define ICON_ARROW_PLAIN_WHITE_UP "icon_arrow_plain_white_up"
#define ICON_ARROW_UP "icon_arrow_up"
#define ICON_ARROW_RIGHT "icon_arrow_right"
#define ICON_FIRE "icon_fire"
#define ICON_PRESENT "icon_present"
#define ICON_BINDING "use_binding"

#define LOCATOR_ICON_FX_PULSE_SLOW		0x00000001
#define LOCATOR_ICON_FX_ALPHA_SLOW		0x00000008
#define LOCATOR_ICON_FX_SHAKE_NARROW	0x00000040
#define LOCATOR_ICON_FX_STATIC			0x00000100	// This icon draws at a fixed location on the HUD.

stock void SendInstructorHint(int client, const char[] hintName, const char[] hintReplaceKey,
    int hintTarget, int hintActivatorUserId, int hintTimeout,
    const char[] hintIconOnScreen, const char[] hintIconOffScreen,
    const char[] hintCaption, const char[] hintActivatorCaption,
    int r, int g, int b, float hintIconOffset, float hintRange,
    int hintFlags, const char[] hintBinding, bool hintAllowNoDrawTarget,
    bool hintNoOffscreen, bool hintForceCaption, bool hintLocalPlayerOnly,
    const char[] hintStartSound, int hintTargetPos)
{
    Event event = CreateEvent("instructor_server_hint_create", true);
    event.SetString("hint_name", hintName);
    event.SetString("hint_replace_key", hintReplaceKey);
    event.SetInt("hint_target", hintTarget);
    event.SetInt("hint_activator_userid", hintActivatorUserId);
    event.SetInt("hint_timeout", hintTimeout);
    event.SetString("hint_icon_onscreen", hintIconOnScreen);
    event.SetString("hint_icon_offscreen", hintIconOffScreen);
    event.SetString("hint_caption", hintCaption);
    event.SetString("hint_activator_caption", hintActivatorCaption);

    char hintColor[12];
    FormatEx(hintColor, sizeof(hintColor), "%d,%d,%d",r,g,b);
    event.SetString("hint_color", hintColor);

    event.SetFloat("hint_icon_offset", hintIconOffset);
    event.SetFloat("hint_range", hintRange);
    event.SetInt("hint_flags", hintFlags);
    event.SetString("hint_binding", hintBinding);
    event.SetBool("hint_allow_nodraw_target", hintAllowNoDrawTarget);
    event.SetBool("hint_nooffscreen", hintNoOffscreen);
    event.SetBool("hint_forcecaption", hintForceCaption);
    event.SetBool("hint_local_player_only", hintLocalPlayerOnly);
    event.SetString("hint_start_sound", hintStartSound);
    event.SetInt("hint_target_pos", hintTargetPos);
    event.FireToClient(client);
    event.Cancel();
}

stock void RemoveInstructorHint(int client, const char[] hintName)
{
    Event event = CreateEvent("instructor_server_hint_stop", true);
    event.SetString("hint_name", hintName);
    event.FireToClient(client);
    event.Cancel();	
}