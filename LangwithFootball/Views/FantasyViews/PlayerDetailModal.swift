//
//  PlayerDetailModal.swift
//  LangwithFootball
//
//  Created by Assistant on 27/05/2025.
//

import SwiftUI

struct PlayerDetailModal: View {
    let player: Player
    let weeklyPoints: Int?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with player image and basic info
                    PlayerDetailHeader(player: player, weeklyPoints: weeklyPoints)
                    
                    // Stats grid
                    PlayerStatsGrid(player: player, weeklyPoints: weeklyPoints)
                    
                    // Additional info
                    PlayerAdditionalInfo(player: player)
                }
                .padding()
            }
            .navigationTitle(player.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct PlayerDetailHeader: View {
    let player: Player
    let weeklyPoints: Int?
    
    var body: some View {
        VStack(spacing: 16) {
            // Player image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(player.position == "Goalkeeper" ? "PlayerIconGK" : "PlayerIcon")
                    .resizable()
                    .interpolation(.low)
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
            
            // Player name and position
            VStack(spacing: 4) {
                Text(player.name)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text(player.position)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                if let team = player.team {
                    Text(team)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray5))
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

private struct PlayerStatsGrid: View {
    let player: Player
    let weeklyPoints: Int?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline.weight(.semibold))
            
            LazyVGrid(columns: columns, spacing: 12) {
                StatCard(
                    title: "Total Points",
                    value: "\(player.points)",
                    icon: "star.fill",
                    color: .orange
                )
                
                if let weeklyPoints = weeklyPoints {
                    StatCard(
                        title: "This Week",
                        value: "\(weeklyPoints)",
                        icon: "calendar",
                        color: .blue
                    )
                }
                
                StatCard(
                    title: "Games Played",
                    value: "\(player.gamesPlayed)",
                    icon: "gamecontroller.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Goals",
                    value: "\(player.goals)",
                    icon: "sportscourt.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Assists",
                    value: "\(player.assists)",
                    icon: "person.2.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "Clean Sheets",
                    value: "\(player.cleanSheets)",
                    icon: "shield.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "MOTM",
                    value: "\(player.motm)",
                    icon: "crown.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Yellow Cards",
                    value: "\(player.yellowCards)",
                    icon: "exclamationmark.triangle.fill",
                    color: .yellow
                )
                
                if player.redCards > 0 {
                    StatCard(
                        title: "Red Cards",
                        value: "\(player.redCards)",
                        icon: "xmark.circle.fill",
                        color: .red
                    )
                }
                
                if player.penSaves > 0 {
                    StatCard(
                        title: "Pen Saves",
                        value: "\(player.penSaves)",
                        icon: "hand.raised.fill",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

private struct PlayerAdditionalInfo: View {
    let player: Player
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Information")
                .font(.headline.weight(.semibold))
            
            VStack(spacing: 12) {
                if let price = player.price {
                    InfoRow(
                        icon: "dollarsign.circle.fill",
                        title: "Price",
                        value: "£\(String(format: "%.1f", price))m",
                        color: .green
                    )
                }
                
                InfoRow(
                    icon: "percent",
                    title: "Points per Game",
                    value: String(format: "%.1f", player.gamesPlayed > 0 ? Double(player.points) / Double(player.gamesPlayed) : 0.0),
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline.weight(.medium))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    PlayerDetailModal(
        player: Player(
            id: 1,
            name: "John Smith",
            position: "Midfielder",
            team: "Langwith FC",
            goals: 8,
            assists: 12,
            yellowCards: 2,
            redCards: 0,
            cleanSheets: 0,
            gamesPlayed: 15,
            price: 12.5,
            points: 89,
            motm: 3,
            penSaves: 0
        ),
        weeklyPoints: 8
    )
}
