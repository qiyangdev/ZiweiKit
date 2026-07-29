# Configuration

Choose calculation rules independently for each chart.

``ZiweiConfiguration`` is an immutable value captured by the resulting
``Astrolabe``. Changing one chart's configuration never changes another chart
or global process state.

```swift
let options = ChartOptions(
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

let chart = try Ziwei.chart(options: options)
```

Use ``DivideMode/exact`` for astronomical solar-term boundaries and
``AgeDivideMode/birthday`` to change nominal-age periods on the lunar birthday.
``AstrolabeType`` selects the heaven, earth, or human palace frame.

## Custom tables

You can replace transformation or brightness tables with strongly typed
dictionaries:

```swift
let configuration = ZiweiConfiguration(
  mutagens: [
    .jia: [.lianzhen, .pojun, .wuqu, .taiyang]
  ],
  brightness: [
    .ziwei: [Brightness?](repeating: .temple, count: 12)
  ]
)
```

An omitted stem or star falls back to the built-in table. A custom mutagen row
must contain four stars, and a nonempty custom brightness row must contain 12
values in palace-index order. ``ZiweiConfiguration/validate()`` checks these
requirements, and chart and horoscope calculation entry points validate
automatically before using a configuration.
