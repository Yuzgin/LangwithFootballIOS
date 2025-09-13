//
//  TopTeamView.swift
//  LangwithFootball
//
//  Created by Assistant on 27/05/2025.
//

import SwiftUI

struct TopTeamView: View {
    let gameWeek: Int
    
    @StateObject private var teamSnapshotViewModel = TeamSnapshotViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            if let highestTeam = getHighestScoringTeam(for: gameWeek) {
                Text("Highest")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
                        )
                    Text("\(highestTeam.weeklyPoints)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }
            } else {
                Text("No Data")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
                        )
                    Text("-")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .onAppear {
            teamSnapshotViewModel.fetchTeamSnapshots()
        }
    }
    
    private func getHighestScoringTeam(for gameWeek: Int) -> TeamSnapshot? {
        let snapshotsForWeek = teamSnapshotViewModel.snapshots.filter { $0.gameWeek.week == gameWeek }
        return snapshotsForWeek.max(by: { $0.weeklyPoints < $1.weeklyPoints })
    }
}

#Preview {
    TopTeamView(
        gameWeek: 1
    )
}
