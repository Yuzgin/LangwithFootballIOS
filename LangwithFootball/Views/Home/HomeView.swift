//
//  HomeView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.largeTitle)
            
            Spacer()
            
            Button("Logout") {
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                appState.isLoggedIn = false
            }
            .padding()
        }
        .padding()
    }
}
