#if defined _shqke_util_string_included
  #endinput
#endif
#define _shqke_util_string_included

stock void Util_LowerCase(char[] str)
{
    for (int i = 0; str[i] != '\0'; i ++) {
        if (str[i] >= 'A' && str[i] <= 'Z') {
            str[i] |= 0x20;
        }
    }
}
