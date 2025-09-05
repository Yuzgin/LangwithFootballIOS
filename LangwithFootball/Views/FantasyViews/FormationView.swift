//
//  FormationView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 29/05/2025.
//

import SwiftUI

struct FormationView: View {
    let players: [Player]

    var groupedPlayers: [String: [Player]] {
        Dictionary(grouping: players, by: { $0.position })
    }

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                Image("Pitch")
                    .resizable()
                    .interpolation(.low) // cheaper scaling for the big background
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(20)
                    .allowsHitTesting(false) // avoids unnecessary event processing

                // LazyVStack renders only visible rows (we only have a few, but it's still cheaper)
                LazyVStack(spacing: 30, pinnedViews: []) {
                    ForEach(orderedPositions, id: \.self) { position in
                        if let playersForPosition = groupedPlayers[position] {
                            // LazyHStack is helpful if a row gets long (e.g., 5 forwards in drafts)
                            LazyHStack(spacing: 4) {
                                ForEach(playersForPosition) { player in
                                    PlayerIconView(player: player)
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

