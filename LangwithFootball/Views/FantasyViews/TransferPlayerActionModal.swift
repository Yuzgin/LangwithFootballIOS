//
//  TransferPlayerActionModal.swift
//  LangwithFootball
//
//  Created by Assistant on 27/05/2025.
//

import SwiftUI

struct TransferPlayerActionModal: View {
    let player: Player
    let position: String
    let onRemovePlayer: () -> Void
    let onSelectReplacement: () -> Void
    let onMakeCaptain: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Player header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(player.position == "Goalkeeper" ? "PlayerIconGK" : "PlayerIcon")
                            .resizable()
                            .interpolation(.low)
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    
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
                
                // Action buttons
                VStack(spacing: 12) {
                    Text("What would you like to do with this player?")
                        .font(.headline.weight(.medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        // Remove Player Button
                        Button(action: {
                            onRemovePlayer()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.title3)
                                Text("Remove Player")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red)
                            )
                        }
                        
                        // Select Replacement Button
                        Button(action: {
                            onSelectReplacement()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.title3)
                                Text("Select Replacement")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                        }

                        // Make Captain Button
                        if let onMakeCaptain {
                            Button(action: {
                                onMakeCaptain()
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "c.circle.fill")
                                        .font(.title3)
                                    Text("Make Captain")
                                        .font(.headline.weight(.semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black)
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Player Actions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TransferPlayerActionModal(
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
        position: "Midfielder-1",
        onRemovePlayer: {},
        onSelectReplacement: {},
        onMakeCaptain: {}
    )
}
