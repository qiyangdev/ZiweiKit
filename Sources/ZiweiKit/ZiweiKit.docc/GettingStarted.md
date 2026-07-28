# Getting Started

Create and inspect a chart using validated, strongly typed inputs.

## Create a natal chart

Construct a ``SolarDate`` or ``LunarDate``, select a ``ChineseHour``, and call
``Ziwei``:

```swift
import ZiweiKit

let birthDate = try SolarDate(year: 2000, month: 8, day: 16)
let chart = try Ziwei.chart(
  solarDate: birthDate,
  hour: .yin,
  gender: .female
)
```

String parsing is limited to the date boundary. Parse once, then use typed
values throughout the calculation layer:

```swift
let date = try SolarDate("2000/08/16")
let hour = ChineseHour(clockHour: 4)
```

## Inspect the result

Chart values use semantic identifiers instead of localized display names:

```swift
let lifePalace = chart.palace(.life)
let ziwei = chart.star(.ziwei)
let ziweiPalace = chart.palace(containing: .ziwei)
```

The returned ``Astrolabe`` is immutable, `Codable`, `Equatable`, and
`Sendable`, so it can safely cross concurrency boundaries and be persisted by
the application.

## Next steps

- <doc:DateAndTimeConventions>
- <doc:Configuration>
- <doc:CalculatingHoroscopes>
- <doc:Analysis>
