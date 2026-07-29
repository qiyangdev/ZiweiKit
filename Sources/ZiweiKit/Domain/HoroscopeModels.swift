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

  init(
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

}

/// The yearly general-before and year-before decoration cycles.
public struct YearlyDecoration: Codable, Equatable, Sendable {
  public let jiangqian12: [JiangqianStage]
  public let suiqian12: [SuiqianStage]

}
