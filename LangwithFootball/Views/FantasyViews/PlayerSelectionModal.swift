//
//  PlayerSelectionModal.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI

struct PlayerSelectionModal: View {
    let players: [Player]
    let position: String
    let isPlayerSelected: (Int) -> Bool
    let onPlayerSelect: (Int) -> Void
    let onDismiss: () -> Void
    
    @State private var searchText = ""
    
    private var filteredPlayers: [Player] {
        let positionType = position.components(separatedBy: "-").first ?? position
        let playersForPosition = players.filter { $0.position == positionType }
        
        if searchText.isEmpty {
            return playersForPosition.sorted { ($0.price ?? 0) > ($1.price ?? 0) }
        } else {
            return playersForPosition.filter { player in
                player.name.localizedCaseInsensitiveContains(searchText)
            }.sorted { ($0.price ?? 0) > ($1.price ?? 0) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search players...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                
                // Players list
                if filteredPlayers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.slash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No players found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try a different search term or check if players are loaded")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredPlayers) { player in
                        PlayerSelectionRow(
                            player: player,
                            isSelected: isPlayerSelected(player.id),
                            onSelect: {
                                onPlayerSelect(player.id)
                            }
                        )
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Select \(position)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

private struct PlayerSelectionRow: View {
    let player: Player
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Player icon
            Image(player.position == "Goalkeeper" ? "PlayerIconGK" : "PlayerIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(player.position)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let team = player.team {
                        Text("• \(team)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    if let price = player.price {
                        Text("£\(String(format: "%.1f", price))m")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.blue)
                    }
                    
                    Text("\(player.points) pts")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            } else {
                Button("Select") {
                    onSelect()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isSelected {
                onSelect()
            }
        }
    }
}

#Preview {
    PlayerSelectionModal(
        players: [
            Player(
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
            Player(
                id: 2,
                name: "Jane Smith",
                position: "Midfielder",
                team: "Halifax",
                goals: 3,
                assists: 7,
                yellowCards: 0,
                redCards: 0,
                cleanSheets: 0,
                gamesPlayed: 10,
                price: 7.0,
                points: 38,
                motm: 1,
                penSaves: 0
            )
        ],
        position: "Midfielder-1",
        isPlayerSelected: { _ in false },
        onPlayerSelect: { _ in },
        onDismiss: {}
    )
}
