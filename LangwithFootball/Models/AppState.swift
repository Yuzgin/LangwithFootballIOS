//
//  AppState.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

// Models/AppState.swift
import SwiftUI

final class AppState: ObservableObject {
    @Published public var isLoggedIn: Bool = false

    init() {
        self.isLoggedIn = AuthService.shared.isLoggedIn()
        
        // Listen for logout notifications
        NotificationCenter.default.addObserver(
            forName: .userLoggedOut,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isLoggedIn = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
