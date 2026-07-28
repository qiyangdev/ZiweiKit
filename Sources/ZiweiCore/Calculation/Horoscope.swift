import Foundation

enum HoroscopeCalculator {
  static func calculate(chart: Astrolabe, target: SolarDate, timeIndex: Int) throws -> Horoscope {
    guard (0...12).contains(timeIndex) else { throw ZiweiError.invalidTimeIndex(timeIndex) }
    let configuration = chart.configuration
    let calculationTimeIndex =
      configuration.dayDivide == .current && timeIndex == 12
      ? 0 : timeIndex
    let targetLunar = try CalendarEngine.solarToLunar(target)
    let targetChinese = try CalendarEngine.chineseDate(
      solar: target, lunar: targetLunar, timeIndex: calculationTimeIndex,
      yearDivide: configuration.horoscopeDivide, monthDivide: configuration.horoscopeDivide,
      dayDivide: configuration.dayDivide)
    var nominalAge = targetLunar.year - chart.lunarDate.year
    if configuration.ageDivide == .birthday {
      if (targetLunar.year == chart.lunarDate.year
        && targetLunar.month == chart.lunarDate.month
        && targetLunar.day > chart.lunarDate.day)
        || targetLunar.month > chart.lunarDate.month
      {
        nominalAge += 1
      }
    } else {
      nominalAge += 1
    }

    var decadalIndex = -1
    var decadalPillar = StemBranch(stem: .jia, branch: .zi)
    var isChildhood = false
    if let palace = chart.palaces.first(where: { palace in
      guard palace.decadal.range.count == 2 else { return false }
      return palace.decadal.range[0]...palace.decadal.range[1] ~= nominalAge
    }) {
      decadalIndex = palace.index
      decadalPillar = StemBranch(stem: palace.decadal.stem, branch: palace.decadal.branch)
    } else if (1...6).contains(nominalAge) {
      let childhoodPalaces: [PalaceID] = [
        .life, .wealth, .health, .spouse, .fortune, .career,
      ]
      if let palace = chart.palace(childhoodPalaces[nominalAge - 1]) {
        isChildhood = true
        decadalIndex = palace.index
        decadalPillar = StemBranch(stem: palace.stem, branch: palace.branch)
      }
    }

    let agePalace = chart.palaces.first { $0.ages.contains(nominalAge) }
    let ageIndex = agePalace?.index ?? -1
    let agePillar = StemBranch(stem: agePalace?.stem ?? .jia, branch: agePalace?.branch ?? .zi)

    let yearlyIndex = Algorithms.branchToPalace(targetChinese.yearly.branch)
    let birthLeapAddition = chart.lunarDate.isLeapMonth && chart.lunarDate.day > 15 ? 1 : 0
    let targetLeapAddition = targetLunar.isLeapMonth && targetLunar.day > 15 ? 1 : 0
    let monthlyIndex = positiveModulo(
      yearlyIndex
        - (chart.lunarDate.month + birthLeapAddition)
        + chart.rawChineseDate.hourly.branch.rawValue
        + (targetLunar.month + targetLeapAddition)
    )
    let dailyIndex = positiveModulo(monthlyIndex + targetLunar.day - 1)
    let hourlyIndex = positiveModulo(dailyIndex + targetChinese.hourly.branch.rawValue)

    let yearlyDecoration = Algorithms.yearly12(
      yearBranch: targetChinese.yearly.branch, algorithm: configuration.algorithm)
    return Horoscope(
      solarDate: target,
      lunarDate: targetLunar,
      decadal: period(
        index: decadalIndex, kind: isChildhood ? .childhood : .decadal, pillar: decadalPillar,
        scope: .decadal, configuration: configuration
      ),
      age: AgePeriod(
        index: ageIndex,
        nominalAge: nominalAge,
        stem: agePillar.stem,
        branch: agePillar.branch,
        palaceIDs: Algorithms.palaceIDs(soulIndex: ageIndex),
        mutagens: mutagens(for: agePillar.stem, configuration: configuration)
      ),
      yearly: period(
        index: yearlyIndex, kind: .yearly, pillar: targetChinese.yearly, scope: .yearly,
        configuration: configuration,
        yearlyDecStar: YearlyDecoration(
          jiangqian12: yearlyDecoration.jiangqian,
          suiqian12: yearlyDecoration.suiqian)),
      monthly: period(
        index: monthlyIndex, kind: .monthly, pillar: targetChinese.monthly, scope: .monthly,
        configuration: configuration),
      daily: period(
        index: dailyIndex, kind: .daily, pillar: targetChinese.daily, scope: .daily,
        configuration: configuration),
      hourly: period(
        index: hourlyIndex, kind: .hourly, pillar: targetChinese.hourly, scope: .hourly,
        configuration: configuration)
    )
  }

  private static func period(
    index: Int, kind: HoroscopePeriodKind, pillar: StemBranch, scope: HoroscopeScope,
    configuration: ZiweiConfiguration,
    yearlyDecStar: YearlyDecoration? = nil
  )
    -> HoroscopePeriod
  {
    HoroscopePeriod(
      index: index,
      kind: kind,
      stem: pillar.stem,
      branch: pillar.branch,
      palaceIDs: Algorithms.palaceIDs(soulIndex: index),
      mutagens: mutagens(for: pillar.stem, configuration: configuration),
      stars: horoscopeStars(pillar: pillar, scope: scope),
      yearlyDecStar: yearlyDecStar
    )
  }

  private static func mutagens(
    for stem: HeavenlyStem, configuration: ZiweiConfiguration
  ) -> [StarID] {
    configuration.mutagenStars(for: stem)
  }

  private static func horoscopeStars(pillar: StemBranch, scope: HoroscopeScope) -> [[Star]] {
    var result = Array(repeating: [Star](), count: 12)
    let labels: [StarID]
    switch scope {
    case .origin: labels = []
    case .decadal:
      labels = [
        .yunKui, .yunYue, .yunChang, .yunQu, .yunLu, .yunYang, .yunTuo, .yunMa, .yunLuan, .yunXi,
      ]
    case .yearly:
      labels = [
        .liuKui, .liuYue, .liuChang, .liuQu, .liuLu, .liuYang, .liuTuo, .liuMa, .liuLuan, .liuXi,
      ]
    case .monthly:
      labels = [
        .yueKui, .yueYue, .yueChang, .yueQu, .yueLu, .yueYang, .yueTuo, .yueMa, .yueLuan, .yueXi,
      ]
    case .daily:
      labels = [.riKui, .riYue, .riChang, .riQu, .riLu, .riYang, .riTuo, .riMa, .riLuan, .riXi]
    case .hourly:
      labels = [
        .shiKui, .shiYue, .shiChang, .shiQu, .shiLu, .shiYang, .shiTuo, .shiMa, .shiLuan, .shiXi,
      ]
    }
    let starScope = scope

    if scope == .yearly {
      let branches: [EarthlyBranch] = [
        .xu, .you, .shen, .wei, .wu, .si, .chen, .mao, .yin, .chou, .zi, .hai,
      ]
      result[Algorithms.branchToPalace(branches[pillar.branch.rawValue])].append(
        Star(id: .nianjie, type: .helper, scope: starScope)
      )
    }

    let (kui, yue): (EarthlyBranch, EarthlyBranch) =
      switch pillar.stem {
      case .jia, .wu, .geng: (.chou, .wei)
      case .yi, .ji: (.zi, .shen)
      case .xin: (.wu, .yin)
      case .bing, .ding: (.hai, .you)
      case .ren, .gui: (.mao, .si)
      }
    let changQu = changQu(stem: pillar.stem)
    let lu = Algorithms.luYangTuoMa(year: pillar)
    let hongluan = positiveModulo(Algorithms.branchToPalace(.mao) - pillar.branch.rawValue)
    let indices = [
      Algorithms.branchToPalace(kui), Algorithms.branchToPalace(yue), changQu.0, changQu.1, lu.lu,
      lu.yang, lu.tuo, lu.ma, hongluan, positiveModulo(hongluan + 6),
    ]
    let types: [StarType] = [
      .soft, .soft, .soft, .soft, .lucun, .tough, .tough, .tianma, .flower, .flower,
    ]
    for position in labels.indices {
      result[indices[position]].append(
        Star(id: labels[position], type: types[position], scope: starScope))
    }
    return result
  }

  private static func changQu(stem: HeavenlyStem) -> (Int, Int) {
    let branches: [(EarthlyBranch, EarthlyBranch)] = [
      (.si, .you), (.wu, .shen), (.shen, .wu), (.you, .si), (.shen, .wu),
      (.you, .si), (.hai, .mao), (.zi, .yin), (.yin, .zi), (.mao, .hai),
    ]
    return (
      Algorithms.branchToPalace(branches[stem.rawValue].0),
      Algorithms.branchToPalace(branches[stem.rawValue].1)
    )
  }
}
