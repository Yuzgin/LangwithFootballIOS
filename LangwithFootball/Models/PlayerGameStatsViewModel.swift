//
//  PlayerGameStatsViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class PlayerGameStatsViewModel: ObservableObject {
    @Published var stats: [PlayerGameStats] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchPlayerGameStats() {
        APIService.shared.fetchPlayerGameStats()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load player game stats: \(error.localizedDescription)"
                    print("❌ Decoding or network error:", error)
                }
            }, receiveValue: { [weak self] stats in
                guard let self = self else { return }
                self.stats = stats
                print("✅ Loaded player game stats:", stats)
            })
            .store(in: &cancellables)
    }
}
