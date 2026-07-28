# ZiweiKit

[English](README.md) | 简体中文

ZiweiKit 是 [iztro](https://github.com/SylarLong/iztro) 计算层的纯 Swift
移植，以 Swift Package 形式提供。运行时只依赖 Foundation，不嵌入 JavaScript，支持
iOS、macOS、tvOS、watchOS 和 visionOS。

```swift
import ZiweiKit

let birthDate = try SolarDate(year: 2000, month: 8, day: 16)
let chart = try Ziwei.chart(
  solarDate: birthDate,
  hour: .yin,
  gender: .female
)

print(chart.fiveElementsClass)  // wood
print(chart.palace(.life) as Any)
print(chart.palace(containing: .ziwei) as Any)

let horoscope = try chart.horoscope(
  at: SolarDate(year: 2026, month: 7, day: 28),
  hour: .wu
)
print(horoscope.yearly.stem)  // bing
print(horoscope.age.nominalAge)  // 27
```

也可以从农历创建：

```swift
let lunarDate = try LunarDate(year: 2000, month: 7, day: 17)
let chart = try Ziwei.chart(
  lunarDate: lunarDate,
  hour: .yin,
  gender: .female
)
```

## 文档

公共类型和计算入口提供 DocC 注释，另外包含入门、日期与时区、配置、运限和分析查询
五篇指南。可以阅读[在线文档](https://qiyangdev.github.io/ZiweiKit/documentation/ziweikit/)，
或在 Xcode 中打开仓库根目录，然后选择 **Product > Build Documentation**。

配置采用每张命盘独立的不可变值，不使用 iztro 的全局可变配置：

```swift
let chart = try Ziwei.chart(
  options: ChartOptions(
    date: .solar(try SolarDate(year: 1979, month: 8, day: 21)),
    hour: .wei,
    gender: .male,
    astrolabeType: .earth,
    configuration: ZiweiConfiguration(
      yearDivide: .exact,
      horoscopeDivide: .exact,
      ageDivide: .birthday,
      dayDivide: .current,
      algorithm: .zhongzhou
    )
  )
)
```

## SwiftUI 示例

`Examples/ZiweiKitExample` 是一个独立的 iOS 16+ SwiftUI Xcode 项目，展示固定日期
排盘、命盘摘要、十二宫列表与星曜详情。示例工程通过本地 Package Dependency 使用
仓库根目录的 `ZiweiKit`，不会向计算库添加 UI product，也不改变根包的纯 Swift
Package 结构。

直接双击 `Examples/ZiweiKitExample/ZiweiKitExample.xcodeproj`，或从命令行打开：

```sh
open Examples/ZiweiKitExample/ZiweiKitExample.xcodeproj
```

在 Xcode 中选择 `ZiweiKitExample` Scheme 和任意 iOS 16+ Simulator 后即可运行；保持
示例目录与仓库根目录的相对位置，Xcode 就能解析本地包依赖。

## 计算层覆盖

- 公历/农历互转、生肖、星座、节气精确分界四柱
- 命宫、身宫、十二宫干支、五行局
- 十四主星、十四辅星、全部杂耀、亮度与生年四化
- 长生十二神、博士十二神、岁前与将前十二神
- 大限、小限、童限、虚岁及生日分界
- 流年、流月、流日、流时、动态流耀及流年十二神
- 宫位、星曜、三方四正、飞化、自化和运限分析器
- 自定义四化、亮度、年/运限/生日/晚子时分界配置
- 通行算法与中州派算法，以及天盘、地盘、人盘重排
- `ChartOptions`、多种日期分隔符解析和强类型时辰换算

公开模型使用 `PalaceID`、`StarID`、`StarScope`、`Brightness` 和 `Mutagen`
等强类型标识，产品 target 不包含中文运行时名称或字符串查询接口。日期值在构造及
`Codable` 解码时都会校验；序列化使用稳定的英文枚举值。

原版运行时插件在 Swift 中对应 `AstrolabePlugin`、`chart.use(_:)`、
`chart.analyze(_:)` 和常规 Swift extension，不引入全局注入。名称、本地化和日期格式化属于
调用方的显示层，不参与计算结果。

## 原版基准

`Tests/ReferenceIztro` 将原版固定为 `iztro@2.5.8`（上游提交
`106d038cc5a30d6aff8fd987f7ed79090b6ad7ff`）。它生成的 JSON oracle 会提交到
`Tests/ZiweiKitTests/Fixtures`。中文 oracle 由测试 target 中的
`IztroOracleAdapter.swift` 转成强类型结果，不进入产品模块，所以普通 Swift 测试完全离线：

```sh
swift test
```

更新基准：

```sh
cd Tests/ReferenceIztro
npm ci
npm run generate
```

测试目前逐字段对照 23 张本命盘和 6 组运限，并额外对照 120 组节气边界。覆盖
1901–2099、春节与节气边界、闰月、晚子时、自定义配置、中州派天/地/人盘、
公历与农历入口，以及功能分析器。

## 时间约定

历法计算固定使用 `Asia/Shanghai`，以避免调用设备时区改变排盘。时辰使用
`ChineseHour` 强类型表示，其中 `.earlyZi` 和 `.lateZi` 分别表示早子时和晚子时；也可以
通过 `ChineseHour(clockHour:)` 将 `0...23` 的钟点转换为对应时辰。

## 上游许可

算法根据 MIT 许可的 iztro 移植；完整声明见
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
