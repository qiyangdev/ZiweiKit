/// A type-safe Swift counterpart to iztro's runtime plugins.
///
/// Plugins evaluate an immutable chart and may return any domain-specific
/// result. Libraries can also extend `Astrolabe`, `Palace`, and `Star`
/// directly with ordinary Swift extensions.
public protocol AstrolabePlugin {
  associatedtype Output
  func apply(to astrolabe: Astrolabe) throws -> Output
}

extension Astrolabe {
  public func use<Plugin: AstrolabePlugin>(_ plugin: Plugin) throws -> Plugin.Output {
    try plugin.apply(to: self)
  }

  public func analyze<Output>(
    _ analysis: (Astrolabe) throws -> Output
  ) rethrows -> Output {
    try analysis(self)
  }
}
