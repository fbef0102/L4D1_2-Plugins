#if defined _gamedata_wrapper_included
    #endinput
#endif
#define _gamedata_wrapper_included

#include <sourcemod>

#define GAMEDATA_WRAPPER_VERSION "3.0.1"

/**
 * This include file was inspired by @Forgetest.
 * https://github.com/jensewe
 * 
 * Summarized and extended by: @blueblur0730.
 * https://github.com/blueblur0730
*/

enum OperatingSystem
{
    OS_UnknownPlatform = -1,
    OS_Windows = 0,
    OS_Linux = 1
}

#if defined _sdktools_included
enum struct SDKCallParamsWrapper {
    SDKType          type;
    SDKPassMethod    pass;
    int              decflags;
    int              encflags;
}

static const char k_sSDKFuncConfSource[3][] = { "Offsets", "Signatures", "Addresses" };
#endif

#if defined _actions_constructor_included
enum ActionCtorConfType {
    ConfType_ActionConstructor = 0,
    ConfType_Signatures = 1,
    ConfType_Addresses = 2
}

enum struct ActionParamsWrapper {
    ACPassType passType;
    ACPassFlags flags;
    ACEncoder encoder;
}

static const char k_sActionCstorConfSource[3][] = { "ActionConstructor", "Signatures", "Addresses" };
#endif

methodmap GameDataWrapper < GameData {
    /**
     * Loads a game config file.
     * 
     * @param file          File to load.  The path must be relative to the 'gamedata' folder under the config folder
     *                      and the extension should be omitted.
     * 
     * @return              A handle to the game config file.
     * 
     * @error               Plugin failed if the file could not be loaded.
    */
    public GameDataWrapper(const char[] file) {
        GameData gd = new GameData(file);
        if (!gd) SetFailState("[GameData] Missing gamedata of file \"%s\".", file);
        return view_as<GameDataWrapper>(gd);
    }

    /**
     * Get its original GameData handle.
     * 
     * @return The handle.
    */
    property GameData Super {
        public get() { return view_as<GameData>(this); }
    }

    /**
     * Returns the operating system of the game from the pre-set gamedata file.
     * Have to define the "OS" key in the "Offsets" section.
     * 
     * @return The enumeration to indicate the OS.
    */
    property OperatingSystem OS {
        public get() { return view_as<OperatingSystem>(this.Super.GetOffset("OS")); }
    }

	/**
	 * Returns an offset value from the "Offsets" section.
     * 
	 * @param key           Key to retrieve from the offset section.
     * 
	 * @return              An offset.
     * 
     * @error               Plugin failed if the offset could not be found.
    */
    public int GetOffset(const char[] key) {
        int offset = this.Super.GetOffset(key);
        if (offset == -1) SetFailState("[GameData] Missing offset of section \"%s\".", key);
        return offset;
    }

    /**
     * Retrives the value of a key from the "Keys" section.
     * 
     * @param key           Key to retrieve from the Keys section.
     * @param buffer        Destination string buffer.
     * @param maxlen        Maximum length of output string buffer.
     * 
     * @noreturn
     * 
     * @error               Plugin failed if the key could not be found.
    */
    public void GetKeyValue(const char[] key, char[] buffer, int maxlen) {
        bool b = this.Super.GetKeyValue(key, buffer, maxlen);
        if (!b) SetFailState("[GameData] Missing key \"%s\" in gamedata file.", key);
    }

    /**
     * Finds an address calculation in a GameConfig file's "Addresses" section,
     * performs LoadFromAddress on it as appropriate, then returns the final address.
     * 
     * @param name          Name of the property to find.
     * @return              An address calculated on success.
     * 
     * @error               Plugin failed if the address could not be found.
    */
    public Address GetAddress(const char[] key) {
        Address ptr = this.Super.GetAddress(key);
        if (ptr == Address_Null) SetFailState("[GameData] Missing address of section \"%s\".", key);
        return ptr;
    }

    /**
     * Returns a function address calculated from a signature.
     * 
     * @param name          Name of the property to find.
     * @return              An address calculated on success.
     * 
     * @error               Plugin failed if the signature could not be found.
    */
    public Address GetMemSig(const char[] key) {
        Address ptr = this.Super.GetMemSig(key);
        if (ptr == Address_Null) SetFailState("[GameData] Missing signature memory of section \"%s\".", key);
        return ptr;
    }

#if defined _sdktools_included
    /**
     * Creates a call from conf file.
     * 
     * @param type              The type of the call.
     * @param src               The source section to retrieve from the gamedata config.
     * @param name              The name of the call.
     * @param params            The parameters of the call.
     * @param numParams         The number of parameters.
     * @param hasReturnValue    Whether the call has a return value.
     * 
     * @return                  Handle of the call.
     * 
     * @error                   Plugin failed if the defined section not found, or the call failed to set up.
     **/ 
    public Handle CreateSDKCallOrFail(  SDKCallType type,
                                        SDKFuncConfSource src,
                                        const char[] name,
                                        const SDKCallParamsWrapper[] params = {},
                                        int numParams = 0,
                                        bool hasReturnValue = false,
                                        const SDKCallParamsWrapper ret = {}) {
        Handle result;
        StartPrepSDKCall(type);
        if (!PrepSDKCall_SetFromConf(this, src, name))
            SetFailState("[SDKCall] Missing key \"%s\" from section \"%s\".", name, k_sSDKFuncConfSource[src]);

        for (int i = 0; i < numParams; ++i)
            PrepSDKCall_AddParameter(params[i].type, params[i].pass, params[i].decflags, params[i].encflags);

        if (hasReturnValue)
            PrepSDKCall_SetReturnInfo(ret.type, ret.pass, ret.decflags, ret.encflags);

        if (!(result = EndPrepSDKCall()))
            SetFailState("[SDKCall] Failed to Prepare SDKCall for section \"%s\".", name);

        return result;
    }

    /**
     * Use relative call address to setup call instead of setting from conf.
     * 
     * @param type              The type of the call.
     * @param pFuncStart        The start address of the relative call function.
     * @param offset            The offset to jump back from the relative call.
     * @param params            The parameters of the call.
     * @param numParams         The number of parameters.
     * @param hasReturnValue    Whether the call has a return value.
     * @param ret               The return value of the call.
     * 
     * @returns Handle          The handle of the call.
     * 
     * @error                   Plugin failed if the address of the start of the function is NULL, or failed to set up the call.
    */
    public static Handle CreateRelativeSDKCallOrFail(   SDKCallType type,
                                                        Address pFuncStart,
                                                        int offset,
                                                        const SDKCallParamsWrapper[] params = {},
                                                        int numParams = 0,
                                                        bool hasReturnValue = false,
                                                        const SDKCallParamsWrapper ret = {}) {
        if (pFuncStart == Address_Null) 
            SetFailState("[SDKCall] Missing address of the start of the function. pFuncStart is NULL.");

        int pOri = LoadFromAddress(pFuncStart, NumberType_Int32);
        pFuncStart += view_as<Address>(pOri + offset);

        Handle result;
        StartPrepSDKCall(type);
        PrepSDKCall_SetAddress(pFuncStart);

        for (int i = 0; i < numParams; ++i)
            PrepSDKCall_AddParameter(params[i].type, params[i].pass, params[i].decflags, params[i].encflags);

        if (hasReturnValue)
            PrepSDKCall_SetReturnInfo(ret.type, ret.pass, ret.decflags, ret.encflags);

        if (!(result = EndPrepSDKCall()))
            SetFailState("[SDKCall] Failed to Prepare SDKCall for a raw address call.");

        return result;
    }

    /**
     * Use call address to setup call instead of setting from conf.
     * 
     * @param type              The type of the call.
     * @param pFuncStart        The address of the call function.
     * @param params            The parameters of the call.
     * @param numParams         The number of parameters.
     * @param hasReturnValue    Whether the call has a return value.
     * @param ret               The return value of the call.
     * 
     * @returns Handle          The handle of the call.
     * 
     * @error                   Plugin failed if the address of the start of the function is NULL, or failed to set up the call.
    */
    public static Handle CreateAddressSDKCallOrFail(    SDKCallType type,
                                                        Address pFunc,
                                                        const SDKCallParamsWrapper[] params = {},
                                                        int numParams = 0,
                                                        bool hasReturnValue = false,
                                                        const SDKCallParamsWrapper ret = {}) {
        if (pFunc == Address_Null) 
            SetFailState("[SDKCall] Missing address of the start of the function. pFuncStart is NULL.");

        Handle result;
        StartPrepSDKCall(type);
        PrepSDKCall_SetAddress(pFunc);

        for (int i = 0; i < numParams; ++i)
            PrepSDKCall_AddParameter(params[i].type, params[i].pass, params[i].decflags, params[i].encflags);

        if (hasReturnValue)
            PrepSDKCall_SetReturnInfo(ret.type, ret.pass, ret.decflags, ret.encflags);

        if (!(result = EndPrepSDKCall()))
            SetFailState("[SDKCall] Failed to Prepare SDKCall for a raw address call.");

        return result;
    }
#endif

#if defined _dhooks_included
    /**
     * Creates and sets up a detour.
     * 
     * @param name              The name of the detour setup section.
     * @param bNow              Whether to enable the detour immediately.
     * @param preHook           The pre-hook function.
     * @param postHook          The post-hook function.
     * 
     * @return                  The handle of the detour.
     * 
     * @error                   Plugin failed if the detour setup section is missing, or failed to enable the detour.
    */
    public DynamicDetour CreateDetourOrFail(const char[] name,
                                            bool bNow = true,
                                            DHookCallback preHook = INVALID_FUNCTION,
                                            DHookCallback postHook = INVALID_FUNCTION) {
        DynamicDetour hSetup = DynamicDetour.FromConf(this, name);

        if (!hSetup)
            SetFailState("[Detour] Missing detour setup section \"%s\".", name);

        if (bNow)
        {
            if (preHook != INVALID_FUNCTION && !hSetup.Enable(Hook_Pre, preHook))
                SetFailState("[Detour] Failed to pre-detour of section \"%s\".", name);

            if (postHook != INVALID_FUNCTION && !hSetup.Enable(Hook_Post, postHook))
                SetFailState("[Detour] Failed to post-detour of section \"%s\".", name);
        }

        return hSetup;
    }

    /**
     * Creates a detour and enables it immediately, and finally frees its handle. 
     * (meaning the detour will never be disabled.)
     * 
     * @param name              The name of the detour setup section.
     * @param preHook           The pre-hook function.
     * @param postHook          The post-hook function.
     * 
     * @noreturn
     * 
     * @error                   Plugin failed if the detour setup section is missing, or failed to enable the detour.
    */
    public void CreateDetourOrFailEx(   const char[] name,
                                        DHookCallback preHook = INVALID_FUNCTION,
                                        DHookCallback postHook = INVALID_FUNCTION) 
    { delete (this.CreateDetourOrFail(name, true, preHook, postHook)); }

    /**
     * Creates and sets up a dynamic hook.
     * Need to specify the hook type and target.
     * 
     * @param name              The name of the dynamic hook setup section.
     * @param type              The hook type.
     * @param entity            The target entity index if choose to hook entities.
     * @param pAdr              The target address if choose to hook raw addresses.
     * @param bNow              Whether to enable the dynamic hook immediately.
     * @param preHook           The pre-hook function. If choose to hook raw pointer addresses, only this parameter can be the callback.
     * @param postHook          The post-hook function.
     * @param removalHook       The removal hook function.
     * 
     * @return                  The handle of the dynamic hook.
     * 
     * @error                   Plugin failed if the dynamic hook setup section is missing, or failed to enable the dynamic hook.
    */
    public DynamicHook CreateDynamicHookOrFail( const char[] name,
                                                HookType type = HookType_Entity,
                                                int entity = -1,
                                                Address pAdr = Address_Null,
                                                bool bNow = true,
                                                DHookCallback preHook = INVALID_FUNCTION,
                                                DHookCallback postHook = INVALID_FUNCTION,
                                                DHookRemovalCB removalHook = INVALID_FUNCTION) {
        DynamicHook hSetup = DynamicHook.FromConf(this, name);

        if (!hSetup) SetFailState("[DHooks] Missing dynamic hook setup section \"%s\".", name);

        if (!bNow) return hSetup;

        switch (type)
        {
            case HookType_Entity:
            {
                if (entity <= 0) SetFailState("[DHooks] Invalid entity index, index: %d.", entity);

                if (preHook != INVALID_FUNCTION && !hSetup.HookEntity(Hook_Pre, entity, preHook, removalHook))
                    SetFailState("[DHooks] Failed to pre-hook section \"%s\".", name);

                if (postHook != INVALID_FUNCTION && !hSetup.HookEntity(Hook_Post, entity, postHook, removalHook))
                    SetFailState("[DHooks] Failed to post-hook section \"%s\".", name);
            }
            
            case HookType_GameRules:
            {
                if (preHook != INVALID_FUNCTION && !hSetup.HookGamerules(Hook_Pre, preHook, removalHook))
                    SetFailState("[DHooks] Failed to pre-hook section \"%s\".", name);

                if (postHook != INVALID_FUNCTION && !hSetup.HookGamerules(Hook_Post, postHook, removalHook))
                    SetFailState("[DHooks] Failed to post-hook section \"%s\".", name);
            }

            case HookType_Raw:
            {
                if (pAdr == Address_Null) SetFailState("[DHooks] Invalid address. The address is NULL.");
                
                if (preHook != INVALID_FUNCTION && !hSetup.HookRaw(Hook_Pre, pAdr, preHook))
                    SetFailState("[DHooks] Failed to hook section \"%s\".", name);
            }
        }

        return hSetup;
    }

    /**
     * Creates and sets up a dynamic hook, enables it immediately and finally frees its handle.
     * Need to specify the hook type and target.
     * 
     * @param name              The name of the dynamic hook setup section.
     * @param type              The hook type.
     * @param entity            The target entity index if choose to hook entities.
     * @param pAdr              The target address if choose to hook raw addresses.
     * @param bNow              Whether to enable the dynamic hook immediately.
     * @param preHook           The pre-hook function. If choose to hook raw pointer addresses, only this parameter can be the callback.
     * @param postHook          The post-hook function.
     * @param removalHook       The removal hook function.
     * 
     * @return                  The handle of the dynamic hook.
     * 
     * @error                   Plugin failed if the dynamic hook setup section is missing, or failed to enable the dynamic hook.
    */
    public DynamicHook CreateDynamicHookOrFailEx(   const char[] name,
                                                    HookType type,
                                                    int entity = -1,
                                                    Address pAdr = Address_Null,
                                                    DHookCallback preHook = INVALID_FUNCTION,
                                                    DHookCallback postHook = INVALID_FUNCTION,
                                                    DHookRemovalCB removalHook = INVALID_FUNCTION) 
    { delete (this.CreateDynamicHookOrFail(name, type, entity, pAdr, true, preHook, postHook, removalHook)); }
#endif

#if defined __sourcescramble_ext_included
    /**
     * Creates a new memory patch for the given name of section "MemPatches".
     * Handle must be freed and patch should be disabled if not use anymore.
     * 
     * @note Function returns the handle to the patch, once the handle gets freed, the patch is disabled.
     * @note Unlike dhook, this is probably a safty consideration.
     * 
     * @param name              The name of the memory patch section.
     * @param enable            Whether to enable the memory patch immediately.
     * 
     * @return                  The handle of the memory patch.
     * 
     * @error                   Plugin failed if the memory patch section is missing, or failed to enable patch or validate the target memory address.
    */
    public MemoryPatch CreateMemoryPatchOrFail(const char[] name, bool enable = false) {
        MemoryPatch hPatch = MemoryPatch.CreateFromConf(this, name);
        if (!hPatch) SetFailState("[MemoryPatch] Failed to create memory patch for section \"%s\".", name);

        if (!(enable ? hPatch.Enable() : hPatch.Validate()))
            SetFailState("[MemoryPatch] Failed to %s section \"%s\" through source scramble.", enable ? "patch" : "validate", name);

        return hPatch;
    }

    /**
     * Allocates a fixed amount of memeory by reading the size from gamedata section "Offests".
     * Size is in bytes, handle and its content must be freed manually.
     * 
     * @param name              The name of the "Offsets" section.
     * 
     * @return                  The handle to the allocated memory.
     * 
     * @error                   Plugin failed if the section is missing, or failed to allocate the memory.
    */
    public MemoryBlock CreateMemoryBlockOrFail(const char[] name) {
        int iOff = this.Super.GetOffset(name);
        MemoryBlock hBlock = new MemoryBlock(iOff);
        if (!hBlock) SetFailState("[MemoryBlock] Failed to create memory block for section \"%s\".", name);
        return hBlock;
    }

    /**
     * Allocates a fixed amount of memeory by the given size.
     * Size is in bytes, handle and its content must be freed manually.
     * 
     * @param iOff              The size in bytes to be allocated.
     * 
     * @return                  The handle to the allocated memory.
     * 
     * @error                   Plugin failed if the section is missing, or failed to allocate the memory.
    */
    public static MemoryBlock CreateMemoryBlockOrFailEx(int iOff) {
        MemoryBlock hBlock = new MemoryBlock(iOff);
        if (!hBlock) SetFailState("[MemoryBlock] Failed to create memory block for the given size: \"%d\".", iOff);
        return hBlock;
    }
#endif

#if defined _midhook_included
    /**
     * Creates a new midhook for the given name of gamedata section "Addresses".
     * Handle must be freed manually if not use.
     * 
     * @note Function returns the handle to the hook, once the handle gets freed, the hook is disabled.
     * @note Unlike dhook, this is probably a safty consideration.
     * 
     * @param name              The name of the "Addresses" section.
     * @param callback          The callback to be called when the hook is triggered.
     * @param enable            Whether to enable the midhook immediately.
     * 
     * @return                  The handle of the midhook.
     * 
     * @error                   Plugin failed if the section is missing, or failed to create the midhook.
    */
    public MidHook CreateMidHookOrFail(const char[] name, MidHookCB callback, bool enable = true) {
        Address pAdr = this.GetAddress(name);
        if (pAdr == Address_Null) SetFailState("[MidHooks] Failed to find address for section \"%s\".", name);

        MidHook hHook = new MidHook(pAdr, callback, enable);
        if (!hHook) SetFailState("[MidHooks] Failed to create Midhook for section \"%s\".", name);
        return hHook;
    }

    /**
     * Creates a new midhook for the given address.
     * Handle must be freed manually if not use.
     * 
     * @note Function returns the handle to the hook, once the handle gets freed, the hook is disabled.
     * @note Unlike dhook, this is probably a safty consideration.
     * 
     * @param pAdr              The address to hook.
     * @param callback          The callback to be called when the hook is triggered.
     * @param enable            Whether to enable the midhook immediately.
     * 
     * @return                  The handle of the midhook.
     * 
     * @error                   Plugin failed if failed to create the midhook.
    */
    public static MidHook CreateMidHookOrFailEx(Address pAdr, MidHookCB callback, bool enable = true) {
        if (pAdr == Address_Null) SetFailState("[MidHooks] The given address is NULL.");

        MidHook hHook = new MidHook(pAdr, callback, enable);
        if (!hHook) SetFailState("[MidHooks] Failed to create Midhook for the given address. Address: \"0x%x\", \"%d\"", pAdr, pAdr);
        return hHook;
    }
#endif

#if defined _actions_constructor_included
    /**
     * Create a new action constructor.
     * Handle must be freed manually.
     * 
     * @param type              The type of the config to setup.
     * @param key               The section name.
     * @param params            The parametaers to fill in if need. Only use when using ConfType_Signatures, ConfType_Addresses.
     * @param numParams         Number of parametaers.
     * 
     * @return                  An action constructor handle.
     * 
     * @error                   Plugin failed if failed to create action constructor.
    */
    public ActionConstructor CreateActionConstructorOrFailed(   ActionCtorConfType type, 
                                                                const char[] key, 
                                                                const ActionParamsWrapper[] params = {}, 
                                                                int numParams = 0) {
        switch (type) {
            case ConfType_ActionConstructor: {
                ActionConstructor ctor = ActionConstructor.SetupFromConf(this, key);
                if (!ctor) SetFailState("[ActionConstructor]: Faied to create action constructor with the given key: \"%s\" on section: \"%s\"", key, k_sActionCstorConfSource[type]);
            }

            case ConfType_Signatures, ConfType_Addresses: {
                ActionConstructor ctor = new ActionConstructor();
                if (!ctor) SetFailState("[ActionConstructor]: Failed to create a new ActionConstructor handle.");
                if (type == ConfType_Signatures) {
                    if (!ctor.SignatureFromConf(this, key)) SetFailState("[ActionConstructor]: Failed to set up action constructor with the given key: \"%s\" on section: \"%s\"", key, k_sActionCstorConfSource[type]);
                } else if (type == ConfType_Addresses) {
                    if (!ctor.AddressesFromConf(this, key)) SetFailState("[ActionConstructor]: Failed to set up action constructor with the given key: \"%s\" on section: \"%s\"", key, k_sActionCstorConfSource[type]);
                }
                
                for (int i = 0; i < numParams; ++i) {
                    if (!ctor.AddParameter(params[i].passType, params[i].flags, params[i].encoder))
                        SetFailState("[ActionConstructor]: Failed to add parameters for action constructor with the given key: \"%s\" on section: \"%s\" of parameters: num: \"%d\", passType: \"%d\", flags: \"%d\", encoder: \"%d\"", key, k_sActionCstorConfSource[type], i, params[i].passType, params[i].flags, params[i].encoder);
                }

                if (!ctor.Finish()) {
                    SetFailState("[ActionConstructor]: Failed to finish set up for action constructor.");
                }
            }
        }

        return ctor;
    }
#endif
}

#if defined __sourcescramble_ext_included && defined _midhook_included
stock MidHook PatchToMidHook(MemoryPatch hPatch, int iOff, MidHookCB callback, bool enable = true) {
    if (!hPatch) SetFailState("[MidHooks] Failed to create Midhook for the given patch.");

    Address pAdr = hPatch.Address + view_as<Address>(iOff);
    if (pAdr == Address_Null) SetFailState("[MidHooks] The given address is NULL.");

    MidHook hHook = new MidHook(pAdr, callback, enable);
    if (!hHook) SetFailState("[MidHooks] Failed to create Midhook for the given address.");

    return hHook;
}
#endif