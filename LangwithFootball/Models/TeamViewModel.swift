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
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchTeam() {
        APIService.shared.fetchTeam()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load team: \(error.localizedDescription)"
                    print("❌ Decoding or network error:", error)
                }
            }, receiveValue: { [weak self] team in
                guard let self = self else { return }
                self.team = team
                print("✅ Loaded team:", team)
            })
            .store(in: &cancellables)
    }
}
