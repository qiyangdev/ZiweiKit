# ``ZiweiCore``

Generate deterministic Zi Wei Dou Shu charts with the complete iztro calculation layer.

## Overview

Use ``Ziwei/chart(solarDate:timeIndex:gender:fixLeap:configuration:astrolabeType:)`` or
``Ziwei/chart(lunarDate:timeIndex:gender:fixLeap:configuration:astrolabeType:)`` to construct an
``Astrolabe``. The returned value is immutable, `Codable`, `Equatable`, and
`Sendable`.

```swift
let birthDate = try SolarDate(year: 2000, month: 8, day: 16)
let chart = try Ziwei.chart(solarDate: birthDate, timeIndex: 2, gender: .female)
let lifePalace = chart.palace(.life)
let annual = try chart.horoscope(at: "2026-7-28", timeIndex: 6)
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

### Creating a chart

- ``Ziwei``
- ``Astrolabe``
- ``SolarDate``
- ``LunarDate``
- ``Gender``
- ``ChartDate``
- ``ChartOptions``
- ``ZiweiConfiguration``
- ``AstrolabeType``

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
- ``SurroundedPalaces``

### Horoscope

- ``Horoscope``
- ``HoroscopePeriod``
- ``AgePeriod``
- ``YearlyDecoration``

### Extensions

- ``AstrolabePlugin``
