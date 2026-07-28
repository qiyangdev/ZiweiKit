enum Constants {
  static let palaceIDs = PalaceID.allCases

  static let tigerRule: [HeavenlyStem] = [
    .bing, .wu, .geng, .ren, .jia, .bing, .wu, .geng, .ren, .jia,
  ]

  static let soulStars: [StarID] = [
    .tanlang, .jumen, .lucun, .wenqu, .lianzhen, .wuqu,
    .pojun, .wuqu, .lianzhen, .wenqu, .lucun, .jumen,
  ]

  static let bodyStars: [StarID] = [
    .huoxing, .tianxiang, .tianliang, .tiantong, .wenchang, .tianji,
    .huoxing, .tianxiang, .tianliang, .tiantong, .wenchang, .tianji,
  ]

  static let mutagens: [[StarID]] = [
    [.lianzhen, .pojun, .wuqu, .taiyang],
    [.tianji, .tianliang, .ziwei, .taiyin],
    [.tiantong, .tianji, .wenchang, .lianzhen],
    [.taiyin, .tiantong, .tianji, .jumen],
    [.tanlang, .taiyin, .youbi, .tianji],
    [.wuqu, .tanlang, .tianliang, .wenqu],
    [.taiyang, .wuqu, .taiyin, .tiantong],
    [.jumen, .taiyang, .wenqu, .wenchang],
    [.tianliang, .ziwei, .zuofu, .wuqu],
    [.pojun, .jumen, .taiyin, .tanlang],
  ]

  static let brightness: [StarID: [Brightness?]] = [
    .ziwei: [
      .prosperous, .prosperous, .good, .prosperous, .temple, .temple, .prosperous, .prosperous,
      .good, .prosperous, .neutral, .temple,
    ],
    .tianji: [
      .good, .prosperous, .advantageous, .neutral, .temple, .fallen, .good, .prosperous,
      .advantageous, .neutral, .temple, .fallen,
    ],
    .taiyang: [
      .prosperous, .temple, .prosperous, .prosperous, .prosperous, .good, .good, .fallen, .dim,
      .fallen, .fallen, .dim,
    ],
    .wuqu: [
      .good, .advantageous, .temple, .neutral, .prosperous, .temple, .good, .advantageous, .temple,
      .neutral, .prosperous, .temple,
    ],
    .tiantong: [
      .advantageous, .neutral, .neutral, .temple, .fallen, .dim, .prosperous, .neutral, .neutral,
      .temple, .prosperous, .dim,
    ],
    .lianzhen: [
      .temple, .neutral, .advantageous, .fallen, .neutral, .advantageous, .temple, .neutral,
      .advantageous, .fallen, .neutral, .advantageous,
    ],
    .tianfu: [
      .temple, .good, .temple, .good, .prosperous, .temple, .good, .prosperous, .temple, .good,
      .temple, .temple,
    ],
    .taiyin: [
      .prosperous, .fallen, .fallen, .fallen, .dim, .dim, .advantageous, .dim, .prosperous, .temple,
      .temple, .temple,
    ],
    .tanlang: [
      .neutral, .advantageous, .temple, .fallen, .prosperous, .temple, .neutral, .advantageous,
      .temple, .fallen, .prosperous, .temple,
    ],
    .jumen: [
      .temple, .temple, .fallen, .prosperous, .prosperous, .dim, .temple, .temple, .fallen,
      .prosperous, .prosperous, .dim,
    ],
    .tianxiang: [
      .temple, .fallen, .good, .good, .temple, .good, .temple, .fallen, .good, .good, .temple,
      .temple,
    ],
    .tianliang: [
      .temple, .temple, .temple, .fallen, .temple, .prosperous, .fallen, .good, .temple, .fallen,
      .temple, .prosperous,
    ],
    .qisha: [
      .temple, .prosperous, .temple, .neutral, .prosperous, .temple, .temple, .temple, .temple,
      .neutral, .prosperous, .temple,
    ],
    .pojun: [
      .good, .fallen, .prosperous, .neutral, .temple, .prosperous, .good, .fallen, .prosperous,
      .neutral, .temple, .prosperous,
    ],
    .wenchang: [
      .fallen, .advantageous, .good, .temple, .fallen, .advantageous, .good, .temple, .fallen,
      .advantageous, .good, .temple,
    ],
    .wenqu: [
      .neutral, .prosperous, .good, .temple, .fallen, .prosperous, .good, .temple, .fallen,
      .prosperous, .good, .temple,
    ],
    .huoxing: [
      .temple, .advantageous, .fallen, .good, .temple, .advantageous, .fallen, .good, .temple,
      .advantageous, .fallen, .good,
    ],
    .lingxing: [
      .temple, .advantageous, .fallen, .good, .temple, .advantageous, .fallen, .good, .temple,
      .advantageous, .fallen, .good,
    ],
    .qingyang: [
      nil, .fallen, .temple, nil, .fallen, .temple, nil, .fallen, .temple, nil, .fallen, .temple,
    ],
    .tuoluo: [
      .fallen, nil, .temple, .fallen, nil, .temple, .fallen, nil, .temple, .fallen, nil, .temple,
    ],
  ]
}
