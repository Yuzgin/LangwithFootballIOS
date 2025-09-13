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
                
                // Table header
                HStack(spacing: 0) {
                    Text("Name")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    
                    Text("Price")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 60, alignment: .center)
                        .padding(.vertical, 10)
                    
                    Text("Pts")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 50, alignment: .center)
                        .padding(.vertical, 10)
                    
                    Text("G")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 40, alignment: .center)
                        .padding(.vertical, 10)
                    
                    Text("A")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 40, alignment: .center)
                        .padding(.vertical, 10)
                    
                    Text("CS")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 40, alignment: .center)
                        .padding(.vertical, 10)
                }
                .background(Color.gray.opacity(0.1))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3)),
                    alignment: .bottom
                )
                
                // Players table
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
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredPlayers) { player in
                                PlayerSelectionRow(
                                    player: player,
                                    isSelected: isPlayerSelected(player.id),
                                    onSelect: {
                                        onPlayerSelect(player.id)
                                    }
                                )
                                
                                if player.id != filteredPlayers.last?.id {
                                    Divider()
                                        .background(Color.gray.opacity(0.2))
                                }
                            }
                        }
                    }
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
        HStack(spacing: 0) {
            // Name column
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(player.position)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            // Price column
            if let price = player.price {
                Text("£\(String(format: "%.1f", price))")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.blue)
                    .frame(width: 60, alignment: .center)
                    .padding(.vertical, 10)
            } else {
                Text("-")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .center)
                    .padding(.vertical, 10)
            }
            
            // Points column
            Text("\(player.points)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .center)
                .padding(.vertical, 10)
            
            // Goals column
            Text("\(player.goals)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
                .frame(width: 40, alignment: .center)
                .padding(.vertical, 10)
            
            // Assists column
            Text("\(player.assists)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
                .frame(width: 40, alignment: .center)
                .padding(.vertical, 10)
            
            // Clean Sheets column
            Text("\(player.cleanSheets)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
                .frame(width: 40, alignment: .center)
                .padding(.vertical, 10)
        }
        .background(isSelected ? Color.green.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
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
