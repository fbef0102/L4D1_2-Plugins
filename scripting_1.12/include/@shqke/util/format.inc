#if defined _shqke_util_format_included
  #endinput
#endif
#define _shqke_util_format_included

stock bool Util_IsCharTimeSpecifier(char c)
{
    if (c < 'A' || c > 'z') {
        return false;
    }
    
    if (c > 'Z' && c < 'a') {
        return false;
    }
    
    switch (c) {
        case 'E', 'f', 'i', 'J', 'K', 'k', 'l', 'L', 'N', 'O', 'o', 'P', 'Q', 'q', 's', 'v':
        {
            return false;
        }
    }
    
    return true;
}

stock int Util_FormatBytes(char[] buffer, int maxlength, int bytes)
{
    int units = bytes;
    if (units > 1000) {
        units /= 1000;
        if (units > 1000) {
            units /= 1000;
            if (units > 1000) {
                units /= 1000;
                
                return Format(buffer, maxlength, "%dGB", units);
            }
            
            return Format(buffer, maxlength, "%dMB", units);
        }
        
        return Format(buffer, maxlength, "%dKB", units);
    }
    
    return Format(buffer, maxlength, "%dB", units);
}

stock int Util_FormatSeconds(char[] buffer, int maxlength, int seconds)
{
    int pos = 0;
    
    int minutes = 0;
    int hours = 0;
    int days = 0;
    
    if (seconds > 60) {
        minutes = seconds / 60;
        seconds -= minutes * 60;
        
        if (minutes > 60) {
            hours = minutes / 60;
            minutes -= hours * 60;
            
            if (hours > 24) {
                days = hours / 24;
                hours -= days * 24;
                
                pos += Format(buffer[pos], maxlength - pos, "%dday%s ", days, days > 1 ? "s" : "");
            }
            
            pos += Format(buffer[pos], maxlength - pos, "%dhr%s ", hours, hours > 1 ? "s" : "");
        }
        
        pos += Format(buffer[pos], maxlength - pos, "%dmin%s ", minutes, minutes > 1 ? "s" : "");
    }
    
    pos += Format(buffer[pos], maxlength - pos, "%dsec", seconds);
    
    return pos;
}
