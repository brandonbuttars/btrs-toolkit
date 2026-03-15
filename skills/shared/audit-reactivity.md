# Reactivity & State Management Audit Reference

Shared analysis guidance for reactive patterns, subscription management, and state architecture. Used by `btrs-audit-reactivity` (standalone) and `btrs-review-mr` (as part of the diff review).

## Detect the reactivity framework

Detect from package.json and file extensions:

- **Svelte 5** — `.svelte` files, runes: `$state`, `$derived`, `$effect`, `$props`, `$bindable`
- **Svelte 4/3** — `.svelte` files, stores: `writable`, `readable`, `derived`, `$:` reactive declarations
- **React** — `.jsx`/`.tsx`, hooks: `useState`, `useEffect`, `useReducer`, `useMemo`, `useCallback`, `useRef`
- **Vue 3** — `.vue` files, Composition API: `ref()`, `reactive()`, `computed()`, `watch()`, `watchEffect()`
- **Vue 2** — `.vue` files, Options API: `data()`, `computed:`, `watch:`, `methods:`
- **Angular** — Signals: `signal()`, `computed()`, `effect()`; or RxJS: `Observable`, `Subject`, `subscribe()`
- **Solid** — `createSignal`, `createEffect`, `createMemo`
- **Vanilla** — `addEventListener`, `MutationObserver`, `IntersectionObserver`, custom event systems

The specific patterns to check vary by framework, but the principles are universal.

## Subscription leak detection

Every subscription, listener, effect, or watcher MUST have a corresponding cleanup on destroy/unmount. Search for these creation patterns and verify cleanup exists:

| Framework | Creates subscription | Cleanup mechanism |
|-----------|---------------------|-------------------|
| Svelte 5 | `$effect(() => {...})` | Return cleanup function from effect |
| Svelte 3/4 | `store.subscribe()` | Call returned unsubscribe function in `onDestroy` |
| React | `useEffect(() => {...})` | Return cleanup function |
| Vue 3 | `watch()`, `watchEffect()` | Call returned stop function, or auto-cleanup on unmount |
| Angular | `.subscribe()` | `unsubscribe()` in `ngOnDestroy`, or use `takeUntilDestroyed()` |
| Vanilla | `addEventListener()` | `removeEventListener()` in teardown |
| Vanilla | `setInterval()` / `setTimeout()` | `clearInterval()` / `clearTimeout()` |
| Any | WebSocket `.onmessage` | `.close()` on teardown |
| Any | `IntersectionObserver` | `.disconnect()` on teardown |
| Any | `MutationObserver` | `.disconnect()` on teardown |
| Any | `EventSource` (SSE) | `.close()` on teardown |

Flag any creation without a corresponding cleanup in all exit paths.

## Unnecessary vs missing reactivity

**Unnecessary reactivity** — values declared as independent state that should be derived:
- A value computed entirely from other reactive values should be `$derived` (Svelte 5), `useMemo` (React), `computed` (Vue), etc.
- Multiple state variables that always update together should be a single object/store
- State that's set once and never changes doesn't need to be reactive

**Missing reactivity** — mutations that won't trigger UI updates:
- Plain `let` where `$state` is needed (Svelte 5)
- Mutating objects/arrays without triggering reactivity (e.g., `array.push()` without reassignment in Svelte)
- Direct DOM manipulation bypassing the reactive framework
- State updates inside `setTimeout`/`setInterval` without proper framework integration

## Reactive dependency issues

- **Stale closures** — effects/computeds that reference reactive values not in their dependency list
- **Over-subscription** — effects that include dependencies they don't actually use, causing unnecessary re-runs
- **Missing dependencies** — React `useEffect` without all referenced values in the deps array
- **Mutable refs used as dependencies** — refs don't trigger re-renders but are used where reactive state is needed

## Expensive computations

- Flag expensive operations inside reactive contexts that should be memoized or debounced
- Look for array `.filter()`, `.map()`, `.sort()` chains that recompute on every render
- Check for API calls or heavy computations inside derived/computed values
- Suggest moving expensive work outside the reactive boundary or using memoization

## Cascading reactivity

Flag chains where state A triggers effect B which updates state C which triggers effect D:
- These are fragile, hard to debug, and often indicate the reactive graph should be restructured
- Suggest flattening to derived values where possible
- Identify circular dependency risks

## Store/signal architecture

- Verify reactive stores/signals used across components have clear ownership
- Flag implicit coupling between unrelated parts of the UI via shared global state
- Check that stores are scoped appropriately (component-local vs global)
- Flag reactive declarations inside loops or conditional branches that recreate subscriptions per iteration
