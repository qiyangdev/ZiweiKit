/// A scope used when querying natal or dynamic star placements.
public typealias HoroscopeScope = StarScope

/// A dynamic period such as a decadal, yearly, monthly, daily, or hourly period.
public struct HoroscopePeriod: Codable, Equatable, Sendable {
  public let index: Int
  public let kind: HoroscopePeriodKind
  public let stem: HeavenlyStem
  public let branch: EarthlyBranch
  public let palaceIDs: [PalaceID]
  public let mutagens: [StarID]
  public let stars: [[Star]]
  public let yearlyDecStar: YearlyDecoration?

  public init(
    index: Int, kind: HoroscopePeriodKind, stem: HeavenlyStem, branch: EarthlyBranch,
    palaceIDs: [PalaceID], mutagens: [StarID], stars: [[Star]],
    yearlyDecStar: YearlyDecoration? = nil
  ) {
    self.index = index
    self.kind = kind
    self.stem = stem
    self.branch = branch
    self.palaceIDs = palaceIDs
    self.mutagens = mutagens
    self.stars = stars
    self.yearlyDecStar = yearlyDecStar
  }
}

/// The nominal-age period active on the target date.
public struct AgePeriod: Codable, Equatable, Sendable {
  public let index: Int
  public let nominalAge: Int
  public let stem: HeavenlyStem
  public let branch: EarthlyBranch
  public let palaceIDs: [PalaceID]
  public let mutagens: [StarID]

  public init(
    index: Int, nominalAge: Int, stem: HeavenlyStem, branch: EarthlyBranch,
    palaceIDs: [PalaceID], mutagens: [StarID]
  ) {
    self.index = index
    self.nominalAge = nominalAge
    self.stem = stem
    self.branch = branch
    self.palaceIDs = palaceIDs
    self.mutagens = mutagens
  }
}

/// All dynamic periods calculated for a target date.
public struct Horoscope: Codable, Equatable, Sendable {
  public let solarDate: SolarDate
  public let lunarDate: LunarDate
  public let decadal: HoroscopePeriod
  public let age: AgePeriod
  public let yearly: HoroscopePeriod
  public let monthly: HoroscopePeriod
  public let daily: HoroscopePeriod
  public let hourly: HoroscopePeriod

  public init(
    solarDate: SolarDate, lunarDate: LunarDate, decadal: HoroscopePeriod, age: AgePeriod,
    yearly: HoroscopePeriod, monthly: HoroscopePeriod, daily: HoroscopePeriod,
    hourly: HoroscopePeriod
  ) {
    self.solarDate = solarDate
    self.lunarDate = lunarDate
    self.decadal = decadal
    self.age = age
    self.yearly = yearly
    self.monthly = monthly
    self.daily = daily
    self.hourly = hourly
  }
}

/// The yearly general-before and year-before decoration cycles.
public struct YearlyDecoration: Codable, Equatable, Sendable {
  public let jiangqian12: [JiangqianStage]
  public let suiqian12: [SuiqianStage]

  public init(jiangqian12: [JiangqianStage], suiqian12: [SuiqianStage]) {
    self.jiangqian12 = jiangqian12
    self.suiqian12 = suiqian12
  }
}
