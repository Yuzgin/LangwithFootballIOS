//
//  TopTeamView.swift
//  LangwithFootball
//
//  Created by AI Assistant on 10/09/2025.
//

import SwiftUI
import Foundation
import Combine

struct TopTeamSheetView: View {
    let gameWeek: Int
    let allSnapshots: [TeamSnapshot]
    let playerGameStats: [PlayerGameStats]
    
    private var topSnapshot: TeamSnapshot? {
        let snapshotsForWeek = allSnapshots.filter { $0.gameWeek.week == gameWeek }
        return snapshotsForWeek.max(by: { $0.weeklyPoints < $1.weeklyPoints })
    }
    
    private func getWeeklyPointsForSnapshot(_ snapshot: TeamSnapshot) -> [Int: Int] {
        let gameWeekId = snapshot.gameWeek.id
        
        // Filter game stats to only include those for the selected gameweek
        let filteredStats = playerGameStats.filter { stat in
            stat.match.gameWeek == gameWeekId
        }
        
        // Group stats by player ID and sum up points for each player
        var weeklyPoints: [Int: Int] = [:]
        
        for stat in filteredStats {
            let playerId = stat.player.id
            weeklyPoints[playerId, default: 0] += stat.points
        }
        
        // For players in the snapshot who don't have game stats for this week, set points to 0
        for player in snapshot.players {
            if weeklyPoints[player.id] == nil {
                weeklyPoints[player.id] = 0
            }
        }
        
        return weeklyPoints
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let topSnapshot = topSnapshot {
                // Highest Team Card
                HighestTeamCard(
                    teamName: topSnapshot.team.name,
                    weeklyPoints: topSnapshot.weeklyPoints,
                    gameWeek: topSnapshot.gameWeek.week,
                    allSnapshots: allSnapshots
                )
                
                // Formation View
                FormationView(
                    players: topSnapshot.players,
                    playerWeeklyPoints: getWeeklyPointsForSnapshot(topSnapshot)
                )
                .transition(.opacity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No data available")
                        .font(.headline)
                    Text("No highest team found for Gameweek \(gameWeek)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .presentationDetents([.large])
    }
}

// MARK: - HighestTeamCard
private struct HighestTeamCard: View {
    let teamName: String
    let weeklyPoints: Int
    let gameWeek: Int
    let allSnapshots: [TeamSnapshot]
    
    private var averagePoints: Double {
        let snapshotsForWeek = allSnapshots.filter { $0.gameWeek.week == gameWeek }
        guard !snapshotsForWeek.isEmpty else { return 0.0 }
        
        let totalPoints = snapshotsForWeek.reduce(0) { $0 + $1.weeklyPoints }
        return Double(totalPoints) / Double(snapshotsForWeek.count)
    }
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Team name and gameweek at the top
            VStack(alignment: .center, spacing: 12) {
                Text(teamName)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                
                Text("Gameweek \(gameWeek)")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            HStack(spacing: 25) {
                // Average Points (Left)
                VStack(alignment: .center, spacing: 4) {
                    Text("Avg Points")
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
                        Text("\(Int(averagePoints.rounded()))")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
                
                // Highest Team Points (Center)
                VStack(alignment: .center, spacing: 4) {
                    Text("Points")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white.opacity(0.25), lineWidth: 2)
                            )
                        Text("\(weeklyPoints)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .accessibilityLabel("Points \(weeklyPoints)")
                    }
                }
                
                Spacer()
                
                // Highest (Right)
                VStack(alignment: .center, spacing: 4) {
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
                        Text("\(weeklyPoints)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.9),
                            Color.purple.opacity(0.85),
                            Color.pink.opacity(0.8)
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
    TopTeamSheetView(
        gameWeek: 1,
        allSnapshots: [],
        playerGameStats: []
    )
}
