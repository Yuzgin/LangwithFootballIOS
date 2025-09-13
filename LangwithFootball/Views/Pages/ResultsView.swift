//
//  ResultsView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 27/05/2025.
//

import SwiftUI
import Foundation
import UIKit   // for UIImage(named:) asset existence check




// MARK: - Results View

struct ResultsView: View {
    @StateObject private var viewModel = MatchViewModel()
    @State private var selectedTeam: LangwithTeam? = nil

    private var filteredMatches: [Match] {
        guard let team = selectedTeam?.rawValue else { return viewModel.matches }
        return viewModel.matches.filter { $0.team1 == team }
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
            } else if viewModel.hasLoaded && filteredMatches.isEmpty {
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
                VStack(spacing: 0) {
                    ForEach(filteredMatches) { match in
                        ResultCard(match: match)
                    }
                }
                .padding(.top, 8)
            }
        }
        .onAppear { viewModel.fetchMatches() }
    }

}

// MARK: - Preview

#Preview {
    ResultsView()
}

