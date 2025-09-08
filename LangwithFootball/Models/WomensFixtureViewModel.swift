//
//  WomensFixtureViewModel.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import SwiftUI
import Foundation
import Combine

final class WomensFixtureViewModel: ObservableObject {
    @Published var fixtures: [WomensFixture] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchWomensFixtures() {
        APIService.shared.fetchWomensFixtures()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load women's fixtures: \(error.localizedDescription)"
                    print("❌ Decoding or network error:", error)
                }
            }, receiveValue: { [weak self] fixtures in
                guard let self = self else { return }
                self.fixtures = fixtures
                print("✅ Loaded women's fixtures:", fixtures)
            })
            .store(in: &cancellables)
    }
}
