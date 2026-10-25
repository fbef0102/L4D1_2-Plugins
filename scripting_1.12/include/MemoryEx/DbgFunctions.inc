#if defined _MemoryEx_Debug_Functions_include_
  #endinput
#endif
#define _MemoryEx_Debug_Functions_include_

#include <MemoryEx/ServerLibrary>

static char g_sMemExDGBPath[PLATFORM_MAX_PATH];

void MemExDGB_RegCommands()
{
    RegServerCmd("sm_mem_ex_loaded_library", Cmd_MemExLoadedLibrary);

    BuildPath(Path_SM, g_sMemExDGBPath, sizeof g_sMemExDGBPath, "logs/MemoryExDGB.log");
}
public Action Cmd_MemExLoadedLibrary(int iArgs)
{
    StringMap hList = GetListLibraries();
    StringMapSnapshot hSnap = hList.Snapshot();

    char sName[64];

    ModuleInfo info;

    LogToFile(g_sMemExDGBPath, "-----------------------Cmd_MemExLoadedLibrary-----------------------");

    for(int x = 0; x < hSnap.Length; x++)
    {
        hSnap.GetKey(x, sName, sizeof sName);
        hList.GetArray(sName, info, sizeof(ModuleInfo));

        LogToFile(g_sMemExDGBPath, "Library %s base 0x%X", sName, info.base);
    }

    LogToFile(g_sMemExDGBPath, "-----------------------Cmd_MemExLoadedLibrary End-----------------------");

    delete hSnap;
}