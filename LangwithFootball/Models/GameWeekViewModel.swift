//
//  GameWeekViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class GameWeekViewModel: ObservableObject {
    @Published var gameWeeks: [GameWeek] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchGameWeeks() {
        APIService.shared.fetchGameWeeks()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load game weeks: \(error.localizedDescription)"
                    print("❌ Decoding or network error:", error)
                }
            }, receiveValue: { [weak self] weeks in
                guard let self = self else { return }
                self.gameWeeks = weeks
                print("✅ Loaded GameWeeks:", weeks)
            })
            .store(in: &cancellables)
    }
}
