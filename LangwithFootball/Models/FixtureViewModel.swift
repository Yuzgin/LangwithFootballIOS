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
    @Published var isLoading: Bool = false
    @Published var hasLoaded: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private var timeoutTimer: Timer?

    func fetchFixtures() {
        // Reset state
        isLoading = true
        hasLoaded = false
        errorMessage = nil
        timeoutTimer?.invalidate()
        
        // Set up 5-second timeout
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.hasLoaded = true
            }
        }
        
        APIService.shared.fetchFixtures()
            // Make sure sink closures run on the main thread
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.timeoutTimer?.invalidate()
                self.isLoading = false
                self.hasLoaded = true
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load fixtures: \(error.localizedDescription)"
                    print("❌ Decoding or network error:", error)
                }
            }, receiveValue: { [weak self] fixtures in
                guard let self = self else { return }
                self.timeoutTimer?.invalidate()
                self.fixtures = fixtures
                self.isLoading = false
                self.hasLoaded = true
                print("✅ Loaded Fixtures:", fixtures)
            })
            .store(in: &cancellables)
    }
}

