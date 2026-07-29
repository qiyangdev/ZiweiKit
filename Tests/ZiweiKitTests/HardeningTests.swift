import Foundation
import Testing

@testable import ZiweiKit

@Suite("hardening and invariants")
struct HardeningTests {
  @Test("custom configuration rows are validated without unsafe indexing")
  func configurationValidation() throws {
    let date = try SolarDate("2000-8-16")
    let shortBrightness = ZiweiConfiguration(brightness: [.ziwei: [.temple]])
    #expect(shortBrightness.brightness(of: .ziwei, atPalaceIndex: 11) == nil)
    #expect(throwsInvalidConfiguration { try shortBrightness.validate() })
    #expect(
      throwsInvalidConfiguration {
        _ = try Ziwei.chart(
          solarDate: date, hour: .yin, gender: .female, configuration: shortBrightness)
      })

    let shortMutagens = ZiweiConfiguration(mutagens: [.jia: [.ziwei]])
    #expect(throwsInvalidConfiguration { try shortMutagens.validate() })

    let emptyBrightness = ZiweiConfiguration(brightness: [.ziwei: []])
    try emptyBrightness.validate()
    #expect(
      emptyBrightness.brightness(of: .ziwei, atPalaceIndex: 0)
        == ZiweiConfiguration.default.brightness(of: .ziwei, atPalaceIndex: 0))

    let encoded = try JSONEncoder().encode(shortBrightness)
    #expect((try? JSONDecoder().decode(ZiweiConfiguration.self, from: encoded)) == nil)
  }

  @Test("date strings require exactly three numeric fields")
  func strictDateParsing() throws {
    #expect(try SolarDate("2000/08/16 12:00") == SolarDate(year: 2000, month: 8, day: 16))
    #expect(try LunarDate("2000.7.17") == LunarDate(year: 2000, month: 7, day: 17))

    for value in [
      "2000-8-16-1", "2000--8-16", "2000-foo-8-16", "2000-8/16x", "2000/8/16/",
    ] {
      #expect(throws: ZiweiError.invalidDate(value)) { try SolarDate(value) }
      #expect(throws: ZiweiError.invalidDate(value)) { try LunarDate(value) }
    }
  }

  @Test("calculation entry points enforce the verified year range")
  func supportedRange() throws {
    #expect(Ziwei.supportedYearRange == (1901...2099))
    let early = try SolarDate(year: 1900, month: 1, day: 1)
    let late = try SolarDate(year: 2100, month: 1, day: 1)
    #expect(throws: ZiweiError.unsupportedYear(1900)) {
      try Ziwei.chart(solarDate: early, hour: .earlyZi, gender: .male)
    }
    #expect(throws: ZiweiError.unsupportedYear(2100)) {
      try Ziwei.lunarDate(fromSolar: late)
    }
  }

  @Test("every supported Gregorian date round trips through the Chinese calendar")
  func fullRangeCalendarRoundTrip() throws {
    for year in Ziwei.supportedYearRange {
      for month in 1...12 {
        for day in 1...31 {
          guard let solar = try? SolarDate(year: year, month: month, day: day) else { continue }
          let lunar = try Ziwei.lunarDate(fromSolar: solar)
          #expect(try Ziwei.solarDate(fromLunar: lunar) == solar)
        }
      }
    }

    let lunarNewYear = try Ziwei.lunarDate(fromSolar: SolarDate("2024-2-10"))
    #expect(lunarNewYear == (try LunarDate(year: 2024, month: 1, day: 1)))
  }

  @Test("generated charts preserve twelve-palace structural invariants")
  func chartInvariants() throws {
    for year in [1901, 1950, 2000, 2099] {
      for hour in ChineseHour.allCases {
        for gender in Gender.allCases {
          for type in [AstrolabeType.heaven, .earth, .human] {
            let chart = try Ziwei.chart(
              solarDate: SolarDate(year: year, month: 6, day: 15), hour: hour,
              gender: gender, astrolabeType: type)
            #expect(chart.palaces.count == 12)
            #expect(chart.palaces.enumerated().allSatisfy { $0.offset == $0.element.index })
            #expect(Set(chart.palaces.map(\.id)) == Set(PalaceID.allCases))
            #expect(chart.palaces.filter(\.isBodyPalace).count == 1)
            #expect(chart.palaces.allSatisfy { $0.decadal.range.count == 2 })
            #expect(chart.palaces.allSatisfy { $0.ages.count == 10 })
            #expect(Set(chart.palaces.flatMap(\.ages)) == Set(1...120))
          }
        }
      }
    }
  }

  @Test("malformed encoded models are rejected")
  func malformedModelDecoding() throws {
    let chart = try Ziwei.chart(
      solarDate: SolarDate("2000-8-16"), hour: .yin, gender: .female)
    var chartObject = try #require(
      JSONSerialization.jsonObject(with: JSONEncoder().encode(chart)) as? [String: Any])
    var palaces = try #require(chartObject["palaces"] as? [[String: Any]])
    palaces.removeLast()
    chartObject["palaces"] = palaces
    let malformedChart = try JSONSerialization.data(withJSONObject: chartObject)
    #expect((try? JSONDecoder().decode(Astrolabe.self, from: malformedChart)) == nil)

    var reorderedObject = try #require(
      JSONSerialization.jsonObject(with: JSONEncoder().encode(chart)) as? [String: Any])
    var reorderedPalaces = try #require(reorderedObject["palaces"] as? [[String: Any]])
    reorderedPalaces.swapAt(0, 1)
    reorderedObject["palaces"] = reorderedPalaces
    let reorderedChart = try JSONSerialization.data(withJSONObject: reorderedObject)
    #expect((try? JSONDecoder().decode(Astrolabe.self, from: reorderedChart)) == nil)

    let horoscope = try chart.horoscope(at: SolarDate("2026-7-28"), hour: .wu)
    var horoscopeObject = try #require(
      JSONSerialization.jsonObject(with: JSONEncoder().encode(horoscope)) as? [String: Any])
    var yearly = try #require(horoscopeObject["yearly"] as? [String: Any])
    yearly["stars"] = []
    horoscopeObject["yearly"] = yearly
    let malformedHoroscope = try JSONSerialization.data(withJSONObject: horoscopeObject)
    #expect((try? JSONDecoder().decode(Horoscope.self, from: malformedHoroscope)) == nil)
  }

  @Test("analysis helpers handle all scopes and empty queries")
  func analyzerBoundaries() throws {
    let chart = try Ziwei.chart(
      solarDate: SolarDate("2000-8-16"), hour: .yin, gender: .female)
    let life = try #require(chart.palace(.life))
    let group = try #require(chart.surroundingPalaces(of: .life))

    #expect(life.contains([]))
    #expect(!life.containsAny(of: []))
    #expect(life.containsNone(of: []))
    #expect(group.contains([]))
    #expect(!group.containsAny(of: []))
    #expect(group.containsNone(of: []))
    #expect(chart.palace(at: -1) == nil)
    #expect(chart.palace(at: 12) == nil)
    let ziwei = try #require(chart.star(.ziwei))
    #expect(ziwei.hasAnyBrightness(Brightness.allCases))
    #expect(ziwei.hasAnyMutagen(Mutagen.allCases) == (ziwei.mutagen != nil))
    if let brightness = ziwei.brightness { #expect(ziwei.hasBrightness(brightness)) }
    if let mutagen = ziwei.mutagen { #expect(ziwei.hasMutagen(mutagen)) }
    #expect(try chart.use(PalaceCountPlugin()) == 12)

    let horoscope = try chart.horoscope(at: SolarDate("2026-7-28"), hour: .wu)
    for scope in StarScope.allCases {
      #expect(horoscope.palace(.life, scope: scope, in: chart) != nil)
      #expect(horoscope.surroundingPalaces(of: .life, scope: scope, in: chart)?.all.count == 4)
    }
    #expect(
      !horoscope.containsAnyHoroscopeStars(
        [], in: .life, scope: .yearly, astrolabe: chart))
    #expect(
      !horoscope.containsHoroscopeMutagen(
        .prosperity, in: .life, scope: .origin, astrolabe: chart))
  }
}

private func throwsInvalidConfiguration(_ operation: () throws -> Void) -> Bool {
  do {
    try operation()
    return false
  } catch let error as ZiweiError {
    switch error {
    case .invalidMutagenCount, .invalidBrightnessCount: return true
    default: return false
    }
  } catch {
    return false
  }
}

private struct PalaceCountPlugin: AstrolabePlugin {
  func apply(to astrolabe: Astrolabe) -> Int { astrolabe.palaces.count }
}
