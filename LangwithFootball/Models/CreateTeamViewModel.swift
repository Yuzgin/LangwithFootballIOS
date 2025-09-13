//
//  CreateTeamViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class CreateTeamViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var selectedPlayers: [String: Int] = [:]
    @Published var teamName: String = ""
    @Published var budget: Double = 100.0
    @Published var selectedFormation: String = "4-4-2"
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var hasTeam: Bool = false
    @Published var isCheckingTeam: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    // Formation definitions matching the website logic
    private let formations = [
        "4-4-2": [
            "Defender-1", "Defender-2", "Defender-3", "Defender-4",
            "Midfielder-1", "Midfielder-2", "Midfielder-3", "Midfielder-4",
            "Attacker-1", "Attacker-2"
        ]
    ]
    
    var formationPositions: [String] {
        formations[selectedFormation] ?? []
    }
    
    init() {
        fetchPlayers()
        checkIfUserHasTeam()
    }
    
    func fetchPlayers() {
        APIService.shared.fetchPlayers()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load players: \(error.localizedDescription)"
                }
                self.isLoading = false
            }, receiveValue: { [weak self] players in
                guard let self = self else { return }
                self.players = players
            })
            .store(in: &cancellables)
    }
    
    func checkIfUserHasTeam() {
        // Reset checking flag whenever we perform the check
        isCheckingTeam = true

        APIService.shared.fetchTeam()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(_) = completion {
                    // On any failure assume user doesn't have a team
                    self.hasTeam = false
                    self.isCheckingTeam = false
                }
            }, receiveValue: { [weak self] team in
                guard let self = self else { return }
                self.hasTeam = true
                self.isCheckingTeam = false
            })
            .store(in: &cancellables)
    }
    
    func selectPlayer(playerId: Int, for position: String) {
        guard let player = players.first(where: { $0.id == playerId }),
              let price = player.price else { return }
        
        // Check if player is already selected
        if isPlayerSelected(playerId: playerId) {
            return
        }
        
        // Check budget
        if budget - price >= 0 {
            selectedPlayers[position] = playerId
            budget -= price
        }
    }
    
    func deselectPlayer(at position: String) {
        guard let playerId = selectedPlayers[position],
              let player = players.first(where: { $0.id == playerId }),
              let price = player.price else { return }
        
        selectedPlayers.removeValue(forKey: position)
        budget += price
    }
    
    func isPlayerSelected(playerId: Int) -> Bool {
        return selectedPlayers.values.contains(playerId)
    }
    
    func getSelectedPlayerCount() -> Int {
        return selectedPlayers.filter { $0.key != "Goalkeeper" }.count
    }
    
    func getPositionCount(type: String) -> Int {
        return selectedPlayers.keys.filter { $0.hasPrefix(type) }.count
    }
    
    // Formation validation logic from website
    var additionalDefenderAllowed: Bool {
        getPositionCount(type: "Defender") == 4 &&
        getPositionCount(type: "Midfielder") < 5 &&
        getPositionCount(type: "Attacker") < 3 &&
        getSelectedPlayerCount() <= 9
    }
    
    var additionalMidfielderAllowed: Bool {
        getPositionCount(type: "Midfielder") == 4 &&
        getPositionCount(type: "Defender") < 5 &&
        getPositionCount(type: "Attacker") < 3 &&
        getSelectedPlayerCount() <= 9
    }
    
    var additionalAttackerAllowed: Bool {
        getPositionCount(type: "Attacker") == 2 &&
        getPositionCount(type: "Midfielder") < 5 &&
        getPositionCount(type: "Defender") < 5 &&
        getSelectedPlayerCount() <= 9
    }
    
    var onlyOneAttackerAllowed: Bool {
        (getPositionCount(type: "Defender") == 4 && getPositionCount(type: "Midfielder") == 5) ||
        (getPositionCount(type: "Defender") == 5 && getPositionCount(type: "Midfielder") == 4)
    }
    
    func canCreateTeam() -> Bool {
        return getSelectedPlayerCount() == 10 && selectedPlayers["Goalkeeper"] != nil && !teamName.isEmpty
    }
    
    func createTeam() {
        guard canCreateTeam() else { return }
        
        let teamData = CreateTeamRequest(
            name: teamName,
            players: Array(selectedPlayers.values)
        )
        
        APIService.shared.createTeam(teamData: teamData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to create team: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] team in
                guard let self = self else { return }
                self.hasTeam = true
                // Clear the form
                self.selectedPlayers.removeAll()
                self.teamName = ""
                self.budget = 100.0
            })
            .store(in: &cancellables)
    }
    
    func getPlayerForPosition(_ position: String) -> Player? {
        guard let playerId = selectedPlayers[position] else { return nil }
        return players.first { $0.id == playerId }
    }
    
    func getPlayersForPosition(_ positionType: String) -> [Player] {
        return players.filter { $0.position == positionType }
    }
}

struct CreateTeamRequest: Codable {
    let name: String
    let players: [Int]
}
