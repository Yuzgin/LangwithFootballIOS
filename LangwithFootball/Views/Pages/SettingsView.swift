//
//  SettingsView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 27/05/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingLoginView = false
    @State private var showLogoutConfirm = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            if appState.isLoggedIn {
                // Show logout button when logged in
                VStack(spacing: 16) {
                    Text("Welcome to Settings!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("Logout") {
                        showLogoutConfirm = true
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                    )
                    .padding(.horizontal)
                }
            } else {
                // Show login button when not logged in
                VStack(spacing: 16) {
                    Text("Please log in to access settings")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("Login") {
                        showingLoginView = true
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                    )
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingLoginView) {
            LoginView()
        }
        .onChange(of: appState.isLoggedIn) { _, isLoggedIn in
            // Dismiss the login sheet when user successfully logs in
            if isLoggedIn {
                showingLoginView = false
            }
        }
        .alert("Are you sure you want to logout?", isPresented: $showLogoutConfirm) {
            Button("Logout", role: .destructive) {
                AuthService.shared.logout()
                appState.isLoggedIn = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You will need to log in again.")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
