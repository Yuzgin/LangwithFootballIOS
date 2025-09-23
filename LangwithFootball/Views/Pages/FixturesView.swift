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
    // Backend supplies separate date and time in UTC; combine them as UTC, then use as absolute Date
    var utcCal = Calendar(identifier: .gregorian)
    utcCal.timeZone = TimeZone(secondsFromGMT: 0)!
    let d = utcCal.dateComponents([.year, .month, .day], from: date)
    let t = utcCal.dateComponents([.hour, .minute, .second], from: time)
    var comps = DateComponents()
    comps.timeZone = TimeZone(secondsFromGMT: 0)
    comps.year = d.year; comps.month = d.month; comps.day = d.day
    comps.hour = t.hour; comps.minute = t.minute; comps.second = t.second
    return utcCal.date(from: comps) ?? date
}

private func isLangwith(_ name: String) -> Bool {
    baseTeamName(from: name) == "Langwith"
}


// MARK: - FixturesView

struct FixturesView: View {
    @StateObject private var viewModel = FixtureViewModel()
    @State private var selectedTeam: LangwithTeam? = nil
    @State private var visibleCount: Int = 6
    @State private var processedFixtures: [DisplayFixture] = []

    private var displayedFixtures: [DisplayFixture] { processedFixtures }

    private func recomputeFixtures() {
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
        let sorted = leftFiltered.sorted {
            mergedDateTime($0.fixture.date, $0.fixture.time) < mergedDateTime($1.fixture.date, $1.fixture.time)
        }

        processedFixtures = sorted
        visibleCount = min(6, sorted.count)
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
                let fixtures = displayedFixtures
                let limited = Array(fixtures.prefix(visibleCount))
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(limited) { df in
                            FixtureCard(fixture: df.fixture)
                        }
                        if fixtures.count > visibleCount {
                            Button(action: {
                                visibleCount = min(visibleCount + 6, fixtures.count)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("View more")
                                }
                                .font(.subheadline)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.accentColor)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 24)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .onAppear { viewModel.fetchFixtures() }
        .onChange(of: selectedTeam) {
            recomputeFixtures()
        }
        .onChange(of: viewModel.fixtures) {
            recomputeFixtures()
        }
    }

    // MARK: - Date formatting helpers

    private func formattedDateTime(date: Date, time: Date) -> String {
        // Combine as UTC, then present in user's local timezone (BST when applicable)
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(secondsFromGMT: 0)!
        let d = utcCal.dateComponents([.year, .month, .day], from: date)
        let t = utcCal.dateComponents([.hour, .minute, .second], from: time)
        var merged = Date()
        if let y = d.year, let m = d.month, let day = d.day,
           let h = t.hour, let min = t.minute, let s = t.second {
            var comps = DateComponents()
            comps.timeZone = TimeZone(secondsFromGMT: 0)
            comps.year = y; comps.month = m; comps.day = day
            comps.hour = h; comps.minute = min; comps.second = s
            merged = utcCal.date(from: comps) ?? date
        } else {
            merged = date
        }
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = .current
        // Example: Wed 1 Oct, 3:30 PM
        formatter.dateFormat = "EEE d MMM, h:mm a"
        return formatter.string(from: merged)
    }
}

// MARK: - Preview

#Preview {
    FixturesView()
}

