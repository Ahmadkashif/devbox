# Game

> Video games and real-time interactive simulations on PC, console, mobile, web or VR

## When this applies

- Games built with an engine (Unity, Unreal, Godot, Bevy) or a custom loop.
- Real-time simulations, interactive visualizations and VR/AR experiences with frame budgets.
- Online games also read `api-service` and `infrastructure` for backends; mobile games also read `mobile`.

## Default architecture

- Fixed-timestep simulation with interpolated, variable-rate rendering ("Fix Your Timestep"). Physics and gameplay never depend on frame rate.
- Entity Component System for hot paths with many similar entities (Bevy, Flecs, Unity Entities); plain components or scene nodes elsewhere. Prefer composition over deep inheritance.
- Data-driven tuning: values in data files or assets that designers can change and hot-reload without a rebuild.
- Seeded random number generators so runs can be reproduced.
- Multiplayer: deterministic simulation with lockstep or rollback netcode, or a server-authoritative model with client prediction. Decide before writing gameplay code.
- Save files versioned with explicit migrations.
- Avoid starting with: an engine of your own when an existing one fits, art pipelines before the core loop is fun, networking bolted onto a single-player architecture.

## Quality attributes

- Frame budget, judged on p95 and p99 frame times, not average FPS:
  - 60 fps: 16.6 ms per frame
  - 90 fps (VR minimum): 11.1 ms per frame
  - 120 fps: 8.3 ms per frame
- Per-system budgets inside the frame (simulation, rendering, audio, UI), with profiler markers.
- Memory budgets per platform; load times; input latency.
- Accessibility: input remapping, subtitles, color-blind modes, difficulty and assist options (Game Accessibility Guidelines, Xbox Accessibility Guidelines).
- Stability: crash rate per build; symbolicated crash reports.
- Fun: measured through playtests, not assumed.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- What is the core loop in one sentence, and what makes it fun? How will a playtest prove it?
- Target platforms, minimum-spec hardware, frame rate and resolution targets.
- Single player, local multiplayer or online? Competitive (needs determinism or authority) or cooperative?
- Input devices (controller, keyboard and mouse, touch, motion controllers).
- Save system expectations, cloud saves, cross-platform progression.
- Platform certification requirements (console TRC/XR checklists, store rules).

/devbox:design should decide and record:

- Engine choice (ADR), simulation timestep, entity model.
- Netcode model and tick rate, if online.
- Asset pipeline, streaming and level-of-detail strategy, memory budgets.
- Profiling plan: which captures run in CI, which thresholds fail a build.
- Telemetry events for playtest funnels (where players quit or get stuck).

## Testing strategy

- Unit tests on pure gameplay systems (damage formulas, inventory rules, AI decisions) separated from rendering.
- Deterministic replay tests: record inputs, replay with the same seed, assert identical state.
- Bot playthrough smoke tests that load every level and run scripted paths in CI.
- Frame-time regression captures in CI: fail on p95/p99 regressions against main.
- Soak tests for memory leaks over long sessions.
- Save file migration tests from every shipped save version.
- Scheduled playtests (internal and external) with telemetry funnels; treat findings like bugs.
- Mock platform services (achievements, matchmaking) in automated tests.

## Walking skeleton

T001 delivers: a fixed-timestep loop with one controllable entity in one level, input remapping wired, a profiler marker per system, a unit test on one gameplay rule, a deterministic replay test, and a CI build for the primary platform that runs the smoke test.

## Checklist

- [ ] Fixed timestep for simulation; rendering interpolated
- [ ] Per-system frame budgets with profiler markers; p95/p99 frame time tracked in CI
- [ ] No per-frame allocations in hot loops
- [ ] Asset streaming and level of detail meet memory budgets on minimum spec
- [ ] Input remapping, subtitles and color-blind modes available
- [ ] Save files versioned with tested migrations
- [ ] Symbolicated crash reports collected per build
- [ ] Seeded RNG; deterministic replays work
- [ ] Platform certification checklist reviewed for each target
- [ ] Reproducible per-platform builds from CI
- [ ] Hot-reload for tuning values
- [ ] Playtest telemetry funnels in place before external playtests
- [ ] Tested on minimum-spec hardware, not just developer machines

## Pitfalls

- Physics or gameplay tied to frame rate, so behavior changes on faster hardware.
- Optimizing average FPS while stutters (p99 spikes) ruin the feel.
- Playtesting too late, after the core loop is expensive to change.
- Deep inheritance hierarchies for entities that need to mix behaviors.
- Ignoring minimum-spec hardware until certification.
- Garbage collection spikes from per-frame allocations.

## Verify gates

Engine-specific; typical gates:

```
DEVBOX_TEST_CMD=<engine test runner, e.g. Unity -runTests -batchmode, cargo test for Bevy, godot --headless with GUT>
DEVBOX_BUILD_CMD=<headless build for the primary platform>
```

CI extras: bot smoke test across levels, frame-time capture compared with main, replay determinism check.

## Sources

- https://gameprogrammingpatterns.com/
- https://gafferongames.com/post/fix_your_timestep/
- https://gameaccessibilityguidelines.com/
- https://learn.microsoft.com/en-us/gaming/accessibility/guidelines
- https://docs.unity3d.com/Manual/Profiler.html
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-insights-in-unreal-engine
- https://docs.godotengine.org/
- https://bevyengine.org/learn/
