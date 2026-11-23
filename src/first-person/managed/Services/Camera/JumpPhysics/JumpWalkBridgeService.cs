// NWN:EE Fix14D J4 -- native walking/jump integration bridge.
// This file is part of the source overlay for NWNCX:EE; it is not a standalone mod.
//
// CONTROL FLOW: hook the existing CNWCCreature::WalkUpdateLocation chain at
// priority 70, *after* calling the previously installed native/managed chain.
// That existing chain includes StepGuard (priority 50) and pose weighting (60).
//
// The bridge never integrates a second gravity tick. JumpPositionService.Tick
// owns airborne physics; this post-walk callback only restores the intended
// airborne height after native movement has updated ground/desired positions.
// The engine still owns wall collision and authoritative walk updates.
//
// SAFETY: an area transition may invalidate a creature mid-frame. The callback
// confines that failure to this optional visual/airborne reapplication path,
// and always returns the native hook's original result unchanged.
//
// Diagnostics and gameplay validation refer to the *integrated* J4 source;
// published explanatory comments do not change runtime behavior.

using System;
using System.Runtime.InteropServices;
using CX.Engine;
using CX.Framework;

namespace CX.Services.Camera;

/// <summary>Reapply airborne Z after NWN completes a walking update; never step gravity here.</summary>
public sealed unsafe class JumpWalkBridgeService : IExtenderService
{
    private static WalkUpdateLocationFn* _next;

    public void Initialize(ExtenderLog log, HookService hooks)
    {
        JumpPositionService.ConfigureTrace(log);
        if (!EngineLayout.Require(log, "JumpWalkBridge", "CNWCObject", "CNWCCreature")) return;
        if (!SymbolMap.Require(log, "JumpWalkBridge", SymbolMap.WalkUpdateLocation)) return;
        // Priority 70 wraps StepGuard (50) and existing pose weight (60).
        _next = hooks.ChainWalkUpdateLocation(&OnWalkUpdateLocation, 70);
        if (_next == null) log.Info("JumpWalkBridge: hook refused, airborne walking unchanged");
        else log.Info("JumpWalkBridge: post-walk airborne Z bridge armed");
    }

    [UnmanagedCallersOnly]
    private static int OnWalkUpdateLocation(IntPtr creature)
    {
        int result = (*_next)(creature);
        try { JumpPositionService.AfterWalk(creature); }
        catch (Exception) { /* area changes can invalidate a creature mid-frame */ }
        return result;
    }
}
