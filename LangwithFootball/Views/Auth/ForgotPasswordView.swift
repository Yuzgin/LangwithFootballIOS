//
//  ForgotPasswordView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Section {
                Button("Reset Password") {
                    // Implement password reset logic
                }
            }
        }
        .navigationTitle("Forgot Password")
    }
}
