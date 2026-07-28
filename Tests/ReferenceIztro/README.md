# iztro reference oracle

This directory pins the original JavaScript implementation at `iztro@2.5.8`
(upstream commit `106d038cc5a30d6aff8fd987f7ed79090b6ad7ff`) and regenerates the JSON
fixtures consumed by Swift tests. Besides full default and configured charts,
the oracle covers horoscope scopes and a 120-case exact solar-term matrix.

```sh
cd Tests/ReferenceIztro
npm ci
npm run generate
```

`node_modules` is intentionally not committed. The generated fixture is, so
ordinary `swift test` runs are offline and deterministic.
