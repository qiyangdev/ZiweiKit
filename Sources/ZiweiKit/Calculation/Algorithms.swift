struct SoulBody {
  let soulIndex: Int
  let bodyIndex: Int
  let stemOfSoul: HeavenlyStem
  let branchOfSoul: EarthlyBranch
}

enum Algorithms {
  static func branchToPalace(_ branch: EarthlyBranch) -> Int {
    positiveModulo(branch.rawValue - EarthlyBranch.yin.rawValue)
  }

  static func fixedLunarMonthIndex(_ lunar: LunarDate, hour: ChineseHour, fixLeap: Bool) -> Int {
    positiveModulo(
      lunar.month - 1
        + (lunar.isLeapMonth && fixLeap && lunar.day > 15 && hour != .lateZi ? 1 : 0))
  }

  static func soulAndBody(lunar: LunarDate, hour: ChineseHour, year: StemBranch, fixLeap: Bool)
    -> SoulBody
  {
    let monthIndex = fixedLunarMonthIndex(lunar, hour: hour, fixLeap: fixLeap)
    let timeBranchIndex = hour.branch.rawValue
    let soulIndex = positiveModulo(monthIndex - timeBranchIndex)
    let bodyIndex = positiveModulo(monthIndex + timeBranchIndex)
    let stem = HeavenlyStem.cyclic(
      at: Constants.tigerRule[year.stem.rawValue].rawValue + soulIndex)
    let branch = EarthlyBranch.cyclic(at: soulIndex + EarthlyBranch.yin.rawValue)
    return SoulBody(
      soulIndex: soulIndex, bodyIndex: bodyIndex, stemOfSoul: stem, branchOfSoul: branch)
  }

  static func soulAndBody(from branch: EarthlyBranch, hour: ChineseHour, year: StemBranch)
    -> SoulBody
  {
    let soulIndex = branchToPalace(branch)
    let bodyOffsets = [0, 2, 4, 6, 8, 10, 0, 2, 4, 6, 8, 10, 0]
    let bodyIndex = positiveModulo(soulIndex + bodyOffsets[hour.rawValue])
    let stem = HeavenlyStem.cyclic(
      at: Constants.tigerRule[year.stem.rawValue].rawValue + soulIndex)
    return SoulBody(
      soulIndex: soulIndex,
      bodyIndex: bodyIndex,
      stemOfSoul: stem,
      branchOfSoul: branch
    )
  }

  static func fiveElements(stem: HeavenlyStem, branch: EarthlyBranch) -> FiveElementsClass {
    let stemNumber = stem.rawValue / 2 + 1
    let branchNumber = positiveModulo(branch.rawValue, 6) / 2 + 1
    var value = stemNumber + branchNumber
    while value > 5 { value -= 5 }
    return [FiveElementsClass.wood, .metal, .water, .fire, .earth][value - 1]
  }

  static func palaceIDs(soulIndex: Int) -> [PalaceID] {
    (0..<12).map { Constants.palaceIDs[positiveModulo($0 - soulIndex)] }
  }

  static func brightness(
    _ id: StarID, at index: Int, configuration: ZiweiConfiguration
  ) -> Brightness? {
    if let values = configuration.brightness[id], !values.isEmpty {
      let palaceIndex = positiveModulo(index)
      return values.indices.contains(palaceIndex) ? values[palaceIndex] : nil
    }
    guard let values = Constants.brightness[id], !values.isEmpty else { return nil }
    return values[positiveModulo(index)]
  }

  static func mutagen(
    _ id: StarID, yearStem: HeavenlyStem, configuration: ZiweiConfiguration
  ) -> Mutagen? {
    let targets = configuration.mutagenStars(for: yearStem)
    guard let index = targets.firstIndex(of: id), Mutagen.allCases.indices.contains(index)
    else { return nil }
    return Mutagen.allCases[index]
  }

  static func star(
    _ id: StarID, type: StarType, index: Int, yearStem: HeavenlyStem,
    configuration: ZiweiConfiguration, withMutagen: Bool = true
  ) -> Star {
    return Star(
      id: id,
      type: type,
      brightness: brightness(id, at: index, configuration: configuration),
      mutagen: withMutagen
        ? mutagen(id, yearStem: yearStem, configuration: configuration) : nil
    )
  }

  static func majorStars(
    solar: SolarDate,
    lunar: LunarDate,
    hour: ChineseHour,
    fixLeap: Bool,
    soulBody: SoulBody,
    year: StemBranch,
    configuration: ZiweiConfiguration
  ) throws -> [[Star]] {
    let five = fiveElements(stem: soulBody.stemOfSoul, branch: soulBody.branchOfSoul)
    var day = lunar.day
    if hour == .lateZi { day += 1 }
    if day > (try CalendarEngine.maxDaysInLunarMonth(containing: solar)) {
      day -= try CalendarEngine.maxDaysInLunarMonth(containing: solar)
    }

    var offset = 0
    while (day + offset) % five.rawValue != 0 { offset += 1 }
    let quotient = ((day + offset) / five.rawValue) % 12
    let rawZiwei = quotient - 1 + (offset.isMultiple(of: 2) ? offset : -offset)
    let ziweiIndex = positiveModulo(rawZiwei)
    let tianfuIndex = positiveModulo(12 - ziweiIndex)

    var result = Array(repeating: [Star](), count: 12)
    let ziweiGroup: [(StarID, Int)] = [
      (.ziwei, 0), (.tianji, 1), (.taiyang, 3), (.wuqu, 4), (.tiantong, 5), (.lianzhen, 8),
    ]
    let tianfuGroup: [(StarID, Int)] = [
      (.tianfu, 0), (.taiyin, 1), (.tanlang, 2), (.jumen, 3), (.tianxiang, 4), (.tianliang, 5),
      (.qisha, 6), (.pojun, 10),
    ]
    for (id, offset) in ziweiGroup {
      let index = positiveModulo(ziweiIndex - offset)
      result[index].append(
        star(
          id, type: .major, index: index, yearStem: year.stem,
          configuration: configuration))
    }
    for (id, offset) in tianfuGroup {
      let index = positiveModulo(tianfuIndex + offset)
      result[index].append(
        star(
          id, type: .major, index: index, yearStem: year.stem,
          configuration: configuration))
    }
    return result
  }

  static func luYangTuoMa(year: StemBranch) -> (lu: Int, yang: Int, tuo: Int, ma: Int) {
    let luBranches: [EarthlyBranch] = [.yin, .mao, .si, .wu, .si, .wu, .shen, .you, .hai, .zi]
    let lu = branchToPalace(luBranches[year.stem.rawValue])
    let maBranch: EarthlyBranch
    switch year.branch {
    case .yin, .wu, .xu: maBranch = .shen
    case .shen, .zi, .chen: maBranch = .yin
    case .si, .you, .chou: maBranch = .hai
    case .hai, .mao, .wei: maBranch = .si
    }
    return (lu, positiveModulo(lu + 1), positiveModulo(lu - 1), branchToPalace(maBranch))
  }

  static func minorStars(
    lunar: LunarDate, hour: ChineseHour, fixLeap: Bool, year: StemBranch,
    configuration: ZiweiConfiguration
  )
    -> [[Star]]
  {
    var result = Array(repeating: [Star](), count: 12)
    let month = fixedLunarMonthIndex(lunar, hour: hour, fixLeap: fixLeap)
    let zuo = positiveModulo(branchToPalace(.chen) + month)
    let you = positiveModulo(branchToPalace(.xu) - month)
    let fixedTime = hour.branch.rawValue
    let chang = positiveModulo(branchToPalace(.xu) - fixedTime)
    let qu = positiveModulo(branchToPalace(.chen) + fixedTime)
    let (kui, yue): (EarthlyBranch, EarthlyBranch) =
      switch year.stem {
      case .jia, .wu, .geng: (.chou, .wei)
      case .yi, .ji: (.zi, .shen)
      case .xin: (.wu, .yin)
      case .bing, .ding: (.hai, .you)
      case .ren, .gui: (.mao, .si)
      }
    let (huoStart, lingStart): (EarthlyBranch, EarthlyBranch) =
      switch year.branch {
      case .yin, .wu, .xu: (.chou, .mao)
      case .shen, .zi, .chen: (.yin, .xu)
      case .si, .you, .chou: (.mao, .xu)
      case .hai, .wei, .mao: (.you, .xu)
      }
    let huo = positiveModulo(branchToPalace(huoStart) + fixedTime)
    let ling = positiveModulo(branchToPalace(lingStart) + fixedTime)
    let kong = positiveModulo(branchToPalace(.hai) - fixedTime)
    let jie = positiveModulo(branchToPalace(.hai) + fixedTime)
    let lu = luYangTuoMa(year: year)

    func add(_ id: StarID, _ type: StarType, _ index: Int, _ withMutagen: Bool = true) {
      result[index].append(
        star(
          id, type: type, index: index, yearStem: year.stem,
          configuration: configuration, withMutagen: withMutagen))
    }
    add(.zuofu, .soft, zuo)
    add(.youbi, .soft, you)
    add(.wenchang, .soft, chang)
    add(.wenqu, .soft, qu)
    add(.tiankui, .soft, branchToPalace(kui), false)
    add(.tianyue, .soft, branchToPalace(yue), false)
    add(.lucun, .lucun, lu.lu, false)
    add(.tianma, .tianma, lu.ma, false)
    add(.dikong, .tough, kong, false)
    add(.dijie, .tough, jie, false)
    add(.huoxing, .tough, huo, false)
    add(.lingxing, .tough, ling, false)
    add(.qingyang, .tough, lu.yang, false)
    add(.tuoluo, .tough, lu.tuo, false)
    return result
  }

  static func adjectiveStars(
    lunar: LunarDate, hour: ChineseHour, fixLeap: Bool, gender: Gender, year: StemBranch,
    soulBody: SoulBody, algorithm: ZiweiAlgorithm = .standard
  ) -> [[Star]] {
    var result = Array(repeating: [Star](), count: 12)
    let month = fixedLunarMonthIndex(lunar, hour: hour, fixLeap: fixLeap)
    let yearIndex = year.branch.rawValue
    let stemIndex = year.stem.rawValue
    let time = hour.branch.rawValue
    let zuo = positiveModulo(branchToPalace(.chen) + month)
    let you = positiveModulo(branchToPalace(.xu) - month)
    let chang = positiveModulo(branchToPalace(.xu) - time)
    let qu = positiveModulo(branchToPalace(.chen) + time)
    let dayIndex = hour == .lateZi ? lunar.day : lunar.day - 1

    func add(_ id: StarID, _ type: StarType = .adjective, _ index: Int) {
      result[positiveModulo(index)].append(Star(id: id, type: type))
    }

    let hongluan = positiveModulo(branchToPalace(.mao) - yearIndex)
    add(.hongluan, .flower, hongluan)
    add(.tianxi, .flower, hongluan + 6)
    add(.jieshen, .helper, branchToPalace([.shen, .xu, .zi, .yin, .chen, .wu][month / 2]))
    add(.tianyao, .flower, branchToPalace(.chou) + month)
    add(.tianxing, .adjective, branchToPalace(.you) + month)
    add(.yinsha, .adjective, branchToPalace([.yin, .zi, .xu, .shen, .wu, .chen][month % 6]))
    add(
      .tianyueAdj, .adjective,
      branchToPalace([.xu, .si, .chen, .yin, .wei, .mao, .hai, .wei, .yin, .wu, .xu, .yin][month]))
    add(.tianwu, .adjective, branchToPalace([.si, .shen, .yin, .hai][month % 4]))
    add(.santai, .adjective, zuo + dayIndex)
    add(.bazuo, .adjective, you - dayIndex)
    add(.enguang, .adjective, chang + dayIndex - 1)
    add(.tiangui, .adjective, qu + dayIndex - 1)
    add(.taifu, .adjective, branchToPalace(.wu) + time)
    add(.fenggao, .adjective, branchToPalace(.yin) + time)

    let (huagai, xianchi): (EarthlyBranch, EarthlyBranch) =
      switch year.branch {
      case .yin, .wu, .xu: (.xu, .mao)
      case .shen, .zi, .chen: (.chen, .you)
      case .si, .you, .chou: (.chou, .wu)
      case .hai, .wei, .mao: (.wei, .zi)
      }
    add(.huagai, .adjective, branchToPalace(huagai))
    add(.xianchi, .flower, branchToPalace(xianchi))

    let (guchen, guasu): (EarthlyBranch, EarthlyBranch) =
      switch year.branch {
      case .yin, .mao, .chen: (.si, .chou)
      case .si, .wu, .wei: (.shen, .chen)
      case .shen, .you, .xu: (.hai, .wei)
      case .hai, .zi, .chou: (.yin, .xu)
      }
    add(.guchen, .adjective, branchToPalace(guchen))
    add(.guasu, .adjective, branchToPalace(guasu))

    add(.tiancai, .adjective, soulBody.soulIndex + yearIndex)
    add(.tianshou, .adjective, soulBody.bodyIndex + yearIndex)
    let tianchu: [EarthlyBranch] = [.si, .wu, .zi, .si, .wu, .shen, .yin, .wu, .you, .hai]
    add(.tianchu, .adjective, branchToPalace(tianchu[stemIndex]))
    add(.posui, .adjective, branchToPalace([.si, .chou, .you][yearIndex % 3]))
    let feilian: [EarthlyBranch] = [
      .shen, .you, .xu, .si, .wu, .wei, .yin, .mao, .chen, .hai, .zi, .chou,
    ]
    add(.feilian, .adjective, branchToPalace(feilian[yearIndex]))
    add(.longchi, .adjective, branchToPalace(.chen) + yearIndex)
    add(.fengge, .adjective, branchToPalace(.xu) - yearIndex)
    add(.tianku, .adjective, branchToPalace(.wu) - yearIndex)
    add(.tianxu, .adjective, branchToPalace(.wu) + yearIndex)
    let tianguan: [EarthlyBranch] = [.wei, .chen, .si, .yin, .mao, .you, .hai, .you, .xu, .wu]
    let tianfu: [EarthlyBranch] = [.you, .shen, .zi, .hai, .mao, .yin, .wu, .si, .wu, .si]
    add(.tianguan, .adjective, branchToPalace(tianguan[stemIndex]))
    add(.tianfuAdj, .adjective, branchToPalace(tianfu[stemIndex]))
    add(.tiande, .adjective, branchToPalace(.you) + yearIndex)
    add(.yuede, .adjective, branchToPalace(.si) + yearIndex)
    add(.tiankong, .adjective, branchToPalace(year.branch) + 1)
    let jieluIndex = branchToPalace([.shen, .wu, .chen, .yin, .zi][stemIndex % 5])
    let kongwangIndex = branchToPalace([.you, .wei, .si, .mao, .chou][stemIndex % 5])
    if algorithm == .standard {
      add(.jielu, .adjective, jieluIndex)
      add(.kongwang, .adjective, kongwangIndex)
    } else {
      add(.longde, .adjective, branchToPalace(year.branch) + 7)
      add(.jiekong, .adjective, yearIndex.isMultiple(of: 2) ? jieluIndex : kongwangIndex)
      let jieshaIndex: Int =
        switch year.branch {
        case .shen, .zi, .chen: 3
        case .hai, .mao, .wei: 6
        case .yin, .wu, .xu: 9
        case .si, .you, .chou: 0
        }
      add(.jiesha, .adjective, jieshaIndex)
      let dahaoBranches: [EarthlyBranch] = [
        .wei, .wu, .you, .shen, .hai, .xu, .chou, .zi, .mao, .yin, .si, .chen,
      ]
      add(.dahao, .adjective, branchToPalace(dahaoBranches[yearIndex]))
    }

    var xunkong = positiveModulo(
      branchToPalace(year.branch) + HeavenlyStem.gui.rawValue - stemIndex + 1)
    if yearIndex % 2 != xunkong % 2 { xunkong = positiveModulo(xunkong + 1) }
    add(.xunkong, .adjective, xunkong)
    add(
      .nianjie, .helper,
      branchToPalace(
        [.xu, .you, .shen, .wei, .wu, .si, .chen, .mao, .yin, .chou, .zi, .hai][yearIndex]))
    var tianshangIndex = Constants.palaceIDs.firstIndex(of: .friends)! + soulBody.soulIndex
    var tianshiIndex = Constants.palaceIDs.firstIndex(of: .health)! + soulBody.soulIndex
    let sameYinYang = year.branch.rawValue % 2 == (gender == .male ? 0 : 1)
    if algorithm == .zhongzhou && !sameYinYang {
      swap(&tianshangIndex, &tianshiIndex)
    }
    add(.tianshang, .adjective, tianshangIndex)
    add(.tianshi, .adjective, tianshiIndex)

    // Preserve iztro's insertion order. Consumers sometimes render these
    // arrays directly, so ordering is part of the compatibility surface.
    let upstreamOrder: [StarID] = [
      .hongluan, .tianxi, .tianyao, .xianchi, .jieshen, .santai, .bazuo, .enguang,
      .tiangui, .longchi, .fengge, .tiancai, .tianshou, .taifu, .fenggao, .tianwu,
      .huagai, .tianguan, .tianfuAdj, .tianchu, .tianyueAdj, .tiande, .yuede,
      .tiankong, .xunkong, .jielu, .kongwang, .longde, .jiekong, .jiesha, .dahao,
      .guchen, .guasu, .feilian, .posui, .tianxing, .yinsha, .tianku, .tianxu,
      .tianshi, .tianshang, .nianjie,
    ]
    let rank = Dictionary(uniqueKeysWithValues: upstreamOrder.enumerated().map { ($1, $0) })
    for index in result.indices {
      result[index].sort { rank[$0.id, default: .max] < rank[$1.id, default: .max] }
    }
    return result
  }

  static func changsheng12(five: FiveElementsClass, gender: Gender, yearBranch: EarthlyBranch)
    -> [ChangshengStage]
  {
    let startBranch: EarthlyBranch =
      switch five {
      case .water, .earth: .shen
      case .wood: .hai
      case .metal: .si
      case .fire: .yin
      }
    let stages = ChangshengStage.allCases
    let forward = gender.yinYang == yearBranch.yinYang
    var result = Array(repeating: ChangshengStage.birth, count: 12)
    for index in 0..<12 {
      let target = positiveModulo(branchToPalace(startBranch) + (forward ? index : -index))
      result[target] = stages[index]
    }
    return result
  }

  static func boshi12(gender: Gender, year: StemBranch) -> [BoshiStage] {
    let stages = BoshiStage.allCases
    let start = luYangTuoMa(year: year).lu
    let forward = gender.yinYang == year.branch.yinYang
    var result = Array(repeating: BoshiStage.scholar, count: 12)
    for index in 0..<12 {
      result[positiveModulo(start + (forward ? index : -index))] = stages[index]
    }
    return result
  }

  static func yearly12(
    yearBranch: EarthlyBranch, algorithm: ZiweiAlgorithm = .standard
  ) -> (suiqian: [SuiqianStage], jiangqian: [JiangqianStage]) {
    let suiqianStages: [SuiqianStage] = [
      .yearEstablishment, .obscurity, .mourningGate, .entanglement, .officialTalisman,
      .minorLoss, algorithm == .zhongzhou ? .yearBreaker : .majorLoss, .dragonVirtue,
      .whiteTiger, .heavenlyVirtue, .mourner, .illness,
    ]
    let jiangqianStages = JiangqianStage.allCases
    let jiangStart: EarthlyBranch =
      switch yearBranch {
      case .yin, .wu, .xu: .wu
      case .shen, .zi, .chen: .zi
      case .si, .you, .chou: .you
      case .hai, .mao, .wei: .mao
      }
    var suiqian = Array(repeating: SuiqianStage.yearEstablishment, count: 12)
    var jiangqian = Array(repeating: JiangqianStage.general, count: 12)
    for index in 0..<12 {
      suiqian[positiveModulo(branchToPalace(yearBranch) + index)] = suiqianStages[index]
      jiangqian[positiveModulo(branchToPalace(jiangStart) + index)] = jiangqianStages[index]
    }
    return (suiqian, jiangqian)
  }

  static func horoscope(
    gender: Gender, year: StemBranch, soulBody: SoulBody, five: FiveElementsClass
  ) -> (decadals: [Decadal], ages: [[Int]]) {
    let forward = gender.yinYang == year.branch.yinYang
    var decadals = Array(
      repeating: Decadal(range: [], stem: .jia, branch: .zi), count: 12)
    let startStem = Constants.tigerRule[year.stem.rawValue]
    for index in 0..<12 {
      let palaceIndex = positiveModulo(soulBody.soulIndex + (forward ? index : -index))
      let start = five.rawValue + 10 * index
      let stem = HeavenlyStem.cyclic(at: startStem.rawValue + palaceIndex)
      let branch = EarthlyBranch.cyclic(at: EarthlyBranch.yin.rawValue + palaceIndex)
      decadals[palaceIndex] = Decadal(
        range: [start, start + 9], stem: stem, branch: branch)
    }

    let ageStartBranch: EarthlyBranch =
      switch year.branch {
      case .yin, .wu, .xu: .chen
      case .shen, .zi, .chen: .xu
      case .si, .you, .chou: .wei
      case .hai, .mao, .wei: .chou
      }
    var ages = Array(repeating: [Int](), count: 12)
    for index in 0..<12 {
      let values = (0..<10).map { 12 * $0 + index + 1 }
      let target = positiveModulo(
        branchToPalace(ageStartBranch) + (gender == .male ? index : -index))
      ages[target] = values
    }
    return (decadals, ages)
  }
}
