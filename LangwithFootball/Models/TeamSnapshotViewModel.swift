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
    private var cancellables = Set<AnyCancellable>()

    func fetchTeamSnapshots() {
        APIService.shared.fetchTeamSnapshots()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load team snapshots: \(error.localizedDescription)"
                    print("❌ Decoding or network error:", error)
                }
            }, receiveValue: { [weak self] snapshots in
                guard let self = self else { return }
                self.snapshots = snapshots
                print("✅ Loaded team snapshots:", snapshots)
            })
            .store(in: &cancellables)
    }
}
