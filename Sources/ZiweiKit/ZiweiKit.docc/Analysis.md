# Analysis

Query immutable charts using semantic identifiers and composable helpers.

## Palaces and stars

```swift
let life = chart.palace(.life)
let hasMajorStars = life?.containsAny(of: [.ziwei, .tianfu]) == true
let ziweiPalace = chart.star(.ziwei)?.palace(in: chart)
let opposite = chart.star(.ziwei)?.oppositePalace(in: chart)
```

``SurroundedPalaces`` represents the target, opposite, wealth, and career
palaces used by three-directions-and-four-alignments analysis:

```swift
let group = chart.surroundingPalaces(of: .life)
let containsAll = group?.contains([.ziwei, .tianfu]) == true
```

``Palace`` also exposes flying-transformation and self-transformation queries.
All helpers accept typed ``StarID`` and ``Mutagen`` values.

## Reusable analysis

Use ``Astrolabe/analyze(_:)`` for a local closure, or implement
``AstrolabePlugin`` when an analysis should be reusable:

```swift
struct MajorStarCount: AstrolabePlugin {
  func apply(to astrolabe: Astrolabe) -> Int {
    astrolabe.palaces.reduce(0) { $0 + $1.majorStars.count }
  }
}

let count = try chart.use(MajorStarCount())
```

Plugins receive an immutable chart and do not modify global state.
