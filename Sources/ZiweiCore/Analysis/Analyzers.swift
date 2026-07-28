/// The four palaces used by three-directions-and-four-alignments analysis (三方四正).
public struct SurroundedPalaces: Equatable, Sendable {
  public let target: Palace
  public let opposite: Palace
  public let wealth: Palace
  public let career: Palace

  public var all: [Palace] { [target, opposite, wealth, career] }

  public init(target: Palace, opposite: Palace, wealth: Palace, career: Palace) {
    self.target = target
    self.opposite = opposite
    self.wealth = wealth
    self.career = career
  }

  public func contains(_ stars: [StarID]) -> Bool {
    let ids = Set(all.flatMap(\.stars).map(\.id))
    return stars.allSatisfy(ids.contains)
  }

  public func containsAny(of stars: [StarID]) -> Bool {
    let ids = Set(all.flatMap(\.stars).map(\.id))
    return stars.contains(where: ids.contains)
  }

  public func containsNone(of stars: [StarID]) -> Bool {
    let ids = Set(all.flatMap(\.stars).map(\.id))
    return stars.allSatisfy { !ids.contains($0) }
  }

  public func contains(_ mutagen: Mutagen) -> Bool {
    all.contains { $0.contains(mutagen) }
  }
}

extension Palace {
  public func contains(_ stars: [StarID]) -> Bool {
    let ids = Set(self.stars.map(\.id))
    return stars.allSatisfy(ids.contains)
  }

  public func containsAny(of stars: [StarID]) -> Bool {
    let ids = Set(self.stars.map(\.id))
    return stars.contains(where: ids.contains)
  }

  public func containsNone(of stars: [StarID]) -> Bool {
    let ids = Set(self.stars.map(\.id))
    return stars.allSatisfy { !ids.contains($0) }
  }

  public func contains(_ mutagen: Mutagen) -> Bool {
    stars.contains { $0.mutagen == mutagen }
  }

  public var isEmpty: Bool { isEmpty(excluding: []) }

  public func isEmpty(excluding stars: [StarID]) -> Bool {
    !majorStars.contains { $0.type == .major } && !containsAny(of: stars)
  }

  public func flies(
    to target: PalaceID, mutagens: [Mutagen], in astrolabe: Astrolabe
  ) -> Bool {
    guard let targetPalace = astrolabe.palace(target) else { return false }
    let stars = astrolabe.mutagenStars(for: stem, mutagens: mutagens)
    return !stars.isEmpty && targetPalace.contains(stars)
  }

  public func fliesAny(
    to target: PalaceID, mutagens: [Mutagen], in astrolabe: Astrolabe
  ) -> Bool {
    guard let targetPalace = astrolabe.palace(target) else { return false }
    let stars = astrolabe.mutagenStars(for: stem, mutagens: mutagens)
    return stars.isEmpty || targetPalace.containsAny(of: stars)
  }

  public func doesNotFly(
    to target: PalaceID, mutagens: [Mutagen], in astrolabe: Astrolabe
  ) -> Bool {
    guard let targetPalace = astrolabe.palace(target) else { return false }
    let stars = astrolabe.mutagenStars(for: stem, mutagens: mutagens)
    return stars.isEmpty || targetPalace.containsNone(of: stars)
  }

  public func isSelfMutated(by mutagens: [Mutagen], in astrolabe: Astrolabe) -> Bool {
    contains(astrolabe.mutagenStars(for: stem, mutagens: mutagens))
  }

  public func isSelfMutatedByAny(
    _ mutagens: [Mutagen] = Mutagen.allCases, in astrolabe: Astrolabe
  ) -> Bool {
    containsAny(of: astrolabe.mutagenStars(for: stem, mutagens: mutagens))
  }

  public func isNotSelfMutated(
    by mutagens: [Mutagen] = Mutagen.allCases, in astrolabe: Astrolabe
  ) -> Bool {
    containsNone(of: astrolabe.mutagenStars(for: stem, mutagens: mutagens))
  }

  public func mutatedPalaces(in astrolabe: Astrolabe) -> [Palace?] {
    astrolabe.mutagenStars(for: stem, mutagens: Mutagen.allCases).map {
      astrolabe.palace(containing: $0)
    }
  }
}

extension Star {
  public func hasBrightness(_ value: Brightness) -> Bool { brightness == value }

  public func hasAnyBrightness(_ values: [Brightness]) -> Bool {
    brightness.map(values.contains) ?? false
  }

  public func hasMutagen(_ value: Mutagen) -> Bool { mutagen == value }

  public func hasAnyMutagen(_ values: [Mutagen]) -> Bool {
    mutagen.map(values.contains) ?? false
  }

  public func palace(in astrolabe: Astrolabe) -> Palace? {
    astrolabe.palace(containing: id)
  }

  public func oppositePalace(in astrolabe: Astrolabe) -> Palace? {
    guard let palace = palace(in: astrolabe) else { return nil }
    return astrolabe.palace(at: positiveModulo(palace.index + 6))
  }

  public func surroundedPalaces(in astrolabe: Astrolabe) -> SurroundedPalaces? {
    guard let palace = palace(in: astrolabe) else { return nil }
    return astrolabe.surroundedPalaces(at: palace.index)
  }
}

extension Astrolabe {
  public func star(_ id: StarID) -> Star? {
    palaces.lazy.flatMap(\.stars).first { $0.id == id }
  }

  public func palace(_ id: PalaceID) -> Palace? {
    palaces.first { $0.id == id }
  }

  public func palace(containing star: StarID) -> Palace? {
    palaces.first { $0.stars.contains { $0.id == star } }
  }

  public func surroundingPalaces(of id: PalaceID) -> SurroundedPalaces? {
    guard let palace = palace(id) else { return nil }
    return surroundedPalaces(at: palace.index)
  }

  public func surroundedPalaces(at index: Int) -> SurroundedPalaces? {
    guard let target = palace(at: positiveModulo(index)),
      let opposite = palace(at: positiveModulo(index + 6)),
      let wealth = palace(at: positiveModulo(index + 8)),
      let career = palace(at: positiveModulo(index + 4))
    else { return nil }
    return SurroundedPalaces(
      target: target, opposite: opposite, wealth: wealth, career: career)
  }

  fileprivate func mutagenStars(for stem: HeavenlyStem, mutagens: [Mutagen]) -> [StarID] {
    let stars = configuration.mutagenStars(for: stem)
    return mutagens.compactMap { mutagen in
      let index = Mutagen.allCases.firstIndex(of: mutagen)!
      return stars.indices.contains(index) ? stars[index] : nil
    }
  }
}

extension Horoscope {
  public func agePalace(in astrolabe: Astrolabe) -> Palace? {
    astrolabe.palace(at: age.index)
  }

  public func palace(
    _ palaceID: PalaceID, scope: HoroscopeScope, in astrolabe: Astrolabe
  ) -> Palace? {
    if scope == .origin { return astrolabe.palace(palaceID) }
    guard let index = period(for: scope)?.palaceIDs.firstIndex(of: palaceID) else { return nil }
    return astrolabe.palace(at: index)
  }

  public func surroundingPalaces(
    of palaceID: PalaceID, scope: HoroscopeScope, in astrolabe: Astrolabe
  ) -> SurroundedPalaces? {
    guard let palace = palace(palaceID, scope: scope, in: astrolabe) else { return nil }
    return astrolabe.surroundedPalaces(at: palace.index)
  }

  public func containsHoroscopeStars(
    _ stars: [StarID], in palaceID: PalaceID, scope: HoroscopeScope,
    astrolabe: Astrolabe
  ) -> Bool {
    guard let index = horoscopePalaceIndex(palaceID, scope: scope, astrolabe: astrolabe) else {
      return false
    }
    let ids = Set((decadal.stars[index] + yearly.stars[index]).map(\.id))
    return stars.allSatisfy(ids.contains)
  }

  public func containsNoneOfHoroscopeStars(
    _ stars: [StarID], in palaceID: PalaceID, scope: HoroscopeScope,
    astrolabe: Astrolabe
  ) -> Bool {
    guard let index = horoscopePalaceIndex(palaceID, scope: scope, astrolabe: astrolabe) else {
      return false
    }
    let ids = Set((decadal.stars[index] + yearly.stars[index]).map(\.id))
    return stars.allSatisfy { !ids.contains($0) }
  }

  public func containsAnyHoroscopeStars(
    _ stars: [StarID], in palaceID: PalaceID, scope: HoroscopeScope,
    astrolabe: Astrolabe
  ) -> Bool {
    guard let index = horoscopePalaceIndex(palaceID, scope: scope, astrolabe: astrolabe) else {
      return false
    }
    let ids = Set((decadal.stars[index] + yearly.stars[index]).map(\.id))
    return stars.contains(where: ids.contains)
  }

  public func containsHoroscopeMutagen(
    _ mutagen: Mutagen, in palaceID: PalaceID, scope: HoroscopeScope,
    astrolabe: Astrolabe
  ) -> Bool {
    guard scope != .origin,
      let period = period(for: scope),
      let mutagenIndex = Mutagen.allCases.firstIndex(of: mutagen),
      period.mutagens.indices.contains(mutagenIndex),
      let palace = palace(palaceID, scope: scope, in: astrolabe)
    else { return false }
    return (palace.majorStars + palace.minorStars).contains {
      $0.id == period.mutagens[mutagenIndex]
    }
  }

  private func period(for scope: HoroscopeScope) -> HoroscopePeriod? {
    switch scope {
    case .origin: nil
    case .decadal: decadal
    case .yearly: yearly
    case .monthly: monthly
    case .daily: daily
    case .hourly: hourly
    }
  }

  private func horoscopePalaceIndex(
    _ palaceID: PalaceID, scope: HoroscopeScope, astrolabe: Astrolabe
  ) -> Int? {
    if scope == .origin { return astrolabe.palaces.firstIndex { $0.id == palaceID } }
    return period(for: scope)?.palaceIDs.firstIndex(of: palaceID)
  }
}
