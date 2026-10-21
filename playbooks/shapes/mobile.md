# Mobile app

> Native and cross-platform iOS and Android apps, offline-first by default

## When this applies

- Apps distributed through the App Store, Google Play, or enterprise channels.
- Cross-platform apps (Kotlin Multiplatform, Flutter, React Native with the New Architecture).
- The backend the app talks to: also read `api-service`. On-device models: also read `ml-system`.

## Default architecture

- Unidirectional data flow (MVVM or MVI): UI (SwiftUI or Jetpack Compose) observes state from a ViewModel, which talks to repositories.
- The local database is the single source of truth (Room, SwiftData, GRDB, SQLite). The UI reads local data; a sync engine reconciles with the server in the background (WorkManager on Android, BGTaskScheduler on iOS).
- Feature modules with clear boundaries so builds stay fast and features can be flagged off.
- Server-driven safety valves: minimum supported version (forced upgrade), feature flags, and a kill switch for risky features.
- Secrets and tokens in the Keychain or Android Keystore; nothing sensitive in the app bundle.
- Avoid starting with: the network as the source of truth, a home-grown navigation framework, a cross-platform choice made before checking which native capabilities you need, analytics SDKs you have not reviewed for data collection.

## Quality attributes

- Crash-free sessions >= 99.5% (track crashes and ANRs per release).
- Cold start within a budget agreed in design.md (measure on a mid-range device, not a flagship).
- No jank: frames rendered within the display's budget (16.6 ms at 60 Hz, 8.3 ms at 120 Hz); no I/O on the main thread.
- Battery and data: background work batched and constrained (charging, unmetered network) where possible.
- Offline resilience: core read flows work offline; writes queue and sync idempotently.
- Accessibility: Dynamic Type and font scaling, screen reader labels (VoiceOver, TalkBack), touch targets >= 44 pt on iOS and >= 48 dp on Android.
- Security and privacy: OWASP MASVS v2.1 (eight control groups including PRIVACY), Apple privacy manifest, Google Play Data safety form.
- Store requirements: Google Play requires new apps and updates to target API 36 (deadline 31 Aug 2026; check the current requirement); native libraries must support 16 KB page sizes.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Which platforms and minimum OS versions? Phones, tablets, foldables?
- What must work offline, and what happens on conflict when two devices edit the same data?
- Which device capabilities are needed (camera, location, notifications, background work) and which permissions does that imply?
- What personal data is collected, and what goes into the privacy manifest and Data safety form?
- Release cadence and how fast a bad release must be stopped.
- Deep links and universal links / app links: which URLs open the app?

/devbox:design should decide and record:

- Native vs cross-platform, with the capability check that drove it (ADR).
- Local schema, sync protocol, conflict resolution policy (last-writer-wins, merge, server-authoritative), and migration plan.
- Navigation model and state restoration after process death.
- Push notification strategy and token lifecycle.
- Release plan: beta tracks, staged rollout percentages, the metric that halts a rollout.

## Testing strategy

- Unit tests for ViewModels, repositories and the sync engine (fake the network and the clock).
- UI tests with XCUITest or Swift Testing plus Compose UI tests for critical flows.
- Snapshot tests for key screens across font sizes, dark mode and right-to-left.
- Device farm runs on a matrix of real devices and OS versions before release.
- Network chaos: airplane mode, slow and flaky connections, server errors mid-sync.
- Process death and restoration tests (Android "Don't keep activities", iOS state restoration).
- Security tests mapped to OWASP MASTG; check storage, network, and platform interaction controls.
- Beta distribution (TestFlight, Play internal/closed testing) before every production rollout.

## Walking skeleton

T001 delivers: an app that launches to one screen reading from the local database, a sync job that pulls one resource from the real (or staging) API into it, a unit test on the repository, a UI smoke test, crash reporting wired, and a CI build that produces signed beta artifacts.

## Checklist

- [ ] Local database is the source of truth; conflict-resolution policy documented and tested
- [ ] Sync is idempotent with exponential backoff and survives app restarts
- [ ] Tokens and secrets in Keychain or Keystore; no API secrets in the binary
- [ ] TLS enforced (App Transport Security, Network Security Config); no cleartext traffic
- [ ] Privacy manifest and Play Data safety form accurate and reviewed
- [ ] Touch targets >= 44 pt / 48 dp; accessibility labels on every control; font scaling supported
- [ ] Universal links and app links verified with the hosted association files
- [ ] Crash and ANR reporting wired, with symbolication
- [ ] Server-driven minimum version so a forced upgrade is possible
- [ ] Feature flags and a remote kill switch for risky features
- [ ] Staged rollout configured, with a halt metric written in the release checklist
- [ ] No sensitive data in logs or in app-switcher snapshots
- [ ] Edge-to-edge layout and predictive back gesture handled on Android
- [ ] Permissions requested in context, only when needed, with a graceful denied path
- [ ] State restored correctly after process death

## Pitfalls

- Treating the network as the source of truth, so every screen spins on a loading indicator.
- Ignoring process death and losing user input.
- Disk or network I/O on the main thread.
- Asking for every permission at first launch.
- API keys or signing secrets compiled into the app.
- Shipping to 100% of users at once with no kill switch.
- Testing only on a flagship device and fast Wi-Fi.

## Verify gates

```
# iOS (SwiftPM or xcodebuild project)
DEVBOX_FORMAT_CMD=swift format lint --strict -r .
DEVBOX_LINT_CMD=swiftlint --strict
DEVBOX_TEST_CMD=xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=<device>'
# Android
DEVBOX_LINT_CMD=./gradlew lint detekt
DEVBOX_TEST_CMD=./gradlew testDebugUnitTest
DEVBOX_BUILD_CMD=./gradlew assembleRelease
```

CI extras: instrumented UI tests on an emulator or device farm, MASVS-oriented static scan, app size budget.

## Sources

- https://developer.apple.com/design/human-interface-guidelines
- https://m3.material.io/
- https://developer.android.com/topic/architecture
- https://developer.android.com/topic/architecture/data-layer/offline-first
- https://mas.owasp.org/ (MASVS, MASTG, MASWE)
- https://developer.android.com/google/play/requirements/target-sdk
- https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
