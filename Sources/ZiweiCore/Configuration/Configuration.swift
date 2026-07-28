import Foundation

public enum DivideMode: String, Codable, Sendable {
  case normal
  case exact
}

public enum AgeDivideMode: String, Codable, Sendable {
  case normal
  case birthday
}

public enum DayDivideMode: String, Codable, Sendable {
  case current
  case forward
}

public enum ZiweiAlgorithm: String, Codable, Sendable {
  case standard = "default"
  case zhongzhou
}

public enum AstrolabeType: String, Codable, Sendable {
  case heaven
  case earth
  case human
}

/// Immutable per-chart configuration corresponding to iztro's calculation config.
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

public enum ChartDate: Codable, Equatable, Sendable {
  case solar(SolarDate)
  case lunar(LunarDate)
}

public struct ChartOptions: Codable, Equatable, Sendable {
  public let date: ChartDate
  public let timeIndex: Int
  public let gender: Gender
  public let fixLeap: Bool
  public let astrolabeType: AstrolabeType
  public let configuration: ZiweiConfiguration

  public init(
    date: ChartDate, timeIndex: Int, gender: Gender, fixLeap: Bool = true,
    astrolabeType: AstrolabeType = .heaven,
    configuration: ZiweiConfiguration = .default
  ) {
    self.date = date
    self.timeIndex = timeIndex
    self.gender = gender
    self.fixLeap = fixLeap
    self.astrolabeType = astrolabeType
    self.configuration = configuration
  }
}
