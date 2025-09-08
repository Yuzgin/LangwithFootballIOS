import Foundation

struct PlayerGameStats: Identifiable, Codable {
    let id: Int
    let player: Player
    let match: Match
    let goals: Int
    let assists: Int
    let yellowCards: Int
    let redCards: Int
    let cleanSheets: Int
    let motm: Int
    let penSaves: Int
    let points: Int

    enum CodingKeys: String, CodingKey {
        case id, player, match, goals, assists, points
        case yellowCards = "yellow_cards"
        case redCards = "red_cards"
        case cleanSheets = "clean_sheets"
        case motm = "MOTM"
        case penSaves = "Pen_Saves"
    }
}
