# SHAI Integration - Development Notes

## REAI Optimization Analysis

After comparing REAI (`/home/user/reai/`) and SH (`/home/user/pd2-streamlined-heisting/`), **SH independently implemented nearly all the same optimizations as REAI**. The SHAI layer hooks on top of SH's already-optimized base code.

### Overlap Matrix

| REAI Optimization | SH Has It? | In SHAI? | Action Taken |
|---|---|---|---|
| CopActionShoot LOD frame skip | Yes (identical) | YES | No work needed |
| CopActionWalk LOD frame skip | Yes (full override) | SH handles | No work needed |
| set_visibility_state LOD visibility | Yes (SH copbase) | SH handles | No work needed |
| chk_freeze_anims at walk transitions | Yes (3 call sites) | SH handles | No work needed |
| CopActionWalk husk speedup | Yes (conservative) | SH handles | No work needed |
| ActionSpooc husk speedup | Yes (`_needs_speedup`) | SH handles | No work needed |
| EnemyManager task queue | Yes (sophisticated) | SH handles | No work needed |
| **HuskCopBase `_allow_invisible`** | **NO** | **NO** | **Ported** ✓ |
| **CivilianBase `_allow_invisible`** | In disabled group | **NO** | **Ported** ✓ |
| **TeamAI/HuskTeamAI freeze support** | Partial | **NO** | **Ported** ✓ |

### REAI-Unique Optimizations Ported

Files created:
- `shai/aitweaks/huskcopbase_lod.lua` — enables invisible LOD for husk cops
- `shai/aitweaks/civilianbase_lod.lua` — enables invisible LOD for civilians
- `shai/aitweaks/teamaibase_lod.lua` — shares chk_freeze_anims to TeamAI/HuskTeamAI

### Key Formula Differences (Where Both Exist)

- **Frame skip**: REAI `lod * 3` vs SH `lod` skip count
- **Husk speedup**: REAI `1 + lod_mul` (max 2x) vs SH `0.85 + lod_mul` (max ~1.5x)
- **Task queue**: SH has sorted execution, stealth bypass, more production-quality

### REAI Variable Name Reference (Decompiled → Human-Readable)

```
arg_X_0 = self (first argument)
arg_X_1 = second argument (t, stage, move_dir, etc.)
var_X_Y = local variable Y in function X
iter_X_Y = loop variable Y in function X
var_0_N = file-level locals (cached functions)
```

## Existing SHAI Files (SH-ported, already working)

- `shai/groupaitweakdata.lua` — spawn groups, balance multipliers, force/pool values
- `shai/groupaistatebase.lua` — group AI state base
- `shai/groupaistatebesiege.lua` — besiege fade override, reenforce, distance cache
- `shai/aitweaks/cop/actions/copactionshoot.lua` — LOD frame skipping (already ported)
- `shai/aitweaks/cop/actions/copactionhurt.lua` — joker no-stagger fix
- `shai/aitweaks/cop/logics/coplogictravel.lua` — REAI Masochism movement
- `shai/firemanager.lua` — fire raycast optimization

## Previous Completed Work

- REAI Masochism-mode movement rewrite in coplogictravel.lua
- Joker no-stagger crash fix in copactionhurt.lua (common_data.unit instead of self._unit)
- Spawn group weight tables + enemy_spawn_groups definitions
- Balance multipliers (force_balance_mul, force_pool_balance_mul)
- Grenade settings, chatter data, special unit limits

## Known Issue: Low Kill Count (200-300 vs vanilla 400)

Under investigation. Possible causes:
- SH `force = {8,11,14}` caps ~23 active cops (SHAI overrides to {24,29,35})
- SH passive/ranged tactics reduce engagement rate
- HH besiege sustain_duration originally {0,0,0} (SHAI overrides with lerp values)
- `_enemies_killed_sustain` only counts kills during sustain phase or hunt_mode
- First assault force_pool multiplied by 0.75, second by 0.80
