//
//  CurrentTeamSnapshotViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 27/05/2025.
//

import SwiftUI
import Foundation
import Combine

class CurrentTeamSnapshotViewModel: ObservableObject {
    @Published var currentSnapshot: TeamSnapshot?
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchCurrentTeamSnapshot() {
        APIService.shared.fetchTeamSnapshots()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load current team snapshot: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] snapshots in
                guard let self = self else { return }
                // Get the most recent snapshot (current team)
                self.currentSnapshot = snapshots.sorted { $0.snapshotDate > $1.snapshotDate }.first
            })
            .store(in: &cancellables)
    }
}
