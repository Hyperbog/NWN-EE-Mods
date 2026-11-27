# Phase 13B.2 — Horizontal FOV gameplay results

OBSERVED: owner reports all eight Phase 13B.2 horizontal FOV checks PASS. Scoped acceptance of horizontal FOV gameplay behavior; exact installed checksum, new matched projection trace and alternate aspect coverage not supplied. Owner also reports jumping still causes a weird camera adjustment and supplies two screenshots. Jump handoff correction was deliberately excluded from this build; symptom remains open, not evidence that FOV conversion failed. Prior seven matched jumps established constant sampled lens and abrupt actor-relative eye offset changes. Screenshots alone do not quantify camera displacement or prove new lens changes. Preserve horizontal FOV source 9840ead195486427478bbc38c4d08f5a3293dfa1 and release 1b69659f16e90f4e942738c64ec4790ed92fc506 as scoped accepted baseline. Next Phase 13C.1: refine reviewed jump continuity patch, especially start landing recovery only on valid animated eye, camera identity, airborne yaw handling, sample settled beyond blend; retain diagnostics for verification. No runtime changes, #13 remains open, #12 queued.

| Scenario | Owner result |
| --- | --- |
| Horizontal FOV setting displays correctly | PASS |
| 90° FOV provides natural perspective | PASS |
| Peripheral stretching reduced | PASS |
| FOV setting persists after restart | PASS |
| Reticle and target selection accurate | PASS |
| Dialogue and camera-mode transitions functional | PASS |
| Combat synchronization preserved | PASS |
| Movement and camera immersion preserved | PASS |

Jump camera adjustment: persists, as expected for this isolated lens checkpoint. No raw screenshots or private configuration committed.
