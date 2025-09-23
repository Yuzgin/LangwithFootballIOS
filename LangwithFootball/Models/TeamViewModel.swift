//
//  TeamViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class TeamViewModel: ObservableObject {
    @Published var team: Team?
    @Published var teams: [Team] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchTeam() {
        APIService.shared.fetchTeam()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load team: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] team in
                guard let self = self else { return }
                self.team = team
            })
            .store(in: &cancellables)
    }

    func fetchTeams() {
        APIService.shared.fetchTeams()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load leaderboard: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] teams in
                guard let self = self else { return }
                self.teams = teams
            })
            .store(in: &cancellables)
    }
}
