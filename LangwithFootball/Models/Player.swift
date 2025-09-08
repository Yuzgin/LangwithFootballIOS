import Foundation

struct Player: Codable, Identifiable {
    let id: Int
    let name: String
    let position: String
    let team: String?
    let goals: Int
    let assists: Int
    let yellowCards: Int
    let redCards: Int
    let cleanSheets: Int
    let gamesPlayed: Int
    let price: Double?
    let points: Int
    let motm: Int
    let penSaves: Int

    enum CodingKeys: String, CodingKey {
        case id, name, position, team, goals, assists, price, points
        case yellowCards = "yellow_cards"
        case redCards = "red_cards"
        case cleanSheets = "clean_sheets"
        case gamesPlayed = "games_played"
        case motm = "MOTM"
        case penSaves = "Pen_Saves"
    }
}
