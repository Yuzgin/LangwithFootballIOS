//
//  TeamCardComponents.swift
//  LangwithFootball
//
//  Shared components for team cards across Fixtures, Results, and Home views
//

import SwiftUI
import Foundation
import UIKit

// MARK: - Shared Constants and Colors

private let lightBlue      = Color(red: 0.65, green: 0.85, blue: 1.0)
private let darkBlue       = Color(red: 0.05, green: 0.20, blue: 0.60)
private let langwithYellow = Color(red: 1.00, green: 0.85, blue: 0.00)
private let BADGE_SIZE: CGFloat = 22
private let BAR_WIDTH: CGFloat = 9

// MARK: - Color Extension

extension Color {
    func lerped(to other: Color, fraction: Double) -> Color {
        let f = min(max(fraction, 0), 1)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        UIColor(self).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        UIColor(other).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return Color(
            red: Double(r1 + (r2 - r1) * CGFloat(f)),
            green: Double(g1 + (g2 - g1) * CGFloat(f)),
            blue: Double(b1 + (b2 - b1) * CGFloat(f)),
            opacity: Double(a1 + (a2 - a1) * CGFloat(f))
        )
    }
}

// MARK: - Helper Functions

/// Returns just the college/base name (e.g. "Langwith 5s" -> "Langwith")
func baseTeamName(from fullName: String) -> String {
    if let first = fullName.split(separator: " ").first {
        return String(first)
    }
    return fullName.replacingOccurrences(of: #"[\d\s]*s?$"#,
                                         with: "",
                                         options: .regularExpression)
}

/// Extract Langwith team number 1...6 if present (e.g. "Langwith 3s" -> 3)
func langwithNumber(from fullName: String) -> Int? {
    let pattern = #"\b([1-6])\s*s\b"#
    if let range = fullName.range(of: pattern, options: .regularExpression) {
        let token = String(fullName[range])
        if let digit = token.first(where: { $0.isNumber }), let n = Int(String(digit)) {
            return n
        }
    }
    return nil
}

/// Fallback solid colours
private let teamBaseColors: [String: Color] = [
    "Langwith": .yellow,
    "Halifax": .blue,
    "Constantine": Color(red: 1.0, green: 0.41, blue: 0.71),
    "Derwent": darkBlue,
    "Goodricke": .green,
    "James": .black,
    "Alcuin": .red,
    "Vanbrugh": .purple
]

/// Helper to build vertical gradients
private func verticalGradient(_ colors: [Color]) -> LinearGradient {
    LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
}

/// Langwith 1s…6s: yellow → tinted yellow stepping from black (1s) to light yellow (6s)
private func langwithYellowToLightYellowGradient(for fullName: String) -> LinearGradient? {
    guard baseTeamName(from: fullName) == "Langwith",
          let n = langwithNumber(from: fullName),
          (1...6).contains(n) else {
        return nil
    }

    // Scale: 1s = black, 6s ≈ light yellow
    let fraction = Double(n - 1) / 5.0 // range 0.0 → 1.0

    // Start at black, blend toward yellow
    let secondColor = Color.black
        .lerped(to: Color.yellow, fraction: fraction)
        .opacity(1.0)

    return verticalGradient([langwithYellow, secondColor])
}

/// Gradient map for other colleges
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

/// Bar glow (yellow) intensity scales down 1s → 6s; nil for others
private func barGlow(for teamName: String) -> (color: Color, radius: CGFloat, opacity: Double)? {
    guard baseTeamName(from: teamName) == "Langwith",
          let n = langwithNumber(from: teamName) else {
        return nil
    }
    // 1s -> strong glow, 6s -> none
    let t = max(0.0, 1.0 - Double(n - 1) / 5.0) // 1s=1, 6s=0
    let radius = CGFloat(30 * t)                // wider halo
    let opacity = 0.9 * t                      // not "stronger", just further reach
    guard radius > 0.2, opacity > 0.1 else { return nil }
    return (langwithYellow, radius, opacity)
}

// A typed fill we can render with .fill(..)
private enum BarFill {
    case color(Color)
    case gradient(LinearGradient)
}

/// Determine the bar fill
private func barFill(for teamName: String) -> BarFill {
    if let lw = langwithYellowToLightYellowGradient(for: teamName) {
        return .gradient(lw)
    }
    let key = baseTeamName(from: teamName)
    if let grad = teamGradient(for: key) {
        return .gradient(grad)
    }
    let color = teamBaseColors[key, default: Color.gray.opacity(0.6)]
    return .color(color)
}

/// Dynamic bar width for Langwith 1s…6s; fixed width for others
private func barWidth(for teamName: String) -> CGFloat {
    guard baseTeamName(from: teamName) == "Langwith",
          let n = langwithNumber(from: teamName) else {
        return BAR_WIDTH
    }

    // Scale: 1s = full width, 6s = 60% of width
    let fraction = 1.0 - (Double(n - 1) / 5.0)  // 1s=1.0 … 6s=0.0
    return BAR_WIDTH * CGFloat(0.6 + 0.4 * fraction)
}

/// Build a side bar view (fixed width, optional glow)
@ViewBuilder
func gradientBar(for teamName: String) -> some View {
    let glow = barGlow(for: teamName)
    switch barFill(for: teamName) {
    case .gradient(let g):
        Rectangle()
            .fill(g)
            .frame(width: barWidth(for: teamName))
            .shadow(color: (glow?.color.opacity(glow?.opacity ?? 0)) ?? .clear,
                    radius: glow?.radius ?? 0, x: 0, y: 0)
    case .color(let c):
        Rectangle()
            .fill(c)
            .frame(width: barWidth(for: teamName))
            .shadow(color: (glow?.color.opacity(glow?.opacity ?? 0)) ?? .clear,
                    radius: glow?.radius ?? 0, x: 0, y: 0)
    }
}

/// Compute the expected asset name for a team badge
private func teamBadgeAssetName(for fullName: String) -> String {
    let base = baseTeamName(from: fullName).lowercased()
    if base == "langwith", let n = langwithNumber(from: fullName) {
        return "badge_langwith_\(n)"
    }
    return "badge_\(base)" // e.g. badge_halifax, badge_derwent, etc.
}

/// Return a SwiftUI Image if the asset exists, else nil
func badgeImage(for fullName: String) -> Image? {
    let asset = teamBadgeAssetName(for: fullName)
    if UIImage(named: asset) != nil {
        return Image(asset)
    }
    // Optional: try a generic 'badge_langwith' if a numbered one isn't present
    if baseTeamName(from: fullName) == "Langwith",
       UIImage(named: "badge_langwith") != nil {
        return Image("badge_langwith")
    }
    return nil
}

/// Display-only aliasing for certain team names
func displayTeamName(_ fullName: String) -> String {
    // Exact merge-name alias
    if fullName.hasPrefix("Lister & Kato") {
        let suffix = fullName.dropFirst("Lister & Kato".count)
        return "Lister/Kato" + suffix
    }
    // Replace base "Constantine" with "Connie", keeping any suffix (e.g., "Connie 1s")
    if fullName.hasPrefix("Constantine") {
        let suffix = fullName.dropFirst("Constantine".count)
        return "Connie" + suffix
    }
    return fullName
}

/// True font scaling that affects layout (instead of .scaleEffect)
func scaledFont(_ style: UIFont.TextStyle, factor: CGFloat, weight: Font.Weight = .semibold) -> Font {
    let base = UIFont.preferredFont(forTextStyle: style).pointSize
    return .system(size: base * factor, weight: weight)
}

/// Label view for the home (team1) side — text aligned right, badge on the right
@ViewBuilder
func homeTeamLabel(_ name: String) -> some View {
    HStack(spacing: 2) {
        Text(displayTeamName(name))
            .font(scaledFont(.headline, factor: 0.9, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .allowsTightening(true)
            .layoutPriority(1)
        if let img = badgeImage(for: name) {
            img.resizable()
                .scaledToFit()
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
func awayTeamLabel(_ name: String) -> some View {
    HStack(spacing: 2) {
        if let img = badgeImage(for: name) {
            img.resizable()
                .scaledToFit()
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

/// Ensure Langwith appears on the LEFT. If both are Langwith, keep original order.
func normalizeSides(team1: String, team2: String) -> (left: String, right: String) {
    let aIs = baseTeamName(from: team1) == "Langwith"
    let bIs = baseTeamName(from: team2) == "Langwith"
    if aIs && bIs { return (team1, team2) }
    if aIs { return (team1, team2) }
    if bIs { return (team2, team1) }
    return (team1, team2)
}

// MARK: - Shared Card Components

/// Shared fixture card component
struct FixtureCard: View {
    let fixture: Fixture
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                homeTeamLabel(fixture.team1)

                Text("vs")
                    .font(.title3).fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .scaleEffect(0.9)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.15))
                    )

                awayTeamLabel(fixture.team2)
            }

            Text(formattedDateTime(date: fixture.date, time: fixture.time))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .scaleEffect(0.7)

            Text(fixture.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .scaleEffect(0.7)

            if let gw = fixture.gameWeek {
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
        .overlay(
            ZStack {
                HStack(spacing: 0) {
                    gradientBar(for: fixture.team1)
                    Spacer(minLength: 0)
                }
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    gradientBar(for: fixture.team2)
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
    }
    
    private func formattedDateTime(date: Date, time: Date) -> String {
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

/// Shared result card component
struct ResultCard: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                homeTeamLabel(match.team1)

                Text("\(match.team1Score) - \(match.team2Score)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .scaleEffect(0.9)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.15))
                    )

                awayTeamLabel(match.team2)
            }

            Text(formattedDate(match.date))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .scaleEffect(0.7)

            if let gameWeek = match.gameWeek {
                Text("Game Week \(gameWeek)")
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
        .overlay(
            ZStack {
                HStack(spacing: 0) {
                    gradientBar(for: match.team1)
                    Spacer(minLength: 0)
                }
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    gradientBar(for: match.team2)
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
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, h:mm a"
        return formatter.string(from: date)
    }
}
