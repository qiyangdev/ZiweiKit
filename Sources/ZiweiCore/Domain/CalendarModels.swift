/// Errors emitted by the deterministic calculation layer.
public enum ZiweiError: Error, Equatable, Sendable {
  case invalidDate(String)
  case unsupportedLunarDate(year: Int, month: Int, day: Int, isLeapMonth: Bool)
}

/// The yin-yang quality used by stems, branches, and chart direction rules.
public enum YinYang: String, Codable, Sendable {
  case yin  // 阴
  case yang  // 阳
}

/// One of the ten heavenly stems (天干), ordered by its traditional cycle.
public enum HeavenlyStem: Int, Codable, CaseIterable, Sendable {
  case jia  // 甲
  case yi  // 乙
  case bing  // 丙
  case ding  // 丁
  case wu  // 戊
  case ji  // 己
  case geng  // 庚
  case xin  // 辛
  case ren  // 壬
  case gui  // 癸

  public var yinYang: YinYang { rawValue.isMultiple(of: 2) ? .yang : .yin }
}

/// One of the twelve earthly branches (地支), ordered from rat to pig.
public enum EarthlyBranch: Int, Codable, CaseIterable, Sendable {
  case zi  // 子（鼠）
  case chou  // 丑（牛）
  case yin  // 寅（虎）
  case mao  // 卯（兔）
  case chen  // 辰（龙）
  case si  // 巳（蛇）
  case wu  // 午（马）
  case wei  // 未（羊）
  case shen  // 申（猴）
  case you  // 酉（鸡）
  case xu  // 戌（狗）
  case hai  // 亥（猪）

  public var yinYang: YinYang { rawValue.isMultiple(of: 2) ? .yang : .yin }
}

/// A traditional two-hour period, distinguishing the early and late rat periods.
public enum ChineseHour: Int, Codable, CaseIterable, Sendable {
  case earlyZi  // 早子时（00:00）
  case chou  // 丑时
  case yin  // 寅时
  case mao  // 卯时
  case chen  // 辰时
  case si  // 巳时
  case wu  // 午时
  case wei  // 未时
  case shen  // 申时
  case you  // 酉时
  case xu  // 戌时
  case hai  // 亥时
  case lateZi  // 晚子时（23:00）

  /// Creates the traditional period containing a 24-hour clock value.
  public init?(clockHour: Int) {
    guard (0...23).contains(clockHour) else { return nil }
    let index = clockHour == 23 ? 12 : (clockHour + 1) / 2
    self = Self.allCases[index]
  }

  public var branch: EarthlyBranch {
    EarthlyBranch.cyclic(at: rawValue)
  }

  var representativeClockHour: Int {
    max(rawValue * 2 - 1, 0)
  }
}

/// A paired heavenly stem and earthly branch in the sexagenary cycle.
public struct StemBranch: Codable, Equatable, Sendable {
  public let stem: HeavenlyStem
  public let branch: EarthlyBranch

  public init(stem: HeavenlyStem, branch: EarthlyBranch) {
    self.stem = stem
    self.branch = branch
  }
}

/// The four year, month, day, and hour pillars (四柱) for a chart date.
public struct ChineseDate: Codable, Equatable, Sendable {
  public let yearly: StemBranch
  public let monthly: StemBranch
  public let daily: StemBranch
  public let hourly: StemBranch

  public init(
    yearly: StemBranch, monthly: StemBranch, daily: StemBranch, hourly: StemBranch
  ) {
    self.yearly = yearly
    self.monthly = monthly
    self.daily = daily
    self.hourly = hourly
  }
}

/// A validated Gregorian calendar date without a time zone or time of day.
public struct SolarDate: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
  public let year: Int
  public let month: Int
  public let day: Int

  /// Creates a Gregorian date, rejecting combinations that do not exist.
  public init(year: Int, month: Int, day: Int) throws {
    let candidate = Self(uncheckedYear: year, month: month, day: day)
    guard CalendarEngine.gregorianDate(from: candidate) != nil else {
      throw ZiweiError.invalidDate("\(year)-\(month)-\(day)")
    }
    self = candidate
  }

  init(uncheckedYear year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }

  /// Parses the date portion of a string using `-`, `.`, or `/` separators.
  public init(_ value: String) throws {
    let datePart = value.split(whereSeparator: \.isWhitespace).first ?? ""
    let values = datePart.split(whereSeparator: { "-./".contains($0) }).compactMap { Int($0) }
    guard values.count >= 3 else { throw ZiweiError.invalidDate(value) }
    try self.init(year: values[0], month: values[1], day: values[2])
  }

  public var description: String { "\(year)-\(month)-\(day)" }

  private enum CodingKeys: String, CodingKey { case year, month, day }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    try self.init(
      year: values.decode(Int.self, forKey: .year),
      month: values.decode(Int.self, forKey: .month),
      day: values.decode(Int.self, forKey: .day))
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: CodingKeys.self)
    try values.encode(year, forKey: .year)
    try values.encode(month, forKey: .month)
    try values.encode(day, forKey: .day)
  }
}

/// A validated Chinese lunar calendar date.
public struct LunarDate: Codable, Equatable, Sendable {
  public let year: Int
  public let month: Int
  public let day: Int
  public let isLeapMonth: Bool

  /// Creates a lunar date and validates it against the Chinese calendar.
  ///
  /// A leap flag for a year without that leap month is treated as ineffective,
  /// matching the calculation rules used by the reference implementation.
  public init(year: Int, month: Int, day: Int, isLeapMonth: Bool = false) throws {
    guard (1...12).contains(month), (1...30).contains(day) else {
      throw ZiweiError.invalidDate("\(year)-\(month)-\(day)")
    }
    let candidate = Self(
      uncheckedYear: year, month: month, day: day, isLeapMonth: isLeapMonth)
    do {
      _ = try CalendarEngine.lunarToSolar(candidate)
    } catch  where isLeapMonth {
      // Match iztro: a leap flag is ignored when this year has no such leap month.
      _ = try CalendarEngine.lunarToSolar(
        Self(uncheckedYear: year, month: month, day: day))
    }
    self = candidate
  }

  /// Parses a lunar date using `-`, `.`, or `/` separators.
  public init(_ value: String, isLeapMonth: Bool = false) throws {
    let datePart = value.split(whereSeparator: \.isWhitespace).first ?? ""
    let values = datePart.split(whereSeparator: { "-./".contains($0) }).compactMap { Int($0) }
    guard values.count >= 3 else { throw ZiweiError.invalidDate(value) }
    try self.init(
      year: values[0], month: values[1], day: values[2], isLeapMonth: isLeapMonth)
  }

  init(uncheckedYear year: Int, month: Int, day: Int, isLeapMonth: Bool = false) {
    self.year = year
    self.month = month
    self.day = day
    self.isLeapMonth = isLeapMonth
  }

  private enum CodingKeys: String, CodingKey { case year, month, day, isLeapMonth }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    try self.init(
      year: values.decode(Int.self, forKey: .year),
      month: values.decode(Int.self, forKey: .month),
      day: values.decode(Int.self, forKey: .day),
      isLeapMonth: values.decode(Bool.self, forKey: .isLeapMonth))
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: CodingKeys.self)
    try values.encode(year, forKey: .year)
    try values.encode(month, forKey: .month)
    try values.encode(day, forKey: .day)
    try values.encode(isLeapMonth, forKey: .isLeapMonth)
  }
}

extension HeavenlyStem {
  static func cyclic(at index: Int) -> Self {
    allCases[positiveModulo(index, allCases.count)]
  }
}

extension EarthlyBranch {
  static func cyclic(at index: Int) -> Self {
    allCases[positiveModulo(index, allCases.count)]
  }
}
