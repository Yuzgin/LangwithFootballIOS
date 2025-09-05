//
//  Team.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 02/05/2025.
//


import Foundation

struct Player: Codable, Identifiable {
    let id: Int
    let name: String
    let position: String
    // Add other fields as needed
}

struct Team: Codable {
    let id: Int
    let name: String
    let players: [Player]
    let totalPoints: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, players
        case totalPoints = "total_points"
        case createdAt = "created_at"
    }
}
