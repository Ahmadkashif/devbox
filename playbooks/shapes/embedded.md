# Embedded firmware

> Firmware for microcontrollers and devices: bare metal, RTOS, embedded Linux, IoT

## When this applies

- Code running on microcontrollers or SoCs with tight memory, power and timing constraints.
- Connected devices (IoT) with over-the-air updates, and the companion protocols they speak.
- The cloud backend for a fleet: also read `api-service` and `infrastructure`. A companion phone app: also read `mobile`.

## Default architecture

- Layers with one-way dependencies: HAL/BSP -> drivers -> RTOS or middleware (Zephyr, FreeRTOS) -> application logic.
- Application logic as explicit state machines or active objects (event queues), not ad hoc flags across ISRs.
- Static memory allocation only after initialization; no heap use in steady state.
- Hardware access behind interfaces so application code builds and runs on the host with fakes.
- A signed bootloader (for example MCUboot) with A/B (or primary/secondary) slots and anti-rollback counters; automatic rollback when the new image fails its post-update health check.
- A watchdog strategy that proves liveness of every critical task, not just one loop.
- Avoid starting with: testing only on target hardware, dynamic allocation in ISRs, a custom RTOS, debug shells and default credentials that "we will remove later".

## Quality attributes

- Real-time determinism: worst-case execution and response times for each deadline, measured.
- Resource budgets: flash, RAM and stack usage per task with headroom (track per build).
- Power budget: average and sleep current targets, battery life estimate.
- Functional safety where it applies: IEC 61508, ISO 26262 (automotive), IEC 62304 (medical).
- Security: secure boot, signed images, per-device credentials, ETSI EN 303 645 for consumer IoT. The EU Cyber Resilience Act requires exploited-vulnerability reporting (from 11 Sep 2026) and full compliance by 11 Dec 2027 for products sold in the EU.
- Field updatability and long lifetime: updates must never brick a device, even on power loss mid-update.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Which MCU or SoC, memory sizes, clock, power source? Is hardware final or still changing?
- Which deadlines are hard real-time, and what happens if one is missed?
- Power and battery life targets; sleep modes required.
- Which safety or regulatory standards apply? Which markets (EU CRA)?
- How are devices provisioned, identified and updated in the field? What is the expected device lifetime?
- What telemetry and crash data comes back from the field?

/devbox:design should decide and record:

- Coding standard (MISRA C:2025 or BARR-C:2018, plus SEI CERT C) and the deviation process.
- Task and interrupt model: priorities, what runs in ISRs (minimal), shared data protection, priority inversion avoidance.
- Memory map, partition layout, bootloader and update scheme.
- Host-side test strategy and the hardware-in-the-loop rig.
- Toolchain version pinned in a container for reproducible builds.

## Testing strategy

- Host unit tests with hardware fakes (Unity, CMock and Ceedling, or GoogleTest) for drivers' logic and application state machines.
- Static analysis: a MISRA checker (cppcheck Premium, PC-lint, Polyspace or Helix QAC) plus clang-tidy, with logged deviations.
- Compiler strictness: `-Wall -Wextra -Werror`; stack usage analysis with `-fstack-usage`.
- Software-in-the-loop on emulators (Renode, QEMU) in CI.
- Hardware-in-the-loop rigs in CI (for example LabGrid) running a smoke suite on every merge.
- Fuzz protocol parsers and packet decoders on the host.
- Timing and power profiling on real hardware for every release.
- Fault injection: power cut during OTA, corrupted image, full flash, brownout.

## Walking skeleton

T001 delivers: a reproducible containerized build that produces a signed image, flashed through the bootloader, blinking (or reporting) a heartbeat from a state machine task, with a host unit test for that state machine, the watchdog enabled, and a CI job that builds, runs host tests and static analysis.

## Checklist

- [ ] Coding standard enforced by a checker; deviations logged and justified
- [ ] `-Wall -Wextra -Werror` and stack usage analysis per build
- [ ] No heap allocation after initialization
- [ ] Watchdog covers every critical task
- [ ] ISRs minimal; shared data protected (atomics, volatile where correct, critical sections)
- [ ] Secure boot with signed images and anti-rollback
- [ ] A/B OTA with automatic rollback on failed health check; power-cut-during-update tested
- [ ] Per-device unique credentials; no default passwords
- [ ] JTAG/SWD debug ports locked in production builds
- [ ] SBOM and a vulnerability disclosure process (EU CRA)
- [ ] Toolchain pinned in a container; builds reproducible
- [ ] HIL smoke test runs on every merge
- [ ] Field crash dumps and telemetry collected and symbolicated
- [ ] Flash, RAM and stack budgets tracked with headroom

## Pitfalls

- Testing only on the target, so feedback takes minutes and coverage stays low.
- Non-atomic updates that brick devices on power loss.
- Integer promotion and signedness bugs; unchecked casts between widths.
- Priority inversion between tasks sharing a mutex.
- Blocking calls or heavy work inside ISRs.
- Debug shells, verbose logs or test keys left enabled in production.
- Assuming the hardware revision will not change.

## Verify gates

```
DEVBOX_FORMAT_CMD=clang-format --dry-run --Werror $(git ls-files '*.c' '*.h')
DEVBOX_LINT_CMD=run-clang-tidy -p build && cppcheck --enable=warning,style --error-exitcode=1 src/
DEVBOX_TEST_CMD=cmake --preset host-test && cmake --build --preset host-test && ctest --preset host-test --output-on-failure
DEVBOX_BUILD_CMD=cmake --preset target && cmake --build --preset target
```

CI extras: MISRA checker report, size report diff against main, emulator run, HIL smoke on a rig.

## Sources

- https://misra.org.uk/ (MISRA C:2025, MISRA C++:2023)
- https://barrgroup.com/embedded-systems/books/embedded-c-coding-standard
- https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard
- https://spinroot.com/gerard/pdf/P10.pdf (NASA/JPL Power of 10)
- https://www.etsi.org/technologies/consumer-iot-security
- https://digital-strategy.ec.europa.eu/en/policies/cyber-resilience-act
- https://docs.mcuboot.com/
- https://uptane.org/
- https://renode.io/
