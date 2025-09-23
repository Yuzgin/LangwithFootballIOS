//
//  FormationView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 29/05/2025.
//

import SwiftUI

struct FormationView: View {
    let players: [Player]
    let playerWeeklyPoints: [Int: Int]?
    let showSplitInfo: Bool
    let metric: PlayerInfoMetric
    let captain: Player?

    init(
        players: [Player],
        playerWeeklyPoints: [Int: Int]? = nil,
        showSplitInfo: Bool = true,
        metric: PlayerInfoMetric = .points,
        captain: Player? = nil
    ) {
        self.players = players
        self.playerWeeklyPoints = playerWeeklyPoints
        self.showSplitInfo = showSplitInfo
        self.metric = metric
        self.captain = captain
    }

    var groupedPlayers: [String: [Player]] {
        Dictionary(grouping: players, by: { $0.position })
    }

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                Image("Pitch")
                    .resizable()
                    .interpolation(.low)
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(20)
                    .allowsHitTesting(false)

                LazyVStack(spacing: 25, pinnedViews: []) {
                    ForEach(orderedPositions, id: \.self) { position in
                        if let playersForPosition = groupedPlayers[position] {
                            LazyHStack(spacing: spacingForPlayerCount(playersForPosition.count)) {
                                ForEach(playersForPosition) { player in
                                    PlayerIconView(
                                        player: player,
                                        weeklyPoints: playerWeeklyPoints?[player.id],
                                        showSplitInfo: showSplitInfo,
                                        metric: metric,
                                        captain: captain
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.black.opacity(0.05))
    }

    private var orderedPositions: [String] {
        ["Attacker", "Midfielder", "Defender", "Goalkeeper"]
    }
    
    private func spacingForPlayerCount(_ count: Int) -> CGFloat {
        FormationSpacingUtility.spacingForPlayerCount(count)
    }
}

// MARK: - Formation Spacing Utility
struct FormationSpacingUtility {
    /// Calculates appropriate spacing between player icons based on the number of players in a row
    /// - Parameter count: Number of player icons in the row
    /// - Returns: Spacing value in points
    static func spacingForPlayerCount(_ count: Int) -> CGFloat {
        switch count {
        case 1:
            return 0 // Single player, no spacing needed
        case 2:
            return 20 // Two players, generous spacing
        case 3:
            return 14 // Three players, good spacing
        case 4:
            return 10 // Four players, moderate spacing
        case 5:
            return 4  // Five players, tight spacing
        case 6:
            return 2  // Six players, very tight spacing
        default:
            return 17 // Default spacing for other cases (fallback)
        }
    }
    
    /// Calculates spacing for a specific position group with additional players
    /// - Parameters:
    ///   - baseCount: Number of base players in the formation
    ///   - additionalCount: Number of additional players (0 or 1)
    /// - Returns: Spacing value in points
    static func spacingForPositionGroup(baseCount: Int, additionalCount: Int = 0) -> CGFloat {
        let totalCount = baseCount + additionalCount
        return spacingForPlayerCount(totalCount)
    }
}

