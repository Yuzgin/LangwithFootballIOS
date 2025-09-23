//
//  TeamPlayerIconView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI

enum TeamPlayerIconContext {
    case createTeam
    case transfer
    case fantasy
}

struct TeamPlayerIconView: View {
    let position: String
    let selectedPlayer: Player?
    let onTap: () -> Void
    let onDeselect: () -> Void
    let context: TeamPlayerIconContext
    let isCaptain: Bool
    let onMakeCaptain: (() -> Void)?
    @State private var showingPlayerDetail = false
    @State private var showingTransferAction = false
    
    init(
        position: String,
        selectedPlayer: Player?,
        onTap: @escaping () -> Void,
        onDeselect: @escaping () -> Void,
        context: TeamPlayerIconContext = .createTeam,
        isCaptain: Bool = false,
        onMakeCaptain: (() -> Void)? = nil
    ) {
        self.position = position
        self.selectedPlayer = selectedPlayer
        self.onTap = onTap
        self.onDeselect = onDeselect
        self.context = context
        self.isCaptain = isCaptain
        self.onMakeCaptain = onMakeCaptain
    }
    
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
                        .opacity(0.95)
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

            // Captain badge (top-left)
            if isCaptain {
                VStack {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 18, height: 18)
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
        .accessibilityLabel(selectedPlayer?.name ?? "\(position) position")
        .onTapGesture {
            if selectedPlayer != nil {
                switch context {
                case .transfer, .createTeam:
                    showingTransferAction = true
                case .fantasy:
                    showingPlayerDetail = true
                }
            } else {
                onTap()
            }
        }
        .sheet(isPresented: $showingPlayerDetail) {
            if let player = selectedPlayer {
                PlayerDetailModal(player: player, weeklyPoints: nil)
            }
        }
        .sheet(isPresented: $showingTransferAction) {
            if let player = selectedPlayer {
                TransferPlayerActionModal(
                    player: player,
                    position: position,
                    onRemovePlayer: {
                        onDeselect()
                    },
                    onSelectReplacement: {
                        onTap()
                    },
                    onMakeCaptain: onMakeCaptain
                )
            }
        }
    }
}

private struct TeamPlayerInfoCard: View {
    let position: String
    let player: Player?
    let onTap: () -> Void
    let onDeselect: () -> Void
    
    private var positionAbbreviation: String {
        if position.hasPrefix("Attacker") {
            return "ATT"
        } else if position.hasPrefix("Midfielder") {
            return "MID"
        } else if position.hasPrefix("Defender") {
            return "DEF"
        } else if position.hasPrefix("Goalkeeper") {
            return "GK"
        }
        return position
    }
    
    var body: some View {
        Group {
            if let player = player {
                // Player selected - show player info with deselect option (matching PlayerInfoCard style)
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
                // No player selected - show position abbreviation and + (matching PlayerInfoCard style)
                VStack(spacing: 0) {
                    Text(positionAbbreviation)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 6)
                        .background(Color.white)
                    
                    Text("+")
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
            onDeselect: {},
            context: .createTeam,
            isCaptain: false
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
            onDeselect: {},
            context: .createTeam,
            isCaptain: true
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
