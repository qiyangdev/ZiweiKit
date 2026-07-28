public enum PalaceID: String, Codable, CaseIterable, Sendable {
  case life  // 命宫
  case parents  // 父母
  case fortune  // 福德
  case property  // 田宅
  case career  // 官禄
  case friends  // 仆役
  case travel  // 迁移
  case health  // 疾厄
  case wealth  // 财帛
  case children  // 子女
  case spouse  // 夫妻
  case siblings  // 兄弟
}

public enum Mutagen: String, Codable, CaseIterable, Sendable {
  case prosperity  // 禄
  case power  // 权
  case reputation  // 科
  case obstacle  // 忌
}

public enum Brightness: String, Codable, CaseIterable, Sendable {
  case temple  // 庙
  case prosperous  // 旺
  case good  // 得
  case advantageous  // 利
  case neutral  // 平
  case dim  // 不
  case fallen  // 陷
}

public enum StarScope: String, Codable, CaseIterable, Sendable {
  case origin, decadal, yearly, monthly, daily, hourly
}

public enum StarID: String, Codable, CaseIterable, Sendable {
  case ziwei  // 紫微
  case tianji  // 天机
  case taiyang  // 太阳
  case wuqu  // 武曲
  case tiantong  // 天同
  case lianzhen  // 廉贞
  case tianfu  // 天府
  case taiyin  // 太阴
  case tanlang  // 贪狼
  case jumen  // 巨门
  case tianxiang  // 天相
  case tianliang  // 天梁
  case qisha  // 七杀
  case pojun  // 破军
  case zuofu  // 左辅
  case youbi  // 右弼
  case wenchang  // 文昌
  case wenqu  // 文曲
  case tiankui  // 天魁
  case tianyue  // 天钺
  case lucun  // 禄存
  case tianma  // 天马
  case dikong  // 地空
  case dijie  // 地劫
  case huoxing  // 火星
  case lingxing  // 铃星
  case qingyang  // 擎羊
  case tuoluo  // 陀罗
  case hongluan  // 红鸾
  case tianxi  // 天喜
  case jieshen  // 解神
  case tianyao  // 天姚
  case tianxing  // 天刑
  case yinsha  // 阴煞
  case tianyueAdj  // 天月
  case tianwu  // 天巫
  case santai  // 三台
  case bazuo  // 八座
  case enguang  // 恩光
  case tiangui  // 天贵
  case taifu  // 台辅
  case fenggao  // 封诰
  case huagai  // 华盖
  case xianchi  // 咸池
  case guchen  // 孤辰
  case guasu  // 寡宿
  case tiancai  // 天才
  case tianshou  // 天寿
  case tianchu  // 天厨
  case posui  // 破碎
  case feilian  // 蜚廉
  case longchi  // 龙池
  case fengge  // 凤阁
  case tianku  // 天哭
  case tianxu  // 天虚
  case tianguan  // 天官
  case tianfuAdj  // 天福
  case tiande  // 天德
  case yuede  // 月德
  case tiankong  // 天空
  case jielu  // 截路
  case kongwang  // 空亡
  case longde  // 龙德
  case jiekong  // 截空
  case jiesha  // 劫杀
  case dahao  // 大耗
  case xunkong  // 旬空
  case nianjie  // 年解
  case tianshang  // 天伤
  case tianshi  // 天使
  // 运魁、运钺、运昌、运曲、运禄、运羊、运陀、运马、运鸾、运喜
  case yunKui, yunYue, yunChang, yunQu, yunLu, yunYang, yunTuo, yunMa, yunLuan, yunXi
  // 流魁、流钺、流昌、流曲、流禄、流羊、流陀、流马、流鸾、流喜
  case liuKui, liuYue, liuChang, liuQu, liuLu, liuYang, liuTuo, liuMa, liuLuan, liuXi
  // 月魁、月钺、月昌、月曲、月禄、月羊、月陀、月马、月鸾、月喜
  case yueKui, yueYue, yueChang, yueQu, yueLu, yueYang, yueTuo, yueMa, yueLuan, yueXi
  // 日魁、日钺、日昌、日曲、日禄、日羊、日陀、日马、日鸾、日喜
  case riKui, riYue, riChang, riQu, riLu, riYang, riTuo, riMa, riLuan, riXi
  // 时魁、时钺、时昌、时曲、时禄、时羊、时陀、时马、时鸾、时喜
  case shiKui, shiYue, shiChang, shiQu, shiLu, shiYang, shiTuo, shiMa, shiLuan, shiXi
}

public enum ChangshengStage: String, Codable, CaseIterable, Sendable {
  case birth  // 长生
  case bathing  // 沐浴
  case crowning  // 冠带
  case office  // 临官
  case peak  // 帝旺
  case decline  // 衰
  case sickness  // 病
  case death  // 死
  case tomb  // 墓
  case extinction  // 绝
  case conception  // 胎
  case nurture  // 养
}

public enum BoshiStage: String, Codable, CaseIterable, Sendable {
  case scholar  // 博士
  case strength  // 力士
  case azureDragon  // 青龙
  case minorLoss  // 小耗
  case general  // 将军
  case memorial  // 奏书
  case flyingIntegrity  // 飞廉
  case joy  // 喜神
  case illness  // 病符
  case majorLoss  // 大耗
  case ambush  // 伏兵
  case office  // 官府
}

public enum SuiqianStage: String, Codable, CaseIterable, Sendable {
  case yearEstablishment  // 岁建
  case obscurity  // 晦气
  case mourningGate  // 丧门
  case entanglement  // 贯索
  case officialTalisman  // 官符
  case minorLoss  // 小耗
  case majorLoss  // 大耗
  case yearBreaker  // 岁破
  case dragonVirtue  // 龙德
  case whiteTiger  // 白虎
  case heavenlyVirtue  // 天德
  case mourner  // 吊客
  case illness  // 病符
}

public enum JiangqianStage: String, Codable, CaseIterable, Sendable {
  case general  // 将星
  case saddle  // 攀鞍
  case travelingHorse  // 岁驿
  case rest  // 息神
  case canopy  // 华盖
  case robbery  // 劫煞
  case disaster  // 灾煞
  case heavenlyCalamity  // 天煞
  case backPointing  // 指背
  case peachBlossom  // 咸池
  case monthlyCalamity  // 月煞
  case lostSpirit  // 亡神
}

public enum HoroscopePeriodKind: String, Codable, Sendable {
  case decadal  // 大限
  case childhood  // 童限
  case age  // 小限
  case yearly  // 流年
  case monthly  // 流月
  case daily  // 流日
  case hourly  // 流时
}

public enum WesternZodiac: String, Codable, CaseIterable, Sendable {
  case capricorn  // 摩羯座
  case aquarius  // 水瓶座
  case pisces  // 双鱼座
  case aries  // 白羊座
  case taurus  // 金牛座
  case gemini  // 双子座
  case cancer  // 巨蟹座
  case leo  // 狮子座
  case virgo  // 处女座
  case libra  // 天秤座
  case scorpio  // 天蝎座
  case sagittarius  // 射手座
}
