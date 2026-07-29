/// Primary entry point for chart and calendar calculations.
public enum Ziwei {
  /// Gregorian years covered by the committed parity and calendar-boundary fixtures.
  public static let supportedYearRange = 1901...2099

  /// Creates a chart from a complete set of options.
  public static func chart(options: ChartOptions) throws -> Astrolabe {
    switch options.date {
    case .solar(let date):
      return try chart(
        solarDate: date, hour: options.hour, gender: options.gender,
        fixLeap: options.fixLeap, configuration: options.configuration,
        astrolabeType: options.astrolabeType)
    case .lunar(let date):
      return try chart(
        lunarDate: date, hour: options.hour, gender: options.gender,
        fixLeap: options.fixLeap, configuration: options.configuration,
        astrolabeType: options.astrolabeType)
    }
  }

  /// Converts a validated Gregorian date to its lunar-calendar date.
  public static func lunarDate(fromSolar date: SolarDate) throws -> LunarDate {
    try validateSupportedYear(date.year)
    return try CalendarEngine.solarToLunar(date)
  }

  /// Converts a validated lunar date to its Gregorian date.
  public static func solarDate(fromLunar lunar: LunarDate) throws -> SolarDate {
    let solar: SolarDate
    do {
      solar = try CalendarEngine.lunarToSolar(lunar)
    } catch  where lunar.isLeapMonth {
      solar = try CalendarEngine.lunarToSolar(
        LunarDate(uncheckedYear: lunar.year, month: lunar.month, day: lunar.day))
    }
    try validateSupportedYear(solar.year)
    return solar
  }

  /// Calculates the four pillars for a Gregorian date and traditional hour.
  public static func chineseDate(
    forSolarDate solar: SolarDate,
    hour: ChineseHour,
    configuration: ZiweiConfiguration = .default
  ) throws -> ChineseDate {
    try validateSupportedYear(solar.year)
    try configuration.validate()
    let lunar = try CalendarEngine.solarToLunar(solar)
    let calculationHour: ChineseHour =
      configuration.dayDivide == .current && hour == .lateZi ? .earlyZi : hour
    return try CalendarEngine.chineseDate(
      solar: solar,
      lunar: lunar,
      hour: calculationHour,
      yearDivide: configuration.yearDivide,
      monthDivide: configuration.horoscopeDivide,
      dayDivide: configuration.dayDivide)
  }

  /// Calculates the five-elements class for a stem-branch pair.
  public static func fiveElementsClass(
    heavenlyStem: HeavenlyStem, earthlyBranch: EarthlyBranch
  ) -> FiveElementsClass {
    Algorithms.fiveElements(stem: heavenlyStem, branch: earthlyBranch)
  }

  /// Creates an immutable chart from a Gregorian date.
  ///
  /// - Parameters:
  ///   - solar: The validated birth date.
  ///   - hour: The traditional two-hour birth period.
  ///   - gender: The gender used by directional rules.
  ///   - fixLeap: Whether the latter half of a leap month advances the month index.
  ///   - configuration: Per-chart calculation settings.
  ///   - astrolabeType: The palace frame to construct.
  /// - Throws: ``ZiweiError`` when calendar conversion cannot represent the input.
  public static func chart(
    solarDate solar: SolarDate,
    hour: ChineseHour,
    gender: Gender,
    fixLeap: Bool = true,
    configuration: ZiweiConfiguration = .default,
    astrolabeType: AstrolabeType = .heaven
  ) throws -> Astrolabe {
    try validateSupportedYear(solar.year)
    try configuration.validate()
    let calculationHour: ChineseHour =
      configuration.dayDivide == .current && hour == .lateZi
      ? .earlyZi : hour
    let lunar = try CalendarEngine.solarToLunar(solar)
    let year = CalendarEngine.yearPillar(
      solar: solar, lunar: lunar, divide: configuration.yearDivide)
    let horoscopeYear = CalendarEngine.yearPillar(
      solar: solar, lunar: lunar, divide: configuration.horoscopeDivide)
    let chineseDate = try CalendarEngine.chineseDate(
      solar: solar, lunar: lunar, hour: calculationHour,
      yearDivide: configuration.yearDivide, monthDivide: configuration.horoscopeDivide,
      dayDivide: configuration.dayDivide)
    let soulBody = Algorithms.soulAndBody(
      lunar: lunar, hour: calculationHour, year: year, fixLeap: fixLeap)
    let five = Algorithms.fiveElements(stem: soulBody.stemOfSoul, branch: soulBody.branchOfSoul)
    let palaceIDs = Algorithms.palaceIDs(soulIndex: soulBody.soulIndex)
    let majors = try Algorithms.majorStars(
      solar: solar, lunar: lunar, hour: calculationHour, fixLeap: fixLeap,
      soulBody: soulBody, year: year, configuration: configuration)
    let minors = Algorithms.minorStars(
      lunar: lunar, hour: calculationHour, fixLeap: fixLeap, year: year,
      configuration: configuration)
    let adjectives = Algorithms.adjectiveStars(
      lunar: lunar, hour: calculationHour, fixLeap: fixLeap, gender: gender,
      year: horoscopeYear,
      soulBody: soulBody, algorithm: configuration.algorithm)
    let changsheng = Algorithms.changsheng12(five: five, gender: gender, yearBranch: year.branch)
    let boshi = Algorithms.boshi12(gender: gender, year: year)
    let yearly = Algorithms.yearly12(
      yearBranch: horoscopeYear.branch, algorithm: configuration.algorithm)
    let horoscope = Algorithms.horoscope(gender: gender, year: year, soulBody: soulBody, five: five)

    let palaces = (0..<12).map { index in
      let stem = HeavenlyStem.cyclic(
        at: soulBody.stemOfSoul.rawValue - soulBody.soulIndex + index)
      let branch = EarthlyBranch.cyclic(at: EarthlyBranch.yin.rawValue + index)
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

    let soulBranch = EarthlyBranch.cyclic(at: soulBody.soulIndex + 2)
    let bodyBranch = EarthlyBranch.cyclic(at: soulBody.bodyIndex + 2)
    let chart = Astrolabe(
      configuration: configuration,
      astrolabeType: astrolabeType,
      fixLeap: fixLeap,
      gender: gender,
      solarDate: solar,
      lunarDate: lunar,
      rawChineseDate: chineseDate,
      hour: hour,
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

  /// Creates an immutable chart from a lunar date.
  ///
  /// - Parameters:
  ///   - lunar: The validated lunar birth date.
  ///   - hour: The traditional two-hour birth period.
  ///   - gender: The gender used by directional rules.
  ///   - fixLeap: Whether the latter half of a leap month advances the month index.
  ///   - configuration: Per-chart calculation settings.
  ///   - astrolabeType: The palace frame to construct.
  /// - Throws: ``ZiweiError`` when calendar conversion cannot represent the input.
  public static func chart(
    lunarDate lunar: LunarDate,
    hour: ChineseHour,
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
      solarDate: solar, hour: hour, gender: gender, fixLeap: fixLeap,
      configuration: configuration, astrolabeType: astrolabeType)
  }

  /// Returns the zodiac branch for a Gregorian date.
  public static func zodiacBranch(
    forSolarDate solar: SolarDate, divide: DivideMode = .normal
  ) throws -> EarthlyBranch {
    try validateSupportedYear(solar.year)
    let lunar = try CalendarEngine.solarToLunar(solar)
    return CalendarEngine.yearPillar(solar: solar, lunar: lunar, divide: divide).branch
  }

  /// Returns the western zodiac sign for a Gregorian date.
  public static func westernZodiac(forSolarDate date: SolarDate) -> WesternZodiac {
    westernZodiac(month: date.month, day: date.day)
  }

  private static func westernZodiac(month: Int, day: Int) -> WesternZodiac {
    let bounds = [20, 19, 21, 20, 21, 22, 23, 23, 23, 24, 23, 22]
    let signs: [WesternZodiac] = [
      .capricorn, .aquarius, .pisces, .aries, .taurus, .gemini,
      .cancer, .leo, .virgo, .libra, .scorpio, .sagittarius, .capricorn,
    ]
    return day < bounds[month - 1] ? signs[month - 1] : signs[month]
  }

  static func validateSupportedYear(_ year: Int) throws {
    guard supportedYearRange.contains(year) else { throw ZiweiError.unsupportedYear(year) }
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

    let calculationHour: ChineseHour =
      chart.configuration.dayDivide == .current && chart.hour == .lateZi
      ? .earlyZi : chart.hour
    let year = CalendarEngine.yearPillar(
      solar: chart.solarDate, lunar: chart.lunarDate, divide: chart.configuration.yearDivide)
    let soulBody = Algorithms.soulAndBody(
      from: sourceBranch, hour: calculationHour, year: year)
    let five = Algorithms.fiveElements(stem: sourceStem, branch: sourceBranch)
    let palaceIDs = Algorithms.palaceIDs(soulIndex: soulBody.soulIndex)
    let majors = try Algorithms.majorStars(
      solar: chart.solarDate, lunar: chart.lunarDate, hour: calculationHour,
      fixLeap: chart.fixLeap, soulBody: soulBody, year: year, configuration: chart.configuration)
    let changsheng = Algorithms.changsheng12(
      five: five, gender: chart.gender, yearBranch: year.branch)
    let horoscope = Algorithms.horoscope(
      gender: chart.gender, year: year, soulBody: soulBody, five: five)

    let tiancaiIndex = positiveModulo(
      soulBody.soulIndex + chart.rawChineseDate.yearly.branch.rawValue)
    var tianshangIndex = positiveModulo(PalaceID.friends.cycleIndex + soulBody.soulIndex)
    var tianshiIndex = positiveModulo(PalaceID.health.cycleIndex + soulBody.soulIndex)
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
      hour: chart.hour,
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
