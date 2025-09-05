//
//  ResultViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class MatchViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchMatches() {
        APIService.shared.fetchMatches()
            // Make sure sink closures run on the main thread
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load matches: \(error.localizedDescription)"
                    print("❌ Decoding or network error:", error)
                }
            }, receiveValue: { [weak self] matches in
                guard let self = self else { return }
                self.matches = matches
                print("✅ Loaded matches:", matches)
            })
            .store(in: &cancellables)
    }
}
