using System;
using System.Numerics;
using CX.Engine;
using CX.Framework;

namespace CX.Services.Camera;

/// <summary>
/// Read-only client motion telemetry. Distinguishes drive intent, engine gait,
/// actual XY displacement, desired-vs-actual correction and head mesh swaps.
/// No input, camera, creature, animation or renderer writes.
/// </summary>
internal static class FirstPersonMoveProbe
{
    private static ExtenderLog? _log;
    private static IntPtr _tracked;
    private static Vector3 _previous;
    private static bool _seeded, _wasHeld, _wasStalled, _wasGhost;
    private static float _stillFor, _ghostFor, _time, _nextSample;
    private static string _head = "";
    private static int _lastAnim = -1, _lines, _stallEdges, _ghostEdges, _headEdges;
    private static float _lastSpeed, _lastGap;
    private const float StalledSeconds = 0.40f;
    private const float GhostSeconds = 0.40f;
    private const float SpeedFloor = 0.035f;  // diagnostic only: m/s
    private const int MaxLines = 160;

    internal static void Attach(ExtenderLog log) => _log = log;

    private static bool IsGait(int anim) => anim is 2 or 3 or 4 or 0x4e or 0x4f
        or (>= 0x54 and <= 0x57);

    internal static void Tick(IntPtr player, bool active, float dt)
    {
        if (!FirstPersonVisibility.Probe.V || !active || player == IntPtr.Zero)
        {
            _seeded = false;
            _tracked = IntPtr.Zero;
            _stillFor = _ghostFor = 0f;
            _wasStalled = _wasGhost = false;
            return;
        }
        if (!float.IsFinite(dt) || dt <= 0f || dt > 0.25f)
        {
            _seeded = false;
            return;
        }
        var obj = new CNWCObject(player);
        var creature = new CNWCCreature(player);
        Vector3 now = obj.Position;
        Vector3 desired = creature.DesiredPos;
        if (!Vector3IsFinite(now) || !Vector3IsFinite(desired))
        {
            _seeded = false;
            return;
        }
        bool held = CameraDriveService.Live && CameraDriveService.Held;
        bool driving = creature.Driving != 0;
        bool airborne = JumpPositionService.AirborneFor(player);
        int anim = obj.Animation;
        string head = FirstPersonModelProbe.HeadModel;
        _time += dt;
        if (!_seeded || _tracked != player)
        {
            _tracked = player;
            _seeded = true;
            _previous = now;
            _wasHeld = held;
            _head = head;
            _lastAnim = anim;
            _nextSample = _time + 1f;
            _stillFor = _ghostFor = 0f;
            _wasStalled = _wasGhost = false;
            Emit("attached", held, driving, airborne, anim, head, 0f, Gap(now, desired));
            return;
        }

        float xySpeed = MathF.Sqrt((now.X - _previous.X) * (now.X - _previous.X)
                                 + (now.Y - _previous.Y) * (now.Y - _previous.Y)) / dt;
        _previous = now;
        float gap = Gap(now, desired);
        _lastSpeed = xySpeed;
        _lastGap = gap;
        bool still = xySpeed < SpeedFloor;
        bool stallCandidate = held && driving && !airborne && still;
        bool ghostCandidate = !held && !airborne && still && IsGait(anim);
        _stillFor = stallCandidate ? _stillFor + dt : 0f;
        _ghostFor = ghostCandidate ? _ghostFor + dt : 0f;
        bool stalled = _stillFor >= StalledSeconds;
        bool ghost = _ghostFor >= GhostSeconds;
        bool headChanged = head.Length != 0 && _head.Length != 0
                            && !string.Equals(head, _head, StringComparison.Ordinal);
        bool heldChanged = held != _wasHeld;
        bool animChanged = anim != _lastAnim;

        if (stalled != _wasStalled)
        {
            if (stalled) _stallEdges++;
            Emit(stalled ? "wall-stall" : "stall-cleared", held, driving, airborne, anim, head, xySpeed, gap);
        }
        if (ghost != _wasGhost)
        {
            if (ghost) _ghostEdges++;
            Emit(ghost ? "uncommanded-gait" : "gait-cleared", held, driving, airborne, anim, head, xySpeed, gap);
        }
        if (headChanged)
        {
            _headEdges++;
            Emit("head-model-change", held, driving, airborne, anim, head, xySpeed, gap);
        }
        else if (heldChanged || (animChanged && (stalled || ghost)))
        {
            Emit(heldChanged ? "input-edge" : "animation-edge", held, driving, airborne, anim, head, xySpeed, gap);
        }
        if ((stalled || ghost) && _time >= _nextSample)
        {
            _nextSample = _time + 0.8f;
            Emit("sustained", held, driving, airborne, anim, head, xySpeed, gap);
        }
        _wasStalled = stalled;
        _wasGhost = ghost;
        _wasHeld = held;
        _lastAnim = anim;
        _head = head;
    }

    private static bool Vector3IsFinite(Vector3 p) =>
        float.IsFinite(p.X) && float.IsFinite(p.Y) && float.IsFinite(p.Z);

    private static float Gap(Vector3 a, Vector3 b)
    {
        float dx = a.X - b.X, dy = a.Y - b.Y;
        return MathF.Sqrt(dx * dx + dy * dy);
    }

    private static void Emit(string why, bool held, bool driving, bool airborne, int anim,
                             string head, float actualSpeed, float desiredGap)
    {
        if (_log == null || _lines >= MaxLines) return;
        _lines++;
        _log.Always(FormattableString.Invariant(
            $"[fpmove] {why} t={_time:0.00}s input={(held ? 1 : 0)} engineDrive={(driving ? 1 : 0)} air={(airborne ? 1 : 0)} anim={anim} walkingAnim={(IsGait(anim) ? 1 : 0)} actualXY={actualSpeed:0.000}m/s desiredGap={desiredGap:0.000}m stepGuardWalk={StepGuardService.ProbeWalkRefusals} stepGuardDrive={StepGuardService.ProbeDriveRefusals} head={head}"));
    }

    internal static string Diagnostics() => FormattableString.Invariant(
        $"fpmove: {(FirstPersonVisibility.Probe.V ? "enabled" : "off")} stalls={_stallEdges} idleGaits={_ghostEdges} headChanges={_headEdges} lastXY={_lastSpeed:0.000}m/s gap={_lastGap:0.000}m lines={_lines}/{MaxLines}");
}
