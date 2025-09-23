//
//  TeamSnapshotViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class TeamSnapshotViewModel: ObservableObject {
    @Published var snapshots: [TeamSnapshot] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()

    func fetchTeamSnapshots() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchTeamSnapshots()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load team snapshots: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] snapshots in
                guard let self = self else { return }
                self.snapshots = snapshots
            })
            .store(in: &cancellables)
    }
}
