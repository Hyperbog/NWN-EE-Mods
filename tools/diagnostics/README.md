# Inactive diagnostic probes

READ: These two historical C# sources were moved byte-for-byte from `src/diagnostics/` in Phase 1.4. They are retained for future diagnosis, not built or installed as standalone plugins. The active M11 build reconstructs only the pinned CX base, the modules listed in `src/first-person/SOURCE_MANIFEST.json`, and the ordered patches in `src/first-person/BUILD_PLAN.json` via `tools/cloud_build.py`. Neither file below is an overlay entry.

| Probe | Intended observations | Limits |
|---|---|---|
| [FirstPersonModelProbe.cs](FirstPersonModelProbe.cs) | Historical Fix14B model/part sampling; mapped head, attachments, part pivots; `modelprobe:` and `[fpmodel]` | Pivot distances are not mesh bounds or collision tests. Do not confuse this historical copy with the distinct active overlay of the same name. |
| [FirstPersonMoveProbe.cs](FirstPersonMoveProbe.cs) | Input/drive state, XY speed, desired-position gap, gait and head changes; `[fpmove]` | Heuristic telemetry, not proof of a root cause. References historical CX/EFP members, including the model probe's HeadModel; compatibility with M11 and this historical model-probe copy is not established. |

## Use restrictions

- Do not copy either file into the active managed tree or overwrite the active `FirstPersonModelProbe.cs` or `Fix14CProbe.cs`.
- Before activating a probe, link an issue, state the hypothesis and discriminating observation, audit APIs against the reconstructed candidate, and define acceptance criteria. Review gating, logging volume and any privacy-sensitive values.
- Compile and test a separately identified candidate before asking for installation. Do not silently change the installed M11 candidate.
- Keep raw logs, saves, configuration, DLLs and personal paths out of Git. Record sanitized excerpts in the applicable test result.

## Provenance and rollback

The original files remain available at the Phase 1.3 checkpoint [78d60bd](https://github.com/Hyperbog/NWN-EE-Mods/tree/78d60bd8b30786e60869534aefc27bb49d97e160/src/diagnostics). Revert the relocation commit (not a reset or force-push) to restore the original paths. Historical documentation is not rewritten.
