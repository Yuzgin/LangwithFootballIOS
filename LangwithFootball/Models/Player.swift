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
    
    // Memberwise initializer for previews and testing
    init(id: Int, name: String, position: String, team: String?, goals: Int, assists: Int, yellowCards: Int, redCards: Int, cleanSheets: Int, gamesPlayed: Int, price: Double?, points: Int, motm: Int, penSaves: Int) {
        self.id = id
        self.name = name
        self.position = position
        self.team = team
        self.goals = goals
        self.assists = assists
        self.yellowCards = yellowCards
        self.redCards = redCards
        self.cleanSheets = cleanSheets
        self.gamesPlayed = gamesPlayed
        self.price = price
        self.points = points
        self.motm = motm
        self.penSaves = penSaves
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        position = try container.decode(String.self, forKey: .position)
        team = try container.decodeIfPresent(String.self, forKey: .team)
        goals = try container.decode(Int.self, forKey: .goals)
        assists = try container.decode(Int.self, forKey: .assists)
        yellowCards = try container.decode(Int.self, forKey: .yellowCards)
        redCards = try container.decode(Int.self, forKey: .redCards)
        cleanSheets = try container.decode(Int.self, forKey: .cleanSheets)
        gamesPlayed = try container.decode(Int.self, forKey: .gamesPlayed)
        points = try container.decode(Int.self, forKey: .points)
        motm = try container.decode(Int.self, forKey: .motm)
        penSaves = try container.decode(Int.self, forKey: .penSaves)
        
        // Handle price as either String or Double
        if let priceString = try? container.decode(String.self, forKey: .price) {
            price = Double(priceString)
        } else {
            price = try container.decodeIfPresent(Double.self, forKey: .price)
        }
    }
}
