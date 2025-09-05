////
//  AuthService.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import Foundation
import Combine

class AuthService {
    static let shared = AuthService()
    private let baseURL = "https://www.langwithfootball.com"
    
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
        guard let refresh = UserDefaults.standard.string(forKey: "refreshToken") else {
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
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccess = json["access"] as? String else {
                let err = NSError(domain: "", code: -5, userInfo: [NSLocalizedDescriptionKey: "Invalid refresh response"])
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
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(true))
            } else {
                let err = NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Registration failed"])
                completion(.failure(err))
            }
        }.resume()
    }
    
    /// Check login state
    func isLoggedIn() -> Bool {
        UserDefaults.standard.string(forKey: "accessToken") != nil
    }
}

