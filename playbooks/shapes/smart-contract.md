# Smart contract

> On-chain programs (EVM and similar) where bugs are public, permanent and expensive

## When this applies

- Solidity or Vyper contracts on EVM chains, and comparable on-chain programs.
- Protocols, tokens, vaults, governance and upgradeable proxy systems.
- The off-chain indexer, API or front end: also read `api-service` and `web-app`.

## Default architecture

- Build on audited libraries (OpenZeppelin Contracts) instead of writing primitives yourself.
- Minimal on-chain surface: keep logic that does not need trustless execution off-chain.
- Explicit access control on every state-changing function (roles or ownership), with admin actions behind a timelock and a multisig.
- Checks-effects-interactions ordering and reentrancy guards on every external call path.
- A pause mechanism (circuit breaker) for emergencies, with clear authority and limits.
- Upgradeability only when justified (ADR): if used, a standard proxy pattern with storage-layout checks before every upgrade.
- Avoid starting with: custom cryptography, unaudited forks, upgradeability "just in case", single-key admin control.

## Quality attributes

- Correctness and safety above all: assume every flaw will be found and exploited.
- Gas efficiency within budgets that matter for users.
- Upgrade safety and governance transparency.
- Resistance to oracle manipulation, flash-loan attacks and MEV where value is at stake.
- Verifiability: source verified on block explorers; reproducible builds.

## Spec and design prompts

/devbox:spec and /devbox:grill should always ask:

- What value is at risk, and what is the worst case if the contract is drained or frozen?
- Who holds admin powers, and what can they do? Is that acceptable to users?
- Which external contracts and oracles does it trust? What if they misbehave?
- Is upgradeability required? Who approves upgrades, and with what delay?
- What invariants must always hold (for example "total supply equals sum of balances")?

/devbox:design should decide and record:

- Contract architecture, roles and permissions table.
- Invariants to test and, where feasible, formally verify.
- Oracle design and manipulation defenses.
- Deployment, verification, audit and bug bounty plan.

## Testing strategy

- Foundry unit tests for every function, including access control failures.
- Fuzz tests and invariant tests for core invariants.
- Static analysis with Slither or Aderyn in CI.
- Formal or symbolic verification for critical invariants (Halmos, Certora, SMTChecker).
- Mainnet-fork tests against real integrations and realistic state.
- At least one external audit before mainnet, plus a bug bounty after launch.
- Map tests to the OWASP Smart Contract Top 10 (2026).

## Walking skeleton

T001 delivers: one minimal contract built on OpenZeppelin with access control, unit and fuzz tests, one invariant test, Slither running in CI, and a scripted deployment to a testnet with source verification.

## Checklist

- [ ] Compiler version pinned (no floating pragma)
- [ ] Checks-effects-interactions everywhere; reentrancy guards on external call paths
- [ ] Access control on every state-changing function; never authorize with `tx.origin`
- [ ] Oracle and flash-loan manipulation resistance reviewed
- [ ] Storage layout checked before every upgrade
- [ ] Admin actions behind a timelock and multisig
- [ ] Pause mechanism with clear authority
- [ ] Invariant and fuzz tests for core properties
- [ ] Static analysis clean or findings triaged
- [ ] Source verified on block explorers
- [ ] External audit completed and findings resolved
- [ ] Bug bounty live at launch

## Pitfalls

- Relying on the SWC Registry, which is no longer actively maintained; use EEA EthTrust Security Levels and the OWASP Smart Contract Top 10 instead.
- Reentrancy through unexpected callbacks (tokens with hooks, fallback functions).
- Unchecked external call results.
- Price oracles readable from a single pool that can be manipulated within one transaction.
- Upgrades that corrupt storage layout.
- Single-key admin control that turns into a single point of failure.

## Verify gates

```
DEVBOX_FORMAT_CMD=forge fmt --check
DEVBOX_LINT_CMD=slither . --fail-high
DEVBOX_TEST_CMD=forge test
DEVBOX_BUILD_CMD=forge build --sizes
```

## Sources

- https://scs.owasp.org/sctop10/
- https://owasp.org/www-project-smart-contract-security-verification-standard/
- https://entethalliance.org/specs/ethtrust-sl/
- https://docs.soliditylang.org/en/latest/security-considerations.html
- https://docs.openzeppelin.com/contracts/
- https://secure-contracts.com/ (Trail of Bits, Building Secure Contracts)
- https://book.getfoundry.sh/
- https://github.com/crytic/slither
