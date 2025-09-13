//
//  TransferViewModel.swift
//  LangwithFootball
//
//  Created by GPT Assistant on 10/09/2025.
//

import SwiftUI
import Foundation
import Combine

final class TransferViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var selectedPlayers: [String: Int] = [:]
    @Published var teamName: String = ""
    @Published var budget: Double = 100.0
    @Published var selectedFormation: String = "4-4-2"
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

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
        // Load both players (catalog) and current team, then prefill
        let playersPublisher = APIService.shared.fetchPlayers()
        let teamPublisher = APIService.shared.fetchTeam()

        Publishers.Zip(playersPublisher, teamPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }, receiveValue: { [weak self] players, team in
                guard let self = self else { return }
                self.players = players
                self.teamName = team.name
                self.prefillSelectedPlayers(from: team)
                // Only set loading to false after prefill is complete
                self.isLoading = false
            })
            .store(in: &cancellables)
    }

    private func prefillSelectedPlayers(from team: Team) {
        // Map team players into formation slots deterministically by position order
        let gks = team.players.filter { $0.position == "Goalkeeper" }
        let defs = team.players.filter { $0.position == "Defender" }
        let mids = team.players.filter { $0.position == "Midfielder" }
        let atts = team.players.filter { $0.position == "Attacker" }

        var selections: [String: Int] = [:]

        if let gk = gks.first { selections["Goalkeeper"] = gk.id }
        for (index, d) in defs.prefix(5).enumerated() { selections["Defender-\(index + 1)"] = d.id }
        for (index, m) in mids.prefix(5).enumerated() { selections["Midfielder-\(index + 1)"] = m.id }
        for (index, a) in atts.prefix(3).enumerated() { selections["Attacker-\(index + 1)"] = a.id }

        selectedPlayers = selections

        // Compute remaining budget from 100 - sum(prices)
        let spent = selections.values.compactMap { id in
            players.first(where: { $0.id == id })?.price
        }.reduce(0.0, +)
        budget = max(0.0, 100.0 - spent)
    }

    func selectPlayer(playerId: Int, for position: String) {
        guard let player = players.first(where: { $0.id == playerId }),
              let price = player.price else { return }

        // Prevent duplicates
        if isPlayerSelected(playerId: playerId) { return }

        // Refund existing player's price at this position if any
        if let existingId = selectedPlayers[position],
           let existingPrice = players.first(where: { $0.id == existingId })?.price {
            budget += existingPrice
        }

        // Check budget after swap/purchase
        if budget - price >= 0 {
            selectedPlayers[position] = playerId
            budget -= price
        } else {
            // Revert refunded budget if we can't afford
            if let existingId = selectedPlayers[position],
               let existingPrice = players.first(where: { $0.id == existingId })?.price {
                budget = max(0, budget - existingPrice)
            }
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

    // Formation validation logic from website (same as CreateTeam)
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

    func getPlayerForPosition(_ position: String) -> Player? {
        guard let playerId = selectedPlayers[position] else { return nil }
        return players.first { $0.id == playerId }
    }

    func getPlayersForPosition(_ positionType: String) -> [Player] {
        return players.filter { $0.position == positionType }
    }

    // MARK: - Update Team
    func canUpdateTeam() -> Bool {
        return getSelectedPlayerCount() == 10 && selectedPlayers["Goalkeeper"] != nil
    }

    func updateTeam(completion: @escaping (Result<Team, Error>) -> Void) {
        guard canUpdateTeam() else { return }
        let payload = UpdateTeamRequest(players: Array(selectedPlayers.values), formation: selectedFormation)
        APIService.shared.updateTeam(teamData: payload)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case .failure(let error) = result { completion(.failure(error)) }
            }, receiveValue: { team in
                completion(.success(team))
            })
            .store(in: &cancellables)
    }
}

struct UpdateTeamRequest: Codable {
    let players: [Int]
    let formation: String
}


