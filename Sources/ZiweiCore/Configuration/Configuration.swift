/// Selects whether a boundary follows the lunar date or the exact solar term.
public enum DivideMode: String, Codable, Sendable {
  /// Uses the lunar-calendar boundary.
  case normal
  /// Uses the astronomical solar-term boundary.
  case exact
}

/// Selects how the active nominal-age period changes.
public enum AgeDivideMode: String, Codable, Sendable {
  /// Changes age periods at the lunar new year.
  case normal
  /// Changes age periods on the chart subject's lunar birthday.
  case birthday
}

/// Selects how the late rat period affects the day pillar.
public enum DayDivideMode: String, Codable, Sendable {
  /// Keeps the late rat period on the current calendar day.
  case current
  /// Advances the late rat period to the following day.
  case forward
}

/// The supported chart calculation rule set.
public enum ZiweiAlgorithm: String, Codable, Sendable {
  /// The standard rule set.
  case standard = "default"
  /// The Zhongzhou rule set.
  case zhongzhou
}

/// The palace frame used to construct an astrolabe.
public enum AstrolabeType: String, Codable, Sendable {
  /// Uses the natal life palace.
  case heaven
  /// Uses the body palace as the chart origin.
  case earth
  /// Uses the fortune palace as the chart origin.
  case human
}

/// Immutable, per-chart calculation settings.
///
/// Empty custom tables fall back to the built-in transformation and brightness
/// tables. Configuration is captured in the resulting ``Astrolabe``.
public struct ZiweiConfiguration: Codable, Equatable, Sendable {
  public let mutagens: [HeavenlyStem: [StarID]]
  public let brightness: [StarID: [Brightness?]]
  public let yearDivide: DivideMode
  public let horoscopeDivide: DivideMode
  public let ageDivide: AgeDivideMode
  public let dayDivide: DayDivideMode
  public let algorithm: ZiweiAlgorithm

  public init(
    mutagens: [HeavenlyStem: [StarID]] = [:],
    brightness: [StarID: [Brightness?]] = [:],
    yearDivide: DivideMode = .normal,
    horoscopeDivide: DivideMode = .normal,
    ageDivide: AgeDivideMode = .normal,
    dayDivide: DayDivideMode = .forward,
    algorithm: ZiweiAlgorithm = .standard
  ) {
    self.mutagens = mutagens
    self.brightness = brightness
    self.yearDivide = yearDivide
    self.horoscopeDivide = horoscopeDivide
    self.ageDivide = ageDivide
    self.dayDivide = dayDivide
    self.algorithm = algorithm
  }

  public static let `default` = ZiweiConfiguration()

  public func mutagenStars(for stem: HeavenlyStem) -> [StarID] {
    mutagens[stem] ?? Constants.mutagens[stem.rawValue]
  }

  public func brightness(of star: StarID, atPalaceIndex index: Int) -> Brightness? {
    Algorithms.brightness(star, at: index, configuration: self)
  }

  public func mutagen(of star: StarID, for stem: HeavenlyStem) -> Mutagen? {
    Algorithms.mutagen(star, yearStem: stem, configuration: self)
  }
}

/// The validated solar or lunar date used to create a chart.
public enum ChartDate: Codable, Equatable, Sendable {
  case solar(SolarDate)
  case lunar(LunarDate)
}

/// A value containing all inputs needed to create an ``Astrolabe``.
public struct ChartOptions: Codable, Equatable, Sendable {
  public let date: ChartDate
  public let hour: ChineseHour
  public let gender: Gender
  public let fixLeap: Bool
  public let astrolabeType: AstrolabeType
  public let configuration: ZiweiConfiguration

  public init(
    date: ChartDate, hour: ChineseHour, gender: Gender, fixLeap: Bool = true,
    astrolabeType: AstrolabeType = .heaven,
    configuration: ZiweiConfiguration = .default
  ) {
    self.date = date
    self.hour = hour
    self.gender = gender
    self.fixLeap = fixLeap
    self.astrolabeType = astrolabeType
    self.configuration = configuration
  }
}
