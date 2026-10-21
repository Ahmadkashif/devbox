# Browser extension

> Manifest V3 extensions for Chrome, Edge, Firefox and Safari

## When this applies

- Extensions that modify pages, add toolbar UI, integrate with a web service, or automate browser tasks.
- Cross-browser extensions built from one codebase (for example with WXT).
- The UI parts (popup, options page, side panel) also follow `web-app` for accessibility and UI testing. A backend the extension calls: also read `api-service`.

## Default architecture

- Manifest V3 only. Manifest V2 was disabled for users in Chrome in 2025 and remaining MV2 listings were scheduled for removal from the Chrome Web Store (check the current timeline).
- An ephemeral service worker as the background context. It can be terminated at any time, so all state lives in `chrome.storage` (or IndexedDB), never in global variables.
- Content scripts run in the isolated world; they talk to the service worker through validated message passing.
- Use `declarativeNetRequest` for request blocking and modification rather than intercepting traffic in code.
- A cross-browser build tool (WXT or similar) that generates per-browser manifests.
- Avoid starting with: broad host permissions (`<all_urls>`) when `activeTab` works, remotely hosted code (forbidden by store policies), injecting into the page's main world without a strong reason.

## Quality attributes

- Least privilege: the smallest set of permissions and host permissions; optional permissions requested at the moment of use.
- Robustness: survives service worker termination and browser restarts without losing state.
- Performance: content scripts add no noticeable delay to page load; work deferred and scoped to matching pages.
- Security: page content and messages from content scripts are hostile input; strict extension CSP.
- Privacy: accurate store privacy disclosures; data collection minimal and declared.
- Store compliance for every target store.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Which browsers and stores? Is Safari (which needs an app wrapper) required?
- On which sites does it run, and can it work with `activeTab` instead of host permissions?
- What data does it read from pages, store, or send anywhere? What will the privacy disclosure say?
- Does it need to work offline or without an account?
- How are updates and breaking changes to stored data handled?

/devbox:design should decide and record:

- Permission list with a one-line justification each (stores ask for this too).
- Message protocol between content scripts, service worker and UI pages, with schemas.
- Storage schema and migrations across versions.
- Build and release pipeline per store.

## Testing strategy

- Unit tests on message handlers, storage logic and parsing of page content.
- Message validation tests with malformed and malicious payloads.
- End-to-end tests with Playwright loading the unpacked extension in Chromium, covering install, the main flow, and a service worker restart.
- Cross-browser smoke tests for Firefox and Safari builds.
- Popup and options page tested like any web UI (Testing Library, axe).
- Mock only remote services.

## Walking skeleton

T001 delivers: an MV3 manifest with minimal permissions, a service worker that persists one setting in `chrome.storage`, a content script that sends one validated message, a Playwright test that loads the unpacked extension and exercises that path, and a CI job that builds the store package.

## Checklist

- [ ] Manifest V3; `activeTab` and `optional_permissions` preferred over broad host permissions
- [ ] Host permissions narrowed to the sites actually needed
- [ ] No remotely hosted code; everything shipped in the package
- [ ] Strict extension CSP
- [ ] Page data and incoming messages treated as hostile and validated
- [ ] No secrets in the package (it is readable by anyone)
- [ ] All state survives service worker termination
- [ ] Playwright tests run with the extension loaded
- [ ] Accurate privacy disclosures and data-use declarations in each store
- [ ] Storage migrations tested across versions
- [ ] Popup and options pages keyboard accessible with labeled controls

## Pitfalls

- Keeping state in service worker globals, which vanish when it is terminated.
- Requesting `<all_urls>` and getting rejected or distrusted.
- Trusting `window.postMessage` or DOM content from the page.
- Remote code loading that violates store policy.
- Slow content scripts that run on every page.

## Verify gates

Use the TypeScript defaults from `.devbox/playbooks/languages.md`, plus:

```
DEVBOX_TEST_CMD=pnpm test && pnpm exec playwright test
DEVBOX_BUILD_CMD=pnpm run build && pnpm exec web-ext lint --source-dir .output/firefox-mv3   # path depends on the build tool
```

## Sources

- https://developer.chrome.com/docs/extensions
- https://developer.chrome.com/docs/extensions/develop/migrate/mv2-deprecation-timeline
- https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions
- https://developer.apple.com/documentation/safariservices/safari-web-extensions
- https://wxt.dev/
- https://playwright.dev/docs/chrome-extensions
