/**
 * No these bug in l4d1
 * Bug 1: Fixed gas cans being unable to ignite after being extinguished while held by survivors.
 * Bug 2: If a gas can comes into contact with flames and starts burning within 0.5 seconds of spawning, the game grants it an additional 20-second protection period (defined by the official cvar 'scavenge_item_respawn_delay'), during which it cannot be ignited by fire.
 *        However, due to poorly written official code, every gas can spawned afterward is also incorrectly given this 20-second protection period.
 * 
 * 一代沒有這些bug
 * Bug 1: 倖存者拿走正在被點燃的汽油桶，當手上的汽油桶被滅火之後，該汽油桶已無法再被任何火焰點燃
 * Bug 2: 汽油桶生成的0.5秒內碰到火焰燃燒時，遊戲會給予汽油桶額外的20秒保護時間(時間由官方指令'scavenge_item_respawn_delay'決定)不會被火焰點燃。
 *        但是因為官方代碼寫太爛導致往後生成的每一個汽油桶都被賦予了20秒保護期
 */

/*
CGasCan - weapon_gascan
- m_OnKilled (Offset 6156) (Save|Key|Output)(0 Bytes) - OnKilled
- CGasCanClearDetonateTimer (Offset 0) (FunctionTable)(0 Bytes)
- m_bVulnerableToSpit (Offset 6196) (Save)(1 Bytes)
- m_iExtraPrimaryAmmo (Offset 5364) (Save)(4 Bytes)
- CWeaponCSBaseFallThink (Offset 0) (FunctionTable)(0 Bytes)
- CWeaponCSBaseRemovalThink (Offset 0) (FunctionTable)(0 Bytes)
- m_flNextPrimaryAttack (Offset 5104) (Save)(4 Bytes)
- m_flNextSecondaryAttack (Offset 5108) (Save)(4 Bytes)
- m_flTimeWeaponIdle (Offset 5152) (Save)(4 Bytes)
- m_bInReload (Offset 5197) (Save)(1 Bytes)
- m_bFireOnEmpty (Offset 5198) (Save)(1 Bytes)
- m_hOwner (Offset 5096) (Save)(4 Bytes)
- m_iState (Offset 5128) (Save)(4 Bytes)
- m_iszName (Offset 5192) (Save)(4 Bytes)
- m_iPrimaryAmmoType (Offset 5132) (Save)(4 Bytes)
- m_iSecondaryAmmoType (Offset 5136) (Save)(4 Bytes)
- m_iClip1 (Offset 5140) (Save)(4 Bytes)
- m_iClip2 (Offset 5144) (Save)(4 Bytes)
- m_bFiresUnderwater (Offset 5199) (Save)(1 Bytes)
- m_bAltFiresUnderwater (Offset 5200) (Save)(1 Bytes)
- m_fMinRange1 (Offset 5160) (Save)(4 Bytes)
- m_fMinRange2 (Offset 5164) (Save)(4 Bytes)
- m_fMaxRange1 (Offset 5168) (Save)(4 Bytes)
- m_fMaxRange2 (Offset 5172) (Save)(4 Bytes)
- m_iPrimaryAmmoCount (Offset 5184) (Save)(4 Bytes)
- m_iSecondaryAmmoCount (Offset 5188) (Save)(4 Bytes)
- m_nViewModelIndex (Offset 5100) (Save)(4 Bytes)
- m_nIdealSequence (Offset 5204) (Save)(4 Bytes)
- m_IdealActivity (Offset 5208) (Save)(4 Bytes)
- m_fFireDuration (Offset 5176) (Save)(4 Bytes)
- m_bReloadsSingly (Offset 5201) (Save)(1 Bytes)
- m_iSubType (Offset 5212) (Save)(4 Bytes)
- m_bRemoveable (Offset 5196) (Save)(1 Bytes)
- m_flUnlockTime (Offset 5216) (Save)(4 Bytes)
- m_hLocker (Offset 5220) (Save)(4 Bytes)
- m_pConstraint (Offset 5228) (Save)(0 Bytes)
- m_iReloadHudHintCount (Offset 5236) (Save)(4 Bytes)
- m_iAltFireHudHintCount (Offset 5232) (Save)(4 Bytes)
- m_bReloadHudHintDisplayed (Offset 5241) (Save)(1 Bytes)
- m_bAltFireHudHintDisplayed (Offset 5240) (Save)(1 Bytes)
- m_flHudHintPollTime (Offset 5244) (Save)(4 Bytes)
- m_flHudHintMinDisplayTime (Offset 5248) (Save)(4 Bytes)
- CBaseCombatWeaponDefaultTouch (Offset 0) (FunctionTable)(0 Bytes)
- CBaseCombatWeaponFallThink (Offset 0) (FunctionTable)(0 Bytes)
- CBaseCombatWeaponMaterialize (Offset 0) (FunctionTable)(0 Bytes)
- CBaseCombatWeaponAttemptToMaterialize (Offset 0) (FunctionTable)(0 Bytes)
- CBaseCombatWeaponDestroyItem (Offset 0) (FunctionTable)(0 Bytes)
- CBaseCombatWeaponSetPickupTouch (Offset 0) (FunctionTable)(0 Bytes)
- CBaseCombatWeaponHideThink (Offset 0) (FunctionTable)(0 Bytes)
- InputHideWeapon (Offset 0) (Input)(0 Bytes) - HideWeapon
- m_OnPlayerUse (Offset 5252) (Save|Key|Output)(0 Bytes) - OnPlayerUse
- m_OnPlayerPickup (Offset 5276) (Save|Key|Output)(0 Bytes) - OnPlayerPickup
- m_OnNPCPickup (Offset 5300) (Save|Key|Output)(0 Bytes) - OnNPCPickup
- m_OnCacheInteraction (Offset 5324) (Save|Key|Output)(0 Bytes) - OnCacheInteraction
- m_flGroundSpeed (Offset 1068) (Save)(4 Bytes)
- m_flLastEventCheck (Offset 1072) (Save)(4 Bytes)
- m_bSequenceFinished (Offset 1140) (Save)(1 Bytes)
- m_bSequenceLoops (Offset 1141) (Save)(1 Bytes)
- m_nSkin (Offset 1092) (Save|Key|Input)(4 Bytes) - skin
- m_nBody (Offset 1096) (Save|Key)(4 Bytes) - body
- m_nBody (Offset 1096) (Save|Key|Input)(4 Bytes) - SetBodyGroup
- m_nHitboxSet (Offset 1100) (Save|Key)(4 Bytes) - hitboxset
- m_nSequence (Offset 1152) (Save|Key)(4 Bytes) - sequence
- m_flPoseParameter (Offset 1156) (Save)(96 Bytes)
- m_flEncodedController (Offset 1252) (Save)(16 Bytes)
- m_flPlaybackRate (Offset 1108) (Save|Key)(4 Bytes) - playbackrate
- m_flCycle (Offset 1148) (Save|Key)(4 Bytes) - cycle
- m_pIk (Offset 1132) (Save)(0 Bytes)
- m_iIKCounter (Offset 1136) (Save)(4 Bytes)
- m_bClientSideAnimation (Offset 1268) (Save)(1 Bytes)
- m_bClientSideFrameReset (Offset 1269) (Save)(1 Bytes)
- m_nNewSequenceParity (Offset 1272) (Save)(4 Bytes)
- m_nResetEventsParity (Offset 1276) (Save)(4 Bytes)
- m_nMuzzleFlashParity (Offset 1280) (Save)(1 Bytes)
- m_iszLightingOrigin (Offset 1288) (Save|Key)(4 Bytes) - LightingOrigin
- m_hLightingOrigin (Offset 1284) (Save)(4 Bytes)
- m_flModelScale (Offset 1104) (Save)(4 Bytes)
- m_flDissolveStartTime (Offset 1144) (Save)(4 Bytes)
- InputIgnite (Offset 0) (Input)(0 Bytes) - Ignite
- InputIgniteLifetime (Offset 0) (Input)(0 Bytes) - IgniteLifetime
- InputIgnite (Offset 0) (Input)(0 Bytes) - IgniteNumHitboxFires
- InputIgnite (Offset 0) (Input)(0 Bytes) - IgniteHitboxFireScale
- InputBecomeRagdoll (Offset 0) (Input)(0 Bytes) - BecomeRagdoll
- InputSetLightingOrigin (Offset 0) (Input)(0 Bytes) - SetLightingOrigin
- m_OnIgnite (Offset 1320) (Save|Key|Output)(0 Bytes) - OnIgnite
- m_flFrozen (Offset 1300) (Save)(4 Bytes)
- m_flFrozenThawRate (Offset 1312) (Save)(4 Bytes)
- m_flFrozenMax (Offset 1316) (Save)(4 Bytes)
- m_fBoneCacheFlags (Offset 1296) (Save)(2 Bytes)
- m_iClassname (Offset 116) (Save|Key)(4 Bytes) - classname
- m_iGlobalname (Offset 120) (Global|Save|Key)(4 Bytes) - globalname
- m_iParent (Offset 124) (Save|Key)(4 Bytes) - parentname
- m_nMinCPULevel (Offset 744) (Save|Key)(1 Bytes) - mincpulevel
- m_nMaxCPULevel (Offset 745) (Save|Key)(1 Bytes) - maxcpulevel
- m_nMinGPULevel (Offset 746) (Save|Key)(1 Bytes) - mingpulevel
- m_nMaxGPULevel (Offset 747) (Save|Key)(1 Bytes) - maxgpulevel
- m_bDisableX360 (Offset 276) (Save|Key)(1 Bytes) - disableX360
- m_iHammerID (Offset 128) (Save|Key)(4 Bytes) - hammerid
- m_flSpeed (Offset 264) (Save|Key)(4 Bytes) - speed
- m_nRenderFX (Offset 268) (Save|Key)(1 Bytes) - renderfx
- m_nRenderMode (Offset 269) (Save|Key)(1 Bytes) - rendermode
- m_flPrevAnimTime (Offset 132) (Save)(4 Bytes)
- m_flAnimTime (Offset 136) (Save)(4 Bytes)
- m_flSimulationTime (Offset 140) (Save)(4 Bytes)
- m_flCreateTime (Offset 144) (Save)(4 Bytes)
- m_nLastThinkTick (Offset 148) (Save)(4 Bytes)
- m_iszScriptId (Offset 996) (Save)(4 Bytes)
- m_iszVScripts (Offset 972) (Save|Key)(4 Bytes) - vscripts
- m_iszScriptThinkFunction (Offset 976) (Save|Key)(4 Bytes) - thinkfunction
- m_nNextThinkTick (Offset 200) (Save|Key)(4 Bytes) - nextthink
- m_fEffects (Offset 204) (Save|Key)(4 Bytes) - effects
- m_clrRender (Offset 272) (Save|Key)(4 Bytes) - rendercolor
- m_nModelIndex (Offset 270) (Global|Save|Key)(2 Bytes) - modelindex
- touchStamp (Offset 152) (Save)(4 Bytes)
- m_aThinkFunctions (Offset 156) (Save)(0 Bytes)
- m_ResponseContexts (Offset 176) (Save)(0 Bytes)
- m_iszResponseContext (Offset 196) (Save|Key)(4 Bytes) - ResponseContext
- m_pfnThink (Offset 24) (Save)(4 Bytes)
- m_pfnTouch (Offset 208) (Save)(4 Bytes)
- m_pfnUse (Offset 212) (Save)(4 Bytes)
- m_pfnBlocked (Offset 216) (Save)(4 Bytes)
- m_pfnMoveDone (Offset 20) (Save)(4 Bytes)
- m_lifeState (Offset 240) (Save)(1 Bytes)
- m_takedamage (Offset 241) (Save)(1 Bytes)
- m_iMaxHealth (Offset 232) (Save|Key)(4 Bytes) - max_health
- m_iHealth (Offset 236) (Save|Key)(4 Bytes) - health
- m_target (Offset 228) (Save|Key)(4 Bytes) - target
- m_iszDamageFilterName (Offset 244) (Save|Key)(4 Bytes) - damagefilter
- m_hDamageFilter (Offset 248) (Save)(4 Bytes)
- m_debugOverlays (Offset 252) (Save)(4 Bytes)
- m_hScriptUseTarget (Offset 260) (Save)(4 Bytes)
- m_pParent (Offset 364) (Global|Save)(4 Bytes)
- m_iParentAttachment (Offset 369) (Save)(1 Bytes)
- m_hMoveParent (Offset 372) (Global|Save)(4 Bytes)
- m_hMoveChild (Offset 376) (Global|Save)(4 Bytes)
- m_hMovePeer (Offset 380) (Global|Save)(4 Bytes)
- m_iEFlags (Offset 312) (Save)(4 Bytes)
- m_iName (Offset 320) (Save)(4 Bytes)
 Sub-Class Table (1 Deep): m_Collision - CCollisionProperty
 - m_vecMins (Offset 8) (Global|Save)(12 Bytes)
 - m_vecMaxs (Offset 20) (Global|Save)(12 Bytes)
 - m_nSolidType (Offset 34) (Save|Key)(1 Bytes) - solid
 - m_usSolidFlags (Offset 32) (Save)(2 Bytes)
 - m_nSurroundType (Offset 42) (Save)(1 Bytes)
 - m_flRadius (Offset 36) (Save)(4 Bytes)
 - m_triggerBloat (Offset 35) (Save)(1 Bytes)
 - m_vecSpecifiedSurroundingMins (Offset 44) (Save)(12 Bytes)
 - m_vecSpecifiedSurroundingMaxs (Offset 56) (Save)(12 Bytes)
 - m_vecSurroundingMins (Offset 68) (Save)(12 Bytes)
 - m_vecSurroundingMaxs (Offset 80) (Save)(12 Bytes)
 Sub-Class Table (1 Deep): m_Network - CServerNetworkProperty
 - m_hParent (Offset 52) (Global|Save)(4 Bytes)
 Sub-Class Table (1 Deep): m_Glow - CGlowProperty
 - m_iGlowType (Offset 4) (Save)(4 Bytes)
- m_MoveType (Offset 370) (Save)(1 Bytes)
- m_MoveCollide (Offset 371) (Save)(1 Bytes)
- m_hOwnerEntity (Offset 524) (Save)(4 Bytes)
- m_CollisionGroup (Offset 544) (Save)(4 Bytes)
- m_pPhysicsObject (Offset 548) (Save)(0 Bytes)
- m_flElasticity (Offset 692) (Save)(4 Bytes)
- m_flShadowCastDistance (Offset 556) (Save|Key)(4 Bytes) - shadowcastdist
- m_flDesiredShadowCastDistance (Offset 560) (Save)(4 Bytes)
- m_iInitialTeamNum (Offset 564) (Save|Key|Input)(4 Bytes) - TeamNum
- m_iTeamNum (Offset 568) (Save)(4 Bytes)
- m_PreStasisMoveType (Offset 4) (Save)(4 Bytes)
- m_bIsInStasis (Offset 8) (Save)(1 Bytes)
- m_hGroundEntity (Offset 580) (Save)(4 Bytes)
- m_flGroundChangeTime (Offset 584) (Save)(4 Bytes)
- m_ModelName (Offset 588) (Global|Save|Key)(4 Bytes) - model
- m_AIAddOn (Offset 592) (Save|Key)(4 Bytes) - addon
- m_vecBaseVelocity (Offset 596) (Save|Key)(12 Bytes) - basevelocity
- m_vecAbsVelocity (Offset 608) (Save)(12 Bytes)
- m_vecAngVelocity (Offset 620) (Save|Key)(12 Bytes) - avelocity
- m_rgflCoordinateFrame (Offset 632) (Save)(48 Bytes)
- m_nWaterLevel (Offset 575) (Save|Key)(1 Bytes) - waterlevel
- m_nWaterType (Offset 574) (Save)(1 Bytes)
- m_pBlocker (Offset 680) (Save)(4 Bytes)
- m_flGravity (Offset 684) (Save|Key)(4 Bytes) - gravity
- m_flFriction (Offset 688) (Save|Key)(4 Bytes) - friction
- m_flLocalTime (Offset 700) (Save|Key)(4 Bytes) - ltime
- m_flVPhysicsUpdateLocalTime (Offset 704) (Save)(4 Bytes)
- m_flMoveDoneTime (Offset 708) (Save)(4 Bytes)
- m_vecAbsOrigin (Offset 716) (Save)(12 Bytes)
- m_vecVelocity (Offset 728) (Save|Key)(12 Bytes) - velocity
- m_iTextureFrameIndex (Offset 740) (Save|Key)(1 Bytes) - texframeindex
- m_bSimulatedEveryTick (Offset 741) (Save)(1 Bytes)
- m_bAnimatedEveryTick (Offset 742) (Save)(1 Bytes)
- m_bAlternateSorting (Offset 743) (Save)(1 Bytes)
- m_bGlowBackfaceMult (Offset 12) (Save|Key)(4 Bytes) - glowbackfacemult
- m_spawnflags (Offset 308) (Save|Key)(4 Bytes) - spawnflags
- m_nTransmitStateOwnedCounter (Offset 368) (Save)(1 Bytes)
- m_angAbsRotation (Offset 872) (Save)(12 Bytes)
- m_vecOrigin (Offset 904) (Save)(12 Bytes)
- m_angRotation (Offset 916) (Save)(12 Bytes)
- m_bClientSideRagdoll (Offset 748) (Save)(1 Bytes)
- m_vecViewOffset (Offset 932) (Save|Key)(12 Bytes) - view_ofs
- m_fFlags (Offset 316) (Save)(4 Bytes)
- m_nSimulationTick (Offset 280) (Save)(4 Bytes)
- m_flNavIgnoreUntilTime (Offset 576) (Save)(4 Bytes)
- InputSetTeam (Offset 0) (Input)(0 Bytes) - SetTeam
- m_fadeMinDist (Offset 532) (Save|Key|Input)(4 Bytes) - fademindist
- m_fadeMaxDist (Offset 536) (Save|Key|Input)(4 Bytes) - fademaxdist
- m_flFadeScale (Offset 540) (Save|Key)(4 Bytes) - fadescale
- InputKill (Offset 0) (Input)(0 Bytes) - Kill
- InputKillHierarchy (Offset 0) (Input)(0 Bytes) - KillHierarchy
- InputUse (Offset 0) (Input)(0 Bytes) - Use
- InputAlpha (Offset 0) (Input)(0 Bytes) - Alpha
- InputAlternativeSorting (Offset 0) (Input)(0 Bytes) - AlternativeSorting
- InputColor (Offset 0) (Input)(0 Bytes) - Color
- InputSetParent (Offset 0) (Input)(0 Bytes) - SetParent
- InputSetParentAttachment (Offset 0) (Input)(0 Bytes) - SetParentAttachment
- InputSetParentAttachmentMaintainOffset (Offset 0) (Input)(0 Bytes) - SetParentAttachmentMaintainOffset
- InputClearParent (Offset 0) (Input)(0 Bytes) - ClearParent
- InputSetDamageFilter (Offset 0) (Input)(0 Bytes) - SetDamageFilter
- InputEnableDamageForces (Offset 0) (Input)(0 Bytes) - EnableDamageForces
- InputDisableDamageForces (Offset 0) (Input)(0 Bytes) - DisableDamageForces
- InputDispatchResponse (Offset 0) (Input)(0 Bytes) - DispatchResponse
- InputAddContext (Offset 0) (Input)(0 Bytes) - AddContext
- InputRemoveContext (Offset 0) (Input)(0 Bytes) - RemoveContext
- InputClearContext (Offset 0) (Input)(0 Bytes) - ClearContext
- InputDisableShadow (Offset 0) (Input)(0 Bytes) - DisableShadow
- InputEnableShadow (Offset 0) (Input)(0 Bytes) - EnableShadow
- InputAddOutput (Offset 0) (Input)(0 Bytes) - AddOutput
- InputFireUser1 (Offset 0) (Input)(0 Bytes) - FireUser1
- InputFireUser2 (Offset 0) (Input)(0 Bytes) - FireUser2
- InputFireUser3 (Offset 0) (Input)(0 Bytes) - FireUser3
- InputFireUser4 (Offset 0) (Input)(0 Bytes) - FireUser4
- InputRunScriptFile (Offset 0) (Input)(0 Bytes) - RunScriptFile
- InputRunScript (Offset 0) (Input)(0 Bytes) - RunScriptCode
- InputCallScriptFunction (Offset 0) (Input)(0 Bytes) - CallScriptFunction
- m_OnUser1 (Offset 752) (Save|Key|Output)(0 Bytes) - OnUser1
- m_OnUser2 (Offset 776) (Save|Key|Output)(0 Bytes) - OnUser2
- m_OnUser3 (Offset 800) (Save|Key|Output)(0 Bytes) - OnUser3
- m_OnUser4 (Offset 824) (Save|Key|Output)(0 Bytes) - OnUser4
- CBaseEntitySUB_Remove (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntitySUB_DoNothing (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntitySUB_StartFadeOut (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntitySUB_StartFadeOutInstant (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntitySUB_FadeOut (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntitySUB_Vanish (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntitySUB_CallUseToggle (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntityShadowCastDistThink (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntityFrictionRevertThink (Offset 0) (FunctionTable)(0 Bytes)
- CBaseEntityScriptThink (Offset 0) (FunctionTable)(0 Bytes)
- m_hEffectEntity (Offset 528) (Save)(4 Bytes)
- m_bLagCompensate (Offset 969) (Save|Key)(1 Bytes) - LagCompensate

CGasCan (type DT_GasCan)
 Table: baseclass (offset 0) (type DT_BaseBackpackItem)
  Table: baseclass (offset 0) (type DT_TerrorWeapon)
   Table: baseclass (offset 0) (type DT_WeaponCSBase)
    Table: baseclass (offset 0) (type DT_BaseCombatWeapon)
     Table: baseclass (offset 0) (type DT_BaseAnimating)
      Table: baseclass (offset 0) (type DT_BaseEntity)
       Table: AnimTimeMustBeFirst (offset 0) (type DT_AnimTimeMustBeFirst)
        Member: m_flAnimTime (offset 136) (type integer) (bits 8) (Unsigned|ChangesOften)
       Member: m_flSimulationTime (offset 140) (type integer) (bits 8) (Unsigned|ChangesOften)
       Member: m_flCreateTime (offset 144) (type float) (bits 0) (NoScale)
       Member: m_cellbits (offset 888) (type integer) (bits 5) (Unsigned)
       Member: m_cellX (offset 892) (type integer) (bits 10) (Unsigned)
       Member: m_cellY (offset 896) (type integer) (bits 10) (Unsigned)
       Member: m_cellZ (offset 900) (type integer) (bits 10) (Unsigned)
       Member: m_vecOrigin (offset 904) (type vector) (bits 5) (ChangesOften)
       Member: m_nModelIndex (offset 270) (type integer) (bits 12) ()
       Table: m_Collision (offset 384) (type DT_CollisionProperty)
        Member: m_vecMins (offset 8) (type vector) (bits 0) (NoScale)
        Member: m_vecMaxs (offset 20) (type vector) (bits 0) (NoScale)
        Member: m_nSolidType (offset 34) (type integer) (bits 3) (Unsigned)
        Member: m_usSolidFlags (offset 32) (type integer) (bits 13) (Unsigned)
        Member: m_nSurroundType (offset 42) (type integer) (bits 3) (Unsigned)
        Member: m_triggerBloat (offset 35) (type integer) (bits 8) (Unsigned)
        Member: m_vecSpecifiedSurroundingMins (offset 44) (type vector) (bits 0) (NoScale)
        Member: m_vecSpecifiedSurroundingMaxs (offset 56) (type vector) (bits 0) (NoScale)
       Table: m_Glow (offset 476) (type DT_GlowProperty)
        Member: m_iGlowType (offset 4) (type integer) (bits 32) ()
        Member: m_nGlowRange (offset 8) (type integer) (bits 32) ()
        Member: m_nGlowRangeMin (offset 12) (type integer) (bits 32) ()
        Member: m_glowColorOverride (offset 16) (type integer) (bits 32) ()
        Member: m_bFlashing (offset 20) (type integer) (bits 1) (Unsigned)
       Member: m_nRenderFX (offset 268) (type integer) (bits 8) (Unsigned)
       Member: m_nRenderMode (offset 269) (type integer) (bits 8) (Unsigned)
       Member: m_fEffects (offset 204) (type integer) (bits 10) (Unsigned)
       Member: m_clrRender (offset 272) (type integer) (bits 32) (Unsigned)
       Member: m_iTeamNum (offset 568) (type integer) (bits 6) ()
       Member: m_CollisionGroup (offset 544) (type integer) (bits 5) (Unsigned)
       Member: m_flElasticity (offset 692) (type float) (bits 0) (NoScale|CoordMP)
       Member: m_flShadowCastDistance (offset 556) (type float) (bits 12) (Unsigned)
       Member: m_hOwnerEntity (offset 524) (type integer) (bits 21) (Unsigned|NoScale)
       Member: m_hEffectEntity (offset 528) (type integer) (bits 21) (Unsigned|NoScale)
       Member: moveparent (offset 372) (type integer) (bits 21) (Unsigned|NoScale)
       Member: m_iParentAttachment (offset 369) (type integer) (bits 6) (Unsigned)
       Member: m_hScriptUseTarget (offset 260) (type integer) (bits 21) (Unsigned|NoScale)
       Member: movetype (offset 370) (type integer) (bits 4) (Unsigned)
       Member: movecollide (offset 371) (type integer) (bits 3) (Unsigned)
       Member: m_angRotation (offset 916) (type vector) (bits 13) (RoundDown|ChangesOften)
       Member: m_iTextureFrameIndex (offset 740) (type integer) (bits 8) (Unsigned)
       Member: m_bSimulatedEveryTick (offset 741) (type integer) (bits 1) (Unsigned)
       Member: m_bAnimatedEveryTick (offset 742) (type integer) (bits 1) (Unsigned)
       Member: m_bAlternateSorting (offset 743) (type integer) (bits 1) (Unsigned)
       Member: m_bGlowBackfaceMult (offset 12) (type integer) (bits 32) ()
       Member: m_Gender (offset 224) (type integer) (bits 32) ()
       Member: m_fadeMinDist (offset 532) (type float) (bits 0) (NoScale)
       Member: m_fadeMaxDist (offset 536) (type float) (bits 0) (NoScale)
       Member: m_flFadeScale (offset 540) (type float) (bits 0) (NoScale)
       Member: m_nMinCPULevel (offset 744) (type integer) (bits 2) (Unsigned)
       Member: m_nMaxCPULevel (offset 745) (type integer) (bits 2) (Unsigned)
       Member: m_nMinGPULevel (offset 746) (type integer) (bits 3) (Unsigned)
       Member: m_nMaxGPULevel (offset 747) (type integer) (bits 3) (Unsigned)
      Member: m_nForceBone (offset 1076) (type integer) (bits 8) ()
      Member: m_vecForce (offset 1080) (type vector) (bits 0) (NoScale)
      Member: m_nSkin (offset 1092) (type integer) (bits 10) ()
      Member: m_nBody (offset 1096) (type integer) (bits 32) ()
      Member: m_nHitboxSet (offset 1100) (type integer) (bits 2) (Unsigned)
      Member: m_flModelScale (offset 1104) (type float) (bits 0) (NoScale)
      Table: m_flPoseParameter (offset 1156) (type m_flPoseParameter)
       Member: 000 (offset 0) (type float) (bits 11) ()
       Member: 001 (offset 4) (type float) (bits 11) ()
       Member: 002 (offset 8) (type float) (bits 11) ()
       Member: 003 (offset 12) (type float) (bits 11) ()
       Member: 004 (offset 16) (type float) (bits 11) ()
       Member: 005 (offset 20) (type float) (bits 11) ()
       Member: 006 (offset 24) (type float) (bits 11) ()
       Member: 007 (offset 28) (type float) (bits 11) ()
       Member: 008 (offset 32) (type float) (bits 11) ()
       Member: 009 (offset 36) (type float) (bits 11) ()
       Member: 010 (offset 40) (type float) (bits 11) ()
       Member: 011 (offset 44) (type float) (bits 11) ()
       Member: 012 (offset 48) (type float) (bits 11) ()
       Member: 013 (offset 52) (type float) (bits 11) ()
       Member: 014 (offset 56) (type float) (bits 11) ()
       Member: 015 (offset 60) (type float) (bits 11) ()
       Member: 016 (offset 64) (type float) (bits 11) ()
       Member: 017 (offset 68) (type float) (bits 11) ()
       Member: 018 (offset 72) (type float) (bits 11) ()
       Member: 019 (offset 76) (type float) (bits 11) ()
       Member: 020 (offset 80) (type float) (bits 11) ()
       Member: 021 (offset 84) (type float) (bits 11) ()
       Member: 022 (offset 88) (type float) (bits 11) ()
       Member: 023 (offset 92) (type float) (bits 11) ()
      Member: m_nSequence (offset 1152) (type integer) (bits 12) (Unsigned)
      Member: m_flPlaybackRate (offset 1108) (type float) (bits 8) (RoundUp)
      Table: m_flEncodedController (offset 1252) (type m_flEncodedController)
       Member: 000 (offset 0) (type float) (bits 11) (RoundDown)
       Member: 001 (offset 4) (type float) (bits 11) (RoundDown)
       Member: 002 (offset 8) (type float) (bits 11) (RoundDown)
       Member: 003 (offset 12) (type float) (bits 11) (RoundDown)
      Member: m_bClientSideAnimation (offset 1268) (type integer) (bits 1) (Unsigned)
      Member: m_bClientSideFrameReset (offset 1269) (type integer) (bits 1) (Unsigned)
      Member: m_bClientSideRagdoll (offset 748) (type integer) (bits 1) (Unsigned)
      Member: m_nNewSequenceParity (offset 1272) (type integer) (bits 3) (Unsigned|ChangesOften)
      Member: m_nResetEventsParity (offset 1276) (type integer) (bits 3) (Unsigned|ChangesOften)
      Member: m_nMuzzleFlashParity (offset 1280) (type integer) (bits 2) (Unsigned|ChangesOften)
      Member: m_hLightingOrigin (offset 1284) (type integer) (bits 21) (Unsigned|NoScale)
      Table: serveranimdata (offset 0) (type DT_ServerAnimationData)
       Member: m_flCycle (offset 1148) (type float) (bits 15) (RoundDown|ChangesOften)
      Member: m_flFrozen (offset 1300) (type float) (bits 0) (NoScale)
     Member: m_flPoseParameter (offset 0) (type integer) (bits 0) (Exclude)
     Member: overlay_vars (offset 0) (type integer) (bits 0) (Exclude)
     Member: m_flexWeight (offset 0) (type integer) (bits 0) (Exclude)
     Member: m_blinktoggle (offset 0) (type integer) (bits 0) (Exclude)
     Member: m_flCycle (offset 0) (type integer) (bits 0) (Exclude)
     Member: m_flAnimTime (offset 0) (type integer) (bits 0) (Exclude)
     Table: LocalWeaponData (offset 0) (type DT_LocalWeaponData)
      Member: m_iClip2 (offset 5144) (type integer) (bits 8) (Unsigned)
      Member: m_iPrimaryAmmoType (offset 5132) (type integer) (bits 8) ()
      Member: m_iSecondaryAmmoType (offset 5136) (type integer) (bits 8) ()
      Member: m_nViewModelIndex (offset 5100) (type integer) (bits 1) (Unsigned)
     Table: LocalActiveWeaponData (offset 0) (type DT_LocalActiveWeaponData)
      Member: m_flNextPrimaryAttack (offset 5104) (type float) (bits 0) (NoScale)
      Member: m_flNextSecondaryAttack (offset 5108) (type float) (bits 0) (NoScale)
      Member: m_nNextThinkTick (offset 200) (type integer) (bits 32) ()
      Member: m_flTimeWeaponIdle (offset 5152) (type float) (bits 0) (NoScale)
      Member: m_nQueuedAttack (offset 5112) (type integer) (bits 32) ()
      Member: m_flTimeAttackQueued (offset 5116) (type float) (bits 0) (NoScale)
      Member: m_bOnlyPump (offset 5148) (type integer) (bits 1) (Unsigned)
     Member: m_iViewModelIndex (offset 5120) (type integer) (bits 12) ()
     Member: m_iWorldModelIndex (offset 5124) (type integer) (bits 12) ()
     Member: m_iState (offset 5128) (type integer) (bits 2) (Unsigned)
     Member: m_hOwner (offset 5096) (type integer) (bits 21) (Unsigned|NoScale)
     Member: m_bInReload (offset 5197) (type integer) (bits 1) (Unsigned)
     Member: m_iClip1 (offset 5140) (type integer) (bits 8) (Unsigned)
    Member: m_iExtraPrimaryAmmo (offset 5364) (type integer) (bits 32) ()
    Member: m_flAnimTime (offset 0) (type integer) (bits 0) (Exclude)
    Member: m_nSequence (offset 0) (type integer) (bits 0) (Exclude)
   Table: LocalL4DWeaponData (offset 0) (type DT_LocalActiveL4DWeaponData)
    Table: m_helpingHandSuppressionTimer (offset 5428) (type DT_CountdownTimer)
     Member: m_duration (offset 4) (type float) (bits 0) (NoScale)
     Member: m_timestamp (offset 8) (type float) (bits 0) (NoScale)
    Table: m_helpingHandTimer (offset 5388) (type DT_IntervalTimer)
     Member: m_timestamp (offset 4) (type float) (bits 0) (NoScale)
    Table: m_helpingHandTargetTimer (offset 5440) (type DT_IntervalTimer)
     Member: m_timestamp (offset 4) (type float) (bits 0) (NoScale)
    Member: m_helpingHandState (offset 5396) (type integer) (bits 32) ()
    Member: m_helpingHandTarget (offset 5400) (type integer) (bits 21) (Unsigned|NoScale)
    Member: m_helpingHandExtendDuration (offset 5404) (type float) (bits 0) (NoScale)
    Member: m_reloadQueuedStartTime (offset 5412) (type float) (bits 0) (NoScale)
    Member: m_releasedAltFireButton (offset 5416) (type integer) (bits 1) (Unsigned)
    Member: m_releasedFireButton (offset 5417) (type integer) (bits 1) (Unsigned)
    Member: m_isHoldingAltFireButton (offset 5419) (type integer) (bits 1) (Unsigned)
    Member: m_isHoldingFireButton (offset 5418) (type integer) (bits 1) (Unsigned)
    Member: m_bPickedUpOnTransition (offset 5424) (type integer) (bits 1) (Unsigned)
    Member: m_DroppedByInfectedGender (offset 6064) (type integer) (bits 6) (Unsigned)
    Member: m_iBloodyWeaponLevel (offset 5420) (type integer) (bits 4) (Unsigned)
   Table: m_attackTimer (offset 5452) (type DT_CountdownTimer)
    Member: m_duration (offset 4) (type float) (bits 0) (NoScale)
    Member: m_timestamp (offset 8) (type float) (bits 0) (NoScale)
   Table: m_swingTimer (offset 5464) (type DT_CountdownTimer)
    Member: m_duration (offset 4) (type float) (bits 0) (NoScale)
    Member: m_timestamp (offset 8) (type float) (bits 0) (NoScale)
   Member: m_nUpgradedPrimaryAmmoLoaded (offset 6024) (type integer) (bits 8) (Unsigned)
  Member: m_bPerformingAction (offset 6104) (type integer) (bits 1) (Unsigned)


    gas_can_use_duration	2	"cheat", "rep", "cl"	
    gascan_spit_time	2.9	"cheat", "rep", "cl"	Gascans can survive this long in spit before they ignite.
    gascan_throw_force	32	"sv", "cheat"	
    gascan_use_range	65	"cheat", "rep", "cl"	
    gascan_use_tolerance	0.1	"cheat", "rep", "cl"	
    scavenge_item_respawn_delay	20	, "sv", "cheat"	After being destroyed, time until a scavenge item will respawn
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION			"1.0-2026/1/27"
#define PLUGIN_NAME			    "l4d2_gascan_flame_fix"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D2] l4d_gascan_flame_fix",
	author = "HarryPotter, Forgetest",
	description = "Fixed unable to ignite gascan sometimes due to poorly written official code",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define GASCAN_HEALTH 20
#define GASCAN_PROTECT_Time 0.5
#define MAXENTITIES                   2048

ConVar scavenge_item_respawn_delay;
int g_iOfficialCvar_scavenge_item_respawn_delay;

ConVar g_hCvarEnable;
bool g_bCvarEnable;

Handle
    g_hChangeImmuneTimer[MAXENTITIES+1];

public void OnPluginStart()
{
    scavenge_item_respawn_delay = FindConVar("scavenge_item_respawn_delay");

    g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                PLUGIN_NAME);

    GetCvars();
    scavenge_item_respawn_delay.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);

}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_iOfficialCvar_scavenge_item_respawn_delay = scavenge_item_respawn_delay.IntValue;
    g_bCvarEnable = g_hCvarEnable.BoolValue;
}

// Sourcemod API Forward-------------------------------

public void OnEntityCreated(int entity, const char[] classname)
{
    if (!g_bCvarEnable || !IsValidEntityIndex(entity))
        return;

    switch (classname[0])
    {
        case 'w':
        {
            if (StrEqual(classname, "weapon_gascan"))
            {
                //RemoveEntity(entity);
                RequestFrame(OnNextFrame_GasCan, EntIndexToEntRef(entity));
            }
        }
    }
}

public void OnEntityDestroyed(int entity)
{
    if(!g_bCvarEnable) return;

    if (entity > MaxClients && IsValidEdict(entity))
    {
        char classname[64];
        GetEntityClassname(entity, classname, sizeof(classname));

        if (IsEntityClass(entity, "entityflame"))
        {
            int target = GetEntPropEnt(entity, Prop_Data, "m_hEntAttached");

            classname = "*INVALID*";
            if (target == -1 || !IsValidEntity(target)) return;

            GetEntityClassname(target, classname, sizeof(classname));

            //PrintToChatAll("flame #%d (attached %s)", entity, classname);

            if (target > MaxClients)
            {
                RequestFrame(NextFrame_FlameRemoved, EntIndexToEntRef(target));
            }
        }
    }
}

// Timer & Frame-------------------------------

void OnNextFrame_GasCan(int data)
{
    int entity = EntRefToEntIndex(data);
    if (entity == INVALID_ENT_REFERENCE)
        return;

    if (IsScavengeGascan(entity))
    {
        SDKHook(entity, SDKHook_UsePost, OnUsePost);
        return;
    }

    delete g_hChangeImmuneTimer[entity];
    DataPack hPack;
    g_hChangeImmuneTimer[entity] = CreateDataTimer(GASCAN_PROTECT_Time+0.05, Timer_ChangeGasImmune, hPack);
    hPack.WriteCell(entity);
    hPack.WriteCell(data);
}

Action Timer_ChangeGasImmune(Handle timer, DataPack hPack)
{
    hPack.Reset();
    int index = hPack.ReadCell();
    int entity = EntRefToEntIndex(hPack.ReadCell());
    g_hChangeImmuneTimer[index] = null;

    if (entity == INVALID_ENT_REFERENCE)
        return Plugin_Continue;

    ChanegGascanSpawnTime(entity);

    return Plugin_Continue;
}

void NextFrame_FlameRemoved(int data)
{
    int entity = EntRefToEntIndex(data);
    if (entity == INVALID_ENT_REFERENCE)
        return;

    if (!(GetEntityFlags(entity) & FL_ONFIRE))
        return;

    int effectent = GetEntPropEnt(entity, Prop_Send, "m_hEffectEntity");
    if (effectent != -1 && IsEntityClass(effectent, "entityflame"))
        return;

    //PrintToChatAll("remove %d FL_ONFIRE flag)", entity);
    //SetEntProp(entity, Prop_Data, "m_iHealth", GASCAN_HEALTH);

    RemoveEntityFlags(entity, FL_ONFIRE);
}

// SDKHooks---------------

void OnUsePost(int gascan, int client, int caller, UseType type, float value)
{
    if(0 < client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
    {
        ChanegGascanSpawnTime(gascan);
        SDKUnhook(gascan, SDKHook_UsePost, OnUsePost);
    }
}

// Function-------------------------------

void ChanegGascanSpawnTime(int entity)
{
    //PrintToChatAll("Change %d spawn time", entity);

    static int g_iOffset_GasCanSpawn = -1; 
    if(g_iOffset_GasCanSpawn == -1)
        g_iOffset_GasCanSpawn = FindDataMapInfo(entity, "m_bVulnerableToSpit") - 16;

    if(g_iOffset_GasCanSpawn == -1) return;
    
    //float fSpawnTime = GetEntDataFloat(entity, g_iOffset_GasCanSpawn);
    //PrintToChatAll("%.1f %.1f", fSpawnTime, GetGameTime());
    SetEntDataFloat(entity, g_iOffset_GasCanSpawn, GetGameTime() - g_iOfficialCvar_scavenge_item_respawn_delay);
}

void RemoveEntityFlags(int entity, int mask)
{
    int flags = GetEntityFlags(entity);
    SetEntityFlags(entity, flags & ~mask);
}

bool IsEntityClass(int entity, const char[] classname)
{
    char buffer[64];
    GetEntityClassname(entity, buffer, sizeof(buffer));
    return !strcmp(buffer, classname, false);
}

bool IsValidEntityIndex(int entity)
{
	return (MaxClients+1 <= entity <= GetMaxEntities());
}

bool IsScavengeGascan(int entity)
{
    int skin = GetEntProp(entity, Prop_Send, "m_nSkin");

    return skin > 0;
}