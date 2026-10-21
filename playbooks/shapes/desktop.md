# Desktop app

> Installable desktop applications for Windows, macOS and Linux (Tauri, Electron, native)

## When this applies

- Apps installed on a user's computer: editors, productivity tools, companions to web services, device utilities.
- Webview-based apps (Tauri, Electron) and native toolkits (SwiftUI/AppKit, WinUI, Qt, GTK).
- A desktop app that wraps a web UI: also read `web-app` for the UI half.

## Default architecture

- Prefer Tauri (Rust core plus the system WebView) for smaller binaries and a capability-based permission model; choose Electron when you need Chromium consistency or its ecosystem. Record the choice in an ADR.
- Privilege separation: the main/core process holds privileges; the renderer is untrusted. In Electron, the preload script exposes a narrow, typed API through `contextBridge`, never `ipcRenderer` wholesale.
- Every IPC message is a contract: validate sender and arguments on the privileged side.
- Signed auto-update (electron-updater or the Tauri updater plugin) with release channels (beta, stable) and rollback.
- Local data in the OS-appropriate app data directory; credentials in the OS keychain (`safeStorage`, keyring).
- Avoid starting with: `nodeIntegration` in renderers, `file://` loading of app content, unsigned builds, a custom update server without signature verification.

## Quality attributes

- Remote code execution resistance: the renderer must not be able to reach the OS except through vetted IPC.
- Update reliability: N-1 to N and old-version to N upgrades always succeed; failed updates roll back.
- Startup time and memory footprint within budgets in design.md, measured on modest hardware.
- OS integration: native menus, shortcuts, file associations, notifications behave per platform conventions.
- Accessibility: keyboard navigation and screen reader support on every platform.
- Trust: signed and notarized builds so Gatekeeper and SmartScreen do not warn users.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Which operating systems and versions? CPU architectures (x64, arm64)?
- Which OS capabilities are needed (file system scope, shell, network, devices, tray, startup at login)?
- How are updates delivered, and can users defer them? Is there an enterprise deployment need (MSI, MDM)?
- What data is stored locally, and is any of it sensitive?
- Does it need to work offline? What syncs with a server?

/devbox:design should decide and record:

- Framework choice (ADR), process model, the IPC contract list.
- For Tauri: per-window capabilities and scoped permissions (fs, shell, http). For Electron: fuses and BrowserWindow security options.
- Signing identities (Apple Developer ID with notarization, Windows code signing such as Azure Artifact Signing), where keys live, who can sign.
- Update channel strategy and rollback plan.

## Testing strategy

- Unit tests on core logic and on IPC handlers (including malicious argument cases).
- IPC contract tests: the renderer-facing API and the privileged handlers agree on shapes.
- End-to-end with Playwright (Electron) or tauri-driver (Tauri) on critical flows.
- CI matrix on Windows, macOS and Linux runners.
- Update-path tests: install N-1, update to N; install an old version, update to N; interrupted update recovers.
- Signature verification in CI: `codesign --verify` and `spctl --assess` on macOS, `signtool verify` on Windows.
- Mock only remote services; use real temporary directories for file operations.

## Walking skeleton

T001 delivers: a window that loads the app UI from a custom protocol (not `file://`), one IPC call from renderer to core with validated arguments and a test, a signed build for one platform from CI, and a working update check against a staging channel.

## Checklist

- [ ] Electron: `contextIsolation` on, `nodeIntegration` off, `sandbox` on for every window
- [ ] Strict Content Security Policy on all app content
- [ ] Sender and arguments validated for every IPC message
- [ ] Navigation and new-window creation restricted to an allowlist
- [ ] URLs passed to `shell.openExternal` (or the Tauri shell) validated against an allowlist
- [ ] App content served from a custom protocol, not `file://`
- [ ] Electron fuses set: RunAsNode off, OnlyLoadAppFromAsar on, ASAR integrity validation on
- [ ] On a supported Electron major (or current Tauri), with a plan to keep up
- [ ] macOS: hardened runtime, Developer ID signing, notarization; Windows: Authenticode signing
- [ ] Updates over HTTPS with signature verification and rollback
- [ ] Tokens and credentials in the OS keychain, never in plain files
- [ ] Tauri: least-privilege capabilities per window; fs and shell scopes as narrow as possible
- [ ] Crash reporting with symbols; logs written to the platform log directory without secrets
- [ ] Keyboard and screen reader pass on each supported OS

## Pitfalls

- Exposing `ipcRenderer` or Node APIs to the renderer, turning any XSS into remote code execution.
- Unsigned builds that trigger SmartScreen and Gatekeeper warnings and train users to click through.
- An update feed without signature verification.
- Shipping a stale Chromium with known vulnerabilities.
- Loading remote content into a privileged window.
- Testing only on the developer's OS.

## Verify gates

Use the stack defaults from `.devbox/playbooks/languages.md` (TypeScript for the UI, Rust for a Tauri core), plus:

```
DEVBOX_TEST_CMD=pnpm test && cargo test --manifest-path src-tauri/Cargo.toml
DEVBOX_BUILD_CMD=pnpm tauri build   # or electron-builder --dir
```

CI extras: OS matrix build, signature verification steps, `@electron/fuses` read-back check, E2E smoke per OS.

## Sources

- https://www.electronjs.org/docs/latest/tutorial/security
- https://www.electronjs.org/docs/latest/tutorial/fuses
- https://v2.tauri.app/security/
- https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution
- https://learn.microsoft.com/en-us/azure/artifact-signing/
- https://theupdateframework.io/
