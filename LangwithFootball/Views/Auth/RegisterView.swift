//
//  RegisterView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
            }
            
            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button(action: handleRegister) {
                    HStack {
                        Text("Register")
                        if isLoading {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
        }
        .navigationTitle("Register")
    }
    
    private func handleRegister() {
        isLoading = true
        errorMessage = nil
        
        AuthService.shared.register(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    appState.isLoggedIn = false
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
