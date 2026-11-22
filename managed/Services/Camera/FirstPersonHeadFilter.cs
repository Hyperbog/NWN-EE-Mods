using System;
using System.Threading;
using CX.Alloy.Db;
using CX.Alloy.Seam;
using CX.Engine;
using CX.Framework;

namespace CX.Services.Camera;

/// <summary>Resolve the local player's head by the engine's separate head-model slot (0xFE).
/// A frame callback captures its generation-checked scene id; the Vulkan colour pass reads only that id.
/// No draw-thread engine calls, model mutation, or new hooks.</summary>
internal static class FirstPersonHeadFilter
{
    private sealed class State { internal int Id; }
    private static readonly State Current = new();

    internal static DbId HeadId => new(unchecked((uint)Volatile.Read(ref Current.Id)));

    internal static void Init(ExtenderLog log)
    {
        FrameRegistry.Global.Register(FramePhase.PostPresent, 65, Tick, "FPHeadId", log);
    }

    private static void Tick()
    {
        DbId id = default;
        if (CameraModes.Driving.HideHead.V && CameraModes.Driving.FirstPerson.V &&
            CameraModes.Driving.Action.V && CameraService.Mode == 2 && !CameraService.GateUp)
        {
            IntPtr cre = CameraService.PlayerCreature();
            if (cre != IntPtr.Zero)
            {
                // CNWCAnimBase's separate head model (NuiModelView.HeadPart).
                IntPtr gob = new CNWCCreature(cre).GetModel(0xfe, 1);
                if (gob != IntPtr.Zero) id = Facade.ObjectId(gob);
            }
        }
        Volatile.Write(ref Current.Id, unchecked((int)id.Value));
    }
}
