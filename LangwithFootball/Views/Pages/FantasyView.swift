//
//  FantasyView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 27/05/2025.
//

import SwiftUI

struct FantasyView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = TeamSnapshotViewModel()
    @StateObject private var createTeamViewModel = CreateTeamViewModel()
    @StateObject private var gameWeekViewModel = GameWeekViewModel()
    @StateObject private var playerGameStatsViewModel = PlayerGameStatsViewModel()
    @StateObject private var teamViewModel = TeamViewModel()
    @State private var showingTransferView = false
    @State private var showingTopTeamSheet = false
    @State private var refreshTrigger = false
    @State private var showGateLoading = true
    @State private var selectedGameWeek: Int? = nil
    

    var body: some View {
        if appState.isLoggedIn {
            // Show fantasy content when logged in
            VStack(alignment: .leading, spacing: 20) {
                if createTeamViewModel.isCheckingTeam {
                    // Under overlay, keep content empty to avoid layout jumps
                    EmptyView()
                } else if createTeamViewModel.hasTeam {
                    // User has a team - show normal fantasy view
                    if let snapshot = getCurrentSnapshot() {
                        CurrentTeamSnapshotCard(
                            teamName: snapshot.team.name,
                            weeklyPoints: snapshot.weeklyPoints,
                            gameWeek: snapshot.gameWeek.week,
                            selectedGameWeek: $selectedGameWeek,
                            allSnapshots: viewModel.snapshots,
                            gameWeeks: gameWeekViewModel.gameWeeks,
                            currentTeamId: snapshot.team.id,
                            onTopTeamTap: {
                                showingTopTeamSheet = true
                            }
                        )

                        FormationView(
                            players: snapshot.players,
                            playerWeeklyPoints: getWeeklyPointsForSnapshot(snapshot)
                        )
                        .transition(.opacity)
                        
                        // Transfers Button
                        Button(action: {
                            showingTransferView = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.title2)
                                Text("Make Transfers")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white,
                                                Color(white: 0.92)
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
                        .padding(.horizontal)
                        
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.title3)
                            .padding(.vertical, 8)
                    } else {
                        // Waiting for snapshots — overlay handles loading UI
                        EmptyView()
                    }
                } else {
                    // User doesn't have a team - show create team view
                    CreateTeamView()
                        .environmentObject(createTeamViewModel)
                        .onAppear {
                            // Refresh team status when view appears
                            createTeamViewModel.checkIfUserHasTeam()
                        }
                        .onChange(of: createTeamViewModel.hasTeam) { hasTeam in
                            if hasTeam {
                                viewModel.fetchTeamSnapshots()
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(showGateLoading ? 0 : 1)
            .padding()
            .overlay(alignment: .center) {
                // Central loading overlay, centered, with 0.5s hold after loading completes
                let isSnapshotLoading = createTeamViewModel.hasTeam && viewModel.snapshots.isEmpty && viewModel.errorMessage == nil
                let shouldShowOverlay = createTeamViewModel.isCheckingTeam || isSnapshotLoading
                if showGateLoading || shouldShowOverlay {
                    FantasyLoadingView()
                        .transition(.opacity)
                }
            }
            .onAppear { 
                showGateLoading = true
                viewModel.fetchTeamSnapshots()
                createTeamViewModel.checkIfUserHasTeam()
                gameWeekViewModel.fetchGameWeeks()
                playerGameStatsViewModel.fetchPlayerGameStats()
                teamViewModel.fetchTeam()
            }
            .onChange(of: createTeamViewModel.isCheckingTeam) { _ in
                handleOverlayVisibility()
            }
            .onChange(of: createTeamViewModel.hasTeam) { _ in
                handleOverlayVisibility()
            }
            .onChange(of: viewModel.snapshots.count) { _ in
                handleOverlayVisibility()
                setInitialGameWeek()
            }
            .onChange(of: gameWeekViewModel.gameWeeks.count) { _ in
                setInitialGameWeek()
            }
            .onChange(of: teamViewModel.team?.id) { _ in
                setInitialGameWeek()
            }
            .sheet(isPresented: $showingTransferView) {
                TransferView()
            }
            .sheet(isPresented: $showingTopTeamSheet) {
                TopTeamSheetView(
                    gameWeek: selectedGameWeek ?? (viewModel.snapshots.first?.gameWeek.week ?? 1),
                    allSnapshots: viewModel.snapshots,
                    playerGameStats: playerGameStatsViewModel.stats
                )
            }
        } else {
            // Show login form when not logged in
            LoginView()
        }
    }
}

private struct FantasyLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(alignment: .center)
    }
}

// MARK: - Overlay Visibility Handling
extension FantasyView {
    private func handleOverlayVisibility() {
        let isSnapshotLoading = createTeamViewModel.hasTeam && viewModel.snapshots.isEmpty && viewModel.errorMessage == nil
        let shouldShowOverlay = createTeamViewModel.isCheckingTeam || isSnapshotLoading
        if shouldShowOverlay {
            if !showGateLoading {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showGateLoading = true
                }
            }
        } else {
            if showGateLoading {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showGateLoading = false
                }
            }
        }
    }
    
    private func getCurrentSnapshot() -> TeamSnapshot? {
        // Get current user's team ID
        guard let currentTeamId = teamViewModel.team?.id else { return nil }
        
        // Filter snapshots to only include the current user's team
        let userSnapshots = viewModel.snapshots.filter { $0.team.id == currentTeamId }
        
        if let selectedWeek = selectedGameWeek {
            // Return snapshot for selected gameweek, or most recent if not found
            return userSnapshots.first { $0.gameWeek.week == selectedWeek } 
                ?? userSnapshots.sorted(by: { $0.snapshotDate > $1.snapshotDate }).first
        } else {
            // Return most recent snapshot for current user's team
            return userSnapshots.sorted(by: { $0.snapshotDate > $1.snapshotDate }).first
        }
    }
    
    private func getWeeklyPointsForSnapshot(_ snapshot: TeamSnapshot) -> [Int: Int] {
        let gameWeekId = snapshot.gameWeek.id
        
        // Filter game stats to only include those for the selected gameweek
        let filteredStats = playerGameStatsViewModel.stats.filter { stat in
            stat.match.gameWeek == gameWeekId
        }
        
        // Group stats by player ID and sum up points for each player
        var weeklyPoints: [Int: Int] = [:]
        
        for stat in filteredStats {
            let playerId = stat.player.id
            weeklyPoints[playerId, default: 0] += stat.points
        }
        
        // For players in the snapshot who don't have game stats for this week, set points to 0
        for player in snapshot.players {
            if weeklyPoints[player.id] == nil {
                weeklyPoints[player.id] = 0
            }
        }
        
        return weeklyPoints
    }
    
    private func setInitialGameWeek() {
        guard selectedGameWeek == nil else { return }
        guard !viewModel.snapshots.isEmpty && !gameWeekViewModel.gameWeeks.isEmpty else { return }
        guard let currentTeamId = teamViewModel.team?.id else { return }
        
        // Set to the most recent gameweek that has a snapshot for the current user's team
        let userSnapshots = viewModel.snapshots.filter { $0.team.id == currentTeamId }
        let sortedSnapshots = userSnapshots.sorted(by: { $0.snapshotDate > $1.snapshotDate })
        if let mostRecentSnapshot = sortedSnapshots.first {
            selectedGameWeek = mostRecentSnapshot.gameWeek.week
        }
    }
}

private struct CurrentTeamSnapshotCard: View {
    let teamName: String
    let weeklyPoints: Int
    let gameWeek: Int
    @Binding var selectedGameWeek: Int?
    let allSnapshots: [TeamSnapshot]
    let gameWeeks: [GameWeek]
    let currentTeamId: Int
    let onTopTeamTap: () -> Void
    
    private var availableGameWeeks: [Int] {
        // Get all gameweeks from 1 up to the maximum week that has a snapshot
        let maxWeek = allSnapshots.map { $0.gameWeek.week }.max() ?? 1
        return Array(1...maxWeek)
    }
    
    private var canGoPrevious: Bool {
        let currentWeek = selectedGameWeek ?? gameWeek
        return currentWeek > 1
    }
    
    private var canGoNext: Bool {
        let currentWeek = selectedGameWeek ?? gameWeek
        let maxWeek = allSnapshots.map { $0.gameWeek.week }.max() ?? 1
        return currentWeek < maxWeek
    }

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Team name and gameweek at the top
            VStack(alignment: .center, spacing: 12) {
                Text(teamName)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                
                // Gameweek with navigation buttons
                HStack(spacing: 16) {
                    Button(action: previousGameWeek) {
                        Image(systemName: "chevron.left")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(canGoPrevious ? .white : .white.opacity(0.3))
                    }
                    .disabled(!canGoPrevious)
                    
                    Text("Gameweek \(selectedGameWeek ?? gameWeek)")
                        .font(.title2)
                        .foregroundStyle(.white)
                    
                    Button(action: nextGameWeek) {
                        Image(systemName: "chevron.right")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(canGoNext ? .white : .white.opacity(0.3))
                    }
                    .disabled(!canGoNext)
                }
            }
            
            HStack(spacing: 25) {
                // Average Points (Left)
                VStack(alignment: .center, spacing: 4) {
                    Text("Avg Points")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
                            )
                        let avgPoints = getAveragePoints(for: selectedGameWeek ?? gameWeek)
                        Text("\(Int(avgPoints.rounded()))")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
                
                // Current Team Points (Center)
                VStack(alignment: .center, spacing: 4) {
                    Text("Your Points")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white.opacity(0.25), lineWidth: 2)
                            )
                        Text("\(weeklyPoints)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .accessibilityLabel("Points \(weeklyPoints)")
                    }
                }
                
                Spacer()
                
                // Top Team Points (Right) - tappable
                Button(action: {
                    onTopTeamTap()
                }) {
                    VStack(alignment: .center, spacing: 4) {
                        Text("Highest")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.8))
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
                                )
                            let topPoints = getTopTeamPoints(for: selectedGameWeek ?? gameWeek)
                            Text("\(topPoints)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
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
        .accessibilityElement(children: .combine)
        .id("\(allSnapshots.count)-\(selectedGameWeek ?? gameWeek)")
    }
    
    private func previousGameWeek() {
        guard canGoPrevious else { return }
        let currentWeek = selectedGameWeek ?? gameWeek
        selectedGameWeek = currentWeek - 1
    }
    
    private func nextGameWeek() {
        guard canGoNext else { return }
        let currentWeek = selectedGameWeek ?? gameWeek
        selectedGameWeek = currentWeek + 1
    }
    
    // MARK: - Helper Functions
    private func getAveragePoints(for gameWeek: Int) -> Double {
        let snapshotsForWeek = allSnapshots.filter { $0.gameWeek.week == gameWeek }
        guard !snapshotsForWeek.isEmpty else { return 0.0 }
        
        let totalPoints = snapshotsForWeek.reduce(0) { $0 + $1.weeklyPoints }
        return Double(totalPoints) / Double(snapshotsForWeek.count)
    }

    private func getTopTeamPoints(for gameWeek: Int) -> Int {
        let snapshotsForWeek = allSnapshots.filter { $0.gameWeek.week == gameWeek }
        return snapshotsForWeek.map { $0.weeklyPoints }.max() ?? 0
    }

    private func getTopSnapshot(for gameWeek: Int) -> TeamSnapshot? {
        let snapshotsForWeek = allSnapshots.filter { $0.gameWeek.week == gameWeek }
        return snapshotsForWeek.max(by: { $0.weeklyPoints < $1.weeklyPoints })
    }
}


#Preview {
    FantasyView()
}

