#if defined _imatchext_included
 #endinput
#endif
#define _imatchext_included

forward void OnMissionCacheReload();

/**
 * Copies game server details information into given KeyValues at the current position.
 *
 * @param kvDest        Handle to copy KeyValues data into.
 * @param kvRequest     Optional handle to extend server details with.
 * @return              True if data was found, false otherwise.
 * @error               Invalid or corrupt Handle. 
 */
native bool GetServerGameDetails(Handle kvDest, Handle kvRequest = null);

/**
 * Gets reservation cookie (lobby id).
 *
 * @param xuidReserve   Array to store the 64bit reservation cookie in.
 * @return              False if internal error.
 */
native bool GetReservationCookie(int cookie[2]);

/**
 * Copies missions information into given KeyValues at the current position.
 *
 * @param kvDest        Handle to copy KeyValues data into.
 * @return              True if data was found, false otherwise.
 * @error               Invalid or corrupt Handle.
 */
native bool GetAllMissions(Handle kvDest);

/**
 * Finds chapter and mission information by game mode, campaign name and chapter number, copies them into respective given KeyValues at their current positions.
 * A KeyValues kvRequest argument must contain following structure:
 * {
 *     "game"
 *     {
 *         "mode" "coop"
 *         "campaign" "L4D2C1"
 *         "chapter" "1"
 *     }
 * }
 *
 * @param kvRequest     Handle to KeyValues tree to find map info by.
 * @param kvMapInfo     Optional handle to copy KeyValues map info into.
 * @param kvMissionInfo Optional handle to copy KeyValues mission info into.
 * @return              True if map was found, false otherwise.
 * @error               Invalid or corrupt Handle.
 */
native bool GetMapInfo(Handle kvRequest, Handle kvMapInfo = null, Handle kvMissionInfo = null);

/**
 * Finds chapter and mission information by map file name and game mode, copies them into respective given KeyValues at their current positions.
 *
 * @param bspName       Name of the map file name without extension.
 * @param gameMode      Name of game mode, or NULL_STRING to use current.
 * @param kvMapInfo     Optional handle to copy KeyValues map info into.
 * @param kvMissionInfo Optional handle to copy KeyValues mission info into.
 * @return              True if map was found, false otherwise.
 * @error               Invalid or corrupt Handle.
 */
native bool GetMapInfoByBspName(const char[] bspName, const char[] gameMode = NULL_STRING, Handle kvMapInfo = null, Handle kvMissionInfo = null);

/**
 * (Left 4 Dead 2 only) Copies all game modes information into given KeyValues at the current position.
 *
 * @param kvDest        Handle to copy KeyValues data into.
 * @return              True if data was found, false otherwise.
 * @error               Invalid or corrupt Handle.
 */
native bool GetAllModes(Handle kvDest);

/**
 * (Left 4 Dead 2 only) Copies game mode information into given KeyValues at the current position.
 *
 * @param kvDest        Optional handle to copy KeyValues data into.
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if game mode was found, false otherwise.
 * @error               Invalid or corrupt Handle.
 */
native bool GetGameModeInfo(Handle kvDest = null, const char[] name = NULL_STRING);

/**
 * Returns if game mode is using single chapters.
 *
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if game mode uses single chapters, false otherwise.
 */
native bool IsSingleChapterMode(const char[] name = NULL_STRING);

/**
 * Returns if game mode is based on coop.
 *
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if coop game mode used as base, false otherwise.
 */
native bool IsCoopMode(const char[] name = NULL_STRING);

/**
 * Returns if game mode is based on realism.
 *
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if realism game mode used as base, false otherwise.
 */
native bool IsRealismMode(const char[] name = NULL_STRING);

/**
 * Returns if game mode is based on versus.
 *
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if versus game mode used as base, false otherwise.
 */
native bool IsVersusMode(const char[] name = NULL_STRING);

/**
 * Returns if game mode is based on survival.
 *
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if survival game mode used as base, false otherwise.
 */
native bool IsSurvivalMode(const char[] name = NULL_STRING);

/**
 * Returns if game mode is based on scavenge.
 *
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if scavenge game mode used as base, false otherwise.
 */
native bool IsScavengeMode(const char[] name = NULL_STRING);

/**
 * Returns if game mode has player controlled zombies.
 *
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if game mode has player controlled zombies, false otherwise.
 */
native bool HasPlayerControlledZombies(const char[] name = NULL_STRING);

/**
 * Returns if game mode has configurable difficulty setting.
 *
 * @param name          Name of game mode, or NULL_STRING to use current.
 * @return              True if game mode has configurable difficulty setting, false otherwise.
 */
native bool HasConfigurableDifficultySetting(const char[] name = NULL_STRING);

/**
 * Returns if current map is first in mission scenario.
 *
 * @return              True if current map is first in mission scenario, false otherwise.
 */
native bool IsFirstMapInScenario();

/**
 * Returns if current map is last in mission scenario.
 *
 * @return              True if current map is last in mission scenario, false otherwise.
 */
native bool IsMissionFinalMap();

// Helpers
enum SurvivorSet
{
    SurvivorSet_L4D2 = 2,           /**< Left 4 Dead 2 and Left 4 Dead 1 characters */
    SurvivorSet_L4D1 = 1,           /**< Left 4 Dead 1 characters */
};

enum MissionSymbol
{
    MissionSymbol_Invalid = -1,
};

methodmap MissionSymbol
{
    /**
     * Returns true if mission is soft disabled.
     *
     * @return              True if mission is soft disabled, false otherwise.
     */
    property bool IsDisabled
    {
        public native get();
    }

    property bool IsAddon
    {
        public native get();
    }

    property bool AllowCola
    {
        public native get();
    }

    property bool NoFemaleBoomers
    {
        public native get();
    }

    property bool NoCSWeapons
    {
        public native get();
    }

    property SurvivorSet SurvivorSet
    {
        public native get();
    }

    /**
     * Retrieves short identifier of mission, e.g. (L4D2) "L4D2C1", "L4D2C13", (L4D1) "Hospital".
     * 
     * @param buffer        Buffer to store name in.
     * @param maxlength     Maximum length of the value buffer.
     * @return              Number of bytes written.
     */
    public native int GetName(char[] buffer, int maxlength);

    /**
     * Retrieves a string value for a given mission subkey.
     *  
     * @param key           Name of the key.
     * @param buffer        Buffer to store key value in.
     * @param maxlength     Maximum length of the value buffer.
     * @param defvalue      Optional default value to use if the key is not found.
     * @return              Number of bytes written.
     */
    public native int GetString(const char[] key, char[] buffer, int maxlength, const char[] defvalue = NULL_STRING);

    /**
     * Copies mission data into given KeyValues at the current position.
     *
     * @param kvDest        Handle to copy KeyValues data into.
     */
    public native void Export(KeyValues kvDest);

    /**
     * Obtain first mission symbol for iteration.
     *
     * @return              First MissionSymbol.
     */
    public static native MissionSymbol First();

    /**
     * Next mission symbol for iteration.
     *
     * @return              Next MissionSymbol.
     */
    public native MissionSymbol Next();

    /**
     * Checks whether given MissionSymbol is valid (corresponding mission exists).
     *
     * @param key           MissionSymbol to check existence of.
     * @return              True if mission is valid, false otherwise.
     */
    public static native bool IsValid(MissionSymbol mission);
};

/**
 * Retrieve MissionSymbol from given game mode name.
 *
 * @param name          Mission name to look for.
 * @return              MissionSymbol value, or MissionSymbol_Invalid if mission was not found.
 */
native MissionSymbol GetMissionSymbol(const char[] name);

enum ModeSymbol
{
    ModeSymbol_Invalid = -1,
};

methodmap ModeSymbol
{
    /**
     * Returns true if mode is soft disabled.
     *
     * @return              True if mode is soft disabled, false otherwise.
     */
    property bool IsDisabled
    {
        public native get();
    }

    property ModeSymbol Base
    {
        public native get();
    }

    property bool IsAddon
    {
        public native get();
    }

    property int MaxPlayers
    {
        public native get();
    }

    property bool HasPlayerControlledZombies
    {
        public native get();
    }

    property bool HasConfigurableDifficultySetting
    {
        public native get();
    }

    property bool IsSingleChapterMode
    {
        public native get();
    }

    /**
     * Retrieves short identifier of game mode, e.g. "coop", "survival", "versus".
     * 
     * @param buffer        Buffer to store name in.
     * @param maxlength     Maximum length of the value buffer.
     * @return              Number of bytes written.
     */
    public native int GetName(char[] buffer, int maxlength);

    /**
     * Retrieves a string value for a given mode subkey.
     * 
     * @param key           Name of the key.
     * @param buffer        Buffer to store key value in.
     * @param maxlength     Maximum length of the value buffer.
     * @param defvalue      Optional default value to use if the key is not found.
     * @return              Number of bytes written.
     */
    public native int GetString(const char[] key, char[] buffer, int maxlength, const char[] defvalue = NULL_STRING);

    /**
     * Copies mission data into given KeyValues at the current position.
     *
     * @param kvDest        Handle to copy KeyValues data into.
     */
    public native void Export(KeyValues kvDest);

    public native int GetNumChapters(MissionSymbol mission);
    public native bool ExportChapter(MissionSymbol mission, int chapter, KeyValues kvDest = null);
    public native bool ExportChapterByFile(const char[] bspName, MissionSymbol &mission = MissionSymbol_Invalid, int &chapter = 0, KeyValues kvDest = null);

    /**
     * Obtain first mode symbol for iteration.
     *
     * @return              First ModeSymbol.
     */
    public static native ModeSymbol First();

    /**
     * Next mode symbol for iteration.
     *
     * @return              Next ModeSymbol.
     */
    public native ModeSymbol Next();

    /**
     * Checks whether given ModeSymbol is valid (corresponding game mode exists).
     *
     * @param key           ModeSymbol to check existence of.
     * @return              True if mode is valid, false otherwise.
     */
    public static native bool IsValid(ModeSymbol mode);
};

/**
 * Retrieve ModeSymbol from given game mode name.
 *
 * @param name          Game mode name to look for.
 * @return              ModeSymbol value, or ModeSymbol_Invalid if game mode was not found.
 */
native ModeSymbol GetModeSymbol(const char[] name);

/** @var ModeSymbol Current mode symbol, or ModeSymbol_Invalid on internal error. */
public const ModeSymbol CurrentMode;

/** @var MissionSymbol Current mission symbol, or MissionSymbol_Invalid if not found. */
public const MissionSymbol CurrentMission;

public Extension __ext_imatchext =
{
    name = "[L4D/2] Matchmaking Extension Interface",
    file = "imatchext.ext",
#if defined AUTOLOAD_EXTENSIONS
    autoload = 1,
#else
    autoload = 0,
#endif
    required = 0,
};

public void __ext_imatchext_SetNTVOptional()
{
#if !defined REQUIRE_EXTENSIONS
    MarkNativeAsOptional("GetServerGameDetails");
    MarkNativeAsOptional("GetAllMissions");
    MarkNativeAsOptional("GetMapInfo");
    MarkNativeAsOptional("GetMapInfoByBspName");

    MarkNativeAsOptional("IsSingleChapterMode");
    MarkNativeAsOptional("IsCoopMode");
    MarkNativeAsOptional("IsRealismMode");
    MarkNativeAsOptional("IsVersusMode");
    MarkNativeAsOptional("IsSurvivalMode");
    MarkNativeAsOptional("IsScavengeMode");
    MarkNativeAsOptional("HasPlayerControlledZombies");
    MarkNativeAsOptional("HasConfigurableDifficultySetting");
    MarkNativeAsOptional("IsFirstMapInScenario");
    MarkNativeAsOptional("IsMissionFinalMap");
#endif
    MarkNativeAsOptional("GetAllModes");
    MarkNativeAsOptional("GetGameModeInfo");

#if !defined REQUIRE_EXTENSIONS
    MarkNativeAsOptional("MissionSymbol.GetName");
    MarkNativeAsOptional("MissionSymbol.GetString");
    MarkNativeAsOptional("MissionSymbol.Export");
    MarkNativeAsOptional("MissionSymbol.IsDisabled.get");
    MarkNativeAsOptional("MissionSymbol.IsAddon.get");
    MarkNativeAsOptional("MissionSymbol.AllowCola.get");
    MarkNativeAsOptional("MissionSymbol.NoFemaleBoomers.get");
    MarkNativeAsOptional("MissionSymbol.NoCSWeapons.get");
    MarkNativeAsOptional("MissionSymbol.SurvivorSet.get");
    MarkNativeAsOptional("MissionSymbol.Next");
    MarkNativeAsOptional("MissionSymbol.First");
    MarkNativeAsOptional("MissionSymbol.IsValid");
    MarkNativeAsOptional("GetMissionSymbol");
#endif

    MarkNativeAsOptional("ModeSymbol.GetName");
    MarkNativeAsOptional("ModeSymbol.GetString");
    MarkNativeAsOptional("ModeSymbol.Export");
    MarkNativeAsOptional("ModeSymbol.IsDisabled.get");
    MarkNativeAsOptional("ModeSymbol.Base.get");
    MarkNativeAsOptional("ModeSymbol.IsAddon.get");
    MarkNativeAsOptional("ModeSymbol.MaxPlayers.get");
    MarkNativeAsOptional("ModeSymbol.HasPlayerControlledZombies.get");
    MarkNativeAsOptional("ModeSymbol.HasConfigurableDifficultySetting.get");
    MarkNativeAsOptional("ModeSymbol.IsSingleChapterMode.get");
    MarkNativeAsOptional("ModeSymbol.GetNumChapters");
    MarkNativeAsOptional("ModeSymbol.GetChapter");
    MarkNativeAsOptional("ModeSymbol.GetChapterByFile");
    MarkNativeAsOptional("ModeSymbol.Next");
    MarkNativeAsOptional("ModeSymbol.First");
    MarkNativeAsOptional("ModeSymbol.IsValid");
    MarkNativeAsOptional("GetModeSymbol");
}
