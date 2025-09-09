//
//  TransferView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 27/05/2025.
//

import SwiftUI

struct TransferView: View {
    @StateObject private var viewModel = FantasyViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let team = viewModel.team {
                TeamInfoCard(teamName: team.name, totalPoints: team.totalPoints)

                FormationView(players: team.players, showSplitInfo: true, metric: .price)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.title3)
                    .padding(.vertical, 8)
            } else {
                ProgressView("Loading team…")
                    .font(.title3)
            }
        }
        .padding()
        .onAppear { viewModel.fetchTeam() }
    }
}

private struct TeamInfoCard: View {
    let teamName: String
    let totalPoints: Int

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .strokeBorder(.white.opacity(0.25), lineWidth: 2)
                    )
                Image(systemName: "shield.lefthalf.filled")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 3)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(teamName)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                HStack(spacing: 10) {
                    Text("Total Points")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))

                    Text("\(totalPoints)")
                        .font(.headline.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(.white.opacity(0.18))
                        )
                        .overlay(
                            Capsule().stroke(.white.opacity(0.25), lineWidth: 1)
                        )
                        .foregroundStyle(.white)
                        .accessibilityLabel("Total points \(totalPoints)")
                }
            }

            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.9),
                            Color.orange.opacity(0.85),
                            Color.red.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TransferView()
}
