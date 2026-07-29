private func invalidModelData(_ decoder: Decoder, _ description: String) -> DecodingError {
  .dataCorrupted(
    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: description))
}

private func containsEveryPalaceID(_ values: [PalaceID]) -> Bool {
  values.count == PalaceID.allCases.count && Set(values) == Set(PalaceID.allCases)
}

extension ZiweiConfiguration {
  enum CodingKeys: String, CodingKey {
    case mutagens, brightness, yearDivide, horoscopeDivide, ageDivide, dayDivide, algorithm
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.init(
      mutagens: try values.decode([HeavenlyStem: [StarID]].self, forKey: .mutagens),
      brightness: try values.decode([StarID: [Brightness?]].self, forKey: .brightness),
      yearDivide: try values.decode(DivideMode.self, forKey: .yearDivide),
      horoscopeDivide: try values.decode(DivideMode.self, forKey: .horoscopeDivide),
      ageDivide: try values.decode(AgeDivideMode.self, forKey: .ageDivide),
      dayDivide: try values.decode(DayDivideMode.self, forKey: .dayDivide),
      algorithm: try values.decode(ZiweiAlgorithm.self, forKey: .algorithm))
    do {
      try validate()
    } catch {
      throw invalidModelData(decoder, "Invalid Ziwei configuration: \(error)")
    }
  }
}

extension Decadal {
  enum CodingKeys: String, CodingKey { case range, stem, branch }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let range = try values.decode([Int].self, forKey: .range)
    guard range.count == 2, range[0] <= range[1] else {
      throw invalidModelData(decoder, "A decadal range must contain an ordered start and end")
    }
    self.init(
      range: range,
      stem: try values.decode(HeavenlyStem.self, forKey: .stem),
      branch: try values.decode(EarthlyBranch.self, forKey: .branch))
  }
}

extension Palace {
  enum CodingKeys: String, CodingKey {
    case index, id, isBodyPalace, isOriginalPalace, stem, branch
    case majorStars, minorStars, adjectiveStars
    case changsheng12, boshi12, jiangqian12, suiqian12, decadal, ages
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let index = try values.decode(Int.self, forKey: .index)
    let ages = try values.decode([Int].self, forKey: .ages)
    guard (0..<12).contains(index) else {
      throw invalidModelData(decoder, "A palace index must be between 0 and 11")
    }
    guard ages.count == 10, Set(ages).count == ages.count, ages.allSatisfy({ $0 > 0 }) else {
      throw invalidModelData(decoder, "A palace must contain ten unique positive nominal ages")
    }
    self.init(
      index: index,
      id: try values.decode(PalaceID.self, forKey: .id),
      isBodyPalace: try values.decode(Bool.self, forKey: .isBodyPalace),
      isOriginalPalace: try values.decode(Bool.self, forKey: .isOriginalPalace),
      stem: try values.decode(HeavenlyStem.self, forKey: .stem),
      branch: try values.decode(EarthlyBranch.self, forKey: .branch),
      majorStars: try values.decode([Star].self, forKey: .majorStars),
      minorStars: try values.decode([Star].self, forKey: .minorStars),
      adjectiveStars: try values.decode([Star].self, forKey: .adjectiveStars),
      changsheng12: try values.decode(ChangshengStage.self, forKey: .changsheng12),
      boshi12: try values.decode(BoshiStage.self, forKey: .boshi12),
      jiangqian12: try values.decode(JiangqianStage.self, forKey: .jiangqian12),
      suiqian12: try values.decode(SuiqianStage.self, forKey: .suiqian12),
      decadal: try values.decode(Decadal.self, forKey: .decadal),
      ages: ages)
  }
}

extension Astrolabe {
  enum CodingKeys: String, CodingKey {
    case configuration, astrolabeType, fixLeap, gender, solarDate, lunarDate, rawChineseDate, hour
    case westernZodiac, zodiacBranch, soulPalaceBranch, bodyPalaceBranch
    case soulStarID, bodyStarID, fiveElementsClass, palaces
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let palaces = try values.decode([Palace].self, forKey: .palaces)
    let ages = palaces.flatMap(\.ages)
    let solarDate = try values.decode(SolarDate.self, forKey: .solarDate)
    guard palaces.count == 12,
      palaces.enumerated().allSatisfy({ $0.offset == $0.element.index }),
      containsEveryPalaceID(palaces.map(\.id)),
      palaces.filter(\.isBodyPalace).count == 1,
      ages.count == 120, Set(ages) == Set(1...120),
      Ziwei.supportedYearRange.contains(solarDate.year)
    else {
      throw invalidModelData(
        decoder,
        "An astrolabe must contain twelve ordered palaces, one body palace, and ages 1 through 120")
    }
    self.init(
      configuration: try values.decode(ZiweiConfiguration.self, forKey: .configuration),
      astrolabeType: try values.decode(AstrolabeType.self, forKey: .astrolabeType),
      fixLeap: try values.decode(Bool.self, forKey: .fixLeap),
      gender: try values.decode(Gender.self, forKey: .gender),
      solarDate: solarDate,
      lunarDate: try values.decode(LunarDate.self, forKey: .lunarDate),
      rawChineseDate: try values.decode(ChineseDate.self, forKey: .rawChineseDate),
      hour: try values.decode(ChineseHour.self, forKey: .hour),
      westernZodiac: try values.decode(WesternZodiac.self, forKey: .westernZodiac),
      zodiacBranch: try values.decode(EarthlyBranch.self, forKey: .zodiacBranch),
      soulPalaceBranch: try values.decode(EarthlyBranch.self, forKey: .soulPalaceBranch),
      bodyPalaceBranch: try values.decode(EarthlyBranch.self, forKey: .bodyPalaceBranch),
      soulStarID: try values.decode(StarID.self, forKey: .soulStarID),
      bodyStarID: try values.decode(StarID.self, forKey: .bodyStarID),
      fiveElementsClass: try values.decode(FiveElementsClass.self, forKey: .fiveElementsClass),
      palaces: palaces)
  }
}

extension HoroscopePeriod {
  enum CodingKeys: String, CodingKey {
    case index, kind, stem, branch, palaceIDs, mutagens, stars, yearlyDecStar
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let index = try values.decode(Int.self, forKey: .index)
    let palaceIDs = try values.decode([PalaceID].self, forKey: .palaceIDs)
    let mutagens = try values.decode([StarID].self, forKey: .mutagens)
    let stars = try values.decode([[Star]].self, forKey: .stars)
    guard (-1..<12).contains(index), containsEveryPalaceID(palaceIDs),
      mutagens.count == Mutagen.allCases.count, stars.count == 12
    else {
      throw invalidModelData(
        decoder, "A horoscope period must contain a valid index and twelve complete palace rows")
    }
    self.init(
      index: index,
      kind: try values.decode(HoroscopePeriodKind.self, forKey: .kind),
      stem: try values.decode(HeavenlyStem.self, forKey: .stem),
      branch: try values.decode(EarthlyBranch.self, forKey: .branch),
      palaceIDs: palaceIDs,
      mutagens: mutagens,
      stars: stars,
      yearlyDecStar: try values.decodeIfPresent(YearlyDecoration.self, forKey: .yearlyDecStar))
  }
}

extension AgePeriod {
  enum CodingKeys: String, CodingKey {
    case index, nominalAge, stem, branch, palaceIDs, mutagens
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let index = try values.decode(Int.self, forKey: .index)
    let palaceIDs = try values.decode([PalaceID].self, forKey: .palaceIDs)
    let mutagens = try values.decode([StarID].self, forKey: .mutagens)
    guard (-1..<12).contains(index), containsEveryPalaceID(palaceIDs),
      mutagens.count == Mutagen.allCases.count
    else {
      throw invalidModelData(decoder, "An age period must contain a valid index and palace cycle")
    }
    self.init(
      index: index,
      nominalAge: try values.decode(Int.self, forKey: .nominalAge),
      stem: try values.decode(HeavenlyStem.self, forKey: .stem),
      branch: try values.decode(EarthlyBranch.self, forKey: .branch),
      palaceIDs: palaceIDs,
      mutagens: mutagens)
  }
}

extension YearlyDecoration {
  enum CodingKeys: String, CodingKey { case jiangqian12, suiqian12 }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let jiangqian = try values.decode([JiangqianStage].self, forKey: .jiangqian12)
    let suiqian = try values.decode([SuiqianStage].self, forKey: .suiqian12)
    guard jiangqian.count == 12, suiqian.count == 12 else {
      throw invalidModelData(decoder, "Yearly decoration cycles must each contain twelve values")
    }
    self.init(jiangqian12: jiangqian, suiqian12: suiqian)
  }
}

extension Horoscope {
  enum CodingKeys: String, CodingKey {
    case solarDate, lunarDate, decadal, age, yearly, monthly, daily, hourly
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let solarDate = try values.decode(SolarDate.self, forKey: .solarDate)
    let decadal = try values.decode(HoroscopePeriod.self, forKey: .decadal)
    let yearly = try values.decode(HoroscopePeriod.self, forKey: .yearly)
    let monthly = try values.decode(HoroscopePeriod.self, forKey: .monthly)
    let daily = try values.decode(HoroscopePeriod.self, forKey: .daily)
    let hourly = try values.decode(HoroscopePeriod.self, forKey: .hourly)
    guard Ziwei.supportedYearRange.contains(solarDate.year),
      [.decadal, .childhood].contains(decadal.kind), yearly.kind == .yearly,
      monthly.kind == .monthly, daily.kind == .daily, hourly.kind == .hourly
    else {
      throw invalidModelData(decoder, "Horoscope periods do not match their declared scopes")
    }
    self.init(
      solarDate: solarDate,
      lunarDate: try values.decode(LunarDate.self, forKey: .lunarDate),
      decadal: decadal,
      age: try values.decode(AgePeriod.self, forKey: .age),
      yearly: yearly,
      monthly: monthly,
      daily: daily,
      hourly: hourly)
  }
}
