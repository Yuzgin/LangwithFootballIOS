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
    @State private var showingLeagueTable = false
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
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.title3)
                            .padding(.vertical, 8)
                    } else if let snapshot = getCurrentSnapshot() {
                        // Show fantasy card and formation for existing snapshot
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
                            playerWeeklyPoints: getWeeklyPointsForSnapshot(snapshot),
                            captain: snapshot.captain
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
                        
                        // League Position Card
                        LeaguePositionCard(
                            teamName: snapshot.team.name,
                            teamId: snapshot.team.id,
                            allSnapshots: viewModel.snapshots,
                            onTap: {
                                showingLeagueTable = true
                            }
                        )
                        .padding(.horizontal)
                        
                    } else if selectedGameWeek != nil {
                        // Show fantasy card for navigation but no formation/content for missing snapshot
                        if let team = teamViewModel.team {
                            CurrentTeamSnapshotCard(
                                teamName: team.name,
                                weeklyPoints: 0, // No points for missing gameweek
                                gameWeek: selectedGameWeek!,
                                selectedGameWeek: $selectedGameWeek,
                                allSnapshots: viewModel.snapshots,
                                gameWeeks: gameWeekViewModel.gameWeeks,
                                currentTeamId: team.id,
                                onTopTeamTap: {
                                    showingTopTeamSheet = true
                                }
                            )
                        } else {
                            // Team not loaded yet, show loading or fallback
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading team information...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        // Transfers Button (should be available even if no snapshot exists for this week)
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
                        
                        // Show message for missing snapshot
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)

                            if selectedGameWeek == 0 {
                                Text("Season starts on 1st October")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.primary)
                            } else {
                                Text("No Team for Gameweek \(selectedGameWeek!)")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                        
                    } else {
                        // Waiting for snapshots or team data — show loading
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // User doesn't have a team - show create team view or error
                    if let errorMessage = createTeamViewModel.errorMessage {
                        // Show error message if there was a problem checking team status
                        VStack(spacing: 16) {
                            Text("Error")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Retry") {
                                createTeamViewModel.checkIfUserHasTeam()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else {
                        // Show create team view
                        CreateTeamView()
                            .environmentObject(createTeamViewModel)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(showGateLoading ? 0 : 1)
            .padding()
            .overlay(alignment: .center) {
                // Central loading overlay, centered, with 0.5s hold after loading completes
                let isSnapshotLoading = createTeamViewModel.hasTeam && viewModel.isLoading
                let shouldShowOverlay = createTeamViewModel.isCheckingTeam || isSnapshotLoading
                if showGateLoading || shouldShowOverlay {
                    FantasyLoadingView()
                        .transition(.opacity)
                }
            }
            .onAppear { 
                showGateLoading = true
                // Only check team status first, then fetch other data based on result
                createTeamViewModel.checkIfUserHasTeam()
                
                // Fetch public data that doesn't require team existence
                gameWeekViewModel.fetchGameWeeks()
                playerGameStatsViewModel.fetchPlayerGameStats()
            }
            .onChange(of: createTeamViewModel.isCheckingTeam) {
                handleOverlayVisibility()
            }
            .onChange(of: createTeamViewModel.hasTeam) { _, hasTeam in
                handleOverlayVisibility()
                if hasTeam {
                    // User has a team, fetch team-specific data
                    viewModel.fetchTeamSnapshots()
                    teamViewModel.fetchTeam()
                }
            }
            .onChange(of: viewModel.snapshots.count) {
                handleOverlayVisibility()
                setInitialGameWeek()
            }
            .onChange(of: viewModel.isLoading) {
                handleOverlayVisibility()
                setInitialGameWeek()
            }
            .onChange(of: gameWeekViewModel.gameWeeks.count) {
                setInitialGameWeek()
            }
            .onChange(of: teamViewModel.team?.id) {
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
            .sheet(isPresented: $showingLeagueTable) {
                FantasyLeagueTableViewAllTeams()
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
        let isSnapshotLoading = createTeamViewModel.hasTeam && viewModel.isLoading
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
            // Return snapshot for selected gameweek, or nil if not found
            return userSnapshots.first { $0.gameWeek.week == selectedWeek }
        } else {
            // Return most recent snapshot for current user's team
            return userSnapshots.sorted(by: { $0.snapshotDate > $1.snapshotDate }).first
        }
    }
    
    private func getMostRecentSnapshot() -> TeamSnapshot? {
        // Get current user's team ID
        guard let currentTeamId = teamViewModel.team?.id else { return nil }
        
        // Filter snapshots to only include the current user's team
        let userSnapshots = viewModel.snapshots.filter { $0.team.id == currentTeamId }
        
        // Return most recent snapshot for current user's team
        return userSnapshots.sorted(by: { $0.snapshotDate > $1.snapshotDate }).first
    }
    
    private func getWeeklyPointsForSnapshot(_ snapshot: TeamSnapshot) -> [Int: Int] {
        // Use pre-calculated points from the team snapshot players, just like the React implementation
        var weeklyPoints: [Int: Int] = [:]
        
        for player in snapshot.players {
            weeklyPoints[player.id] = player.points
        }
        
        return weeklyPoints
    }
    
    private func setInitialGameWeek() {
        guard selectedGameWeek == nil else { return }
        guard let currentTeamId = teamViewModel.team?.id else { 
            return 
        }
        
        // If user has snapshots, set to the most recent gameweek that has a snapshot
        let userSnapshots = viewModel.snapshots.filter { $0.team.id == currentTeamId }
        let sortedSnapshots = userSnapshots.sorted(by: { $0.snapshotDate > $1.snapshotDate })
        if let mostRecentSnapshot = sortedSnapshots.first {
            selectedGameWeek = mostRecentSnapshot.gameWeek.week
        } else if !viewModel.isLoading {
            // User has no snapshots and loading is complete, set to current gameweek or fallback
            if !gameWeekViewModel.gameWeeks.isEmpty {
                let currentGameWeek = gameWeekViewModel.gameWeeks.first { $0.isCurrent }?.week ?? gameWeekViewModel.gameWeeks.first?.week ?? 0
                selectedGameWeek = currentGameWeek
            } else {
                // Fallback: set to week 0 if no gameweeks loaded
                selectedGameWeek = 0
            }
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
                            .foregroundStyle(.white.opacity(selectedGameWeek == 0 ? 0.3 : 0.8))
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(selectedGameWeek == 0 ? 0.1 : 0.25), lineWidth: 1.5)
                                )
                            let topPoints = getTopTeamPoints(for: selectedGameWeek ?? gameWeek)
                            Text("\(topPoints)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white.opacity(selectedGameWeek == 0 ? 0.3 : 1.0))
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(selectedGameWeek == 0)
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

// MARK: - League Position Card
private struct LeaguePositionCard: View {
    let teamName: String
    let teamId: Int
    let allSnapshots: [TeamSnapshot]
    let onTap: () -> Void
    @StateObject private var leaderboardVM = TeamViewModel()
    
    private var leaguePosition: Int {
        if !leaderboardVM.teams.isEmpty {
            let sorted = leaderboardVM.teams.sorted { a, b in
                if a.totalPoints == b.totalPoints { return a.name < b.name }
                return a.totalPoints > b.totalPoints
            }
            if let idx = sorted.firstIndex(where: { $0.id == teamId }) {
                return idx + 1
            }
            return sorted.count
        }
        return calculateLeaguePositionFromSnapshots()
    }
    
    private var totalTeams: Int {
        if !leaderboardVM.teams.isEmpty { return leaderboardVM.teams.count }
        let uniqueTeamIds = Set(allSnapshots.map { $0.team.id })
        return uniqueTeamIds.count
    }
    
    var body: some View {
        Button(action: { onTap() }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("League Position")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        Text(teamName)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Position")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Text("\(leaguePosition)")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.primary)
                            
                            Text("of \(totalTeams)")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            if leaderboardVM.teams.isEmpty {
                leaderboardVM.fetchTeams()
            }
        }
    }
    
    private func calculateLeaguePositionFromSnapshots() -> Int {
        // Calculate total points for each team across all gameweeks
        var teamTotalPoints: [Int: Int] = [:]
        
        for snapshot in allSnapshots {
            let teamId = snapshot.team.id
            teamTotalPoints[teamId, default: 0] += snapshot.weeklyPoints
        }
        
        // Sort teams by total points (descending)
        let sortedTeams = teamTotalPoints.sorted { $0.value > $1.value }
        
        // Find the position of the current team
        for (index, teamData) in sortedTeams.enumerated() {
            if teamData.key == teamId {
                return index + 1
            }
        }
        
        return totalTeams // Default to last position if not found
    }
    
    init(teamName: String, teamId: Int, allSnapshots: [TeamSnapshot], onTap: @escaping () -> Void) {
        self.teamName = teamName
        self.teamId = teamId
        self.allSnapshots = allSnapshots
        self.onTap = onTap
        _leaderboardVM = StateObject(wrappedValue: TeamViewModel())
    }
}


// MARK: - Fantasy League Table View
private struct FantasyLeagueTableView: View {
    let allSnapshots: [TeamSnapshot]

    private struct TeamStanding: Identifiable {
        let id: Int
        let name: String
        let totalPoints: Int
        let rank: Int
    }

    private var standings: [TeamStanding] {
        var totals: [Int: (name: String, points: Int)] = [:]
        for snapshot in allSnapshots {
            let id = snapshot.team.id
            let name = snapshot.team.name
            totals[id] = (name, (totals[id]?.points ?? 0) + snapshot.weeklyPoints)
        }
        let sorted = totals
            .map { (id, data) in (id: id, name: data.name, points: data.points) }
            .sorted { a, b in
                if a.points == b.points { return a.name < b.name }
                return a.points > b.points
            }
        return sorted.enumerated().map { index, item in
            TeamStanding(id: item.id, name: item.name, totalPoints: item.points, rank: index + 1)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Fantasy League Table")
                    .font(.title2.weight(.bold))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)

            List(standings) { standing in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Text("\(standing.rank)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(standing.name)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.primary)
                        Text("Total points")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(standing.totalPoints)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .listRowBackground(Color(.systemBackground))
            }
            .listStyle(.insetGrouped)
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Fantasy League Table View (All Teams via API)
private struct FantasyLeagueTableViewAllTeams: View {
    @StateObject private var teamVM = TeamViewModel()

    private struct TeamStanding: Identifiable {
        let id: Int
        let name: String
        let totalPoints: Int
        let rank: Int
    }

    private var standings: [TeamStanding] {
        let sorted = teamVM.teams.sorted { a, b in
            if a.totalPoints == b.totalPoints { return a.name < b.name }
            return a.totalPoints > b.totalPoints
        }
        return sorted.enumerated().map { index, team in
            TeamStanding(id: team.id, name: team.name, totalPoints: team.totalPoints, rank: index + 1)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Fantasy League Table")
                    .font(.title2.weight(.bold))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)

            if teamVM.teams.isEmpty {
                ProgressView()
                    .padding()
                    .onAppear {
                        teamVM.fetchTeams()
                    }
            } else {
                List(standings) { standing in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Text("\(standing.rank)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.blue)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(standing.name)
                                .font(.body.weight(.semibold))
                                .foregroundColor(.primary)
                            Text("Total points")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(standing.totalPoints)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .listRowBackground(Color(.systemBackground))
                }
                .listStyle(.insetGrouped)
            }
        }
        .presentationDetents([.medium, .large])
    }
}


#Preview {
    FantasyView()
}

