//
//  FixturesView.swift
//  LangwithFootball
//

import SwiftUI
import Foundation
import UIKit

private struct DisplayFixture: Identifiable {
    let id: String
    let left: String
    let right: String
    let fixture: Fixture
    let isSwapped: Bool
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

private func isLangwith(_ name: String) -> Bool {
    baseTeamName(from: name) == "Langwith"
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
        VStack(spacing: 0) {
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
            
            // Content area
            if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding(.top, 20)
            } else if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading fixtures...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
            } else if viewModel.hasLoaded && displayedFixtures.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("No fixtures available")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Check back later for upcoming matches")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
            } else {
                // Fixtures content
                VStack(spacing: 0) {
                    ForEach(displayedFixtures) { df in
                        FixtureCard(fixture: df.fixture)
                    }
                }
                .padding(.top, 8)
            }
        }
        .onAppear { viewModel.fetchFixtures() }
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

