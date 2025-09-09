//
//  FantasyView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 27/05/2025.
//

import SwiftUI

struct FantasyView: View {
    @StateObject private var viewModel = TeamSnapshotViewModel()
    @State private var showingTransferView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let snapshot = viewModel.snapshots.sorted(by: { $0.snapshotDate > $1.snapshotDate }).first {
                CurrentTeamSnapshotCard(
                    teamName: snapshot.team.name,
                    weeklyPoints: snapshot.weeklyPoints,
                    gameWeek: snapshot.gameWeek.week
                )

                FormationView(
                    players: snapshot.players,
                    playerWeeklyPoints: Dictionary(uniqueKeysWithValues: snapshot.players.map { ($0.id, $0.points) })
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                
                // Transfers Button
                Button(action: {
                    showingTransferView = true
                }) {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.title2)
                        Text("Make Transfers")
                            .font(.headline.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.title3)
                    .padding(.vertical, 8)
            } else {
                ProgressView("Loading current team…")
                    .font(.title3)
            }
        }
        .padding()
        .onAppear { viewModel.fetchTeamSnapshots() }
        .sheet(isPresented: $showingTransferView) {
            TransferView()
        }
    }
}

private struct CurrentTeamSnapshotCard: View {
    let teamName: String
    let weeklyPoints: Int
    let gameWeek: Int

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
                
                Text("Game Week \(gameWeek)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))

                HStack(spacing: 10) {
                    Text("This Week")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))

                    Text("\(weeklyPoints)")
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
                        .accessibilityLabel("This week points \(weeklyPoints)")
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
    FantasyView()
}

