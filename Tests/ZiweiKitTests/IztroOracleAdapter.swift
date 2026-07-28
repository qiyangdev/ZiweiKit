import ZiweiKit

extension Gender {
  init?(iztroName: String) {
    switch iztroName {
    case "男": self = .male
    case "女": self = .female
    default: return nil
    }
  }

  var iztroName: String { self == .male ? "男" : "女" }
}

extension HeavenlyStem {
  init?(iztroName: String) {
    guard let value = Self.allCases.first(where: { $0.iztroName == iztroName }) else { return nil }
    self = value
  }

  var iztroName: String { ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"][rawValue] }
}

extension EarthlyBranch {
  init?(iztroName: String) {
    guard let value = Self.allCases.first(where: { $0.iztroName == iztroName }) else { return nil }
    self = value
  }

  var iztroName: String { ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"][rawValue] }
  var iztroZodiac: String {
    ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"][rawValue]
  }
}

extension StemBranch {
  var iztroDescription: String { stem.iztroName + branch.iztroName }
}

extension PalaceID {
  init?(iztroName: String) {
    guard let value = Self.allCases.first(where: { $0.iztroName == iztroName }) else { return nil }
    self = value
  }

  var iztroName: String {
    switch self {
    case .life: "命宫"
    case .parents: "父母"
    case .fortune: "福德"
    case .property: "田宅"
    case .career: "官禄"
    case .friends: "仆役"
    case .travel: "迁移"
    case .health: "疾厄"
    case .wealth: "财帛"
    case .children: "子女"
    case .spouse: "夫妻"
    case .siblings: "兄弟"
    }
  }
}

extension Mutagen {
  init?(iztroName: String) {
    guard let value = Self.allCases.first(where: { $0.iztroName == iztroName }) else { return nil }
    self = value
  }

  var iztroName: String {
    switch self {
    case .prosperity: "禄"
    case .power: "权"
    case .reputation: "科"
    case .obstacle: "忌"
    }
  }
}

extension Brightness {
  init?(iztroName: String) {
    guard let value = Self.allCases.first(where: { $0.iztroName == iztroName }) else { return nil }
    self = value
  }

  var iztroName: String {
    switch self {
    case .temple: "庙"
    case .prosperous: "旺"
    case .good: "得"
    case .advantageous: "利"
    case .neutral: "平"
    case .dim: "不"
    case .fallen: "陷"
    }
  }
}

extension StarID {
  init?(iztroName: String) {
    guard let value = Self.allCases.first(where: { $0.iztroName == iztroName }) else { return nil }
    self = value
  }

  var iztroName: String { Self.iztroNames[self]! }

  private static let iztroNames: [Self: String] = [
    .ziwei: "紫微", .tianji: "天机", .taiyang: "太阳", .wuqu: "武曲", .tiantong: "天同", .lianzhen: "廉贞",
    .tianfu: "天府", .taiyin: "太阴", .tanlang: "贪狼", .jumen: "巨门", .tianxiang: "天相", .tianliang: "天梁",
    .qisha: "七杀", .pojun: "破军",
    .zuofu: "左辅", .youbi: "右弼", .wenchang: "文昌", .wenqu: "文曲", .tiankui: "天魁", .tianyue: "天钺",
    .lucun: "禄存", .tianma: "天马",
    .dikong: "地空", .dijie: "地劫", .huoxing: "火星", .lingxing: "铃星", .qingyang: "擎羊", .tuoluo: "陀罗",
    .hongluan: "红鸾", .tianxi: "天喜", .jieshen: "解神", .tianyao: "天姚", .tianxing: "天刑", .yinsha: "阴煞",
    .tianyueAdj: "天月",
    .tianwu: "天巫", .santai: "三台", .bazuo: "八座", .enguang: "恩光", .tiangui: "天贵", .taifu: "台辅",
    .fenggao: "封诰",
    .huagai: "华盖", .xianchi: "咸池", .guchen: "孤辰", .guasu: "寡宿", .tiancai: "天才", .tianshou: "天寿",
    .tianchu: "天厨",
    .posui: "破碎", .feilian: "蜚廉", .longchi: "龙池", .fengge: "凤阁", .tianku: "天哭", .tianxu: "天虚",
    .tianguan: "天官",
    .tianfuAdj: "天福", .tiande: "天德", .yuede: "月德", .tiankong: "天空", .jielu: "截路", .kongwang: "空亡",
    .longde: "龙德",
    .jiekong: "截空", .jiesha: "劫杀", .dahao: "大耗", .xunkong: "旬空", .nianjie: "年解", .tianshang: "天伤",
    .tianshi: "天使",
    .yunKui: "运魁", .yunYue: "运钺", .yunChang: "运昌", .yunQu: "运曲", .yunLu: "运禄", .yunYang: "运羊",
    .yunTuo: "运陀", .yunMa: "运马", .yunLuan: "运鸾", .yunXi: "运喜",
    .liuKui: "流魁", .liuYue: "流钺", .liuChang: "流昌", .liuQu: "流曲", .liuLu: "流禄", .liuYang: "流羊",
    .liuTuo: "流陀", .liuMa: "流马", .liuLuan: "流鸾", .liuXi: "流喜",
    .yueKui: "月魁", .yueYue: "月钺", .yueChang: "月昌", .yueQu: "月曲", .yueLu: "月禄", .yueYang: "月羊",
    .yueTuo: "月陀", .yueMa: "月马", .yueLuan: "月鸾", .yueXi: "月喜",
    .riKui: "日魁", .riYue: "日钺", .riChang: "日昌", .riQu: "日曲", .riLu: "日禄", .riYang: "日羊",
    .riTuo: "日陀", .riMa: "日马", .riLuan: "日鸾", .riXi: "日喜",
    .shiKui: "时魁", .shiYue: "时钺", .shiChang: "时昌", .shiQu: "时曲", .shiLu: "时禄", .shiYang: "时羊",
    .shiTuo: "时陀", .shiMa: "时马", .shiLuan: "时鸾", .shiXi: "时喜",
  ]
}

extension FiveElementsClass {
  var iztroName: String {
    switch self {
    case .water: "水二局"
    case .wood: "木三局"
    case .metal: "金四局"
    case .earth: "土五局"
    case .fire: "火六局"
    }
  }
}

extension WesternZodiac {
  var iztroName: String {
    switch self {
    case .capricorn: "摩羯座"
    case .aquarius: "水瓶座"
    case .pisces: "双鱼座"
    case .aries: "白羊座"
    case .taurus: "金牛座"
    case .gemini: "双子座"
    case .cancer: "巨蟹座"
    case .leo: "狮子座"
    case .virgo: "处女座"
    case .libra: "天秤座"
    case .scorpio: "天蝎座"
    case .sagittarius: "射手座"
    }
  }
}

extension ChangshengStage {
  var iztroName: String {
    ["长生", "沐浴", "冠带", "临官", "帝旺", "衰", "病", "死", "墓", "绝", "胎", "养"][
      Self.allCases.firstIndex(of: self)!]
  }
}

extension BoshiStage {
  var iztroName: String {
    ["博士", "力士", "青龙", "小耗", "将军", "奏书", "飞廉", "喜神", "病符", "大耗", "伏兵", "官府"][
      Self.allCases.firstIndex(of: self)!]
  }
}

extension SuiqianStage {
  var iztroName: String {
    switch self {
    case .yearEstablishment: "岁建"
    case .obscurity: "晦气"
    case .mourningGate: "丧门"
    case .entanglement: "贯索"
    case .officialTalisman: "官符"
    case .minorLoss: "小耗"
    case .majorLoss: "大耗"
    case .yearBreaker: "岁破"
    case .dragonVirtue: "龙德"
    case .whiteTiger: "白虎"
    case .heavenlyVirtue: "天德"
    case .mourner: "吊客"
    case .illness: "病符"
    }
  }
}

extension JiangqianStage {
  var iztroName: String {
    ["将星", "攀鞍", "岁驿", "息神", "华盖", "劫煞", "灾煞", "天煞", "指背", "咸池", "月煞", "亡神"][
      Self.allCases.firstIndex(of: self)!]
  }
}

extension HoroscopePeriodKind {
  var iztroName: String {
    switch self {
    case .decadal: "大限"
    case .childhood: "童限"
    case .age: "小限"
    case .yearly: "流年"
    case .monthly: "流月"
    case .daily: "流日"
    case .hourly: "流时"
    }
  }
}

enum IztroTimeFormatter {
  static let names = [
    "早子时", "丑时", "寅时", "卯时", "辰时", "巳时", "午时",
    "未时", "申时", "酉时", "戌时", "亥时", "晚子时",
  ]

  static let ranges = [
    "00:00~01:00", "01:00~03:00", "03:00~05:00", "05:00~07:00", "07:00~09:00",
    "09:00~11:00", "11:00~13:00", "13:00~15:00", "15:00~17:00", "17:00~19:00",
    "19:00~21:00", "21:00~23:00", "23:00~00:00",
  ]
}
