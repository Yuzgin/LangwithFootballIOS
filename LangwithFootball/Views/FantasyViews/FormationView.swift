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

    init(
        players: [Player],
        playerWeeklyPoints: [Int: Int]? = nil,
        showSplitInfo: Bool = true,
        metric: PlayerInfoMetric = .points
    ) {
        self.players = players
        self.playerWeeklyPoints = playerWeeklyPoints
        self.showSplitInfo = showSplitInfo
        self.metric = metric
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
                            LazyHStack(spacing: 4) {
                                ForEach(playersForPosition) { player in
                                    PlayerIconView(
                                        player: player,
                                        weeklyPoints: playerWeeklyPoints?[player.id],
                                        showSplitInfo: showSplitInfo,
                                        metric: metric
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.bottom, 60)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.black.opacity(0.05))
        .edgesIgnoringSafeArea(.bottom)
    }

    private var orderedPositions: [String] {
        ["Attacker", "Midfielder", "Defender", "Goalkeeper"]
    }
}

