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

The scope selects the palace-name mapping. To preserve iztro's functional
analyzer semantics, horoscope-star predicates merge decadal and yearly dynamic
stars after resolving that mapping. Mutagen predicates use the selected
period's transformation table. The `.origin` scope queries natal palace
placement and does not have a dynamic mutagen table.
