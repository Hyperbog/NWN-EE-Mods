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
