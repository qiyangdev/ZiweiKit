public enum Gender: String, Codable, CaseIterable, Sendable {
  case male  // 男
  case female  // 女

  var yinYang: YinYang { self == .male ? .yang : .yin }
}

public enum FiveElementsClass: Int, Codable, Sendable {
  case water = 2  // 水二局
  case wood = 3  // 木三局
  case metal = 4  // 金四局
  case earth = 5  // 土五局
  case fire = 6  // 火六局
}

public enum StarType: String, Codable, Sendable {
  case major, soft, tough, lucun, tianma, flower, helper, adjective
}

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

public struct Decadal: Codable, Equatable, Sendable {
  public let range: [Int]
  public let stem: HeavenlyStem
  public let branch: EarthlyBranch

  public init(range: [Int], stem: HeavenlyStem, branch: EarthlyBranch) {
    self.range = range
    self.stem = stem
    self.branch = branch
  }
}

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

  public init(
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

public struct Astrolabe: Codable, Equatable, Sendable {
  public let configuration: ZiweiConfiguration
  public let astrolabeType: AstrolabeType
  public let fixLeap: Bool
  public let gender: Gender
  public let solarDate: SolarDate
  public let lunarDate: LunarDate
  public let rawChineseDate: ChineseDate
  public let timeIndex: Int
  public let westernZodiac: WesternZodiac
  public let zodiacBranch: EarthlyBranch
  public let soulPalaceBranch: EarthlyBranch
  public let bodyPalaceBranch: EarthlyBranch
  public let soulStarID: StarID
  public let bodyStarID: StarID
  public let fiveElementsClass: FiveElementsClass
  public let palaces: [Palace]

  public init(
    configuration: ZiweiConfiguration, astrolabeType: AstrolabeType, fixLeap: Bool,
    gender: Gender, solarDate: SolarDate, lunarDate: LunarDate,
    rawChineseDate: ChineseDate, timeIndex: Int, westernZodiac: WesternZodiac,
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
    self.timeIndex = timeIndex
    self.westernZodiac = westernZodiac
    self.zodiacBranch = zodiacBranch
    self.soulPalaceBranch = soulPalaceBranch
    self.bodyPalaceBranch = bodyPalaceBranch
    self.soulStarID = soulStarID
    self.bodyStarID = bodyStarID
    self.fiveElementsClass = fiveElementsClass
    self.palaces = palaces
  }

  public func palace(at index: Int) -> Palace? {
    palaces.indices.contains(index) ? palaces[index] : nil
  }

  /// The target, opposite, wealth and career positions (三方四正).
  public func surroundedPalaces(of index: Int) -> [Palace] {
    [index, index + 4, index + 6, index + 8].compactMap { palace(at: positiveModulo($0)) }
  }

  public func horoscope(at targetDate: String, timeIndex: Int? = nil) throws -> Horoscope {
    let resolvedTimeIndex =
      timeIndex ?? Ziwei.timeIndex(forHour: SolarDate.hour(in: targetDate) ?? 0)
    return try HoroscopeCalculator.calculate(
      chart: self, target: SolarDate(targetDate), timeIndex: resolvedTimeIndex)
  }

  public func horoscope(at targetDate: SolarDate, timeIndex: Int = 0) throws -> Horoscope {
    try HoroscopeCalculator.calculate(chart: self, target: targetDate, timeIndex: timeIndex)
  }

  public var bodyPalace: Palace? { palaces.first(where: \.isBodyPalace) }

  public var originalPalace: Palace? { palaces.first(where: \.isOriginalPalace) }
}
