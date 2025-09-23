//
//  Result.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 01/06/2025.
//

import Foundation

struct Match: Identifiable, Codable, Equatable {
    let id: Int
    let date: Date
    let team1: String
    let team2: String
    let team1Score: Int
    let team2Score: Int
    let gameWeek: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case team1
        case team2
        case team1Score = "team1_score"
        case team2Score = "team2_score"
        case gameWeek = "game_week"
    }
}

struct MatchResponse: Codable {
    let results: [Match]
}
