# ZiweiKit

English | [简体中文](README.zh-CN.md)

ZiweiKit is a pure Swift port of the calculation layer from
[iztro](https://github.com/SylarLong/iztro), distributed as a Swift Package. It
depends only on Foundation at runtime, embeds no JavaScript, and supports iOS,
macOS, tvOS, watchOS, and visionOS.

```swift
import ZiweiKit

let birthDate = try SolarDate(year: 2000, month: 8, day: 16)
let chart = try Ziwei.chart(
  solarDate: birthDate,
  hour: .yin,
  gender: .female
)

print(chart.fiveElementsClass)  // wood
print(chart.palace(.life) as Any)
print(chart.palace(containing: .ziwei) as Any)

let horoscope = try chart.horoscope(
  at: SolarDate(year: 2026, month: 7, day: 28),
  hour: .wu
)
print(horoscope.yearly.stem)  // bing
print(horoscope.age.nominalAge)  // 27
```

Charts can also be created from lunar dates:

```swift
let lunarDate = try LunarDate(year: 2000, month: 7, day: 17)
let chart = try Ziwei.chart(
  lunarDate: lunarDate,
  hour: .yin,
  gender: .female
)
```

## Documentation

Public types and calculation entry points include DocC comments, complemented
by guides for getting started, date and time conventions, configuration,
horoscopes, and analysis queries. Read the
[online documentation](https://qiyangdev.github.io/ZiweiKit/documentation/ziweikit/),
or open the package root in Xcode and choose **Product > Build Documentation**.

Configuration is an immutable value captured independently by each chart. It
does not use iztro's global mutable configuration:

```swift
let chart = try Ziwei.chart(
  options: ChartOptions(
    date: .solar(try SolarDate(year: 1979, month: 8, day: 21)),
    hour: .wei,
    gender: .male,
    astrolabeType: .earth,
    configuration: ZiweiConfiguration(
      yearDivide: .exact,
      horoscopeDivide: .exact,
      ageDivide: .birthday,
      dayDivide: .current,
      algorithm: .zhongzhou
    )
  )
)
```

## SwiftUI Example

`Examples/ZiweiKitExample` is an independent iOS 16+ SwiftUI Xcode project.
It demonstrates chart creation for a fixed date, a chart summary, the twelve
palaces, and star details. The example uses the repository root as a local
Package Dependency, so it adds no UI product to ZiweiKit and keeps the root a
pure Swift Package.

Open `Examples/ZiweiKitExample/ZiweiKitExample.xcodeproj` directly, or run:

```sh
open Examples/ZiweiKitExample/ZiweiKitExample.xcodeproj
```

Choose the `ZiweiKitExample` scheme and any iOS 16+ Simulator. Keep the
example at its current relative path so Xcode can resolve the local package.

## Calculation Coverage

- Gregorian/lunar conversion, zodiac, western zodiac, and exact solar-term pillars
- Life and body palaces, twelve-palace stems and branches, and five-elements class
- Fourteen major stars, fourteen auxiliary stars, adjective stars, brightness, and natal mutagens
- Twelve growth, doctor, year-before, and general-before cycles
- Decadal, nominal-age, childhood, and lunar-birthday boundaries
- Yearly, monthly, daily, and hourly periods, dynamic stars, and yearly cycles
- Palace, star, surrounded-palace, flying-mutagen, self-mutagen, and horoscope analyzers
- Custom mutagens, brightness, year, horoscope, birthday, and late-rat-period boundaries
- Standard and Zhongzhou algorithms, plus heaven, earth, and human astrolabe layouts
- `ChartOptions`, multiple date separators, and strongly typed Chinese-hour conversion

Public models use strongly typed identifiers such as `PalaceID`, `StarID`,
`StarScope`, `Brightness`, and `Mutagen`. The product target contains no
localized runtime names or string-based query interfaces. Dates are validated
both during construction and `Codable` decoding, and serialization uses stable
English enumeration values.

The original runtime plugin mechanism maps to `AstrolabePlugin`,
`chart.use(_:)`, `chart.analyze(_:)`, and ordinary Swift extensions. No global
injection is used. Display names, localization, and date formatting belong to
the consuming application's presentation layer and do not affect calculations.

## Reference Baseline

`Tests/ReferenceIztro` pins the reference implementation to `iztro@2.5.8`
(upstream commit `106d038cc5a30d6aff8fd987f7ed79090b6ad7ff`). Its generated JSON
oracles are committed under `Tests/ZiweiKitTests/Fixtures`. The test target's
`IztroOracleAdapter.swift` converts localized oracle values into strongly typed
results, so normal Swift tests run entirely offline:

```sh
swift test
```

To update the reference fixtures:

```sh
cd Tests/ReferenceIztro
npm ci
npm run generate
```

The suite compares every field across 23 natal charts and 6 horoscope cases,
plus 120 solar-term boundary cases. It covers 1901–2099, lunar new year and
solar-term boundaries, leap months, the late rat period, custom configuration,
Zhongzhou heaven/earth/human charts, solar and lunar entry points, and the
functional analyzers.

## Time Convention

Calendar calculations always use `Asia/Shanghai`, preventing the device time
zone from changing chart results. Hours use the strongly typed `ChineseHour`;
`.earlyZi` and `.lateZi` distinguish the early and late rat periods.
`ChineseHour(clockHour:)` converts a clock hour in `0...23` to its traditional
two-hour period.

## Upstream License

The algorithms are ported from MIT-licensed iztro. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the complete notice.
