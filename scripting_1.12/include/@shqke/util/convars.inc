#if defined _shqke_util_convars_included
  #endinput
#endif
#define _shqke_util_convars_included

stock int Util_ConVarGetStringValue(ConVar cvar, char[] buffer, int maxlength, const char[] defaultValue = NULL_STRING)
{
    char[] value = new char[maxlength];
    cvar.GetString(value, maxlength);
    
    if (value[0] == '\0') {
        if (defaultValue[0] == '\0') {
            buffer[0] = '\0';
            
            return 0;
        }
        
        return strcopy(buffer, maxlength, defaultValue);
    }
    
    return strcopy(buffer, maxlength, value);
}
