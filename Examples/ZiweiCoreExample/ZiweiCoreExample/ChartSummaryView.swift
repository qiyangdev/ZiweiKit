import SwiftUI
import ZiweiCore

struct ChartSummaryView: View {
  @State private var chart: Astrolabe?
  @State private var errorMessage: String?

  var body: some View {
    NavigationStack {
      Group {
        if let chart {
          chartList(chart)
        } else if let errorMessage {
          errorView(errorMessage)
        } else {
          ProgressView("Calculating chart…")
        }
      }
      .navigationTitle("ZiweiCore")
      .navigationDestination(for: PalaceID.self) { palaceID in
        if let palace = chart?.palace(palaceID) {
          PalaceDetailView(palace: palace)
        }
      }
    }
    .task {
      calculateChart()
    }
  }

  private func chartList(_ chart: Astrolabe) -> some View {
    List {
      Section("Example chart") {
        LabeledContent("Solar date", value: chart.solarDate.description)
        LabeledContent("Gender", value: chart.gender.rawValue)
        LabeledContent("Five-elements class", value: String(describing: chart.fiveElementsClass))
        LabeledContent("Western zodiac", value: chart.westernZodiac.rawValue)
        LabeledContent("Soul star", value: chart.soulStarID.rawValue)
        LabeledContent("Body star", value: chart.bodyStarID.rawValue)
      }

      Section("Palaces") {
        ForEach(chart.palaces, id: \.index) { palace in
          NavigationLink(value: palace.id) {
            PalaceRow(palace: palace)
          }
        }
      }
    }
  }

  private func errorView(_ message: String) -> some View {
    VStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle")
        .font(.largeTitle)
        .foregroundStyle(.secondary)
      Text("Unable to calculate chart")
        .font(.headline)
      Text(message)
        .foregroundStyle(.secondary)
    }
    .padding()
  }

  private func calculateChart() {
    do {
      chart = try Ziwei.chart(
        solarDate: SolarDate(year: 2000, month: 8, day: 16),
        hour: .yin,
        gender: .female
      )
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}

private struct PalaceRow: View {
  let palace: Palace

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(palace.id.rawValue)
        .font(.headline)
      Text(palace.stars.map(\.id.rawValue).joined(separator: ", "))
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(2)
    }
    .padding(.vertical, 2)
  }
}

private struct PalaceDetailView: View {
  let palace: Palace

  var body: some View {
    List {
      Section("Palace") {
        LabeledContent("Identifier", value: palace.id.rawValue)
        LabeledContent("Heavenly stem", value: String(describing: palace.stem))
        LabeledContent("Earthly branch", value: String(describing: palace.branch))
        LabeledContent("Body palace", value: palace.isBodyPalace ? "Yes" : "No")
      }

      starSection("Major stars", stars: palace.majorStars)
      starSection("Minor stars", stars: palace.minorStars)
      starSection("Adjective stars", stars: palace.adjectiveStars)
    }
    .navigationTitle(palace.id.rawValue)
  }

  private func starSection(_ title: String, stars: [Star]) -> some View {
    Section(title) {
      if stars.isEmpty {
        Text("None")
          .foregroundStyle(.secondary)
      } else {
        ForEach(stars, id: \.id) { star in
          LabeledContent(star.id.rawValue, value: star.type.rawValue)
        }
      }
    }
  }
}

#Preview {
  ChartSummaryView()
}
