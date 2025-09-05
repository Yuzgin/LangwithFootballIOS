//
//  LangwithFootballModels.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import SwiftUI
import Foundation
import Combine

class FantasyViewModel: ObservableObject {
    @Published var team: Team?
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchTeam() {
        APIService.shared.fetchTeam()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load team: \(error.localizedDescription)"
                }
            }, receiveValue: { team in
                self.team = team
            })
            .store(in: &cancellables)
    }
}
