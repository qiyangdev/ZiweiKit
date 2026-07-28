import Foundation

/// Pure Swift entry point corresponding to iztro's `astro` calculation namespace.
public enum Ziwei {
  public static func chart(
    solarDate date: String, timeIndex: Int, gender: Gender, fixLeap: Bool = true,
    configuration: ZiweiConfiguration = .default,
    astrolabeType: AstrolabeType = .heaven
  ) throws -> Astrolabe {
    try chart(
      solarDate: SolarDate(date), timeIndex: timeIndex, gender: gender, fixLeap: fixLeap,
      configuration: configuration, astrolabeType: astrolabeType)
  }

  public static func chart(
    lunarDate date: String, timeIndex: Int, gender: Gender, isLeapMonth: Bool = false,
    fixLeap: Bool = true, configuration: ZiweiConfiguration = .default,
    astrolabeType: AstrolabeType = .heaven
  ) throws -> Astrolabe {
    return try chart(
      lunarDate: LunarDate(date, isLeapMonth: isLeapMonth),
      timeIndex: timeIndex, gender: gender, fixLeap: fixLeap,
      configuration: configuration, astrolabeType: astrolabeType)
  }

  public static func chart(options: ChartOptions) throws -> Astrolabe {
    switch options.date {
    case .solar(let date):
      return try chart(
        solarDate: date, timeIndex: options.timeIndex, gender: options.gender,
        fixLeap: options.fixLeap, configuration: options.configuration,
        astrolabeType: options.astrolabeType)
    case .lunar(let date):
      return try chart(
        lunarDate: date, timeIndex: options.timeIndex, gender: options.gender,
        fixLeap: options.fixLeap, configuration: options.configuration,
        astrolabeType: options.astrolabeType)
    }
  }

  public static func lunarDate(fromSolar date: SolarDate) throws -> LunarDate {
    try CalendarEngine.solarToLunar(date)
  }

  public static func lunarDate(fromSolar date: String) throws -> LunarDate {
    try lunarDate(fromSolar: SolarDate(date))
  }

  public static func solarDate(fromLunar lunar: LunarDate) throws -> SolarDate {
    do {
      return try CalendarEngine.lunarToSolar(lunar)
    } catch  where lunar.isLeapMonth {
      return try CalendarEngine.lunarToSolar(
        LunarDate(uncheckedYear: lunar.year, month: lunar.month, day: lunar.day))
    }
  }

  public static func chineseDate(
    forSolarDate solar: SolarDate,
    timeIndex: Int,
    configuration: ZiweiConfiguration = .default
  ) throws -> ChineseDate {
    guard (0...12).contains(timeIndex) else { throw ZiweiError.invalidTimeIndex(timeIndex) }
    let lunar = try CalendarEngine.solarToLunar(solar)
    let calculationTimeIndex =
      configuration.dayDivide == .current && timeIndex == 12 ? 0 : timeIndex
    return try CalendarEngine.chineseDate(
      solar: solar,
      lunar: lunar,
      timeIndex: calculationTimeIndex,
      yearDivide: configuration.yearDivide,
      monthDivide: configuration.horoscopeDivide,
      dayDivide: configuration.dayDivide)
  }

  public static func chineseDate(
    forSolarDate date: String,
    timeIndex: Int,
    configuration: ZiweiConfiguration = .default
  ) throws -> ChineseDate {
    try chineseDate(
      forSolarDate: SolarDate(date), timeIndex: timeIndex, configuration: configuration)
  }

  public static func fiveElementsClass(
    heavenlyStem: HeavenlyStem, earthlyBranch: EarthlyBranch
  ) -> FiveElementsClass {
    Algorithms.fiveElements(stem: heavenlyStem, branch: earthlyBranch)
  }

  public static func chart(
    solarDate solar: SolarDate,
    timeIndex: Int,
    gender: Gender,
    fixLeap: Bool = true,
    configuration: ZiweiConfiguration = .default,
    astrolabeType: AstrolabeType = .heaven
  ) throws -> Astrolabe {
    guard (0...12).contains(timeIndex) else { throw ZiweiError.invalidTimeIndex(timeIndex) }
    let calculationTimeIndex =
      configuration.dayDivide == .current && timeIndex == 12
      ? 0 : timeIndex
    let lunar = try CalendarEngine.solarToLunar(solar)
    let year = CalendarEngine.yearPillar(
      solar: solar, lunar: lunar, divide: configuration.yearDivide)
    let horoscopeYear = CalendarEngine.yearPillar(
      solar: solar, lunar: lunar, divide: configuration.horoscopeDivide)
    let chineseDate = try CalendarEngine.chineseDate(
      solar: solar, lunar: lunar, timeIndex: calculationTimeIndex,
      yearDivide: configuration.yearDivide, monthDivide: configuration.horoscopeDivide,
      dayDivide: configuration.dayDivide)
    let soulBody = Algorithms.soulAndBody(
      lunar: lunar, timeIndex: calculationTimeIndex, year: year, fixLeap: fixLeap)
    let five = Algorithms.fiveElements(stem: soulBody.stemOfSoul, branch: soulBody.branchOfSoul)
    let palaceIDs = Algorithms.palaceIDs(soulIndex: soulBody.soulIndex)
    let majors = try Algorithms.majorStars(
      solar: solar, lunar: lunar, timeIndex: calculationTimeIndex, fixLeap: fixLeap,
      soulBody: soulBody, year: year, configuration: configuration)
    let minors = Algorithms.minorStars(
      lunar: lunar, timeIndex: calculationTimeIndex, fixLeap: fixLeap, year: year,
      configuration: configuration)
    let adjectives = Algorithms.adjectiveStars(
      lunar: lunar, timeIndex: calculationTimeIndex, fixLeap: fixLeap, gender: gender,
      year: horoscopeYear,
      soulBody: soulBody, algorithm: configuration.algorithm)
    let changsheng = Algorithms.changsheng12(five: five, gender: gender, yearBranch: year.branch)
    let boshi = Algorithms.boshi12(gender: gender, year: year)
    let yearly = Algorithms.yearly12(
      yearBranch: horoscopeYear.branch, algorithm: configuration.algorithm)
    let horoscope = Algorithms.horoscope(gender: gender, year: year, soulBody: soulBody, five: five)

    let palaces = (0..<12).map { index in
      let stem = HeavenlyStem(
        rawValue: positiveModulo(soulBody.stemOfSoul.rawValue - soulBody.soulIndex + index, 10))!
      let branch = EarthlyBranch(rawValue: positiveModulo(EarthlyBranch.yin.rawValue + index))!
      return Palace(
        index: index,
        id: palaceIDs[index],
        isBodyPalace: soulBody.bodyIndex == index,
        isOriginalPalace: branch != .zi && branch != .chou && stem == year.stem,
        stem: stem,
        branch: branch,
        majorStars: majors[index],
        minorStars: minors[index],
        adjectiveStars: adjectives[index],
        changsheng12: changsheng[index],
        boshi12: boshi[index],
        jiangqian12: yearly.jiangqian[index],
        suiqian12: yearly.suiqian[index],
        decadal: horoscope.decadals[index],
        ages: horoscope.ages[index]
      )
    }

    let soulBranch = EarthlyBranch(rawValue: positiveModulo(soulBody.soulIndex + 2))!
    let bodyBranch = EarthlyBranch(rawValue: positiveModulo(soulBody.bodyIndex + 2))!
    let chart = Astrolabe(
      configuration: configuration,
      astrolabeType: astrolabeType,
      fixLeap: fixLeap,
      gender: gender,
      solarDate: solar,
      lunarDate: lunar,
      rawChineseDate: chineseDate,
      timeIndex: timeIndex,
      westernZodiac: westernZodiac(month: solar.month, day: solar.day),
      zodiacBranch: year.branch,
      soulPalaceBranch: soulBranch,
      bodyPalaceBranch: bodyBranch,
      soulStarID: Constants.soulStars[
        configuration.algorithm == .zhongzhou ? year.branch.rawValue : soulBranch.rawValue],
      bodyStarID: Constants.bodyStars[year.branch.rawValue],
      fiveElementsClass: five,
      palaces: palaces
    )
    return astrolabeType == .heaven ? chart : try rearrange(chart, as: astrolabeType)
  }

  public static func chart(
    lunarDate lunar: LunarDate,
    timeIndex: Int,
    gender: Gender,
    fixLeap: Bool = true,
    configuration: ZiweiConfiguration = .default,
    astrolabeType: AstrolabeType = .heaven
  ) throws -> Astrolabe {
    let solar: SolarDate
    do {
      solar = try CalendarEngine.lunarToSolar(lunar)
    } catch  where lunar.isLeapMonth {
      // iztro treats an `isLeapMonth` flag as ineffective when that lunar
      // month has no leap counterpart.
      solar = try CalendarEngine.lunarToSolar(
        LunarDate(uncheckedYear: lunar.year, month: lunar.month, day: lunar.day))
    }
    return try chart(
      solarDate: solar, timeIndex: timeIndex, gender: gender, fixLeap: fixLeap,
      configuration: configuration, astrolabeType: astrolabeType)
  }

  public static func zodiacBranch(
    forSolarDate solar: SolarDate, divide: DivideMode = .normal
  ) throws -> EarthlyBranch {
    let lunar = try CalendarEngine.solarToLunar(solar)
    return CalendarEngine.yearPillar(solar: solar, lunar: lunar, divide: divide).branch
  }

  public static func zodiacBranch(
    forSolarDate date: String, divide: DivideMode = .normal
  ) throws -> EarthlyBranch {
    try zodiacBranch(forSolarDate: SolarDate(date), divide: divide)
  }

  public static func westernZodiac(forSolarDate date: SolarDate) -> WesternZodiac {
    westernZodiac(month: date.month, day: date.day)
  }

  public static func westernZodiac(forSolarDate date: String) throws -> WesternZodiac {
    westernZodiac(forSolarDate: try SolarDate(date))
  }

  /// Converts a wall-clock hour to iztro's 0...12 time index.
  public static func timeIndex(forHour hour: Int) -> Int {
    if hour == 0 { return 0 }
    if hour == 23 { return 12 }
    return max(0, min(11, (hour + 1) / 2))
  }

  private static func westernZodiac(month: Int, day: Int) -> WesternZodiac {
    let bounds = [20, 19, 21, 20, 21, 22, 23, 23, 23, 24, 23, 22]
    let signs: [WesternZodiac] = [
      .capricorn, .aquarius, .pisces, .aries, .taurus, .gemini,
      .cancer, .leo, .virgo, .libra, .scorpio, .sagittarius, .capricorn,
    ]
    return day < bounds[month - 1] ? signs[month - 1] : signs[month]
  }

  private static func rearrange(_ chart: Astrolabe, as type: AstrolabeType) throws -> Astrolabe {
    let sourcePalace: Palace?
    switch type {
    case .heaven:
      return chart
    case .earth:
      sourcePalace = chart.bodyPalace
    case .human:
      sourcePalace = chart.palace(.fortune)
    }
    guard let sourcePalace else { throw ZiweiError.invalidDate(chart.solarDate.description) }
    let sourceStem = sourcePalace.stem
    let sourceBranch = sourcePalace.branch

    let calculationTimeIndex =
      chart.configuration.dayDivide == .current && chart.timeIndex == 12
      ? 0 : chart.timeIndex
    let year = CalendarEngine.yearPillar(
      solar: chart.solarDate, lunar: chart.lunarDate, divide: chart.configuration.yearDivide)
    let soulBody = Algorithms.soulAndBody(
      from: sourceBranch, timeIndex: calculationTimeIndex, year: year)
    let five = Algorithms.fiveElements(stem: sourceStem, branch: sourceBranch)
    let palaceIDs = Algorithms.palaceIDs(soulIndex: soulBody.soulIndex)
    let majors = try Algorithms.majorStars(
      solar: chart.solarDate, lunar: chart.lunarDate, timeIndex: calculationTimeIndex,
      fixLeap: chart.fixLeap, soulBody: soulBody, year: year, configuration: chart.configuration)
    let changsheng = Algorithms.changsheng12(
      five: five, gender: chart.gender, yearBranch: year.branch)
    let horoscope = Algorithms.horoscope(
      gender: chart.gender, year: year, soulBody: soulBody, five: five)

    let tiancaiIndex = positiveModulo(
      soulBody.soulIndex + chart.rawChineseDate.yearly.branch.rawValue)
    var tianshangIndex = positiveModulo(
      Constants.palaceIDs.firstIndex(of: .friends)! + soulBody.soulIndex)
    var tianshiIndex = positiveModulo(
      Constants.palaceIDs.firstIndex(of: .health)! + soulBody.soulIndex)
    let sameYinYang = year.branch.rawValue % 2 == (chart.gender == .male ? 0 : 1)
    if chart.configuration.algorithm == .zhongzhou && !sameYinYang {
      swap(&tianshangIndex, &tianshiIndex)
    }

    // Preserve iztro's mutation order and leave already-correct stars in place.
    let movedStars: [StarID] = [.tianshang, .tianshi, .tiancai]
    let movedTargets = [tianshangIndex, tianshiIndex, tiancaiIndex]
    let palaces = chart.palaces.map { palace in
      var adjectives = palace.adjectiveStars
      for (offset, target) in movedTargets.enumerated() where palace.index == target {
        if !adjectives.contains(where: { $0.id == movedStars[offset] }) {
          adjectives.append(Star(id: movedStars[offset], type: .adjective))
        }
      }
      for (offset, target) in movedTargets.enumerated() where palace.index != target {
        adjectives.removeAll { $0.id == movedStars[offset] }
      }
      return Palace(
        index: palace.index,
        id: palaceIDs[palace.index],
        isBodyPalace: soulBody.bodyIndex == palace.index,
        isOriginalPalace: palace.isOriginalPalace,
        stem: palace.stem,
        branch: palace.branch,
        majorStars: majors[palace.index],
        minorStars: palace.minorStars,
        adjectiveStars: adjectives,
        changsheng12: changsheng[palace.index],
        boshi12: palace.boshi12,
        jiangqian12: palace.jiangqian12,
        suiqian12: palace.suiqian12,
        decadal: horoscope.decadals[palace.index],
        ages: horoscope.ages[palace.index]
      )
    }

    return Astrolabe(
      configuration: chart.configuration,
      astrolabeType: type,
      fixLeap: chart.fixLeap,
      gender: chart.gender,
      solarDate: chart.solarDate,
      lunarDate: chart.lunarDate,
      rawChineseDate: chart.rawChineseDate,
      timeIndex: chart.timeIndex,
      westernZodiac: chart.westernZodiac,
      zodiacBranch: chart.zodiacBranch,
      soulPalaceBranch: sourceBranch,
      bodyPalaceBranch: chart.bodyPalaceBranch,
      soulStarID: chart.soulStarID,
      bodyStarID: chart.bodyStarID,
      fiveElementsClass: five,
      palaces: palaces
    )
  }
}
