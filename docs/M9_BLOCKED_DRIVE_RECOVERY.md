# M9 — Blocked drive recovery

Log (2026-11-25): key mask zero, native drive stays 1, guard repeatedly reverses displacement. M6 abort at 156.85 ms, drive finally 1->0 at 908.23 ms. Send result is not acknowledgement. M8 exact binary hash unavailable in log.

M9 attempts the existing abort earlier on release with two recent same-player/area guard refusals, then at most three total attempts (including explicit release abort), at least 200 ms apart within one second, only while post-release refusals persist and drive remains active. No new opcode, local animation or drive flag writes. Existing M7/M8 camera guard remains; faster release of the original sweep (6->10 fraction/s) and M8 edge correction (0.8->1.8 m/s) should reduce lingering offsets. Collision checks and hard clamp unchanged. Boot milestone marker and periodic wall-camera counters (when logs enabled). Rates provisional, may reintroduce visible release motion; camera and native animation behavior not yet verified. No claim this fixes walking while holding keys.

Source anchors reviewed; full patch-chain replay succeeded in memory for the earlier draft but this revised patch requires GitHub's full git apply and Windows compilation. No local build. Previous releases retained.
