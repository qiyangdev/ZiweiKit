# ``ZiweiKit``

Generate deterministic Zi Wei Dou Shu charts with the complete iztro calculation layer.

## Overview

Use ``Ziwei/chart(solarDate:hour:gender:fixLeap:configuration:astrolabeType:)`` or
``Ziwei/chart(lunarDate:hour:gender:fixLeap:configuration:astrolabeType:)`` to construct an
``Astrolabe``. The returned value is immutable, `Codable`, `Equatable`, and
`Sendable`.

```swift
let birthDate = try SolarDate(year: 2000, month: 8, day: 16)
let chart = try Ziwei.chart(solarDate: birthDate, hour: .yin, gender: .female)
let lifePalace = chart.palace(.life)
let annual = try chart.horoscope(
  at: SolarDate(year: 2026, month: 7, day: 28),
  hour: .wu
)
```

Calendar calculations use `Asia/Shanghai` and do not depend on the device's
current locale or time zone.

The core target exposes semantic identifiers only. Display names, localization,
and date formatting are intentionally owned by the consuming application.

Use ``Ziwei/chart(options:)``, ``ChartOptions``, and ``ZiweiConfiguration`` for exact solar-term
boundaries, custom mutagens and brightness, Zhongzhou calculation, and heaven,
earth, or human astrolabes. Functional queries are available on ``Astrolabe``,
``Palace``, ``Star``, ``SurroundedPalaces``, and ``Horoscope``.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:DateAndTimeConventions>
- <doc:Configuration>
- <doc:CalculatingHoroscopes>
- <doc:Analysis>

### Creating a chart

- ``Ziwei``
- ``Astrolabe``
- ``SolarDate``
- ``LunarDate``
- ``ChineseHour``
- ``Gender``
- ``ChartDate``
- ``ChartOptions``
- ``ZiweiConfiguration``
- ``AstrolabeType``
- ``DivideMode``
- ``AgeDivideMode``
- ``DayDivideMode``
- ``ZiweiAlgorithm``

### Chart values

- ``Palace``
- ``Star``
- ``StarType``
- ``PalaceID``
- ``StarID``
- ``StarScope``
- ``Brightness``
- ``Mutagen``
- ``FiveElementsClass``
- ``ChineseDate``
- ``StemBranch``
- ``HeavenlyStem``
- ``EarthlyBranch``
- ``YinYang``
- ``SurroundedPalaces``

### Horoscope

- ``Horoscope``
- ``HoroscopePeriod``
- ``AgePeriod``
- ``YearlyDecoration``
- ``HoroscopeScope``
- ``HoroscopePeriodKind``

### Extensions

- ``AstrolabePlugin``
