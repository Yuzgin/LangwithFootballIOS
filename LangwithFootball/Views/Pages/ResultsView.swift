//
//  ResultsView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 27/05/2025.
//

import SwiftUI
import Foundation
import UIKit   // for UIImage(named:) asset existence check

private struct DisplayMatch: Identifiable {
    let id: String
    let left: String
    let right: String
    let match: Match
    let isSwapped: Bool
}
// MARK: - Results View

struct ResultsView: View {
    @StateObject private var viewModel = MatchViewModel()
    @State private var selectedTeam: LangwithTeam? = nil
    @State private var visibleCount: Int = 6
    @State private var processedMatches: [DisplayMatch] = []

    private var displayedMatches: [DisplayMatch] { processedMatches }

    private func recomputeMatches() {
        // Normalize sides to keep Langwith (if any) on the left
        let expanded: [DisplayMatch] = viewModel.matches.flatMap { m in
            let aIs = baseTeamName(from: m.team1) == "Langwith"
            let bIs = baseTeamName(from: m.team2) == "Langwith"

            if aIs && bIs {
                return [
                    DisplayMatch(id: "\(m.id)-A", left: m.team1, right: m.team2, match: m, isSwapped: false),
                    DisplayMatch(id: "\(m.id)-B", left: m.team2, right: m.team1, match: m, isSwapped: true)
                ]
            } else {
                let sides = normalizeSides(team1: m.team1, team2: m.team2)
                let swapped = (sides.left != m.team1)
                return [
                    DisplayMatch(id: "\(m.id)", left: sides.left, right: sides.right, match: m, isSwapped: swapped)
                ]
            }
        }

        // Apply filter only to the left side
        let leftFiltered: [DisplayMatch]
        if let team = selectedTeam?.rawValue {
            leftFiltered = expanded.filter { $0.left == team }
        } else {
            leftFiltered = expanded
        }

        processedMatches = leftFiltered
        visibleCount = min(6, leftFiltered.count)
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
                    Text("Loading results...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
            } else if viewModel.hasLoaded && displayedMatches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("No results available")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Check back later for match results")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
            } else {
                // Results content
                let matches = displayedMatches
                let limited = Array(matches.prefix(visibleCount))
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(limited) { dm in
                            // Build a display-only match with sides swapped if needed
                            let m = dm.match
                            let displayMatch: Match = dm.isSwapped ?
                                Match(id: m.id, date: m.date, team1: dm.left, team2: dm.right, team1Score: m.team2Score, team2Score: m.team1Score, gameWeek: m.gameWeek) :
                                Match(id: m.id, date: m.date, team1: dm.left, team2: dm.right, team1Score: m.team1Score, team2Score: m.team2Score, gameWeek: m.gameWeek)
                            ResultCard(match: displayMatch)
                        }
                        if matches.count > visibleCount {
                            Button(action: {
                                visibleCount = min(visibleCount + 6, matches.count)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle-fill")
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
        .onAppear { viewModel.fetchMatches() }
        .onChange(of: selectedTeam) {
            recomputeMatches()
        }
        .onChange(of: viewModel.matches) {
            recomputeMatches()
        }
    }

}

// MARK: - Preview

#Preview {
    ResultsView()
}

