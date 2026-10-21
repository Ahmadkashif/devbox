# Web app

> Browser-delivered apps: SPA, SSR, SSG and multi-page sites, including the UI half of fullstack

## When this applies

- Anything a user reaches through a browser: marketing sites, dashboards, SaaS front ends, internal tools, PWAs.
- Fullstack products: combine with the API shape via `devbox init --shape web-app,api-service` and read both playbooks.
- Browser extensions have their own shape (`browser-extension`); embedded webviews in desktop apps also read `desktop`.

## Default architecture

- Start HTML-first with a server-rendering meta-framework (Next.js, React Router 7, Nuxt, SvelteKit, or Astro islands for mostly static content). Server rendering wins LCP and works before JavaScript loads.
- Progressive enhancement: links and forms work before hydration; JavaScript upgrades the experience, it does not gate it.
- Server state lives in a server-state cache (TanStack Query or the framework's loaders). Keep client state minimal and local; reach for a global store only when two distant components truly share mutable state.
- Generate a typed API client from the OpenAPI (or GraphQL/proto) contract instead of hand-writing fetch calls.
- Design tokens (color, spacing, type, radius, motion) as the single source for styling; components consume tokens, never raw hex values.
- Route-level code splitting and per-route JS budgets from day one.
- Authorization is enforced on the server. The client only hides what the server already forbids.
- Avoid starting with: a client-only SPA for content that must be fast or indexable, micro-frontends, a custom design system before you have three screens, a global state library "just in case".

## Quality attributes

Core Web Vitals, measured at p75 of real-user (field) data, are the bar:

| Metric | Good | Poor |
|--------|------|------|
| LCP (Largest Contentful Paint) | <= 2.5 s | > 4 s |
| INP (Interaction to Next Paint) | <= 200 ms | > 500 ms |
| CLS (Cumulative Layout Shift) | <= 0.1 | > 0.25 |

- Accessibility: WCAG 2.2 AA. Text contrast >= 4.5:1 (3:1 for large text), visible and unobscured focus (2.4.11), target size >= 24 x 24 CSS px (2.5.8). Do not target WCAG 3 (still a draft). The European Accessibility Act applies to many consumer products sold in the EU.
- Performance budgets: no long tasks over 50 ms on the critical path; per-route JS budget agreed in design.md (start around 170 KB compressed for the initial route and justify anything above).
- Security: strict nonce- or hash-based CSP, Trusted Types where feasible, HSTS, frame-ancestors, Referrer-Policy, X-Content-Type-Options nosniff, SameSite cookies, CSRF protection on state-changing requests.
- Resilience: usable on slow 3G and flaky networks; meaningful error and empty states; offline behavior stated (even if "shows a retry banner").
- Privacy, SEO and i18n: consent before non-essential tracking, server-rendered metadata, strings externalized, `lang` and `dir` set.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- Who are the users, on what devices and networks? Is there a minimum browser matrix?
- Which pages must be indexable or shareable (SEO, link previews)? Which are behind auth?
- What is the most important user journey, and what is its performance budget?
- What must work without JavaScript or while offline?
- Accessibility target (default WCAG 2.2 AA) and any assistive technology users we know about.
- Languages, locales, right-to-left support, time zones, currencies.
- What analytics and consent rules apply?

/devbox:design should decide and record (ADR when non-obvious):

- Rendering mode per route (SSR, SSG, ISR, client), and the reason.
- Data fetching and caching strategy, including invalidation after mutations.
- Auth and session model (cookies vs tokens, where they live, refresh flow).
- Error boundaries, client error reporting, and the loading/empty/error state for every view.
- Component library and token source; how forms validate (shared schema with the API when possible).

## Testing strategy

- Static: TypeScript strict mode, lint, format check. This is the base of the testing trophy.
- Unit: Vitest for pure logic (formatters, reducers, validation schemas).
- Component/integration: Testing Library or Vitest browser mode. Query by role and label, the way users and assistive tech find things. Mock the network at the boundary (MSW or framework test utilities), never your own components.
- End-to-end: Playwright on the critical journeys only (sign up, core task, checkout). Run axe-core inside these tests.
- Manual: keyboard-only pass and a screen-reader pass on each new flow.
- Performance: Lighthouse CI budgets in CI (lab), plus real-user monitoring with the `web-vitals` library in production (field). Field data is what users feel and what Google grades.
- Visual regression only for stable, design-critical components.

## Walking skeleton

T001 delivers: one server-rendered route that fetches real data through the generated API client (or a stub contract), renders it with design tokens, has an accessible layout with landmarks, a passing Playwright smoke test with an axe check, Lighthouse CI wired with budgets, deployed to a preview environment from CI.

## Checklist

- [ ] Core Web Vitals budgets enforced in CI and field data reported via `web-vitals`
- [ ] Semantic HTML: landmarks, headings in order, buttons are `<button>`, links are `<a>`
- [ ] Every control has an accessible name; form errors are announced and tied to fields
- [ ] Visible focus that is never obscured; full keyboard operability; no keyboard traps
- [ ] Targets >= 24 x 24 px; contrast >= 4.5:1; `prefers-reduced-motion` honored
- [ ] axe-core checks pass in E2E; manual keyboard and screen-reader pass recorded in progress.md
- [ ] Core flows work before hydration (forms post, links navigate)
- [ ] Strict CSP plus security headers; cookies HttpOnly, Secure, SameSite; CSRF protection
- [ ] LCP image has `fetchpriority="high"`; all images have explicit width and height; below-the-fold media lazy-loaded
- [ ] Per-route JS budget met; no unused polyfills; fonts preloaded with `font-display` set
- [ ] Error boundaries and client error reporting wired; no blank screens on failure
- [ ] Loading, empty and error states designed for every data view
- [ ] Strings externalized; `lang` and `dir` set on the document
- [ ] Authorization checked on the server for every protected route and action
- [ ] Lockfile committed; dependency audit clean of high-severity issues

## Pitfalls

- Client-only rendering for content pages, which wrecks LCP and SEO.
- Hydration bloat: shipping the whole component tree as JavaScript for static content.
- `div` and `span` used as buttons; ARIA added instead of using the native element ("no ARIA is better than bad ARIA").
- Layout shift from late-loading fonts, ads, images without dimensions, or injected banners.
- Long tasks from heavy event handlers that blow INP; do work after paint or in a worker.
- Trusting lab Lighthouse scores while field data is red.
- Authorization only in the UI; secrets or private API keys in the client bundle.
- Global state for server data, leading to stale caches and duplicated fetching.

## Verify gates

Suggested `.devbox/config` values for a pnpm project (adapt to the package manager):

```
DEVBOX_FORMAT_CMD=pnpm run --if-present format:check     # biome ci . or prettier --check .
DEVBOX_LINT_CMD=pnpm run --if-present lint               # biome or eslint (flat config)
DEVBOX_TYPECHECK_CMD=pnpm run --if-present typecheck     # tsc --noEmit
DEVBOX_TEST_CMD=pnpm test                                # vitest run
DEVBOX_BUILD_CMD=pnpm run --if-present build
```

Extra gates in CI: `playwright test` with axe-core, `lhci autorun` with budgets, bundle size check per route.

## Sources

- https://web.dev/articles/vitals
- https://www.w3.org/TR/WCAG22/
- https://www.w3.org/WAI/ARIA/apg/
- https://developer.mozilla.org/en-US/docs/Glossary/Progressive_Enhancement
- https://cheatsheetseries.owasp.org/
- https://owasp.org/Top10/2025/
- https://playwright.dev/
- https://github.com/dequelabs/axe-core
- https://github.com/GoogleChrome/lighthouse-ci
- https://github.com/GoogleChrome/web-vitals
- https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications
