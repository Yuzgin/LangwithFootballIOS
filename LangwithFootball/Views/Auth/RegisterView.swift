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
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showingSuccessAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Account Details")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Password", text: $password)
                
                SecureField("Confirm Password", text: $confirmPassword)
            }
            
            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
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
                .disabled(!isFormValid || isLoading)
            }
        }
        .navigationTitle("Register")
        .alert("Registration Successful", isPresented: $showingSuccessAlert) {
            Button("OK") {
                // Clear form and return to login
                email = ""
                password = ""
                confirmPassword = ""
                errorMessage = nil
            }
        } message: {
            Text("Your account has been created successfully! Please log in with your credentials.")
        }
    }
    
    // MARK: - Validation
    private var isFormValid: Bool {
        return !email.isEmpty && 
               !password.isEmpty && 
               !confirmPassword.isEmpty &&
               isValidEmail(email) &&
               password == confirmPassword &&
               password.count >= 6
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validateForm() -> String? {
        if email.isEmpty {
            return "Email is required"
        }
        
        if !isValidEmail(email) {
            return "Please enter a valid email address"
        }
        
        if password.isEmpty {
            return "Password is required"
        }
        
        if password.count < 6 {
            return "Password must be at least 6 characters long"
        }
        
        if confirmPassword.isEmpty {
            return "Please confirm your password"
        }
        
        if password != confirmPassword {
            return "Passwords do not match"
        }
        
        return nil
    }
    
    private func handleRegister() {
        // Clear previous messages
        errorMessage = nil
        successMessage = nil
        
        // Validate form
        if let validationError = validateForm() {
            errorMessage = validationError
            return
        }
        
        isLoading = true
        
        AuthService.shared.register(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    showingSuccessAlert = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
