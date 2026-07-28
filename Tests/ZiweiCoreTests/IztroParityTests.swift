import Foundation
import Testing

@testable import ZiweiCore

@Suite("iztro 2.5.8 parity")
struct IztroParityTests {
  @Test("all pinned reference charts match")
  func referenceCharts() throws {
    let fixtures = try loadFixtures()
    #expect(fixtures.count == 17)

    for fixture in fixtures {
      let gender = try #require(Gender(iztroName: fixture.input.gender))
      let chart: Astrolabe
      if fixture.input.type == "solar" {
        chart = try Ziwei.chart(
          solarDate: SolarDate(fixture.input.date),
          hour: chineseHour(fixture.input.timeIndex),
          gender: gender,
          fixLeap: fixture.input.fixLeap
        )
      } else {
        chart = try Ziwei.chart(
          lunarDate: LunarDate(
            fixture.input.date, isLeapMonth: fixture.input.isLeapMonth ?? false),
          hour: chineseHour(fixture.input.timeIndex),
          gender: gender,
          fixLeap: fixture.input.fixLeap
        )
      }
      #expect(snapshot(chart) == fixture.expected, "Reference mismatch: \(fixture.input.id)")
    }
  }

  @Test("default horoscope scopes match the reference")
  func referenceHoroscopes() throws {
    let url = try #require(
      Bundle.module.url(forResource: "iztro-2.5.8-horoscope", withExtension: "json"))
    let fixtures = try JSONDecoder().decode([HoroscopeFixture].self, from: Data(contentsOf: url))
    #expect(fixtures.count == 4)

    for fixture in fixtures {
      let gender = try #require(Gender(iztroName: fixture.input.gender))
      let chart = try Ziwei.chart(
        solarDate: SolarDate(fixture.input.birthDate),
        hour: chineseHour(fixture.input.birthTimeIndex),
        gender: gender
      )
      let horoscope = try chart.horoscope(
        at: SolarDate(fixture.input.targetDate),
        hour: chineseHour(fixture.input.targetTimeIndex)
      )
      let actual = HoroscopeExpected(
        solarDate: horoscope.solarDate.description,
        lunar: LunarFixture(
          year: horoscope.lunarDate.year,
          month: horoscope.lunarDate.month,
          day: horoscope.lunarDate.day,
          isLeapMonth: horoscope.lunarDate.isLeapMonth
        ),
        decadal: HoroscopePeriodFixture(horoscope.decadal),
        age: AgePeriodFixture(horoscope.age),
        yearly: HoroscopePeriodFixture(horoscope.yearly),
        monthly: HoroscopePeriodFixture(horoscope.monthly),
        daily: HoroscopePeriodFixture(horoscope.daily),
        hourly: HoroscopePeriodFixture(horoscope.hourly)
      )
      #expect(actual == fixture.expected, "Horoscope mismatch: \(fixture.input.id)")
    }
  }

  @Test("configuration, Zhongzhou, earth and human charts match the reference")
  func configuredCharts() throws {
    let url = try #require(
      Bundle.module.url(forResource: "iztro-2.5.8-configured", withExtension: "json"))
    let fixtures = try JSONDecoder().decode([ConfiguredFixture].self, from: Data(contentsOf: url))
    #expect(fixtures.count == 6)

    for fixture in fixtures {
      let input = fixture.input
      let chart: Astrolabe
      if input.type == "solar" {
        chart = try Ziwei.chart(
          solarDate: SolarDate(input.date), hour: chineseHour(input.timeIndex),
          gender: try #require(Gender(iztroName: input.gender)),
          fixLeap: input.fixLeap, configuration: input.config.configuration,
          astrolabeType: try #require(AstrolabeType(rawValue: input.astroType)))
      } else {
        chart = try Ziwei.chart(
          lunarDate: LunarDate(input.date, isLeapMonth: input.isLeapMonth ?? false),
          hour: chineseHour(input.timeIndex),
          gender: try #require(Gender(iztroName: input.gender)),
          fixLeap: input.fixLeap,
          configuration: input.config.configuration,
          astrolabeType: try #require(AstrolabeType(rawValue: input.astroType)))
      }
      #expect(snapshot(chart) == fixture.expected, "Configured mismatch: \(input.id)")
    }
  }

  @Test("configured horoscope dividers match the reference")
  func configuredHoroscopes() throws {
    let url = try #require(
      Bundle.module.url(
        forResource: "iztro-2.5.8-configured-horoscope", withExtension: "json"))
    let fixtures = try JSONDecoder().decode(
      [ConfiguredHoroscopeFixture].self, from: Data(contentsOf: url))
    #expect(fixtures.count == 2)

    for fixture in fixtures {
      let input = fixture.input
      let date: ChartDate =
        input.type == "solar"
        ? .solar(try SolarDate(input.birthDate))
        : .lunar(try LunarDate(input.birthDate))
      let chart = try Ziwei.chart(
        options: ChartOptions(
          date: date, hour: chineseHour(input.birthTimeIndex),
          gender: try #require(Gender(iztroName: input.gender)),
          configuration: input.config.configuration))
      let horoscope = try chart.horoscope(
        at: SolarDate(input.targetDate), hour: chineseHour(input.targetTimeIndex))
      #expect(horoscopeSnapshot(horoscope) == fixture.expected, "Horoscope mismatch: \(input.id)")
    }
  }

  @Test("functional analyzers match iztro semantics")
  func analyzers() throws {
    let chart = try Ziwei.chart(
      solarDate: SolarDate("1987-9-23"), hour: .lateZi, gender: .female,
      configuration: ZiweiConfiguration(dayDivide: .current))
    let soul = try #require(chart.palace(.life))
    #expect(soul.isEmpty)
    #expect(soul.contains([.huoxing, .tianyue]))
    #expect(
      chart.palace(.travel)?.contains([
        .taiyang, .tianliang, .youbi, .bazuo, .tiangui, .kongwang, .tianku,
      ]) == true)

    let flying = try Ziwei.chart(
      solarDate: SolarDate("2017-12-4"), hour: .lateZi, gender: .male)
    let flyingSoul = try #require(flying.palace(.life))
    #expect(flyingSoul.flies(to: .siblings, mutagens: [.obstacle], in: flying))
    #expect(flyingSoul.doesNotFly(to: .siblings, mutagens: [.reputation], in: flying))
    let flyingHome = try #require(flying.palace(.property))
    #expect(flyingHome.flies(to: .fortune, mutagens: [.prosperity, .reputation], in: flying))
    let flyingSiblings = try #require(flying.palace(.siblings))
    #expect(!flyingSiblings.flies(to: .spouse, mutagens: [.power, .reputation], in: flying))
    #expect(flyingSiblings.fliesAny(to: .spouse, mutagens: [.power, .reputation], in: flying))
    let flyingFriends = try #require(flying.palace(.friends))
    #expect(flyingFriends.isSelfMutated(by: [.reputation], in: flying))
    #expect(!flyingFriends.isSelfMutated(by: [.reputation, .power], in: flying))
    #expect(flyingFriends.isSelfMutatedByAny([.reputation, .power], in: flying))
    #expect(
      flyingSoul.mutatedPalaces(in: flying).compactMap { $0?.id }
        == [.life, .travel, .friends, .siblings])

    let canonical = try Ziwei.chart(
      solarDate: SolarDate("2000-8-16"), hour: .yin, gender: .female)
    #expect(canonical.star(.ziwei)?.palace(in: canonical) != nil)
    #expect(canonical.surroundingPalaces(of: .life)?.all.count == 4)

    let horoscope = try canonical.horoscope(at: SolarDate("2026-7-28"), hour: .wu)
    #expect(horoscope.agePalace(in: canonical)?.index == horoscope.age.index)
    #expect(horoscope.palace(.life, scope: .yearly, in: canonical) != nil)

    let referenceHoroscope = try canonical.horoscope(at: SolarDate("2023-8-19"), hour: .yin)
    #expect(
      referenceHoroscope.containsHoroscopeStars(
        [.liuTuo, .liuQu, .yunChang], in: .health, scope: .decadal, astrolabe: canonical))
    #expect(
      referenceHoroscope.containsNoneOfHoroscopeStars(
        [.liuXi, .liuLuan, .liuKui], in: .health, scope: .decadal, astrolabe: canonical))
    #expect(
      referenceHoroscope.containsAnyHoroscopeStars(
        [.liuTuo, .liuQu, .yunChang], in: .health, scope: .decadal, astrolabe: canonical))
    #expect(
      referenceHoroscope.containsHoroscopeMutagen(
        .prosperity, in: .siblings, scope: .decadal, astrolabe: canonical))
  }

  @Test("exact solar-term boundaries match across the supported range")
  func solarTermBoundaries() throws {
    let url = try #require(
      Bundle.module.url(forResource: "iztro-2.5.8-solar-terms", withExtension: "json"))
    let fixtures = try JSONDecoder().decode(
      [SolarTermFixture].self, from: Data(contentsOf: url))
    #expect(fixtures.count == 120)
    let configuration = ZiweiConfiguration(yearDivide: .exact, horoscopeDivide: .exact)
    for fixture in fixtures {
      let chart = try Ziwei.chart(
        solarDate: SolarDate(fixture.input.date),
        hour: chineseHour(fixture.input.timeIndex), gender: .male,
        configuration: configuration)
      let actual = SolarTermExpected(
        zodiac: chart.zodiacBranch.iztroZodiac,
        yearly: chart.rawChineseDate.yearly.iztroDescription,
        monthly: chart.rawChineseDate.monthly.iztroDescription,
        daily: chart.rawChineseDate.daily.iztroDescription,
        hourly: chart.rawChineseDate.hourly.iztroDescription)
      #expect(actual == fixture.expected, "Solar-term mismatch: \(fixture.input.id)")
    }
  }

  @Test("solar and lunar entry points are equivalent")
  func entryPointEquivalence() throws {
    let solar = try Ziwei.chart(
      solarDate: SolarDate("2000-8-16"), hour: .yin, gender: .female)
    let lunar = try Ziwei.chart(
      lunarDate: LunarDate("2000-7-17"), hour: .yin, gender: .female)
    #expect(solar == lunar)
  }

  @Test("native date parsing and extension hooks")
  func nativeConveniences() throws {
    let dashed = try Ziwei.chart(
      solarDate: SolarDate("1979-8-21"), hour: .wu, gender: .male)
    let dotted = try Ziwei.chart(
      solarDate: SolarDate("1979.08.21"), hour: .wu, gender: .male)
    #expect(dashed == dotted)
    #expect(ChineseHour(clockHour: 0) == .earlyZi)
    #expect(ChineseHour(clockHour: 12) == .wu)
    #expect(ChineseHour(clockHour: 23) == .lateZi)
    #expect(
      (0...23).compactMap(ChineseHour.init(clockHour:))
        == [
          .earlyZi, .chou, .chou, .yin, .yin, .mao, .mao, .chen, .chen, .si, .si, .wu,
          .wu, .wei, .wei, .shen, .shen, .you, .you, .xu, .xu, .hai, .hai, .lateZi,
        ])
    #expect(ChineseHour.earlyZi.branch == .zi)
    #expect(ChineseHour.lateZi.branch == .zi)

    let horoscope = try dotted.horoscope(at: SolarDate("2025-06-10"), hour: .wu)
    #expect(horoscope.monthly.index == 7)
    #expect(horoscope.daily.index == 9)
    #expect(horoscope.yearly.yearlyDecStar?.jiangqian12.count == 12)
    #expect(dotted.analyze { $0.palaces.count } == 12)
  }

  @Test("strongly typed models preserve invariants and Codable round trips")
  func typedModelInvariants() throws {
    #expect(PalaceID.allCases.map(\.rawValue).count == Set(PalaceID.allCases.map(\.rawValue)).count)
    #expect(StarID.allCases.map(\.rawValue).count == Set(StarID.allCases.map(\.rawValue)).count)

    let star = Star(
      id: .ziwei, type: .major, brightness: .temple, mutagen: .prosperity)
    let starData = try JSONEncoder().encode(star)
    #expect(try JSONDecoder().decode(Star.self, from: starData) == star)
    #expect(String(decoding: starData, as: UTF8.self).contains("ziwei"))

    let chart = try Ziwei.chart(
      solarDate: SolarDate("2000-8-16"), hour: .yin, gender: .female)
    let chartData = try JSONEncoder().encode(chart)
    #expect(try JSONDecoder().decode(Astrolabe.self, from: chartData) == chart)

    #expect((1...12).contains { (try? LunarDate(year: 2000, month: $0, day: 30)) == nil })
    let invalidSolarData = Data(#"{"year":2000,"month":2,"day":31}"#.utf8)
    #expect(throws: ZiweiError.invalidDate("2000-2-31")) {
      try JSONDecoder().decode(SolarDate.self, from: invalidSolarData)
    }
  }

  @Test("invalid input is rejected")
  func invalidInput() throws {
    #expect(ChineseHour(clockHour: -1) == nil)
    #expect(ChineseHour(clockHour: 24) == nil)
    #expect(throws: ZiweiError.invalidDate("not-a-date")) {
      try SolarDate("not-a-date")
    }
    #expect(throws: ZiweiError.invalidDate("2000-2-31")) {
      try SolarDate("2000-2-31")
    }
    #expect(throws: ZiweiError.invalidDate("2000-2-31")) {
      try SolarDate(year: 2000, month: 2, day: 31)
    }
  }

  private func loadFixtures() throws -> [Fixture] {
    let url = try #require(Bundle.module.url(forResource: "iztro-2.5.8", withExtension: "json"))
    return try JSONDecoder().decode([Fixture].self, from: Data(contentsOf: url))
  }

  private func chineseHour(_ rawValue: Int) throws -> ChineseHour {
    try #require(ChineseHour(rawValue: rawValue))
  }

  private func snapshot(_ chart: Astrolabe) -> ChartFixture {
    ChartFixture(
      gender: chart.gender.iztroName,
      solarDate: chart.solarDate.description,
      time: IztroTimeFormatter.names[chart.hour.rawValue],
      timeRange: IztroTimeFormatter.ranges[chart.hour.rawValue],
      sign: chart.westernZodiac.iztroName,
      zodiac: chart.zodiacBranch.iztroZodiac,
      earthlyBranchOfSoulPalace: chart.soulPalaceBranch.iztroName,
      earthlyBranchOfBodyPalace: chart.bodyPalaceBranch.iztroName,
      soul: chart.soulStarID.iztroName,
      body: chart.bodyStarID.iztroName,
      fiveElementsClass: chart.fiveElementsClass.iztroName,
      lunar: .init(
        year: chart.lunarDate.year,
        month: chart.lunarDate.month,
        day: chart.lunarDate.day,
        isLeapMonth: chart.lunarDate.isLeapMonth
      ),
      pillars: PillarFixture(
        yearly: chart.rawChineseDate.yearly.iztroDescription,
        monthly: chart.rawChineseDate.monthly.iztroDescription,
        daily: chart.rawChineseDate.daily.iztroDescription,
        hourly: chart.rawChineseDate.hourly.iztroDescription
      ),
      palaces: chart.palaces.map { palace in
        PalaceFixture(
          index: palace.index,
          name: palace.id.iztroName,
          isBodyPalace: palace.isBodyPalace,
          isOriginalPalace: palace.isOriginalPalace,
          heavenlyStem: palace.stem.iztroName,
          earthlyBranch: palace.branch.iztroName,
          majorStars: palace.majorStars.map(StarFixture.init),
          minorStars: palace.minorStars.map(StarFixture.init),
          adjectiveStars: palace.adjectiveStars.map(StarFixture.init),
          changsheng12: palace.changsheng12.iztroName,
          boshi12: palace.boshi12.iztroName,
          jiangqian12: palace.jiangqian12.iztroName,
          suiqian12: palace.suiqian12.iztroName,
          decadal: DecadalFixture(palace.decadal),
          ages: palace.ages
        )
      }
    )
  }

  private func horoscopeSnapshot(_ horoscope: Horoscope) -> HoroscopeExpected {
    HoroscopeExpected(
      solarDate: horoscope.solarDate.description,
      lunar: LunarFixture(
        year: horoscope.lunarDate.year,
        month: horoscope.lunarDate.month,
        day: horoscope.lunarDate.day,
        isLeapMonth: horoscope.lunarDate.isLeapMonth),
      decadal: HoroscopePeriodFixture(horoscope.decadal),
      age: AgePeriodFixture(horoscope.age),
      yearly: HoroscopePeriodFixture(horoscope.yearly),
      monthly: HoroscopePeriodFixture(horoscope.monthly),
      daily: HoroscopePeriodFixture(horoscope.daily),
      hourly: HoroscopePeriodFixture(horoscope.hourly))
  }
}

private struct Fixture: Decodable {
  let input: Input
  let expected: ChartFixture
}

private struct Input: Decodable {
  let id: String
  let type: String
  let date: String
  let timeIndex: Int
  let gender: String
  let isLeapMonth: Bool?
  let fixLeap: Bool
}

private struct ChartFixture: Codable, Equatable {
  let gender: String
  let solarDate: String
  let time: String
  let timeRange: String
  let sign: String
  let zodiac: String
  let earthlyBranchOfSoulPalace: String
  let earthlyBranchOfBodyPalace: String
  let soul: String
  let body: String
  let fiveElementsClass: String
  let lunar: LunarFixture
  let pillars: PillarFixture
  let palaces: [PalaceFixture]

}

private struct LunarFixture: Codable, Equatable {
  let year: Int
  let month: Int
  let day: Int
  let isLeapMonth: Bool
}

private struct PillarFixture: Codable, Equatable {
  let yearly: String
  let monthly: String
  let daily: String
  let hourly: String
}

private struct PalaceFixture: Codable, Equatable {
  let index: Int
  let name: String
  let isBodyPalace: Bool
  let isOriginalPalace: Bool
  let heavenlyStem: String
  let earthlyBranch: String
  let majorStars: [StarFixture]
  let minorStars: [StarFixture]
  let adjectiveStars: [StarFixture]
  let changsheng12: String
  let boshi12: String
  let jiangqian12: String
  let suiqian12: String
  let decadal: DecadalFixture
  let ages: [Int]

}

private struct DecadalFixture: Codable, Equatable {
  let range: [Int]
  let heavenlyStem: String
  let earthlyBranch: String

  init(_ decadal: Decadal) {
    range = decadal.range
    heavenlyStem = decadal.stem.iztroName
    earthlyBranch = decadal.branch.iztroName
  }
}

private struct StarFixture: Codable, Equatable {
  let name: String
  let type: StarType
  let scope: String
  let brightness: String?
  let mutagen: String?

  init(_ star: Star) {
    name = star.id.iztroName
    type = star.type
    scope = star.scope.rawValue
    brightness = star.brightness?.iztroName
    mutagen = star.mutagen?.iztroName
  }
}

private struct HoroscopeFixture: Decodable {
  let input: HoroscopeInput
  let expected: HoroscopeExpected
}

private struct HoroscopeInput: Decodable {
  let id: String
  let birthDate: String
  let birthTimeIndex: Int
  let gender: String
  let targetDate: String
  let targetTimeIndex: Int
}

private struct HoroscopeExpected: Codable, Equatable {
  let solarDate: String
  let lunar: LunarFixture
  let decadal: HoroscopePeriodFixture
  let age: AgePeriodFixture
  let yearly: HoroscopePeriodFixture
  let monthly: HoroscopePeriodFixture
  let daily: HoroscopePeriodFixture
  let hourly: HoroscopePeriodFixture
}

private struct HoroscopePeriodFixture: Codable, Equatable {
  let index: Int
  let name: String
  let heavenlyStem: String
  let earthlyBranch: String
  let palaceNames: [String]
  let mutagen: [String]
  let stars: [[StarFixture]]
  let yearlyDecStar: YearlyDecorationFixture?

  init(_ period: HoroscopePeriod) {
    index = period.index
    name = period.kind.iztroName
    heavenlyStem = period.stem.iztroName
    earthlyBranch = period.branch.iztroName
    palaceNames = period.palaceIDs.map(\.iztroName)
    mutagen = period.mutagens.map(\.iztroName)
    stars = period.stars.map { $0.map(StarFixture.init) }
    yearlyDecStar = period.yearlyDecStar.map(YearlyDecorationFixture.init)
  }
}

private struct AgePeriodFixture: Codable, Equatable {
  let index: Int
  let nominalAge: Int
  let name: String
  let heavenlyStem: String
  let earthlyBranch: String
  let palaceNames: [String]
  let mutagen: [String]

  init(_ period: AgePeriod) {
    index = period.index
    nominalAge = period.nominalAge
    name = HoroscopePeriodKind.age.iztroName
    heavenlyStem = period.stem.iztroName
    earthlyBranch = period.branch.iztroName
    palaceNames = period.palaceIDs.map(\.iztroName)
    mutagen = period.mutagens.map(\.iztroName)
  }
}

private struct YearlyDecorationFixture: Codable, Equatable {
  let jiangqian12: [String]
  let suiqian12: [String]

  init(_ decoration: YearlyDecoration) {
    jiangqian12 = decoration.jiangqian12.map(\.iztroName)
    suiqian12 = decoration.suiqian12.map(\.iztroName)
  }
}

private struct ConfiguredFixture: Decodable {
  let input: ConfiguredInput
  let expected: ChartFixture
}

private struct ConfiguredInput: Decodable {
  let id: String
  let type: String
  let date: String
  let timeIndex: Int
  let gender: String
  let isLeapMonth: Bool?
  let fixLeap: Bool
  let config: ConfigurationFixture
  let astroType: String
}

private struct ConfigurationFixture: Decodable {
  let mutagens: [String: [String]]?
  let brightness: [String: [String]]?
  let yearDivide: DivideMode?
  let horoscopeDivide: DivideMode?
  let ageDivide: AgeDivideMode?
  let dayDivide: DayDivideMode?
  let algorithm: ZiweiAlgorithm?

  var configuration: ZiweiConfiguration {
    ZiweiConfiguration(
      mutagens: Dictionary(
        uniqueKeysWithValues: (mutagens ?? [:]).compactMap { key, value in
          HeavenlyStem(iztroName: key).map {
            ($0, value.compactMap(StarID.init(iztroName:)))
          }
        }),
      brightness: Dictionary(
        uniqueKeysWithValues: (brightness ?? [:]).compactMap { key, value in
          StarID(iztroName: key).map {
            ($0, value.map(Brightness.init(iztroName:)))
          }
        }),
      yearDivide: yearDivide ?? .normal,
      horoscopeDivide: horoscopeDivide ?? .normal,
      ageDivide: ageDivide ?? .normal,
      dayDivide: dayDivide ?? .forward,
      algorithm: algorithm ?? .standard)
  }
}

private struct ConfiguredHoroscopeFixture: Decodable {
  let input: ConfiguredHoroscopeInput
  let expected: HoroscopeExpected
}

private struct ConfiguredHoroscopeInput: Decodable {
  let id: String
  let type: String
  let birthDate: String
  let birthTimeIndex: Int
  let gender: String
  let targetDate: String
  let targetTimeIndex: Int
  let config: ConfigurationFixture
}

private struct SolarTermFixture: Decodable {
  let input: SolarTermInput
  let expected: SolarTermExpected
}

private struct SolarTermInput: Decodable {
  let id: String
  let date: String
  let timeIndex: Int
}

private struct SolarTermExpected: Codable, Equatable {
  let zodiac: String
  let yearly: String
  let monthly: String
  let daily: String
  let hourly: String
}
