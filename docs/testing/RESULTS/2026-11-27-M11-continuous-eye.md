# Phase 13C.2 — Continuous animated eye observation

OBSERVED: owner reports perspective change gone, but a small perceptible pre-hop at jump onset remains. Fresh cx.log SHA-256 e99e6782a92203e0ae9ef4a6fe28e8175ff6b18944c7d846e919881436dc4b4d (2,058,787 bytes, 7,464 lines) identifies source 0ae674ac at L1; CameraService.SelfCheck passed L365, unrelated SSAO self-check failed L150. All 96 capped [efpjump] samples tracked=True and matched Alloy view, 2560x1440, requested/before/after/draw vertical 58.716, projection scales 1.00000/1.77778, drawEyeDelta 0.0000. Eight complete sampled jumps plus ninth partial; 15 launch/15 land_on_ground events in separate JumpSlope-J4 trace. Nine sampled takeoffs actor rises 0.0278–0.0422 m, offsetZ changes -0.0402 to -0.0299 m, sum world eyeZ changes -0.0024 to +0.0048 m. OffsetStep norm 0.0347–0.0546 m at takeoff, 0.0095–0.0830 m at eight landings. Direct tracking remains active, but initial camera rise is almost canceled. Pose timing or animated dip plausible, not established; sampled actor motion alone does not prove a second hop or establish exact rendered body motion. READ: JumpPositionService initializes one ballistic launch, then advances actor using SetPosition, before camera follow. Do not add compensating camera offsets, alter jump physics, or restore a separate airborne state machine based on this evidence. Preserve continuous-eye candidate for further isolated inspection; verify stationary versus moving symptom and whether model-root/world-head update timing accounts for the cancellation. No raw log committed, no independent installed DLL rehash or full regression checklist. #13 remains open, #12 queued.

| Jump | Takeoff log line | Actor Z step (m) | Relative eye Z step (m) | World eye Z step (m) |
| --- | ---: | ---: | ---: | ---: |
| 1 | 2684 | 0.0389 | -0.0377 | 0.0012 |
| 2 | 2743 | 0.0334 | -0.0312 | 0.0022 |
| 3 | 2896 | 0.0422 | -0.0402 | 0.0020 |
| 4 | 2991 | 0.0367 | -0.0366 | 0.0001 |
| 5 | 3044 | 0.0333 | -0.0341 | -0.0008 |
| 6 | 3105 | 0.0278 | -0.0302 | -0.0024 |
| 7 | 3160 | 0.0373 | -0.0325 | 0.0048 |
| 8 | 3199 | 0.0382 | -0.0387 | -0.0005 |
| 9 | 3241 | 0.0303 | -0.0299 | 0.0004 |

World eye Z step is actorStep.Z + offsetStep.Z at logged precision. No claim of full jump acceptance. Source and build pin unchanged.
