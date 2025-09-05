//
//  LoginView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
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
                    Button(action: handleLogin) {
                        HStack {
                            Text("Login")
                            if isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("Register")
                    }
                    
                    NavigationLink(destination: ForgotPasswordView()) {
                        Text("Forgot Password?")
                    }
                }
            }
            .navigationTitle("Login")
        }
    }
    
    private func handleLogin() {
        isLoading = true
        errorMessage = nil
        
        AuthService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    appState.isLoggedIn = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
