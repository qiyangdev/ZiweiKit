# Calculating Horoscopes

Calculate dynamic periods for a typed target date and hour.

```swift
let target = try SolarDate(year: 2026, month: 7, day: 28)
let horoscope = try chart.horoscope(at: target, hour: .wu)

let nominalAge = horoscope.age.nominalAge
let yearlyStem = horoscope.yearly.stem
let yearlyLife = horoscope.palace(.life, scope: .yearly, in: chart)
```

``Horoscope`` contains decadal, yearly, monthly, daily, and hourly
``HoroscopePeriod`` values, plus the active ``AgePeriod``.

Within each dynamic period, `palaceIDs[index]` and `stars[index]` refer to the
same natal palace index. The `mutagens` array follows ``Mutagen`` declaration
order: fortune, power, reputation, and obstacle.

Use scoped queries instead of manually matching array indices:

```swift
let hasStar = horoscope.containsAnyHoroscopeStars(
  [.ziwei, .tianfu],
  in: .life,
  scope: .yearly,
  astrolabe: chart
)
```

The `.origin` scope queries natal placement. Other ``HoroscopeScope`` values
query their corresponding dynamic period.
