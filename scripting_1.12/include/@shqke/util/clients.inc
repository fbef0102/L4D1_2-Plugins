#if defined _shqke_util_clients_included
  #endinput
#endif
#define _shqke_util_clients_included

stock int Util_ClientsConnected(bool bCountBots = false)
{
    int count = 0;

    for (int i = 1; i <= MaxClients; i ++) {
        if (!IsClientConnected(i)) {
            continue;
        }
        
        if (!bCountBots && IsFakeClient(i)) {
            continue;
        }
        
        if (IsClientSourceTV(i)) {
            continue;
        }
        
        count ++;
    }

    return count;
}
