using System;
using System.Numerics;
using CX.Engine;

namespace CX.Services.Camera;

/// <summary>
/// Phase 3: native CREATURE-POSITION experiment. Called exactly once by the
/// existing world-camera solve, which runs even when the player stands still.
/// Does not adjust eye height or rendered model matrices; it changes actual
/// local CNWCCreature.Position and DesiredPos through the existing engine API.
/// This does not grant server authority or guarantee valid walkmesh traversal.
/// </summary>
internal static unsafe class JumpPositionService
{
    private static bool _airborne;
    private static IntPtr _creature, _module;
    private static float _floor, _rise, _velocity, _expectedZ;
    private static readonly AirMomentumMotor _air = new();
    private static Vector2 _lastGroundXY, _groundVelocity;
    private static bool _haveGroundSample;
    private static int _airSteerFrames, _airBlockedSteps, _walkAtLaunch;

    private static int _jumps, _lands, _corrections, _aborts, _correctionStreak, _walkReapplies;

    // Physically integrated ballistic arc (units in NWN meters/seconds).
    private const float Impulse = 5f;
    private const float Gravity = 13.5f;
    private const float MaximumRise = 1.15f;
    private const int MaxCorrectionFrames = 4;

    // Read-only native jump state for visual camera effects. No extra stepping,
    // velocity edits or physics ownership changes; does not consume jump input.
    internal static bool IsAirborne => _airborne;
    internal static bool AirborneFor(IntPtr player) =>
        _airborne && player != IntPtr.Zero && player == _creature;

    internal static void Tick(float dt, bool worldCameraActive)
    {
        try { Step(dt, worldCameraActive); }
        catch (Exception)
        {
            // Native engine and module state may disappear during an area load;
            // never unwind a managed exception across the camera's native hook.
            _airborne = false;
            JumpPreview.Reset();
            _aborts++;
        }
    }

    private static void Step(float dt, bool worldCameraActive)
    {
        IntPtr module = CameraService.Module();
        IntPtr player = CameraService.PlayerCreature();
        if (_airborne && (_module != module || _creature != player))
        {
            // Do not restore the old area's elevation into a new area.
            _airborne = false;
            JumpPreview.Reset();
        }
        bool allowed = worldCameraActive && module != IntPtr.Zero && player != IntPtr.Zero
            && CameraModes.Driving.JumpPreview.V && CameraModes.Driving.FirstPerson.V
            && CameraService.Mode == 2 && MouseLookService.ActionHeld
            && !FreeCameraService.Active;
        if (!allowed)
        {
            if (_airborne && player == _creature && module == _module)
                Land(player, restore: true);
            JumpPreview.Reset();
            return;
        }
        if (!(dt > 0f && dt < 0.12f))
        {
            if (_airborne) Land(player, restore: true);
            JumpPreview.Reset();
            return;
        }
        // Explicitly use a small time step to prevent a hanged/paused frame
        // from launching the player upward by multiple metres.
        dt = Math.Clamp(dt, 0.001f, 0.040f);
        Vector3 current = new CNWCObject(player).Position;
        if (!Finite(current)) { _airborne = false; JumpPreview.Reset(); return; }
        bool press = JumpPreview.Take();
        if (!_airborne && !press)
        {
            TrackGroundSpeed(current, dt);
            return;
        }
        if (!_airborne)
        {
            _floor = current.Z;
            _rise = 0f;
            _expectedZ = current.Z;
            _velocity = Impulse;
            Vector2 carry = _groundVelocity;
            if (carry.LengthSquared() < 0.09f && CameraDriveService.AirWish.LengthSquared() > 0.1f)
                carry = CameraDriveService.AirWish * 2.6f;
            _air.Launch(new Vector2(current.X, current.Y), carry);
            _haveGroundSample = false;
            _walkAtLaunch = _walkReapplies;
            _correctionStreak = 0;
            _airborne = true;
            _creature = player; _module = module;
            _jumps++;
        }
        else if (MathF.Abs(current.Z - _expectedZ) > 0.12f)
        {
            _corrections++;
            // A walk update can temporarily flatten Z. The Fix6 post-walk
            // bridge has already demonstrated successful reapplication during
            // this jump; do not mistake that for a hard authority correction.
            if (_walkReapplies > _walkAtLaunch) _correctionStreak = 0;
            else if (++_correctionStreak >= MaxCorrectionFrames)
            {
                _aborts++;
                _airborne = false;
                return;
            }
        }
        else _correctionStreak = 0;

        float next = _rise + _velocity * dt - 0.5f * Gravity * dt * dt;
        _velocity -= Gravity * dt;
        if (next <= 0f)
        {
            Land(player, restore: false);
            return;
        }
        _rise = Math.Clamp(next, 0f, MaximumRise);
        Vector2 previous = _air.Position;
        Vector2 proposed = _air.Step(dt, CameraDriveService.AirWish);
        if (CameraDriveService.AirWish.LengthSquared() > 0.01f) _airSteerFrames++;
        Vector2 accepted = ConstrainHorizontal(player, module, previous, proposed);
        if (Vector2.DistanceSquared(proposed, accepted) > 1e-6f) _airBlockedSteps++;
        _air.Resolve(accepted);
        WriteCreaturePosition(player, new Vector3(accepted.X, accepted.Y, _floor + _rise));
    }

    // Sample NWN's real takeoff motion. Anomalous/teleport-sized deltas are
    // deliberately discarded, rather than carried into a launch.
    private static void TrackGroundSpeed(in Vector3 current, float dt)
    {
        Vector2 xy = new(current.X, current.Y);
        if (_haveGroundSample && dt > 0.001f)
        {
            Vector2 sample = (xy - _lastGroundXY) / dt;
            _groundVelocity = sample.LengthSquared() < 36f ? sample : Vector2.Zero;
        }
        else _groundVelocity = Vector2.Zero;
        _lastGroundXY = xy;
        _haveGroundSample = true;
    }

    // Native CNWCArea path clearance, the same API used by StepGuardService.
    // At this stage all casts stay at takeoff ground elevation: flat terrain only.
    // An absent symbol or missing area FAILS CLOSED, never ghosts through walls.
    private static bool GroundSegmentClear(IntPtr creature, IntPtr module, Vector2 from, Vector2 to)
    {
        if (Vector2.DistanceSquared(from, to) < 1e-10f) return true;
        CNWCArea area = new CNWCModule(module).CurrentArea;
        CPathfindInformation pathfind = new CNWCCreature(creature).Pathfind;
        TestDirectLineFn test = EngineFn.TestDirectLine;
        if (area.IsNull || pathfind.IsNull || test == null) return false;
        Span<float> space = pathfind.SpaceArgs;
        Vec3 a = new() { X = from.X, Y = from.Y, Z = _floor };
        Vec3 b = new() { X = to.X, Y = to.Y, Z = _floor };
        return test(area.Ptr, creature, VectorArg.Of(&a), VectorArg.Of(&b),
                    space[0], space[1], 0) == 1;
    }

    // Slide along a wall by retrying one horizontal axis at a time.
    private static Vector2 ConstrainHorizontal(IntPtr creature, IntPtr module, Vector2 from, Vector2 target)
    {
        if (GroundSegmentClear(creature, module, from, target)) return target;
        Vector2 x = new(target.X, from.Y);
        if (GroundSegmentClear(creature, module, from, x)) from = x;
        Vector2 y = new(from.X, target.Y);
        if (GroundSegmentClear(creature, module, from, y)) from = y;
        return from;
    }

    private static void WriteCreaturePosition(IntPtr player, Vector3 target)
    {
        // This API is already used by StepGuardService to restore the player's
        // model after rejecting a movement step. Both the native creature and
        // its desired movement point are updated in this local experiment.
        var c = new CNWCCreature(player);
        Vec3 n = new() { X = target.X, Y = target.Y, Z = target.Z };
        c.SetPosition(VectorArg.Of(&n));
        ref Vector3 desired = ref c.DesiredPos;
        desired = target;
        _expectedZ = target.Z;
    }

    private static void Land(IntPtr player, bool restore)
    {
        Vector3 current = new CNWCObject(player).Position;
        if (Finite(current) && (!restore || MathF.Abs(current.Z - _expectedZ) <= 0.25f))
            WriteCreaturePosition(player, new Vector3(current.X, current.Y, _floor));
        _rise = 0f;
        _velocity = 0f;
        _airborne = false;
        if (!restore) _lands++;
    }

    private static bool Finite(Vector3 p)
        => float.IsFinite(p.X) && float.IsFinite(p.Y) && float.IsFinite(p.Z);

    // Run after the engine's native walking step. Preserve its actual X/Y and
    // restore our current airborne height if the walkmesh flattened Z.
    // This method does not integrate gravity or consume input.
    internal static void AfterWalk(IntPtr creature)
    {
        if (!_airborne || creature == IntPtr.Zero || creature != _creature ||
            CameraService.Module() != _module) return;
        Vector3 actual = new CNWCObject(creature).Position;
        if (!Finite(actual)) return;
        Vector3 desiredAir = new(_air.Position.X, _air.Position.Y, _expectedZ);
        Vector2 planarError = new(actual.X - desiredAir.X, actual.Y - desiredAir.Y);
        // A large correction is a teleport/authority reset, not a walking step.
        if (planarError.LengthSquared() > 16f || MathF.Abs(actual.Z - desiredAir.Z) > MaximumRise + 0.4f)
        {
            _airborne = false;
            JumpPreview.Reset();
            _aborts++;
            return;
        }
        if (Vector3.DistanceSquared(actual, desiredAir) < 0.015f * 0.015f) return;
        WriteCreaturePosition(creature, desiredAir);
        _walkReapplies++;
    }

    // If the host repeatedly overwrites Z, this is a client-authority failure,
    // not something that can be fixed by moving the model or camera again.
    internal static string Diagnostics()
        => $"native jump: jumps={_jumps} landed={_lands} corrected={_corrections} "
         + $"rejected={_aborts} rise={_rise:0.000} walkReapplies={_walkReapplies} airInput={_airSteerFrames} blocked={_airBlockedSteps}";
}
