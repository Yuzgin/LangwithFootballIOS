//
//  CreateTeamView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI

struct CreateTeamView: View {
    @EnvironmentObject var viewModel: CreateTeamViewModel
    @State private var selectedPosition: String? = nil
    @State private var showingSuccessAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header card
            CreateTeamHeaderCard(
                teamName: $viewModel.teamName,
                budget: viewModel.budget
            )
            
                // Formation view
                CreateTeamFormationView(
                    viewModel: viewModel,
                    onPlayerTap: { position in
                        selectedPosition = position
                    }
                )
            
            // Captain instruction when only captain selection remains
            if viewModel.needsCaptainSelection {
                VStack(spacing: 4) {
                    Text("Select a captain to finish your team.")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Tip: click on a player to select captain")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }

                // Controls
                CreateTeamControls(
                    canCreateTeam: viewModel.canCreateTeam(),
                    onCreateTeam: {
                        viewModel.createTeam()
                    }
                )
            
            
            // Selected players summary
            if !viewModel.selectedPlayers.isEmpty {
                SelectedPlayersSummary(viewModel: viewModel)
            }
        }
        .sheet(isPresented: Binding<Bool>(
            get: { selectedPosition != nil },
            set: { if !$0 { selectedPosition = nil } }
        )) {
            if let position = selectedPosition {
                PlayerSelectionModal(
                    players: viewModel.players,
                    position: position,
                    isPlayerSelected: viewModel.isPlayerSelected,
                    onPlayerSelect: { playerId in
                        viewModel.selectPlayer(playerId: playerId, for: position)
                        selectedPosition = nil
                    },
                    onDismiss: {
                        selectedPosition = nil
                    }
                )
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading players...")
                    .font(.title3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
            }
        }
    }
}

private struct CreateTeamHeaderCard: View {
    @Binding var teamName: String
    let budget: Double
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Create Team")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                
                // Team name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Team Name")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter team name", text: $teamName)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Budget display
                HStack {
                    Text("Budget Remaining:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("£\(String(format: "%.1f", budget))m")
                        .font(.headline.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(.white.opacity(0.2))
                        )
                        .overlay(
                            Capsule().stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundStyle(.white)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.9),
                            Color.orange.opacity(0.85),
                            Color.red.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

private struct CreateTeamFormationView: View {
    @ObservedObject var viewModel: CreateTeamViewModel
    let onPlayerTap: (String) -> Void
    
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
                    // Attackers (top)
                    LazyHStack(spacing: attackerSpacing) {
                        ForEach(Array(viewModel.formationPositions.filter { $0.hasPrefix("Attacker") }.enumerated()), id: \.offset) { index, position in
                            // Only render base slot if team is incomplete or this exact slot is already assigned
                            if viewModel.getSelectedPlayerCount() < 10 || viewModel.getPlayerForPosition(position) != nil {
                                // Skip Attacker-2 if only one attacker is allowed
                                if position == "Attacker-2" && viewModel.onlyOneAttackerAllowed && viewModel.selectedPlayers["Attacker-2"] == nil {
                                    EmptyView()
                                } else {
                                    TeamPlayerIconView(
                                        position: position,
                                        selectedPlayer: viewModel.getPlayerForPosition(position),
                                        onTap: { onPlayerTap(position) },
                                        onDeselect: { viewModel.deselectPlayer(at: position) },
                                        context: .createTeam,
                                        isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition(position)?.id,
                                        onMakeCaptain: {
                                            if let id = viewModel.getPlayerForPosition(position)?.id {
                                                viewModel.setCaptain(playerId: id)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Additional attacker if allowed
                        if viewModel.additionalAttackerAllowed || viewModel.selectedPlayers["Attacker-3"] != nil {
                            TeamPlayerIconView(
                                position: "Attacker-3",
                                selectedPlayer: viewModel.getPlayerForPosition("Attacker-3"),
                                onTap: { onPlayerTap("Attacker-3") },
                                onDeselect: { viewModel.deselectPlayer(at: "Attacker-3") },
                                context: .createTeam,
                                isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition("Attacker-3")?.id,
                                onMakeCaptain: {
                                    if let id = viewModel.getPlayerForPosition("Attacker-3")?.id {
                                        viewModel.setCaptain(playerId: id)
                                    }
                                }
                            )
                        }
                    }
                    
                    // Midfielders
                    LazyHStack(spacing: midfielderSpacing) {
                        ForEach(Array(viewModel.formationPositions.filter { $0.hasPrefix("Midfielder") }.enumerated()), id: \.offset) { index, position in
                            if viewModel.getSelectedPlayerCount() < 10 || viewModel.getPlayerForPosition(position) != nil {
                            TeamPlayerIconView(
                                position: position,
                                selectedPlayer: viewModel.getPlayerForPosition(position),
                                onTap: { onPlayerTap(position) },
                                onDeselect: { viewModel.deselectPlayer(at: position) },
                                context: .createTeam,
                                isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition(position)?.id,
                                onMakeCaptain: {
                                    if let id = viewModel.getPlayerForPosition(position)?.id {
                                        viewModel.setCaptain(playerId: id)
                                    }
                                }
                            )
                            }
                        }
                        
                        // Additional midfielder if allowed
                        if viewModel.additionalMidfielderAllowed || viewModel.selectedPlayers["Midfielder-5"] != nil {
                            TeamPlayerIconView(
                                position: "Midfielder-5",
                                selectedPlayer: viewModel.getPlayerForPosition("Midfielder-5"),
                                onTap: { onPlayerTap("Midfielder-5") },
                                onDeselect: { viewModel.deselectPlayer(at: "Midfielder-5") },
                                context: .createTeam,
                                isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition("Midfielder-5")?.id,
                                onMakeCaptain: {
                                    if let id = viewModel.getPlayerForPosition("Midfielder-5")?.id {
                                        viewModel.setCaptain(playerId: id)
                                    }
                                }
                            )
                        }
                    }
                    
                    // Defenders
                    LazyHStack(spacing: defenderSpacing) {
                        ForEach(Array(viewModel.formationPositions.filter { $0.hasPrefix("Defender") }.enumerated()), id: \.offset) { index, position in
                            if viewModel.getSelectedPlayerCount() < 10 || viewModel.getPlayerForPosition(position) != nil {
                            TeamPlayerIconView(
                                position: position,
                                selectedPlayer: viewModel.getPlayerForPosition(position),
                                onTap: { onPlayerTap(position) },
                                onDeselect: { viewModel.deselectPlayer(at: position) },
                                context: .createTeam,
                                isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition(position)?.id,
                                onMakeCaptain: {
                                    if let id = viewModel.getPlayerForPosition(position)?.id {
                                        viewModel.setCaptain(playerId: id)
                                    }
                                }
                            )
                            }
                        }
                        
                        // Additional defender if allowed
                        if viewModel.additionalDefenderAllowed || viewModel.selectedPlayers["Defender-5"] != nil {
                            TeamPlayerIconView(
                                position: "Defender-5",
                                selectedPlayer: viewModel.getPlayerForPosition("Defender-5"),
                                onTap: { onPlayerTap("Defender-5") },
                                onDeselect: { viewModel.deselectPlayer(at: "Defender-5") },
                                context: .createTeam,
                                isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition("Defender-5")?.id,
                                onMakeCaptain: {
                                    if let id = viewModel.getPlayerForPosition("Defender-5")?.id {
                                        viewModel.setCaptain(playerId: id)
                                    }
                                }
                            )
                        }
                    }
                    
                    // Goalkeeper (bottom)
                    HStack {
                        TeamPlayerIconView(
                            position: "Goalkeeper",
                            selectedPlayer: viewModel.getPlayerForPosition("Goalkeeper"),
                            onTap: { onPlayerTap("Goalkeeper") },
                            onDeselect: { viewModel.deselectPlayer(at: "Goalkeeper") },
                            context: .createTeam,
                            isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition("Goalkeeper")?.id,
                            onMakeCaptain: {
                                if let id = viewModel.getPlayerForPosition("Goalkeeper")?.id {
                                    viewModel.setCaptain(playerId: id)
                                }
                            }
                        )
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
    
    // MARK: - Dynamic Spacing Calculations
    
    private var attackerSpacing: CGFloat {
        let baseAttackers = viewModel.formationPositions.filter { $0.hasPrefix("Attacker") }.count
        let additionalAttackers = (viewModel.additionalAttackerAllowed || viewModel.selectedPlayers["Attacker-3"] != nil) ? 1 : 0
        return FormationSpacingUtility.spacingForPositionGroup(baseCount: baseAttackers, additionalCount: additionalAttackers)
    }
    
    private var midfielderSpacing: CGFloat {
        let baseMidfielders = viewModel.formationPositions.filter { $0.hasPrefix("Midfielder") }.count
        let additionalMidfielders = (viewModel.additionalMidfielderAllowed || viewModel.selectedPlayers["Midfielder-5"] != nil) ? 1 : 0
        return FormationSpacingUtility.spacingForPositionGroup(baseCount: baseMidfielders, additionalCount: additionalMidfielders)
    }
    
    private var defenderSpacing: CGFloat {
        let baseDefenders = viewModel.formationPositions.filter { $0.hasPrefix("Defender") }.count
        let additionalDefenders = (viewModel.additionalDefenderAllowed || viewModel.selectedPlayers["Defender-5"] != nil) ? 1 : 0
        return FormationSpacingUtility.spacingForPositionGroup(baseCount: baseDefenders, additionalCount: additionalDefenders)
    }
}

private struct CreateTeamControls: View {
    let canCreateTeam: Bool
    let onCreateTeam: () -> Void
    @State private var isPressed: Bool = false
    @State private var showTapConfirmation: Bool = false
    
    var body: some View {
        Button(action: {
            if canCreateTeam {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                    showTapConfirmation = true
                }
            }
            onCreateTeam()
            // Reset confirmation if view stays
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showTapConfirmation = false
                }
            }
        }) {
            HStack {
                Image(systemName: showTapConfirmation ? "checkmark.circle.fill" : (canCreateTeam ? "plus.circle.fill" : "exclamationmark.circle.fill"))
                    .font(.title2)
                Text(canCreateTeam ? "Create Team" : "Complete Team Selection")
                    .font(.headline.weight(.semibold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        canCreateTeam ?
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(white: 0.92)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color(white: 0.95),
                                Color(white: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
        .disabled(!canCreateTeam)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        }, perform: {})
        .padding(.horizontal)
    }
}

private struct SelectedPlayersSummary: View {
    @ObservedObject var viewModel: CreateTeamViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Players")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(Array(viewModel.selectedPlayers.keys.sorted().enumerated()), id: \.offset) { index, position in
                    if let player = viewModel.getPlayerForPosition(position) {
                        HStack {
                            Text(player.name)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let price = player.price {
                                Text("£\(String(format: "%.1f", price))m")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    CreateTeamView()
}
