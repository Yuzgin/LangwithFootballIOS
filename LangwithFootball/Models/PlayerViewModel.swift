//
//  PlayerViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class PlayerViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchPlayers() {
        APIService.shared.fetchPlayers()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load players: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] players in
                guard let self = self else { return }
                self.players = players
            })
            .store(in: &cancellables)
    }
}
