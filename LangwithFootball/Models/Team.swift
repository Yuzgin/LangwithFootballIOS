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
    let captain: Player?
    let totalPoints: Int
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, players, captain
        case totalPoints = "total_points"
        case createdAt = "created_at"
    }

    init(id: Int, name: String, players: [Player], captain: Player?, totalPoints: Int, createdAt: String?) {
        self.id = id
        self.name = name
        self.players = players
        self.captain = captain
        self.totalPoints = totalPoints
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        // Some endpoints (e.g., team snapshots) embed a lightweight team object without players.
        // Default to an empty list if the key is missing.
        players = (try container.decodeIfPresent([Player].self, forKey: .players)) ?? []
        captain = try container.decodeIfPresent(Player.self, forKey: .captain)
        totalPoints = try container.decode(Int.self, forKey: .totalPoints)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }
}
