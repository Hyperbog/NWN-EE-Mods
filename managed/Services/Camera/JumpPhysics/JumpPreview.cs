using System.Threading;

namespace CX.Services.Camera;

/// <summary>
/// Spacebar input shared with JumpPositionService. This file deliberately does not
/// move the camera or renderer; those remain tied to the game's creature position.
/// </summary>
internal static class JumpPreview
{
    private static int _spaceEdge;
    private const uint KeyDown = 0x300, KeyUp = 0x301, Space = 32;

    internal static bool CaptureKey(uint kind, uint sym, byte repeat, bool actionHeld)
    {
        if (sym != Space || !actionHeld || !CameraModes.Driving.JumpPreview.V
            || !CameraModes.Driving.FirstPerson.V || CameraService.Mode != 2)
            return false;
        if (kind == KeyDown)
        {
            if (repeat == 0) Interlocked.Exchange(ref _spaceEdge, 1);
            return true;
        }
        return kind == KeyUp;
    }

    internal static bool Take() => Interlocked.Exchange(ref _spaceEdge, 0) != 0;
    internal static void Reset() => Interlocked.Exchange(ref _spaceEdge, 0);
}
