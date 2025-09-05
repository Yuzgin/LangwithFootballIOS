//
//  FixturesView.swift
//  LangwithFootball
//

import SwiftUI
import Foundation
import UIKit

// MARK: - If you already have these helpers in a shared file, delete this block.
// (They mirror your ResultsView helpers so the visuals match exactly.)

private let lightBlue      = Color(red: 0.65, green: 0.85, blue: 1.0)
private let darkBlue       = Color(red: 0.05, green: 0.20, blue: 0.60)
private let langwithYellow = Color(red: 1.00, green: 0.85, blue: 0.00)
private let BADGE_SIZE: CGFloat = 22
private let BAR_WIDTH: CGFloat = 9

private func baseTeamName(from fullName: String) -> String {
    if let first = fullName.split(separator: " ").first { return String(first) }
    return fullName.replacingOccurrences(of: #"[\d\s]*s?$"#, with: "", options: .regularExpression)
}

private func langwithNumber(from fullName: String) -> Int? {
    let pattern = #"\b([1-6])\s*s\b"#
    if let range = fullName.range(of: pattern, options: .regularExpression) {
        let token = String(fullName[range])
        if let digit = token.first(where: { $0.isNumber }), let n = Int(String(digit)) { return n }
    }
    return nil
}

private let teamBaseColors: [String: Color] = [
    "Langwith": .yellow, "Halifax": .blue,
    "Constantine": Color(red: 1.0, green: 0.41, blue: 0.71),
    "Derwent": darkBlue, "Goodricke": .green, "James": .black,
    "Alcuin": .red, "Vanbrugh": .purple
]

private func verticalGradient(_ colors: [Color]) -> LinearGradient {
    LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
}

// === CHANGED: match ResultsView (yellow → black-tinted yellow up to light yellow by 6s) ===
private func langwithYellowToLightYellowGradient(for fullName: String) -> LinearGradient? {
    guard baseTeamName(from: fullName) == "Langwith",
          let n = langwithNumber(from: fullName),
          (1...6).contains(n) else {
        return nil
    }
    // Scale: 1s = black, 6s ≈ light yellow
    let fraction = Double(n - 1) / 5.0 // 0.0 → 1.0
    let secondColor = Color.black
        .lerped(to: Color.yellow, fraction: fraction)
        .opacity(1.0)

    return verticalGradient([langwithYellow, secondColor])
}

private func teamGradient(for base: String) -> LinearGradient? {
    switch base {
    case "Lister", "Kato":
        return verticalGradient([lightBlue, .orange])
    case "Langwith":
        return verticalGradient([
            Color(red: 1.00, green: 0.95, blue: 0.40),
            Color(red: 1.00, green: 0.78, blue: 0.00)
        ])
    case "Halifax":
        return verticalGradient([ lightBlue, Color(red: 0.20, green: 0.55, blue: 0.95) ])
    case "Constantine":
        return verticalGradient([ Color(red: 1.00, green: 0.60, blue: 0.80),
                                  Color(red: 0.90, green: 0.10, blue: 0.50) ])
    case "Derwent":
        return verticalGradient([ Color(red: 0.15, green: 0.35, blue: 0.85), darkBlue ])
    case "Goodricke":
        return verticalGradient([ Color(red: 0.70, green: 0.93, blue: 0.70), .green ])
    case "James":
        return verticalGradient([ Color(white: 0.30), .black ])
    case "Alcuin":
        return verticalGradient([ Color(red: 1.00, green: 0.65, blue: 0.65), .red ])
    case "Vanbrugh":
        return verticalGradient([ Color(red: 0.75, green: 0.60, blue: 0.95), .purple ])
    default:
        return nil
    }
}

// === CHANGED: stronger reach glow like ResultsView ===
private func barGlow(for teamName: String) -> (color: Color, radius: CGFloat, opacity: Double)? {
    guard baseTeamName(from: teamName) == "Langwith",
          let n = langwithNumber(from: teamName) else { return nil }
    // 1s -> strong glow, 6s -> none
    let t = max(0.0, 1.0 - Double(n - 1) / 5.0) // 1s=1 → 6s=0
    let radius = CGFloat(30 * t)                // wider halo (match Results)
    let opacity = 0.9 * t                       // further reach rather than “brighter”
    guard radius > 0.2, opacity > 0.1 else { return nil }
    return (langwithYellow, radius, opacity)
}

private enum BarFill { case color(Color); case gradient(LinearGradient) }

// === CHANGED: use the new Langwith gradient ===
private func barFill(for teamName: String) -> BarFill {
    if let lw = langwithYellowToLightYellowGradient(for: teamName) { return .gradient(lw) }
    let key = baseTeamName(from: teamName)
    if let grad = teamGradient(for: key) { return .gradient(grad) }
    let color = teamBaseColors[key, default: Color.gray.opacity(0.6)]
    return .color(color)
}

// === NEW: dynamic width for Langwith bars (1s widest → 6s 60%) ===
private func barWidth(for teamName: String) -> CGFloat {
    guard baseTeamName(from: teamName) == "Langwith",
          let n = langwithNumber(from: teamName) else {
        return BAR_WIDTH
    }
    let fraction = 1.0 - (Double(n - 1) / 5.0)  // 1s=1.0 … 6s=0.0
    return BAR_WIDTH * CGFloat(0.6 + 0.4 * fraction)
}

@ViewBuilder
private func gradientBar(for teamName: String) -> some View {
    let glow = barGlow(for: teamName)
    let width = barWidth(for: teamName) // === CHANGED: variable width ===
    switch barFill(for: teamName) {
    case .gradient(let g):
        Rectangle()
            .fill(g)
            .frame(width: width)
            .shadow(color: (glow?.color.opacity(glow?.opacity ?? 0)) ?? .clear,
                    radius: glow?.radius ?? 0, x: 0, y: 0)
    case .color(let c):
        Rectangle()
            .fill(c)
            .frame(width: width)
            .shadow(color: (glow?.color.opacity(glow?.opacity ?? 0)) ?? .clear,
                    radius: glow?.radius ?? 0, x: 0, y: 0)
    }
}

private func teamBadgeAssetName(for fullName: String) -> String {
    let base = baseTeamName(from: fullName).lowercased()
    if base == "langwith", let n = langwithNumber(from: fullName) { return "badge_langwith_\(n)" }
    return "badge_\(base)"
}

private var startOfToday: Date {
    Calendar.current.startOfDay(for: Date())
}

private func mergedDateTime(_ date: Date, _ time: Date) -> Date {
    let cal = Calendar.current
    let d = cal.dateComponents([.year, .month, .day], from: date)
    let t = cal.dateComponents([.hour, .minute, .second], from: time)
    var comps = DateComponents()
    comps.year = d.year; comps.month = d.month; comps.day = d.day
    comps.hour = t.hour; comps.minute = t.minute; comps.second = t.second
    return cal.date(from: comps) ?? date
}

private func badgeImage(for fullName: String) -> Image? {
    let asset = teamBadgeAssetName(for: fullName)
    if UIImage(named: asset) != nil { return Image(asset) }
    if baseTeamName(from: fullName) == "Langwith", UIImage(named: "badge_langwith") != nil {
        return Image("badge_langwith")
    }
    return nil
}

private func displayTeamName(_ fullName: String) -> String {
    if fullName.hasPrefix("Lister & Kato") {
        let suffix = fullName.dropFirst("Lister & Kato".count)
        return "Lister/Kato" + suffix
    }
    if fullName.hasPrefix("Constantine") {
        let suffix = fullName.dropFirst("Constantine".count)
        return "Connie" + suffix
    }
    return fullName
}

private func scaledFont(_ style: UIFont.TextStyle, factor: CGFloat, weight: Font.Weight = .semibold) -> Font {
    let base = UIFont.preferredFont(forTextStyle: style).pointSize
    return .system(size: base * factor, weight: weight)
}

private struct DisplayFixture: Identifiable {
    let id: String
    let left: String
    let right: String
    let fixture: Fixture
    let isSwapped: Bool
}

@ViewBuilder
private func homeTeamLabel(_ name: String) -> some View {
    HStack(spacing: 2) {
        Text(displayTeamName(name))
            .font(scaledFont(.headline, factor: 0.9, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .allowsTightening(true)
            .layoutPriority(1)
        if let img = badgeImage(for: name) {
            img.resizable().scaledToFit()
                .frame(width: BADGE_SIZE, height: BADGE_SIZE)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
        } else {
            Image(systemName: "shield.lefthalf.filled")
                .font(.headline)
                .frame(width: BADGE_SIZE, height: BADGE_SIZE)
                .opacity(0.5)
        }
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
}

@ViewBuilder
private func awayTeamLabel(_ name: String) -> some View {
    HStack(spacing: 2) {
        if let img = badgeImage(for: name) {
            img.resizable().scaledToFit()
                .frame(width: BADGE_SIZE, height: BADGE_SIZE)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
        } else {
            Image(systemName: "shield.lefthalf.filled")
                .font(.headline)
                .frame(width: BADGE_SIZE, height: BADGE_SIZE)
                .opacity(0.5)
        }
        Text(displayTeamName(name))
            .font(scaledFont(.headline, factor: 0.9, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .allowsTightening(true)
            .layoutPriority(1)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

private func isLangwith(_ name: String) -> Bool {
    baseTeamName(from: name) == "Langwith"
}

/// Ensure Langwith appears on the LEFT. If both are Langwith, keep original order.
private func normalizeSides(team1: String, team2: String) -> (left: String, right: String) {
    let aIs = isLangwith(team1)
    let bIs = isLangwith(team2)
    if aIs && bIs { return (team1, team2) }
    if aIs { return (team1, team2) }
    if bIs { return (team2, team1) }
    return (team1, team2)
}

// MARK: - FixturesView

struct FixturesView: View {
    @StateObject private var viewModel = FixtureViewModel()
    @State private var selectedTeam: LangwithTeam? = nil

    private var displayedFixtures: [DisplayFixture] {
        // 1) Keep only fixtures from today onwards
        let future = viewModel.fixtures.filter { mergedDateTime($0.date, $0.time) >= startOfToday }

        // 2) Expand for Langwith-vs-Langwith and normalize sides elsewhere
        let expanded: [DisplayFixture] = future.flatMap { f in
            let aIs = isLangwith(f.team1)
            let bIs = isLangwith(f.team2)

            if aIs && bIs {
                return [
                    DisplayFixture(id: "\(f.id)-A", left: f.team1, right: f.team2, fixture: f, isSwapped: false),
                    DisplayFixture(id: "\(f.id)-B", left: f.team2, right: f.team1, fixture: f, isSwapped: true)
                ]
            } else {
                let sides = normalizeSides(team1: f.team1, team2: f.team2)
                let swapped = (sides.left != f.team1)
                return [
                    DisplayFixture(id: "\(f.id)", left: sides.left, right: sides.right, fixture: f, isSwapped: swapped)
                ]
            }
        }

        // 3) Apply the menu filter ONLY to the left/home side
        let leftFiltered: [DisplayFixture]
        if let team = selectedTeam?.rawValue {
            leftFiltered = expanded.filter { $0.left == team }
        } else {
            leftFiltered = expanded
        }

        // 4) Sort chronologically
        return leftFiltered.sorted {
            mergedDateTime($0.fixture.date, $0.fixture.time) < mergedDateTime($1.fixture.date, $1.fixture.time)
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Content
                List {
                    ForEach(displayedFixtures) { df in
                        VStack(spacing: 8) {
                            HStack {
                                homeTeamLabel(df.left)

                                Text("vs")
                                    .font(.title3).fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .scaleEffect(0.9)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.15))
                                    )

                                awayTeamLabel(df.right)
                            }

                            Text(formattedDateTime(date: df.fixture.date, time: df.fixture.time))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .scaleEffect(0.7)

                            if let gw = df.fixture.gameWeek {
                                Text("Game Week \(gw)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .scaleEffect(0.7)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                        // side bars use the displayed sides too
                        .overlay(
                            ZStack {
                                HStack(spacing: 0) {
                                    gradientBar(for: df.left)
                                    Spacer(minLength: 0)
                                }
                                HStack(spacing: 0) {
                                    Spacer(minLength: 0)
                                    gradientBar(for: df.right)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)
                .padding(.top, 44)

                // Floating filter pill
                Menu {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTeam = nil
                        }
                    } label: {
                        Label("All Teams", systemImage: selectedTeam == nil ? "checkmark" : "circle")
                    }

                    Divider()

                    ForEach(LangwithTeam.allCases) { team in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTeam = team
                            }
                        } label: {
                            HStack {
                                Text(team.rawValue)
                                Spacer()
                                if selectedTeam == team { Image(systemName: "checkmark") }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedTeam?.rawValue ?? "All Teams")
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule().strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                }
                .padding(.top, 6)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .top)
                .zIndex(1)
            }
            .onAppear { viewModel.fetchFixtures() }
            .overlay {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.fixtures.isEmpty {
                    ProgressView("Loading...")
                }
            }
        }
    }

    // MARK: - Date formatting helpers

    private func formattedDateTime(date: Date, time: Date) -> String {
        // If your backend already gives combined Date, use that directly.
        // Otherwise, merge date & time components for display only:
        let cal = Calendar.current
        let dateComps = cal.dateComponents([.year, .month, .day], from: date)
        let timeComps = cal.dateComponents([.hour, .minute, .second], from: time)
        var merged = Date()
        if let y = dateComps.year, let m = dateComps.month, let d = dateComps.day,
           let h = timeComps.hour, let min = timeComps.minute, let s = timeComps.second {
            var comps = DateComponents()
            comps.year = y; comps.month = m; comps.day = d
            comps.hour = h; comps.minute = min; comps.second = s
            merged = cal.date(from: comps) ?? date
        } else {
            merged = date
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, h:mm a"
        return formatter.string(from: merged)
    }
}

// MARK: - Preview

#Preview {
    FixturesView()
}

