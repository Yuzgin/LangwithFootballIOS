//
//  FixtureViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class FixtureViewModel: ObservableObject {
    @Published var fixtures: [Fixture] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchFixtures() {
        APIService.shared.fetchFixtures()
            // Make sure sink closures run on the main thread
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load fixtures: \(error.localizedDescription)"
                    print("❌ Decoding or network error:", error)
                }
            }, receiveValue: { [weak self] fixtures in
                guard let self = self else { return }
                self.fixtures = fixtures
                print("✅ Loaded Fixtures:", fixtures)
            })
            .store(in: &cancellables)
    }
}

