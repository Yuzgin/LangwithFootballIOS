//
//  TransferView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 27/05/2025.
//

import SwiftUI

struct TransferView: View {
    @StateObject private var viewModel = TransferViewModel()
    @State private var selectedPosition: String? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header card mirrors Create Team but shows existing team name and budget
                    TransferHeaderCard(teamName: $viewModel.teamName, budget: viewModel.budget)

                    // Formation pitch with tappable slots, prefilled from current team
                    TransferFormationView(
                        viewModel: viewModel,
                        onPlayerTap: { position in selectedPosition = position }
                    )

                    TransferControls(
                        canUpdateTeam: viewModel.canUpdateTeam(),
                        onUpdateTeam: {
                            viewModel.updateTeam { result in
                                switch result {
                                case .success:
                                    // Automatically dismiss the view on successful update
                                    dismiss()
                                case .failure(let error):
                                    // Surface error text
                                    viewModel.errorMessage = "Failed to update team: \(error.localizedDescription)"
                                }
                            }
                        }
                    )

                    // Optional: summary of currently selected players
                    if !viewModel.selectedPlayers.isEmpty {
                        TransferSelectedPlayersSummary(viewModel: viewModel)
                    }
                }
            }
            .padding()
            .opacity(viewModel.isLoading ? 0 : 1)
            
            // Loading overlay
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
            
            // Error overlay
            if let error = viewModel.errorMessage {
                VStack {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
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
    }
}

// MARK: - Local components to avoid cross-file private scope issues

private struct TransferHeaderCard: View {
    @Binding var teamName: String
    let budget: Double

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Transfers")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("Team:")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(String(teamName))
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

private struct TransferFormationView: View {
    @ObservedObject var viewModel: TransferViewModel
    let onPlayerTap: (String) -> Void

    var body: some View {
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
                    // Attackers
                    LazyHStack(spacing: attackerSpacing) {
                        ForEach(Array(viewModel.formationPositions.filter { $0.hasPrefix("Attacker") }.enumerated()), id: \.offset) { index, position in
                            if viewModel.getSelectedPlayerCount() < 10 || viewModel.getPlayerForPosition(position) != nil {
                                if position == "Attacker-2" && viewModel.onlyOneAttackerAllowed && viewModel.selectedPlayers["Attacker-2"] == nil {
                                    EmptyView()
                                } else {
                                    TeamPlayerIconView(
                                        position: position,
                                        selectedPlayer: viewModel.getPlayerForPosition(position),
                                        onTap: { onPlayerTap(position) },
                                        onDeselect: { viewModel.deselectPlayer(at: position) },
                                        context: .transfer,
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

                        if viewModel.additionalAttackerAllowed || viewModel.selectedPlayers["Attacker-3"] != nil {
                            TeamPlayerIconView(
                                position: "Attacker-3",
                                selectedPlayer: viewModel.getPlayerForPosition("Attacker-3"),
                                onTap: { onPlayerTap("Attacker-3") },
                                onDeselect: { viewModel.deselectPlayer(at: "Attacker-3") },
                                context: .transfer,
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
                                    context: .transfer,
                                    isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition(position)?.id,
                                    onMakeCaptain: {
                                        if let id = viewModel.getPlayerForPosition(position)?.id {
                                            viewModel.setCaptain(playerId: id)
                                        }
                                    }
                                )
                            }
                        }

                        if viewModel.additionalMidfielderAllowed || viewModel.selectedPlayers["Midfielder-5"] != nil {
                            TeamPlayerIconView(
                                position: "Midfielder-5",
                                selectedPlayer: viewModel.getPlayerForPosition("Midfielder-5"),
                                onTap: { onPlayerTap("Midfielder-5") },
                                onDeselect: { viewModel.deselectPlayer(at: "Midfielder-5") },
                                context: .transfer,
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
                                    context: .transfer,
                                    isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition(position)?.id,
                                    onMakeCaptain: {
                                        if let id = viewModel.getPlayerForPosition(position)?.id {
                                            viewModel.setCaptain(playerId: id)
                                        }
                                    }
                                )
                            }
                        }

                        if viewModel.additionalDefenderAllowed || viewModel.selectedPlayers["Defender-5"] != nil {
                            TeamPlayerIconView(
                                position: "Defender-5",
                                selectedPlayer: viewModel.getPlayerForPosition("Defender-5"),
                                onTap: { onPlayerTap("Defender-5") },
                                onDeselect: { viewModel.deselectPlayer(at: "Defender-5") },
                                context: .transfer,
                                isCaptain: viewModel.captainId != nil && viewModel.captainId == viewModel.getPlayerForPosition("Defender-5")?.id,
                                onMakeCaptain: {
                                    if let id = viewModel.getPlayerForPosition("Defender-5")?.id {
                                        viewModel.setCaptain(playerId: id)
                                    }
                                }
                            )
                        }
                    }

                    // Goalkeeper
                    HStack {
                        TeamPlayerIconView(
                            position: "Goalkeeper",
                            selectedPlayer: viewModel.getPlayerForPosition("Goalkeeper"),
                            onTap: { onPlayerTap("Goalkeeper") },
                            onDeselect: { viewModel.deselectPlayer(at: "Goalkeeper") },
                            context: .transfer,
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

private struct TransferSelectedPlayersSummary: View {
    @ObservedObject var viewModel: TransferViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Players")
                .font(.headline)
                .foregroundColor(.primary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
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

private struct TransferControls: View {
    let canUpdateTeam: Bool
    let onUpdateTeam: () -> Void
    @State private var showTapConfirmation: Bool = false

    var body: some View {
        Button(action: {
            if canUpdateTeam {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                    showTapConfirmation = true
                }
            }
            onUpdateTeam()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showTapConfirmation = false
                }
            }
        }) {
            HStack {
                Image(systemName: showTapConfirmation ? "checkmark.circle.fill" : (canUpdateTeam ? "arrow.triangle.2.circlepath.circle.fill" : "exclamationmark.circle.fill"))
                    .font(.title2)
                Text(canUpdateTeam ? "Update Team" : "Complete Team Selection")
                    .font(.headline.weight(.semibold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        canUpdateTeam ?
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
        .disabled(!canUpdateTeam)
        .padding(.horizontal)
    }
}

#Preview {
    TransferView()
}
