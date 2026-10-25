#if defined _smd_report_email_included
 #endinput
#endif
#define _smd_report_email_included


native void SMD_ReportMail_Ban(const char[] sInitiatorName, const char[] sInitiatorSteamId2, const char[] sChosenPlayerName, const char[] sChosenPlayerSteamId2, const char[] sReason, int iBanMinutes);


public SharedPlugin __pl_smd_report_email = 
{
	name = "smd_report_email",
	file = "smd_report_email.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_smd_report_email_SetNTVOptional()
{
	MarkNativeAsOptional("SMD_ReportMail_Ban");
}
#endif