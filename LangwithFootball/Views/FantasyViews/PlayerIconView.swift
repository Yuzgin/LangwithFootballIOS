//
//  PlayerIconView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 29/05/2025.
//

import SwiftUI

enum PlayerInfoMetric {
    case points
    case price
}

struct PlayerIconView: View {
    let player: Player
    let weeklyPoints: Int?
    let showSplitInfo: Bool
    let metric: PlayerInfoMetric
    let captain: Player?
    @State private var showingPlayerDetail = false

    init(
        player: Player,
        weeklyPoints: Int? = nil,
        showSplitInfo: Bool = true,
        metric: PlayerInfoMetric = .points,
        captain: Player? = nil
    ) {
        self.player = player
        self.weeklyPoints = weeklyPoints
        self.showSplitInfo = showSplitInfo
        self.metric = metric
        self.captain = captain
    }

    private var isCaptain: Bool {
        captain?.id == player.id
    }
    
    private var displayPoints: Int? {
        guard let points = weeklyPoints else { return nil }
        return isCaptain ? points * 2 : points
    }
    
    private var splitBottomText: String? {
        switch metric {
        case .points:
            return displayPoints.map { "\($0) pts" }
        case .price:
            if let price = player.price {
                let formatted = String(format: "£%.1f", price)
                return formatted
            } else {
                return nil
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main card background
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.4))

            VStack(spacing: 0) {
                Image(player.position == "Goalkeeper" ? "PlayerIconGK" : "PlayerIcon")
                    .resizable()
                    .interpolation(.low)
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .padding(.top, 6)

                Spacer()
            }
            .padding(.horizontal, 4)

            // Bottom-anchored info card, slightly raised to overlap the image
            PlayerInfoCard(
                name: player.name,
                bottomText: splitBottomText,
                split: showSplitInfo
            )
            .frame(width: 63)
            .padding(.bottom, 1)
            .offset(y: 0)
            
            // Captain indicator
            if isCaptain {
                VStack {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 20, height: 20)
                            
                            Text("C")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 2)
                        .padding(.leading, 2)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .frame(width: 65, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(player.name)
        .onTapGesture {
            showingPlayerDetail = true
        }
        .sheet(isPresented: $showingPlayerDetail) {
            PlayerDetailModal(player: player, weeklyPoints: weeklyPoints)
        }
    }
}

private struct PlayerInfoCard: View {
    let name: String
    let bottomText: String?
    let split: Bool

    var body: some View {
        Group {
            if split, let bottomText {
                // Two-band 50:50 split
                VStack(spacing: 0) {
                    Text(name)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 6)
                        .background(Color.white)

                    Text(bottomText)
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 6)
                        .background(Color.black)
                }
                .frame(height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
            } else {
                VStack(spacing: 3) {
                    Text(name)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 72)

                    if let bottomText {
                        Text(bottomText)
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(
                                Capsule()
                                    .fill(Color.black)
                            )
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
            }
        }
    }
}

