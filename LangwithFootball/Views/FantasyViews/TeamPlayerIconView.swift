//
//  TeamPlayerIconView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI

struct TeamPlayerIconView: View {
    let position: String
    let selectedPlayer: Player?
    let onTap: () -> Void
    let onDeselect: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main card background
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.4))
            
            VStack(spacing: 0) {
                // Player icon or placeholder
                if let player = selectedPlayer {
                    Image(player.position == "Goalkeeper" ? "PlayerIconGK" : "PlayerIcon")
                        .resizable()
                        .interpolation(.low)
                        .scaledToFit()
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                        .padding(.top, 6)
                } else {
                    // Unselected player placeholder
                    Image("UnselectedPlayer") // You'll need to add this image to Assets.xcassets
                        .resizable()
                        .interpolation(.low)
                        .scaledToFit()
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                        .padding(.top, 6)
                        .opacity(0.8)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // Bottom-anchored info card
            TeamPlayerInfoCard(
                position: position,
                player: selectedPlayer,
                onTap: onTap,
                onDeselect: onDeselect
            )
            .frame(width: 63)
            .padding(.bottom, 1)
            .offset(y: 0)
        }
        .frame(width: 65, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(selectedPlayer?.name ?? "\(position) position")
    }
}

private struct TeamPlayerInfoCard: View {
    let position: String
    let player: Player?
    let onTap: () -> Void
    let onDeselect: () -> Void
    
    var body: some View {
        Group {
            if let player = player {
                // Player selected - show player info with deselect option
                VStack(spacing: 0) {
                    Text(player.name)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 6)
                        .background(Color.white)
                    
                    HStack(spacing: 4) {
                        if let price = player.price {
                            Text("£\(String(format: "%.1f", price))")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: onDeselect) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 6)
                    .background(Color.black)
                }
                .frame(height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
            } else {
                // No player selected - show position with tap to select
                VStack(spacing: 3) {
                    Text(position)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 72)
                    
                    Text("Tap to select")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .lineLimit(1)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                .onTapGesture {
                    onTap()
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Unselected player
        TeamPlayerIconView(
            position: "Defender-1",
            selectedPlayer: nil,
            onTap: {},
            onDeselect: {}
        )
        
        // Selected player
        TeamPlayerIconView(
            position: "Midfielder-1",
            selectedPlayer: Player(
                id: 1,
                name: "John Doe",
                position: "Midfielder",
                team: "Langwith",
                goals: 5,
                assists: 3,
                yellowCards: 1,
                redCards: 0,
                cleanSheets: 0,
                gamesPlayed: 10,
                price: 8.5,
                points: 45,
                motm: 2,
                penSaves: 0
            ),
            onTap: {},
            onDeselect: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
