////
//  AuthService.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import Foundation
import Combine

// Notification for when user needs to be logged out due to token issues
extension Notification.Name {
    static let userLoggedOut = Notification.Name("userLoggedOut")
}

class AuthService {
    static let shared = AuthService()
    private let baseURL = "https://www.langwithfootball.com"
    
    // Prevent concurrent refresh attempts
    private var isRefreshing = false
    private let refreshQueue = DispatchQueue(label: "refreshQueue", attributes: .concurrent)
    private let refreshSemaphore = DispatchSemaphore(value: 1)
    
    private init() {}
    
    /// Save both access and refresh tokens
    private func saveTokens(access: String, refresh: String) {
        UserDefaults.standard.set(access, forKey: "accessToken")
        UserDefaults.standard.set(refresh, forKey: "refreshToken")
    }
    
    /// Expose the saved access token for API requests
    var authToken: String? {
        UserDefaults.standard.string(forKey: "accessToken")
    }

    /// Refresh the access token using the saved refresh token
    private func refreshAccessToken(completion: @escaping (Result<Void, Error>) -> Void) {
        // Prevent concurrent refresh attempts
        refreshQueue.async(flags: .barrier) {
            guard !self.isRefreshing else {
                // If already refreshing, wait for it to complete
                DispatchQueue.global().async {
                    self.refreshSemaphore.wait()
                    self.refreshSemaphore.signal()
                    // Try again after the current refresh completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.refreshAccessToken(completion: completion)
                    }
                }
                return
            }
            
            self.isRefreshing = true
            self.refreshSemaphore.wait()
        }
        
        guard let refresh = UserDefaults.standard.string(forKey: "refreshToken") else {
            self.isRefreshing = false
            self.refreshSemaphore.signal()
            let err = NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No refresh token available"])
            completion(.failure(err))
            return
        }

        let url = URL(string: "\(baseURL)/api/token/refresh/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["refresh": refresh]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                self.isRefreshing = false
                self.refreshSemaphore.signal()
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }

            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    // Success - continue processing
                    break
                case 401:
                    // Refresh token is invalid/expired
                    let err = NSError(domain: "", code: -6, userInfo: [NSLocalizedDescriptionKey: "Refresh token expired or invalid"])
                    completion(.failure(err))
                    return
                case 400:
                    // Bad request - refresh token malformed
                    let err = NSError(domain: "", code: -7, userInfo: [NSLocalizedDescriptionKey: "Invalid refresh token format"])
                    completion(.failure(err))
                    return
                default:
                    // Other server errors
                    let err = NSError(domain: "", code: -8, userInfo: [NSLocalizedDescriptionKey: "Server error during token refresh: \(httpResponse.statusCode)"])
                    completion(.failure(err))
                    return
                }
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccess = json["access"] as? String else {
                let err = NSError(domain: "", code: -5, userInfo: [NSLocalizedDescriptionKey: "Invalid refresh response format"])
                completion(.failure(err))
                return
            }

            UserDefaults.standard.set(newAccess, forKey: "accessToken")
            completion(.success(()))
        }.resume()
    }

    /// Publisher wrapper for refreshing tokens
    func refreshTokensPublisher() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.refreshAccessToken { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Log in and store tokens
    func login(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(err))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access"] as? String,
                   let refreshToken = json["refresh"] as? String {
                    self.saveTokens(access: accessToken, refresh: refreshToken)
                    completion(.success(true))
                } else {
                    let err = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    completion(.failure(err))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Register new user
    func register(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/user/register/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Debug logging (removed unused variables)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let err = NSError(domain: "", code: -10, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                completion(.failure(err))
                return
            }
            
            // Debug logging for response (removed unused variables)
            
            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(true))
            case 400:
                // Bad request - try to parse error message from response
                var errorMessage = "Invalid registration data"
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let detail = json["detail"] as? String {
                        errorMessage = detail
                    } else if let message = json["message"] as? String {
                        errorMessage = message
                    } else if let errors = json["errors"] as? [String: Any] {
                        // Handle validation errors
                        let errorMessages = errors.compactMap { key, value in
                            if let valueArray = value as? [String] {
                                return "\(key): \(valueArray.joined(separator: ", "))"
                            }
                            return "\(key): \(value)"
                        }
                        errorMessage = errorMessages.joined(separator: "; ")
                    }
                }
                let err = NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                completion(.failure(err))
            case 409:
                let err = NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "An account with this email already exists"])
                completion(.failure(err))
            case 422:
                let err = NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid email format or password requirements not met"])
                completion(.failure(err))
            case 500...599:
                let err = NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Server error. Please try again later"])
                completion(.failure(err))
            default:
                let err = NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Registration failed with status code: \(httpResponse.statusCode)"])
                completion(.failure(err))
            }
        }.resume()
    }
    
    /// Check login state
    func isLoggedIn() -> Bool {
        UserDefaults.standard.string(forKey: "accessToken") != nil
    }
    
    /// Logout user and clear all tokens
    func logout() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        isRefreshing = false
        // Notify UI that user has been logged out
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)
    }
    
    /// Check if refresh token is expired (basic check)
    private func isRefreshTokenExpired() -> Bool {
        // For now, we'll let the server handle refresh token validation
        // In a production app, you might want to decode the JWT to check expiration
        return false
    }
    
    /// Send password reset email
    func sendPasswordReset(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/password-reset/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(true))
            } else {
                let err = NSError(domain: "", code: -9, userInfo: [NSLocalizedDescriptionKey: "Failed to send password reset email"])
                completion(.failure(err))
            }
        }.resume()
    }
}

