import Foundation
import ZiweiKit

let localizedListSeparator = localized("List separator", fallback: ", ")
let localizedYes = localized("Yes", fallback: "Yes")
let localizedNo = localized("No", fallback: "No")

extension Gender {
  var localizedName: String {
    localized("gender.\(rawValue)", fallback: rawValue.humanized)
  }
}

extension FiveElementsClass {
  var localizedName: String {
    let identifier: String
    switch self {
    case .water: identifier = "water"
    case .wood: identifier = "wood"
    case .metal: identifier = "metal"
    case .earth: identifier = "earth"
    case .fire: identifier = "fire"
    }
    return localized("fiveElementsClass.\(identifier)", fallback: identifier.humanized)
  }
}

extension WesternZodiac {
  var localizedName: String {
    localized("westernZodiac.\(rawValue)", fallback: rawValue.humanized)
  }
}

extension PalaceID {
  var localizedName: String {
    localized("palace.\(rawValue)", fallback: rawValue.humanized)
  }
}

extension StarID {
  var localizedName: String {
    localized("star.\(rawValue)", fallback: rawValue.humanized)
  }
}

extension StarType {
  var localizedName: String {
    localized("starType.\(rawValue)", fallback: rawValue.humanized)
  }
}

extension HeavenlyStem {
  var localizedName: String {
    let identifiers = ["jia", "yi", "bing", "ding", "wu", "ji", "geng", "xin", "ren", "gui"]
    let identifier = identifiers[rawValue]
    return localized("heavenlyStem.\(identifier)", fallback: identifier.humanized)
  }
}

extension EarthlyBranch {
  var localizedName: String {
    let identifiers = [
      "zi", "chou", "yin", "mao", "chen", "si", "wu", "wei", "shen", "you", "xu", "hai",
    ]
    let identifier = identifiers[rawValue]
    return localized("earthlyBranch.\(identifier)", fallback: identifier.humanized)
  }
}

private func localized(_ key: String, fallback: String) -> String {
  Bundle.main.localizedString(forKey: key, value: fallback, table: nil)
}

private extension String {
  var humanized: String {
    guard let first else { return self }
    let spaced = reduce(into: "") { result, character in
      if character.isUppercase, !result.isEmpty {
        result.append(" ")
      }
      result.append(character)
    }
    return first.uppercased() + String(spaced.dropFirst())
  }
}
