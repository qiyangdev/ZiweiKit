/// A type-safe Swift counterpart to iztro's runtime plugins.
///
/// Plugins evaluate an immutable chart and may return any domain-specific
/// result. Libraries can also extend `Astrolabe`, `Palace`, and `Star`
/// directly with ordinary Swift extensions.
public protocol AstrolabePlugin {
  associatedtype Output

  /// Evaluates a chart and returns the plugin-defined result.
  func apply(to astrolabe: Astrolabe) throws -> Output
}

extension Astrolabe {
  /// Applies a reusable, strongly typed analysis plugin to this chart.
  public func use<Plugin: AstrolabePlugin>(_ plugin: Plugin) throws -> Plugin.Output {
    try plugin.apply(to: self)
  }

  /// Evaluates this chart with an inline analysis closure.
  public func analyze<Output>(
    _ analysis: (Astrolabe) throws -> Output
  ) rethrows -> Output {
    try analysis(self)
  }
}
