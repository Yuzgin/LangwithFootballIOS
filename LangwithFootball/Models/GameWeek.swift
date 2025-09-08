import Foundation

struct GameWeek: Identifiable, Codable {
    let id: Int
    let week: Int
    let startDate: Date
    let endDate: Date

    enum CodingKeys: String, CodingKey {
        case id, week
        case startDate = "start_date"
        case endDate = "end_date"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        week = try container.decode(Int.self, forKey: .week)
        let startStr = try container.decode(String.self, forKey: .startDate)
        let endStr = try container.decode(String.self, forKey: .endDate)
        guard let start = GameWeek.dateFormatter.date(from: startStr),
              let end = GameWeek.dateFormatter.date(from: endStr) else {
            throw DecodingError.dataCorruptedError(forKey: .startDate, in: container, debugDescription: "Invalid date format")
        }
        startDate = start
        endDate = end
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
