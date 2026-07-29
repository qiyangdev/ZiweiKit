/// The gender value used to determine directional chart rules.
public enum Gender: String, Codable, CaseIterable, Sendable {
  case male  // 男
  case female  // 女

  var yinYang: YinYang { self == .male ? .yang : .yin }
}

/// The five-elements class (五行局) and its associated cycle number.
public enum FiveElementsClass: Int, Codable, Sendable {
  case water = 2  // 水二局
  case wood = 3  // 木三局
  case metal = 4  // 金四局
  case earth = 5  // 土五局
  case fire = 6  // 火六局
}

/// The calculation category assigned to a star.
public enum StarType: String, Codable, Sendable {
  case major, soft, tough, lucun, tianma, flower, helper, adjective
}

/// A star placement with its scope, brightness, and optional transformation.
public struct Star: Codable, Equatable, Sendable {
  public let id: StarID
  public let type: StarType
  public let scope: StarScope
  public let brightness: Brightness?
  public let mutagen: Mutagen?

  public init(
    id: StarID, type: StarType, scope: StarScope = .origin, brightness: Brightness? = nil,
    mutagen: Mutagen? = nil
  ) {
    self.id = id
    self.type = type
    self.scope = scope
    self.brightness = brightness
    self.mutagen = mutagen
  }
}

/// The age range and stem-branch pair associated with a decadal period.
public struct Decadal: Codable, Equatable, Sendable {
  public let range: [Int]
  public let stem: HeavenlyStem
  public let branch: EarthlyBranch

}

/// One of the twelve chart palaces and all calculated values placed in it.
public struct Palace: Codable, Equatable, Sendable {
  public let index: Int
  public let id: PalaceID
  public let isBodyPalace: Bool
  public let isOriginalPalace: Bool
  public let stem: HeavenlyStem
  public let branch: EarthlyBranch
  public let majorStars: [Star]
  public let minorStars: [Star]
  public let adjectiveStars: [Star]
  public let changsheng12: ChangshengStage
  public let boshi12: BoshiStage
  public let jiangqian12: JiangqianStage
  public let suiqian12: SuiqianStage
  public let decadal: Decadal
  public let ages: [Int]

  public var stars: [Star] { majorStars + minorStars + adjectiveStars }

  init(
    index: Int, id: PalaceID, isBodyPalace: Bool, isOriginalPalace: Bool,
    stem: HeavenlyStem, branch: EarthlyBranch, majorStars: [Star], minorStars: [Star],
    adjectiveStars: [Star], changsheng12: ChangshengStage, boshi12: BoshiStage,
    jiangqian12: JiangqianStage, suiqian12: SuiqianStage, decadal: Decadal, ages: [Int]
  ) {
    self.index = index
    self.id = id
    self.isBodyPalace = isBodyPalace
    self.isOriginalPalace = isOriginalPalace
    self.stem = stem
    self.branch = branch
    self.majorStars = majorStars
    self.minorStars = minorStars
    self.adjectiveStars = adjectiveStars
    self.changsheng12 = changsheng12
    self.boshi12 = boshi12
    self.jiangqian12 = jiangqian12
    self.suiqian12 = suiqian12
    self.decadal = decadal
    self.ages = ages
  }
}

/// An immutable natal chart containing its input, pillars, palaces, and stars.
public struct Astrolabe: Codable, Equatable, Sendable {
  public let configuration: ZiweiConfiguration
  public let astrolabeType: AstrolabeType
  public let fixLeap: Bool
  public let gender: Gender
  public let solarDate: SolarDate
  public let lunarDate: LunarDate
  public let rawChineseDate: ChineseDate
  public let hour: ChineseHour
  public let westernZodiac: WesternZodiac
  public let zodiacBranch: EarthlyBranch
  public let soulPalaceBranch: EarthlyBranch
  public let bodyPalaceBranch: EarthlyBranch
  public let soulStarID: StarID
  public let bodyStarID: StarID
  public let fiveElementsClass: FiveElementsClass
  public let palaces: [Palace]

  init(
    configuration: ZiweiConfiguration, astrolabeType: AstrolabeType, fixLeap: Bool,
    gender: Gender, solarDate: SolarDate, lunarDate: LunarDate,
    rawChineseDate: ChineseDate, hour: ChineseHour, westernZodiac: WesternZodiac,
    zodiacBranch: EarthlyBranch, soulPalaceBranch: EarthlyBranch,
    bodyPalaceBranch: EarthlyBranch, soulStarID: StarID, bodyStarID: StarID,
    fiveElementsClass: FiveElementsClass, palaces: [Palace]
  ) {
    self.configuration = configuration
    self.astrolabeType = astrolabeType
    self.fixLeap = fixLeap
    self.gender = gender
    self.solarDate = solarDate
    self.lunarDate = lunarDate
    self.rawChineseDate = rawChineseDate
    self.hour = hour
    self.westernZodiac = westernZodiac
    self.zodiacBranch = zodiacBranch
    self.soulPalaceBranch = soulPalaceBranch
    self.bodyPalaceBranch = bodyPalaceBranch
    self.soulStarID = soulStarID
    self.bodyStarID = bodyStarID
    self.fiveElementsClass = fiveElementsClass
    self.palaces = palaces
  }

  /// Returns the palace at a zero-based chart index, or `nil` when out of range.
  public func palace(at index: Int) -> Palace? {
    palaces.indices.contains(index) ? palaces[index] : nil
  }

  /// The target, opposite, wealth and career positions (三方四正).
  public func surroundedPalaces(of index: Int) -> [Palace] {
    [index, index + 4, index + 6, index + 8].compactMap { palace(at: positiveModulo($0)) }
  }

  /// Calculates dynamic periods for a target date and traditional hour.
  public func horoscope(at targetDate: SolarDate, hour: ChineseHour = .earlyZi) throws -> Horoscope
  {
    try HoroscopeCalculator.calculate(chart: self, target: targetDate, hour: hour)
  }

  public var bodyPalace: Palace? { palaces.first(where: \.isBodyPalace) }

  public var originalPalace: Palace? { palaces.first(where: \.isOriginalPalace) }
}
