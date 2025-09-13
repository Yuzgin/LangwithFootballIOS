//
//  APIService.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import Foundation
import Combine

class APIService {
    static let shared = APIService()
    private let baseURL = URL(string: "https://www.langwithfootball.com")!

    private enum APIError: Error {
        case unauthorized
    }
    
    private init() {}
    
    /// Build a URLRequest and attach the JWT if available
    // 🔓 Public (no token)
    private func makePublicRequest(path: String, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        return request
    }

    // 🔐 Authenticated (attaches JWT)
    private func makeAuthRequest(path: String, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method

        if let token = AuthService.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ No auth token found for path: \(path)")
        }

        return request
    }

    /// Perform an authenticated request, attempting token refresh on 401 responses
    private func performAuthorizedRequest(path: String, method: String = "GET", retry: Bool = true) -> AnyPublisher<Data, Error> {
        let request = makeAuthRequest(path: path, method: method)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .mapError { $0 as Error }
            .catch { [weak self] error -> AnyPublisher<Data, Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                if retry, let apiError = error as? APIError, apiError == .unauthorized {
                    return AuthService.shared.refreshTokensPublisher()
                        .flatMap { _ in
                            self.performAuthorizedRequest(path: path, method: method, retry: false)
                        }
                        .catch { refreshError -> AnyPublisher<Data, Error> in
                            // If refresh fails, logout user and return error
                            print("❌ Token refresh failed: \(refreshError)")
                            AuthService.shared.logout()
                            return Fail(error: refreshError).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Fetch all players
    func fetchPlayers() -> AnyPublisher<[Player], Error> {
        return performAuthorizedRequest(path: "/api/players/")
            .decode(type: [Player].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    /// Fetch the current user's team
    func fetchTeam() -> AnyPublisher<Team, Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return performAuthorizedRequest(path: "/api/team/")
            // Peek at the raw response body
            .handleEvents(receiveOutput: { data in
                if let body = String(data: data, encoding: .utf8) {
                    print("📦 Response body:\n\(body)")
                } else {
                    print("📦 Response body (non-UTF8, \(data.count) bytes)")
                }
            })
            .decode(type: Team.self, decoder: decoder)
            .mapError { error in
                // Helpful debug for decoding or transport errors
                print("❌ fetchTeam error:", error)
                return error
            }
            .eraseToAnyPublisher()
    }
    
    
    /// Delete the current user's team
    func deleteTeam() -> AnyPublisher<Void, Error> {
        return performAuthorizedRequest(path: "/api/team/delete/", method: "DELETE")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// Fetch all Results
    func fetchMatches() -> AnyPublisher<[Match], Error> {
        let request = makePublicRequest(path: "/api/results/")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                // 📡 Debug: print HTTP status code
                if let httpResponse = result.response as? HTTPURLResponse {
                    print("📡 Status code:", httpResponse.statusCode)
                }

                // 📦 Debug: print raw response body
                if let body = String(data: result.data, encoding: .utf8) {
                    print("📦 Response body:\n\(body)")
                }

                // ❌ Throw error if not 2xx status
                guard let response = result.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }

                return result.data
            }
            .decode(type: [Match].self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    /// Fetch all Fixtures
    func fetchFixtures() -> AnyPublisher<[Fixture], Error> {
        let request = makePublicRequest(path: "/api/fixtures/")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { fixture in
                // 📡 Debug: print HTTP status code
                if let httpResponse = fixture.response as? HTTPURLResponse {
                    print("📡 Status code:", httpResponse.statusCode)
                }

                // 📦 Debug: print raw response body
                if let body = String(data: fixture.data, encoding: .utf8) {
                    print("📦 Response body:\n\(body)")
                }

                // ❌ Throw error if not 2xx status
                guard let response = fixture.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }

                return fixture.data
            }
            .decode(type: [Fixture].self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// Fetch all GameWeeks
    func fetchGameWeeks() -> AnyPublisher<[GameWeek], Error> {
        let request = makePublicRequest(path: "/api/gameweeks/")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: [GameWeek].self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// Fetch all PlayerGameStats
    func fetchPlayerGameStats() -> AnyPublisher<[PlayerGameStats], Error> {
        let request = makePublicRequest(path: "/api/playergamestats/")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: [PlayerGameStats].self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// Fetch all Team Snapshots
    func fetchTeamSnapshots() -> AnyPublisher<[TeamSnapshot], Error> {
        return performAuthorizedRequest(path: "/api/team-snapshots/")
            .decode(type: [TeamSnapshot].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    /// Fetch all Women's Fixtures
    func fetchWomensFixtures() -> AnyPublisher<[WomensFixture], Error> {
        let request = makePublicRequest(path: "/api/womensfixtures/")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: [WomensFixture].self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    /// Create a new team
    func createTeam(teamData: CreateTeamRequest) -> AnyPublisher<Team, Error> {
        return performAuthorizedRequestWithBody(path: "/api/team/", method: "POST", body: teamData)
            .decode(type: Team.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .eraseToAnyPublisher()
    }

    /// Update existing team (players and formation)
    func updateTeam(teamData: UpdateTeamRequest) -> AnyPublisher<Team, Error> {
        return performAuthorizedRequestWithBody(path: "/api/team/", method: "PUT", body: teamData)
            .decode(type: Team.self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .eraseToAnyPublisher()
    }
    
    /// Perform an authenticated request with JSON body, attempting token refresh on 401 responses
    private func performAuthorizedRequestWithBody<T: Codable>(path: String, method: String, body: T) -> AnyPublisher<Data, Error> {
        var request = makeAuthRequest(path: path, method: method)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .mapError { $0 as Error }
            .catch { [weak self] error -> AnyPublisher<Data, Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                if let apiError = error as? APIError, apiError == .unauthorized {
                    return AuthService.shared.refreshTokensPublisher()
                        .flatMap { _ in
                            self.performAuthorizedRequestWithBody(path: path, method: method, body: body)
                        }
                        .catch { refreshError -> AnyPublisher<Data, Error> in
                            // If refresh fails, logout user and return error
                            print("❌ Token refresh failed: \(refreshError)")
                            AuthService.shared.logout()
                            return Fail(error: refreshError).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
