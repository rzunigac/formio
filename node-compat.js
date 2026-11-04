// Node 21+ defines a read-only global `navigator`. form.io and formio-workers assign their own stub
// to it, which then throws. Make it a plain writable property, as on older Node. Loaded before any
// other code with NODE_OPTIONS=--require (Dockerfile), which child processes inherit.
Object.defineProperty(globalThis, 'navigator', {
  value: undefined, writable: true, configurable: true, enumerable: true
});
