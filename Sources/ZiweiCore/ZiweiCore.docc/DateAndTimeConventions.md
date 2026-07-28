# Date and Time Conventions

Understand the calendar, time-zone, leap-month, and late-rat-period rules used
by ZiweiCore.

## Calendar dates

``SolarDate`` represents a Gregorian date and ``LunarDate`` represents a
Chinese lunar-calendar date. Both validate their components when constructed
and decoded. They intentionally contain neither a time of day nor a time zone.

Calendar calculations use `Asia/Shanghai` internally and do not depend on the
device's locale or current time zone. You can convert in either direction:

```swift
let lunar = try Ziwei.lunarDate(
  fromSolar: SolarDate(year: 2000, month: 8, day: 16)
)
let solar = try Ziwei.solarDate(fromLunar: lunar)
```

## Chinese hours

``ChineseHour`` distinguishes the early and late rat periods. Use
``ChineseHour/init(clockHour:)`` to map a 24-hour clock value:

| Clock hour | Value |
| --- | --- |
| `00` | `.earlyZi` |
| `01...02` | `.chou` |
| `03...04` | `.yin` |
| `05...06` | `.mao` |
| `07...08` | `.chen` |
| `09...10` | `.si` |
| `11...12` | `.wu` |
| `13...14` | `.wei` |
| `15...16` | `.shen` |
| `17...18` | `.you` |
| `19...20` | `.xu` |
| `21...22` | `.hai` |
| `23` | `.lateZi` |

``DayDivideMode/current`` keeps `.lateZi` on the current calendar day, while
``DayDivideMode/forward`` advances its day pillar to the following day.

## Leap months

The `fixLeap` chart option controls the reference implementation's leap-month
adjustment. When enabled, dates in the latter half of a leap month use the next
month for chart placement while retaining the validated lunar date. The late
rat period is excluded from this month adjustment. Disable `fixLeap` only when
reproducing a convention that does not apply the adjustment.

The parity fixtures exercise calendar and solar-term boundaries from 1901
through 2099. Treat dates outside that tested range as unverified.
