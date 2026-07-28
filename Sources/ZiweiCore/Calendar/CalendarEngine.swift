import Foundation

enum CalendarEngine {
  static let timeZone: TimeZone = {
    guard let value = TimeZone(identifier: "Asia/Shanghai") else {
      preconditionFailure("The system time-zone database does not contain Asia/Shanghai")
    }
    return value
  }()

  static var gregorian: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar
  }

  static var chinese: Calendar {
    var calendar = Calendar(identifier: .chinese)
    calendar.timeZone = timeZone
    return calendar
  }

  static func gregorianDate(from solar: SolarDate) -> Date? {
    let date = gregorian.date(
      from: DateComponents(
        timeZone: timeZone, year: solar.year, month: solar.month, day: solar.day, hour: 12))
    guard let date else { return nil }
    let parts = gregorian.dateComponents([.year, .month, .day], from: date)
    guard parts.year == solar.year, parts.month == solar.month, parts.day == solar.day else {
      return nil
    }
    return date
  }

  static func solarToLunar(_ solar: SolarDate) throws -> LunarDate {
    guard let date = gregorianDate(from: solar) else {
      throw ZiweiError.invalidDate(solar.description)
    }
    // `isLeapMonth` is populated for Chinese calendars even when it is not
    // explicitly requested (requesting the component requires newer SDKs).
    let parts = chinese.dateComponents([.era, .year, .month, .day], from: date)
    guard let era = parts.era, let cycleYear = parts.year, let month = parts.month,
      let day = parts.day
    else {
      throw ZiweiError.invalidDate(solar.description)
    }
    // ICU's Chinese calendar epoch maps Chinese year 4697 to Gregorian lunar year 2000.
    let lunarYear = era * 60 + cycleYear - 2_697
    return LunarDate(
      uncheckedYear: lunarYear, month: month, day: day,
      isLeapMonth: parts.isLeapMonth ?? false)
  }

  static func lunarToSolar(_ lunar: LunarDate) throws -> SolarDate {
    let chineseYear = lunar.year + 2_697
    var parts = DateComponents()
    parts.calendar = chinese
    parts.timeZone = timeZone
    parts.era = (chineseYear - 1) / 60
    parts.year = (chineseYear - 1) % 60 + 1
    parts.month = lunar.month
    parts.day = lunar.day
    parts.hour = 12
    parts.isLeapMonth = lunar.isLeapMonth
    guard let date = chinese.date(from: parts) else {
      throw ZiweiError.unsupportedLunarDate(
        year: lunar.year, month: lunar.month, day: lunar.day, isLeapMonth: lunar.isLeapMonth)
    }
    let roundTrip = chinese.dateComponents([.era, .year, .month, .day], from: date)
    guard roundTrip.era == parts.era,
      roundTrip.year == parts.year,
      roundTrip.month == parts.month,
      roundTrip.day == parts.day,
      (roundTrip.isLeapMonth ?? false) == lunar.isLeapMonth
    else {
      throw ZiweiError.unsupportedLunarDate(
        year: lunar.year, month: lunar.month, day: lunar.day, isLeapMonth: lunar.isLeapMonth)
    }
    let solar = gregorian.dateComponents([.year, .month, .day], from: date)
    guard let year = solar.year, let month = solar.month, let day = solar.day else {
      throw ZiweiError.unsupportedLunarDate(
        year: lunar.year, month: lunar.month, day: lunar.day, isLeapMonth: lunar.isLeapMonth)
    }
    return SolarDate(uncheckedYear: year, month: month, day: day)
  }

  static func yearPillar(
    solar: SolarDate,
    lunar: LunarDate,
    divide: DivideMode = .normal
  ) -> StemBranch {
    let effectiveYear: Int
    if divide == .exact {
      let lichunDay = solarTermDay(year: solar.year, termIndex: 2)
      effectiveYear =
        (solar.month < 2 || (solar.month == 2 && solar.day < lichunDay))
        ? solar.year - 1 : solar.year
    } else {
      effectiveYear = lunar.year
    }
    return StemBranch(
      stem: HeavenlyStem.cyclic(at: effectiveYear - 4),
      branch: EarthlyBranch.cyclic(at: effectiveYear - 4)
    )
  }

  static func chineseDate(
    solar: SolarDate,
    lunar: LunarDate,
    hour: ChineseHour,
    yearDivide: DivideMode = .normal,
    monthDivide: DivideMode = .normal,
    dayDivide: DayDivideMode = .forward
  ) throws -> ChineseDate {
    let year = yearPillar(solar: solar, lunar: lunar, divide: yearDivide)
    let effectiveMonth: Int
    if monthDivide == .exact {
      effectiveMonth = try exactMonthNumber(for: solar, hour: hour)
    } else {
      // lunar-lite treats the latter half of a leap month as the following month.
      effectiveMonth = lunar.month + (lunar.isLeapMonth && lunar.day > 15 ? 1 : 0)
    }
    let monthYearStem: HeavenlyStem
    if monthDivide == .exact {
      let input = try solarDateTime(solar, hour: hour)
      let exactYear =
        input < solarTermDate(year: solar.year, termIndex: 2) ? solar.year - 1 : solar.year
      monthYearStem = HeavenlyStem.cyclic(at: exactYear - 4)
    } else {
      monthYearStem = year.stem
    }
    let monthStem = HeavenlyStem.cyclic(
      at: Constants.tigerRule[monthYearStem.rawValue].rawValue + effectiveMonth - 1)
    let monthBranch = EarthlyBranch.cyclic(at: EarthlyBranch.yin.rawValue + effectiveMonth - 1)

    guard let date = gregorianDate(from: solar) else {
      throw ZiweiError.invalidDate(solar.description)
    }
    guard
      let epoch = gregorianDate(from: SolarDate(uncheckedYear: 1970, month: 1, day: 1)),
      var elapsedDays = gregorian.dateComponents([.day], from: epoch, to: date).day
    else {
      throw ZiweiError.invalidDate(solar.description)
    }
    if hour == .lateZi && dayDivide == .forward { elapsedDays += 1 }
    let dayCycle = positiveModulo(elapsedDays + 17, 60)
    let day = StemBranch(
      stem: HeavenlyStem.cyclic(at: dayCycle),
      branch: EarthlyBranch.cyclic(at: dayCycle)
    )

    let ratStarts: [HeavenlyStem] = [.jia, .bing, .wu, .geng, .ren, .jia, .bing, .wu, .geng, .ren]
    let hourBranch = hour.branch
    let hourStem = HeavenlyStem.cyclic(
      at: ratStarts[day.stem.rawValue].rawValue + hourBranch.rawValue)
    return ChineseDate(
      yearly: year,
      monthly: StemBranch(stem: monthStem, branch: monthBranch),
      daily: day,
      hourly: StemBranch(stem: hourStem, branch: hourBranch)
    )
  }

  /// Month number where 1 is the tiger month beginning at 立春.
  private static func exactMonthNumber(for solar: SolarDate, hour: ChineseHour) throws -> Int {
    let boundaryTermByMonth = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22]
    let boundary = solarTermDate(
      year: solar.year, termIndex: boundaryTermByMonth[solar.month - 1])
    let input = try solarDateTime(solar, hour: hour)
    var branchMonth = solar.month - 1
    if input < boundary { branchMonth -= 1 }
    return positiveModulo(branchMonth - 1, 12) + 1
  }

  private static func solarDateTime(_ solar: SolarDate, hour: ChineseHour) throws -> Date {
    guard
      let date = gregorian.date(
        from: DateComponents(
          timeZone: timeZone, year: solar.year, month: solar.month, day: solar.day,
          hour: hour.representativeClockHour, minute: 30))
    else {
      throw ZiweiError.invalidDate(solar.description)
    }
    return date
  }

  /// Gregorian day of a solar term for date-only calculations (1900–2100).
  static func solarTermDay(year: Int, termIndex: Int) -> Int {
    gregorian.component(.day, from: solarTermDate(year: year, termIndex: termIndex))
  }

  /// Astronomical instant of a solar term. Index 0 is 小寒 (solar longitude 285°).
  private static func solarTermDate(year: Int, termIndex: Int) -> Date {
    let termMinutes = [
      0, 21_208, 42_467, 63_693, 85_337, 107_014, 128_867, 150_921,
      173_149, 195_551, 218_072, 240_693, 263_343, 285_989, 308_563, 331_033,
      353_350, 375_494, 397_447, 419_210, 440_795, 462_224, 483_532, 504_758,
    ]
    var utcCalendar = Calendar(identifier: .gregorian)
    guard let utc = TimeZone(secondsFromGMT: 0) else {
      preconditionFailure("Foundation could not construct UTC")
    }
    utcCalendar.timeZone = utc
    guard
      let base = utcCalendar.date(
        from: DateComponents(year: 1900, month: 1, day: 6, hour: 2, minute: 5))
    else {
      preconditionFailure("Foundation could not construct the solar-term epoch")
    }
    let milliseconds =
      31_556_925_974.7 * Double(year - 1900)
      + Double(termMinutes[termIndex]) * 60_000
    let guess = base.addingTimeInterval(milliseconds / 1_000)
    let target = positiveDegrees(285 + 15 * Double(termIndex))
    var lower = guess.addingTimeInterval(-2 * 86_400)
    var upper = guess.addingTimeInterval(2 * 86_400)
    for _ in 0..<48 {
      let middle = lower.addingTimeInterval(upper.timeIntervalSince(lower) / 2)
      if signedDegrees(solarLongitude(at: middle) - target) < 0 {
        lower = middle
      } else {
        upper = middle
      }
    }
    return lower.addingTimeInterval(upper.timeIntervalSince(lower) / 2)
  }

  private static func solarLongitude(at date: Date) -> Double {
    let julianDay = date.timeIntervalSince1970 / 86_400 + 2_440_587.5
    let centuries = (julianDay - 2_451_545) / 36_525
    let meanLongitude = 280.46646 + 36_000.76983 * centuries + 0.0003032 * centuries * centuries
    let meanAnomaly =
      357.52911 + 35_999.05029 * centuries - 0.0001537 * centuries * centuries
    let radians = meanAnomaly * .pi / 180
    let equation =
      (1.914602 - 0.004817 * centuries - 0.000014 * centuries * centuries) * sin(radians)
      + (0.019993 - 0.000101 * centuries) * sin(2 * radians)
      + 0.000289 * sin(3 * radians)
    let omega = (125.04 - 1_934.136 * centuries) * .pi / 180
    return positiveDegrees(meanLongitude + equation - 0.00569 - 0.00478 * sin(omega))
  }

  private static func positiveDegrees(_ value: Double) -> Double {
    let result = value.truncatingRemainder(dividingBy: 360)
    return result < 0 ? result + 360 : result
  }

  private static func signedDegrees(_ value: Double) -> Double {
    let normalized = positiveDegrees(value)
    return normalized > 180 ? normalized - 360 : normalized
  }

  static func maxDaysInLunarMonth(containing solar: SolarDate) throws -> Int {
    guard let date = gregorianDate(from: solar),
      let range = chinese.range(of: .day, in: .month, for: date)
    else {
      throw ZiweiError.invalidDate(solar.description)
    }
    return range.count
  }
}

@inline(__always)
func positiveModulo(_ value: Int, _ modulus: Int = 12) -> Int {
  let result = value % modulus
  return result >= 0 ? result : result + modulus
}
