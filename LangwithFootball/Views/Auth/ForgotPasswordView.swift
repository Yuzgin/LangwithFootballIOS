//
//  ForgotPasswordView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var message = ""
    @State private var showMessage = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Forgot Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: handleSubmit) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Sending..." : "Send Reset Link")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(email.isEmpty || isLoading)
                    .padding(.horizontal)
                    
                    if showMessage {
                        Text(message)
                            .foregroundColor(message.contains("Error") ? .red : .green)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handleSubmit() {
        guard !email.isEmpty else { return }
        
        isLoading = true
        message = ""
        showMessage = false
        
        AuthService.shared.sendPasswordReset(email: email) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    message = "Password reset email sent. Please check your inbox."
                    showMessage = true
                case .failure:
                    message = "Error sending password reset email. Please try again."
                    showMessage = true
                    
                }
            }
        }
    }
}
