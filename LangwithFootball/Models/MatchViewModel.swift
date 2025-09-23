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
    @Published var isLoading: Bool = false
    @Published var hasLoaded: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private var timeoutTimer: Timer?

    func fetchMatches() {
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
        
        APIService.shared.fetchMatches()
            // Make sure sink closures run on the main thread
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.timeoutTimer?.invalidate()
                self.isLoading = false
                self.hasLoaded = true
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load matches: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] matches in
                guard let self = self else { return }
                self.timeoutTimer?.invalidate()
                self.matches = matches
                self.isLoading = false
                self.hasLoaded = true
            })
            .store(in: &cancellables)
    }
}
