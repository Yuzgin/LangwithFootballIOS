import Foundation

struct TeamSnapshot: Identifiable, Codable {
    let id: Int
    let team: Team
    let players: [Player]
    let gameWeek: GameWeek
    let snapshotDate: Date
    let weeklyPoints: Int
    let captain: Player?

    enum CodingKeys: String, CodingKey {
        case team, players
        case gameWeek = "game_week"
        case snapshotDate = "snapshot_date"
        case weeklyPoints = "weekly_points"
        case captain
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        team = try container.decode(Team.self, forKey: .team)
        players = try container.decode([Player].self, forKey: .players)
        gameWeek = try container.decode(GameWeek.self, forKey: .gameWeek)
        let dateStr = try container.decode(String.self, forKey: .snapshotDate)
        guard let date = TeamSnapshot.dateFormatter.date(from: dateStr) else {
            throw DecodingError.dataCorruptedError(forKey: .snapshotDate, in: container, debugDescription: "Invalid date format")
        }
        snapshotDate = date
        weeklyPoints = try container.decode(Int.self, forKey: .weeklyPoints)
        captain = try container.decodeIfPresent(Player.self, forKey: .captain)
        
        // Generate a unique ID from team ID and snapshot date
        id = team.id.hashValue ^ snapshotDate.hashValue
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
