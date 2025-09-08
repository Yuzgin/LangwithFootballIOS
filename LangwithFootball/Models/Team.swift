//
//  Team.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 02/05/2025.
//


import Foundation

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
